defmodule SPARQL.Algebra.Filter do
  defstruct [:filters, :expr]


  def result_set(%SPARQL.Query.Result{results: results} = result, filters, data) do
    %SPARQL.Query.Result{result |
      results: Enum.filter(results, &(apply?(&1, filters, data)))
    }
  end

  defp apply?(solution, filters, data) do
    filters
    |> Stream.map(fn
         %RDF.Literal{} = literal -> literal
         %RDF.IRI{} = iri         -> iri
         %RDF.BlankNode{} = bnode -> bnode

         variable when is_binary(variable) ->
           Map.get(solution, variable)

         filter ->
           SPARQL.Algebra.Expression.evaluate(filter, %{solution: solution, data: data})
       end)
    |> Stream.map(&(RDF.Boolean.ebv/1))
    |> conjunction()
  end

  defp conjunction(function_call_results) do
    Enum.all? function_call_results, fn
      %RDF.Literal{value: true} -> true
      _                         -> false
    end
  end


  defimpl SPARQL.Algebra.Expression do
    def evaluate(filter, data) do
      SPARQL.Algebra.Expression.evaluate(filter.expr, data)
      |> SPARQL.Algebra.Filter.result_set(filter.filters, data)
    end

    # TODO: Are variables of filters taken into consideration?
    # TODO: What happens if variables are used, which are not part of the expression?
    def variables(filter) do
      SPARQL.Algebra.Expression.variables(filter.expr)
    end
  end
end
