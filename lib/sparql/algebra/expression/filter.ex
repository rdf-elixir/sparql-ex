defmodule SPARQL.Algebra.Filter do
  defstruct [:filters, :expr]

  alias SPARQL.Algebra.Expression
  alias RDF.XSD

  def result_set(%SPARQL.Query.Result{results: results} = result, filters, data, execution) do
    %SPARQL.Query.Result{result |
      results: Enum.filter(results, &(apply?(&1, filters, data, execution)))
    }
  end

  def apply?(solution, filters, data, execution) do
    filters
    |> Stream.map(fn function_call ->
         Expression.evaluate(function_call, %{solution: solution, data: data}, execution)
       end)
    |> Stream.map(&(RDF.XSD.Boolean.ebv/1))
    |> conjunction()
  end

  defp conjunction(function_call_results) do
    Enum.all? function_call_results, fn
      %RDF.Literal{literal: %XSD.Boolean{value: true}} -> true
      _ -> false
    end
  end


  defimpl Expression do
    def evaluate(filter, data, execution) do
      Expression.evaluate(filter.expr, data, execution)
      |> SPARQL.Algebra.Filter.result_set(filter.filters, data, execution)
    end

    # TODO: Are variables of filters taken into consideration?
    # TODO: What happens if variables are used, which are not part of the expression?
    def variables(filter) do
      Expression.variables(filter.expr)
    end
  end
end
