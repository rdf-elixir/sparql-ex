defmodule SPARQL.ExtensionFunction.Registry do
  @moduledoc """
  A registry of all available `SPARQL.ExtensionFunction`s.
  """

  use Agent

  def start_link(_) do
    Agent.start_link(&setup/0, name: __MODULE__)
  end

  @doc """
  Returns the extension for the given name.

  If no function for the given name exists, `nil` is returned.
  """
  def get_extension(name)

  def get_extension(%RDF.IRI{value: value}), do: value |> get_extension()

  def get_extension(name) do
    Agent.get(__MODULE__, &Map.get(&1, name))
  end

  @doc """
  Rechecks for all available `SPARQL.ExtensionFunction`s and resets the registry.

  This might be necessary when dynamically defining `SPARQL.ExtensionFunction`s,
  eg. in tests.
  """
  def refresh() do
    Agent.update(__MODULE__, &setup/1)
  end


  defp setup(_ \\ nil) do
    determine_available_extension_functions()
    |> Map.new(fn extension -> {extension.name(), extension} end)
  end

  defp determine_available_extension_functions() do
    (for {module, _} <- :code.all_loaded(), do: module)
    |> Enum.filter(&is_extension_function?/1)
    |> check_homonyms!()
  end

  defp is_extension_function?(module) do
    module.module_info[:attributes]
    |> Keyword.get(:behaviour, [])
    |> Enum.member?(SPARQL.ExtensionFunction)
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
