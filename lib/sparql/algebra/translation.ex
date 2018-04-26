defmodule SPARQL.Algebra.Translation do
  @moduledoc """
  Translation of ASTs of the `SPARQL.Language.Decoder` into a `SPARQL.Algebra.Expression`.

  <https://www.w3.org/TR/sparql11-query/#sparqlQuery>
  """

  alias RDF.IRI


  @no_mapping nil

  def translate(ast, prefixes, base, options \\ %{}) do
    with state = %{expr: ast},
         {:ok, state} <-
           # 18.2.2 Converting Graph Patterns
           convert_graph_patterns(state, prefixes, base, options),

#         {:ok, state} <-
#           # 18.2.4.1 Grouping and Aggregation - Step: GROUP BY
#           group(...) # https://www.w3.org/TR/sparql11-query/#defn_algGroup

         {:ok, state} <-
           # 18.2.4.1 Grouping and Aggregation - Step: Aggregates
           convert_aggregates(state),

         {:ok, state} <-
           # 18.2.4.2 HAVING
           convert_having(state),

         {:ok, state} <-
           # 18.2.4.3 VALUES
           convert_final_values_clause(state),

         {:ok, state} <-
           # 18.2.4.4 SELECT Expressions
           convert_select(state),

         {:ok, state} <-
           # 18.2.5 Converting Solution Modifiers
           convert_solution_modifiers(state)
    do
      {:ok, state.expr}
    end
  end


  ############################################################################
  # 18.2.2 Converting Graph Patterns

  @doc """
  Translates a SPARQL graph pattern into a `SPARQL.Algebra.Expression`

  This process is applied to the group graph pattern (the unit between `{...}` delimiters)
  forming the `WHERE` clause of a query, and recursively to each syntactic element
  within the group graph pattern.

  The result of the translation is a `SPARQL.Algebra.Expression`.

  <https://www.w3.org/TR/sparql11-query/#convertGraphPattern>
  """
  defp convert_graph_patterns(state, prefixes, base, _options) do
    with {:ok, ast} <-
            # 18.2.2.1 Expand Syntax Forms
            expand_syntax_forms(state.expr, prefixes, base),

         {:ok, ast} <-
            # 18.2.2.2 Collect FILTER Elements
            collect_filter_elements(ast),

         {:ok, ast} <-
            # 18.2.2.3 Translate Property Path Expressions
            translate_property_path_expressions(ast),

         {:ok, ast} <-
            # 18.2.2.4 Translate Property Path Patterns
            translate_property_path_patterns(ast),

         {:ok, ast} <-
            # 18.2.2.5 Translate Basic Graph Patterns
            translate_basic_graph_patterns(ast),

         {:ok, ast} <-
            # 18.2.2.6 Translate Graph Patterns
            translate_graph_patterns(ast),

         {:ok, ast} <-
            # 18.2.2.7 Filters of Group
            add_filters_of_group(ast),

         {:ok, ast} <-
            # 18.2.2.8 Simplification step
            simplification(ast)
    do
      {:ok, %{state | expr: ast}}
    end
  end


  @doc """
  Expand Syntax Forms

  Expand abbreviations for IRIs and triple patterns.

  We also replace some AST elements with more natural representations:

  - variables as atoms

  <https://www.w3.org/TR/sparql11-query/#sparqlExpandForms>
  """
  defp expand_syntax_forms(ast, prefixes, base) do
    {:ok, map(ast, %{prefixes: prefixes, base: base}, &expand_syntax_form/2)}
  end

  defp expand_syntax_form({:prefix_ln, line, {ns, locale}}, %{prefixes: prefixes, base: base}) do
    case prefixes[ns] do
      nil ->
       {:error, "unknown prefix in '#{ns <> ":" <> locale}' on line #{line}"}
      prefix ->
        iri = IRI.new(prefix.value <> locale)
        if IRI.absolute?(iri) do
          iri
        else
          IRI.absolute(iri, base)
        end
    end
  end

  defp expand_syntax_form({:relative_iri, relative_iri}, %{base: base}) do
    IRI.absolute(relative_iri, base)
  end

  defp expand_syntax_form({:var, _, var}, _), do: var
  defp expand_syntax_form({:*, _}, _),        do: "*"
  defp expand_syntax_form({:nil, _}, _),      do: RDF.nil()

  # TODO: optimize performance by providing function clauses for AST patterns which don't need further traversal

  defp expand_syntax_form(_, _), do: @no_mapping


  @doc """
  Collect FILTER Elements

  `FILTER` expressions apply to the whole group graph pattern in which they appear.
  The algebra operators to perform filtering are added to the group after translation
  of each group element. We collect the filters together here and remove them from group,
  then apply them to the whole translated group graph pattern.

  In this step, we also translate graph patterns within `FILTER` expressions `EXISTS` and `NOT EXISTS`.

      Let FS := empty set

      For each form FILTER(expr) in the group graph pattern:
          In expr, replace NOT EXISTS{P} with fn:not(exists(translate(P)))
          In expr, replace EXISTS{P} with exists(translate(P))
          FS := FS ∪ {expr}
          End

  The set of filter expressions `FS` is used later.

  <https://www.w3.org/TR/sparql11-query/#sparqlCollectFilters>
  """
  defp collect_filter_elements(ast) do
    # TODO: traverse the group graph_pattern and apply
    #       `Expression.Translation.collect_filter_elements/1` recursivley
    #       via `SPARQL.Algebra.Expression.Translation` protocol(Ex) dispatch
    {:ok, ast}
  end


  @doc """
  Translate Property Path Expressions

  The following table gives the translation of property paths expressions from
  SPARQL syntax to terms in the SPARQL algebra. This applies to all elements of
  a property path expression recursively.

  The next step after this one - - translates certain forms to triple patterns, and
  these are converted later to basic graph patterns by adjacency (without intervening
  group pattern delimiters { and }) or other syntax forms. Overall, SPARQL syntax
  property paths of just an IRI become triple patterns and these are aggregated
  into basic graph patterns.

  Notes: The order of forms IRI and ^IRI in negated property sets is not relevant.

  We introduce the following symbols:

  - `link`
  - `inv`
  - `alt`
  - `seq`
  - `ZeroOrMorePath`
  - `OneOrMorePath`
  - `ZeroOrOnePath`
  - `NPS (for NegatedPropertySet)`


  |! Syntax Form (path)                      |!	Algebra (path)                         |
  |:======================================== |:========================================|
  | `iri`	                                   | `link(iri)`                             |
  | `^path`	                                 | `inv(path)`                             |
  | `!(:iri1|...|:irin)`	                   | `NPS({:iri1 ... :irin})`                |
  | `!(^:iri1|...|^:irin)`                   | `inv(NPS({:iri1 ... :irin}))`           |
  | `!(:iri1|...|:irii|^:irii+1|...|^:irim)` | `alt(NPS({:iri1 ...:irii}),`            |
  |                                          | `    inv(NPS({:irii+1, ..., :irim})) )` |
  | `path1 / path2`                          |	`seq(path1, path2)`                    |
  | `path1 | path2`                          |	`alt(path1, path2)`                    |
  | `path*`                                  | `ZeroOrMorePath(path)`                  |
  | `path+`                                  | `OneOrMorePath(path)`                   |
  | `path?`                                  | `ZeroOrOnePath(path)`                   |

  <https://www.w3.org/TR/sparql11-query/#sparqlTranslatePathExpressions>
  """
  defp translate_property_path_expressions(ast) do
    {:ok, ast}
  end


  @doc """
  Translate Property Path Patterns

  The previous step translated property path expressions. This step translates
  property path patterns, which are a subject end point, property path expression
  and object end point, into triple patterns or wraps in a general algebra operation
  for path evaluation.

  Notes:

  - `X` and `Y` are `RDF.Term`s or `SPARQL.Query.Variable`s.
  - `?V` is a fresh `SPARQL.Query.Variable`.
  - `P` and `Q` are path expressions.
  - These are only applied to property path patterns, not within
    property path expressions.
  - Translations earlier in the table are applied in preference to the last translation.
  - The final translation simply wraps any remaining property path expression to
    use a common form `Path(...)`.

  |! Algebra (path)	|! Translation      |
  |:=============== |:================= |
  | `X link(iri) Y`	| `X iri Y`         |
  | `X inv(iri) Y`	| `Y iri X`         |
  | `X seq(P, Q) Y` |	`X P ?V . ?V Q P` |
  | `X P Y`	        | `Path(X, P, Y)`   |

  <https://www.w3.org/TR/sparql11-query/#sparqlTranslatePathPatterns>
  """
  defp translate_property_path_patterns(ast) do
    {:ok, ast}
  end


  @doc """
  Translate Basic Graph Patterns

  After translating property paths, any adjacent triple patterns are collected
  together to form a basic graph pattern `BGP(triples)`.

  <https://www.w3.org/TR/sparql11-query/#sparqlTranslateBasicGraphPatterns>
  """
  defp translate_basic_graph_patterns(ast) do
    {:ok, map(ast, &do_translate_basic_graph_patterns/2)}
  end

  defp do_translate_basic_graph_patterns({:group_graph_pattern, graph_patterns}, _)
      when is_list(graph_patterns) do
    {:group_graph_pattern,
      Enum.map(graph_patterns, fn
        {:triples_block, triples_block} ->
         %SPARQL.Algebra.BGP{triples: translate_triples_block(triples_block)}
        other ->
          map(other, &do_translate_basic_graph_patterns/2)
      end)
    }
  end

  # TODO: optimize performance by providing function clauses for AST patterns which don't need further traversal

  defp do_translate_basic_graph_patterns(_, _), do: @no_mapping

  def translate_triples_block(triples_block) do
    Enum.flat_map triples_block, fn same_subject_triples ->
      with [{:subject, subject} | property_list] = same_subject_triples,
           {subject, triples}                    = node_with_triples(subject)
      do
        triples ++ property_list_to_triples(subject, property_list)
      end
    end
  end

  defp node_with_triples({:blank_node_property_list, property_list}) do
    with bnode = RDF.bnode() do
      {bnode, property_list_to_triples(bnode, property_list)}
    end
  end

  defp node_with_triples({:collection, list}) do
    list_to_triples(list, RDF.bnode())
  end

  defp node_with_triples(node) do
    {node, []}
  end

  defp property_list_to_triples(subject, property_list) do
    predications = chunk_property_list(property_list)
    Enum.flat_map predications, fn predication ->
      [predicate | objects] = predication
      Enum.flat_map objects, fn object ->
        {object, triples} = node_with_triples(object)
        [{subject, predicate, object} | triples]
      end
    end
  end

  defp chunk_property_list(property_list, acc \\ [])

  defp chunk_property_list([], acc) do
    acc
    |> Stream.map(&Enum.reverse/1)
    |> Enum.reverse()
  end

  defp chunk_property_list([{:predicate, predicate} | rest], acc) do
    chunk_property_list(rest, [[predicate] | acc])
  end

  defp chunk_property_list([{:object, object} | rest], [current | done]) do
    chunk_property_list(rest, [[object | current] | done])
  end


  defp list_to_triples(list, head, triples \\ [])
  defp list_to_triples([], _, triples), do: {RDF.nil, triples}
  defp list_to_triples([first | rest], head, triples) do
    with {node, node_triples} = node_with_triples(first),
         {next, triples} = list_to_triples(rest, RDF.bnode(), triples) do
      {
        head,
        [{head, RDF.first, node}] ++ node_triples ++
        [{head, RDF.rest,  next}] ++ triples
      }
    end
  end


  @doc """
  Translate Graph Patterns

  Next, we translate each remaining graph pattern form, recursively applying the translation process.

  If the form is GroupOrUnionGraphPattern

      Let A := undefined

      For each element G in the GroupOrUnionGraphPattern
          If A is undefined
              A := Translate(G)
          Else
              A := Union(A, Translate(G))
          End

      The result is A

  If the form is GraphGraphPattern

      If the form is GRAPH IRI GroupGraphPattern
          The result is Graph(IRI, Translate(GroupGraphPattern))
      If the form is GRAPH Var GroupGraphPattern
          The result is Graph(Var, Translate(GroupGraphPattern))

  If the form is GroupGraphPattern:

      Let FS := the empty set
      Let G := the empty pattern, a basic graph pattern which is the empty set.

      For each element E in the GroupGraphPattern

          If E is of the form OPTIONAL{P}
              Let A := Translate(P)
              If A is of the form Filter(F, A2)
                  G := LeftJoin(G, A2, F)
              Else
                  G := LeftJoin(G, A, true)
                  End
              End

          If E is of the form MINUS{P}
              G := Minus(G, Translate(P))
              End

          If E is of the form BIND(expr AS var)
              G := Extend(G, var, expr)
              End

          If E is any other form
              Let A := Translate(E)
              G := Join(G, A)
              End

         End

      The result is G.

  If the form is InlineData

      The result is a multiset of solution mappings 'data'.
      data is formed by forming a solution mapping from the variable in the
      corresponding position in list of variables (or single variable), omitting
      a binding if the BindingValue is the word UNDEF.

  If the form is SubSelect

      The result is ToMultiset(Translate(SubSelect))


  <https://www.w3.org/TR/sparql11-query/#sparqlTranslateGraphPatterns>
  """
  defp translate_graph_patterns(ast) do
    {:ok, map(ast, &translate_graph_pattern/2)}
  end

  # TODO: This is just a temporary hack; currently we just support a single BGP
  defp translate_graph_pattern({:group_graph_pattern, [pattern]}, _state) do
    pattern
  end

  # TODO: optimize performance by providing function clauses for AST patterns which don't need further traversal

  defp translate_graph_pattern(_, _), do: @no_mapping


  @doc """
  Add filters of Group

  After the group has been translated, the filter expressions are added so they
  will apply to the whole of the rest of the group:

      If FS is not empty
          Let G := output of preceding step
          Let X := Conjunction of expressions in FS
          G := Filter(X, G)
          End

  <https://www.w3.org/TR/sparql11-query/#sparqlAddFilters>
  """
  defp add_filters_of_group(ast) do
    {:ok, ast}
  end


  @doc """
  Simplification step

  Some groups of one graph pattern become `join(Z, A)`, where `Z` is the empty
  basic graph pattern (which is the empty set). These can be replaced by `A`.
  The empty graph pattern `Z` is the identity for join:

      Replace join(Z, A) by A
      Replace join(A, Z) by A

  <https://www.w3.org/TR/sparql11-query/#sparqlSimplification>
  """
  defp simplification(ast) do
    {:ok, ast}
  end


  ############################################################################
  # 18.2.4 Converting Groups, Aggregates, HAVING, final VALUES clause and SELECT Expressions

  # https://www.w3.org/TR/sparql11-query/#sparqlGroupAggregate
  defp convert_aggregates(state) do
    {:ok, state}
  end


  # https://www.w3.org/TR/sparql11-query/#sparqlAlgebraFinalValues
  defp convert_final_values_clause(%{expr: {:query, p, nil}} = state) do
    {:ok, %{state | expr: p}}
  end

  defp convert_final_values_clause(%{expr: {:query, p, data}} = state) do
    {:ok, %{state | expr: p}}
  end

  # https://www.w3.org/TR/sparql11-query/#sparqlHavingClause
  defp convert_having(state) do
    {:ok, state}
  end


  # https://www.w3.org/TR/sparql11-query/#sparqlSelectExpressions
  defp convert_select(%{expr:
        {:select, {var_decls, modifier}, _dataset_clause, where_clause, _solution_modifier}} = state) do
    with {pv, e} = select_items(var_decls, where_clause) do
      # TODO: process e (with AS expressions)
      {:ok,
        state
        |> Map.put(:expr, {where_clause, modifier})
        |> Map.put(:pv, pv)
      }
    end
  end

  defp convert_select(%{expr:
        {:ask, _dataset_clauses, where_clause, _solution_modifier}} = state) do
    {:ok,
      state
      |> Map.put(:expr, where_clause)
      |> Map.put(:pv, visible_variables(where_clause))
    }
  end

  defp convert_select(%{expr:
        {:describe, _subject, _dataset_clauses, where_clause, _solution_modifier}} = state) do
    {:ok,
      state
      |> Map.put(:expr, where_clause)
      |> Map.put(:pv, visible_variables(where_clause))
    }
  end

  defp convert_select(%{expr:
        {:construct, _construct_template, _dataset_clauses, where_clause, _solution_modifier}} = state) do
    {:ok,
      state
      |> Map.put(:expr, where_clause)
      |> Map.put(:pv, visible_variables(where_clause))
    }
  end


  defp select_items(["*"], where_clause) do
    {visible_variables(where_clause), []}
  end

  defp select_items(sel_items, _) do
    {pv, e} =
      Enum.reduce sel_items, {[], []}, fn
        {variable, nil},  {pv, e} -> {[variable | pv], e}
        {variable, expr}, {pv, e} -> {[variable | pv], [{variable, expr} | e]}
      end
    {Enum.reverse(pv), Enum.reverse(e)}
  end


  ############################################################################
  # 18.2.5 Converting Solution Modifiers

  @doc """
  Converting Solution Modifiers

  Solutions modifiers apply to the processing of a SPARQL query after pattern matching.
  The solution modifiers are applied to a query in the following order:

  - Order by
  - Projection
  - Distinct
  - Reduced
  - Offset
  - Limit

  <https://www.w3.org/TR/sparql11-query/#convertSolMod>
  """
  defp convert_solution_modifiers(state) do
    {pattern, modifier} = case state.expr do
      {pattern, modifier} -> {pattern, modifier}
      pattern             -> {pattern, nil}
    end

    m = pattern # TODO: to_list(pattern)

    # TODO: 18.2.5.1 ORDER BY

    # 18.2.5.2 Projection
    m =
      if state.pv && not Enum.empty?(state.pv) do
        %SPARQL.Algebra.Project{vars: state.pv, expr: m}
      else
        m
      end

    # 18.2.5.3 DISTINCT and 18.2.5.4 REDUCED
    m = case modifier do
      :distinct -> %SPARQL.Algebra.Distinct{expr: m}
      :reduced  -> %SPARQL.Algebra.Reduced{expr: m}
      nil       -> m
      _         -> m # TODO: remove this when the implementation is complete; we currently need this to make the W3C syntax tests pass on non-select queries
    end

    # TODO: 18.2.5.5 OFFSET and LIMIT

    {:ok, %{state | expr: m}}
  end


  ############################################################################
  # Helpers

  @doc """
  Turns a multiset into a sequence with the same elements and cardinality.

  There is no implied ordering to the sequence; duplicates need not be adjacent.
  """
  defp to_list(pattern) do
    pattern # TODO
  end

  # TODO: This should be implemented on SPARQL.Algebra.Expression recursively
  defp visible_variables(pattern) do
    # TODO:
  end

  @doc """
  https://www.w3.org/TR/sparql11-query/#variableScope
  """
  defp variable_in_scope?(expr) do

  end


  defp map(ast, state \\ %{}, fun)

  defp map(ast, state, fun) when is_list(ast) do
    Enum.map ast, fn element ->
       fun.(element, state) || map(element, state, fun)
    end
  end

  defp map({e0, e1, e2, e3, e4, e5}, state, fun) do
    {
      fun.(e0, state) || map(e0, state, fun),
      fun.(e1, state) || map(e1, state, fun),
      fun.(e2, state) || map(e2, state, fun),
      fun.(e3, state) || map(e3, state, fun),
      fun.(e4, state) || map(e4, state, fun),
      fun.(e5, state) || map(e5, state, fun)
    }
  end

  defp map({e0, e1, e2, e3, e4}, state, fun) do
    {
      fun.(e0, state) || map(e0, state, fun),
      fun.(e1, state) || map(e1, state, fun),
      fun.(e2, state) || map(e2, state, fun),
      fun.(e3, state) || map(e3, state, fun),
      fun.(e4, state) || map(e4, state, fun)
    }
  end

  defp map({e0, e1, e2, e3}, state, fun) do
    {
      fun.(e0, state) || map(e0, state, fun),
      fun.(e1, state) || map(e1, state, fun),
      fun.(e2, state) || map(e2, state, fun),
      fun.(e3, state) || map(e3, state, fun)
    }
  end

  defp map({e0, e1, e2}, state, fun) do
    {
      fun.(e0, state) || map(e0, state, fun),
      fun.(e1, state) || map(e1, state, fun),
      fun.(e2, state) || map(e2, state, fun)
    }
  end

  defp map({e0, e1}, state, fun) do
    {
      fun.(e0, state) || map(e0, state, fun),
      fun.(e1, state) || map(e1, state, fun)
    }
  end

  defp map({e}, state, fun) do
    {fun.(e, state) || map(e, state, fun)}
  end

  defp map(other, _, _), do: other

end