defmodule SPARQL.Query.Result.Turtle do
  @moduledoc """
  An implementation of the Turtle serialization of SPARQL Query Results used in some W3C SPARQL tests.
  """

  use SPARQL.Query.Result.Format

  import RDF.Sigils

  @id         ~I<http://www.w3.org/ns/formats/Turtle>
  @name       :turtle
  @extension  "ttl"
  @media_type "text/turtle"

  @supported_query_forms ~w[select ask]a


  defmodule NS do
    use RDF.Vocabulary.Namespace

    defvocab RS,
      base_iri: "http://www.w3.org/2001/sw/DataAccess/tests/result-set#",
      file: "result-set.ttl"
  end

end
