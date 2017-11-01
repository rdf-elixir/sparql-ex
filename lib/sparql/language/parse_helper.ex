defmodule SPARQL.Language.ParseHelper do

  def variable('?' ++ name), do: List.to_string(name)
  def variable('$' ++ name), do: List.to_string(name)

end
