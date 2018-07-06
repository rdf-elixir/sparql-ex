defmodule SPARQL.Functions.Builtins do

  alias RDF.{Literal, Boolean}
  alias RDF.NS.XSD

  @xsd_string XSD.string
  @lang_string RDF.langString

  @doc """
  Value equality

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  - <https://www.w3.org/TR/sparql11-query/#func-RDFterm-equal>
  """
  def call(:=, [left, right]) do
    left |> RDF.Term.equal_value?(right) |> ebv()
  end

  @doc """
  Value inequality

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  - <https://www.w3.org/TR/sparql11-query/#func-RDFterm-equal>
  """
  def call(:!=, [left, right]) do
    left |> RDF.Term.equal_value?(right) |> fn_not()
  end

  @doc """
  `sameTerm` equality

  see <https://www.w3.org/TR/sparql11-query/#func-sameTerm>
  """
  def call(:sameTerm, [left, right]) do
    left |> RDF.Term.equal?(right) |> ebv()
  end

  @doc """
  Less-than operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:<, [%Literal{} = left, %Literal{} = right]) do
    cond do
      RDF.Numeric.type?(left.datatype) and RDF.Numeric.type?(right.datatype) ->
        ebv(left.value < right.value)

      left.datatype == right.datatype ->
        ebv(left.value < right.value)

      true ->
        :error
    end
  end

  def call(:<, _), do: :error

  @doc """
  Greater-than operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:>, [arg1, arg2]) do
    call(:<, [arg2, arg1])
  end

  @doc """
  Greater-or-equal operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:>=, args) do
    case call(:>, args) do
      %RDF.Literal{value: false} -> call(:=, args)
      true_or_error              -> true_or_error
    end
  end

  @doc """
  Less-or-equal operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:<=, args) do
    case call(:<, args) do
      %RDF.Literal{value: false} -> call(:=, args)
      true_or_error              -> true_or_error
    end
  end


  @doc """
  Logical `NOT`

  Returns `RDF.true` if the effective boolean value of the given argument is
  `RDF.false`, or `RDF.false` if it is `RDF.true`. Otherwise it returns `error`.

  see <http://www.w3.org/TR/xpath-functions/#func-not>
  """
  def call(:!, [argument]) do
    fn_not(argument)
  end


  @doc """
  Numeric addition.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-add>
  """
  def call(:+, [left, right]) do
    RDF.Numeric.add(left, right) || :error
  end

  @doc """
  Numeric subtraction.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-subtract>
  """
  def call(:-, [left, right]) do
    RDF.Numeric.subtract(left, right) || :error
  end

  @doc """
  Numeric multiplication.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-multiply>
  """
  def call(:*, [left, right]) do
    RDF.Numeric.multiply(left, right) || :error
  end

  @doc """
  Numeric division.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-divide>
  """
  def call(:/, [left, right]) do
    RDF.Numeric.divide(left, right) || :error
  end

  @doc """
  Checks if the given argument is an IRI.

  see <https://www.w3.org/TR/sparql11-query/#func-isIRI>
  """
  def call(:isIRI, [%RDF.IRI{}]), do: RDF.true
  def call(:isIRI, [:error]),     do: :error
  def call(:isIRI, _),            do: RDF.false

  @doc """
  Checks if the given argument is an IRI.

  see <https://www.w3.org/TR/sparql11-query/#func-isIRI>
  """
  def call(:isURI, args), do: call(:isIRI, args)

  @doc """
  Checks if the given argument is a blank node.

  see <https://www.w3.org/TR/sparql11-query/#func-isBlank>
  """
  def call(:isBLANK, [%RDF.BlankNode{}]), do: RDF.true
  def call(:isBLANK, [:error]),           do: :error
  def call(:isBLANK, _),                  do: RDF.false

  @doc """
  Checks if the given argument is a RDF literal.

  see <https://www.w3.org/TR/sparql11-query/#func-isLiteral>
  """
  def call(:isLITERAL, [%RDF.Literal{}]), do: RDF.true
  def call(:isLITERAL, [:error]),         do: :error
  def call(:isLITERAL, _),                do: RDF.false

  @doc """
  Checks if the given argument is a RDF literal with a numeric datatype.

  see <https://www.w3.org/TR/sparql11-query/#func-isNumeric>
  """
  def call(:isNUMERIC, [%RDF.Literal{datatype: datatype} = literal]) do
    if RDF.Numeric.type?(datatype) and RDF.Literal.valid?(literal) do
      RDF.true
    else
      RDF.false
    end
  end
  def call(:isNUMERIC, [:error]), do: :error
  def call(:isNUMERIC, _),        do: RDF.false

  @doc """
  Returns the lexical form of a literal or the codepoint representation of an IRI.

  It returns the empty string for all blank nodes, thereby following the behavior
  mentioned in [DuCharme2013, p. 156].

  see <https://www.w3.org/TR/sparql11-query/#func-str>
  """
  def call(:STR, [%RDF.Literal{} = literal]), do: literal |> to_string() |> RDF.string()
  def call(:STR, [%RDF.IRI{} = iri]),         do: iri |> to_string() |> RDF.string()
  def call(:STR, [%RDF.BlankNode{}]),         do: RDF.string("")
  def call(:STR, _),                          do: :error

  @doc """
  Returns the language tag of language tagged literal.

  It returns `~L""` if the given literal has no language tag. Note that the RDF
  data model does not include literals with an empty language tag.

  see <https://www.w3.org/TR/sparql11-query/#func-lang>
  """
  def call(:LANG, [%RDF.Literal{language: language}]), do: language |> to_string() |> RDF.string()
  def call(:LANG, [%RDF.Literal{}]),                   do: RDF.string("")
  def call(:LANG, _),                                  do: :error

  @doc """
  Returns the datatype IRI of a literal.

  see <https://www.w3.org/TR/sparql11-query/#func-datatype>
  """
  def call(:DATATYPE, [%RDF.Literal{datatype: datatype}]), do: datatype
  def call(:DATATYPE, _),                                  do: :error

  @doc """
  Constructs a literal with lexical form and type as specified by the arguments.

  see <https://www.w3.org/TR/sparql11-query/#func-strdt>
  """
  def call(:STRDT, [%RDF.Literal{} = literal, %RDF.IRI{} = datatype]) do
    RDF.Literal.new(to_string(literal), datatype: datatype)
  end
  def call(:STRDT, _), do: :error

  @doc """
  Constructs a literal with lexical form and language tag as specified by the arguments.

  see <https://www.w3.org/TR/sparql11-query/#func-strlang>
  """
  def call(:STRLANG, [%RDF.Literal{datatype: @xsd_string} = lexical_form_literal,
                      %RDF.Literal{datatype: @xsd_string} = language_literal]) do
    language = language_literal |> to_string() |> String.trim()
    if language != "" do
      RDF.LangString.new(to_string(lexical_form_literal), language: language)
    else
      :error
    end
  end
  def call(:STRLANG, _), do: :error

  @doc """
  Constructs an IRI from the given string argument.

  It constructs an IRI by resolving the string argument (see RFC 3986 and RFC 3987
  or any later RFC that superceeds RFC 3986 or RFC 3987). The IRI is resolved
  against the base IRI of the query and must result in an absolute IRI.

  see <https://www.w3.org/TR/sparql11-query/#func-iri>
  """
  def call(:IRI, [%RDF.Literal{datatype: @xsd_string} = literal]) do
    literal |> to_string() |> RDF.IRI.new()
  end
  def call(:IRI, [%RDF.IRI{} = iri]), do: iri
  def call(:IRI, _),                  do: :error

  @doc """
  Checks if the given argument is an IRI.

  Alias for `IRI`.

  see <https://www.w3.org/TR/sparql11-query/#func-isIRI>
  """
  def call(:URI, args), do: call(:IRI, args)

  @doc """
  Constructs a blank node.

  The constructed blank node is distinct from all blank nodes in the dataset
  being queried and distinct from all blank nodes created by calls to this
  constructor for other query solutions.

  If the no argument form is used, every call results in a distinct blank node.
  If the form with a simple literal is used, every call results in distinct
  blank nodes for different simple literals, and the same blank node for calls
  with the same simple literal within expressions for one solution mapping.

  see <https://www.w3.org/TR/sparql11-query/#func-bnode>
  """
  def call(:BNODE, []), do: RDF.bnode()
  def call(:BNODE, _), do: :error

  @doc """
  Return a fresh IRI from the UUID URN scheme.

  Each call of UUID() returns a different UUID.

  Currently, UUID v4 ids according to RFC 4122 are produced.

  see <https://www.w3.org/TR/sparql11-query/#func-uuid>
  """
  def call(:UUID, []), do: uuid(:urn) |> RDF.IRI.new()
  def call(:UUID, _),  do: :error

  @doc """
  Return a string literal that is the scheme specific part of UUID.

  Currently, UUID v4 ids according to RFC 4122 are produced.

  see <https://www.w3.org/TR/sparql11-query/#func-struuid>
  """
  def call(:STRUUID, []), do: uuid(:default) |> RDF.string()
  def call(:STRUUID, _),  do: :error

  @doc """
  Returns an `xsd:integer` equal to the length in characters of the lexical form of a literal.

  see <https://www.w3.org/TR/sparql11-query/#func-strlen>
  """
  def call(:STRLEN, [%RDF.Literal{datatype: datatype} = literal])
      when datatype in [@xsd_string, @lang_string],
      do: literal |> to_string() |> String.length() |> RDF.Integer.new()
  def call(:STRLEN, _), do: :error



  # TODO: This just a preliminary implementation
  def call(:UCASE, [literal]) do
    literal |> Literal.lexical() |> String.upcase() |> Literal.new()
  end


  @doc """
  Argument Compatibility Rules

  see <https://www.w3.org/TR/sparql11-query/#func-arg-compatibility>
  """
  def compatible_arguments?(left, right)

  # The arguments are simple literals or literals typed as xsd:string
  def compatible_arguments?(%RDF.Literal{datatype: @xsd_string},
                            %RDF.Literal{datatype: @xsd_string}), do: true
  # The first argument is a plain literal with language tag and the second argument is a simple literal or literal typed as xsd:string
  def compatible_arguments?(%RDF.Literal{datatype: @lang_string},
                            %RDF.Literal{datatype: @xsd_string}), do: true
  # The arguments are plain literals with identical language tags
  def compatible_arguments?(%RDF.Literal{datatype: @lang_string, language: language},
                            %RDF.Literal{datatype: @lang_string, language: language}), do: true

  def compatible_arguments?(_, _), do: false


  defp ebv(value),    do: Boolean.ebv(value) || :error
  defp fn_not(value), do: Boolean.fn_not(value) || :error

  defp uuid(format), do: UUID.uuid4(format)

end
