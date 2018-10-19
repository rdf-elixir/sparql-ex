defmodule SPARQL.Algebra.FunctionCall do
  @moduledoc """
  Shared functions for builtin and extension function calls.
  """

  alias __MODULE__
  alias SPARQL.Algebra.Expression

  @doc """
  Evaluates argument expressions.

  An unbound variable is evaluated to the value `:error`.

  """
  def evaluate_arguments(arguments, data, execution) do
    {:ok, Enum.map(arguments, &(evaluate_argument(&1, data, execution)))}
  end

  def evaluate_argument(variable, data, execution)

  def evaluate_argument(variable, %{solution: solution}, _) when is_binary(variable),
    do: Map.get(solution, variable, :error)

  def evaluate_argument(%FunctionCall.Builtin{} = function_call, data, execution),
    do: Expression.evaluate(function_call, data, execution)

  def evaluate_argument(%FunctionCall.Extension{} = function_call, data, execution),
    do: Expression.evaluate(function_call, data, execution)

  def evaluate_argument(value, _, _), do: value

end
