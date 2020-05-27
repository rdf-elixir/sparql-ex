defmodule SPARQL.TestExtensionFunctions do
  defmodule ExampleFunction do
    use SPARQL.ExtensionFunction, name: "http://example.com/function"

    def call(_distinct, _arguments, _data, _execution), do: RDF.XSD.true
  end

end
