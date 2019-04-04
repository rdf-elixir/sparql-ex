defmodule SPARQL.Algebra.Construct do
  defstruct [:template, :query]

  alias SPARQL.Algebra.Expression
  alias RDF.BlankNode

  def result(%SPARQL.Query.Result{results: results}, template, generator, prefixes) do
    template_bnodes = template_bnodes(template)
    prefixes = if Enum.empty?((prefixes)), do: nil, else: prefixes
    Enum.reduce results, RDF.Graph.new(prefixes: prefixes), fn result, graph ->
      template_for_solution =
        template_bnodes
        |> create_solution_bnodes(generator)
        |> set_template_solution_bnodes(template)
      RDF.Graph.add(graph, solve_patterns(template_for_solution, result, generator))
    end
  end

  defp solve_patterns(template, solutions, generator) do
    template
    |> Stream.map(&(solve_pattern(&1, solutions, generator)))
    |> Enum.filter(&RDF.Triple.valid?/1)
  end

  defp solve_pattern({variable, predicate, object}, solutions, generator) when is_binary(variable) do
    if subject = solutions[variable] do
      {replace_solved_bnode(subject, solutions, generator), predicate, object}
      |> solve_pattern(solutions, generator)
    end
  end

  defp solve_pattern({subject, variable, object}, solutions, generator) when is_binary(variable) do
    if predicate = solutions[variable] do
      {subject, replace_solved_bnode(predicate, solutions, generator), object}
      |> solve_pattern(solutions, generator)
    end
  end

  defp solve_pattern({subject, predicate, variable}, solutions, generator) when is_binary(variable) do
    if object = solutions[variable] do
      {subject, predicate, replace_solved_bnode(object, solutions, generator)}
      |> solve_pattern(solutions, generator)
    end
  end

  defp solve_pattern(pattern, _, _), do: pattern


  defp template_bnodes(template) do
    Enum.reduce template, MapSet.new, fn pattern, bnodes ->
      MapSet.union(bnodes, pattern_bnodes(pattern))
    end
  end

  defp pattern_bnodes(pattern, acc \\ MapSet.new)
  defp pattern_bnodes({%BlankNode{} = bnode, p, o}, acc), do: pattern_bnodes({nil, p, o}, MapSet.put(acc, bnode))
  defp pattern_bnodes({s, %BlankNode{} = bnode, o}, acc), do: pattern_bnodes({s, nil, o}, MapSet.put(acc, bnode))
  defp pattern_bnodes({s, p, %BlankNode{} = bnode}, acc), do: pattern_bnodes({s, p, nil}, MapSet.put(acc, bnode))
  defp pattern_bnodes(_, acc),                            do: acc


  defp create_solution_bnodes(bnodes, generator) do
    Enum.reduce bnodes, %{}, fn bnode, solution_bnodes ->
      Map.put(solution_bnodes, bnode, BlankNode.Generator.generate(generator))
    end
  end


  defp set_template_solution_bnodes(bnodes, template) when map_size(bnodes) == 0, do: template

  defp set_template_solution_bnodes(bnodes, template) do
    Enum.map template, &(set_solution_bnodes(&1, bnodes))
  end

  defp set_solution_bnodes({s, p, o}, bnodes) do
    {set_solution_bnode(s, bnodes), set_solution_bnode(p, bnodes), set_solution_bnode(o, bnodes)}
  end

  defp set_solution_bnode(%BlankNode{} = bnode, solution_bnodes), do: solution_bnodes[bnode]
  defp set_solution_bnode(node, _), do: node

  defp replace_solved_bnode(%BlankNode{} = bnode, %{__id__: solution_id}, generator) do
    BlankNode.Generator.generate_for(generator, {:construct, bnode})
  end

  defp replace_solved_bnode(node, _, _), do: node

  defimpl Expression do
    def evaluate(construct, data, execution) do
      Expression.evaluate(construct.query, data, execution)
      |> SPARQL.Algebra.Construct.result(construct.template, execution.bnode_generator, execution.prefixes)
    end

    def variables(construct) do
      Expression.variables(construct.query)
    end
  end
end
