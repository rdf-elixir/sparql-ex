defmodule SPARQL.Query.Result.JSON do
  @moduledoc """
  An implementation of the W3C Recommendation for the SPARQL 1.1 Query Results JSON Format.

  see <http://www.w3.org/TR/sparql11-results-json/>
  """

  use SPARQL.Query.Result.Format

  import RDF.Sigils

  @id         ~I<http://www.w3.org/ns/formats/SPARQL_Results_JSON>
  @name       :json
  @extension  "srj"
  @media_type "application/sparql-results+json"

  @supported_query_forms ~w[select ask]a
end
