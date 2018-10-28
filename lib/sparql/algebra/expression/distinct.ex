defmodule SPARQL.Algebra.Distinct do
  defstruct [:expr]

  alias SPARQL.Algebra.Expression
  alias SPARQL.Query.Result.SolutionMapping

  def result_set(%SPARQL.Query.Result{results: results} = result) do
    %SPARQL.Query.Result{result | results:
      results
      |> Stream.map(&SolutionMapping.remove_identity/1)
      |> Enum.uniq()
    }
  end

  defimpl Expression do
    def evaluate(distinct, data, execution) do
      Expression.evaluate(distinct.expr, data, execution)
      |> SPARQL.Algebra.Distinct.result_set()
    end

    def variables(distinct) do
      Expression.variables(distinct.expression)
    end
  end
end
