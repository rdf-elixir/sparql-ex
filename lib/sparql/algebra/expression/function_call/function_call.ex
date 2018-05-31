defmodule SPARQL.Algebra.FunctionCall do

  alias __MODULE__
  alias SPARQL.Algebra.Expression


  def evaluate_arguments(arguments, data) do
    {:ok, Enum.map(arguments, &(evaluate_argument(&1, data)))}
    # TODO: 17.2.1 Invocation: Numeric arguments are promoted as necessary to fit the expected types for that function or operator.
    # TODO: 17.2.1 Invocation: If any of these steps fails, the invocation generates an error. The effects of errors are defined in Filter Evaluation.
  end

  def evaluate_argument(variable, data)

  def evaluate_argument(variable, %{solution: solution}) when is_binary(variable),
    do: solution[variable]

  def evaluate_argument(%FunctionCall.Builtin{} = function_call, data),
    do: Expression.evaluate(function_call, data)

  def evaluate_argument(value, _), do: value

end
