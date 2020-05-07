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
              %SPARQL.Algebra.FunctionCall.Builtin{
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
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :/,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [XSD.integer(42),
                %SPARQL.Algebra.FunctionCall.Builtin{
                  name: :*,
                  arguments: [XSD.integer(11), XSD.integer(2)]
                }
              ]
            }, XSD.integer(2)
          ]
        }
  end

  test "complex mathematical expression with signed numbers" do
     assert_algebra_expr "(-42 - -(+11 * -2)) / -2",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :/,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [XSD.integer(-42),
                %SPARQL.Algebra.FunctionCall.Builtin{
                  name: :-,
                  arguments: [
                    %SPARQL.Algebra.FunctionCall.Builtin{
                      name: :*,
                      arguments: [XSD.integer("+11"), XSD.integer(-2)]
                    }
                  ]
                }
              ]
            }, XSD.integer(-2)
          ]
        }
  end

  test "associativity of additive expressions" do
     assert_algebra_expr "2 - 3 + 1",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [XSD.integer(2), XSD.integer(3)
              ]
            }, XSD.integer(1)
          ]
        }

     assert_algebra_expr "2 - 3 + 1 - 42",
        %SPARQL.Algebra.FunctionCall.Builtin{
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              arguments: [
                %SPARQL.Algebra.FunctionCall.Builtin{
                  arguments: [XSD.integer(2), XSD.integer(3)],
                  name: :-
                }, XSD.integer(1)
              ],
              name: :+
            }, XSD.integer(42)
          ],
          name: :-
        }
  end

  test "associativity of multiplicative expressions" do
     assert_algebra_expr "1 * 2 / 3",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :/,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :*,
              arguments: [XSD.integer(1), XSD.integer(2)
              ]
            }, XSD.integer(3)
          ]
        }

     assert_algebra_expr "2 / 3 * 1 / 42",
        %SPARQL.Algebra.FunctionCall.Builtin{
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              arguments: [
                %SPARQL.Algebra.FunctionCall.Builtin{
                  arguments: [XSD.integer(2), XSD.integer(3)],
                  name: :/
                }, XSD.integer(1)
              ],
              name: :*
            }, XSD.integer(42)
          ],
          name: :/
        }
  end

  test "associativity of mixed expressions" do
     assert_algebra_expr "1 + 2 / 3",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            XSD.integer(1),
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :/,
              arguments: [XSD.integer(2), XSD.integer(3)
              ]
            }
          ]
        }

     assert_algebra_expr "1 * 2 + 3",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :*,
              arguments: [XSD.integer(1), XSD.integer(2)
              ]
            }, XSD.integer(3)
          ]
        }

     assert_algebra_expr "2 - 3 + 4 * 42 / 5",
        %SPARQL.Algebra.FunctionCall.Builtin{
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              arguments: [XSD.integer(2), XSD.integer(3)],
              name: :-
            },
            %SPARQL.Algebra.FunctionCall.Builtin{
              arguments: [
                %SPARQL.Algebra.FunctionCall.Builtin{
                  arguments: [XSD.integer(4), XSD.integer(42)],
                  name: :*
                }, XSD.integer(5)
              ],
              name: :/
            }
          ],
          name: :+
        }
  end

  test "arithmetic expression signs quirk #1" do
     assert_algebra_expr "2-3+1",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [XSD.integer(2), XSD.integer(3)
              ]
            }, XSD.integer(1)
          ]
        }

     assert_algebra_expr "2-+3+1",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [XSD.integer(2), XSD.integer("+3")
              ]
            }, XSD.integer(1)
          ]
        }

     assert_algebra_expr "2-+3++1",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [XSD.integer(2), XSD.integer("+3")
              ]
            }, XSD.integer("+1")
          ]
        }

     assert_algebra_expr "-2*+3+-1",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :*,
              arguments: [XSD.integer(-2), XSD.integer("+3")
              ]
            },
            XSD.integer(-1),
          ]
        }

  end

  test "arithmetic expression signs quirk #2" do
     assert_algebra_expr "2-3*1",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :-,
          arguments: [
            XSD.integer(2),
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :*,
              arguments: [XSD.integer(3), XSD.integer(1)
              ]
            }
          ]
        }

     assert_algebra_expr "-2-+3*-1",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :-,
          arguments: [
            XSD.integer(-2),
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :*,
              arguments: [XSD.integer("+3"), XSD.integer(-1)
              ]
            }
          ]
        }
  end

  test "arithmetic expression signs quirk #3" do
     assert_algebra_expr "2-3*1+4",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [
                XSD.integer(2),
                %SPARQL.Algebra.FunctionCall.Builtin{
                  name: :*,
                  arguments: [XSD.integer(3), XSD.integer(1)]
                }
              ]
            }, XSD.integer(4)
          ]
        }

     assert_algebra_expr "2-3*1/5+4",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :+,
          arguments: [
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :-,
              arguments: [
                XSD.integer(2),
                %SPARQL.Algebra.FunctionCall.Builtin{
                  name: :/,
                  arguments: [
                    %SPARQL.Algebra.FunctionCall.Builtin{
                      name: :*,
                      arguments: [XSD.integer(3), XSD.integer(1)]
                    }, XSD.integer(5)
                  ]
                }
              ]
            }, XSD.integer(4)
          ]
        }
  end

  test "arithmetic expression signs quirk #4" do
     assert_algebra_expr "2-3*1/4",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :-,
          arguments: [
            XSD.integer(2),
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :/,
              arguments: [
                %SPARQL.Algebra.FunctionCall.Builtin{
                  name: :*,
                  arguments: [XSD.integer(3), XSD.integer(1)]
                }, XSD.integer(4)
              ]
            }
          ]
        }

     assert_algebra_expr "2-3*1/4*5",
        %SPARQL.Algebra.FunctionCall.Builtin{
          name: :-,
          arguments: [
            XSD.integer(2),
            %SPARQL.Algebra.FunctionCall.Builtin{
              name: :*,
              arguments: [
                %SPARQL.Algebra.FunctionCall.Builtin{
                  name: :/,
                  arguments: [
                    %SPARQL.Algebra.FunctionCall.Builtin{
                      name: :*,
                      arguments: [XSD.integer(3), XSD.integer(1)]
                    }, XSD.integer(4)
                  ]
                }, XSD.integer(5)
              ]
            }
          ]
        }
  end

end
