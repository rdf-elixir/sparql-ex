defmodule SPARQL.Functions.Builtins do

  alias RDF.{Literal, Boolean}


  @doc """
  Value equality

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  - <https://www.w3.org/TR/sparql11-query/#func-RDFterm-equal>
  """
  def call(:=, [left, right]) do
    left |> RDF.Term.equal_value?(right) |> ebv()
  end

  @doc """
  Value inequality

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  - <https://www.w3.org/TR/sparql11-query/#func-RDFterm-equal>
  """
  def call(:!=, [left, right]) do
    left |> RDF.Term.equal_value?(right) |> fn_not()
  end

  @doc """
  `sameTerm` equality

  see <https://www.w3.org/TR/sparql11-query/#func-sameTerm>
  """
  def call(:sameTerm, [left, right]) do
    left |> RDF.Term.equal?(right) |> ebv()
  end

  @doc """
  Logical `NOT`

  Returns `RDF.true` if the effective boolean value of the given argument is
  `RDF.false`, or `RDF.false` if it is `RDF.true`. Otherwise it returns `error`.

  see <http://www.w3.org/TR/xpath-functions/#func-not>
  """
  def call(:!, [argument]) do
    fn_not(argument)
  end


  # TODO: This just a preliminary implementation
  def call(:STR, [literal]) do
    literal |> Literal.lexical() |> Literal.new()
  end

  # TODO: This just a preliminary implementation
  def call(:UCASE, [literal]) do
    literal |> Literal.lexical() |> String.upcase() |> Literal.new()
  end

  defp ebv(value),    do: Boolean.ebv(value) || :error
  defp fn_not(value), do: Boolean.fn_not(value) || :error


end
