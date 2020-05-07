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
    n1 = XSD.integer(1)
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
    n1 = XSD.integer(1)
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

  test "nested group graph patterns" do
    n1 = XSD.integer(1)
    [
      """
      SELECT ?s
      WHERE {
        {
          ?s ?p ?o
          FILTER(?o2 = 1)
          ?s2 ?p2 ?o2 .
        }
        {
          ?s3 ?p3 ?o3 .
        }
      }
      """,
      """
      SELECT ?s
      WHERE {
        {{
          ?s ?p ?o
          FILTER(?o2 = 1)
          ?s2 ?p2 ?o2 .
        }}
        {
          ?s3 ?p3 ?o3 .
        }
      }
      """
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
                            arguments: ["o2", ^n1]
                          }
                        ],
                        expr: %SPARQL.Algebra.Join{
                          expr1: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]},
                          expr2: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]}
                        }
                      },
                      expr2: %SPARQL.Algebra.BGP{triples: [{"s3", "p3", "o3"}]},
                    }
                  }
                }} = decode(query)
       end)

    query = """
      SELECT ?s
      WHERE {
        ?s ?p ?o
        {
          ?s2 ?p2 ?o2 .
          FILTER(?o2 = 1)
          ?s3 ?p3 ?o3 .
        }
      }
      """
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
                   expr: %SPARQL.Algebra.Join{
                     expr1: %SPARQL.Algebra.BGP{triples: [{"s2", "p2", "o2"}]},
                     expr2: %SPARQL.Algebra.BGP{triples: [{"s3", "p3", "o3"}]}
                   }
                 }
               }
             }
           }} = decode(query)
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

    n1 = XSD.integer(1)
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
