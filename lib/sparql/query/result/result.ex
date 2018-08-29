defmodule SPARQL.Query.Result do

  defstruct variables: nil, results: []

  @type t :: module


  def new(results, variables \\ nil) do
    %__MODULE__{
      variables: variables,
      results: results
    }
  end

  def add_identity(result) do
    %SPARQL.Query.Result{result | results:
      Enum.map(result.results, fn solution ->
        Map.put(solution, :__id__, make_ref())
      end)
    }
  end

  def remove_identity(result) do
    %SPARQL.Query.Result{result | results:
      Enum.map(result.results, fn solution ->
        Map.delete(solution, :__id__)
      end)
    }
  end

  defimpl Enumerable do
    def member?(result, solution),  do: Enumerable.member?(result.results, solution)
    def count(result),              do: Enumerable.count(result.results)
    def slice(result),              do: Enumerable.slice(result.results)
    def reduce(result, acc, fun),   do: Enumerable.reduce(result.results, acc, fun)
  end

end
