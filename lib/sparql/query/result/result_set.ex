defmodule SPARQL.Query.ResultSet do

  defstruct variables: nil, results: []

  @type t :: module

  alias SPARQL.Query.Result


  def new(solutions, variables \\ nil) do
    %__MODULE__{
      variables: variables,
      results: Enum.map(solutions, &(%Result{bindings: &1}))
    }
  end

  defimpl Enumerable do
    def member?(result_set, result),  do: Enumerable.member?(result_set.results, result)
    def count(result_set),            do: Enumerable.count(result_set.results)
    def slice(result_set),            do: Enumerable.slice(result_set.results)
    def reduce(result_set, acc, fun), do: Enumerable.reduce(result_set.results, acc, fun)
  end

end
