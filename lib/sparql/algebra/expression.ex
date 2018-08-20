defprotocol SPARQL.Algebra.Expression do

  def variables(expr)

  def evaluate(expr, data)

end

defimpl SPARQL.Algebra.Expression, for: RDF.Literal do
  def variables(_), do: []
  def evaluate(literal, _), do: literal
end

defimpl SPARQL.Algebra.Expression, for: RDF.IRI do
  def variables(_), do: []
  def evaluate(iri, _), do: iri
end

defimpl SPARQL.Algebra.Expression, for: RDF.BlankNode do
  def variables(_), do: []
  def evaluate(bnode, _), do: bnode
end

defimpl SPARQL.Algebra.Expression, for: RDF.Literal do
  def variables(_), do: []
  def evaluate(literal, _), do: literal
end

defimpl SPARQL.Algebra.Expression, for: BitString do
  def variables(_), do: []
  def evaluate(variable, %{solution: solution}), do: Map.get(solution, variable)
end
