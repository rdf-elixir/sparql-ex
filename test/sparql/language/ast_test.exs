defmodule SPARQL.Language.ASTTest do
  use ExUnit.Case

  import SPARQL.Language.Decoder, only: [ast: 1]


  describe "SELECT query" do

    test "with a single projected variable in a bgp with a single triple" do
      query = """
        PREFIX foaf: <http://xmlns.com/foaf/0.1/>
        SELECT ?name WHERE { ?x foaf:name ?name }
        """

      assert {:ok, {:query, {_prologue,
        {:select,
          {[{{:var, _line, "name"}, _}], _},
          _dataset_clauses,
          {:group_graph_pattern, [
            triples_block: [[
              subject: {:var, _, "x"},
              predicate: {:prefix_ln, _, {"foaf", "name"}},
              object: {:var, _, "name"},
            ]]
          ]},
          _solution_modifier},
        _values}}} = ast(query)
    end

  end

end
