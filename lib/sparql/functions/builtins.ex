defmodule SPARQL.Functions.Builtins do

  alias RDF.{Literal, Boolean}
  alias RDF.NS.XSD

  @xsd_string XSD.string

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
  def call(:isBlank, [%RDF.BlankNode{}]), do: RDF.true
  def call(:isBlank, [:error]),           do: :error
  def call(:isBlank, _),                  do: RDF.false

  @doc """
  Checks if the given argument is a RDF literal.

  see <https://www.w3.org/TR/sparql11-query/#func-isLiteral>
  """
  def call(:isLiteral, [%RDF.Literal{}]), do: RDF.true
  def call(:isLiteral, [:error]),         do: :error
  def call(:isLiteral, _),                do: RDF.false

  @doc """
  Checks if the given argument is a RDF literal with a numeric datatype.

  see <https://www.w3.org/TR/sparql11-query/#func-isNumeric>
  """
  def call(:isNumeric, [%RDF.Literal{datatype: datatype} = literal]) do
    if RDF.Numeric.type?(datatype) and RDF.Literal.valid?(literal) do
      RDF.true
    else
      RDF.false
    end
  end
  def call(:isNumeric, [:error]),         do: :error
  def call(:isNumeric, _),                do: RDF.false

  @doc """
  Returns the lexical form of a literal or the codepoint representation of an IRI.

  It returns the empty string for all blank nodes, thereby following the behavior
  mentioned in [DuCharme2013, p. 156].

  see <https://www.w3.org/TR/sparql11-query/#func-str>
  """
  def call(:str, [%RDF.Literal{} = literal]), do: literal |> to_string() |> RDF.string()
  def call(:str, [%RDF.IRI{} = iri]),         do: iri |> to_string() |> RDF.string()
  def call(:str, [%RDF.BlankNode{}]),         do: RDF.string("")
  def call(:str, _),                          do: :error

  @doc """
  Returns the language tag of language tagged literal.

  It returns `~L""` if the given literal has no language tag. Note that the RDF
  data model does not include literals with an empty language tag.

  see <https://www.w3.org/TR/sparql11-query/#func-lang>
  """
  def call(:lang, [%RDF.Literal{language: language}]), do: language |> to_string() |> RDF.string()
  def call(:lang, [%RDF.Literal{}]),                   do: RDF.string("")
  def call(:lang, _),                                  do: :error

  @doc """
  Returns the datatype IRI of a literal.

  see <https://www.w3.org/TR/sparql11-query/#func-datatype>
  """
  def call(:datatype, [%RDF.Literal{datatype: datatype}]), do: datatype
  def call(:datatype, _),                                  do: :error

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


  # TODO: This just a preliminary implementation
  def call(:STR, [literal]) do
    literal |> Literal.lexical() |> Literal.new()
  end

  # TODO: This just a preliminary implementation
  def call(:UCASE, [literal]) do
    literal |> Literal.lexical() |> String.upcase() |> Literal.new()
  end

  defp ebv(value),    do: Boolean.ebv(value) || :error
  defp fn_not(value), do: Boolean.fn_not(value) || :error


end
