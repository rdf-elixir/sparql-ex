defmodule SPARQL.Language.ParseHelper do

  def variable('?' ++ name), do: List.to_string(name)
  def variable('$' ++ name), do: List.to_string(name)

  # TODO: Literal construction should not happen in the lexer, but during parsing;
  #       grammars and RDF.Serialization.ParseHelper should be rewritten accordingly
  def extract_literal({_, _, literal}), do: literal

end
