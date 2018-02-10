defmodule SPARQL.Query.Result.JSON.DecoderTest do
  use ExUnit.Case
  doctest SPARQL.Query.Result.JSON.Decoder

  import RDF.Sigils

  alias SPARQL.Query

  @tag skip: "TODO"
  test "with no head" do
  end

  test "with no results" do
    assert Query.Result.JSON.decode("""
      {
        "head": {
          "vars": [ "s" , "p" , "o" ]
        }
      }
      """) == {:ok, %Query.ResultSet{results: []}}
  end

  test "with no bindings" do
    assert Query.Result.JSON.decode("""
      {
        "head": {
          "vars": [ "s" , "p" , "o" ]
        } ,
        "results": {}
      }
      """) == {:ok, %Query.ResultSet{results: []}}
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
    test "SELECT * WHERE { ?S ?P ?O }", %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
        %Query.ResultSet{
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
              "p" => ~I<http://example.org/p2>,
              "o" => RDF.String.new("bar")
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => RDF.Integer.new(4)
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => RDF.Literal.new("5", datatype: "http://www.w3.org/2001/XMLSchema#decimal")
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<b0>
            }}
          ]
        }
      }
    end

    @tag test_case: "jsonres02"
    test "jsonres02: SELECT with OPTIONAL (i.e. not all vars bound in all results)",
          %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
        %Query.ResultSet{
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
              "o" => ~L"foo"
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p2>,
              "o" => RDF.String.new("bar")
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s4>,
              "p" => ~I<http://example.org/p4>,
              "o" => RDF.Integer.new(4)
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s5>,
              "p" => ~I<http://example.org/p5>,
              "o" => RDF.Literal.new("5", datatype: "http://www.w3.org/2001/XMLSchema#decimal")
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s6>,
              "p" => ~I<http://example.org/p6>,
              "o" => ~B<b0>
            }},
          ]
        }
      }
    end

    @tag test_case: "jsonres03"
    test "ASK - answer: true", %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
        %Query.ResultSet{results: true}
      }
    end

    @tag test_case: "jsonres04"
    test "ASK - answer: false", %{result_string: result_string} do
      assert Query.Result.JSON.decode(result_string) == {:ok,
        %Query.ResultSet{results: false}
      }
    end
  end

end
