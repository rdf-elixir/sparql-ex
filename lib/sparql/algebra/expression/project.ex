defmodule SPARQL.Algebra.Project do
  defstruct [:vars, :expr]

  alias SPARQL.Algebra.Expression

  def result_set(%SPARQL.Query.Result{results: results}, variables) do
    %SPARQL.Query.Result{
      variables: variables,
      results: Enum.map(results, &(solution(&1, variables)))
    }
  end

  def solution(bindings, variables) do
    bindings
    |> Stream.filter(fn {var, value} -> var in variables end)
    |> Map.new
  end

  defimpl Expression do
    def evaluate(project, data, execution) do
      Expression.evaluate(project.expr, data, execution)
      |> SPARQL.Algebra.Project.result_set(project.vars)
    end

    def variables(project) do
      Expression.variables(project.expression)
    end
  end
end
