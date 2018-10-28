defmodule SPARQL.Algebra.Union do
  defstruct [:expr1, :expr2]

  alias __MODULE__
  alias SPARQL.Algebra.Expression


  def result_set(results1, results2) do
    %SPARQL.Query.Result{
      variables: variables(results1.variables, results2.variables),
      results: results1.results ++ results2.results
    }
  end


  def variables(vars, []), do: vars

  def variables(vars1, [var | vars2]) do
    if var in vars1 do
      variables(vars1, vars2)
    else
      variables([var | vars1], vars2)
    end
  end


  defimpl Expression do
    def evaluate(union, data, execution) do
      Union.result_set(
        Expression.evaluate(union.expr1, data, execution),
        Expression.evaluate(union.expr2, data, execution))
    end

    def variables(union) do
      Union.variables(
        Expression.variables(union.expr1), Expression.variables(union.expr2))
    end
  end
end
