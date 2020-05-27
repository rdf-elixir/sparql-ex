defmodule SPARQL.Functions.CastTest do
  use SPARQL.Test.Case

  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall
  alias SPARQL.ExtensionFunction

  test "xsd:integer" do
    [
      {XSD.true,  XSD.integer(1)},
      {XSD.false, XSD.integer(0)},

      {XSD.integer(1),  XSD.integer(1)},
      {XSD.integer(42), XSD.integer(42)},
      {XSD.integer(0),  XSD.integer(0)},

      {XSD.decimal(3.14), XSD.integer(3)},
      {XSD.decimal(0.0),  XSD.integer(0)},

      {XSD.double(3.14), XSD.integer(3)},
      {XSD.double(0.0),  XSD.integer(0)},

      {XSD.string("42"),   XSD.integer(42)},

      {XSD.boolean("42"), :error},
      {XSD.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.integer, [value], result)
       end)
  end

  test "xsd:decimal" do
    [
      {XSD.true,  XSD.decimal(1.0)},
      {XSD.false, XSD.decimal(0.0)},

      {XSD.integer(1),  XSD.decimal(1.0)},
      {XSD.integer(42), XSD.decimal(42.0)},
      {XSD.integer(0),  XSD.decimal(0.0)},

      {XSD.decimal(3.14), XSD.decimal(3.14)},
      {XSD.decimal(0.0),  XSD.decimal(0.0)},

      {XSD.double(3.14), XSD.decimal(3.14)},
      {XSD.double(0.0),  XSD.decimal(0.0)},

      {XSD.string("3.14"), XSD.decimal(3.14)},
      {XSD.string("42"),   XSD.decimal(42.0)},

      {XSD.boolean("42"), :error},
      {XSD.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.decimal, [value], result)
       end)
  end

  test "xsd:float" do
    float_literal = fn (value) -> XSD.float(value) end
    [
      {XSD.true,  float_literal.("1.0")},
      {XSD.false, float_literal.("0.0")},

      {XSD.integer(1),  float_literal.("1.0")},
      {XSD.integer(42), float_literal.("42.0")},
      {XSD.integer(0),  float_literal.("0.0")},

      {XSD.decimal(3.14), float_literal.("3.14")},
      {XSD.decimal(0.0),  float_literal.("0.0")},

      {XSD.double(3.14), float_literal.("3.14")},
      {XSD.double(0.0),  float_literal.("0.0")},

      {XSD.string("3.14"), float_literal.("3.14")},

      {XSD.boolean("42"), :error},
      {XSD.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.float, [value], result)
       end)
  end

  test "xsd:double" do
    [
      {XSD.true,  XSD.double(1.0)},
      {XSD.false, XSD.double(0.0)},

      {XSD.integer(1),  XSD.double(1.0)},
      {XSD.integer(42), XSD.double(42.0)},
      {XSD.integer(0),  XSD.double(0.0)},

      {XSD.decimal(3.14), XSD.double(3.14)},
      {XSD.decimal(0.0),  XSD.double(0.0)},

      {XSD.double(3.14), XSD.double(3.14)},
      {XSD.double(0.0),  XSD.double(0.0)},

      {XSD.string("3.14"), XSD.double("3.14E0")},

      {XSD.boolean("42"), :error},
      {XSD.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.double, [value], result)
       end)
  end

  test "xsd:string" do
    [
      {XSD.true,  XSD.string("true")},
      {XSD.false, XSD.string("false")},

      {XSD.integer(1),  XSD.string("1")},
      {XSD.integer(42), XSD.string("42")},
      {XSD.integer(0),  XSD.string("0")},

      {XSD.decimal(3.14), XSD.string("3.14")},
      {XSD.decimal(0.0),  XSD.string("0")},

      {XSD.double(3.14), XSD.string("3.14")},
      {XSD.double(0.0),  XSD.string("0")},

      {XSD.string("foo"), XSD.string("foo")},

      {XSD.date_time(~N[2010-01-01T12:34:56]),     XSD.string("2010-01-01T12:34:56")},
      {XSD.date_time("2010-01-01T00:00:00+00:00"), XSD.string("2010-01-01T00:00:00Z")},
      {XSD.date_time("2010-01-01T01:00:00+01:00"), XSD.string("2010-01-01T01:00:00+01:00")},
      {XSD.date_time("2010-01-01 01:00:00+01:00"), XSD.string("2010-01-01T01:00:00+01:00")},

      {RDF.iri("http://example.com/"), XSD.string("http://example.com/")},

      {XSD.boolean("42"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.string, [value], result)
       end)
  end

  test "xsd:boolean" do
    [
      {XSD.true,  XSD.true},
      {XSD.false, XSD.false},

      {XSD.integer(1),  XSD.true},
      {XSD.integer(42), XSD.true},
      {XSD.integer(0),  XSD.false},

      {XSD.decimal(3.14), XSD.true},
      {XSD.decimal(0.0),  XSD.false},

      {XSD.double(3.14), XSD.true},
      {XSD.double(0.0),  XSD.false},

      {XSD.string("true"),  XSD.true},
      {XSD.string("1"),     XSD.true},
      {XSD.string("false"), XSD.false},
      {XSD.string("0"),     XSD.false},

      {XSD.boolean("42"),   :error},
      {XSD.string("tRuE"),  :error},
      {XSD.string("FaLsE"), :error},
      {XSD.DateTime.now(), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.boolean, [value], result)
       end)
  end

  test "xsd:dateTime" do
    [
      {XSD.date_time("2010-01-01T12:34:56"),    XSD.date_time("2010-01-01T12:34:56")},

      {XSD.string("2010-01-01T12:34:56"),       XSD.date_time("2010-01-01T12:34:56")},
      {XSD.string("2010-01-01T12:34:56Z"),      XSD.date_time("2010-01-01T12:34:56Z")},
      {XSD.string("2010-01-01T12:34:56+01:00"), XSD.date_time("2010-01-01T12:34:56+01:00")},

      {XSD.true, :error},
      {XSD.date_time("02010-01-01T00:00:00"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.dateTime, [value], result)
       end)
  end

  test "xsd:date" do
    [
      {XSD.date("2010-01-01"),         XSD.date("2010-01-01")},

      {XSD.string("2010-01-01"),       XSD.date("2010-01-01")},
      {XSD.string("2010-01-01Z"),      XSD.date("2010-01-01Z")},
      {XSD.string("2010-01-01+01:00"), XSD.date("2010-01-01+01:00")},

      {XSD.date_time("2010-01-01T12:34:56"),    XSD.date("2010-01-01")},

      {XSD.true, :error},
      {XSD.date_time("02010-01-01T00:00:00"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.date, [value], result)
       end)
  end

  test "xsd:time" do
    [
      {XSD.time("12:34:56"), XSD.time("12:34:56")},

      {XSD.date_time("2010-01-01T12:34:56"), XSD.time("12:34:56")},

      {XSD.string("12:34:56"),       XSD.time("12:34:56")},
      {XSD.string("12:34:56Z"),      XSD.time("12:34:56Z")},
      {XSD.string("12:34:56+01:00"), XSD.time("12:34:56+01:00")},

      {XSD.true, :error},
      {XSD.date_time("02010-01-01T00:00:00"), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_result(NS.XSD.time, [value], result)
       end)
  end


  defp assert_result(function_name, args, expected) do
    assert_call_result(function_name, args, expected)
    assert_expression_evaluation_result(function_name, args, expected)
  end

  defp assert_call_result(function_name, args, expected) do
    function_extension = ExtensionFunction.Registry.extension_function(function_name)
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
