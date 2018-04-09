defmodule SPARQL.Algebra.BGP do
  defstruct [:triples]
end

defmodule SPARQL.Algebra.Project do
  defstruct [:vars, :expr]
end

defmodule SPARQL.Algebra.Extend do
  defstruct [:var, :expr]
end

defmodule SPARQL.Algebra.Distinct do
  defstruct [:expr]
end

defmodule SPARQL.Algebra.Reduced do
  defstruct [:expr]
end
