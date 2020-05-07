defmodule SPARQL.Query.Result.XML.DecoderTest do
  use ExUnit.Case
  doctest SPARQL.Query.Result.XML.Decoder

  import RDF.Sigils

  alias SPARQL.Query
  alias RDF.XSD


  test "with no head and no results" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
          <head></head>
        </sparql>
        """) == {:ok, %Query.Result{variables: nil, results: []}}
  end

  test "with no variables and no results" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
        </sparql>
        """) == {:ok, %Query.Result{variables: nil, results: []}}
  end

  test "with head and variables, but no results" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
          <head>
            <variable name="s"/>
            <variable name="p"/>
            <variable name="o"/>
          </head>
        </sparql>
        """) == {:ok, %Query.Result{variables: ~w[s p o], results: []}}
  end

  test "with head and variables, but no results.bindings" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
          <head>
            <variable name="s"/>
            <variable name="p"/>
            <variable name="o"/>
          </head>
          <results>
          </results>
        </sparql>
        """) == {:ok, %Query.Result{variables: ~w[s p o], results: []}}
  end

  test "with no head, but results" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
          <results>
            <result>
              <binding name="s">
                <uri>http://example.org/s1</uri>
              </binding>
              <binding name="p">
                <uri>http://example.org/p1</uri>
              </binding>
              <binding name="o">
                <uri>http://example.org/o1</uri>
              </binding>
            </result>
          </results>
        </sparql>
        """) == {:ok, %Query.Result{variables: nil, results: [
                        %{
                          "s" => ~I<http://example.org/s1>,
                          "p" => ~I<http://example.org/p1>,
                          "o" => ~I<http://example.org/o1>,
                        }
                      ]}}
  end

  test "with no variables, but results" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
          <head></head>
          <results>
            <result>
              <binding name="s">
                <uri>http://example.org/s1</uri>
              </binding>
              <binding name="p">
                <uri>http://example.org/p1</uri>
              </binding>
              <binding name="o">
                <uri>http://example.org/o1</uri>
              </binding>
            </result>
          </results>
        </sparql>
        """) == {:ok, %Query.Result{variables: nil, results: [
                        %{
                          "s" => ~I<http://example.org/s1>,
                          "p" => ~I<http://example.org/p1>,
                          "o" => ~I<http://example.org/o1>,
                        }
                      ]}}
  end

  test "SELECT result" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
          <head>
            <variable name="x"/>
            <variable name="hpage"/>
            <variable name="name"/>
            <variable name="mbox"/>
            <variable name="age"/>
            <variable name="blurb"/>
            <variable name="friend"/>
            <link href="example.rq"/>
          </head>
          <results>
            <result>
              <binding name="x">
                <bnode>r1</bnode>
              </binding>
              <binding name="hpage">
                <uri>http://work.example.org/alice/</uri>
              </binding>
              <binding name="name">
                <literal>Alice</literal>
              </binding>
              <binding name="mbox">
                <literal/>
              </binding>
              <binding name="friend">
                <bnode>r2</bnode>
              </binding>
            </result>
            <result>
              <binding name="x">
                <bnode>r2</bnode>
              </binding>
              <binding name="hpage">
                <uri>http://work.example.org/bob/</uri>
              </binding>
              <binding name="name">
                <literal xml:lang="en">Bob</literal>
              </binding>
              <binding name="mbox">
                <uri>mailto:bob@work.example.org</uri>
              </binding>
              <binding name="age">
                <literal datatype="http://www.w3.org/2001/XMLSchema#integer">30</literal>
              </binding>
              <binding name="friend">
                <bnode>r1</bnode>
              </binding>
            </result>
          </results>
        </sparql>
        """) == {:ok, %Query.Result{
                  variables: ~w[x hpage name mbox age blurb friend],
                  results: [
                    %{
                      "x"      => ~B<r1>,
                      "hpage"  => ~I<http://work.example.org/alice/>,
                      "name"   => ~L"Alice",
                      "mbox"   => ~L"",
                      "friend" => ~B<r2>,
                    },
                    %{
                      "x"      => ~B<r2>,
                      "hpage"  => ~I<http://work.example.org/bob/>,
                      "name"   => ~L"Bob"en,
                      "mbox"   => ~I<mailto:bob@work.example.org>,
                      "age"    => XSD.integer(30),
                      "friend" => ~B<r1>,
                    }
                  ]}}
  end

  test "SELECT result with rdf:XMLLiteral" do
    assert Query.Result.XML.decode("""
        <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
          <head>
            <variable name="blurb"/>
          </head>
          <results>
            <result>
              <binding name="blurb">
                <literal datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral">
                  <p xmlns="http://www.w3.org/1999/xhtml">My name is <b>alice</b></p>
                </literal>
              </binding>
            </result>
          </results>
        </sparql>
        """) == {:ok, %Query.Result{
                  variables: ~w[blurb],
                  results: [
                    %{
                      "blurb"  => RDF.literal(
                        ~S'<p xmlns="http://www.w3.org/1999/xhtml">My name is <b>alice</b></p>',
                        datatype: RDF.XMLLiteral),
                    },
                  ]}}
  end

  test "ASK result" do
    assert Query.Result.XML.decode("""
      <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
        <head>
          <link href="example2.rq"/>
        </head>
        <boolean>true</boolean>
      </sparql>
      """) == {:ok, %Query.Result{variables: nil, results: true}}
  end

  test "ASK result with non-boolean value" do
    assert Query.Result.XML.decode("""
      <sparql xmlns="http://www.w3.org/2005/sparql-results#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2001/sw/DataAccess/rf1/result2.xsd">
        <head>
          <link href="example2.rq"/>
        </head>
        <boolean>foo</boolean>
      </sparql>
      """) == {:error, ~S[invalid boolean: "foo"]}
  end

  test "malformed XML" do
    assert {:error, "XML parser error: " <> _} = Query.Result.XML.decode("<sparql>")
  end

end
