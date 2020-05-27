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

  The name of the module is arbitrary and has no further meaning.

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
  modifier was used in the function call, which is syntactically allowed in
  custom aggregate function calls only.

  The `arguments` argument is the list of already evaluated RDF terms with which
  the extension function was called in the SPARQL query.

  The `data` argument contains the currently evaluated solution and some other
  internal information and shouldn't be relied upon, because it might be subject
  to changes and contain different elements depending on the context the function
  was called in. Since the arguments are already evaluated against the current
  solution it shouldn't be necessary anyway.

  The `execution` argument is a map with some global execution context
  information. In particular:

  - `base`: the base IRI
  - `time`: the query execution time
  - `bnode_generator`: the name of the `RDF.BlankNode.Generator` (see
    [RDF.ex documentation](http://hexdocs.pm/rdf)) used to generate unique blank
    nodes consistently

  """
  @callback call(distinct :: boolean(),
                 arguments :: list(RDF.Term.t),
                 data :: RDF.Dataset.t | RDF.Graph.t,
                 execution :: map)
              :: RDF.Term.t | :error


  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)
    extension_function = __CALLER__.module

    quote do
      @behaviour unquote(__MODULE__)

      @impl unquote(__MODULE__)
      def name(), do: unquote(name)


      import ProtocolEx

      defimpl_ex Registration, unquote(name),
                 for: SPARQL.ExtensionFunction.Registration do
        def extension_function(name), do: unquote(extension_function)
      end
    end
  end

end
