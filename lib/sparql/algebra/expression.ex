defprotocol SPARQL.Algebra.Expression do

  def variables(expr)

  def evaluate(expr, data)

end
