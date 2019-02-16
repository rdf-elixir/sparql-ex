defmodule SPARQL.Processor.MinusTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2]

  @w3c_example_graph RDF.Turtle.read_string! """
    @prefix :       <http://example/> .
    @prefix foaf:   <http://xmlns.com/foaf/0.1/> .

    :alice  foaf:givenName "Alice" ;
            foaf:familyName "Smith" .

    :bob    foaf:givenName "Bob" ;
            foaf:familyName "Jones" .

    :carol  foaf:givenName "Carol" ;
            foaf:familyName "Smith" .
    """

  test "basic example" do
    assert query(@w3c_example_graph, """
           PREFIX :       <http://example/>
           PREFIX foaf:   <http://xmlns.com/foaf/0.1/>

           SELECT DISTINCT ?s
           WHERE {
             ?s ?p ?o .
             MINUS {
               ?s foaf:givenName "Bob" .
             }
           }
           """) ==
             %Query.Result{
               variables: ~w[s],
               results: [
                 %{
                   "s" => ~I<http://example/carol>,
                 },
                 %{
                   "s" => ~I<http://example/alice>,
                 },
               ]}
  end

  test "with disjoint variables" do
    assert query(RDF.Graph.new({EX.a, EX.b, EX.c}), """
           SELECT *
           {
             ?s ?p ?o
             MINUS
               { ?x ?y ?z }
           }
           """) ==
             %Query.Result{
               variables: ~w[s p o],
               results: [
                 %{
                   "s" => EX.a,
                   "p" => EX.b,
                   "o" => EX.c,
                 }
               ]}
  end

  test "with fixed pattern" do
    assert query(RDF.Graph.new({EX.a, EX.b, EX.c}), """
           PREFIX : <http://example/>
           SELECT *
           {
             ?s ?p ?o
             MINUS { :a :b :c }
           }
           """) ==
             %Query.Result{
               variables: ~w[s p o],
               results: [
                 %{
                   "s" => EX.a,
                   "p" => EX.b,
                   "o" => EX.c,
                 }
               ]}
  end
end
