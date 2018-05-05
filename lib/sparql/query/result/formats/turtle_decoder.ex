defmodule SPARQL.Query.Result.Turtle.Decoder do
  @moduledoc false

  use SPARQL.Query.Result.Format.Decoder

  alias SPARQL.Query.Result.Turtle.NS.RS
  alias RDF.{Description, Graph}


  def decode(content, _opts \\ []) do
    with {:ok, graph}       <- RDF.Turtle.read_string(content),
         {:ok, description} <- result_set_description(graph)
    do
      {:ok,
        if boolean = Description.first(description, RS.boolean) do
          %Result{results: boolean.value}
        else
          %Result{
            variables: variables(description),
            results:   solutions(description, graph)
          }
        end
      }
    end
  end

  defp result_set_description(graph) do
    graph.descriptions
    |> Stream.map(&(elem(&1, 1)))
    |> Enum.find(fn description ->
         description |> Description.include?({RDF.type, RS.ResultSet})
       end)
    |> case do
         nil         -> {:error, "no rs:ResultSet found"}
         description -> {:ok, description}
       end
  end

  defp variables(result_set_description) do
    result_set_description
    |> Description.get(RS.resultVariable)
    |> Enum.map(&to_string/1)
  end

  defp solutions(result_set_description, graph) do
    result_set_description
    |> Description.get(RS.solution)
    |> Stream.map(&(solution(&1, graph)))
    |> Enum.sort_by(fn {index, _} -> index end)
    |> Enum.map(fn {_, solution} -> solution end)
  end

  defp solution(solution_resource, graph) do
    with solution_description = Graph.description(graph, solution_resource) do
      {
        Description.first(solution_description, RS.index),
        solution_description
        |> Description.get(RS.binding)
        |> Enum.reduce(%{}, fn binding_resource, bindings ->
              binding = Graph.description(graph, binding_resource)
              Map.put bindings,
                binding |> Description.first(RS.variable) |> to_string(),
                binding |> Description.first(RS.value)
           end)
      }
    end
  end
end
