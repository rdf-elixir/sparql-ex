defmodule SPARQL.Functions.Builtins do

  alias RDF.Literal


  # TODO: This just a preliminary implementation
  def call(:=, [left, right]) do
    left == right
  end

  # TODO: This just a preliminary implementation
  def call(:STR, [literal]) do
    literal |> Literal.lexical() |> Literal.new()
  end

  # TODO: This just a preliminary implementation
  def call(:UCASE, [literal]) do
    literal |> Literal.lexical() |> String.upcase() |> Literal.new()
  end

end
