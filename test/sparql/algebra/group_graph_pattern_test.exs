defmodule SPARQL.Algebra.GroupGraphPatternTest do
  use SPARQL.Test.Case

  import SPARQL.Language.Decoder, only: [decode: 1]

  test "a filter splitting a bgp into a group" do
    query = """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        FILTER(?o = 1)
        ?s2 ?p2 ?o2
      }
      """
    n1 = RDF.integer(1)
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Project{
               vars: ~w[s],
               expr: %SPARQL.Algebra.Filter{
                 filters: [
                   %SPARQL.Algebra.FunctionCall.Builtin{
                     name: :=,
                     arguments: ["o", ^n1]
                   }
                 ],
                 expr: %SPARQL.Algebra.Join{
                   expr1: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
                   expr2: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
                 }
               }
             }
           }} = decode(query)
  end

  test "nested graph pattern without filter" do
    [
      """
      SELECT ?s
      WHERE {
        {?s ?p ?o}
        ?s2 ?p2 ?o2 .
      }
      """,
      """
      SELECT ?s
            WHERE {
              ?s ?p ?o .
              {?s2 ?p2 ?o2}
            }
      """,
      """
      SELECT ?s
      WHERE {
        {?s ?p ?o}
        {?s2 ?p2 ?o2}
      }
      """
    ]
    |> Enum.each(fn query ->
         assert {:ok, %SPARQL.Query{
                  expr: %SPARQL.Algebra.Project{
                    vars: ~w[s],
                    expr: %SPARQL.Algebra.Join{
                      expr1: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
                      expr2: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
                    }
                  }
                }} = decode(query)
       end)
  end


  test "nested graph pattern with filter" do
    n1 = RDF.integer(1)
    [
      """
      SELECT ?s
      WHERE {
        {
          ?s ?p ?o
          FILTER(?o = 1)
        }
        ?s2 ?p2 ?o2
      }
      """,
      """
      SELECT ?s
      WHERE {
        {
          FILTER(?o = 1)
          ?s ?p ?o
        }
        ?s2 ?p2 ?o2
      }
      """,
    ]
    |> Enum.each(fn query ->
         assert {:ok, %SPARQL.Query{
                  expr: %SPARQL.Algebra.Project{
                    vars: ~w[s],
                    expr: %SPARQL.Algebra.Join{
                      expr1: %SPARQL.Algebra.Filter{
                        filters: [
                          %SPARQL.Algebra.FunctionCall.Builtin{
                            name: :=,
                            arguments: ["o", ^n1]
                          }
                        ],
                        expr: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]}
                      },
                      expr2: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
                    }
                  }
                }} = decode(query)
       end)

    [
      """
      SELECT ?s
      WHERE {
        ?s ?p ?o .
        {
          ?s2 ?p2 ?o2 .
          FILTER(?o2 = 1)
        }
      }
      """,
      """
      SELECT ?s
      WHERE {
        ?s ?p ?o .
        {
          FILTER(?o2 = 1)
          ?s2 ?p2 ?o2 .
        }
      }
      """
    ]
    |> Enum.each(fn query ->
         assert {:ok, %SPARQL.Query{
                  expr: %SPARQL.Algebra.Project{
                    vars: ~w[s],
                    expr: %SPARQL.Algebra.Join{
                      expr1: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
                      expr2: %SPARQL.Algebra.Filter{
                        filters: [
                          %SPARQL.Algebra.FunctionCall.Builtin{
                            name: :=,
                            arguments: ["o2", ^n1]
                          }
                        ],
                        expr: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
                      },
                    }
                  }
                }} = decode(query)
       end)
  end

  test "simplification" do
    query = """
      SELECT ?s
      WHERE {
        ?s ?p ?o .
        {}
        ?s2 ?p2 ?o2 .
      }
      """
    assert {:ok, %SPARQL.Query{
             expr: %SPARQL.Algebra.Project{
               vars: ~w[s],
               expr: %SPARQL.Algebra.Join{
                   expr1: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
                   expr2: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
               }
             }
           }} = decode(query)

    n1 = RDF.integer(1)
    [
      """
      SELECT ?s
      WHERE {
        ?s ?p ?o .
        {}
        ?s2 ?p2 ?o2 .
        FILTER(?o = 1)
      }
      """,
      """
      SELECT ?s
      WHERE {
        ?s ?p ?o .
        {}
        FILTER(?o = 1)
        ?s2 ?p2 ?o2 .
      }
      """,
      """
      SELECT ?s
      WHERE {
        ?s ?p ?o .
        FILTER(?o = 1)
        {}
        ?s2 ?p2 ?o2 .
      }
      """,
      """
      SELECT ?s
      WHERE {
        FILTER(?o = 1)
        ?s ?p ?o .
        {}
        ?s2 ?p2 ?o2 .
      }
      """
    ]
    |> Enum.each(fn query ->
         assert {:ok, %SPARQL.Query{
                  expr: %SPARQL.Algebra.Project{
                    vars: ~w[s],
                    expr: %SPARQL.Algebra.Filter{
                      filters: [
                        %SPARQL.Algebra.FunctionCall.Builtin{
                          name: :=,
                          arguments: ["o", ^n1]
                        }
                      ],
                      expr: %SPARQL.Algebra.Join{
                        expr1: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
                        expr2: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
                      }
                    }
                  }
                }} = decode(query)
       end)
  end

end

#{:ok,
#  {:query,
#    {:select, {[{"s", nil}], nil}, nil,
#      %SPARQL.Algebra.Join{
#        expr1: %SPARQL.Algebra.Filter{
#          expr: [
#            %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
#            %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
#          ],
#          filters: [
#            %SPARQL.Algebra.FunctionCall.Builtin{
#              arguments: ["o2",
#                %RDF.Literal{value: 1, datatype: ~I<http://www.w3.org/2001/XMLSchema#integer>}],
#              name: :=
#            }
#          ]
#        },
#        expr2: [%SPARQL.Algebra.BGP{triples: [{"s3", "p3", "o3"}]}]
#      }, nil}, nil}}
#
#{:ok,
#  {:query,
#    {:select, {[{"s", nil}], nil}, nil,
#      %SPARQL.Algebra.Join{
#        expr1: %SPARQL.Algebra.Translation.GroupGraphPattern{
#          expr: [
#            %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
#            %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
#          ],
#          fs: [
#            %SPARQL.Algebra.FunctionCall.Builtin{
#              arguments: ["o2",
#                %RDF.Literal{value: 1, datatype: ~I<http://www.w3.org/2001/XMLSchema#integer>}],
#              name: :=
#            }
#          ]
#        },
#        expr2: %SPARQL.Algebra.BGP{triples: [{"s3", "p3", "o3"}]}
#      }, nil}, nil}}
