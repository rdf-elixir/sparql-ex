defmodule SPARQL.QueryFactory do
#  import SPARQL.Algebra

  alias SPARQL.Query

  def prologue(prologue) do
    with query_string =
           """
           #{prologue}
           SELECT ?name WHERE { ?x foaf:name ?name }
           """
    do
      {
        query_string,
        %Query{
          form: :select, # %Query.Select{}
          query_string: query_string
        }
      }
    end
  end

  def select_query(query, prefixes, base \\ nil)
  def select_query(query, prefixes, nil) do
    with query_string = (
        for {ns, iri} <- prefixes do
          "PREFIX #{ns}: <#{iri}>"
        end |> Enum.join("\n")
      ) <> "\n\n" <> query
    do
      {
        query_string,
        %Query{
          prefixes: for {ns, iri} <- prefixes, into: %{} do
                      {to_string(ns), RDF.iri(iri)}
                    end,
          form: :select, # %Query.Select{}
          query_string: query_string
        }
      }
    end
  end

  def select_query(query, prefixes, base) do
    with {query, expected_result} <- select_query(query, prefixes) do
      {
        "BASE <#{base}>\n" <> query,
        %Query{expected_result | base: RDF.iri(base)}
      }
    end

  end

end
