defmodule SPARQL.Functions.Builtins do

  require Logger

  alias RDF.{Literal, Boolean}
  alias RDF.NS.XSD

  @xsd_string XSD.string
  @lang_string RDF.langString
  @xsd_integer XSD.integer
  @xsd_datetime XSD.dateTime

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
  Numeric unary plus.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-unary-plus>
  """
  def call(:+, [number]) do
    if RDF.Numeric.literal?(number) do
      number
    else
      :error
    end
  end

  @doc """
  Numeric unary minus.

  see <http://www.w3.org/TR/xpath-functions/#func-numeric-unary-minus>
  """
  def call(:-, [number]) do
    if RDF.Numeric.literal?(number) do
      RDF.Numeric.multiply(number, RDF.integer(-1))
    else
      :error
    end
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

  see <https://www.w3.org/TR/sparql11-query/#func-str>
  """
  def call(:STR, [%RDF.Literal{} = literal]), do: literal |> to_string() |> RDF.string()
  def call(:STR, [%RDF.IRI{} = iri]),         do: iri     |> to_string() |> RDF.string()
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
  def call(:STRDT, [%RDF.Literal{datatype: @xsd_string} = literal, %RDF.IRI{} = datatype]) do
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

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strlen>
  - <http://www.w3.org/TR/xpath-functions/#func-string-length>
  """
  def call(:STRLEN, [%RDF.Literal{datatype: datatype} = literal])
      when datatype in [@xsd_string, @lang_string],
      do: literal |> to_string() |> String.length() |> RDF.Integer.new()
  def call(:STRLEN, _), do: :error

  @doc """
  Returns a portion of a string .

  The arguments startingLoc and length may be derived types of `xsd:integer`. The
  index of the first character in a strings is 1.

  Returns a literal of the same kind (simple literal, literal with language tag,
  xsd:string typed literal) as the source input parameter but with a lexical form
  formed from the substring of the lexcial form of the source.

  The substr function corresponds to the XPath `fn:substring` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-substr>
  - <http://www.w3.org/TR/xpath-functions/#func-substring>
  """
  def call(:SUBSTR, [%RDF.Literal{datatype: datatype} = source,
                     %RDF.Literal{datatype: @xsd_integer} = starting_loc])
      when datatype in [@xsd_string, @lang_string] do
    %RDF.Literal{source |
      value:
        source
        |> to_string()
        |> String.slice((starting_loc.value - 1) .. -1)
    }
  end

  def call(:SUBSTR, [%RDF.Literal{datatype: datatype} = source,
                     %RDF.Literal{datatype: @xsd_integer} = starting_loc,
                     %RDF.Literal{datatype: @xsd_integer} = length])
      when datatype in [@xsd_string, @lang_string] do
    %RDF.Literal{source |
      value:
        source
        |> to_string()
        |> String.slice((starting_loc.value - 1), length.value)
    }
  end

  def call(:SUBSTR, _), do: :error

  @doc """
  Returns a string literal whose lexical form is the upper case of the lexcial form of the argument.

  The UCASE function corresponds to the XPath `fn:upper-case` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-ucase>
  - <http://www.w3.org/TR/xpath-functions/#func-upper-case>
  """
  def call(:UCASE, [%RDF.Literal{datatype: datatype} = str])
      when datatype in [@xsd_string, @lang_string] do
    %RDF.Literal{str | value: str |> to_string() |> String.upcase()}
  end

  def call(:UCASE, _), do: :error

  @doc """
  Returns a string literal whose lexical form is the lower case of the lexcial form of the argument.

  The LCASE function corresponds to the XPath `fn:lower-case` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-lcase>
  - <http://www.w3.org/TR/xpath-functions/#func-lower-case>
  """
  def call(:LCASE, [%RDF.Literal{datatype: datatype} = str])
      when datatype in [@xsd_string, @lang_string] do
    %RDF.Literal{str | value: str |> to_string() |> String.downcase()}
  end

  def call(:LCASE, _), do: :error

  @doc """
  Returns true if the lexical form of arg1 starts with the lexical form of arg2, otherwise it returns false.

  The STRSTARTS function corresponds to the XPath `fn:starts-with` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strstarts>
  - <http://www.w3.org/TR/xpath-functions/#func-starts-with>
  """
  def call(:STRSTARTS, [arg1, arg2]) do
    if compatible_arguments?(arg1, arg2) do
      if arg1 |> to_string() |> String.starts_with?(to_string(arg2)) do
        RDF.true
      else
        RDF.false
      end
    else
      :error
    end
  end

  def call(:STRSTARTS, _), do: :error

  @doc """
  Returns true if the lexical form of arg1 ends with the lexical form of arg2, otherwise it returns false.

  The STRENDS function corresponds to the XPath `fn:ends-with` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-strends>
  - <http://www.w3.org/TR/xpath-functions/#func-ends-with>
  """
  def call(:STRENDS, [arg1, arg2]) do
    if compatible_arguments?(arg1, arg2) do
      if arg1 |> to_string() |> String.ends_with?(to_string(arg2)) do
        RDF.true
      else
        RDF.false
      end
    else
      :error
    end
  end

  def call(:STRENDS, _), do: :error

  @doc """
  Returns true if the lexical form of arg1 contains the lexical form of arg2, otherwise it returns false.

  The CONTAINS function corresponds to the XPath `fn:contains` function.

  The arguments must be `compatible_arguments?/2` otherwise `:error` is returned.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-contains>
  - <http://www.w3.org/TR/xpath-functions/#func-contains>
  """
  def call(:CONTAINS, [arg1, arg2]) do
    if compatible_arguments?(arg1, arg2) do
      if arg1 |> to_string() |> String.contains?(to_string(arg2)) do
        RDF.true
      else
        RDF.false
      end
    else
      :error
    end
  end

  def call(:CONTAINS, _), do: :error

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
  def call(:STRBEFORE, [arg1, arg2]) do
    cond do
      not compatible_arguments?(arg1, arg2) ->  :error
      arg2.value == ""                      -> %RDF.Literal{arg1 | value: ""}
      true ->
        case String.split(arg1.value, arg2.value, parts: 2) do
          [left, _] -> %RDF.Literal{arg1 | value: left}
          [_]       -> RDF.Literal.new("")
        end
    end
  end

  def call(:STRBEFORE, _), do: :error

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
  def call(:STRAFTER, [arg1, arg2]) do
    cond do
      not compatible_arguments?(arg1, arg2) ->  :error
      arg2.value == ""                      -> arg1
      true ->
        case String.split(arg1.value, arg2.value, parts: 2) do
          [_, right] -> %RDF.Literal{arg1 | value: right}
          [_]        -> RDF.Literal.new("")
        end
    end
  end

  def call(:STRAFTER, _), do: :error

  @doc """
  Returns a simple literal with the lexical form obtained from the lexical form of its input after translating reserved characters according to the fn:encode-for-uri function.

  The ENCODE_FOR_URI function corresponds to the XPath `fn:encode-for-uri` function.

  see:
  - <https://www.w3.org/TR/sparql11-query/#func-encode>
  - <http://www.w3.org/TR/xpath-functions/#func-encode-for-uri>
  """
  def call(:ENCODE_FOR_URI, [%RDF.Literal{datatype: datatype} = str])
      when datatype in [@xsd_string, @lang_string] do
    str
    |> to_string()
    |> URI.encode(&URI.char_unreserved?/1)
    |> RDF.Literal.new()
  end

  def call(:ENCODE_FOR_URI, _), do: :error

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
  def call(:CONCAT, []), do: RDF.string("")
  def call(:CONCAT, [%RDF.Literal{datatype: datatype} = first |rest])
      when datatype in [@xsd_string, @lang_string] do
    rest
    |> Enum.reduce_while({to_string(first), first.language}, fn
         %RDF.Literal{datatype: datatype} = str, {acc, language}
               when datatype in [@xsd_string, @lang_string] ->
           {:cont, {
               acc <> to_string(str),
               if language && language == str.language do
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
         {str, nil}      -> RDF.string(str)
         {str, language} -> RDF.lang_string(str, language: language)
         _               -> :error
       end
  end

  def call(:CONCAT, _), do: :error

  @doc """
  Checks if a language tagged string literal or language tag matches a language range.

  The check is performed per the basic filtering scheme defined in
  [RFC4647](http://www.ietf.org/rfc/rfc4647.txt) section 3.3.1.
  A language range is a basic language range per _Matching of Language Tags_ in
  RFC4647 section 2.1.
  A language range of `"*"` matches any non-empty language-tag string.

  see <https://www.w3.org/TR/sparql11-query/#func-langMatches>
  """
  def call(:LANGMATCHES, [%RDF.Literal{datatype: @xsd_string} = language_tag,
    %RDF.Literal{datatype: @xsd_string} = language_range]) do
    if RDF.LangString.match_language?(language_tag.value, language_range.value) do
      RDF.true
    else
      RDF.false
    end
  end

  def call(:LANGMATCHES, _), do: :error

  @doc """
  Matches text against a regular expression pattern.

  The regular expression language is defined in _XQuery 1.0 and XPath 2.0 Functions and Operators_.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-regex>
  - <https://www.w3.org/TR/xpath-functions/#func-matches>
  """
  def call(:REGEX, [text, pattern]),        do: match_regex(text, pattern, RDF.string(""))
  def call(:REGEX, [text, pattern, flags]), do: match_regex(text, pattern, flags)
  def call(:REGEX, _),                      do: :error

  @doc """
  Replaces each non-overlapping occurrence of the regular expression pattern with the replacement string.

  Regular expession matching may involve modifier flags. See REGEX.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-replace>
  - <http://www.w3.org/TR/xpath-functions/#func-replace>
  """
  def call(:REPLACE, [text, pattern, replacement]),
    do: replace_regex(text, pattern, replacement, RDF.string(""))
  def call(:REPLACE, [text, pattern, replacement, flags]),
    do: replace_regex(text, pattern, replacement, flags)
  def call(:REPLACE, _), do: :error

  @doc """
  Returns the absolute value of the argument.

  If the argument is not a numeric value `:error` is returned.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-abs>
  - <http://www.w3.org/TR/xpath-functions/#func-abs>
  """
  def call(:ABS, [%RDF.Literal{} = literal]) do
    RDF.Numeric.abs(literal) || :error
  end

  def call(:ABS, _), do: :error

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
  def call(:ROUND, [%RDF.Literal{} = literal]) do
    RDF.Numeric.round(literal) || :error
  end

  def call(:ROUND, _), do: :error

  @doc """
  Rounds a numeric value upwards to a whole number.

  If the argument is not a numeric value `:error` is returned.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-ceil>
  - <http://www.w3.org/TR/xpath-functions/#func-ceil>
  """
  def call(:CEIL, [%RDF.Literal{} = literal]) do
    RDF.Numeric.ceil(literal) || :error
  end

  def call(:CEIL, _), do: :error

  @doc """
  Rounds a numeric value downwards to a whole number.

  If the argument is not a numeric value `:error` is returned.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-floor>
  - <http://www.w3.org/TR/xpath-functions/#func-floor>
  """
  def call(:FLOOR, [%RDF.Literal{} = literal]) do
    RDF.Numeric.floor(literal) || :error
  end

  def call(:FLOOR, _), do: :error

  @doc """
  Returns a pseudo-random number between 0 (inclusive) and 1.0e0 (exclusive).

  see <https://www.w3.org/TR/sparql11-query/#idp2130040>
  """
  def call(:RAND, []) do
    :rand.uniform() |> RDF.Double.new()
  end

  def call(:RAND, _), do: :error

  @doc """
  Returns the year part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-year>
  - <https://www.w3.org/TR/xpath-functions/#func-year-from-dateTime>
  """
  def call(:YEAR, [%RDF.Literal{datatype: @xsd_datetime} = literal]) do
    naive_datetime_part(literal, :year)
  end

  def call(:YEAR, _), do: :error

  @doc """
  Returns the month part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-month>
  - <https://www.w3.org/TR/xpath-functions/#func-month-from-dateTime>
  """
  def call(:MONTH, [%RDF.Literal{datatype: @xsd_datetime} = literal]) do
    naive_datetime_part(literal, :month)
  end

  def call(:MONTH, _), do: :error

  @doc """
  Returns the day part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-day>
  - <https://www.w3.org/TR/xpath-functions/#func-day-from-dateTime>
  """
  def call(:DAY, [%RDF.Literal{datatype: @xsd_datetime} = literal]) do
    naive_datetime_part(literal, :day)
  end

  def call(:DAY, _), do: :error

  @doc """
  Returns the hours part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-hours>
  - <https://www.w3.org/TR/xpath-functions/#func-hours-from-dateTime>
  """
  def call(:HOURS, [%RDF.Literal{datatype: @xsd_datetime} = literal]) do
    naive_datetime_part(literal, :hour)
  end

  def call(:HOURS, _), do: :error

  @doc """
  Returns the minutes part of the given datetime as an integer.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-minutes>
  - <https://www.w3.org/TR/xpath-functions/#func-minutes-from-dateTime>
  """
  def call(:MINUTES, [%RDF.Literal{datatype: @xsd_datetime} = literal]) do
    naive_datetime_part(literal, :minute)
  end

  def call(:MINUTES, _), do: :error

  @doc """
  Returns the seconds part of the given datetime as a decimal.

  see
  - <https://www.w3.org/TR/sparql11-query/#func-seconds>
  - <https://www.w3.org/TR/xpath-functions/#func-seconds-from-dateTime>
  """
  def call(:SECONDS, [%RDF.Literal{datatype: @xsd_datetime} = literal]) do
    if RDF.DateTime.valid?(literal) do
      case literal.value.microsecond do
        {_, 0} ->
          literal.value.second
          |> to_string() # This is needed to get the lexical integer form; required for the SPARQL 1.1 test suite
          |> RDF.decimal()

        {microsecond, _} ->
          %Decimal{coef: microsecond, exp: -6}
          |> Decimal.add(literal.value.second)
          |> RDF.decimal()

        _ ->
          :error
      end
    else
      :error
    end
  end

  def call(:SECONDS, _), do: :error

  @doc """
  Returns the timezone part of a given datetime as a simple literal.

  Returns the empty string if there is no timezone.

  see <https://www.w3.org/TR/sparql11-query/#func-tz>
  """
  def call(:TZ, [%RDF.Literal{datatype: @xsd_datetime} = literal]) do
    if tz = RDF.DateTime.tz(literal) do
      RDF.string(tz)
    else
      :error
    end
  end

  def call(:TZ, _), do: :error

  @doc """
  Returns the MD5 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-md5>
  """
  def call(:MD5, [%RDF.Literal{datatype: @xsd_string} = literal]) do
    hash(:md5, literal.value)
  end

  def call(:MD5, _), do: :error

  @doc """
  Returns the SHA1 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-sha1>
  """
  def call(:SHA1, [%RDF.Literal{datatype: @xsd_string} = literal]) do
    hash(:sha, literal.value)
  end

  def call(:SHA1, _), do: :error

  @doc """
  Returns the SHA256 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-sha256>
  """
  def call(:SHA256, [%RDF.Literal{datatype: @xsd_string} = literal]) do
    hash(:sha256, literal.value)
  end

  def call(:SHA256, _), do: :error

  @doc """
  Returns the SHA384 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#fun  c-sha384>
  """
  def call(:SHA384, [%RDF.Literal{datatype: @xsd_string} = literal]) do
    hash(:sha384, literal.value)
  end

  def call(:SHA384, _), do: :error

  @doc """
  Returns the SHA512 checksum, as a hex digit string.

  see <https://www.w3.org/TR/sparql11-query/#func-sha512>
  """
  def call(:SHA512, [%RDF.Literal{datatype: @xsd_string} = literal]) do
    hash(:sha512, literal.value)
  end

  def call(:SHA512, _), do: :error

  defp hash(type, value) do
    :crypto.hash(type, value)
    |> Base.encode16()
    |> String.downcase()
    |> RDF.string()
  end

  defp match_regex(%RDF.Literal{datatype: datatype} = text,
                   %RDF.Literal{datatype: @xsd_string} = pattern,
                   %RDF.Literal{datatype: @xsd_string} = flags)
       when datatype in [@xsd_string, @lang_string] do
    case xpath_pattern(pattern.value, flags.value) do
      {:regex, regex} ->
        Regex.match?(regex, text.value) |> ebv()

      {:q, pattern} ->
        String.contains?(text.value, pattern) |> ebv()

      {:qi, pattern} ->
        text.value
        |> String.downcase()
        |> String.contains?(String.downcase(pattern))
        |> ebv()

      _ ->
        :error
    end
  end

  defp match_regex(_, _, _), do: :error

  defp replace_regex(%RDF.Literal{datatype: datatype} = text,
                     %RDF.Literal{datatype: @xsd_string} = pattern,
                     %RDF.Literal{datatype: @xsd_string} = replacement,
                     %RDF.Literal{datatype: @xsd_string} = flags)
       when datatype in [@xsd_string, @lang_string] do
    case xpath_pattern(pattern.value, flags.value) do
      {:regex, regex} ->
        %RDF.Literal{text | value:
          String.replace(text.value, regex, xpath_to_erlang_regex_variables(replacement.value))}

      {:q, pattern} ->
        %RDF.Literal{text | value:
          String.replace(text.value, pattern, replacement.value)}

      {:qi, _pattern} ->
        Logger.error "The combination of the q and the i flag is currently not supported in REPLACE"
        :error

      _ ->
        :error
    end
  end

  defp replace_regex(_, _, _, _), do: :error

  defp xpath_pattern(pattern, flags) do
    q_pattern(pattern, flags) || xpath_regex_pattern(pattern, flags)
  end

  defp q_pattern(pattern, flags) do
    if String.contains?(flags, "q") and String.replace(flags, ~r/[qi]/, "") == "" do
      {(if String.contains?(flags, "i"), do: :qi, else: :q), pattern}
    end
  end

  defp xpath_regex_pattern(pattern, flags) do
    with {:ok, regex} <- Regex.compile(pattern, xpath_regex_flags(flags)) do
      {:regex, regex}
    end
  end

  defp xpath_regex_flags(flags) do
    String.replace(flags, "q", "") <> "u"
  end

  defp xpath_to_erlang_regex_variables(text) do
    String.replace(text, ~r/(?<!\\)\$/, "\\")
  end


  defp naive_datetime_part(%RDF.Literal{value: %DateTime{} = datetime,
                                        uncanonical_lexical: nil}, field) do
    datetime
    |> Map.get(field)
    |> RDF.integer()
  end

  defp naive_datetime_part(%RDF.Literal{value: %NaiveDateTime{} = datetime}, field) do
    datetime
    |> Map.get(field)
    |> RDF.integer()
  end

  defp naive_datetime_part(literal, field) do
    with {:ok, datetime} <-
           literal
           |> RDF.DateTime.lexical()
           |> NaiveDateTime.from_iso8601()
    do
      datetime
      |> Map.get(field)
      |> RDF.integer()
    else
      _ -> :error
    end
  end


  @doc """
  Argument Compatibility Rules

  see <https://www.w3.org/TR/sparql11-query/#func-arg-compatibility>
  """
  def compatible_arguments?(arg1, arg2)

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
