defmodule SPARQL.Functions.Builtins do

  alias RDF.Literal


  # TODO: This just a preliminary implementation
  def call(:=, [left, right]) do
    left == right
  end

  @doc """
  Logical `NOT`.

  Returns `RDF.true` if the effective boolean value of the given argument is
  `RDF.false`, or `RDF.false` if it is `RDF.true`. Otherwise it returns `error`.

  see <http://www.w3.org/TR/xpath-functions/#func-not>
  """
  def call(:!, [argument]) do
    RDF.Boolean.fn_not(argument) || :error
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
