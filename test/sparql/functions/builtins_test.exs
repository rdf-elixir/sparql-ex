defmodule SPARQL.Functions.BuiltinsTest do
  use SPARQL.Test.Case

  doctest SPARQL.Functions.Builtins

  alias SPARQL.Functions.Builtins
  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall

  test "! operator" do
    examples = [
        {RDF.true,               RDF.false},
        {RDF.false,              RDF.true},
        {RDF.integer(42),        RDF.false},
        {RDF.string(""),         RDF.true},
        {RDF.date("2010-01-01"), :error},
        {nil,                    :error},
        {:error,                 :error},
      ]

    Enum.each examples, fn {value, result} ->
      assert Builtins.call(:!, [value]) == result,
         "expected !(#{inspect value}) to be #{inspect result}, but got #{inspect Builtins.call(:!, [value])}"
    end

    Enum.each examples, fn {value, result} ->
      assert Expression.evaluate(%FunctionCall.Builtin{name: :!, arguments: [value]}, nil) == result,
         "expected SPARQL expression evaluation of\n\t!(#{inspect value})\nto be\n\t #{inspect result}\nbut got\n\t#{inspect Expression.evaluate(%FunctionCall.Builtin{name: :!, arguments: [value]}, nil)}"
    end
  end

  test "&& operator" do
    examples = [
        {RDF.true,               RDF.true,  RDF.true},
        {RDF.integer(42),        RDF.false, RDF.false},
        {RDF.string(""),         RDF.true,  RDF.false},
        {RDF.false,              RDF.false, RDF.false},
        {RDF.true,               nil,       :error},
        {RDF.date("2010-01-01"), RDF.true,  :error},
        {RDF.false,              nil,       RDF.false},
        {:error,                 RDF.false, RDF.false},
        {:error,                 :error,    :error},
      ]

    Enum.each examples, fn {left, right, result} ->
      assert Expression.evaluate(%FunctionCall.Builtin{name: :&&, arguments: [left, right]}, nil) == result,
         "expected SPARQL expression evaluation of\n\t#{inspect left} &&\n\t#{inspect right}\nto be\n\t#{inspect result}\nbut got\n\t#{inspect Expression.evaluate(%FunctionCall.Builtin{name: :&&, arguments: [left, right]}, nil)}"
    end
  end

  test "|| operator" do
    examples = [
        {RDF.true,               RDF.true,  RDF.true},
        {RDF.string("foo"),      RDF.false, RDF.true},
        {RDF.integer(42),        RDF.true,  RDF.true},
        {RDF.false,              RDF.false, RDF.false},
        {RDF.true,               :error,    RDF.true},
        {nil,                    RDF.true,  RDF.true},
        {RDF.false,              :error,    :error},
        {RDF.date("2010-01-01"), RDF.false, :error},
        {:error,                 :error,    :error},
      ]

    Enum.each examples, fn {left, right, result} ->
      assert Expression.evaluate(%FunctionCall.Builtin{name: :||, arguments: [left, right]}, nil) == result,
         "expected SPARQL expression evaluation of\n\t#{inspect left} ||\n\t#{inspect right}\nto be\n\t#{inspect result}\nbut got\n\t#{inspect Expression.evaluate(%FunctionCall.Builtin{name: :&&, arguments: [left, right]}, nil)}"
    end
  end

end
