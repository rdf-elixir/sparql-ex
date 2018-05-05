defmodule SPARQL.Processor.SelectQueryTest do
  use ExUnit.Case

  import SPARQL.Processor, only: [query: 2]

  import RDF.Sigils

  alias RDF.Graph
  alias SPARQL.Query

  use RDF.Vocabulary.Namespace
  defvocab EX,
    base_iri: "http://example.org/",
    terms: [], strict: false

  @example_graph Graph.new([
      {EX.s1, EX.p1, EX.o1},
      {EX.s1, EX.p2, EX.o2},
      {EX.s3, EX.p3, EX.o2}
    ])

  describe "BGPs" do

    test "single {s ?p ?o}" do
      assert query(@example_graph, "SELECT * WHERE { <#{EX.s1}> ?p ?o }") ==
        %Query.ResultSet{
         variables: ~w[p o],
          results: [
            %Query.Result{bindings: %{
              "p" => ~I<http://example.org/p1>,
              "o" => ~I<http://example.org/o1>,
            }},
            %Query.Result{bindings: %{
              "p" => ~I<http://example.org/p2>,
              "o" => ~I<http://example.org/o2>,
            }}
        ]}
    end

    test "single {?s ?p o}" do
      assert query(@example_graph, "SELECT * WHERE { ?s ?p <#{EX.o2}> }") ==
        %Query.ResultSet{
          variables: ~w[s p],
          results: [
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s3>,
              "p" => ~I<http://example.org/p3>,
            }},
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s1>,
              "p" => ~I<http://example.org/p2>,
            }}
        ]}
    end

    test "single {?s p ?o}" do
      assert query(@example_graph, "SELECT * WHERE { ?s <#{EX.p3}> ?o }") ==
        %Query.ResultSet{
          variables: ~w[s o],
          results: [
            %Query.Result{bindings: %{
              "s" => ~I<http://example.org/s3>,
              "o" => ~I<http://example.org/o2>,
            }},
        ]}
    end

    test "two connected triple patterns with a match" do
      assert query(@example_graph, """
        SELECT *
        WHERE {
          <#{EX.s1}> ?p ?o .
          <#{EX.s3}> ?p2 ?o .
        }
        """) ==
        %Query.ResultSet{
          variables: ~w[p p2 o],
          results: [
            %Query.Result{bindings: %{
              "p"  => ~I<http://example.org/p2>,
              "p2" => ~I<http://example.org/p3>,
              "o"  => ~I<http://example.org/o2>,
            }},
        ]}

      assert query(@example_graph, """
        SELECT *
        WHERE {
          <#{EX.s1}> ?p ?o1, ?o2 .
        }
        """) ==
        %Query.ResultSet{
          variables: ~w[o1 p o2],
          results: [
            %Query.Result{bindings: %{
              "p"  => ~I<http://example.org/p1>,
              "o1" => ~I<http://example.org/o1>,
              "o2" => ~I<http://example.org/o1>,
            }},
            %Query.Result{bindings: %{
              "p"  => ~I<http://example.org/p2>,
              "o1" => ~I<http://example.org/o2>,
              "o2" => ~I<http://example.org/o2>,
            }},
          ]
        }

      assert query(
        Graph.new([
          {EX.s1, EX.p1, EX.o1},
          {EX.s3, EX.p2, EX.o2},
          {EX.s3, EX.p3, EX.o1}
        ]),
        """
        SELECT *
        WHERE {
          <#{EX.s1}> <#{EX.p1}> ?o .
          <#{EX.s3}> ?p ?o .
        }
        """) ==
        %Query.ResultSet{
          variables: ~w[p o],
          results: [
            %Query.Result{bindings: %{
              "p"  => ~I<http://example.org/p3>,
              "o"  => ~I<http://example.org/o1>,
            }},
        ]}
    end

    test "a triple pattern with dependent variables from separate triple patterns" do
      assert query(
        Graph.new([
          {EX.s1, EX.p1, EX.o1},
          {EX.s2, EX.p2, EX.o2},
          {EX.s3, EX.p2, EX.o1}
        ]),
        """
        SELECT *
        WHERE {
          <#{EX.s1}> <#{EX.p1}> ?o .
          <#{EX.s2}> ?p <#{EX.o2}>  .
          ?s ?p ?o .
        }
        """) ==
        %Query.ResultSet{
          variables: ~w[s p o],
          results: [
            %Query.Result{bindings: %{
              "s"  => ~I<http://example.org/s3>,
              "p"  => ~I<http://example.org/p2>,
              "o"  => ~I<http://example.org/o1>,
            }},
        ]}
    end

    test "when no solutions" do
      assert query(@example_graph, """
          SELECT *
          WHERE {
            <#{EX.s}> <#{EX.p}> ?o .
          }
          """) ==
          %Query.ResultSet{
            variables: ~w[o],
            results: []
          }
    end

    test "multiple triple patterns with a constant unmatched triple has no solutions" do
      assert query(@example_graph, """
        SELECT *
        WHERE {
          <#{EX.s1}> ?p ?o .
          <#{EX.s}> <#{EX.p}> <#{EX.o}> .
        }
        """) ==
        %Query.ResultSet{
          variables: ~w[p o],
          results: []
        }
    end

    test "independent triple patterns lead to cross-products" do
      assert query(@example_graph, """
          SELECT *
          WHERE {
            <#{EX.s1}> ?p1 ?o .
            ?s ?p2 <#{EX.o2}>.
          }
          """) ==
          %Query.ResultSet{
            variables: ~w[p1 o s p2],
            results: [
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p1>,
                "o"  => ~I<http://example.org/o1>,
                "s"  => ~I<http://example.org/s3>,
                "p2" => ~I<http://example.org/p3>,
              }},
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p2>,
                "o"  => ~I<http://example.org/o2>,
                "s"  => ~I<http://example.org/s3>,
                "p2" => ~I<http://example.org/p3>,
              }},
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p1>,
                "o"  => ~I<http://example.org/o1>,
                "s"  => ~I<http://example.org/s1>,
                "p2" => ~I<http://example.org/p2>,
              }},
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p2>,
                "o"  => ~I<http://example.org/o2>,
                "s"  => ~I<http://example.org/s1>,
                "p2" => ~I<http://example.org/p2>,
              }},
            ]
          }
    end

    test "blank nodes behave like variables, but don't appear in the solution" do
      assert query(@example_graph, """
        SELECT *
        WHERE {
          <#{EX.s1}> ?p _:o .
          <#{EX.s3}> ?p2 _:o .
        }
        """) ==
        %Query.ResultSet{
          variables: ~w[p p2],
          results: [
            %Query.Result{bindings: %{
              "p"  => ~I<http://example.org/p2>,
              "p2" => ~I<http://example.org/p3>,
            }},
        ]}
    end

    test "cross-product with blank nodes" do
      assert query(@example_graph, """
          SELECT *
          WHERE {
            <#{EX.s1}> ?p1 ?o .
            _:s ?p2 <#{EX.o2}>.
          }
          """) ==
          %Query.ResultSet{
            variables: ~w[p1 o p2],
            results: [
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p1>,
                "o"  => ~I<http://example.org/o1>,
                "p2" => ~I<http://example.org/p3>,
              }},
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p2>,
                "o"  => ~I<http://example.org/o2>,
                "p2" => ~I<http://example.org/p3>,
              }},
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p1>,
                "o"  => ~I<http://example.org/o1>,
                "p2" => ~I<http://example.org/p2>,
              }},
              %Query.Result{bindings: %{
                "p1" => ~I<http://example.org/p2>,
                "o"  => ~I<http://example.org/o2>,
                "p2" => ~I<http://example.org/p2>,
              }},
            ]
          }
    end
  end


  describe "projection" do
    test "single variable" do
      assert query(@example_graph, "SELECT ?o WHERE { <#{EX.s1}> ?p ?o }") ==
        %Query.ResultSet{
          variables: ~w[o],
          results: [
            %Query.Result{bindings: %{"o" => ~I<http://example.org/o1>}},
            %Query.Result{bindings: %{"o" => ~I<http://example.org/o2>}}
          ]}
    end
  end

end
