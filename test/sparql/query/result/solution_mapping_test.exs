defmodule SPARQL.Query.Result.SolutionMappingTest do
  use SPARQL.Test.Case

  alias SPARQL.Query.Result.SolutionMapping

  describe "compatible?/2" do
    @compatible_mappings [
      {%{a: 1}, %{}},
      {%{a: 1}, %{a: 1}},
      {%{a: 1}, %{b: 2}},
      {%{a: 1}, %{a: 1, b: 2}},
      {%{a: 1, b: 2}, %{a: 1, c: 3}},
      {%{a: 1, b: 2}, %{a: 1, b: 2, c: 3}}
    ]

    @incompatible_mappings [
      {%{a: 0}, %{a: 1}},
      {%{a: 0}, %{a: 1, b: 0}},
      {%{a: 1, b: 2}, %{a: 1, b: 3}}
    ]

    test "compatible mappings" do
      Enum.each @compatible_mappings, fn {m1, m2} ->
        assert SolutionMapping.compatible?(m1, m2)
        assert SolutionMapping.compatible?(m2, m1)
      end
    end

    test "incompatible mappings" do
      Enum.each @incompatible_mappings, fn {m1, m2} ->
        refute SolutionMapping.compatible?(m1, m2)
        refute SolutionMapping.compatible?(m2, m1)
      end
    end

    test ":__id__ is ignored" do
      with_id = fn solution -> Map.put(solution, :__id__, make_ref()) end

      @compatible_mappings
      |> Enum.map(fn {m1, m2} -> {with_id.(m1), with_id.(m2)} end)
      |> Enum.each(fn {m1, m2} ->
          assert SolutionMapping.compatible?(m1, m2)
          assert SolutionMapping.compatible?(m2, m1)
        end)

      @incompatible_mappings
      |> Enum.map(fn {m1, m2} -> {with_id.(m1), with_id.(m2)} end)
      |> Enum.each(fn {m1, m2} ->
        refute SolutionMapping.compatible?(m1, m2)
        refute SolutionMapping.compatible?(m2, m1)
      end)
    end
  end

end