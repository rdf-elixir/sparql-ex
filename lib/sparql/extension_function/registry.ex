defmodule SPARQL.ExtensionFunction.Registry do
  @moduledoc """
  A registry of all available `SPARQL.ExtensionFunction`s.
  """

  @key :sparql_extension_functions

  def init do
    FastGlobal.put(
      @key,
      find_available_extension_functions!()
      |> Map.new(fn extension -> {extension.name, extension} end)
    )
  end

  @doc """
  Returns the extension for the given name.

  If no function for the given name exists, `nil` is returned.
  """
  def get_extension(name)

  def get_extension(%RDF.IRI{value: value}), do: value |> get_extension()

  def get_extension(name) do
    FastGlobal.get(@key)[name]
  end

  @doc """
  Returns a map of all extensions by name.
  """
  def get_all() do
    FastGlobal.get(@key)
  end

  defp find_available_extension_functions!() do
    SPARQL.ExtensionFunction
    |> SPARQL.Utils.find_behaviour_implementations()
    |> check_homonyms!()
  end

  defp check_homonyms!(extensions) do
    extensions
    |> Enum.group_by(fn extension -> extension.name end)
    |> Enum.reject(fn {_, extension} -> Enum.count(extension) == 1 end)
    |> case do
         [] -> extensions
         homonyms ->
           raise """
            The following names are used for multiple SPARQL.ExtensionFunctions:
            #{inspect Map.new(homonyms)}
            """
       end
  end
end
