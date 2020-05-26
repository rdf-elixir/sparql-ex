defmodule SPARQL.Functions.Builtins do

  require Logger

  alias RDF.{IRI, BlankNode, Literal, XSD, NS}

  @doc """
  Value equality

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  - <https://www.w3.org/TR/sparql11-query/#func-RDFterm-equal>
  """
  def call(:=, [left, right], _) do
    left |> RDF.Term.equal_value?(right) |> ebv()
  end

  @doc """
  Value inequality

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  - <https://www.w3.org/TR/sparql11-query/#func-RDFterm-equal>
  """
  def call(:!=, [left, right], _) do
    left |> RDF.Term.equal_value?(right) |> fn_not()
  end

  @doc """
  `sameTerm` equality

  see <https://www.w3.org/TR/sparql11-query/#func-sameTerm>
  """
  def call(:sameTerm, [left, right], _) do
    left |> RDF.Term.equal?(right) |> ebv()
  end

  @doc """
  Less-than operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:<, [%Literal{} = left, %Literal{} = right], _) do
    case Literal.compare(left, right) do
      :lt -> true
      nil -> nil
      _ -> false
    end
    |> ebv()
  end

  def call(:<, _, _), do: :error

  @doc """
  Greater-than operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:>, [%Literal{} = left, %Literal{} = right], _) do
    case Literal.compare(left, right) do
      :gt -> true
      nil -> nil
      _ -> false
    end
    |> ebv()
  end

  def call(:>, _, _), do: :error

  @doc """
  Greater-or-equal operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:>=, [%Literal{} = left, %Literal{} = right], _) do
    case Literal.compare(left, right) do
      :gt -> XSD.true
      :eq -> XSD.true
      :lt -> XSD.false
      _   -> :error
    end
  end

  def call(:>=, _, _), do: :error

  @doc """
  Less-or-equal operator.

  see
  - <https://www.w3.org/TR/sparql11-query/#OperatorMapping>
  """
  def call(:<=, [%Literal{} = left, %Literal{} = right], _) do
    case Literal.compare(left, right) do
      :lt -> XSD.true
      :eq -> XSD.true
      :gt -> XSD.false
      _   -> :error
    end
  end

  def call(:<=, _, _), do: :error

  @doc """
  Logical `NOT`

  Returns `RDF.XSD.true` if the effective boolean value of the given argument is
  `RDF.XSD.false`, or `RDF.XSD.false` if it is `RDF.XSD.true`. Otherwise it returns `error`.

  see <http://www.w3.org/TR/xpath-functions/#func-not>
  """
  def call(:!, [argument], _) do
    fn_not(argument)
  end


  @doc """
  Numeric unary plus.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-unary-plus>
  """
  def call(:+, [number], _) do
    if XSD.Numeric.datatype?(number) do
      number
    else
      :error
    end
  end

  @doc """
  Numeric unary minus.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-unary-minus>
  """
  def call(:-, [number], _) do
    if XSD.Numeric.datatype?(number) do
      XSD.Numeric.multiply(number, -1)
    else
      :error
    end
  end

  @doc """
  Numeric addition.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-add>
  """
  def call(:+, [left, right], _) do
    XSD.Numeric.add(left, right) || :error
  end

  @doc """
  Numeric subtraction.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-subtract>
  """
  def call(:-, [left, right], _) do
    XSD.Numeric.subtract(left, right) || :error
  end

  @doc """
  Numeric multiplication.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-multiply>
  """
  def call(:*, [left, right], _) do
    XSD.Numeric.multiply(left, right) || :error
  end

  @doc """
  Numeric division.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-divide>
  """
  def call(:/, [left, right], _) do
    XSD.Numeric.divide(left, right) || :error
  end

  @doc """
  Checks if the given argument is an IRI.

  see <https://www.w3.org/TR/sparql11-query/#func-isIRI>
  """
  def call(:isIRI, [%IRI{}], _), do: XSD.true
  def call(:isIRI, [:error], _), do: :error
  def call(:isIRI, _, _),        do: XSD.false

  @doc """
  Checks if the given argument is an IRI.

  see <https://www.w3.org/TR/sparql11-query/#func-isIRI>
  """
  def call(:isURI, args, execution), do: call(:isIRI, args, execution)

  @doc """
  Checks if the given argument is a blank node.

  see <https://www.w3.org/TR/sparql11-query/#func-isBlank>
  """
  def call(:isBLANK, [%BlankNode{}], _), do: XSD.true
  def call(:isBLANK, [:error], _),       do: :error
  def call(:isBLANK, _, _),              do: XSD.false

  @doc """
  Checks if the given argument is a RDF literal.

  see <https://www.w3.org/TR/sparql11-query/#func-isLiteral>
  """
  def call(:isLITERAL, [%Literal{}], _), do: XSD.true
  def call(:isLITERAL, [:error], _),     do: :error
  def call(:isLITERAL, _, _),            do: XSD.false

  @doc """
  Checks if the given argument is a RDF literal with a numeric datatype.

  see <https://www.w3.org/TR/sparql11-query/#func-isNumeric>
  """
  def call(:isNUMERIC, [%Literal{} = literal], _) do
    if XSD.Numeric.datatype?(literal) and Literal.valid?(literal) do
      XSD.true
    else
      XSD.false
    end
  end
  def call(:isNUMERIC, [:error], _), do: :error
  def call(:isNUMERIC, _, _),        do: XSD.false

  @doc """
  Returns the lexical form of a literal or the codepoint representation of an IRI.

  see <https://www.w3.org/TR/sparql11-query/#func-str>
  """
  def call(:STR, [%Literal{} = literal], _), do: literal |> to_string() |> XSD.string()
  def call(:STR, [%IRI{} = iri], _),         do: iri     |> to_string() |> XSD.string()
  def call(:STR, _, _),                      do: :error

  @doc """
  Returns the language tag of language tagged literal.

  It returns `~L""` if the given literal has no language tag. Note that the RDF
  data model does not include literals with an empty language tag.

  see <https://www.w3.org/TR/sparql11-query/#func-lang>
  """
  def call(:LANG, [%Literal{} = literal], _),
    do: literal |> Literal.language() |> to_string() |> XSD.string()
  def call(:LANG, _, _), do: :error

  @doc """
  Returns the datatype IRI of a literal.

  see <https://www.w3.org/TR/sparql11-query/#func-datatype>
  """
  def call(:DATATYPE, [%Literal{} = literal], _), do: Literal.datatype_id(literal)
  def call(:DATATYPE, _, _),                          do: :error

  @doc """
  Constructs a literal with lexical form and type as specified by the arguments.

  see <https://www.w3.org/TR/sparql11-query/#func-strdt>
  """
  def call(:STRDT, [%Literal{literal: %XSD.String{}} = literal, %IRI{} = datatype], _) do
    literal |> Literal.lexical() |> Literal.new(datatype: datatype)
  end
  def call(:STRDT, _, _), do: :error

  @doc """
  Constructs a literal with lexical form and language tag as specified by the arguments.

  see <https://www.w3.org/TR/sparql11-query/#func-strlang>
  """
  def call(:STRLANG, [%Literal{literal: %XSD.String{}} = lexical_form_literal,
                      %Literal{literal: %XSD.String{}} = language_literal], _) do
    language = language_literal |> to_string() |> String.trim()
    if language != "" do
      RDF.LangString.new(to_string(lexical_form_literal), language: language)
    else
      :error
    end
  end
  def call(:STRLANG, _, _), do: :error

  @doc """
  Constructs an IRI from the given string argument.

  It constructs an IRI by resolving the string argument (see RFC 3986 and RFC 3987
  or any later RFC that supersedes RFC 3986 or RFC 3987). The IRI is resolved
  against the base IRI of the query and must result in an absolute IRI.

  see <https://www.w3.org/TR/sparql11-query/#func-iri>
  """
  def call(:IRI, [%Literal{literal: %XSD.String{}} = literal], execution) do
    literal |> to_string() |> IRI.absolute(Map.get(execution, :base)) || :error
  end
  def call(:IRI, [%IRI{} = iri], _), do: iri
  def call(:IRI, _, _),              do: :error

  @doc """
  Checks if the given argument is an IRI.

  Alias for `IRI`.

  see <https://www.w3.org/TR/sparql11-query/#func-isIRI>
  """
  def call(:URI, args, execution), do: call(:IRI, args, execution)

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
  def call(:BNODE, [], %{bnode_generator: generator}) do
    BlankNode.Generator.generate(generator)
  end

  def call(:BNODE, [%Literal{literal: %XSD.String{}} = literal],
        %{bnode_generator: generator, solution_id: solution_id}) do
    BlankNode.Generator.generate_for(generator, {solution_id, to_string(literal)})
  end

  def call(:BNODE, _, _), do: :error

  @doc """
  Return a fresh IRI from the UUID URN scheme.

  Each call of UUID() returns a different UUID.

  Currently, UUID v4 ids according to RFC 4122 are produced.

  see <https://www.w3.org/TR/sparql11-query/#func-uuid>
  """
  def call(:UUID, [], _), do: uuid(:urn) |> IRI.new()
  def call(:UUID, _, _),  do: :error

  @doc """
  Return a string literal that is the scheme specific part of UUID.

  Currently, UUID v4 ids according to RFC 4122 are produced.

  see <https://www.w3.org/TR/sparql11-query/#func-struuid>
  """
  def call(:STRUUID, [], _), do: uuid(:default) |> XSD.string()
  def call(:STRUUID, _, _),  do: :error

  @doc """
  Returns an `xsd:integer` equal to the length in characters of the lexical form of a literal.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strlen>
  - <http://www.w3.org/TR/xpath-functions/#func-string-length>
  """
  def call(:STRLEN, [%Literal{literal: %datatype{}} = literal], _)
      when datatype in [XSD.String, RDF.LangString],
      do: literal |> to_string() |> String.length() |> XSD.integer()
  def call(:STRLEN, _, _), do: :error

  @doc """
  Returns a portion of a string .

  The arguments startingLoc and length may be derived types of `xsd:integer`. The
  index of the first character in a strings is 1.

  Returns a literal of the same kind (simple literal, literal with language tag,
  xsd:string typed literal) as the source input parameter but with a lexical form
  formed from the substring of the lexical form of the source.

  The substr function corresponds to the XPath `fn:substring` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-substr>
  - <http://www.w3.org/TR/xpath-functions/#func-substring>
  """
  def call(:SUBSTR, [%Literal{literal: %source_datatype{}} = source, %Literal{} = starting_loc], _)
      when source_datatype in [XSD.String, RDF.LangString] do
    if XSD.Integer.valid?(starting_loc) do
      Literal.update(source, fn source_string ->
        String.slice(source_string, (XSD.Integer.value(starting_loc) - 1) .. -1)
      end)
    else
      :error
    end
  end

  def call(:SUBSTR, [%Literal{literal: %source_datatype{}} = source,
                     %Literal{} = starting_loc, %Literal{} = length], _)
      when source_datatype in [XSD.String, RDF.LangString] do
    if XSD.Integer.valid?(starting_loc) and XSD.Integer.valid?(length) do
      Literal.update(source, fn source_string ->
        String.slice(source_string, (XSD.Integer.value(starting_loc) - 1), XSD.Integer.value(length))
      end)
    else
      :error
    end
  end

  def call(:SUBSTR, _, _), do: :error

  @doc """
  Returns a string literal whose lexical form is the upper case of the lexcial form of the argument.

  The UCASE function corresponds to the XPath `fn:upper-case` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-ucase>
  - <http://www.w3.org/TR/xpath-functions/#func-upper-case>
  """
  def call(:UCASE, [%Literal{literal: %datatype{}} = str], _)
      when datatype in [XSD.String, RDF.LangString] do
    Literal.update(str, &String.upcase/1)
  end

  def call(:UCASE, _, _), do: :error

  @doc """
  Returns a string literal whose lexical form is the lower case of the lexcial form of the argument.

  The LCASE function corresponds to the XPath `fn:lower-case` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-lcase>
  - <http://www.w3.org/TR/xpath-functions/#func-lower-case>
  """
  def call(:LCASE, [%Literal{literal: %datatype{}} = str], _)
      when datatype in [XSD.String, RDF.LangString] do
    Literal.update(str, &String.downcase/1)
  end

  def call(:LCASE, _, _), do: :error

  @doc """
  Returns true if the lexical form of arg1 starts with the lexical form of arg2, otherwise it returns false.

  The STRSTARTS function corresponds to the XPath `fn:starts-with` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strstarts>
  - <http://www.w3.org/TR/xpath-functions/#func-starts-with>
  """
  def call(:STRSTARTS, [arg1, arg2], _) do
    if compatible_arguments?(arg1, arg2) do
      if arg1 |> to_string() |> String.starts_with?(to_string(arg2)) do
        XSD.true
      else
        XSD.false
      end
    else
      :error
    end
  end

  def call(:STRSTARTS, _, _), do: :error

  @doc """
  Returns true if the lexical form of arg1 ends with the lexical form of arg2, otherwise it returns false.

  The STRENDS function corresponds to the XPath `fn:ends-with` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strends>
  - <http://www.w3.org/TR/xpath-functions/#func-ends-with>
  """
  def call(:STRENDS, [arg1, arg2], _) do
    if compatible_arguments?(arg1, arg2) do
      if arg1 |> to_string() |> String.ends_with?(to_string(arg2)) do
        XSD.true
      else
        XSD.false
      end
    else
      :error
    end
  end

  def call(:STRENDS, _, _), do: :error

  @doc """
  Returns true if the lexical form of arg1 contains the lexical form of arg2, otherwise it returns false.

  The CONTAINS function corresponds to the XPath `fn:contains` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-contains>
  - <http://www.w3.org/TR/xpath-functions/#func-contains>
  """
  def call(:CONTAINS, [arg1, arg2], _) do
    if compatible_arguments?(arg1, arg2) do
      if arg1 |> to_string() |> String.contains?(to_string(arg2)) do
        XSD.true
      else
        XSD.false
      end
    else
      :error
    end
  end

  def call(:CONTAINS, _, _), do: :error

  @doc """
  Returns the substring of the lexical form of arg1 that precedes the first occurrence of the lexical form of arg2.

  The STRBEFORE function corresponds to the XPath `fn:substring-before` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  For compatible arguments, if the lexical part of the second argument occurs as
  a substring of the lexical part of the first argument, the function returns a
  literal of the same kind as the first argument arg1 (simple literal, plain
  literal same language tag, xsd:string). The lexical form of the result is the
  substring of the lexical form of arg1 that precedes the first occurrence of
  the lexical form of arg2. If the lexical form of arg2 is the empty string,
  this is considered to be a match and the lexical form of the result is the
  empty string.

  If there is no such occurrence, an empty simple literal is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strbefore>
  - <http://www.w3.org/TR/xpath-functions/#func-substring-before>
  """
  def call(:STRBEFORE, [arg1, arg2], _) do
    cond do
      not compatible_arguments?(arg1, arg2) -> :error
      Literal.lexical(arg2) == ""           -> Literal.update(arg1, fn _ -> "" end)
      true ->
        case String.split(Literal.lexical(arg1), Literal.lexical(arg2), parts: 2) do
          [left, _] -> Literal.update(arg1, fn _ -> left end)
          [_]       -> Literal.new("")
        end
    end
  end

  def call(:STRBEFORE, _, _), do: :error

  @doc """
  Returns the substring of the lexical form of arg1 that follows the first occurrence of the lexical form of arg2.

  The STRAFTER function corresponds to the XPath `fn:substring-before` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  For compatible arguments, if the lexical part of the second argument occurs as
  a substring of the lexical part of the first argument, the function returns a
  literal of the same kind as the first argument arg1 (simple literal, plain
  literal same language tag, xsd:string). The lexical form of the result is the
  substring of the lexical form of arg1 that precedes the first occurrence of
  the lexical form of arg2. If the lexical form of arg2 is the empty string,
  this is considered to be a match and the lexical form of the result is the
  lexical form of arg1.

  If there is no such occurrence, an empty simple literal is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strafter>
  - <http://www.w3.org/TR/xpath-functions/#func-substring-after>
  """
  def call(:STRAFTER, [arg1, arg2], _) do
    cond do
      not compatible_arguments?(arg1, arg2) -> :error
      Literal.lexical(arg2) == ""           -> arg1
      true ->
        case String.split(Literal.lexical(arg1), Literal.lexical(arg2), parts: 2) do
          [_, right] -> Literal.update(arg1, fn _ -> right end)
          [_]        -> Literal.new("")
        end
    end
  end

  def call(:STRAFTER, _, _), do: :error

  @doc """
  Returns a simple literal with the lexical form obtained from the lexical form of its input after translating reserved characters according to the fn:encode-for-uri function.

  The ENCODE_FOR_URI function corresponds to the XPath `fn:encode-for-uri` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-encode>
  - <http://www.w3.org/TR/xpath-functions/#func-encode-for-uri>
  """
  def call(:ENCODE_FOR_URI, [%Literal{literal: %datatype{}} = str], _)
      when datatype in [XSD.String, RDF.LangString] do
    str
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
    |> Literal.new()
  end

  def call(:ENCODE_FOR_URI, _, _), do: :error

  @doc """
  Returns a string literal with the lexical form being obtained by concatenating the lexical forms of its inputs.

  If all input literals are typed literals of type `xsd:string`, then the returned
  literal is also of type `xsd:string`, if all input literals are plain literals
  with identical language tag, then the returned literal is a plain literal with
  the same language tag, in all other cases, the returned literal is a simple literal.

  The CONCAT function corresponds to the XPath `fn:concat` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-concat>
  - <http://www.w3.org/TR/xpath-functions/#func-concat>
  """
  def call(:CONCAT, [], _), do: XSD.string("")
  def call(:CONCAT, [%Literal{literal: %datatype{}} = first |rest], _)
      when datatype in [XSD.String, RDF.LangString] do
    rest
    |> Enum.reduce_while({to_string(first), Literal.language(first)}, fn
         %Literal{literal: %datatype{}} = str, {acc, language}
               when datatype in [XSD.String, RDF.LangString] ->
           {:cont, {
               acc <> to_string(str),
               if language && language == Literal.language(str) do
                 language
               else
                 nil
               end
             }
           }
         _, _ ->
           {:halt, :error}
       end)
    |> case do
         {str, nil}      -> XSD.string(str)
         {str, language} -> RDF.lang_string(str, language: language)
         _               -> :error
       end
  end

  def call(:CONCAT, _, _), do: :error

  @doc """
  Checks if a language tagged string literal or language tag matches a language range.

  The check is performed per the basic filtering scheme defined in
  [RFC4647](http://www.ietf.org/rfc/rfc4647.txt) section 3.3.1.
  A language range is a basic language range per _Matching of Language Tags_ in
  RFC4647 section 2.1.
  A language range of `"*"` matches any non-empty language-tag string.

  see <https://www.w3.org/TR/sparql11-query/#func-langMatches>
  """
  def call(:LANGMATCHES, [%Literal{literal: %XSD.String{value: language_tag}},
                          %Literal{literal: %XSD.String{value: language_range}}], _) do
    if RDF.LangString.match_language?(language_tag, language_range) do
      XSD.true
    else
      XSD.false
    end
  end

  def call(:LANGMATCHES, _, _), do: :error

  @doc """
  Matches text against a regular expression pattern.

  The regular expression language is defined in _XQuery 1.0 and XPath 2.0 Functions and Operators_.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-regex>
  - <https://www.w3.org/TR/xpath-functions/#func-matches>
  """
  def call(:REGEX, [text, pattern], _),        do: match_regex(text, pattern, XSD.string(""))
  def call(:REGEX, [text, pattern, flags], _), do: match_regex(text, pattern, flags)
  def call(:REGEX, _, _),                      do: :error

  @doc """
  Replaces each non-overlapping occurrence of the regular expression pattern with the replacement string.

  Regular expression matching may involve modifier flags. See REGEX.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-replace>
  - <http://www.w3.org/TR/xpath-functions/#func-replace>
  """
  def call(:REPLACE, [text, pattern, replacement], _),
    do: replace_regex(text, pattern, replacement, XSD.string(""))
  def call(:REPLACE, [text, pattern, replacement, flags], _),
    do: replace_regex(text, pattern, replacement, flags)
  def call(:REPLACE, _, _), do: :error

  @doc """
  Returns the absolute value of the argument.

  If the argument is not a numeric value `:error` is returned.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-abs>
  - <http://www.w3.org/TR/xpath-functions/#func-abs>
  """
  def call(:ABS, [%Literal{} = literal], _) do
    XSD.Numeric.abs(literal) || :error
  end

  def call(:ABS, _, _), do: :error

  @doc """
  Rounds a value to a specified number of decimal places, rounding upwards if two such values are equally near.

  The function returns the nearest (that is, numerically closest) value to the
  given literal value that is a multiple of ten to the power of minus `precision`.
  If two such values are equally near (for example, if the fractional part in the
  literal value is exactly .5), the function returns the one that is closest to
  positive infinity.

  If the argument is not a numeric value `:error` is returned.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-round>
  - <http://www.w3.org/TR/xpath-functions/#func-round>
  """
  def call(:ROUND, [%Literal{} = literal], _) do
    XSD.Numeric.round(literal) || :error
  end

  def call(:ROUND, _, _), do: :error

  @doc """
  Rounds a numeric value upwards to a whole number.

  If the argument is not a numeric value `:error` is returned.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-ceil>
  - <http://www.w3.org/TR/xpath-functions/#func-ceil>
  """
  def call(:CEIL, [%Literal{} = literal], _) do
    XSD.Numeric.ceil(literal) || :error
  end

  def call(:CEIL, _, _), do: :error

  @doc """
  Rounds a numeric value downwards to a whole number.

  If the argument is not a numeric value `:error` is returned.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-floor>
  - <http://www.w3.org/TR/xpath-functions/#func-floor>
  """
  def call(:FLOOR, [%Literal{} = literal], _) do
    XSD.Numeric.floor(literal) || :error
  end

  def call(:FLOOR, _, _), do: :error

  @doc """
  Returns a pseudo-random number between 0 (inclusive) and 1.0e0 (exclusive).

  see <https://www.w3.org/TR/sparql11-query/#idp2130040>
  """
  def call(:RAND, [], _) do
    :rand.uniform() |> XSD.double()
  end

  def call(:RAND, _, _), do: :error

  @doc """
  Returns an XSD dateTime value for the current query execution.

  All calls to this function in any one query execution return the same value.

  see <https://www.w3.org/TR/sparql11-query/#func-now>
  """
  def call(:NOW, [], %{time: time}) do
    XSD.date_time(time)
  end

  def call(:NOW, _, _), do: :error

  @doc """
  Returns the year part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-year>
  - <https://www.w3.org/TR/xpath-functions/#func-year-from-dateTime>
  """
  def call(:YEAR, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    naive_datetime_part(literal, :year)
  end

  def call(:YEAR, _, _), do: :error

  @doc """
  Returns the month part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-month>
  - <https://www.w3.org/TR/xpath-functions/#func-month-from-dateTime>
  """
  def call(:MONTH, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    naive_datetime_part(literal, :month)
  end

  def call(:MONTH, _, _), do: :error

  @doc """
  Returns the day part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-day>
  - <https://www.w3.org/TR/xpath-functions/#func-day-from-dateTime>
  """
  def call(:DAY, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    naive_datetime_part(literal, :day)
  end

  def call(:DAY, _, _), do: :error

  @doc """
  Returns the hours part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-hours>
  - <https://www.w3.org/TR/xpath-functions/#func-hours-from-dateTime>
  """
  def call(:HOURS, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    naive_datetime_part(literal, :hour)
  end

  def call(:HOURS, _, _), do: :error

  @doc """
  Returns the minutes part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-minutes>
  - <https://www.w3.org/TR/xpath-functions/#func-minutes-from-dateTime>
  """
  def call(:MINUTES, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    naive_datetime_part(literal, :minute)
  end

  def call(:MINUTES, _, _), do: :error

  @doc """
  Returns the seconds part of the given datetime as a decimal.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-seconds>
  - <https://www.w3.org/TR/xpath-functions/#func-seconds-from-dateTime>
  """
  def call(:SECONDS, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    if XSD.DateTime.valid?(literal) do
      case literal.value.microsecond do
        {_, 0} ->
          literal.value.second
          |> to_string() # This is needed to get the lexical integer form; required for the SPARQL 1.1 test suite
          |> XSD.decimal()

        {microsecond, _} ->
          %Decimal{coef: microsecond, exp: -6}
          |> Decimal.add(literal.value.second)
          |> XSD.decimal()

        _ ->
          :error
      end
    else
      :error
    end
  end

  def call(:SECONDS, _, _), do: :error

  @doc """
  Returns the timezone part of the given datetime as an `xsd:dayTimeDuration` literal.

  Returns `:error` if there is no timezone.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-timezone>
  - <http://www.w3.org/TR/xpath-functions/#func-timezone-from-dateTime>
  """
  def call(:TIMEZONE, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    literal
    |> XSD.DateTime.tz()
    |> tz_duration()
    || :error
  end

  def call(:TIMEZONE, _, _), do: :error

  @doc """
  Returns the timezone part of a given datetime as a simple literal.

  Returns the empty string if there is no timezone.

  see <https://www.w3.org/TR/sparql11-query/#func-tz>
  """
  def call(:TZ, [%Literal{literal: %XSD.DateTime{} = literal}], _) do
    if tz = XSD.DateTime.tz(literal) do
      XSD.string(tz)
    else
      :error
    end
  end

  def call(:TZ, _, _), do: :error

  @doc """
  Returns the MD5 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-md5>
  """
  def call(:MD5, [%Literal{literal: %XSD.String{}} = literal], _) do
    hash(:md5, Literal.value(literal))
  end

  def call(:MD5, _, _), do: :error

  @doc """
  Returns the SHA1 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-sha1>
  """
  def call(:SHA1, [%Literal{literal: %XSD.String{}} = literal], _) do
    hash(:sha, Literal.value(literal))
  end

  def call(:SHA1, _, _), do: :error

  @doc """
  Returns the SHA256 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-sha256>
  """
  def call(:SHA256, [%Literal{literal: %XSD.String{}} = literal], _) do
    hash(:sha256, Literal.value(literal))
  end

  def call(:SHA256, _, _), do: :error

  @doc """
  Returns the SHA384 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#fun  c-sha384>
  """
  def call(:SHA384, [%Literal{literal: %XSD.String{}} = literal], _) do
    hash(:sha384, Literal.value(literal))
  end

  def call(:SHA384, _, _), do: :error

  @doc """
  Returns the SHA512 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-sha512>
  """
  def call(:SHA512, [%Literal{literal: %XSD.String{}} = literal], _) do
    hash(:sha512, Literal.value(literal))
  end

  def call(:SHA512, _, _), do: :error

  defp hash(type, value) do
    :crypto.hash(type, value)
    |> Base.encode16()
    |> String.downcase()
    |> XSD.string()
  end

  defp match_regex(%Literal{literal: %datatype{}} = text,
                   %Literal{literal: %XSD.String{}} = pattern,
                   %Literal{literal: %XSD.String{}} = flags)
       when datatype in [XSD.String, RDF.LangString] do
    text
    |> Literal.matches?(pattern, flags)
    |> ebv()
  rescue
    _error -> :error
  end

  defp match_regex(_, _, _), do: :error

  defp replace_regex(%Literal{literal: %datatype{}} = text,
                     %Literal{literal: %XSD.String{} = pattern},
                     %Literal{literal: %XSD.String{} = replacement},
                     %Literal{literal: %XSD.String{} = flags})
       when datatype in [XSD.String, RDF.LangString] do
    case XSD.Utils.Regex.xpath_pattern(pattern.value, flags.value) do
      {:regex, regex} ->
        Literal.update(text, fn text_value ->
          String.replace(text_value, regex, xpath_to_erlang_regex_variables(replacement.value))
        end)

      {:q, pattern} ->
        Literal.update(text, fn text_value ->
          String.replace(text_value, pattern, replacement.value)
        end)

      {:qi, _pattern} ->
        Logger.error "The combination of the q and the i flag is currently not supported in REPLACE"
        :error

      _ ->
        :error
    end
  end

  defp replace_regex(_, _, _, _), do: :error

  defp xpath_to_erlang_regex_variables(text) do
    String.replace(text, ~r/(?<!\\)\$/, "\\")
  end


  defp naive_datetime_part(%XSD.DateTime{value: %DateTime{} = datetime,
                                         uncanonical_lexical: nil}, field) do
    datetime
    |> Map.get(field)
    |> XSD.integer()
  end

  defp naive_datetime_part(%XSD.DateTime{value: %NaiveDateTime{} = datetime}, field) do
    datetime
    |> Map.get(field)
    |> XSD.integer()
  end

  defp naive_datetime_part(literal, field) do
    with {:ok, datetime} <-
           literal
           |> XSD.DateTime.lexical()
           |> NaiveDateTime.from_iso8601()
    do
      datetime
      |> Map.get(field)
      |> XSD.integer()
    else
      _ -> :error
    end
  end

  defp tz_duration(""),  do: nil
  defp tz_duration("Z"), do: day_time_duration("PT0S")
  defp tz_duration(tz) do
    [_, sign, hours, minutes] = Regex.run(~r/\A(?:([\+\-])(\d{2}):(\d{2}))\Z/, tz)
    sign = if sign == "-", do: "-", else: ""
    hours = String.trim_leading(hours, "0") <> "H"
    minutes = if minutes != "00", do: (minutes <> "M"), else: ""

    day_time_duration(sign <> "PT" <> hours <> minutes)
  end

  # TODO: This is just a preliminary implementation until we have a proper XSD.Duration datatype
  defp day_time_duration(value) do
    Literal.new(value, datatype: NS.XSD.dayTimeDuration)
  end

  @doc """
  Argument Compatibility Rules

  see <https://www.w3.org/TR/sparql11-query/#func-arg-compatibility>
  """
  def compatible_arguments?(arg1, arg2)

  # The arguments are simple literals or literals typed as xsd:string
  def compatible_arguments?(%Literal{literal: %XSD.String{}},
                            %Literal{literal: %XSD.String{}}), do: true
  # The first argument is a plain literal with language tag and the second argument is a simple literal or literal typed as xsd:string
  def compatible_arguments?(%Literal{literal: %RDF.LangString{}},
                            %Literal{literal: %XSD.String{}}), do: true
  # The arguments are plain literals with identical language tags
  def compatible_arguments?(%Literal{literal: %RDF.LangString{language: language}},
                            %Literal{literal: %RDF.LangString{language: language}}), do: true

  def compatible_arguments?(_, _), do: false


  defp ebv(value),    do: XSD.Boolean.ebv(value) || :error
  defp fn_not(value), do: XSD.Boolean.fn_not(value) || :error

  defp uuid(format), do: UUID.uuid4(format)

end
