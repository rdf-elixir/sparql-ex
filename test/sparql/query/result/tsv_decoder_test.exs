defmodule SPARQL.Query.Result.TSV.DecoderTest do
  use ExUnit.Case
  doctest SPARQL.Query.Result.TSV.Decoder

  import RDF.Sigils

  alias SPARQL.Query
  alias RDF.XSD


  describe "W3C tests" do
    setup context do
      {:ok,
        result_string:
          (context.test_case <> ".tsv")
          |> SPARQL.W3C.TestSuite.file({"1.1", "csv-tsv-res"})
          |> File.read!()
      }
    end

    @tag test_case: "csvtsv01"
    test "csvtsv01: SELECT * WHERE { ?S ?P ?O }", %{result_string: result_string} do
      assert Query.Result.TSV.decode(result_string) == {:ok,
        %Query.Result{
          variables: ~w[s p o],
          results: [
            %{
              "s" => ~I<http://example.org/s1>,
              "p" => ~I<http://example.org/p1>,
              "o" => ~I<http://example.org/s2>,
            },
            %{
              "s" => ~I<http://example.org/s2>,
              "p" => ~I<http://example.org/p2>,
              "o" => ~L"foo"
            },
            %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
              "o" => ~L"bar"
            },
            %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => XSD.integer(4)
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => XSD.decimal("5.5")
            },
            %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<b0>
            }
          ]
        }
      }
    end

    @tag test_case: "csvtsv02"
    test "csvtsv02: SELECT with OPTIONAL (i.e. not all vars bound in all results)",
          %{result_string: result_string} do
      assert Query.Result.TSV.decode(result_string) == {:ok,
        %Query.Result{
          variables: ~w[s p o p2 o2],
          results: [
            %{
              "s"  => ~I<http://example.org/s1>,
              "p"  => ~I<http://example.org/p1>,
              "o"  => ~I<http://example.org/s2>,
              "p2" => ~I<http://example.org/p2>,
              "o2" => ~L"foo"
            },
            %{
              "s" => ~I<http://example.org/s2>,
              "p" => ~I<http://example.org/p2>,
              "o" => ~L"foo",
              "p2" => nil,
              "o2" => nil
            },
            %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
              "o" => ~L"bar",
              "p2" => nil,
              "o2" => nil
            },
            %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => XSD.integer(4),
              "p2" => nil,
              "o2" => nil
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => XSD.decimal("5.5"),
              "p2" => nil,
              "o2" => nil
            },
            %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<b0>,
              "p2" => nil,
              "o2" => nil
            },
          ]
        }
      }
    end

    @tag test_case: "csvtsv03"
    test "csvtsv03: SELECT * WHERE { ?S ?P ?O } with some corner cases of typed literals",
          %{result_string: result_string} do
      assert Query.Result.TSV.decode(result_string) == {:ok,
        %Query.Result{
          variables: ~w[s p o],
          results: [
            %{
              "s" => ~I<http://example.org/s1>,
              "p" => ~I<http://example.org/p1>,
              "o" => ~L"1"
            },
            %{
              "s" => ~I<http://example.org/s2>,
              "p" => ~I<http://example.org/p2>,
              "o" => XSD.decimal("2.2")
            },
            %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
              "o" => XSD.negativeInteger("-3")
            },
            %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => ~L"4,4"
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => RDF.literal("5,5", datatype: "http://example.org/myCustomDatatype")
            },
            %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => XSD.double("1.0e6")
            },
            %{
              "s" => ~I<http://example.org/s7>,
              "p" => ~I<http://example.org/p7>,
              "o" => RDF.literal("a7", datatype: "http://www.w3.org/2001/XMLSchema#hexBinary")
            },
          ]
        }
      }
    end
  end

  test "values with escaped characters" do
    assert Query.Result.TSV.decode("?a\n\"foo\\n\\tbar\"") == {:ok,
      %Query.Result{
          variables: ~w[a],
          results: [%{"a" => ~L"foo\n\tbar"}]
        }
      }
  end

  test "with no header and no results" do
    assert Query.Result.TSV.decode("") ==
            {:ok, %Query.Result{variables: nil, results: []}}
  end

  test "with empty header values" do
    error = {:error, "invalid header variable: ''"}
    assert Query.Result.TSV.decode("?a\t\t?b") == error 
    assert Query.Result.TSV.decode("?a\t \t?b") == error
    assert Query.Result.TSV.decode("?a\t") == error
    assert Query.Result.TSV.decode("\t?a") == error
    assert Query.Result.TSV.decode(" ") == error
  end

  test "with header variables without a leading question mark" do
    assert Query.Result.TSV.decode("a") == {:error, "invalid header variable: 'a'"}
  end

  test "with syntax errors in the values" do
    assert Query.Result.TSV.decode("?a\n\"foo") == {:error, "illegal \"foo"}
  end

end
