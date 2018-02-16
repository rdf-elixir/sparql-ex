defmodule SPARQL.Query.Result.CSV.DecoderTest do
  use ExUnit.Case
  doctest SPARQL.Query.Result.CSV.Decoder

  import RDF.Sigils

  alias SPARQL.Query


  describe "W3C tests" do
    setup context do
      {:ok,
        result_string:
          (context.test_case <> ".csv")
          |> SPARQL.W3C.TestSuite.file({"1.1", "csv-tsv-res"})
          |> File.read!()
      }
    end

    @tag test_case: "csvtsv01"
    test "csvtsv01: SELECT * WHERE { ?S ?P ?O }", %{result_string: result_string} do
      assert Query.Result.CSV.decode(result_string) == {:ok,
        %Query.ResultSet{
          variables: ~w[s p o],
          results: [
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s1>,
              "p" => ~I<http://example.org/p1>,
              "o" => ~I<http://example.org/s2>,
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s2>,
              "p" => ~I<http://example.org/p2>,
              "o" => ~L"foo"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
              "o" => ~L"bar"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => ~L"4"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => ~L"5.5"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<a>
            }}
          ]
        }
      }
    end

    @tag test_case: "csvtsv02"
    test "csvtsv02: SELECT with OPTIONAL (i.e. not all vars bound in all results)",
          %{result_string: result_string} do
      assert Query.Result.CSV.decode(result_string) == {:ok,
        %Query.ResultSet{
          variables: ~w[s p o p2 o2],
          results: [
            %Query.Result{bindings: %{
              "s"  => ~I<http://example.org/s1>,
              "p"  => ~I<http://example.org/p1>,
              "o"  => ~I<http://example.org/s2>,
              "p2" => ~I<http://example.org/p2>,
              "o2" => ~L"foo"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s2>,
              "p" => ~I<http://example.org/p2>,
              "o" => ~L"foo",
              "p2" => nil,
              "o2" => nil
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
              "o" => ~L"bar",
              "p2" => nil,
              "o2" => nil
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => ~L"4",
              "p2" => nil,
              "o2" => nil
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => ~L"5.5",
              "p2" => nil,
              "o2" => nil
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<a>,
              "p2" => nil,
              "o2" => nil
            }},
          ]
        }
      }
    end

    @tag test_case: "csvtsv03"
    test "csvtsv03: SELECT * WHERE { ?S ?P ?O } with some corner cases of typed literals",
          %{result_string: result_string} do
      assert Query.Result.CSV.decode(result_string) == {:ok,
        %Query.ResultSet{
          variables: ~w[s p o],
          results: [
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s1>,
              "p" => ~I<http://example.org/p1>,
              "o" => ~L"1"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s2>,
              "p" => ~I<http://example.org/p2>,
              "o" => ~L"2.2"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
              "o" => ~L"-3"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => ~L"4,4"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => ~L"5,5"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~L"1.0E6"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s7>,
              "p" => ~I<http://example.org/p7>,
              "o" => ~L"a7"
            }},
          ]
        }
      }
    end

  end

  test "with no header and no results" do
    assert Query.Result.CSV.decode("") ==
            {:ok, %Query.ResultSet{variables: nil, results: []}}
  end

  test "with empty header values" do
    assert Query.Result.CSV.decode("a,,b") == {:error, :blank_variable}
    assert Query.Result.CSV.decode("a, ,b") == {:error, :blank_variable}
    assert Query.Result.CSV.decode("a,") == {:error, :blank_variable}
    assert Query.Result.CSV.decode(",a") == {:error, :blank_variable}
    assert Query.Result.CSV.decode(" ") == {:error, :blank_variable}
  end

  test "with syntax errors" do
    assert {:error, %NimbleCSV.ParseError{}} = Query.Result.CSV.decode("a\"")

  end

end
