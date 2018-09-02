defmodule SPARQL.ExtensionFunction do
  @moduledoc """
  A behaviour for SPARQL extension functions.

  ## Examples

  An extension function can be defined like this:

      defmodule ExampleFunction do
        use SPARQL.ExtensionFunction, name: "http://example.com/function"

        def call(distinct, arguments, data, execution) do
          # your implementation
        end
      end


  see
  - <https://www.w3.org/TR/sparql11-query/#extensionFunctions>
  - <https://www.w3.org/TR/sparql11-query/#operatorExtensibility>
  """

  @doc """
  The name of the extension function.

  As specified in the SPARQL grammar the name of a function is an IRI.
  """
  @callback name() :: String.t

  @doc """
  Calls the extension function.

  The `distinct` argument is a boolean flag  which signifies if the `DISTINCT`
  modifier was used in the function call.
  """
  @callback call(distinct :: boolean(),
                 arguments :: list(RDF.Term.t),
                 data :: RDF.Dataset.t | RDF.Graph.t,
                 execution :: map)
              :: RDF.Term.t | :error


  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)

    quote do
      @behaviour unquote(__MODULE__)

      @impl unquote(__MODULE__)
      def name(), do: unquote(name)
    end
  end

end
