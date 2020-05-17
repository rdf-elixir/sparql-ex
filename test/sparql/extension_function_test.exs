defmodule SPARQL.ExtensionFunctionTest do
  use SPARQL.Test.Case

  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall
  alias SPARQL.ExtensionFunction


  @example_solution_id :example_ref
  @example_solution_data %{solution: %{:__id__ => @example_solution_id}}


  defmodule ExampleFunction do
    use SPARQL.ExtensionFunction, name: "http://example.com/function"

    def call(_distinct, _arguments, _data, _execution), do: XSD.true
  end

  alias __MODULE__.ExampleFunction


  setup_all do
    ExtensionFunction.Registry.init()
    :ok
  end


  test "registration" do
    assert ExtensionFunction.Registry.get_extension("http://example.com/function") ==
             ExampleFunction
  end

  test "call" do
    assert Expression.evaluate(
             %FunctionCall.Extension{name: "http://example.com/function", arguments: []},
             @example_solution_data, %{}) == XSD.true
  end

end
