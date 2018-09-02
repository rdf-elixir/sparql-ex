defmodule SPARQL.Algebra.FunctionCall do

  alias __MODULE__
  alias SPARQL.Algebra.Expression

  def evaluate_arguments(arguments, data, execution) do
    {:ok, Enum.map(arguments, &(evaluate_argument(&1, data, execution)))}
    # TODO: 17.2.1 Invocation: Numeric arguments are promoted as necessary to fit the expected types for that function or operator.
    # TODO: 17.2.1 Invocation: If any of these steps fails, the invocation generates an error. The effects of errors are defined in Filter Evaluation.
  end

  def evaluate_argument(variable, data, execution)

  def evaluate_argument(variable, %{solution: solution}, _) when is_binary(variable),
    do: solution[variable]

  def evaluate_argument(%FunctionCall.Builtin{} = function_call, data, execution),
    do: Expression.evaluate(function_call, data, execution)

  def evaluate_argument(%FunctionCall.Extension{} = function_call, data, execution),
    do: Expression.evaluate(function_call, data, execution)

  def evaluate_argument(value, _, _), do: value

end
