defmodule SPARQL.Query.Result.Format do
  @moduledoc """
  A behaviour for SPARQL query result formats.

  A `SPARQL.Query.Result.Format` for a format can be implemented like this

      defmodule SomeFormat do
        use SPARQL.Query.Result.Format
        import RDF.Sigils

        @id         ~I<http://example.com/some_format>
        @name       :some_format
        @extension  "ext"
        @media_type "application/some-format"
      end

  When `@id`, `@name`, `@extension` and `@media_type` module attributes are
  defined the resp. behaviour functions are generated automatically and return
  these values.

  Then you'll have to do the main work by implementing a
  `RDF.Serialization.Encoder` and a `RDF.Serialization.Decoder` for the format.

  By default, it is assumed that these are defined in `Encoder` and `Decoder`
  modules under the module of the format, i.e. in the example above in
  `SomeFormat.Encoder` and `SomeFormat.Decoder`.
  If you want them in another module, you'll have to override the `encoder/0`
  and/or `decoder/0` functions in your `SPARQL.Query.Result.Format` module.
  """

  @doc """
  An IRI of the SPARQL query result format.
  """
  @callback id :: RDF.IRI.t

  @doc """
  An name atom of the SPARQL query result format under which it can referenced.
  """
  @callback name :: atom

  @doc """
  The usual file extension for the SPARQL query result format.
  """
  @callback extension :: binary

  @doc """
  The MIME type of the SPARQL query result format.
  """
  @callback media_type :: binary

  @doc """
  A list of the supported query forms of the SPARQL query result format.
  """
  @callback supported_query_forms :: [SPARQL.Query.forms]

  @doc """
  The `SPARQL.Query.Result.Format.Decoder` module for the result format.
  """
  @callback decoder :: module

  @doc """
  The `SPARQL.Query.Result.Format.Encoder` module for the result format.
  """
  @callback encoder :: module


  defmacro __using__(_) do
    quote bind_quoted: [], unquote: true do
      @behaviour unquote(__MODULE__)

      @decoder __MODULE__.Decoder
      @encoder __MODULE__.Encoder

      def decoder, do: @decoder
      def encoder, do: @encoder

      defdelegate decode(results, opts \\ []),  to: @decoder
      defdelegate decode!(results, opts \\ []), to: @decoder

#      defdelegate encode(content, opts \\ []),  to: @encoder
#      defdelegate encode!(content, opts \\ []), to: @encoder

      # This is just to be API-compatible to RDF.Serialization.format.
      # TODO: Should we introduce a similar Reader-/Writer-functionality here or introduce RDF.Serialization.decode?
      defdelegate read_string(results, opts \\ []),  to: __MODULE__, as: :decode


      defoverridable [decoder: 0, encoder: 0]

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      if !Module.defines?(__MODULE__, {:id, 0}) &&
          Module.get_attribute(__MODULE__, :id) do
        def id, do: @id
      end
      if !Module.defines?(__MODULE__, {:name, 0}) &&
          Module.get_attribute(__MODULE__, :name) do
        def name, do: @name
      end
      if !Module.defines?(__MODULE__, {:extension, 0}) &&
          Module.get_attribute(__MODULE__, :extension) do
        def extension, do: @extension
      end
      if !Module.defines?(__MODULE__, {:media_type, 0}) &&
          Module.get_attribute(__MODULE__, :media_type) do
        def media_type, do: @media_type
      end
      if !Module.defines?(__MODULE__, {:supported_query_forms, 0}) &&
          Module.get_attribute(__MODULE__, :supported_query_forms) do
        def supported_query_forms, do: @supported_query_forms
      end
    end
  end
end
