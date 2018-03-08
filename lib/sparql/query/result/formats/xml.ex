defmodule SPARQL.Query.Result.XML do
  @moduledoc """
  An implementation of the W3C Recommendation for the SPARQL 1.1 Query Results XML Format.

  see <http://www.w3.org/TR/rdf-sparql-XMLres/>
  """

  use SPARQL.Query.Result.Format

  import RDF.Sigils

  @id         ~I<http://www.w3.org/ns/formats/SPARQL_Results_JSON>
  @name       :xml
  @extension  "srx"
  @media_type "application/sparql-results+xml"

  @supported_query_forms ~w[select ask]a
end
