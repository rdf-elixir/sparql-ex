defmodule SPARQL.Functions.BuiltinsTest do
  use SPARQL.Test.Case

  doctest SPARQL.Functions.Builtins

  alias SPARQL.Functions.Builtins
  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall

  alias RDF.Literal
  alias RDF.NS.XSD

  @xsd_string XSD.string

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
     RDF.literal("http://example.com/", datatype: XSD.anyURI)},
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
#    {RDF.literal(0, datatype: XSD.byte), RDF.integer(1)},
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
        assert_builtin_result(:=, [left, right], RDF.true)
      end
    end

    test "with equal values" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_result(:=, [left, right], RDF.true)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:=, [left, right], RDF.false)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_result(:=, [left, right], RDF.false)
      end
    end

    test "with incompatible terms" do
      Enum.each @incomparable_terms, fn {left, right} ->
        assert_builtin_result(:=, [left, right], :error)
      end
    end
  end

  describe "!= operator" do
    test "with equal terms" do
      Enum.each @equal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], RDF.false)
      end
    end

    test "with equal values" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], RDF.false)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], RDF.true)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], RDF.true)
      end
    end

    test "with incompatible terms" do
      Enum.each @incomparable_terms, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], :error)
      end
    end
  end

  describe "sameTerm function" do
    test "with equal terms" do
      Enum.each @equal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], RDF.true)
      end
    end

    test "with equal values, but unequal terms" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], RDF.false)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], RDF.false)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], RDF.false)
      end
    end

    test "with incompatible terms" do
      Enum.each @incomparable_terms, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], RDF.false)
      end
    end
  end

  describe "< operator" do
    test "with booleans" do
      assert_builtin_result(:<, [RDF.false, RDF.true], RDF.true)
      assert_builtin_result(:<, [RDF.true, RDF.false], RDF.false)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<, [left, right], RDF.true)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<, [right, left], RDF.false)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<, [left, right], RDF.true)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<, [right, left], RDF.false)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<, [left, right], RDF.true)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<, [right, left], RDF.false)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
        assert_builtin_result(:<, [left, right], RDF.false)
      end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_result(:<, [left, right], :error)
      end
    end
  end

  describe "<= operator" do
    test "with booleans" do
      assert_builtin_result(:<=, [RDF.false, RDF.true], RDF.true)
      assert_builtin_result(:<=, [RDF.true, RDF.false], RDF.false)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], RDF.true)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<=, [right, left], RDF.false)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], RDF.true)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<=, [right, left], RDF.false)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], RDF.true)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<=, [right, left], RDF.false)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], RDF.true)
      end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], :error)
      end
    end
  end

  describe "> operator" do
    test "with booleans" do
      assert_builtin_result(:>, [RDF.false, RDF.true], RDF.false)
      assert_builtin_result(:>, [RDF.true, RDF.false], RDF.true)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>, [left, right], RDF.false)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>, [right, left], RDF.true)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>, [left, right], RDF.false)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>, [right, left], RDF.true)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>, [left, right], RDF.false)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>, [right, left], RDF.true)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
        assert_builtin_result(:>, [left, right], RDF.false)
      end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_result(:>, [left, right], :error)
      end
    end
  end

  describe ">= operator" do
    test "with booleans" do
      assert_builtin_result(:>=, [RDF.false, RDF.true], RDF.false)
      assert_builtin_result(:>=, [RDF.true, RDF.false], RDF.true)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>=, [left, right], RDF.false)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>=, [right, left], RDF.true)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>=, [left, right], RDF.false)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>=, [right, left], RDF.true)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>=, [left, right], RDF.false)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>=, [right, left], RDF.true)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
          assert_builtin_result(:>=, [left, right], RDF.true)
        end
    end

    test "with incomparable literals" do
      Enum.each @incomparable_literals, fn {left, right} ->
        assert_builtin_result(:>=, [left, right], :error)
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
         assert_builtin_result(:!, [value], result)
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

  test "unary + operator" do
    [
      {RDF.integer(42),   RDF.integer(42)},
      {RDF.double(3.14),  RDF.double(3.14)},
      {RDF.decimal(3.14), RDF.decimal(3.14)},
      {RDF.string("42"),  :error},
      {RDF.true,          :error},
      {nil,               :error},
      {:error,            :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:+, [value], result)
       end)
  end

  test "unary - operator" do
    [
      {RDF.integer(42),    RDF.integer(-42)},
      {RDF.double(3.14),   RDF.double(-3.14)},
      {RDF.decimal(3.14),  RDF.decimal(-3.14)},
      {RDF.integer(-42),   RDF.integer(42)},
      {RDF.double(-3.14),  RDF.double(3.14)},
      {RDF.decimal(-3.14), RDF.decimal(3.14)},
      {RDF.string("42"),   :error},
      {RDF.true,           :error},
      {nil,                :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:-, [value], result)
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
         assert_builtin_result(:+, [left, right], result)
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
         assert_builtin_result(:-, [left, right], result)
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
         assert_builtin_result(:*, [left, right], result)
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
         assert_builtin_result(:/, [left, right], result)
       end)
  end

  test "isIRI/isURI function" do
    [
      RDF.iri("http://example.com/foo"),
    ]
    |> Enum.each(fn positive_example ->
         assert_builtin_result(:isIRI, [positive_example], RDF.true)
         assert_builtin_result(:isURI, [positive_example], RDF.true)
       end)

    [
      RDF.bnode("http://example.com/foo"),
      RDF.literal("http://example.com/foo"),
      "http://example.com/foo",
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isIRI, [negative_example], RDF.false)
         assert_builtin_result(:isURI, [negative_example], RDF.false)
       end)

    assert_builtin_result(:isIRI, [:error], :error)
    assert_builtin_result(:isURI, [:error], :error)
  end

  test "isBlank function" do
    [
      RDF.bnode("foo"),
      RDF.bnode(42),
      RDF.bnode(),
    ]
    |> Enum.each(fn positive_example ->
         assert_builtin_result(:isBLANK, [positive_example], RDF.true)
       end)

    [
      RDF.literal("foo"),
      RDF.iri("foo"),
      "foo",
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isBLANK, [negative_example], RDF.false)
       end)

    assert_builtin_result(:isBLANK, [:error], :error)
  end

  test "isLiteral function" do
    [
      RDF.literal("foo"),
      RDF.literal("foo", language: "en"),
      RDF.integer(42),
    ]
    |> Enum.each(fn positive_example ->
         assert_builtin_result(:isLITERAL, [positive_example], RDF.true)
       end)

    [
      RDF.iri("http://example.com/foo"),
      RDF.bnode("foo"),
      "foo",
      42,
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isLITERAL, [negative_example], RDF.false)
       end)

    assert_builtin_result(:isLITERAL, [:error], :error)
  end

  test "isNumeric function" do
    [
      RDF.integer(42),
      RDF.double("3.14"),
      RDF.literal("42", datatype: XSD.nonPositiveInteger),
    ]
    |> Enum.each(fn positive_example ->
         assert_builtin_result(:isNUMERIC, [positive_example], RDF.true)
       end)

    [
      RDF.literal("42"),
      RDF.literal("42", language: "en"),
      RDF.integer("3.14"),
      RDF.decimal("foo"),
      RDF.iri("http://example.com/foo"),
      RDF.bnode("foo"),
      "foo",
      42,
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isNUMERIC, [negative_example], RDF.false)
       end)

    assert_builtin_result(:isNUMERIC, [:error], :error)
  end

  test "str function" do
    [
      {RDF.string("foo"), RDF.string("foo")},
      {RDF.lang_string("foo", language: "en"), RDF.string("foo")},
      {RDF.integer(42), RDF.string("42")},
      {RDF.double("3.14"), RDF.string("3.14")},
      {RDF.literal("42", datatype: XSD.nonPositiveInteger), RDF.string("42")},

      {RDF.iri("http://example.com/"), RDF.string("http://example.com/")},

      {RDF.bnode("foo"), :error},

      {:error, :error}
    ]
    |> Enum.each(fn {arg, result} ->
         assert_builtin_result(:STR, [arg], result)
       end)
  end

  test "lang function" do
    [
      {RDF.lang_string("foo", language: "en"), RDF.string("en")},

      {RDF.string("foo"), ~L""},

      {RDF.integer(42), ~L""},

      {RDF.iri("http://example.com/"), :error},
      {RDF.bnode("foo"), :error},
      {:error, :error}
    ]
    |> Enum.each(fn {arg, result} ->
         assert_builtin_result(:LANG, [arg], result)
       end)
  end

  test "datatype function" do
    [
      {RDF.integer(42),                        XSD.integer},
      {RDF.string("foo"),                      XSD.string},
      {RDF.lang_string("foo", language: "en"), RDF.langString},
      {~L"foo",                                XSD.string},

      {RDF.iri("http://example.com/"), :error},
      {RDF.bnode("foo"), :error},
      {:error, :error}
    ]
    |> Enum.each(fn {arg, result} ->
         assert_builtin_result(:DATATYPE, [arg], result)
       end)
  end

  test "STRDT function" do
    [
      {RDF.string("123"),  XSD.integer, RDF.integer("123")},
      {RDF.string("iiii"), RDF.iri("http://example/romanNumeral"),
        RDF.literal("iiii", datatype: RDF.iri("http://example/romanNumeral"))},

      {RDF.integer(123), XSD.string, RDF.string("123")},
      {RDF.integer(123), XSD.double, RDF.double("123")},

      # TODO: Should this be an error? An rdf:langString with an empty language is invalid.
      {RDF.string("foo"), RDF.langString, RDF.lang_string("foo")},

      {RDF.string("123"), :error, :error},
      {:error, XSD.integer, :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {literal, datatype, result} ->
         assert_builtin_result(:STRDT, [literal, datatype], result)
       end)
  end

  test "STRLANG function" do
    valid_language = RDF.string("en")
    [
      {RDF.string("foo"), valid_language, RDF.lang_string("foo", language: "en")},

      {RDF.lang_string("foo"), valid_language, :error},
      {RDF.integer(42),        valid_language, :error},
      {:error,                 valid_language, :error},

      {RDF.string("foo"), RDF.string(""),         :error},
      {RDF.string("foo"), RDF.lang_string("en"),  :error},
      {RDF.string("foo"), RDF.integer(42),        :error},
      {RDF.string("foo"), :error,                 :error},

      {:error, :error, :error},
    ]
    |> Enum.each(fn {literal, language, result} ->
         assert_builtin_result(:STRLANG, [literal, language], result)
       end)
  end


  describe "IRI/URI function" do
    test "simple cases" do
      [
        {RDF.iri("http://example/"),    RDF.iri("http://example/")},
        {RDF.string("http://example/"), RDF.iri("http://example/")},
        {~L"http://example/",           RDF.iri("http://example/")},

        {RDF.lang_string("http://example/", language: "en"), :error},
        {RDF.integer(42),  :error},
        {RDF.bnode("foo"), :error},
        {:error, :error}
      ]
      |> Enum.each(fn {arg, result} ->
           assert_builtin_result(:IRI, [arg], result)
           assert_builtin_result(:URI, [arg], result)
         end)
    end

    @tag skip: "TODO: How do we get the base IRI here?"
    test "relative IRIs"

    @tag skip: "TODO: implement and use RDF.IRI.normalize/1"
    test "normalization"

  end

  describe "BNODE function" do
    test "without args" do
      assert %RDF.BlankNode{} = bnode1 = Builtins.call(:BNODE, [])
      assert %RDF.BlankNode{} = bnode2 = Builtins.call(:BNODE, [])
      assert bnode1 != bnode2
      assert %RDF.BlankNode{} =
               Expression.evaluate(%FunctionCall.Builtin{name: :BNODE, arguments: []}, nil)
    end

    @tag skip: "TODO: We need some form of global state for this"
    test "with a string" do
      assert %RDF.BlankNode{} = bnode1 = Builtins.call(:BNODE, [~L"foo"])
      assert Builtins.call(:BNODE, [~L"foo"]) == bnode1
      assert %RDF.BlankNode{} = bnode2 = Builtins.call(:BNODE, [~L"bar"])
      assert bnode1 != bnode2
      assert Expression.evaluate(%FunctionCall.Builtin{name: :BNODE, arguments: [~L"foo"]}, nil)
             == bnode1
    end
  end

  test "UUID function" do
    assert %RDF.IRI{value: "urn:uuid:" <> _} = uuid1 = Builtins.call(:UUID, [])
    assert %RDF.IRI{value: "urn:uuid:" <> _} = uuid2 = Builtins.call(:UUID, [])
    assert uuid1 != uuid2
    assert %RDF.IRI{value: "urn:uuid:" <> _} =
             Expression.evaluate(%FunctionCall.Builtin{name: :UUID, arguments: []}, nil)
  end

  test "STRUUID function" do
    assert %Literal{datatype: @xsd_string} = uuid1 = Builtins.call(:STRUUID, [])
    assert %Literal{datatype: @xsd_string} = uuid2 = Builtins.call(:STRUUID, [])
    assert uuid1 != uuid2
    assert %Literal{datatype: @xsd_string} =
             Expression.evaluate(%FunctionCall.Builtin{name: :STRUUID, arguments: []}, nil)
  end

  test "STRLEN function" do
    [
      {~L"chat",           RDF.integer(4)},
      {RDF.string("chat"), RDF.integer(4)},
      {~L"chat"en,         RDF.integer(4)},
      {RDF.integer(42),    :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {string, result} ->
         assert_builtin_result(:STRLEN, [string], result)
       end)
  end

  describe "SUBSTR function" do
    test "without length" do
      [
        {RDF.string("foobar"), RDF.integer(4), RDF.string("bar")},
        {~L"foobar",           RDF.integer(4), ~L"bar"},
        {~L"foobar"en,         RDF.integer(4), ~L"bar"en},

        {RDF.integer(42),      RDF.integer(4), :error},
        {RDF.string("foo"),    RDF.string(4),  :error},

        {:error,               RDF.integer(4), :error},
        {RDF.string("foo"),    :error,         :error},
        {:error,               :error,         :error},
      ]
      |> Enum.each(fn {source, starting_loc, result} ->
           assert_builtin_result(:SUBSTR, [source, starting_loc], result)
         end)
    end

    test "with length" do
      [
        {RDF.string("foobar"), RDF.integer(4), RDF.integer(1), RDF.string("b")},
        {~L"foobar",           RDF.integer(4), RDF.integer(1), ~L"b"},
        {~L"foobar"en,         RDF.integer(4), RDF.integer(1), ~L"b"en},

        {RDF.integer(42),      RDF.integer(4), RDF.integer(1), :error},
        {RDF.string("foo"),    RDF.string(4),  RDF.integer(1), :error},
        {RDF.string("foo"),    RDF.integer(4), RDF.string(1),  :error},

        {:error,               RDF.integer(4), RDF.integer(1), :error},
        {RDF.string("foo"),    :error,         RDF.integer(1), :error},
        {RDF.string("foo"),    RDF.integer(4), :error,         :error},
        {:error,               :error,         :error,         :error},
      ]
      |> Enum.each(fn {source, starting_loc, length, result} ->
           assert_builtin_result(:SUBSTR, [source, starting_loc, length], result)
         end)
    end

    @tag skip: "TODO: We need support for derived datatypes in general and integers in particular"
    test "with derived integer as starting location" do
      assert_builtin_result(:SUBSTR,
        [RDF.string("foobar"), RDF.literal(4, datatype: XSD.byte)], RDF.string("bar"))
    end

    @tag skip: "TODO: We need support for derived datatypes in general and integers in particular"
    test "with derived integer as length" do
      assert_builtin_result(:SUBSTR, [
          RDF.string("foobar"),
          RDF.integer(4),
          RDF.literal(1, datatype: XSD.byte)
        ],
        RDF.string("b"))
    end
  end

  test "UCASE function" do
    [
      {RDF.string("foo"), RDF.string("FOO")},
      {~L"foo",           ~L"FOO"},
      {~L"foo"en,         ~L"FOO"en},
      {RDF.integer(42),    :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {string, result} ->
         assert_builtin_result(:UCASE, [string], result)
       end)
  end

  test "LCASE function" do
    [
      {RDF.string("BAR"), RDF.string("bar")},
      {~L"BAR",           ~L"bar"},
      {~L"BAR"en,         ~L"bar"en},
      {RDF.integer(42),    :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {string, result} ->
         assert_builtin_result(:LCASE, [string], result)
       end)
  end

  test "STRSTARTS function" do
    [
      {~L"foobar",           ~L"foo",           RDF.true},
      {~L"foobar"en,         ~L"foo"en,         RDF.true},
      {RDF.string("foobar"), RDF.string("foo"), RDF.true},
      {RDF.string("foobar"), ~L"foo",           RDF.true},
      {~L"foobar",           RDF.string("foo"), RDF.true},
      {~L"foobar"en,         ~L"foo",           RDF.true},
      {~L"foobar"en,         RDF.string("foo"), RDF.true},
      {~L"foo",           ~L"foobar",           RDF.false},

      {~L"foobar"en, ~L"foo"de, :error},
      {~L"foobar",   ~L"foo"de, :error},

      {RDF.string("42"),  RDF.integer("4"), :error},
      {RDF.integer("42"), RDF.string("4"),  :error},
      {:error,            RDF.integer(42),  :error},
      {RDF.integer(42),   :error,           :error},
      {:error,            :error,           :error},
    ]
    |> Enum.each(fn {arg1, arg2, result} ->
         assert_builtin_result(:STRSTARTS, [arg1, arg2], result)
       end)
  end

  test "STRENDS function" do
    [
      {~L"foobar",           ~L"bar",           RDF.true},
      {~L"foobar"en,         ~L"bar"en,         RDF.true},
      {RDF.string("foobar"), RDF.string("bar"), RDF.true},
      {RDF.string("foobar"), ~L"bar",           RDF.true},
      {~L"foobar",           RDF.string("bar"), RDF.true},
      {~L"foobar"en,         ~L"bar",           RDF.true},
      {~L"foobar"en,         RDF.string("bar"), RDF.true},
      {~L"foo",           ~L"foobar",           RDF.false},

      {~L"foobar"en, ~L"bar"de, :error},
      {~L"foobar",   ~L"bar"de, :error},

      {RDF.string("42"),  RDF.integer("2"), :error},
      {RDF.integer("42"), RDF.string("2"),  :error},
      {:error,            RDF.integer(42),  :error},
      {RDF.integer(42),   :error,           :error},
      {:error,            :error,           :error},
    ]
    |> Enum.each(fn {arg1, arg2, result} ->
         assert_builtin_result(:STRENDS, [arg1, arg2], result)
       end)
  end

  test "CONTAINS function" do
    [
      {~L"foobar",           ~L"bar",           RDF.true},
      {~L"foobar"en,         ~L"foo"en,         RDF.true},
      {RDF.string("foobar"), RDF.string("bar"), RDF.true},
      {RDF.string("foobar"), ~L"foo",           RDF.true},
      {~L"foobar",           RDF.string("bar"), RDF.true},
      {~L"foobar"en,         ~L"foo",           RDF.true},
      {~L"foobar"en,         RDF.string("bar"), RDF.true},
      {~L"foo",           ~L"foobar",           RDF.false},

      {~L"foobar"en, ~L"bar"de, :error},
      {~L"foobar",   ~L"bar"de, :error},

      {RDF.string("42"),  RDF.integer("2"), :error},
      {RDF.integer("42"), RDF.string("2"),  :error},
      {:error,            RDF.integer(42),  :error},
      {RDF.integer(42),   :error,           :error},
      {:error,            :error,           :error},
    ]
    |> Enum.each(fn {arg1, arg2, result} ->
      assert_builtin_result(:CONTAINS, [arg1, arg2], result)
    end)
  end

  test "STRBEFORE function" do
    [
      {~L"abc",           ~L"b",           ~L"a"},
      {~L"abc"en,         ~L"bc",          ~L"a"en},
      {~L"abc"en,         ~L"b"cy,         :error},
      {RDF.string("abc"), ~L"",            RDF.string("")},
      {~L"abc",           ~L"xyz",         ~L""},
      {~L"abc"en,         ~L"z"en,         ~L""},
      {~L"abc"en,         ~L"z",           ~L""},
      {~L"abc"en,         ~L""en,          ~L""en},
      {~L"abc"en,         ~L"",            ~L""en},

      {RDF.string("42"),  RDF.integer("2"), :error},
      {RDF.integer("42"), RDF.string("2"),  :error},
      {:error,            RDF.integer(42),  :error},
      {RDF.integer(42),   :error,           :error},
      {:error,            :error,           :error},
    ]
    |> Enum.each(fn {arg1, arg2, result} ->
         assert_builtin_result(:STRBEFORE, [arg1, arg2], result)
       end)
  end

  test "STRAFTER function" do
    [
      {~L"abc",           ~L"b",           ~L"c"},
      {~L"abc"en,         ~L"ab",          ~L"c"en},
      {~L"abc"en,         ~L"b"cy,        :error},
      {RDF.string("abc"), ~L"",            RDF.string("abc")},
      {~L"abc",           ~L"xyz",         ~L""},
      {~L"abc"en,         ~L"z"en,         ~L""},
      {~L"abc"en,         ~L"z",           ~L""},
      {~L"abc"en,         ~L""en,          ~L"abc"en},
      {~L"abc"en,         ~L"",            ~L"abc"en},

      {RDF.string("42"),  RDF.integer("2"), :error},
      {RDF.integer("42"), RDF.string("2"),  :error},
      {:error,            RDF.integer(42),  :error},
      {RDF.integer(42),   :error,           :error},
      {:error,            :error,           :error},
    ]
    |> Enum.each(fn {arg1, arg2, result} ->
         assert_builtin_result(:STRAFTER, [arg1, arg2], result)
       end)
  end

  test "ENCODE_FOR_URI function" do
    [
      {~L"Los Angeles",           ~L"Los%20Angeles"},
      {~L"Los Angeles"en,         ~L"Los%20Angeles"},
      {RDF.string("Los Angeles"), ~L"Los%20Angeles"},

      {~L"http://www.example.com/00/Weather/CA/Los%20Angeles#ocean",
       ~L"http%3A%2F%2Fwww.example.com%2F00%2FWeather%2FCA%2FLos%2520Angeles%23ocean"},
      {~L"~bébé",        ~L"~b%C3%A9b%C3%A9"},
      {~L"100% organic", ~L"100%25%20organic"},

      {RDF.integer("42"), :error},
      {:error,            :error},
    ]
    |> Enum.each(fn {string, result} ->
         assert_builtin_result(:ENCODE_FOR_URI, [string], result)
       end)
  end

  test "CONCAT function" do
    [
      {[~L"foo",           ~L"bar"          ], ~L"foobar"},
      {[~L"foo"en,         ~L"bar"en        ], ~L"foobar"en},
      {[RDF.string("foo"), RDF.string("bar")], RDF.string("foobar")},
      {[~L"foo",           RDF.string("bar")], ~L"foobar"},
      {[~L"foo"en,         ~L"bar"          ], ~L"foobar"},
      {[~L"foo"en,         RDF.string("bar")], ~L"foobar"},


      {[~L"foo"en, RDF.string("bar"), ~L"baz"],  ~L"foobarbaz"},

      {[~L"foo"],   ~L"foo"},
      {[~L"foo"en], ~L"foo"en},
      {[], ~L""},

      {[RDF.string("4"),   RDF.integer("2")], :error},
      {[RDF.integer("4"),  RDF.string("2")],  :error},
      {[:error,            RDF.integer(42)],  :error},
      {[RDF.integer(42),   :error         ],  :error},
      {[:error,            :error         ],  :error},
    ]
    |> Enum.each(fn {args, result} ->
      assert_builtin_result(:CONCAT, args, result)
    end)
  end

  test "langMatches function" do
    [
      {~L"de",         ~L"de",    RDF.true},
      {~L"de",         ~L"DE",    RDF.true},
      {~L"de-DE",      ~L"de",    RDF.true},
      {~L"de-CH",      ~L"de",    RDF.true},
      {~L"de-CH",      ~L"de-ch", RDF.true},
      {~L"de-DE-1996", ~L"de-de", RDF.true},

      {~L"en",         ~L"de",    RDF.false},
      {~L"de",         ~L"de-CH", RDF.false},
      {~L"de-Deva",    ~L"de-de", RDF.false},
      {~L"de-Latn-DE", ~L"de-de", RDF.false},

      {~L"en",            ~L"en"en,          :error},
      {~L"en"en,          ~L"en",            :error},
      {~L"en",            RDF.integer("42"), :error},
      {RDF.integer("42"), ~L"en",            :error},
      {:error,            ~L"en",            :error},
      {~L"en",            :error,            :error},
      {:error,            :error,            :error},
    ]
    |> Enum.each(fn {language_tag, language_range, result} ->
         assert_builtin_result(:LANGMATCHES, [language_tag, language_range], result)
       end)
  end

  describe "REGEX function" do
    @poem RDF.string """
      <poem author="Wilhelm Busch">
      Kaum hat dies der Hahn gesehen,
      Fängt er auch schon an zu krähen:
      Kikeriki! Kikikerikih!!
      Tak, tak, tak! - da kommen sie.
      </poem>
      """

    test "without flags" do
      [
        {~L"abracadabra", ~L"bra",    RDF.true},
        {~L"abracadabra", ~L"^a.*a$", RDF.true},
        {~L"abracadabra", ~L"^bra",   RDF.false},
        {@poem, ~L"Kaum.*krähen",     RDF.false},
        {@poem, ~L"^Kaum.*gesehen,$", RDF.false},

        {~L"en"en,          ~L"en",            :error},
        {~L"en",            ~L"en"en,          :error},
        {~L"en",            RDF.integer("42"), :error},
        {RDF.integer("42"), ~L"en",            :error},
        {:error,            ~L"en",            :error},
        {~L"en",            :error,            :error},
        {:error,            :error,            :error},
      ]
      |> Enum.each(fn {text, pattern, result} ->
           assert_builtin_result(:REGEX, [text, pattern], result)
         end)
    end

    test "with flags" do
      [
        {@poem, ~L"Kaum.*krähen",     ~L"s", RDF.true},
        {@poem, ~L"^Kaum.*gesehen,$", ~L"m", RDF.true},
        {@poem, ~L"kiki",             ~L"i", RDF.true},

        {~L"en", ~L"en", RDF.integer("42"), :error},
        {~L"en", ~L"en", :error, :error},
        {:error, :error, :error, :error},
      ]
      |> Enum.each(fn {text, pattern, flags, result} ->
           assert_builtin_result(:REGEX, [text, pattern, flags], result)
         end)
    end

    test "with q flag" do
      [
        {~L"abcd",         ~L".*",       ~L"q",  RDF.false},
        {~L"Mr. B. Obama", ~L"B. OBAMA", ~L"iq", RDF.true},

        # If the q flag is used together with the m, s, or x flag, that flag has no effect.
        {~L"abcd",         ~L".*",       ~L"mq",   RDF.true},
        {~L"abcd",         ~L".*",       ~L"qim",  RDF.true},
        {~L"abcd",         ~L".*",       ~L"xqm",  RDF.true},
      ]
      |> Enum.each(fn {text, pattern, flags, result} ->
           assert_builtin_result(:REGEX, [text, pattern, flags], result)
         end)
    end
  end

  describe "REPLACE function" do
    test "without flags" do
      [
        {~L"abcd",        ~L"b",     ~L"Z",	    ~L"aZcd"},
        {~L"abracadabra", ~L"bra",   ~L"*",     ~L"a*cada*"},
        {~L"abracadabra", ~L"a.*a",  ~L"*",     ~L"*"},
        {~L"abracadabra", ~L"a.*?a", ~L"*",     ~L"*c*bra"},
        {~L"abracadabra", ~L"a",     ~L"",      ~L"brcdbr"},
        {~L"AAAA",        ~L"A+",    ~L"b",     ~L"b"},
        {~L"AAAA",        ~L"A+?",   ~L"b",     ~L"bbbb"},

        {~L"en"en, ~L"en",   ~L"de",   :error},
        {~L"en",   ~L"en"en, ~L"de",   :error},
        {~L"en",   ~L"en",   ~L"de"en, :error},
        {:error,   ~L"en",   ~L"de",   :error},
        {~L"en",   :error,   ~L"de",   :error},
        {~L"en",   ~L"en",   :error,   :error},
        {:error,   :error,   :error,   :error},
      ]
      |> Enum.each(fn {text, pattern, replacement, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement], result)
         end)
    end

    test "with flags" do
      [
        {~L"abab", ~L"B",  ~L"Z", ~L"i", ~L"aZaZ"},
        {~L"abab", ~L"B.", ~L"Z", ~L"i", ~L"aZb"},

        {~L"en",   ~L"en",   ~L"en",   ~L"i"en, :error},
        {:error,   ~L"en",   ~L"en",   ~L"i",   :error},
        {~L"en",   :error,   ~L"en",   ~L"i",   :error},
        {~L"en",   ~L"en",   :error,   ~L"i",   :error},
        {~L"en",   ~L"en",   ~L"en",   :error,  :error},
        {:error,   :error,   :error,   :error,  :error},
      ]
      |> Enum.each(fn {text, pattern, replacement, flags, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement, flags], result)
         end)
    end

    test "with q flag" do
      [
        {~L"a\b\c", RDF.string("\\"), ~L"\\", ~L"q", ~L"a\\b\\c"},
        {~L"a/b/c", ~L"/",            ~L"$",    ~L"q", ~L"a$b$c"},
      ]
      |> Enum.each(fn {text, pattern, replacement, flags, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement, flags], result)
         end)
    end

    @tag skip: "TODO"
    test "with combination of q and i flag"

    test "with variables in replacement" do
      [
        {~L"abracadabra", ~L"a(.)",         ~L"a$1$1", ~L"abbraccaddabbra"},
        {~L"darted",      ~L"^(.*?)d(.*)$", ~L"$1c$2", ~L"carted"}, # (The first d is replaced.)
      ]
      |> Enum.each(fn {text, pattern, replacement, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement], result)
         end)
    end

    @tag skip: "TODO"
    test "error Conditions" do
      [
        {~L"abracadabra", ~L".*?", ~L"$1", :error}, # because the pattern matches the zero-length string
        {~L"abracadabra", ~L"a(.)", ~L"$foo", :error}, # because replacement contains a $ that is not immediately followed by a digit and not immediately preceded by a backslash
        {~L"abracadabra", ~L"a(.)", RDF.string("\\"), :error}, # because replacement contains a backslash character that is not part of a \\ pair, or immediately followed by a $ character
      ]
      |> Enum.each(fn {text, pattern, replacement, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement], result)
         end)
    end
  end

  test "abs function" do
    [
      {RDF.integer(1),    RDF.integer(1)},
      {RDF.integer(-1),   RDF.integer(1)},
      {RDF.decimal(-1.5), RDF.decimal(1.5)},
      {RDF.double(-1.5),  RDF.double(1.5)},

      {~L"-42", :error},
      {:error,  :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:ABS, [numeric], result)
       end)
  end

  test "round function" do
    [
      {RDF.integer(1),      RDF.integer(1)},
      {RDF.decimal(2.4999), RDF.decimal(2.0)},
      {RDF.decimal(2.5),    RDF.decimal(3.0)},
      {RDF.decimal(-2.5),   RDF.decimal(-2.0)},
      {RDF.double(2.4999),  RDF.double(2.0)},
      {RDF.double(2.5),     RDF.double(3.0)},
      {RDF.double(-2.5),    RDF.double(-2.0)},

      {~L"42", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:ROUND, [numeric], result)
       end)
  end

  test "ceil function" do
    [
      {RDF.integer(1),      RDF.integer(1)},
      {RDF.decimal(10.5),   RDF.integer(11)},
      {RDF.decimal(-10.5),  RDF.integer(-10)},
      {RDF.double(10.5),    RDF.integer(11)},
      {RDF.double(-10.5),   RDF.integer(-10)},

      {~L"42", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:CEIL, [numeric], result)
       end)
  end

  test "floor function" do
    [
      {RDF.integer(1),      RDF.integer(1)},
      {RDF.decimal(10.5),   RDF.integer(10)},
      {RDF.decimal(-10.5),  RDF.integer(-11)},
      {RDF.double(10.5),    RDF.integer(10)},
      {RDF.double(-10.5),   RDF.integer(-11)},

      {~L"42", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:FLOOR, [numeric], result)
       end)
  end

  test "RAND function" do
    xsd_double = XSD.double
    assert %Literal{datatype: ^xsd_double, value: value} = Builtins.call(:RAND, [])
    assert value >= 0 and value < 1
    assert %Literal{datatype: ^xsd_double, value: another_value} = Builtins.call(:RAND, [])
    assert value != another_value

    assert %Literal{datatype: ^xsd_double, value: value} =
             Expression.evaluate(%FunctionCall.Builtin{name: :RAND, arguments: []}, nil)
    assert value >= 0 and value < 1
  end

  test "year function" do
    [
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), RDF.integer(2011)},
      {RDF.date_time("1999-12-31T19:20:00"),           RDF.integer(1999)},
      {RDF.date_time("1999-12-31T24:00:00"),           RDF.integer(2000)},
      {RDF.date_time("1999-05-31T13:20:00Z"),          RDF.integer(1999)},
      {RDF.date_time("1999-05-31T13:20:00-05:00"),     RDF.integer(1999)},
      {RDF.date_time("1999-05-31T13:20:00-05:00"),     RDF.integer(1999)},
      {RDF.date_time("1999-05-31T21:30:00-05:00"),     RDF.integer(1999)},
      {RDF.date_time("1999-12-31T21:30:00-05:00"),     RDF.integer(1999)},
