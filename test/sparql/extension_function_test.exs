defmodule SPARQL.ExtensionFunctionTest do
  use SPARQL.Test.Case

  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall
  alias SPARQL.ExtensionFunction
  alias SPARQL.TestExtensionFunctions.ExampleFunction

  @example_solution_id :example_ref
  @example_solution_data %{solution: %{:__id__ => @example_solution_id}}

  test "registration" do
    assert ExtensionFunction.Registry.extension_function("http://example.com/function") ==
             ExampleFunction
  end

  test "call" do
    assert Expression.evaluate(
             %FunctionCall.Extension{name: "http://example.com/function", arguments: []},
             @example_solution_data, %{}) == XSD.true
  end
end
