defmodule SPARQL.Query.Result.Format.Encoder do
  @moduledoc """
  A behaviour for encoders of `SPARQL.Query.Result`s in a specific `SPARQL.Query.Result.Format`s.
  """

  @doc """
  Encodes a `SPARQL.Query.Result`.

  It returns an `{:ok, string}` tuple, with `string` being the serialized
  `SPARQL.Query.Result`, or `{:error, reason}` if an error occurs.
  """
  @callback encode(SPARQL.Query.Result.t, keyword) :: keyword(String.t)

  @doc """
  Encodes a `SPARQL.Query.Result`.

  As opposed to `encode`, it raises an exception if an error occurs.

  Note: The `__using__` macro automatically provides an overridable default
  implementation based on the non-bang `encode` function.
  """
  @callback encode!(SPARQL.Query.Result.t, keyword) :: String.t


  defmacro __using__(_) do
    quote bind_quoted: [], unquote: true do
      @behaviour unquote(__MODULE__)

      def encode!(data, opts \\ []) do
        case encode(data, opts) do
          {:ok,    data}   -> data
          {:error, reason} -> raise reason
        end
      end

      defoverridable [encode!: 2]
    end
  end

end
