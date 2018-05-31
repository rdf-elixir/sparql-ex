defmodule SPARQL.Algebra.FunctionCall.Builtin do
  defstruct name: nil,
            arguments: []

  alias SPARQL.Algebra.FunctionCall
  alias SPARQL.Functions.Builtins


  def invoke(name, arguments, data) do
    with {:ok, evaluated_arguments} <-
            FunctionCall.evaluate_arguments(arguments, data)
    do
      Builtins.call(name, evaluated_arguments)
    end
  end


  defimpl SPARQL.Algebra.Expression do
    def evaluate(%FunctionCall.Builtin{name: name, arguments: arguments}, data) do
      FunctionCall.Builtin.invoke(name, arguments, data)
    end

    def variables(function_call) do
      # TODO: return used and/or introduced variables???
    end
  end

end
