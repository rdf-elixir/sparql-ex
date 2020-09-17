defmodule SPARQL.Query.Result.JSON.DecoderTest do
  use ExUnit.Case
  doctest SPARQL.Query.Result.JSON.Decoder

  import RDF.Sigils

  alias SPARQL.Query
  alias RDF.XSD

  test "with no head and no results" do
    assert Query.Result.JSON.decode("{}") ==
            {:ok, %Query.Result{variables: nil, results: []}}
  end

  test "with no vars and no results" do
    assert Query.Result.JSON.decode(~s[{ "head": { } }]) ==
            {:ok, %Query.Result{variables: nil, results: []}}
  end

  test "with head and vars, but no results" do
    assert Query.Result.JSON.decode("""
      {
        "head": {
          "vars": [ "s" , "p" , "o" ]
        }
      }
      """) == {:ok, %Query.Result{variables: ~w[s p o], results: []}}
  end

  test "with head and vars, but no results.bindings" do
    assert Query.Result.JSON.decode("""
      {
        "head": {
          "vars": [ "s" , "p" , "o" ]
        } ,
        "results": {}
      }
      """) == {:ok, %Query.Result{variables: ~w[s p o], results: []}}
  end

  test "with no head, but results" do
    assert Query.Result.JSON.decode("""
      {
        "results": {
          "bindings": [
            {
              "s": { "type": "uri" , "value": "http://example.org/s1" } ,
              "p": { "type": "uri" , "value": "http://example.org/p1" } ,
              "o": { "type": "uri" , "value": "http://example.org/s1" }
            }
          ]
        }
      }
      """) == {:ok, %Query.Result{variables: nil, results: [
                        %{
                          "s" => ~I<http://example.org/s1>,
                          "p" => ~I<http://example.org/p1>,
                          "o" => ~I<http://example.org/s1>,
                        }
                      ]}}
  end

  test "with no vars, but results" do
    assert Query.Result.JSON.decode("""
      {
        "head": { },
        "results": {
          "bindings": [
            {
              "s": { "type": "uri" , "value": "http://example.org/s1" } ,
              "p": { "type": "uri" , "value": "http://example.org/p1" } ,
              "o": { "type": "uri" , "value": "http://example.org/s1" }
            }
          ]
        }
      }
      """) == {:ok, %Query.Result{variables: nil, results: [
                        %{
                          "s" => ~I<http://example.org/s1>,
                          "p" => ~I<http://example.org/p1>,
                          "o" => ~I<http://example.org/s1>,
                        }
                      ]}}
  end

  test "international characters in language-tagged literal" do
    assert Query.Result.JSON.decode("""
      {
        "results": {
          "bindings": [
            {"name": { "type": "literal" , "xml:lang": "jp", "value": "東京" }}
          ]
        }
      }
      """) == {:ok, %Query.Result{results: [%{"name" => ~L"東京"jp}]}}
  end

  test "literals with datatype" do
    assert Query.Result.JSON.decode("""
            {
              "head" : {
                "vars" : [
                  "count"
                ]
              },
              "results" : {
                "bindings" : [
                  {
                    "count" : {
                      "datatype" : "http://www.w3.org/2001/XMLSchema#integer",
                      "type" : "literal",
                      "value" : "42"
                    }
                  }
                ]
              }
            }
          """) == {:ok,
             %Query.Result{
               variables: ["count"],
               results: [%{"count" => XSD.integer(42)}]}
           }
  end

  test "ASK result with non-boolean value" do
    assert Query.Result.JSON.decode(~S[{"boolean": "foo"}]) ==
      {:error, ~S[invalid boolean: "foo"]}
  end

  describe "W3C tests" do
    setup context do
      {:ok,
        result_string:
          (context.test_case <> ".srj")
          |> SPARQL.W3C.TestSuite.file({"1.1", "json-res"})
          |> File.read!()
      }
    end

    @tag test_case: "jsonres01"
    test "jsonres01: SELECT * WHERE { ?S ?P ?O }", %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
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
              "p" => ~I<http://example.org/p2>,
              "o" => XSD.string("bar")
            },
            %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => XSD.integer(4)
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => XSD.decimal("5")
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

    @tag test_case: "jsonres02"
    test "jsonres02: SELECT with OPTIONAL (i.e. not all vars bound in all solutions)",
          %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
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
              "o" => ~L"foo"
            },
            %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p2>,
              "o" => XSD.string("bar")
            },
            %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => XSD.integer(4)
            },
            %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => XSD.decimal("5")
            },
            %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<b0>
            },
          ]
        }
      }
    end

    @tag test_case: "jsonres03"
    test "jsonres03: ASK - answer: true", %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
        %Query.Result{variables: nil, results: true}
      }
    end

    @tag test_case: "jsonres04"
    test "ASK - answer: false", %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
        %Query.Result{variables: nil, results: false}
      }
    end
  end

end
