defmodule SPARQL.Utils do
  @moduledoc false

  @doc """
  Find and loads all modules implementing the given Behaviour.

  Finding all modules implementing a behaviour is an open problem in Elixir.
  We apply multiple heuristics to catch as much as possible.
  """
  @spec find_behaviour_implementations(atom) :: [] | [atom]
  def find_behaviour_implementations(behaviour) when is_atom(behaviour) do
    MapSet.union(
      MapSet.new(find_behaviour_implementations_from_beam_files(behaviour)),
      MapSet.new(find_behaviour_implementations_from_code_all_loaded(behaviour))
    )
    |> MapSet.to_list()
  end

  # from https://stackoverflow.com/a/36435699/2114405
  defp find_behaviour_implementations_from_beam_files(behaviour) when is_atom(behaviour) do
    if :code.get_mode() == :embedded do
      [] # if we run in embedded, the find_behaviour_implementations_from_code_all_loaded approach should be sufficient
    else
      available_modules(behaviour) |> Enum.reduce([], &load_module/2)
    end
  end

  defp load_module(module, modules) do
    if Code.ensure_loaded?(module), do: [module | modules], else: modules
  end

  defp available_modules(behaviour) do
    unless running_as_release?() do
      # Ensure the current projects code path is loaded
      Mix.Task.run("loadpaths", [])
      # Fetch all .beam files
      Path.wildcard(Path.join([Mix.Project.build_path, "**/ebin/**/*.beam"]))
      # Parse the BEAM for behaviour implementations
      |> Stream.map(fn path ->
        {:ok, {mod, chunks}} = :beam_lib.chunks('#{path}', [:attributes])
        {mod, get_in(chunks, [:attributes, :behaviour])}
      end)
        # Filter out behaviours we don't care about and duplicates
      |> Stream.filter(fn {_mod, behaviours} -> is_list(behaviours) && behaviour in behaviours end)
      |> Enum.uniq
      |> Enum.map(fn {module, _} -> module end)
    else
      unless Application.get_env(:sparql, :no_extension_detection_in_releases_warning) do
        IO.warn """
                You're probably running a release with the runtime system in interactive mode. Not all SPARQL extensions functions may be detected properly. Some of them might not be available.
                """, []
      end
      []
    end
  end

  defp find_behaviour_implementations_from_code_all_loaded(behaviour) when is_atom(behaviour) do
    (for {module, _} <- :code.all_loaded(), do: module)
    |> Enum.filter(&(implements_behaviour?(&1, behaviour)))
  end

  defp implements_behaviour?(module, behaviour) do
    module.module_info[:attributes]
    |> Keyword.get(:behaviour, [])
    |> Enum.member?(behaviour)
  end

  # TODO: is there a better way to determine if we are running a release and don't have a proper Mix environment?
  defp running_as_release? do
    is_nil(Process.whereis(Mix.ProjectStack))
  end

end
