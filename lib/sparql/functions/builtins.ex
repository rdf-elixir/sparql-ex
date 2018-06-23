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
  Less-than operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:<, [%Literal{} = left, %Literal{} = right]) do
    cond do
      RDF.Numeric.type?(left.datatype) and RDF.Numeric.type?(right.datatype) ->
        ebv(left.value < right.value)

      left.datatype == right.datatype ->
        ebv(left.value < right.value)

      true ->
        :error
    end
  end

  def call(:<, _), do: :error

  @doc """
  Greater-than operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:>, [arg1, arg2]) do
    call(:<, [arg2, arg1])
  end

  @doc """
  Greater-or-equal operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:>=, args) do
    case call(:>, args) do
      %RDF.Literal{value: false} -> call(:=, args)
      true_or_error              -> true_or_error
    end
  end

  @doc """
  Less-or-equal operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:<=, args) do
    case call(:<, args) do
      %RDF.Literal{value: false} -> call(:=, args)
      true_or_error              -> true_or_error
    end
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


  @doc """
  Numeric addition.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-add>
  """
  def call(:+, [left, right]) do
    RDF.Numeric.add(left, right) || :error
  end

  @doc """
  Numeric subtraction.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-subtract>
  """
  def call(:-, [left, right]) do
    RDF.Numeric.subtract(left, right) || :error
  end

  @doc """
  Numeric multiplication.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-multiply>
  """
  def call(:*, [left, right]) do
    RDF.Numeric.multiply(left, right) || :error
  end

  @doc """
  Numeric division.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-divide>
  """
  def call(:/, [left, right]) do
    RDF.Numeric.divide(left, right) || :error
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
