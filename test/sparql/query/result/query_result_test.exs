defmodule SPARQL.Query.ResultTest do
  use ExUnit.Case

  import RDF.Sigils

  doctest SPARQL.Query.Result

  alias SPARQL.Query


  @example %Query.Result{
    variables: ~w[p o],
    results: [
      %{
        "p" => ~I<http://example.org/p1>,
        "o" => ~I<http://example.org/o1>,
      },
      %{
        "p" => ~I<http://example.org/p2>,
        "o" => ~I<http://example.org/o2>,
      }
    ]}

  describe "get/2" do
    test "when values for the given variable exists" do
      assert Query.Result.get(@example, "p") ==
               [~I<http://example.org/p1>, ~I<http://example.org/p2>]
      assert Query.Result.get(@example, :p) ==
               [~I<http://example.org/p1>, ~I<http://example.org/p2>]
    end

    test "when no values for the given variable exist" do
      assert Query.Result.get(@example, "foo") == nil
      assert Query.Result.get(@example, :foo) == nil
    end
  end

end
