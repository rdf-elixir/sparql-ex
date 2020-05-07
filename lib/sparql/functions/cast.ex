defmodule SPARQL.Functions.Cast do

  alias RDF.{Literal, XSD}

  defmodule Integer do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:integer` XPath constructor function.

    See:

    - <https://www.w3.org/TR/sparql11-query/#FunctionMapping>
    - <https://www.w3.org/TR/xpath-functions/#casting-to-numerics>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#integer"

    def call(_, [%Literal{} = literal], _, _) do
      XSD.Integer.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule Decimal do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:decimal` XPath constructor function.

    See:

    - <https://www.w3.org/TR/sparql11-query/#FunctionMapping>
    - <https://www.w3.org/TR/xpath-functions/#casting-to-numerics>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#decimal"

    def call(_, [%Literal{} = literal], _, _) do
      XSD.Decimal.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule Float do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:float` XPath constructor function.

    See:

    - <https://www.w3.org/TR/sparql11-query/#FunctionMapping>
    - <https://www.w3.org/TR/xpath-functions/#casting-to-numerics>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#float"

    def call(_, [%Literal{} = literal], _, _) do
      XSD.Float.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule Double do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:double` XPath constructor function.

    See:

    - <https://www.w3.org/TR/sparql11-query/#FunctionMapping>
    - <https://www.w3.org/TR/xpath-functions/#casting-to-numerics>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#double"

    def call(_, [%Literal{} = literal], _, _) do
      XSD.Double.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule String do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:string` XPath constructor function.

    See:

    - <https://www.w3.org/TR/sparql11-query/#FunctionMapping>
    - <https://www.w3.org/TR/xpath-functions/#casting-to-string>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#string"

    def call(_, [value], _, _) do
      XSD.String.cast(value) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule Boolean do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:boolean` XPath constructor function.

    See:

    - <https://www.w3.org/TR/sparql11-query/#FunctionMapping>
    - <https://www.w3.org/TR/xpath-functions/#casting-boolean>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#boolean"

    def call(_, [%Literal{} = literal], _, _) do
      XSD.Boolean.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule DateTime do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:dateTime` XPath constructor function.

    See:

    - <https://www.w3.org/TR/sparql11-query/#FunctionMapping>
    - <https://www.w3.org/TR/xpath-functions/#casting-to-datetimes>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#dateTime"

    def call(_, [%Literal{} = literal], _, _) do
      XSD.DateTime.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule Date do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:date` XPath constructor function.

    Note: This is not required to be implemented on all SPARQL processing engines,
    so a query using this function might not be portable.

    See: <https://www.w3.org/TR/xpath-functions/#casting-to-datetimes>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#date"

    def call(_, [%Literal{} = literal], _, _) do
      XSD.Date.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

  defmodule Time do
    @moduledoc """
    An `SPARQL.ExtensionFunction` for the `xsd:time` XPath constructor function.

    Note: This is not required to be implemented on all SPARQL processing engines,
    so a query using this function might not be portable.

    See:  <https://www.w3.org/TR/xpath-functions/#casting-to-datetimes>
    """

    use SPARQL.ExtensionFunction,
        name: "http://www.w3.org/2001/XMLSchema#time"

    def call(_, [%Literal{} = literal], _, _) do
      RDF.XSD.Time.cast(literal) || :error
    end

    def call(_, _, _, _), do: :error
  end

end
