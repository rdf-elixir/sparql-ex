defmodule SPARQL.Algebra.Minus do
  defstruct [:expr1, :expr2]

  alias __MODULE__
  alias SPARQL.Algebra.Expression
  alias SPARQL.Query.Result.SolutionMapping


  def result_set(query_result1, query_result2) do
    %SPARQL.Query.Result{
      variables: query_result1.variables,
      results: minus(query_result1.results, query_result2.results)
    }
  end

  def minus(results1, results2) do
    # TODO: optimization: Assuming the variables of all solutions are the same, just look at the first solution to determine if variables are disjoint
    Enum.filter results1, fn result1 ->
      Enum.all? results2, fn result2 ->
        !SolutionMapping.compatible?(result1, result2) ||
          SolutionMapping.disjoint?(result1, result2)
      end
    end
  end

  defimpl Expression do
    def evaluate(minus, data, execution) do
      Minus.result_set(
        Expression.evaluate(minus.expr1, data, execution),
        Expression.evaluate(minus.expr2, data, execution))
    end

    def variables(minus) do
      Expression.variables(minus.expr1)
    end
  end
end
