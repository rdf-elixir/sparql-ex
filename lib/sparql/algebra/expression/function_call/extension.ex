defmodule SPARQL.Algebra.FunctionCall.Extension do
  defstruct name: nil,
            arguments: [],
            distinct: false

  alias SPARQL.Algebra.FunctionCall

  defimpl SPARQL.Algebra.Expression do
    def evaluate(%SPARQL.Algebra.FunctionCall.Extension{
                    name: name, arguments: arguments, distinct: distinct},
                  data, execution) do
      case SPARQL.ExtensionFunction.Registry.extension_function(name) do
        nil ->
          # TODO: What should happen when no function_extension found?
          :error

        extension_function ->
          with {:ok, evaluated_arguments} <-
                 FunctionCall.evaluate_arguments(arguments, data, execution) do
            extension_function.call(distinct, evaluated_arguments, data, execution)
          end
      end
    end

    def variables(function_call) do
      # TODO: return used and/or introduced variables???
    end
  end

end
