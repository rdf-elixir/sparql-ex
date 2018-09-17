defmodule SPARQL.Language.Decoder do

  alias SPARQL.{Query, Algebra}


  def decode(content, opts \\ %{})

  def decode(content, opts) when is_list(opts),
    do: decode(content, Map.new(opts))

  def decode(content, opts) do
    with {:ok, ast}   <- ast(content),
         default_base  = Map.get(opts, :base, RDF.IRI.default_base()),
         {:ok, query} <- build(ast, default_base)
    do
      {:ok, %Query{query| query_string: content}}
    end
  end

  def ast(content) do
    with {:ok, tokens, _} <- tokenize(content),
         {:ok, ast}       <- parse(tokens) do
      {:ok, ast}
    else
      {:error, {error_line, :lexer, error_descriptor}, _error_line_again} ->
        {:error, "SPARQL language scanner error on line #{error_line}: #{inspect error_descriptor}"}
      {:error, {error_line, :parser, error_descriptor}} ->
        {:error, "SPARQL language parser error on line #{error_line}: #{inspect error_descriptor}"}
    end
  end


  defp tokenize(content), do: content |> to_charlist |> :lexer.string


  defp parse([]),     do: {:ok, []}
  defp parse(tokens), do: tokens |> :parser.parse


  defp build({:query, {prologue, form, values}}, default_base) do
    with {:ok, base, prefixes} <- do_prologue(prologue),
         base                   = iri(base || default_base),
         {:ok, query_form}     <- do_query_form(form),
         {:ok, expression}     <-
           Algebra.Translation.translate({:query, form, values}, prefixes, base)
    do
      {:ok,
        %Query{
          base:     base,
          prefixes: prefixes,
          form:     query_form,
          expr:     expression
        }
      }
    end
  end

  defp do_prologue(prologue, result \\ {nil, %{}})

  defp do_prologue([{:base_decl, base} | rest], {_, prefixes}) do
    do_prologue(rest, {base, prefixes})
  end

  defp do_prologue([{:prefix_decl, {:prefix_ns, _line, prefix}, iri} | rest], {base, prefixes}) do
    do_prologue(rest, {base, Map.put(prefixes, prefix, iri(iri))})
  end

  defp do_prologue([], {base, prefixes}), do: {:ok, base, prefixes}


  defp do_query_form({:select, _select_clause, _dataset_clauses, _where_clause, _solution_modifier}) do
    {:ok, :select}
  end

  defp do_query_form({:ask, _dataset_clauses, _where_clause, _solution_modifier}) do
    {:ok, :ask}
  end

  defp do_query_form({:describe, _subject, _dataset_clauses, _where_clause, _solution_modifier}) do
    {:ok, :describe}
  end

  defp do_query_form({:construct, _construct_template, _dataset_clauses, _where_clause, _solution_modifier}) do
    {:ok, :construct}
  end

  defp do_query_form(ast), do: {:error, "invalid query form: #{ast}"}


  defp iri(nil),              do: nil
  defp iri(%RDF.IRI{} = iri), do: iri
  defp iri(string),           do: RDF.iri(string)

end
