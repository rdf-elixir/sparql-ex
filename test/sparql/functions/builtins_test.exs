defmodule SPARQL.Functions.BuiltinsTest do
  use SPARQL.Test.Case

  doctest SPARQL.Functions.Builtins

  alias SPARQL.Functions.Builtins
  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall

  alias RDF.NS.XSD


  @term_equal_rdf_literals [
    # String literals
    {RDF.string("foo"), RDF.string("foo")},
    {RDF.lang_string("foo", language: "de"), RDF.lang_string("foo", language: "de")},

    # Boolean literals
    {RDF.false, RDF.false},

    # Numeric literals
    {RDF.integer("042"), RDF.integer("042")},

    # DateTime literals
    {RDF.date_time("2002-04-02T12:00:00-01:00"), RDF.date_time("2002-04-02T12:00:00-01:00")},
    {RDF.date_time("2002-04-02T12:00:00"),       RDF.date_time("2002-04-02T12:00:00")},
  ]

  @equal_rdf_terms [
    # IRIs
    {RDF.iri("http://example.com/"), RDF.iri("http://example.com/")},

    # Blank Nodes
    {RDF.bnode("foo"), RDF.bnode("foo")},
  ] ++ @term_equal_rdf_literals

  @unequal_rdf_terms [
    # IRIs
    {RDF.iri("http://example.com/foo"), RDF.iri("http://example.com/bar")},

    # Blank Nodes
    {RDF.bnode("foo"), RDF.bnode("bar")},

    # String literals
    {RDF.string("foo"), RDF.string("bar")},
    {RDF.lang_string("foo", language: "de"), RDF.lang_string("bar", language: "de")},

    # Boolean literals
    {RDF.true, RDF.false},

    # Numeric literals
    {RDF.integer(1), RDF.integer(2)},

    # DateTime literals
    {RDF.date_time("2002-04-02T12:00:00"), RDF.date_time("2002-04-02T17:00:00")},
  ]

  @value_equal_rdf_literals [
    # Boolean literals
    {RDF.true,       RDF.boolean("TRUE")},

    # Numeric literals

    {RDF.integer("42"), RDF.integer("042")},
    {RDF.integer("42"), RDF.double("42")},
    {RDF.integer(42),   RDF.double(42.0)},
    {RDF.double("+0"),  RDF.double("-0")},

    # DateTime literals
    {RDF.date_time("2002-04-02T12:00:00-01:00"), RDF.date_time("2002-04-02T17:00:00+04:00")},
    {RDF.date_time("2002-04-02T23:00:00-04:00"), RDF.date_time("2002-04-03T02:00:00-01:00")},
    {RDF.date_time("1999-12-31T24:00:00"),       RDF.date_time("2000-01-01T00:00:00")},
  ]

  @equal_rdf_values [
    # IRIs
    # RDF URI references are compatible with the anyURI datatype as defined by XML schema datatypes, constrained to be an absolute rather than a relative URI reference.
    {RDF.iri("http://example.com/"),
     RDF.Literal.new("http://example.com/", datatype: XSD.anyURI)},
  ] ++ @value_equal_rdf_literals

  @unequal_rdf_values [
    # IRIs
    {RDF.iri("http://example.com/foo"),
     RDF.literal("http://example.com/bar", datatype: XSD.anyURI)},

    # Boolean literals
    {RDF.true,       RDF.boolean("FALSE")},
    {RDF.boolean(0), RDF.true},

    # Numeric literals
    {RDF.integer("1"), RDF.double("1.1")},

    # DateTime literals
    {RDF.date_time("2005-04-04T24:00:00"), RDF.date_time("2005-04-04T00:00:00")},
  ]

  @incomparable_literals [
    # String literals
    {RDF.string("foo"), RDF.lang_string("foo", language: "de")},
    {RDF.string("foo"), RDF.bnode("foo")},

    # Boolean literals
    {RDF.true,       nil},
    {RDF.true,       RDF.string("FALSE")},
    {RDF.integer(0), RDF.true},

    # Numeric literals
    {RDF.integer("42"),   RDF.string("42")},
# TODO: How to handle invalid number literals?
#    {RDF.integer("3.14"), RDF.integer("007")},

    # DateTime literals
    {RDF.date_time("2002-04-02T12:00:00-01:00"), RDF.string("2002-04-02T12:00:00-01:00")},
  ]

  @incomparable_terms [
    # IRIs
    {RDF.iri("http://example.com/"), RDF.string("http://example.com/")},

    # Blank Nodes
    {RDF.bnode("foo"), RDF.string("foo")},

  ] ++ @incomparable_literals

  @ordered_numbers [
    {RDF.integer(0),   RDF.integer(1)},
    {RDF.integer("3"), RDF.integer("007")},
    {RDF.double(1.1),  RDF.double(2.2)},
    {RDF.double(3.14), RDF.integer(42)},
# TODO: How to handle invalid number literals?
#    {RDF.integer("3.14"), RDF.integer("007")},
# TODO: We need a RDF.Decimal datatype for this
#    {RDF.decimal(1.1), RDF.decimal(2.2)},
#    {RDF.integer(3),   RDF.decimal(3.14)},
# TODO: We need support for other derived numeric datatypes
#    {RDF.Literal.new(0, datatype: XSD.byte), RDF.integer(1)},
  ]

  @ordered_strings [
    {RDF.string("a"), RDF.string("b")},
    {RDF.string("0"), RDF.string("1")},
  ]

  @ordered_datetimes [
    {RDF.date_time("2002-04-02T12:00:00"), RDF.date_time("2002-04-02T17:00:00")},
    {RDF.date_time("2002-04-02T12:00:00+01:00"), RDF.date_time("2002-04-02T12:00:00+00:00")},
  ]


  describe "= operator" do
    test "with equal terms" do
      Enum.each @equal_rdf_terms, fn {left, right} ->
        assert_builtin_call_result(:=, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:=, [left, right], RDF.true)
      end
    end

    test "with equal values" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_call_result(:=, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:=, [left, right], RDF.true)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_call_result(:=, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:=, [left, right], RDF.false)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_call_result(:=, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:=, [left, right], RDF.false)
      end
    end

    test "with incompatible terms" do
      Enum.each @incomparable_terms, fn {left, right} ->
        assert_builtin_call_result(:=, [left, right], :error)
        assert_builtin_expression_evaluation_result(:=, [left, right], :error)
      end
    end
  end

  describe "!= operator" do
    test "with equal terms" do
      Enum.each @equal_rdf_terms, fn {left, right} ->
        assert_builtin_call_result(:!=, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:!=, [left, right], RDF.false)
      end
    end

    test "with equal values" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_call_result(:!=, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:!=, [left, right], RDF.false)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_call_result(:!=, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:!=, [left, right], RDF.true)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_call_result(:!=, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:!=, [left, right], RDF.true)
      end
    end

    test "with incompatible terms" do
      Enum.each @incomparable_terms, fn {left, right} ->
        assert_builtin_call_result(:!=, [left, right], :error)
        assert_builtin_expression_evaluation_result(:!=, [left, right], :error)
      end
    end
  end

  describe "sameTerm function" do
    test "with equal terms" do
      Enum.each @equal_rdf_terms, fn {left, right} ->
        assert_builtin_call_result(:sameTerm, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:sameTerm, [left, right], RDF.true)
      end
    end

    test "with equal values, but unequal terms" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_call_result(:sameTerm, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:sameTerm, [left, right], RDF.false)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_call_result(:sameTerm, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:sameTerm, [left, right], RDF.false)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_call_result(:sameTerm, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:sameTerm, [left, right], RDF.false)
      end
    end

    test "with incompatible terms" do
      Enum.each @incomparable_terms, fn {left, right} ->
        assert_builtin_call_result(:sameTerm, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:sameTerm, [left, right], RDF.false)
      end
    end
  end

  describe "< operator" do
    test "with booleans" do
      assert_builtin_call_result(:<, [RDF.false, RDF.true], RDF.true)
      assert_builtin_expression_evaluation_result(:<, [RDF.false, RDF.true], RDF.true)

      assert_builtin_call_result(:<, [RDF.true, RDF.false], RDF.false)
      assert_builtin_expression_evaluation_result(:<, [RDF.true, RDF.false], RDF.false)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:<, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:<, [left, right], RDF.true)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:<, [right, left], RDF.false)
        assert_builtin_expression_evaluation_result(:<, [right, left], RDF.false)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:<, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:<, [left, right], RDF.true)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:<, [right, left], RDF.false)
        assert_builtin_expression_evaluation_result(:<, [right, left], RDF.false)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:<, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:<, [left, right], RDF.true)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:<, [right, left], RDF.false)
        assert_builtin_expression_evaluation_result(:<, [right, left], RDF.false)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
          assert_builtin_call_result(:<, [left, right], RDF.false)
          assert_builtin_expression_evaluation_result(:<, [left, right], RDF.false)
        end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_call_result(:<, [left, right], :error)
        assert_builtin_expression_evaluation_result(:<, [left, right], :error)
      end
    end
  end

  describe "<= operator" do
    test "with booleans" do
      assert_builtin_call_result(:<=, [RDF.false, RDF.true], RDF.true)
      assert_builtin_expression_evaluation_result(:<=, [RDF.false, RDF.true], RDF.true)

      assert_builtin_call_result(:<=, [RDF.true, RDF.false], RDF.false)
      assert_builtin_expression_evaluation_result(:<=, [RDF.true, RDF.false], RDF.false)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:<=, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:<=, [left, right], RDF.true)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:<=, [right, left], RDF.false)
        assert_builtin_expression_evaluation_result(:<=, [right, left], RDF.false)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:<=, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:<=, [left, right], RDF.true)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:<=, [right, left], RDF.false)
        assert_builtin_expression_evaluation_result(:<=, [right, left], RDF.false)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:<=, [left, right], RDF.true)
        assert_builtin_expression_evaluation_result(:<=, [left, right], RDF.true)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:<=, [right, left], RDF.false)
        assert_builtin_expression_evaluation_result(:<=, [right, left], RDF.false)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
          assert_builtin_call_result(:<=, [left, right], RDF.true)
          assert_builtin_expression_evaluation_result(:<=, [left, right], RDF.true)
        end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_call_result(:<=, [left, right], :error)
        assert_builtin_expression_evaluation_result(:<=, [left, right], :error)
      end
    end
  end

  describe "> operator" do
    test "with booleans" do
      assert_builtin_call_result(:>, [RDF.false, RDF.true], RDF.false)
      assert_builtin_expression_evaluation_result(:>, [RDF.false, RDF.true], RDF.false)

      assert_builtin_call_result(:>, [RDF.true, RDF.false], RDF.true)
      assert_builtin_expression_evaluation_result(:>, [RDF.true, RDF.false], RDF.true)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:>, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:>, [left, right], RDF.false)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:>, [right, left], RDF.true)
        assert_builtin_expression_evaluation_result(:>, [right, left], RDF.true)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:>, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:>, [left, right], RDF.false)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:>, [right, left], RDF.true)
        assert_builtin_expression_evaluation_result(:>, [right, left], RDF.true)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:>, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:>, [left, right], RDF.false)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:>, [right, left], RDF.true)
        assert_builtin_expression_evaluation_result(:>, [right, left], RDF.true)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
          assert_builtin_call_result(:>, [left, right], RDF.false)
          assert_builtin_expression_evaluation_result(:>, [left, right], RDF.false)
        end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_call_result(:>, [left, right], :error)
        assert_builtin_expression_evaluation_result(:>, [left, right], :error)
      end
    end
  end

  describe ">= operator" do
    test "with booleans" do
      assert_builtin_call_result(:>=, [RDF.false, RDF.true], RDF.false)
      assert_builtin_expression_evaluation_result(:>=, [RDF.false, RDF.true], RDF.false)

      assert_builtin_call_result(:>=, [RDF.true, RDF.false], RDF.true)
      assert_builtin_expression_evaluation_result(:>=, [RDF.true, RDF.false], RDF.true)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:>=, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:>=, [left, right], RDF.false)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_call_result(:>=, [right, left], RDF.true)
        assert_builtin_expression_evaluation_result(:>=, [right, left], RDF.true)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:>=, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:>=, [left, right], RDF.false)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_call_result(:>=, [right, left], RDF.true)
        assert_builtin_expression_evaluation_result(:>=, [right, left], RDF.true)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:>=, [left, right], RDF.false)
        assert_builtin_expression_evaluation_result(:>=, [left, right], RDF.false)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_call_result(:>=, [right, left], RDF.true)
        assert_builtin_expression_evaluation_result(:>=, [right, left], RDF.true)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
          assert_builtin_call_result(:>=, [left, right], RDF.true)
          assert_builtin_expression_evaluation_result(:>=, [left, right], RDF.true)
        end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_call_result(:>=, [left, right], :error)
        assert_builtin_expression_evaluation_result(:>=, [left, right], :error)
      end
    end
  end



  test "! operator" do
    [
      {RDF.true,               RDF.false},
      {RDF.false,              RDF.true},
      {RDF.integer(42),        RDF.false},
      {RDF.string(""),         RDF.true},
      {RDF.date("2010-01-01"), :error},
      {nil,                    :error},
      {:error,                 :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_call_result(:!, [value], result)
         assert_builtin_expression_evaluation_result(:!, [value], result)
       end)
  end

  test "&& operator" do
    [
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
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:&&, [left, right], result)
       end)
  end

  test "|| operator" do
    [
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
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:||, [left, right], result)
       end)
  end

  test "IF function" do
    [
      {RDF.true,        RDF.integer(1),  RDF.integer(2), RDF.integer(1)},
      {RDF.false,       RDF.integer(1),  RDF.integer(2), RDF.integer(2)},
      {:error,          RDF.integer(1),  RDF.integer(2), :error},
      {RDF.integer(42), RDF.true,        :error,         RDF.true},
      {RDF.string(""),  :error,          RDF.false,      RDF.false},
      {nil,             RDF.true,        RDF.true,       :error},
    ]
    |> Enum.each(fn {condition, then_value, else_value, result} ->
         assert_builtin_expression_evaluation_result(:IF, [condition, then_value, else_value], result)
       end)
  end

  test "COALESCE function" do
    [
      {[RDF.integer(42)], RDF.integer(42)},
      {[RDF.string(""), RDF.true], RDF.string("")},
      {[:error], :error},
      {[], :error},
    ]
    |> Enum.each(fn {expressions, result} ->
         assert_builtin_expression_evaluation_result(:COALESCE, expressions, result)
       end)
  end

  test "IN operator" do
    [
      {RDF.integer(2), [RDF.integer(1), RDF.integer(2), RDF.integer(3)], RDF.true},
      {RDF.integer(2), [], RDF.false},
      {RDF.integer(2), [~I<http://example/iri>, RDF.string("str"), RDF.double(2.0)], RDF.true},

      {RDF.integer(2), [:error, RDF.integer(2)], RDF.true},
      {RDF.integer(2), [RDF.integer(2), :error], RDF.true},
      {RDF.integer(2), [RDF.integer(3), :error], :error},

      {:error, [RDF.integer(2)], :error},
      {:error, [:error, RDF.integer(2)], :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:IN, [left, right], result)
       end)
  end

  test "NOT IN operator" do
    [
      {RDF.integer(2), [RDF.integer(1), RDF.integer(2), RDF.integer(3)],	RDF.false},
      {RDF.integer(2), [],	RDF.true},
      {RDF.integer(2), [~I<http://example/iri>, RDF.string("str"), RDF.double(2.0)],	RDF.false},

      {RDF.integer(2), [:error, RDF.integer(2)], RDF.false},
      {RDF.integer(2), [RDF.integer(2), :error], RDF.false},
      {RDF.integer(2), [RDF.integer(3), :error], :error},

      {:error, [RDF.integer(2)], :error},
      {:error, [:error, RDF.integer(2)], :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:NOT_IN, [left, right], result)
       end)
  end


  test "numeric + operator" do
    [
      {RDF.integer(1),  RDF.integer(2),    RDF.integer(3)},
      {RDF.integer(42), RDF.decimal(3.14), RDF.decimal(45.14)},
      {RDF.integer(42), RDF.double(3.14),  RDF.double(45.14)},

      {RDF.integer(1), :error, :error},
      {:error, RDF.integer(1), :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {left, right, result} ->
      assert_builtin_call_result(:+, [left, right], result)
      assert_builtin_expression_evaluation_result(:+, [left, right], result)
    end)
  end

  test "numeric - operator" do
    [
      {RDF.integer(3),  RDF.integer(2),    RDF.integer(1)},
      {RDF.integer(42), RDF.decimal(3.14), RDF.decimal(38.86)},
      {RDF.integer(42), RDF.double(3.14),  RDF.double(38.86)},

      {RDF.integer(1), :error, :error},
      {:error, RDF.integer(1), :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {left, right, result} ->
      assert_builtin_call_result(:-, [left, right], result)
      assert_builtin_expression_evaluation_result(:-, [left, right], result)
    end)
  end

  test "numeric * operator" do
    [
      {RDF.integer(2),   RDF.integer(3),   RDF.integer(6)},
      {RDF.decimal(1.5), RDF.double(3.14), RDF.double(4.71)},

      {RDF.integer(1), :error, :error},
      {:error, RDF.integer(1), :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {left, right, result} ->
      assert_builtin_call_result(:*, [left, right], result)
      assert_builtin_expression_evaluation_result(:*, [left, right], result)
    end)
  end

  test "numeric / operator" do
    [
      {RDF.integer(3),   RDF.integer(2), RDF.decimal(1.5)},
      {RDF.decimal(1.5), RDF.double(2),  RDF.double(0.75)},

      {RDF.integer(1), :error, :error},
      {:error, RDF.integer(1), :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {left, right, result} ->
      assert_builtin_call_result(:/, [left, right], result)
      assert_builtin_expression_evaluation_result(:/, [left, right], result)
    end)
  end

  test "isIRI/isURI function" do
    [
      RDF.iri("http://example.com/foo"),
    ]
    |> Enum.each(fn positive_example ->
      assert_builtin_call_result(:isIRI, [positive_example], RDF.true)
      assert_builtin_expression_evaluation_result(:isIRI, [positive_example], RDF.true)
      assert_builtin_call_result(:isURI, [positive_example], RDF.true)
      assert_builtin_expression_evaluation_result(:isURI, [positive_example], RDF.true)
    end)

    [
      RDF.bnode("http://example.com/foo"),
      RDF.literal("http://example.com/foo"),
      "http://example.com/foo",
    ]
    |> Enum.each(fn negative_example ->
      assert_builtin_call_result(:isIRI, [negative_example], RDF.false)
      assert_builtin_expression_evaluation_result(:isIRI, [negative_example], RDF.false)
      assert_builtin_call_result(:isURI, [negative_example], RDF.false)
      assert_builtin_expression_evaluation_result(:isURI, [negative_example], RDF.false)
    end)

    assert_builtin_call_result(:isIRI, [:error], :error)
    assert_builtin_expression_evaluation_result(:isIRI, [:error], :error)
    assert_builtin_call_result(:isURI, [:error], :error)
    assert_builtin_expression_evaluation_result(:isURI, [:error], :error)
  end

  test "isBlank function" do
    [
      RDF.bnode("foo"),
      RDF.bnode(42),
      RDF.bnode(),
    ]
    |> Enum.each(fn positive_example ->
      assert_builtin_call_result(:isBlank, [positive_example], RDF.true)
      assert_builtin_expression_evaluation_result(:isBlank, [positive_example], RDF.true)
    end)

    [
      RDF.literal("foo"),
      RDF.iri("foo"),
      "foo",
    ]
    |> Enum.each(fn negative_example ->
      assert_builtin_call_result(:isBlank, [negative_example], RDF.false)
      assert_builtin_expression_evaluation_result(:isBlank, [negative_example], RDF.false)
    end)

    assert_builtin_call_result(:isBlank, [:error], :error)
    assert_builtin_expression_evaluation_result(:isBlank, [:error], :error)
  end


  defp assert_builtin_call_result(builtin, args, expected) do
    result = Builtins.call(builtin, args)
    assert result == expected, """
      expected SPARQL builtin call #{builtin}(\n\t#{args |> Stream.map(&inspect/1) |> Enum.join(",\n\t")})
      to be:   #{inspect expected}
      but got: #{inspect result}
      """
  end

  defp assert_builtin_expression_evaluation_result(builtin, args, expected) do
    result = Expression.evaluate(%FunctionCall.Builtin{name: builtin, arguments: args}, nil)
    assert result == expected, """
      expected SPARQL builtin expression evaluation #{builtin}(\n\t#{args |> Stream.map(&inspect/1) |> Enum.join(",\n\t")})
      to be:   #{inspect expected}
      but got: #{inspect result}
      """
  end

end
