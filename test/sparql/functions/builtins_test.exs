defmodule SPARQL.Functions.BuiltinsTest do
  use SPARQL.Test.Case

  doctest SPARQL.Functions.Builtins

  alias SPARQL.Functions.Builtins
  alias SPARQL.Algebra.Expression
  alias SPARQL.Algebra.FunctionCall

  @example_solution_id :example_ref
  @example_solution_data %{solution: %{:__id__ => @example_solution_id}}


  @term_equal_rdf_literals [
    # String literals
    {XSD.string("foo"), XSD.string("foo")},
    {RDF.lang_string("foo", language: "de"), RDF.lang_string("foo", language: "de")},

    # Boolean literals
    {XSD.false, XSD.false},

    # Numeric literals
    {XSD.integer("042"), XSD.integer("042")},

    # DateTime literals
    {XSD.date_time("2002-04-02T12:00:00-01:00"), XSD.date_time("2002-04-02T12:00:00-01:00")},
    {XSD.date_time("2002-04-02T12:00:00"),       XSD.date_time("2002-04-02T12:00:00")},
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
    {XSD.string("foo"), XSD.string("bar")},
    {RDF.lang_string("foo", language: "de"), RDF.lang_string("bar", language: "de")},

    # Boolean literals
    {XSD.true, XSD.false},

    # Numeric literals
    {XSD.integer(1), XSD.integer(2)},

    # DateTime literals
    {XSD.date_time("2002-04-02T12:00:00"), XSD.date_time("2002-04-02T17:00:00")},
  ]

  @value_equal_rdf_literals [
    # Boolean literals
    {XSD.true, XSD.boolean("1")},

    # Numeric literals
    {XSD.integer("42"), XSD.integer("042")},
    {XSD.integer("42"), XSD.double("42")},
    {XSD.integer(42),   XSD.double(42.0)},
    {XSD.integer(42),   XSD.decimal(42.0)},
    {XSD.double(42.0),  XSD.decimal(42.0)},
    {XSD.double("+0"),  XSD.double("-0")},

    # DateTime literals
    {XSD.date_time("2002-04-02T12:00:00-01:00"), XSD.date_time("2002-04-02T17:00:00+04:00")},
    {XSD.date_time("2002-04-02T23:00:00-04:00"), XSD.date_time("2002-04-03T02:00:00-01:00")},
    {XSD.date_time("1999-12-31T24:00:00"),       XSD.date_time("2000-01-01T00:00:00")},
  ]

  @equal_rdf_values [
    # IRIs
    # RDF URI references are compatible with the anyURI datatype as defined by XML schema datatypes, constrained to be an absolute rather than a relative URI reference.
    {RDF.iri("http://example.com/"), XSD.anyURI("http://example.com/")},
  ] ++ @value_equal_rdf_literals

  @unequal_rdf_values [
    # IRIs
    {RDF.iri("http://example.com/foo"), XSD.anyURI("http://example.com/bar")},

    # Boolean literals
    {XSD.true,       XSD.boolean("false")},
    {XSD.boolean(0), XSD.true},

    # Numeric literals
    {XSD.integer("1"), XSD.double("1.1")},

    # DateTime literals
    {XSD.date_time("2005-04-04T24:00:00"), XSD.date_time("2005-04-04T00:00:00")},
  ]

  @incomparable_literals [
    # String literals
    {XSD.string("foo"), RDF.lang_string("foo", language: "de")},
    {XSD.string("foo"), RDF.bnode("foo")},

    # Boolean literals
    {XSD.true,       nil},
    {XSD.true,       XSD.string("false")},
    {XSD.integer(0), XSD.true},

    # Numeric literals
    {XSD.integer("42"),   XSD.string("42")},
# TODO: How to handle invalid number literals?
#    {XSD.integer("3.14"), XSD.integer("007")},

    # DateTime literals
    {XSD.date_time("2002-04-02T12:00:00-01:00"), XSD.string("2002-04-02T12:00:00-01:00")},
  ]

  @incomparable_terms [
    # IRIs
    {RDF.iri("http://example.com/"), XSD.string("http://example.com/")},

    # Blank Nodes
    {RDF.bnode("foo"), XSD.string("foo")},

  ] ++ @incomparable_literals

  @ordered_numbers [
    {XSD.integer(0),   XSD.integer(1)},
    {XSD.integer("3"), XSD.integer("007")},
    {XSD.double(1.1),  XSD.double(2.2)},
    {XSD.decimal(1.1), XSD.decimal(2.2)},
    {XSD.decimal(1.1), XSD.double(2.2)},
    {XSD.double(3.14), XSD.integer(42)},
    {XSD.decimal(3.14), XSD.integer(42)},
    {RDF.literal(0, datatype: NS.XSD.byte), XSD.integer(1)},
    {XSD.integer(1), RDF.literal(2, datatype: NS.XSD.positiveInteger)},
# TODO: How to handle invalid number literals?
#    {XSD.integer("3.14"), XSD.integer("007")},
  ]

  @ordered_strings [
    {XSD.string("a"), XSD.string("b")},
    {XSD.string("0"), XSD.string("1")},
  ]

  @ordered_datetimes [
    {XSD.date_time("2002-04-02T12:00:00"), XSD.date_time("2002-04-02T17:00:00")},
    {XSD.date_time("2002-04-02T12:00:00+01:00"), XSD.date_time("2002-04-02T12:00:00+00:00")},
  ]


  describe "= operator" do
    test "with equal terms" do
      Enum.each @equal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:=, [left, right], XSD.true)
      end
    end

    test "with equal values" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_result(:=, [left, right], XSD.true)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:=, [left, right], XSD.false)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_result(:=, [left, right], XSD.false)
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
        assert_builtin_result(:!=, [left, right], XSD.false)
      end
    end

    test "with equal values" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], XSD.false)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], XSD.true)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_result(:!=, [left, right], XSD.true)
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
        assert_builtin_result(:sameTerm, [left, right], XSD.true)
      end
    end

    test "with equal values, but unequal terms" do
      Enum.each @equal_rdf_values, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], XSD.false)
      end
    end

    test "with unequal terms" do
      Enum.each @unequal_rdf_terms, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], XSD.false)
      end
    end

    test "with unequal values" do
      Enum.each @unequal_rdf_values, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], XSD.false)
      end
    end

    test "with incompatible terms" do
      Enum.each @incomparable_terms, fn {left, right} ->
        assert_builtin_result(:sameTerm, [left, right], XSD.false)
      end
    end
  end

  describe "< operator" do
    test "with booleans" do
      assert_builtin_result(:<, [XSD.false, XSD.true], XSD.true)
      assert_builtin_result(:<, [XSD.true, XSD.false], XSD.false)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<, [left, right], XSD.true)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<, [right, left], XSD.false)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<, [left, right], XSD.true)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<, [right, left], XSD.false)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<, [left, right], XSD.true)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<, [right, left], XSD.false)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
        assert_builtin_result(:<, [left, right], XSD.false)
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
      assert_builtin_result(:<=, [XSD.false, XSD.true], XSD.true)
      assert_builtin_result(:<=, [XSD.true, XSD.false], XSD.false)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], XSD.true)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:<=, [right, left], XSD.false)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], XSD.true)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:<=, [right, left], XSD.false)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], XSD.true)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:<=, [right, left], XSD.false)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
        assert_builtin_result(:<=, [left, right], XSD.true)
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
      assert_builtin_result(:>, [XSD.false, XSD.true], XSD.false)
      assert_builtin_result(:>, [XSD.true, XSD.false], XSD.true)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>, [left, right], XSD.false)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>, [right, left], XSD.true)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>, [left, right], XSD.false)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>, [right, left], XSD.true)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>, [left, right], XSD.false)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>, [right, left], XSD.true)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
        assert_builtin_result(:>, [left, right], XSD.false)
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
      assert_builtin_result(:>=, [XSD.false, XSD.true], XSD.false)
      assert_builtin_result(:>=, [XSD.true, XSD.false], XSD.true)
    end

    test "with numbers: left number smaller than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>=, [left, right], XSD.false)
      end
    end

    test "with numbers: left number greater than right number" do
      Enum.each @ordered_numbers, fn {left, right} ->
        assert_builtin_result(:>=, [right, left], XSD.true)
      end
    end

    test "with date_times: left date_time before than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>=, [left, right], XSD.false)
      end
    end

    test "with date_times: left date_time after than right date_time" do
      Enum.each @ordered_datetimes, fn {left, right} ->
        assert_builtin_result(:>=, [right, left], XSD.true)
      end
    end

    test "with strings: left string lexicographical before right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>=, [left, right], XSD.false)
      end
    end

    test "with strings: left string lexicographical after right string" do
      Enum.each @ordered_strings, fn {left, right} ->
        assert_builtin_result(:>=, [right, left], XSD.true)
      end
    end

    test "with equal literals" do
      Enum.each @term_equal_rdf_literals ++ @value_equal_rdf_literals, fn {left, right} ->
          assert_builtin_result(:>=, [left, right], XSD.true)
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
      {XSD.true,               XSD.false},
      {XSD.false,              XSD.true},
      {XSD.integer(42),        XSD.false},
      {XSD.string(""),         XSD.true},
      {XSD.date("2010-01-01"), :error},
      {nil,                    :error},
      {:error,                 :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:!, [value], result)
       end)
  end

  test "&& operator" do
    [
      {XSD.true,               XSD.true,  XSD.true},
      {XSD.integer(42),        XSD.false, XSD.false},
      {XSD.string(""),         XSD.true,  XSD.false},
      {XSD.false,              XSD.false, XSD.false},
      {XSD.true,               nil,       :error},
      {XSD.date("2010-01-01"), XSD.true,  :error},
      {XSD.false,              nil,       XSD.false},
      {:error,                 XSD.false, XSD.false},
      {:error,                 :error,    :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:&&, [left, right], result)
       end)
  end

  test "|| operator" do
    [
      {XSD.true,               XSD.true,  XSD.true},
      {XSD.string("foo"),      XSD.false, XSD.true},
      {XSD.integer(42),        XSD.true,  XSD.true},
      {XSD.false,              XSD.false, XSD.false},
      {XSD.true,               :error,    XSD.true},
      {nil,                    XSD.true,  XSD.true},
      {XSD.false,              :error,    :error},
      {XSD.date("2010-01-01"), XSD.false, :error},
      {:error,                 :error,    :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:||, [left, right], result)
       end)
  end

  test "IF function" do
    [
      {XSD.true,        XSD.integer(1),  XSD.integer(2), XSD.integer(1)},
      {XSD.false,       XSD.integer(1),  XSD.integer(2), XSD.integer(2)},
      {:error,          XSD.integer(1),  XSD.integer(2), :error},
      {XSD.integer(42), XSD.true,        :error,         XSD.true},
      {XSD.string(""),  :error,          XSD.false,      XSD.false},
      {nil,             XSD.true,        XSD.true,       :error},
    ]
    |> Enum.each(fn {condition, then_value, else_value, result} ->
         assert_builtin_expression_evaluation_result(:IF, [condition, then_value, else_value], result)
       end)
  end

  describe "bound function" do
    test "when the given variable is bound" do
      [
        {"foo", %{"foo" => ~L"bar"}},
        {"foo", %{"foo" => ~L""}},
        {"foo", %{"foo" => XSD.double("NAN")}},
        {"foo", %{"foo" => XSD.double("INF")}},
      ]
      |> Enum.each(fn {arg, solution} ->
           assert Expression.evaluate(%FunctionCall.Builtin{name: :BOUND, arguments: [arg]},
                    %{solution: Map.merge(solution, %{:__id__ => @example_solution_id})}, %{}) == XSD.true
         end)
    end

    test "when the given variable is unbound" do
      [
        {"foo", %{}},
      ]
      |> Enum.each(fn {arg, solution} ->
           assert Expression.evaluate(%FunctionCall.Builtin{name: :BOUND, arguments: [arg]},
                    %{solution: Map.merge(solution, %{:__id__ => @example_solution_id})}, %{}) == XSD.false
         end)
    end

    test "when given anything other than a variable" do
      [
        {~L"foo", %{"foo" => ~L"bar"}},
        {~L<http://foo>, %{"foo" => ~L"bar"}},
        {XSD.integer(42), %{"foo" => ~L"bar"}},
      ]
      |> Enum.each(fn {arg, solution} ->
           assert Expression.evaluate(%FunctionCall.Builtin{name: :BOUND, arguments: [arg]},
                    %{solution: Map.merge(solution, %{:__id__ => @example_solution_id})}, %{}) == :error
         end)
    end
  end
  
  test "COALESCE function" do
    [
      {[XSD.integer(42)], XSD.integer(42)},
      {[XSD.string(""), XSD.true], XSD.string("")},
      {["foo", XSD.true], XSD.true},
      {["foo"], :error},
      {[:error], :error},
      {[], :error},
    ]
    |> Enum.each(fn {expressions, result} ->
         assert_builtin_expression_evaluation_result(:COALESCE, expressions, result)
       end)
  end

  test "IN operator" do
    [
      {XSD.integer(2), [XSD.integer(1), XSD.integer(2), XSD.integer(3)], XSD.true},
      {XSD.integer(2), [], XSD.false},
      {XSD.integer(2), [~I<http://example/iri>, XSD.string("str"), XSD.double(2.0)], XSD.true},

      {XSD.integer(2), [:error, XSD.integer(2)], XSD.true},
      {XSD.integer(2), [XSD.integer(2), :error], XSD.true},
      {XSD.integer(2), [XSD.integer(3), :error], :error},

      {:error, [XSD.integer(2)], :error},
      {:error, [:error, XSD.integer(2)], :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:IN, [left, right], result)
       end)
  end

  test "NOT IN operator" do
    [
      {XSD.integer(2), [XSD.integer(1), XSD.integer(2), XSD.integer(3)],	XSD.false},
      {XSD.integer(2), [],	XSD.true},
      {XSD.integer(2), [~I<http://example/iri>, XSD.string("str"), XSD.double(2.0)],	XSD.false},

      {XSD.integer(2), [:error, XSD.integer(2)], XSD.false},
      {XSD.integer(2), [XSD.integer(2), :error], XSD.false},
      {XSD.integer(2), [XSD.integer(3), :error], :error},

      {:error, [XSD.integer(2)], :error},
      {:error, [:error, XSD.integer(2)], :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_expression_evaluation_result(:NOT_IN, [left, right], result)
       end)
  end

  test "unary + operator" do
    [
      {XSD.integer(42),   XSD.integer(42)},
      {XSD.double(3.14),  XSD.double(3.14)},
      {XSD.decimal(3.14), XSD.decimal(3.14)},
      {XSD.string("42"),  :error},
      {XSD.true,          :error},
      {nil,               :error},
      {:error,            :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:+, [value], result)
       end)
  end

  test "unary - operator" do
    [
      {XSD.integer(42),    XSD.integer(-42)},
      {XSD.double(3.14),   XSD.double(-3.14)},
      {XSD.decimal(3.14),  XSD.decimal(-3.14)},
      {XSD.integer(-42),   XSD.integer(42)},
      {XSD.double(-3.14),  XSD.double(3.14)},
      {XSD.decimal(-3.14), XSD.decimal(3.14)},
      {XSD.string("42"),   :error},
      {XSD.true,           :error},
      {nil,                :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:-, [value], result)
       end)
  end

  test "numeric + operator" do
    [
      {XSD.integer(1),  XSD.integer(2),    XSD.integer(3)},
      {XSD.integer(42), XSD.decimal(3.14), XSD.decimal(45.14)},
      {XSD.integer(42), XSD.double(3.14),  XSD.double(45.14)},

      {XSD.integer(1), :error, :error},
      {:error, XSD.integer(1), :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_result(:+, [left, right], result)
       end)
  end

  test "numeric - operator" do
    [
      {XSD.integer(3),  XSD.integer(2),    XSD.integer(1)},
      {XSD.integer(42), XSD.decimal(3.14), XSD.decimal(38.86)},
      {XSD.integer(42), XSD.double(3.14),  XSD.double(38.86)},

      {XSD.integer(1), :error, :error},
      {:error, XSD.integer(1), :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_result(:-, [left, right], result)
       end)
  end

  test "numeric * operator" do
    [
      {XSD.integer(2),   XSD.integer(3),   XSD.integer(6)},
      {XSD.decimal(1.5), XSD.double(3.14), XSD.double(4.71)},

      {XSD.integer(1), :error, :error},
      {:error, XSD.integer(1), :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {left, right, result} ->
         assert_builtin_result(:*, [left, right], result)
       end)
  end

  test "numeric / operator" do
    [
      {XSD.integer(3),   XSD.integer(2), XSD.decimal(1.5)},
      {XSD.decimal(1.5), XSD.double(2),  XSD.double(0.75)},

      {XSD.integer(1), :error, :error},
      {:error, XSD.integer(1), :error},
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
         assert_builtin_result(:isIRI, [positive_example], XSD.true)
         assert_builtin_result(:isURI, [positive_example], XSD.true)
       end)

    [
      RDF.bnode("http://example.com/foo"),
      RDF.literal("http://example.com/foo"),
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isIRI, [negative_example], XSD.false)
         assert_builtin_result(:isURI, [negative_example], XSD.false)
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
         assert_builtin_result(:isBLANK, [positive_example], XSD.true)
       end)

    [
      RDF.literal("foo"),
      RDF.iri("foo"),
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isBLANK, [negative_example], XSD.false)
       end)

    assert_builtin_result(:isBLANK, [:error], :error)
  end

  test "isLiteral function" do
    [
      RDF.literal("foo"),
      RDF.literal("foo", language: "en"),
      XSD.integer(42),
    ]
    |> Enum.each(fn positive_example ->
         assert_builtin_result(:isLITERAL, [positive_example], XSD.true)
       end)

    [
      RDF.iri("http://example.com/foo"),
      RDF.bnode("foo"),
      42,
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isLITERAL, [negative_example], XSD.false)
       end)

    assert_builtin_result(:isLITERAL, [:error], :error)
  end

  test "isNumeric function" do
    [
      XSD.integer(42),
      XSD.double("3.14"),
      XSD.nonPositiveInteger("-42"),
    ]
    |> Enum.each(fn positive_example ->
         assert_builtin_result(:isNUMERIC, [positive_example], XSD.true)
       end)

    [
      RDF.literal("42"),
      RDF.literal("42", language: "en"),
      XSD.integer("3.14"),
      XSD.decimal("foo"),
      RDF.iri("http://example.com/foo"),
      RDF.bnode("foo"),
      42,
    ]
    |> Enum.each(fn negative_example ->
         assert_builtin_result(:isNUMERIC, [negative_example], XSD.false)
       end)

    assert_builtin_result(:isNUMERIC, [:error], :error)
  end

  test "str function" do
    [
      {XSD.string("foo"), XSD.string("foo")},
      {RDF.lang_string("foo", language: "en"), XSD.string("foo")},
      {XSD.integer(42), XSD.string("42")},
      {XSD.double("3.14"), XSD.string("3.14")},
      {XSD.nonPositiveInteger("42"), XSD.string("42")},

      {RDF.iri("http://example.com/"), XSD.string("http://example.com/")},

      {RDF.bnode("foo"), :error},

      {:error, :error}
    ]
    |> Enum.each(fn {arg, result} ->
         assert_builtin_result(:STR, [arg], result)
       end)
  end

  test "lang function" do
    [
      {RDF.lang_string("foo", language: "en"), XSD.string("en")},

      {XSD.string("foo"), ~L""},

      {XSD.integer(42), ~L""},

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
      {XSD.integer(42),                        NS.XSD.integer},
      {XSD.string("foo"),                      NS.XSD.string},
      {RDF.lang_string("foo", language: "en"), RDF.langString},
      {~L"foo",                                NS.XSD.string},
      {XSD.byte(42),                           NS.XSD.byte},

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
      {XSD.string("123"),  NS.XSD.integer, XSD.integer("123")},
      {XSD.string("iiii"), RDF.iri("http://example/romanNumeral"),
        RDF.literal("iiii", datatype: RDF.iri("http://example/romanNumeral"))},

      # TODO: Should this be an error? An rdf:langString with an empty language is invalid.
      {XSD.string("foo"), RDF.langString, RDF.langString("foo", language: nil)},

      {RDF.lang_string("123", language: "en"), NS.XSD.integer, :error},
      {XSD.integer(123), NS.XSD.string, :error},
      {XSD.integer(123), NS.XSD.double, :error},

      {XSD.string("123"), :error, :error},
      {:error, NS.XSD.integer, :error},
      {:error, :error, :error},
    ]
    |> Enum.each(fn {literal, datatype, result} ->
         assert_builtin_result(:STRDT, [literal, datatype], result)
       end)
  end

  test "STRLANG function" do
    valid_language = XSD.string("en")
    [
      {XSD.string("foo"), valid_language, RDF.langString("foo", language: "en")},

      {RDF.lang_string("foo", language: ""), valid_language,   :error},
      {XSD.integer(42),                      valid_language,   :error},
      {:error,                               valid_language,   :error},

      {XSD.string("foo"), XSD.string(""),                      :error},
      {XSD.string("foo"), RDF.langString("en", language: ""),  :error},
      {XSD.string("foo"), XSD.integer(42),                     :error},
      {XSD.string("foo"), :error,                              :error},

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
        {XSD.string("http://example/"), RDF.iri("http://example/")},
        {~L"http://example/",           RDF.iri("http://example/")},

        {RDF.lang_string("http://example/", language: "en"), :error},
        {XSD.integer(42),  :error},
        {RDF.bnode("foo"), :error},
        {:error, :error}
      ]
      |> Enum.each(fn {arg, result} ->
           assert_builtin_result(:IRI, [arg], result)
           assert_builtin_result(:URI, [arg], result)
         end)
    end

    test "relative IRIs" do
      base = "http://example.com/"
      [
        {~L"foo", RDF.iri("http://example.com/foo")},

        {RDF.lang_string("foo", language: "en"), :error},
      ]
      |> Enum.each(fn {arg, result} ->
           assert Builtins.call(:IRI, [arg], %{base: base}) == result
           assert Builtins.call(:URI, [arg], %{base: base}) == result
           assert Expression.evaluate(%FunctionCall.Builtin{name: :IRI, arguments: [arg]},
                    @example_solution_data, %{base: base}) == result
           assert Expression.evaluate(%FunctionCall.Builtin{name: :URI, arguments: [arg]},
                    @example_solution_data, %{base: base}) == result
         end)
    end

    test "relative IRIs without base" do
      assert Builtins.call(:IRI, [~L"foo"], %{}) == :error
    end

    @tag skip: "TODO: implement and use RDF.IRI.normalize/1"
    test "normalization"

  end

  describe "BNODE function" do
    test "without args" do
      {:ok, generator} = BlankNode.Generator.start_link(BlankNode.Increment)
      execution = %{bnode_generator: generator, solution_id: @example_solution_id}
      assert %BlankNode{} = bnode1 = Builtins.call(:BNODE, [], execution)
      assert %BlankNode{} = bnode2 = Builtins.call(:BNODE, [], execution)
      assert bnode1 != bnode2
      assert %BlankNode{} =
               Expression.evaluate(%FunctionCall.Builtin{name: :BNODE, arguments: []},
                 @example_solution_data, execution)
      BlankNode.Generator.stop(generator)
    end

    test "with a string" do
      {:ok, generator} = BlankNode.Generator.start_link(BlankNode.Increment)
      execution = %{bnode_generator: generator, solution_id: @example_solution_id}
      assert %BlankNode{} = bnode1 = Builtins.call(:BNODE, [~L"foo"], execution)
      assert %BlankNode{} = bnode2 = Builtins.call(:BNODE, [~L"bar"], execution)
      assert bnode1 != bnode2
      assert Builtins.call(:BNODE, [~L"foo"], execution) == bnode1
      assert Builtins.call(:BNODE, [~L"foo"], Map.put(execution, :solution_id, :other_ref)) != bnode1
      assert Expression.evaluate(%FunctionCall.Builtin{name: :BNODE, arguments: [~L"foo"]},
               @example_solution_data, execution) == bnode1
      BlankNode.Generator.stop(generator)
    end
  end

  test "UUID function" do
    assert %IRI{value: "urn:uuid:" <> _} = uuid1 = Builtins.call(:UUID, [], %{})
    assert %IRI{value: "urn:uuid:" <> _} = uuid2 = Builtins.call(:UUID, [], %{})
    assert uuid1 != uuid2
    assert %IRI{value: "urn:uuid:" <> _} =
             Expression.evaluate(%FunctionCall.Builtin{name: :UUID, arguments: []},
                                  @example_solution_data, %{})
  end

  test "STRUUID function" do
    assert %Literal{literal: %XSD.String{}} = uuid1 = Builtins.call(:STRUUID, [], %{})
    assert %Literal{literal: %XSD.String{}} = uuid2 = Builtins.call(:STRUUID, [], %{})
    assert uuid1 != uuid2
    assert %Literal{literal: %XSD.String{}} =
             Expression.evaluate(%FunctionCall.Builtin{name: :STRUUID, arguments: []},
                                  @example_solution_data, %{})
  end

  test "STRLEN function" do
    [
      {~L"chat",           XSD.integer(4)},
      {XSD.string("chat"), XSD.integer(4)},
      {~L"chat"en,         XSD.integer(4)},
      {XSD.integer(42),    :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {string, result} ->
         assert_builtin_result(:STRLEN, [string], result)
       end)
  end

  describe "SUBSTR function" do
    test "without length" do
      [
        {XSD.string("foobar"), XSD.integer(4), XSD.string("bar")},
        {~L"foobar",           XSD.integer(4), ~L"bar"},
        {~L"foobar"en,         XSD.integer(4), ~L"bar"en},

        {XSD.integer(42),      XSD.integer(4), :error},
        {XSD.string("foo"),    XSD.string(4),  :error},

        {:error,               XSD.integer(4), :error},
        {XSD.string("foo"),    :error,         :error},
        {:error,               :error,         :error},
      ]
      |> Enum.each(fn {source, starting_loc, result} ->
           assert_builtin_result(:SUBSTR, [source, starting_loc], result)
         end)
    end

    test "with length" do
      [
        {XSD.string("foobar"), XSD.integer(4), XSD.integer(1), XSD.string("b")},
        {~L"foobar",           XSD.integer(4), XSD.integer(1), ~L"b"},
        {~L"foobar"en,         XSD.integer(4), XSD.integer(1), ~L"b"en},

        {XSD.integer(42),      XSD.integer(4), XSD.integer(1), :error},
        {XSD.string("foo"),    XSD.string(4),  XSD.integer(1), :error},
        {XSD.string("foo"),    XSD.integer(4), XSD.string(1),  :error},

        {:error,               XSD.integer(4), XSD.integer(1), :error},
        {XSD.string("foo"),    :error,         XSD.integer(1), :error},
        {XSD.string("foo"),    XSD.integer(4), :error,         :error},
        {:error,               :error,         :error,         :error},
      ]
      |> Enum.each(fn {source, starting_loc, length, result} ->
           assert_builtin_result(:SUBSTR, [source, starting_loc, length], result)
         end)
    end

    test "with derived integer as starting location" do
      assert_builtin_result(:SUBSTR,
        [XSD.string("foobar"), RDF.literal(4, datatype: NS.XSD.byte)], XSD.string("bar"))
    end

    test "with derived integer as length" do
      assert_builtin_result(:SUBSTR, [
          XSD.string("foobar"),
          XSD.integer(4),
          RDF.literal(1, datatype: NS.XSD.byte)
        ],
        XSD.string("b"))
    end
  end

  test "UCASE function" do
    [
      {XSD.string("foo"), XSD.string("FOO")},
      {~L"foo",           ~L"FOO"},
      {~L"foo"en,         ~L"FOO"en},
      {XSD.integer(42),    :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {string, result} ->
         assert_builtin_result(:UCASE, [string], result)
       end)
  end

  test "LCASE function" do
    [
      {XSD.string("BAR"), XSD.string("bar")},
      {~L"BAR",           ~L"bar"},
      {~L"BAR"en,         ~L"bar"en},
      {XSD.integer(42),    :error},
      {:error,             :error},
    ]
    |> Enum.each(fn {string, result} ->
         assert_builtin_result(:LCASE, [string], result)
       end)
  end

  test "STRSTARTS function" do
    [
      {~L"foobar",           ~L"foo",           XSD.true},
      {~L"foobar"en,         ~L"foo"en,         XSD.true},
      {XSD.string("foobar"), XSD.string("foo"), XSD.true},
      {XSD.string("foobar"), ~L"foo",           XSD.true},
      {~L"foobar",           XSD.string("foo"), XSD.true},
      {~L"foobar"en,         ~L"foo",           XSD.true},
      {~L"foobar"en,         XSD.string("foo"), XSD.true},
      {~L"foo",           ~L"foobar",           XSD.false},

      {~L"foobar"en, ~L"foo"de, :error},
      {~L"foobar",   ~L"foo"de, :error},

      {XSD.string("42"),  XSD.integer("4"), :error},
      {XSD.integer("42"), XSD.string("4"),  :error},
      {:error,            XSD.integer(42),  :error},
      {XSD.integer(42),   :error,           :error},
      {:error,            :error,           :error},
    ]
    |> Enum.each(fn {arg1, arg2, result} ->
         assert_builtin_result(:STRSTARTS, [arg1, arg2], result)
       end)
  end

  test "STRENDS function" do
    [
      {~L"foobar",           ~L"bar",           XSD.true},
      {~L"foobar"en,         ~L"bar"en,         XSD.true},
      {XSD.string("foobar"), XSD.string("bar"), XSD.true},
      {XSD.string("foobar"), ~L"bar",           XSD.true},
      {~L"foobar",           XSD.string("bar"), XSD.true},
      {~L"foobar"en,         ~L"bar",           XSD.true},
      {~L"foobar"en,         XSD.string("bar"), XSD.true},
      {~L"foo",           ~L"foobar",           XSD.false},

      {~L"foobar"en, ~L"bar"de, :error},
      {~L"foobar",   ~L"bar"de, :error},

      {XSD.string("42"),  XSD.integer("2"), :error},
      {XSD.integer("42"), XSD.string("2"),  :error},
      {:error,            XSD.integer(42),  :error},
      {XSD.integer(42),   :error,           :error},
      {:error,            :error,           :error},
    ]
    |> Enum.each(fn {arg1, arg2, result} ->
         assert_builtin_result(:STRENDS, [arg1, arg2], result)
       end)
  end

  test "CONTAINS function" do
    [
      {~L"foobar",           ~L"bar",           XSD.true},
      {~L"foobar"en,         ~L"foo"en,         XSD.true},
      {XSD.string("foobar"), XSD.string("bar"), XSD.true},
      {XSD.string("foobar"), ~L"foo",           XSD.true},
      {~L"foobar",           XSD.string("bar"), XSD.true},
      {~L"foobar"en,         ~L"foo",           XSD.true},
      {~L"foobar"en,         XSD.string("bar"), XSD.true},
      {~L"foo",           ~L"foobar",           XSD.false},

      {~L"foobar"en, ~L"bar"de, :error},
      {~L"foobar",   ~L"bar"de, :error},

      {XSD.string("42"),  XSD.integer("2"), :error},
      {XSD.integer("42"), XSD.string("2"),  :error},
      {:error,            XSD.integer(42),  :error},
      {XSD.integer(42),   :error,           :error},
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
      {XSD.string("abc"), ~L"",            XSD.string("")},
      {~L"abc",           ~L"xyz",         ~L""},
      {~L"abc"en,         ~L"z"en,         ~L""},
      {~L"abc"en,         ~L"z",           ~L""},
      {~L"abc"en,         ~L""en,          ~L""en},
      {~L"abc"en,         ~L"",            ~L""en},

      {XSD.string("42"),  XSD.integer("2"), :error},
      {XSD.integer("42"), XSD.string("2"),  :error},
      {:error,            XSD.integer(42),  :error},
      {XSD.integer(42),   :error,           :error},
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
      {XSD.string("abc"), ~L"",            XSD.string("abc")},
      {~L"abc",           ~L"xyz",         ~L""},
      {~L"abc"en,         ~L"z"en,         ~L""},
      {~L"abc"en,         ~L"z",           ~L""},
      {~L"abc"en,         ~L""en,          ~L"abc"en},
      {~L"abc"en,         ~L"",            ~L"abc"en},

      {XSD.string("42"),  XSD.integer("2"), :error},
      {XSD.integer("42"), XSD.string("2"),  :error},
      {:error,            XSD.integer(42),  :error},
      {XSD.integer(42),   :error,           :error},
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
      {XSD.string("Los Angeles"), ~L"Los%20Angeles"},

      {~L"http://www.example.com/00/Weather/CA/Los%20Angeles#ocean",
       ~L"http%3A%2F%2Fwww.example.com%2F00%2FWeather%2FCA%2FLos%2520Angeles%23ocean"},
      {~L"~bébé",        ~L"~b%C3%A9b%C3%A9"},
      {~L"100% organic", ~L"100%25%20organic"},

      {XSD.integer("42"), :error},
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
      {[XSD.string("foo"), XSD.string("bar")], XSD.string("foobar")},
      {[~L"foo",           XSD.string("bar")], ~L"foobar"},
      {[~L"foo"en,         ~L"bar"          ], ~L"foobar"},
      {[~L"foo"en,         XSD.string("bar")], ~L"foobar"},


      {[~L"foo"en, XSD.string("bar"), ~L"baz"],  ~L"foobarbaz"},

      {[~L"foo"],   ~L"foo"},
      {[~L"foo"en], ~L"foo"en},
      {[], ~L""},

      {[XSD.string("4"),   XSD.integer("2")], :error},
      {[XSD.integer("4"),  XSD.string("2")],  :error},
      {[:error,            XSD.integer(42)],  :error},
      {[XSD.integer(42),   :error         ],  :error},
      {[:error,            :error         ],  :error},
    ]
    |> Enum.each(fn {args, result} ->
      assert_builtin_result(:CONCAT, args, result)
    end)
  end

  test "langMatches function" do
    [
      {~L"de",         ~L"de",    XSD.true},
      {~L"de",         ~L"DE",    XSD.true},
      {~L"de-DE",      ~L"de",    XSD.true},
      {~L"de-CH",      ~L"de",    XSD.true},
      {~L"de-CH",      ~L"de-ch", XSD.true},
      {~L"de-DE-1996", ~L"de-de", XSD.true},

      {~L"en",         ~L"de",    XSD.false},
      {~L"de",         ~L"de-CH", XSD.false},
      {~L"de-Deva",    ~L"de-de", XSD.false},
      {~L"de-Latn-DE", ~L"de-de", XSD.false},

      {~L"en",            ~L"en"en,          :error},
      {~L"en"en,          ~L"en",            :error},
      {~L"en",            XSD.integer("42"), :error},
      {XSD.integer("42"), ~L"en",            :error},
      {:error,            ~L"en",            :error},
      {~L"en",            :error,            :error},
      {:error,            :error,            :error},
    ]
    |> Enum.each(fn {language_tag, language_range, result} ->
         assert_builtin_result(:LANGMATCHES, [language_tag, language_range], result)
       end)
  end

  describe "REGEX function" do
    @poem XSD.string """
      <poem author="Wilhelm Busch">
      Kaum hat dies der Hahn gesehen,
      Fängt er auch schon an zu krähen:
      Kikeriki! Kikikerikih!!
      Tak, tak, tak! - da kommen sie.
      </poem>
      """

    test "without flags" do
      [
        {~L"abracadabra", ~L"bra",    XSD.true},
        {~L"abracadabra", ~L"^a.*a$", XSD.true},
        {~L"abracadabra", ~L"^bra",   XSD.false},
        {@poem, ~L"Kaum.*krähen",     XSD.false},
        {@poem, ~L"^Kaum.*gesehen,$", XSD.false},

        {~L"abracadabra"en, ~L"bra",    XSD.true},

        {~L"en",            ~L"en"en,          :error},
        {~L"en",            XSD.integer("42"), :error},
        {XSD.integer("42"), ~L"en",            :error},
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
        {@poem, ~L"Kaum.*krähen",     ~L"s", XSD.true},
        {@poem, ~L"^Kaum.*gesehen,$", ~L"m", XSD.true},
        {@poem, ~L"kiki",             ~L"i", XSD.true},

        {~L"en", ~L"en", XSD.integer("42"), :error},
        {~L"en", ~L"en", :error, :error},
        {:error, :error, :error, :error},
      ]
      |> Enum.each(fn {text, pattern, flags, result} ->
           assert_builtin_result(:REGEX, [text, pattern, flags], result)
         end)
    end

    test "with q flag" do
      [
        {~L"abcd",         ~L".*",       ~L"q",  XSD.false},
        {~L"Mr. B. Obama", ~L"B. OBAMA", ~L"iq", XSD.true},

        # If the q flag is used together with the m, s, or x flag, that flag has no effect.
        {~L"abcd",         ~L".*",       ~L"mq",   XSD.true},
        {~L"abcd",         ~L".*",       ~L"qim",  XSD.true},
        {~L"abcd",         ~L".*",       ~L"xqm",  XSD.true},
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

        {~L"abracadabra"en, ~L"bra",   ~L"*",     ~L"a*cada*"en},

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
        {~L"a\b\c", XSD.string("\\"), ~L"\\", ~L"q", ~L"a\\b\\c"},
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

    test "unicode characters" do
      [
        {~L"日本語"ja, ~L"[^a-z0-9]", ~L"-",	~L"---"ja},
      ]
      |> Enum.each(fn {text, pattern, replacement, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement], result)
         end)

      [
        {~L"日本語"ja, ~L"[^a-z0-9]", ~L"-",	~L"i", ~L"---"ja},
        {~L"日本語"ja, ~L"[^a-z0-9]", ~L"-",	~L"iu", ~L"---"ja},
      ]
      |> Enum.each(fn {text, pattern, replacement, flags, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement, flags], result)
         end)
    end

    @tag skip: "TODO"
    test "error conditions" do
      [
        {~L"abracadabra", ~L".*?", ~L"$1", :error}, # because the pattern matches the zero-length string
        {~L"abracadabra", ~L"a(.)", ~L"$foo", :error}, # because replacement contains a $ that is not immediately followed by a digit and not immediately preceded by a backslash
        {~L"abracadabra", ~L"a(.)", XSD.string("\\"), :error}, # because replacement contains a backslash character that is not part of a \\ pair, or immediately followed by a $ character
      ]
      |> Enum.each(fn {text, pattern, replacement, result} ->
           assert_builtin_result(:REPLACE, [text, pattern, replacement], result)
         end)
    end
  end

  test "abs function" do
    [
      {XSD.integer(1),    XSD.integer(1)},
      {XSD.integer(-1),   XSD.integer(1)},
      {XSD.decimal(-1.5), XSD.decimal(1.5)},
      {XSD.double(-1.5),  XSD.double(1.5)},

      {~L"-42", :error},
      {:error,  :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:ABS, [numeric], result)
       end)
  end

  test "round function" do
    [
      {XSD.integer(1),      XSD.integer(1)},
      {XSD.decimal(2.4999), XSD.decimal("2")},
      {XSD.decimal(2.5),    XSD.decimal("3")},
      {XSD.decimal(-2.5),   XSD.decimal("-2")},
      {XSD.double(2.4999),  XSD.double(2.0)},
      {XSD.double(2.5),     XSD.double(3.0)},
      {XSD.double(-2.5),    XSD.double(-2.0)},

      {~L"42", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:ROUND, [numeric], result)
       end)
  end

  test "ceil function" do
    [
      {XSD.integer(1),      XSD.integer(1)},
      {XSD.decimal(10.5),   XSD.decimal("11")},
      {XSD.decimal(-10.5),  XSD.decimal("-10")},
      {XSD.double(10.5),    XSD.double("11")},
      {XSD.double(-10.5),   XSD.double("-10")},

      {~L"42", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:CEIL, [numeric], result)
       end)
  end

  test "floor function" do
    [
      {XSD.integer(1),      XSD.integer(1)},
      {XSD.decimal(10.5),   XSD.decimal("10")},
      {XSD.decimal(-10.5),  XSD.decimal("-11")},
      {XSD.double(10.5),    XSD.double("10")},
      {XSD.double(-10.5),   XSD.double("-11")},

      {~L"42", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {numeric, result} ->
         assert_builtin_result(:FLOOR, [numeric], result)
       end)
  end

  test "RAND function" do
    assert %Literal{literal: %XSD.Double{value: value}} = Builtins.call(:RAND, [], %{})
    assert value >= 0 and value < 1
    assert %Literal{literal: %XSD.Double{value: another_value}} = Builtins.call(:RAND, [], %{})
    assert value != another_value

    assert %Literal{literal: %XSD.Double{value: value}} =
             Expression.evaluate(%FunctionCall.Builtin{name: :RAND, arguments: []},
                                  @example_solution_data, %{})
    assert value >= 0 and value < 1
  end

  test "now function" do
    now = DateTime.utc_now()
    assert XSD.date_time(now) == Builtins.call(:NOW, [], %{time: now})
    assert XSD.date_time(now) ==
             Expression.evaluate(%FunctionCall.Builtin{name: :NOW, arguments: []},
                                  @example_solution_data, %{time: now})
  end

  test "year function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), XSD.integer(2011)},
      {XSD.date_time("1999-12-31T19:20:00"),           XSD.integer(1999)},
      {XSD.date_time("1999-12-31T24:00:00"),           XSD.integer(2000)},
      {XSD.date_time("1999-05-31T13:20:00Z"),          XSD.integer(1999)},
      {XSD.date_time("1999-05-31T13:20:00-05:00"),     XSD.integer(1999)},
      {XSD.date_time("1999-05-31T13:20:00-05:00"),     XSD.integer(1999)},
      {XSD.date_time("1999-05-31T21:30:00-05:00"),     XSD.integer(1999)},
      {XSD.date_time("1999-12-31T21:30:00-05:00"),     XSD.integer(1999)},

      unless Version.compare(System.version(), "1.7.2") == :lt do
        {XSD.date_time("-0002-06-06T00:00:00"), XSD.integer(-2)}
      end,

      {XSD.integer(1999), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn
          nil -> :ignored
          {datetime, result} ->
            assert_builtin_result(:YEAR, [datetime], result)
       end)
  end

  test "month function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), XSD.integer(1)},
      {XSD.date_time("1999-12-31T19:20:00"),           XSD.integer(12)},
      {XSD.date_time("1999-12-31T24:00:00"),           XSD.integer(1)},
      {XSD.date_time("1999-12-31T19:20:00Z"),          XSD.integer(12)},
      {XSD.date_time("1999-05-31T13:20:00-05:00"),     XSD.integer(5)},
      {XSD.date_time("1999-12-31T19:20:00-05:00"),     XSD.integer(12)},

      {XSD.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:MONTH, [datetime], result)
       end)
  end

  test "day function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), XSD.integer(10)},
      {XSD.date_time("1999-12-31T19:20:00"),           XSD.integer(31)},
      {XSD.date_time("1999-12-31T24:00:00"),           XSD.integer(1)},
      {XSD.date_time("1999-12-31T19:20:00Z"),          XSD.integer(31)},
      {XSD.date_time("1999-05-31T13:20:00-05:00"),     XSD.integer(31)},
      {XSD.date_time("1999-12-31T20:00:00-05:00"),     XSD.integer(31)},

      {XSD.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:DAY, [datetime], result)
       end)
  end

  test "hours function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), XSD.integer(14)},
      {XSD.date_time("1999-12-31T12:00:00"),          XSD.integer(12)},
      {XSD.date_time("1999-12-31T24:00:00"),          XSD.integer(0)},
      {XSD.date_time("1999-12-31T19:20:00Z"),         XSD.integer(19)},
      {XSD.date_time("1999-05-31T08:20:00-05:00"),    XSD.integer(8)},
      {XSD.date_time("1999-12-31T21:20:00-05:00"),    XSD.integer(21)},

      {XSD.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:HOURS, [datetime], result)
       end)
  end

  test "minutes function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), XSD.integer(45)},
      {XSD.date_time("1999-05-31T13:30:00"),           XSD.integer(30)},
      {XSD.date_time("1999-05-31T13:30:00Z"),          XSD.integer(30)},
      {XSD.date_time("1999-05-31T13:20:00-05:00"),     XSD.integer(20)},
      {XSD.date_time("1999-05-31T13:30:00+05:30"),     XSD.integer(30)},

      {XSD.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:MINUTES, [datetime], result)
       end)
  end

  test "seconds function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), XSD.decimal(13.815)},
      {XSD.date_time("1999-05-31T13:20:00"),           XSD.decimal("0")},
      {XSD.date_time("1999-05-31T13:20:42Z"),          XSD.decimal("42")},
      {XSD.date_time("1999-05-31T13:20:12.340-05:00"), XSD.decimal(12.34)},
      {XSD.date_time("1999-05-31T13:20:12.034-05:00"), XSD.decimal(12.034)},

      {XSD.integer(1), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:SECONDS, [datetime], result)
       end)
  end

  # TODO: Use a to be written XSD.day_time_duration datatype
  test "timezone function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), Literal.new("-PT5H", datatype: NS.XSD.dayTimeDuration)},
      {XSD.date_time("2011-01-10T14:45:13.815Z"),      Literal.new("PT0S", datatype: NS.XSD.dayTimeDuration)},
      {XSD.date_time("2011-01-10T14:45:13.815-05:30"), Literal.new("-PT5H30M", datatype: NS.XSD.dayTimeDuration)},

      {XSD.date_time("2011-01-10T14:45:13.815"), :error},
      {~L"1999-05-31T13:20:00-05:00", :error},
      {XSD.integer(1), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:TIMEZONE, [datetime], result)
       end)
  end

  test "tz function" do
    [
      {XSD.date_time("2011-01-10T14:45:13.815-05:00"), ~L"-05:00"},
      {XSD.date_time("2011-01-10T14:45:13.815Z"),      ~L"Z"},
      {XSD.date_time("2011-01-10T14:45:13.815"),       ~L""},

      {~L"1999-05-31T13:20:00-05:00", :error},
      {XSD.integer(1), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {datetime, result} ->
         assert_builtin_result(:TZ, [datetime], result)
       end)
  end

  test "MD5 function" do
    [
      {~L"abc",           ~L"900150983cd24fb0d6963f7d28e17f72"},
      {XSD.string("abc"), ~L"900150983cd24fb0d6963f7d28e17f72"},

      {XSD.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:MD5, [value], result)
       end)
  end

  test "SHA1 function" do
    [
      {~L"abc",           ~L"a9993e364706816aba3e25717850c26c9cd0d89d"},
      {XSD.string("abc"), ~L"a9993e364706816aba3e25717850c26c9cd0d89d"},

      {XSD.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA1, [value], result)
       end)
  end

  test "SHA256 function" do
    [
      {~L"abc",           ~L"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"},
      {XSD.string("abc"), ~L"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"},

      {XSD.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA256, [value], result)
       end)
  end

  test "SHA384 function" do
    [
      {~L"abc",           ~L"cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7"},
      {XSD.string("abc"), ~L"cb00753f45a35e8bb5a03d699ac65007272c32ab0eded1631a8b605a43ff5bed8086072ba1e7cc2358baeca134c825a7"},

      {XSD.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA384, [value], result)
       end)
  end

  test "SHA512 function" do
    [
      {~L"abc",           ~L"ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f"},
      {XSD.string("abc"), ~L"ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f"},

      {XSD.integer(42), :error},
      {:error, :error},
    ]
    |> Enum.each(fn {value, result} ->
         assert_builtin_result(:SHA512, [value], result)
       end)
  end


  test "compatible_arguments?/2" do
    [
      {RDF.literal("abc"),	               RDF.literal("b"),                 true},
      {RDF.literal("abc"),	               XSD.string("b"),                  true},
      {XSD.string("abc"),                  RDF.literal("b"),                 true},
      {XSD.string("abc"),                  XSD.string("b"),                  true},
      {RDF.literal("abc", language: "en"), RDF.literal("b"),                 true},
      {RDF.literal("abc", language: "en"), XSD.string("b"),                  true},
      {RDF.literal("abc", language: "en"), RDF.literal("b", language: "en"), true},
      {RDF.literal("abc", language: "fr"), RDF.literal("b", language: "ja"), false},
      {RDF.literal("abc"),	               RDF.literal("b", language: "ja"), false},
      {RDF.literal("abc"),	               RDF.literal("b", language: "en"), false},
      {XSD.string("abc"),                  RDF.literal("b", language: "en"), false},
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
    result = Builtins.call(builtin, args, %{})
    assert result == expected, """
      expected SPARQL builtin call #{builtin}(\n\t#{args |> Stream.map(&inspect/1) |> Enum.join(",\n\t")})
      to be:   #{inspect expected}
      but got: #{inspect result}
      """
  end

  defp assert_builtin_expression_evaluation_result(builtin, args, expected) do
    result = Expression.evaluate(%FunctionCall.Builtin{name: builtin, arguments: args},
                                  @example_solution_data, %{})
    assert result == expected, """
      expected SPARQL builtin expression evaluation #{builtin}(\n\t#{args |> Stream.map(&inspect/1) |> Enum.join(",\n\t")})
      to be:   #{inspect expected}
      but got: #{inspect result}
      """
  end

end
