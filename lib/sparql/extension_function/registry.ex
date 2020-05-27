defmodule SPARQL.ExtensionFunction.Registry do
  @moduledoc """
  A registry of all available `SPARQL.ExtensionFunction`s.
  """

  alias SPARQL.ExtensionFunction.Registration

  @doc """
  Returns the extension for the given name.

  If no function for the given name exists, `nil` is returned.
  """
  def extension_function(name)

  def extension_function(%RDF.IRI{value: value}), do: value |> extension_function()

  def extension_function(name) do
    Registration.extension_function(name)
  end
end