# TODO: support for negative years in RDF.DateTime datatype
#      {RDF.date_time("-0002-06-06T00:00:00"), RDF.integer(-2)},

      {RDF.integer(1999), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:YEAR, [datetime], result)
       end)
  end

  test "month function" do
    [
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), RDF.integer(1)},
      {RDF.date_time("1999-12-31T19:20:00"),           RDF.integer(12)},
      {RDF.date_time("1999-12-31T24:00:00"),           RDF.integer(1)},
      {RDF.date_time("1999-12-31T19:20:00Z"),          RDF.integer(12)},
      {RDF.date_time("1999-05-31T13:20:00-05:00"),     RDF.integer(5)},
      {RDF.date_time("1999-12-31T19:20:00-05:00"),     RDF.integer(12)},

      {RDF.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:MONTH, [datetime], result)
       end)
  end

  test "day function" do
    [
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), RDF.integer(10)},
      {RDF.date_time("1999-12-31T19:20:00"),           RDF.integer(31)},
      {RDF.date_time("1999-12-31T24:00:00"),           RDF.integer(1)},
      {RDF.date_time("1999-12-31T19:20:00Z"),          RDF.integer(31)},
      {RDF.date_time("1999-05-31T13:20:00-05:00"),     RDF.integer(31)},
      {RDF.date_time("1999-12-31T20:00:00-05:00"),     RDF.integer(31)},

      {RDF.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:DAY, [datetime], result)
       end)
  end

  test "hours function" do
    [
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), RDF.integer(14)},
      {RDF.date_time("1999-12-31T12:00:00"),          RDF.integer(12)},
      {RDF.date_time("1999-12-31T24:00:00"),          RDF.integer(0)},
      {RDF.date_time("1999-12-31T19:20:00Z"),         RDF.integer(19)},
      {RDF.date_time("1999-05-31T08:20:00-05:00"),    RDF.integer(8)},
      {RDF.date_time("1999-12-31T21:20:00-05:00"),    RDF.integer(21)},

      {RDF.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:HOURS, [datetime], result)
       end)
  end

  test "minutes function" do
    [
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), RDF.integer(45)},
      {RDF.date_time("1999-05-31T13:30:00"),           RDF.integer(30)},
      {RDF.date_time("1999-05-31T13:30:00Z"),          RDF.integer(30)},
      {RDF.date_time("1999-05-31T13:20:00-05:00"),     RDF.integer(20)},
      {RDF.date_time("1999-05-31T13:30:00+05:30"),     RDF.integer(30)},

      {RDF.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:MINUTES, [datetime], result)
       end)
  end

  test "seconds function" do
    [
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), RDF.decimal(13.815)},
      {RDF.date_time("1999-05-31T13:20:00"),           RDF.decimal(0.0)},
      {RDF.date_time("1999-05-31T13:20:42Z"),          RDF.decimal(42.0)},
      {RDF.date_time("1999-05-31T13:20:12.340-05:00"), RDF.decimal(12.34)},
      {RDF.date_time("1999-05-31T13:20:12.034-05:00"), RDF.decimal(12.034)},

      {RDF.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:SECONDS, [datetime], result)
       end)
  end

  test "tz function" do
    [
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), ~L"-05:00"},
      {RDF.date_time("2011-01-10T14:45:13.815-05:00"), ~L"-05:00"},
      {RDF.date_time("2011-01-10T14:45:13.815Z"),      ~L"Z"},
      {RDF.date_time("2011-01-10T14:45:13.815"),       ~L""},

      {RDF.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:TZ, [datetime], result)
       end)
  end

  test "MD5 function" do
    [
      {~L"abc",           ~L"900150983cd24fb0d6963f7d28e17f72"},
      {RDF.string("abc"), ~L"900150983cd24fb0d6963f7d28e17f72"},

      {RDF.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:MD5, [value], result)
       end)
  end

  test "SHA1 function" do
    [
      {~L"abc",           ~L"a9993e364706816aba3e25717850c26c9cd0d89d"},
      {RDF.string("abc"), ~L"a9993e364706816aba3e25717850c26c9cd0d89d"},

      {RDF.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA1, [value], result)
       end)
  end

  test "SHA256 function" do
    [
      {~L"abc",           ~L"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"},
      {RDF.string("abc"), ~L"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"},

      {RDF.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA256, [value], result)
       end)
  end

  test "SHA384 function" do
    [
      {~L"abc",           ~L"cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7"},
      {RDF.string("abc"), ~L"cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7"},

      {RDF.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA384, [value], result)
       end)
  end

  test "SHA512 function" do
    [
      {~L"abc",           ~L"ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f"},
      {RDF.string("abc"), ~L"ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f"},

      {RDF.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA512, [value], result)
       end)
  end


  test "compatible_arguments?/2" do
    [
      {RDF.literal("abc"),	                     RDF.literal("b"),                       true},
      {RDF.literal("abc"),	                     RDF.literal("b", datatype: XSD.string), true},
      {RDF.literal("abc", datatype: XSD.string), RDF.literal("b"),                       true},
      {RDF.literal("abc", datatype: XSD.string), RDF.literal("b", datatype: XSD.string), true},
      {RDF.literal("abc", language: "en"),	     RDF.literal("b"),                       true},
      {RDF.literal("abc", language: "en"),	     RDF.literal("b", datatype: XSD.string), true},
      {RDF.literal("abc", language: "en"),	     RDF.literal("b", language: "en"),       true},
      {RDF.literal("abc", language: "fr"),	     RDF.literal("b", language: "ja"),       false},
      {RDF.literal("abc"),	                     RDF.literal("b", language: "ja"),       false},
      {RDF.literal("abc"),	                     RDF.literal("b", language: "en"),       false},
      {RDF.literal("abc", datatype: XSD.string), RDF.literal("b", language: "en"),       false},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert Builtins.compatible_arguments?(left, right) == result, (
            if result,
              do:   "expected #{inspect left} to be compatible with #{inspect right}, but it's not",
              else: "expected #{inspect left} to not be compatible with #{inspect right}, but it is"
           )
    end)
  end

  defp assert_builtin_result(builtin, args, expected) do
    assert_builtin_call_result(builtin, args, expected)
    assert_builtin_expression_evaluation_result(builtin, args, expected)
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
