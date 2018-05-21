defmodule SPARQL.Algebra.Translation.SelectQueryTest do
  use ExUnit.Case

  import RDF.Sigils

  import SPARQL.Language.Decoder, only: [decode: 1]

  test "a single bgp with a single triple" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT * WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
        }
      }} = decode(query)
  end

  test "a single bgp with a multiple triples" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT *
      WHERE {
        ?person foaf:name ?name ;
                foaf:knows ?other, ?friend .
        ?other foaf:knows ?friend .
      }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {"person", ~I<http://xmlns.com/foaf/0.1/name>,  "name"},
            {"person", ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {"person", ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
            {"other",  ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
          ]
        }
      }} = decode(query)
  end

  test "a single bgp with a blank node property list at subject position" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT *
      WHERE {
        [ foaf:mbox ?email ] foaf:knows ?other, ?friend .
      }
      """
    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  "email"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
          ]
        }
      }} = decode(query)

    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT *
      WHERE {
        [ foaf:mbox ?email ; foaf:knows ?other, ?friend ] .
      }
      """
    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  "email"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
          ]
        }
      }} = decode(query)
  end

  test "a single bgp with a blank node property list at object position" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT *
      WHERE {
        ?s ?p [ foaf:mbox ?email ; foaf:knows ?other, ?friend ] .
      }
      """
    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.BGP{
          triples: [
            {"s", "p", %RDF.BlankNode{} = bnode},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/mbox>,  "email"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "other"},
            {%RDF.BlankNode{} = bnode, ~I<http://xmlns.com/foaf/0.1/knows>, "friend"},
          ]
        }
      }} = decode(query)
  end

  test "simple projected variables" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT ?person ?name WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Project{
          vars: ~w[person name],
          expr: %SPARQL.Algebra.BGP{
              triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
            }
          }
      }} = decode(query)
  end

  @tag skip: "TODO when we have SPARQL expressions as algebra expressions available"
  test "projected expressions"


  test "DISTINCT with *" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT DISTINCT * WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Distinct{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
          }
        }
      }} = decode(query)
  end

  test "DISTINCT with projected variables" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT DISTINCT ?person ?name WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Distinct{expr:
          %SPARQL.Algebra.Project{
            vars: ~w[person name],
            expr: %SPARQL.Algebra.BGP{
                triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
              }
            }
          }
      }} = decode(query)
  end

  test "REDUCED with *" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT REDUCED * WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Reduced{expr:
          %SPARQL.Algebra.BGP{
            triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
          }
        }
      }} = decode(query)
  end

  test "REDUCED with projected variables" do
    query = """
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      SELECT REDUCED ?person ?name WHERE { ?person foaf:name ?name }
      """

    assert {:ok, %SPARQL.Query{expr:
        %SPARQL.Algebra.Reduced{expr:
          %SPARQL.Algebra.Project{
            vars: ~w[person name],
            expr: %SPARQL.Algebra.BGP{
                triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
              }
            }
          }
      }} = decode(query)
  end

  describe "FILTER" do
    test "single filter" do
      query = """
        PREFIX ex: <http://example.org/>
        SELECT ?s ?cost WHERE {
          ?s ex:cost ?cost .
          FILTER (?cost < 10)
        }
        """
      n10 = RDF.integer(10)
      assert {:ok, %SPARQL.Query{
          expr: %SPARQL.Algebra.Project{
            vars: ~w[s cost],
            expr: %SPARQL.Algebra.Filter{
              filters: [
                %SPARQL.Algebra.FunctionCall{
                  name: :<,
                  arguments: ["cost", ^n10]
                }
              ],
              expr: %SPARQL.Algebra.BGP{
                  triples: [{"s", ~I<http://example.org/cost>, "cost"}]
                }
              }
            }
        }} = decode(query)
    end

    test "single filter with function" do
      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT ?person ?name WHERE {
          ?person foaf:name ?name
          FILTER(regex(?name, "foo", "i"))
        }
        """
      assert {:ok, %SPARQL.Query{
          expr: %SPARQL.Algebra.Project{
            vars: ~w[person name],
            expr: %SPARQL.Algebra.Filter{
              filters: [
                %SPARQL.Algebra.FunctionCall{
                  name: :REGEX,
                  arguments: ["name", ~L"foo", ~L"i"]
                }
              ],
              expr: %SPARQL.Algebra.BGP{
                  triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
                }
              }
            }
        }} = decode(query)
    end

    test "nested function call" do
      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT ?person ?name WHERE {
          ?person foaf:name ?name
          FILTER (UCASE(?name) = "foo")
        }
        """
      assert {:ok, %SPARQL.Query{
          expr: %SPARQL.Algebra.Project{
            vars: ~w[person name],
            expr: %SPARQL.Algebra.Filter{
              filters: [
                %SPARQL.Algebra.FunctionCall{
                  name: :=,
                  arguments: [
                    %SPARQL.Algebra.FunctionCall{
                      name: :UCASE,
                      arguments: ["name"]
                    },
                    ~L"foo"
                  ]
                }
              ],
              expr: %SPARQL.Algebra.BGP{
                  triples: [{"person", ~I<http://xmlns.com/foaf/0.1/name>, "name"}]
                }
              }
            }
        }} = decode(query)
    end

  end

  describe "arithmetic expressions" do

    test "complex mathematical expression" do
       assert_algebra_expr "(42 - 11 * 2) / 2",
          %SPARQL.Algebra.FunctionCall{
            name: :/,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [RDF.integer(42),
                  %SPARQL.Algebra.FunctionCall{
                    name: :*,
                    arguments: [RDF.integer(11), RDF.integer(2)]
                  }
                ]
              }, RDF.integer(2)
            ]
          }
    end

    test "complex mathematical expression with signed numbers" do
       assert_algebra_expr "(-42 - -(+11 * -2)) / -2",
          %SPARQL.Algebra.FunctionCall{
            name: :/,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [RDF.integer(-42),
                  %SPARQL.Algebra.FunctionCall{
                    name: :-,
                    arguments: [
                      %SPARQL.Algebra.FunctionCall{
                        name: :*,
                        arguments: [RDF.integer("+11"), RDF.integer(-2)]
                      }
                    ]
                  }
                ]
              }, RDF.integer(-2)
            ]
          }
    end

    test "associativity of additive expressions" do
       assert_algebra_expr "2 - 3 + 1",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [RDF.integer(2), RDF.integer(3)
                ]
              }, RDF.integer(1)
            ]
          }

       assert_algebra_expr "2 - 3 + 1 - 42",
          %SPARQL.Algebra.FunctionCall{
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                arguments: [
                  %SPARQL.Algebra.FunctionCall{
                    arguments: [RDF.integer(2), RDF.integer(3)],
                    name: :-
                  }, RDF.integer(1)
                ],
                name: :+
              }, RDF.integer(42)
            ],
            name: :-
          }
    end

    test "associativity of multiplicative expressions" do
       assert_algebra_expr "1 * 2 / 3",
          %SPARQL.Algebra.FunctionCall{
            name: :/,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :*,
                arguments: [RDF.integer(1), RDF.integer(2)
                ]
              }, RDF.integer(3)
            ]
          }

       assert_algebra_expr "2 / 3 * 1 / 42",
          %SPARQL.Algebra.FunctionCall{
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                arguments: [
                  %SPARQL.Algebra.FunctionCall{
                    arguments: [RDF.integer(2), RDF.integer(3)],
                    name: :/
                  }, RDF.integer(1)
                ],
                name: :*
              }, RDF.integer(42)
            ],
            name: :/
          }
    end

    test "associativity of mixed expressions" do
       assert_algebra_expr "1 + 2 / 3",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              RDF.integer(1),
              %SPARQL.Algebra.FunctionCall{
                name: :/,
                arguments: [RDF.integer(2), RDF.integer(3)
                ]
              }
            ]
          }

       assert_algebra_expr "1 * 2 + 3",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :*,
                arguments: [RDF.integer(1), RDF.integer(2)
                ]
              }, RDF.integer(3)
            ]
          }

       assert_algebra_expr "2 - 3 + 4 * 42 / 5",
          %SPARQL.Algebra.FunctionCall{
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                arguments: [RDF.integer(2), RDF.integer(3)],
                name: :-
              },
              %SPARQL.Algebra.FunctionCall{
                arguments: [
                  %SPARQL.Algebra.FunctionCall{
                    arguments: [RDF.integer(4), RDF.integer(42)],
                    name: :*
                  }, RDF.integer(5)
                ],
                name: :/
              }
            ],
            name: :+
          }
    end

    test "arithmetic expression signs quirk #1" do
       assert_algebra_expr "2-3+1",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [RDF.integer(2), RDF.integer(3)
                ]
              }, RDF.integer(1)
            ]
          }

       assert_algebra_expr "2-+3+1",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [RDF.integer(2), RDF.integer("+3")
                ]
              }, RDF.integer(1)
            ]
          }

       assert_algebra_expr "2-+3++1",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [RDF.integer(2), RDF.integer("+3")
                ]
              }, RDF.integer("+1")
            ]
          }

       assert_algebra_expr "-2*+3+-1",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :*,
                arguments: [RDF.integer(-2), RDF.integer("+3")
                ]
              },
              RDF.integer(-1),
            ]
          }

    end

    test "arithmetic expression signs quirk #2" do
       assert_algebra_expr "2-3*1",
          %SPARQL.Algebra.FunctionCall{
            name: :-,
            arguments: [
              RDF.integer(2),
              %SPARQL.Algebra.FunctionCall{
                name: :*,
                arguments: [RDF.integer(3), RDF.integer(1)
                ]
              }
            ]
          }

       assert_algebra_expr "-2-+3*-1",
          %SPARQL.Algebra.FunctionCall{
            name: :-,
            arguments: [
              RDF.integer(-2),
              %SPARQL.Algebra.FunctionCall{
                name: :*,
                arguments: [RDF.integer("+3"), RDF.integer(-1)
                ]
              }
            ]
          }
    end

    test "arithmetic expression signs quirk #3" do
       assert_algebra_expr "2-3*1+4",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [
                  RDF.integer(2),
                  %SPARQL.Algebra.FunctionCall{
                    name: :*,
                    arguments: [RDF.integer(3), RDF.integer(1)]
                  }
                ]
              }, RDF.integer(4)
            ]
          }

       assert_algebra_expr "2-3*1/5+4",
          %SPARQL.Algebra.FunctionCall{
            name: :+,
            arguments: [
              %SPARQL.Algebra.FunctionCall{
                name: :-,
                arguments: [
                  RDF.integer(2),
                  %SPARQL.Algebra.FunctionCall{
                    name: :/,
                    arguments: [
                      %SPARQL.Algebra.FunctionCall{
                        name: :*,
                        arguments: [RDF.integer(3), RDF.integer(1)]
                      }, RDF.integer(5)
                    ]
                  }
                ]
              }, RDF.integer(4)
            ]
          }
    end

    test "arithmetic expression signs quirk #4" do
       assert_algebra_expr "2-3*1/4",
          %SPARQL.Algebra.FunctionCall{
            name: :-,
            arguments: [
              RDF.integer(2),
              %SPARQL.Algebra.FunctionCall{
                name: :/,
                arguments: [
                  %SPARQL.Algebra.FunctionCall{
                    name: :*,
                    arguments: [RDF.integer(3), RDF.integer(1)]
                  }, RDF.integer(4)
                ]
              }
            ]
          }

       assert_algebra_expr "2-3*1/4*5",
          %SPARQL.Algebra.FunctionCall{
            name: :-,
            arguments: [
              RDF.integer(2),
              %SPARQL.Algebra.FunctionCall{
                name: :*,
                arguments: [
                  %SPARQL.Algebra.FunctionCall{
                    name: :/,
                    arguments: [
                      %SPARQL.Algebra.FunctionCall{
                        name: :*,
                        arguments: [RDF.integer(3), RDF.integer(1)]
                      }, RDF.integer(4)
                    ]
                  }, RDF.integer(5)
                ]
              }
            ]
          }
    end

    def assert_algebra_expr(arithmetic_expr, algebra_expr) do
      query = """
        SELECT ?o WHERE {
          ?s ?p ?o .
          FILTER (?o = (#{arithmetic_expr}))
        }
        """

      assert {:ok, %SPARQL.Query{
          expr: %SPARQL.Algebra.Project{
            vars: ~w[o],
            expr: %SPARQL.Algebra.Filter{
              filters: [
                %SPARQL.Algebra.FunctionCall{
                  name: :=,
                  arguments: ["o", ^algebra_expr]
                }
              ],
              expr: %SPARQL.Algebra.BGP{triples: [{"s", "p", "o"}]}
            }
          }
        }} = decode(query)
    end
  end

end
