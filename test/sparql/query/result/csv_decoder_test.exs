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
              "o" => ~L"4"
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => ~L"5.5"
            },
            %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<a>
            }
          ]
        }
      }
    end

    @tag test_case: "csvtsv02"
    test "csvtsv02: SELECT with OPTIONAL (i.e. not all vars bound in all results)",
          %{result_string: result_string} do
      assert Query.Result.CSV.decode(result_string) == {:ok,
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
              "o" => ~L"4",
              "p2" => nil,
              "o2" => nil
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => ~L"5.5",
              "p2" => nil,
              "o2" => nil
            },
            %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<a>,
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
      assert Query.Result.CSV.decode(result_string) == {:ok,
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
              "o" => ~L"2.2"
            },
            %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
              "o" => ~L"-3"
            },
            %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => ~L"4,4"
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => ~L"5,5"
            },
            %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~L"1.0E6"
            },
            %{
              "s" => ~I<http://example.org/s7>,
              "p" => ~I<http://example.org/p7>,
              "o" => ~L"a7"
            },
          ]
        }
      }
    end

  end

  test "with no header and no results" do
    assert Query.Result.CSV.decode("") ==
            {:ok, %Query.Result{variables: nil, results: []}}
  end

  test "with empty header values" do
    error = {:error, "invalid header variable: ''"}
    assert Query.Result.CSV.decode("a,,b") == error
    assert Query.Result.CSV.decode("a, ,b") == error
    assert Query.Result.CSV.decode("a,") == error
    assert Query.Result.CSV.decode(",a") == error
    assert Query.Result.CSV.decode(" ") == error
  end

  test "with syntax errors" do
    assert {:error, %NimbleCSV.ParseError{}} = Query.Result.CSV.decode("a\"")
  end

  test "IRIs with non-http scheme" do
    assert Query.Result.CSV.decode("""
             o
             urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6
             file:///etc/hosts
             ftp://ftp.is.co.za/rfc/rfc1808.txt
             mailto:John.Doe@example.com
             "geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0"
             "data:;base64,SGVsbG8gV29ybGQh"
             """) == {:ok,
             %Query.Result{
               variables: ~w[o],
               results: [
                 %{"o" => ~I<urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6>},
                 %{"o" => ~I<file:///etc/hosts>},
                 %{"o" => ~I<ftp://ftp.is.co.za/rfc/rfc1808.txt>},
                 %{"o" => ~I<mailto:John.Doe@example.com>},
                 %{"o" => ~I<geo:48.198634,-16.371648,3.4;crs=wgs84;u=40.0>},
                 %{"o" => ~I<data:;base64,SGVsbG8gV29ybGQh>},
             ]}}
  end

end
