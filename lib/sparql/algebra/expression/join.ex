defmodule SPARQL.Algebra.Join do
  defstruct [:expr1, :expr2]

  alias SPARQL.Algebra.Expression

  defimpl Expression do
# TODO: remove this conditional which is currently needed to work with the unfinished algebra expression
    def variables(%SPARQL.Algebra.Join{expr1: expr} = join) when expr in [nil, :"$undefined"],
      do: %SPARQL.Algebra.Join{join | expr1: SPARQL.Algebra.BGP.zero()} |> variables()
    def variables(%SPARQL.Algebra.Join{expr2: expr} = join) when expr in [nil, :"$undefined"],
        do: %SPARQL.Algebra.Join{join | expr2: SPARQL.Algebra.BGP.zero()} |> variables()
# END-TODO
    def variables(join) do
      Expression.variables(join.expr1) ++ Expression.variables(join.expr2)
    end
  end
end
