defmodule SPARQL.Query.Result.SolutionMapping do
  @moduledoc !"""
  Some shared functions on solution mappings for internal purposes.
  """

  @doc """
  Two solution mappings `m1` and `m2` are compatible if, for every variable `v in `dom(m1)` and in `dom(m2)`, `m1(v) = m2(v)`.

  see Definition in <https://www.w3.org/TR/sparql11-query/#BasicGraphPattern>
  """
  def compatible?(m1, m2) do
    Enum.all? m1, fn
      {:__id__, _} ->
        true

      {k, v} ->
        Map.get(m2, k, v) == v
    end
  end

  @doc """
  Two solution mappings `m1` and `m2` are disjoint if they don't share any variable.
  """
  def disjoint?(m1, m2) do
    m1
    |> remove_identity()
    |> Map.take(Map.keys(remove_identity(m2)))
    |> Enum.empty?()
  end

  @doc """
  Merges two solution mappings.

  see Definition in <https://www.w3.org/TR/sparql11-query/#BasicGraphPattern>
  """
  def merge(m1, m2) do
    m1
    |> Map.merge(m2)
    |> add_identity()
  end

  @doc false
  def add_identity(m), do: Map.put(m, :__id__, make_ref())

  @doc false
  def remove_identity(m), do: Map.delete(m, :__id__)
end
