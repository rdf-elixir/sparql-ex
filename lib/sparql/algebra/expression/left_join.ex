defmodule SPARQL.Algebra.LeftJoin do
  defstruct [:expr1, :expr2, :filters]

  alias __MODULE__
  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.{Filter, Join}
  alias SPARQL.Query.Result
  alias SPARQL.Query.Result.SolutionMapping
  alias RDF.XSD

  def result_set(results1, results2, filter_expr, data, execution) do
    # TODO: optimization: if variables are disjoint, build cross-product directly, without checking compatibility for every pair (Assuming the variables of all solutions are the same)
    # TODO: optimization: build the results in one loop, i.e. produce the diff results during join
    Join.result_set(results1, results2)
    |> filter(filter_expr, data, execution)
    |> Result.append(diff(results1, results2, filter_expr, data, execution))
  end

  defp filter(result, %RDF.Literal{literal: %XSD.Boolean{value: true}}, _, _), do: result
  defp filter(result, filters, data, execution),
    do: Filter.result_set(result, filters, data, execution)

  defp diff(results1, results2, filter_expr, data, execution) do
    Enum.filter results1, fn result1 ->
      Enum.all? results2, fn result2 ->
        not SolutionMapping.compatible?(result1, result2) or
          not (
            result1
            |> SolutionMapping.merge(result2)
            |> Filter.apply?(filter_expr, data, execution)
          )
      end
    end
  end

  defimpl Expression do
    def evaluate(left_join, data, execution) do
      LeftJoin.result_set(
        Expression.evaluate(left_join.expr1, data, execution),
        Expression.evaluate(left_join.expr2, data, execution),
        left_join.filters, data, execution)
    end

    def variables(left_join) do
      Expression.variables(left_join.expr1) ++ Expression.variables(left_join.expr2)
    end
  end
end
