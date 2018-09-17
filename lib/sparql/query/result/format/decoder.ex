defmodule SPARQL.Query.Result.Format.Decoder do
  @moduledoc """
  A behaviour for decoders of strings encoded in a specific `SPARQL.Query.Result.Format`.
  """


  @doc """
  Decodes a serialized `SPARQL.Query.Result` from the given string.

  It returns an `{:ok, result_set}` tuple or `{:error, reason}` if an error occurs.
  """
  @callback decode(String.t, keyword) :: {:ok, SPARQL.Query.Result.t} |
                                         {:error, any}
  @doc """
  Decodes a serialized `SPARQL.Query.Result` from the given string.

  As opposed to `decode`, it raises an exception if an error occurs.

  Note: The `__using__` macro automatically provides an overridable default
  implementation based on the non-bang `decode` function.
  """
  @callback decode!(String.t, keyword) :: SPARQL.Query.Result.t


  defmacro __using__(_) do
    quote bind_quoted: [], unquote: true do
      @behaviour unquote(__MODULE__)

      alias SPARQL.Query.Result

      def decode!(content, opts \\ []) do
        case decode(content, opts) do
          {:ok,    data}   -> data
          {:error, reason} -> raise reason
        end
      end

      defoverridable [decode!: 2]
    end
  end

end
