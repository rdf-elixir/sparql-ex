defmodule SPARQL.Functions.CastTest do
  use SPARQL.Test.Case

  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall
  alias SPARQL.ExtensionFunction

  alias RDF.NS.XSD

  test "xsd:integer" do
    [
      {RDF.true,  RDF.integer(1)},
      {RDF.false, RDF.integer(0)},

      {RDF.integer(1),  RDF.integer(1)},
      {RDF.integer(42), RDF.integer(42)},
      {RDF.integer(0),  RDF.integer(0)},

      {RDF.decimal(3.14), RDF.integer(3)},
      {RDF.decimal(0.0),  RDF.integer(0)},

      {RDF.double(3.14), RDF.integer(3)},
      {RDF.double(0.0),  RDF.integer(0)},

      {RDF.string("3.14"), RDF.integer(3)},
      {RDF.string("42"),   RDF.integer(42)},

      {RDF.boolean("42"), :error},
      {RDF.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.integer, [value], result)
       end)
  end

  test "xsd:decimal" do
    [
      {RDF.true,  RDF.decimal(1.0)},
      {RDF.false, RDF.decimal(0.0)},

      {RDF.integer(1),  RDF.decimal(1.0)},
      {RDF.integer(42), RDF.decimal(42.0)},
      {RDF.integer(0),  RDF.decimal(0.0)},

      {RDF.decimal(3.14), RDF.decimal(3.14)},
      {RDF.decimal(0.0),  RDF.decimal(0.0)},

      {RDF.double(3.14), RDF.decimal(3.14)},
      {RDF.double(0.0),  RDF.decimal(0.0)},

      {RDF.string("3.14"), RDF.decimal(3.14)},
      {RDF.string("42"),   RDF.decimal(42.0)},

      {RDF.boolean("42"), :error},
      {RDF.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.decimal, [value], result)
       end)
  end

  test "xsd:double" do
    [
      {RDF.true,  RDF.double(1.0)},
      {RDF.false, RDF.double(0.0)},

      {RDF.integer(1),  RDF.double(1.0)},
      {RDF.integer(42), RDF.double(42.0)},
      {RDF.integer(0),  RDF.double(0.0)},

      {RDF.decimal(3.14), RDF.double(3.14)},
      {RDF.decimal(0.0),  RDF.double(0.0)},

      {RDF.double(3.14), RDF.double(3.14)},
      {RDF.double(0.0),  RDF.double(0.0)},

      {RDF.string("3.14"), RDF.double("3.14E0")},

      {RDF.boolean("42"), :error},
      {RDF.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.double, [value], result)
       end)
  end

  test "xsd:string" do
    [
      {RDF.true,  RDF.string("true")},
      {RDF.false, RDF.string("false")},

      {RDF.integer(1),  RDF.string("1")},
      {RDF.integer(42), RDF.string("42")},
      {RDF.integer(0),  RDF.string("0")},

      {RDF.decimal(3.14), RDF.string("3.14")},
      {RDF.decimal(0.0),  RDF.string("0")},

      {RDF.double(3.14), RDF.string("3.14")},
      {RDF.double(0.0),  RDF.string("0")},

      {RDF.string("foo"), RDF.string("foo")},

      {RDF.date_time(~N[2010-01-01T12:34:56]),     RDF.string("2010-01-01T12:34:56")},
      {RDF.date_time("2010-01-01T00:00:00+00:00"), RDF.string("2010-01-01T00:00:00Z")},
      {RDF.date_time("2010-01-01T01:00:00+01:00"), RDF.string("2010-01-01T01:00:00+01:00")},
      {RDF.date_time("2010-01-01 01:00:00+01:00"), RDF.string("2010-01-01T01:00:00+01:00")},

      {RDF.boolean("42"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.string, [value], result)
       end)
  end

  test "xsd:boolean" do
    [
      {RDF.true,  RDF.true},
      {RDF.false, RDF.false},

      {RDF.integer(1),  RDF.true},
      {RDF.integer(42), RDF.true},
      {RDF.integer(0),  RDF.false},

      {RDF.decimal(3.14), RDF.true},
      {RDF.decimal(0.0),  RDF.false},

      {RDF.double(3.14), RDF.true},
      {RDF.double(0.0),  RDF.false},

      {RDF.string("true"),  RDF.true},
      {RDF.string("tRuE"),  RDF.true},
      {RDF.string("1"),     RDF.true},
      {RDF.string("false"), RDF.false},
      {RDF.string("FaLsE"), RDF.false},
      {RDF.string("0"),     RDF.false},

      {RDF.boolean("42"), :error},
      {RDF.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.boolean, [value], result)
       end)
  end

  test "xsd:dateTime" do
    [
      {RDF.date_time("2010-01-01T12:34:56"),    RDF.date_time("2010-01-01T12:34:56")},

      {RDF.string("2010-01-01T12:34:56"),       RDF.date_time("2010-01-01T12:34:56")},
      {RDF.string("2010-01-01T12:34:56Z"),      RDF.date_time("2010-01-01T12:34:56Z")},
      {RDF.string("2010-01-01T12:34:56+01:00"), RDF.date_time("2010-01-01T12:34:56+01:00")},

      {RDF.true, :error},
      {RDF.date_time("02010-01-01T00:00:00"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.dateTime, [value], result)
       end)
  end

  test "xsd:date" do
    [
      {RDF.date("2010-01-01"),         RDF.date("2010-01-01")},

      {RDF.string("2010-01-01"),       RDF.date("2010-01-01")},
      {RDF.string("2010-01-01Z"),      RDF.date("2010-01-01Z")},
      {RDF.string("2010-01-01+01:00"), RDF.date("2010-01-01+01:00")},

      {RDF.date_time("2010-01-01T12:34:56"),    RDF.date("2010-01-01")},

      {RDF.true, :error},
      {RDF.date_time("02010-01-01T00:00:00"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.date, [value], result)
       end)
  end

  test "xsd:time" do
    [
      {RDF.time("12:34:56"), RDF.time("12:34:56")},

      {RDF.date_time("2010-01-01T12:34:56"), RDF.time("12:34:56")},

      {RDF.string("12:34:56"),       RDF.time("12:34:56")},
      {RDF.string("12:34:56Z"),      RDF.time("12:34:56Z")},
      {RDF.string("12:34:56+01:00"), RDF.time("12:34:56+01:00")},

      {RDF.true, :error},
      {RDF.date_time("02010-01-01T00:00:00"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(XSD.time, [value], result)
       end)
  end


  defp assert_result(function_name, args, expected) do
    assert_call_result(function_name, args, expected)
    assert_expression_evaluation_result(function_name, args, expected)
  end

  defp assert_call_result(function_name, args, expected) do
    function_extension = ExtensionFunction.Registry.get_extension(function_name)
    assert function_extension, "extension for #{function_name} not found"

    result = function_extension.call(false, args, nil, %{})
    assert result == expected, """
      expected SPARQL extension function call #{function_name}(\n\t#{args |> Stream.map(&inspect/1) |> Enum.join(",\n\t")})
      to be:   #{inspect expected}
      but got: #{inspect result}
      """
  end

  defp assert_expression_evaluation_result(function_name, args, expected) do
    result = Expression.evaluate(%FunctionCall.Extension{name: RDF.iri(function_name), arguments: args}, nil, %{})
    assert result == expected, """
      expected SPARQL function call expression evaluation #{function_name}(\n\t#{args |> Stream.map(&inspect/1) |> Enum.join(",\n\t")})
      to be:   #{inspect expected}
      but got: #{inspect result}
      """
  end

end
