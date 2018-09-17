defmodule SPARQL.ExtensionFunction.Registry do
  @moduledoc """
  A registry of all available `SPARQL.ExtensionFunction`s.
  """

  use GenServer

  @ets_table :sparql_extension_function_registry

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Returns the extension for the given name.

  If no function for the given name exists, `nil` is returned.
  """
  def get_extension(name)

  def get_extension(%RDF.IRI{value: value}), do: value |> get_extension()

  def get_extension(name) do
    case :ets.lookup(@ets_table, name) do
      []               -> nil
      [{_, extension}] -> extension
    end
  end

  @doc """
  Returns a map of all extensions by name.
  """
  def get_all() do
    @ets_table
    |> :ets.match_object({:"$0", :"$1"})
    |> Map.new()
  end

  @doc """
  Rechecks for all available `SPARQL.ExtensionFunction`s and resets the registry.

  This might be necessary when dynamically defining `SPARQL.ExtensionFunction`s,
  eg. in tests.
  """
  def refresh() do
    GenServer.call(__MODULE__, :refresh)
  end


  def init(_) do
    :ets.new(@ets_table, [:set, :named_table, :protected])
    setup()

    {:ok, nil}
  end

  def handle_call(:refresh, _, state) do
    :ets.delete_all_objects(@ets_table)
    setup()

    {:reply, :ok, state}
  end
  
  defp setup() do
    find_available_extension_functions!()
    |> Enum.each(fn extension ->
         :ets.insert(@ets_table, {extension.name, extension})
       end)
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
