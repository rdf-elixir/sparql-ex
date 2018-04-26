defmodule SPARQL.Algebra.Project do
  defstruct [:vars, :expr]

  def result_set(%SPARQL.Query.ResultSet{results: results}, variables) do
    %SPARQL.Query.ResultSet{
      variables: variables,
      results: Enum.map(results, &(result(&1, variables)))
    }
  end

  def result(%SPARQL.Query.Result{bindings: bindings} = result, variables) do
    %SPARQL.Query.Result{result | bindings:
      bindings
      |> Stream.filter(fn {var, value} -> var in variables end)
      |> Map.new
    }
  end

  defimpl SPARQL.Algebra.Expression do
    def evaluate(project, data) do
      SPARQL.Algebra.Expression.evaluate(project.expr, data)
      |> SPARQL.Algebra.Project.result_set(project.vars)
    end

    def variables(project) do
      SPARQL.Algebra.Expression.variables(project.expression)
    end
  end
end
