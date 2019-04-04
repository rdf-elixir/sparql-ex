defmodule SPARQL.Processor.ConstructTest do
  use SPARQL.Test.Case

  import SPARQL.Processor, only: [query: 2, query: 3]

  @example_graph RDF.Turtle.read_string!("""
    @prefix  foaf:  <http://xmlns.com/foaf/0.1/> .

    _:a    foaf:name   "Alice" .
    _:a    foaf:mbox   <mailto:alice@example.org> .
    """)

  test "template with single triple pattern" do
    assert RDF.Graph.equal?(
             query(@example_graph, """
               PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
               PREFIX vcard: <http://www.w3.org/2001/vcard-rdf/3.0#>
               CONSTRUCT   { <http://example.org/person#Alice> vcard:FN ?name }
               WHERE       { ?x foaf:name ?name }
               """),
             RDF.Turtle.read_string!("""
               @prefix vcard: <http://www.w3.org/2001/vcard-rdf/3.0#> .
               <http://example.org/person#Alice> vcard:FN "Alice" .
               """)
           )
  end

  test "template with multiple triple patterns" do
    assert RDF.Graph.equal?(
             query(
               RDF.Turtle.read_string!("""
                 @prefix  foaf:  <http://xmlns.com/foaf/0.1/> .

                 <http://alice.name/#me>    foaf:name   "Alice" .
                 <http://alice.name/#me>    foaf:mbox   <mailto:alice@example.org> .
                 """),
               """
               PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
               PREFIX vcard: <http://www.w3.org/2001/vcard-rdf/3.0#>
               PREFIX owl:   <http://www.w3.org/2002/07/owl#>
               CONSTRUCT
               {
                 <http://example.org/person#Alice> vcard:FN ?name .
                 <http://example.org/person#Alice> owl:sameAs ?x .
               }
               WHERE
               { ?x foaf:name ?name }
               """),
             RDF.Turtle.read_string!("""
               @prefix vcard: <http://www.w3.org/2001/vcard-rdf/3.0#> .
               @prefix owl:   <http://www.w3.org/2002/07/owl#> .
               <http://example.org/person#Alice> vcard:FN "Alice" .
               <http://example.org/person#Alice> owl:sameAs <http://alice.name/#me>.
               """)
           )
  end

  test "short form" do
    assert_query_equivalence(@example_graph,
      """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      CONSTRUCT WHERE { ?x foaf:name ?name }
      """,
      """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      CONSTRUCT { ?x foaf:name ?name }
      WHERE
      { ?x foaf:name ?name }
      """)
  end

  test "empty WHERE clause" do
    assert RDF.Graph.equal?(
             query(@example_graph, """
               PREFIX vcard: <http://www.w3.org/2001/vcard-rdf/3.0#>
               CONSTRUCT   { <http://example.org/person#Alice> vcard:FN ?name }
               WHERE       { }
               """),
             RDF.Graph.new()
           )

    assert RDF.Graph.equal?(
             query(@example_graph, "CONSTRUCT WHERE { }"),
             RDF.graph()
           )
  end

  test "template with ground triples" do
    assert RDF.Graph.equal?(
             query(@example_graph, """
               PREFIX foaf:  <http://xmlns.com/foaf/0.1/>
               PREFIX vcard: <http://www.w3.org/2001/vcard-rdf/3.0#>
               PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
               CONSTRUCT
               {
                 <http://example.org/person#Alice> vcard:FN ?name .
                 <http://example.org/person#Alice> rdfs:comment "Example" .
               }
               WHERE
               { ?x foaf:name ?name }
               """),
             RDF.Turtle.read_string!("""
               @prefix vcard: <http://www.w3.org/2001/vcard-rdf/3.0#> .
               @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
               <http://example.org/person#Alice> vcard:FN "Alice" .
               <http://example.org/person#Alice> rdfs:comment "Example" .
               """)
           )
  end

  test "templates with blank nodes" do
    assert RDF.Graph.equal?(
             query(
               RDF.Turtle.read_string!("""
                 @prefix  foaf:  <http://xmlns.com/foaf/0.1/> .

                 _:a    foaf:givenname   "Alice" .
                 _:a    foaf:family_name "Hacker" .

                 _:b    foaf:firstname   "Bob" .
                 _:b    foaf:surname     "Hacker" .
                 """),
               """
               PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
               PREFIX vcard:   <http://www.w3.org/2001/vcard-rdf/3.0#>

               CONSTRUCT { ?x  vcard:N _:v .
                           _:v vcard:givenName ?gname .
                           _:v vcard:familyName ?fname }
               WHERE
                 {
                   { ?x foaf:firstname ?gname } UNION  { ?x foaf:givenname   ?gname } .
                   { ?x foaf:surname   ?fname } UNION  { ?x foaf:family_name ?fname } .
                 }
               """),
             RDF.Turtle.read_string!("""
               @prefix vcard: <http://www.w3.org/2001/vcard-rdf/3.0#> .

               _:b1 vcard:N         _:b0 .
               _:b0 vcard:givenName  "Alice" .
               _:b0 vcard:familyName "Hacker" .

               _:b3 vcard:N         _:b2 .
               _:b2 vcard:givenName  "Bob" .
               _:b2 vcard:familyName "Hacker" .
               """)
           )
  end

  test "solution modifiers that have no effect on the resulting graph" do
    assert_query_equivalence(@example_graph,
      """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      CONSTRUCT WHERE { ?x foaf:name ?name }
      """,
      """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      CONSTRUCT { ?x foaf:name ?name }
      WHERE
      { ?x foaf:name ?name }
      """)

    assert_query_equivalence(@example_graph,
      """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      CONSTRUCT WHERE { ?x foaf:name ?name }
      ORDER BY ?name
      """,
      """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      CONSTRUCT { ?x foaf:name ?name }
      WHERE
      { ?x foaf:name ?name }
      """)
  end

  test "when variable substitution produces invalid triples" do
    assert RDF.Graph.equal?(
             query(@example_graph, """
               PREFIX foaf: <http://xmlns.com/foaf/0.1/>
               CONSTRUCT   { <http://example.org/person#Alice> ?name "literal on predicate position" }
               WHERE       { ?x foaf:name ?name }
               """),
             RDF.Graph.new()
           )
  end

  describe "prefix handling" do
    test "when no prefixes defined and standard default_prefixes used" do
      assert_result_prefixes(
        query_prefixes: %{},
        default_prefixes: :standard,
        result: RDF.graph(prefixes: RDF.default_prefixes()))
    end

    test "when prefixes defined and standard default_prefixes used" do
      assert_result_prefixes(
        query_prefixes: %{ex: EX.__base_iri__},
        default_prefixes: :standard,
        result: RDF.graph(prefixes: RDF.default_prefixes(ex: EX)))
    end

    test "when prefixes defined and special default_prefixes provided" do
      assert_result_prefixes(
        query_prefixes: %{ex: EX.__base_iri__},
        default_prefixes: %{rdf: RDF},
        result: RDF.graph(prefixes: %{ex: EX, rdf: RDF}))
    end

    test "when prefixes defined and standard default_prefixes disabled" do
      assert_result_prefixes(
        query_prefixes: %{ex: EX.__base_iri__},
        default_prefixes: nil,
        result: RDF.graph(prefixes: %{ex: EX}))
    end

    test "when no prefixes defined and standard default_prefixes disabled" do
      assert_result_prefixes(
        query_prefixes: %{},
        default_prefixes: nil,
        result: RDF.graph())
    end
  end

  defp assert_query_equivalence(graph, short_query, full_query) do
    assert query(graph, short_query) == query(graph, full_query)
  end

  defp assert_result_prefixes(query_prefixes: prefixes, default_prefixes: :standard, result: graph) do
    assert query(RDF.graph(), empty_query_with_prefixes(prefixes)) == graph
  end

  defp assert_result_prefixes(query_prefixes: prefixes, default_prefixes: default_prefixes, result: graph) do
    assert query(RDF.graph(), empty_query_with_prefixes(prefixes), default_prefixes: default_prefixes) == graph
  end

  defp empty_query_with_prefixes(prefixes) do
    (
      prefixes
      |> Stream.map(fn {prefix, ns} -> "PREFIX #{to_string(prefix)}: <#{to_string(ns)}>" end)
      |> Enum.join("\n")
      ) <>
    "\n\nCONSTRUCT WHERE { }"
  end
end
