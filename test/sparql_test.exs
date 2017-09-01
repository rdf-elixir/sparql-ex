defmodule SPARQLTest do
  use ExUnit.Case
  doctest SPARQL

  test "greets the world" do
    assert SPARQL.hello() == :world
  end
end
