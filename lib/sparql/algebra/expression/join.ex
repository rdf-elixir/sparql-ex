defmodule SPARQL.Algebra.Join do
  defstruct [:expr1, :expr2]

  alias __MODULE__
  alias SPARQL.Algebra.Expression
  alias SPARQL.Query.Result.SolutionMapping

  def result_set(results1, results2) do
    # TODO: optimization: if variables are disjoint, build cross-product directly, without checking compatibility for every pair (Assuming the variables of all solutions are the same)
    joined_results =
      Enum.reduce(results1, [], fn result1, joined_results ->
        Enum.reduce(results2, joined_results, fn result2, joined_results ->
          if SolutionMapping.compatible?(result1, result2) do
            [SolutionMapping.merge(result1, result2) | joined_results]
          else
            joined_results
          end
        end)
      end)
    joined_variables =
      results1.variables
      |> MapSet.new()
      |> MapSet.union(MapSet.new(results2.variables))
      |> MapSet.to_list()
    SPARQL.Query.Result.new(joined_results, joined_variables)
  end

  defimpl Expression do
    def evaluate(join, data, execution) do
      Join.result_set(
        Expression.evaluate(join.expr1, data, execution),
        Expression.evaluate(join.expr2, data, execution))
    end

# TODO: remove this conditional which is currently needed to work with the unfinished algebra expression
    def variables(%Join{expr1: expr} = join) when expr in [nil, :"$undefined"],
      do: %Join{join | expr1: SPARQL.Algebra.BGP.zero()} |> variables()
    def variables(%Join{expr2: expr} = join) when expr in [nil, :"$undefined"],
        do: %Join{join | expr2: SPARQL.Algebra.BGP.zero()} |> variables()
# END-TODO
    def variables(join) do
      Expression.variables(join.expr1) ++ Expression.variables(join.expr2)
    end
  end
end
