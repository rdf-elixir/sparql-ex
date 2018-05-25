defmodule SPARQL.Algebra.ArithmeticExpressionTest do
  use SPARQL.Test.Case


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
      }} = SPARQL.Language.Decoder.decode(query)
  end


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

end
