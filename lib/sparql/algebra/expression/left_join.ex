defmodule SPARQL.Algebra.LeftJoin do
  defstruct [:expr1, :expr2, :filters]

  alias __MODULE__
  alias SPARQL.Algebra.Expression
  alias SPARQL.Query.Result.SolutionMapping

  defimpl Expression do
    def variables(join) do
      Expression.variables(join.expr1) ++ Expression.variables(join.expr2)
    end
  end
end
