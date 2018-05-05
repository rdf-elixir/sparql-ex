defmodule SPARQL.Query.Result do

  defstruct variables: nil, results: []

  @type t :: module


  def new(results, variables \\ nil) do
    %__MODULE__{
      variables: variables,
      results: results
    }
  end

  defimpl Enumerable do
    def member?(result, solution),  do: Enumerable.member?(result.results, solution)
    def count(result),              do: Enumerable.count(result.results)
    def slice(result),              do: Enumerable.slice(result.results)
    def reduce(result, acc, fun),   do: Enumerable.reduce(result.results, acc, fun)
  end

end
