defmodule SPARQL.Algebra.FunctionCall.Extension do
  defstruct name: nil,
            arguments: [],
            distinct: false

  defimpl SPARQL.Algebra.Expression do
    def evaluate(%SPARQL.Algebra.FunctionCall.Extension{
                    name: name, arguments: arguments, distinct: distinct},
                  data, execution) do
      case SPARQL.ExtensionFunction.Registry.get_extension(name) do
        nil ->
          # TODO: What should happen when no function_extension found?
          :error

        extension_function ->
          extension_function.call(distinct, arguments, data, execution)
      end
    end

    def variables(function_call) do
      # TODO: return used and/or introduced variables???
    end
  end

end
