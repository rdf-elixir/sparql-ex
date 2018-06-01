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

  test "IF function" do
    examples = [
        {RDF.true,        RDF.integer(1),  RDF.integer(2), RDF.integer(1)},
        {RDF.false,       RDF.integer(1),  RDF.integer(2), RDF.integer(2)},
        {:error,          RDF.integer(1),  RDF.integer(2), :error},
        {RDF.integer(42), RDF.true,        :error,         RDF.true},
        {RDF.string(""),  :error,          RDF.false,      RDF.false},
        {nil,             RDF.true,        RDF.true,       :error},
      ]

    Enum.each examples, fn {condition, then_value, else_value, result} ->
      assert Expression.evaluate(%FunctionCall.Builtin{name: :IF, arguments: [condition, then_value, else_value]}, nil) == result,
         "expected SPARQL expression evaluation of IF(#{condition}, \n\t#{inspect then_value},\n\t#{inspect else_value}\nto be\n\t#{inspect result}\nbut got\n\t#{inspect Expression.evaluate(%FunctionCall.Builtin{name: :IF, arguments: [condition, then_value, else_value]}, nil)}"
    end
  end

  test "COALESCE function" do
    examples = [
        {[RDF.integer(42)], RDF.integer(42)},
        {[RDF.string(""), RDF.true], RDF.string("")},
        {[:error], :error},
        {[], :error},
      ]

    Enum.each examples, fn {expressions, result} ->
      assert Expression.evaluate(%FunctionCall.Builtin{name: :COALESCE, arguments: expressions}, nil) == result,
         "expected SPARQL expression evaluation of\n\tCOALESCE(#{expressions |> Enum.map(&inspect/1) |> Enum.join(",\n\t\t")})\nto be\n\t#{inspect result}\nbut got\n\t#{inspect Expression.evaluate(%FunctionCall.Builtin{name: :COALESCE, arguments: expressions}, nil)}"
    end
  end

end
