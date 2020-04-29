defmodule SPARQL.Language.ParseHelper do
  alias RDF.Literal

  def variable('?' ++ name), do: List.to_string(name)
  def variable('$' ++ name), do: List.to_string(name)

  # TODO: Literal construction should not happen in the lexer, but during parsing;
  #       grammars and RDF.Serialization.ParseHelper should be rewritten accordingly
  def extract_literal({_, _, literal}), do: literal


  def strip_sign(%Literal{} = literal) do
    {_sign, number} = literal |> Literal.lexical() |> String.split_at(1)
    Literal.update(literal, fn _ -> number end)
  end


  def arithmetic_expr({:rpn, rpn}), do: rpn_to_ast(rpn)
  def arithmetic_expr(expr),        do: expr

  def arithmetic_expr(left, [operator, {:rpn, rpn}]) do
    arithmetic_expr(left, [operator, rpn_to_ast(rpn)])
  end

  def arithmetic_expr({:rpn, rpn}, [operator, right]) do
    arithmetic_expr(rpn_to_ast(rpn), [operator, right])
  end

  def arithmetic_expr([{left_operator, _}, left], {:rpn, rpn})
      when left_operator in ~w[* /]a do
    {:rpn, [left, left_operator | rpn]}
  end

  def arithmetic_expr([{left_operator, _}, left], [{right_operator, _}, right])
      when left_operator in ~w[* /]a and right_operator in ~w[* /]a do
    {:rpn, [left, left_operator, right, right_operator]}
  end

  def arithmetic_expr(left, [operator, right]) do
    {:builtin_function_call, arithmetic_operator(operator), [left, right]}
  end

  def arithmetic_expr(left, {:rpn, rpn}) do
    rpn_to_ast([left | rpn])
  end

  def arithmetic_expr(left_operator, left, [right_operator, {:rpn, rpn}]) do
    arithmetic_expr(left_operator, left, [right_operator, rpn_to_ast(rpn)])
  end

  def arithmetic_expr(left_operator, left, [right_operator, right]) do
    {:rpn, [left, arithmetic_operator(left_operator), right, arithmetic_operator(right_operator)]}
  end

  def arithmetic_expr(left_operator, left, {:rpn, rpn}) do
    {:rpn, [left, arithmetic_operator(left_operator) | rpn]}
  end

  def arithmetic_quirk_expr(sign, left, {:rpn, rpn}, [additive_operator, right]) do
    {:rpn,
      [left | rpn] ++ [
        sign,
        right,
        arithmetic_operator(additive_operator)
      ]
    }
  end

  def arithmetic_quirk_expr(sign, left,
                      [{multiplicative_operator, _}, middle],
                      [additive_operator, right]) do
    {:rpn,
      [
        arithmetic_expr(left, [multiplicative_operator, middle]),
        sign,
        right,
        arithmetic_operator(additive_operator)
      ]
    }
  end

  def multiplicative_expr({left_operator, _}, left, {:rpn, [right | rpn]}) do
    {:rpn, [left, right, left_operator | rpn]}
  end

  def multiplicative_expr({left_operator, _}, left, right) do
    {:rpn, [left, right, left_operator]}
  end

  def multiplicative_quirk_expr(sign, left, {:rpn, rpn}) do
    {:rpn, [left | rpn] ++ [sign]}
  end

  def multiplicative_quirk_expr(sign, left, [{right_operator, _}, right]) do
    {:rpn, [left, right, right_operator, sign]}
  end

  defp arithmetic_operator({operator, _}),                   do: operator
  defp arithmetic_operator(operator) when is_atom(operator), do: operator

  defp rpn_to_ast(rpn) do
    {function_call, []} = rpn |> Enum.reverse() |> do_rpn_to_ast()
    function_call
  end

  defp do_rpn_to_ast([operator | rest]) when operator in ~w[+ - * /]a do
    {right, rest} = do_rpn_to_ast(rest)
    {left,  rest} = do_rpn_to_ast(rest)
    {{:builtin_function_call, operator, [left, right]}, rest}
  end

  defp do_rpn_to_ast([arg | rest]), do: {arg, rest}

end
