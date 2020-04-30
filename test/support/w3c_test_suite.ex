defmodule SPARQL.W3C.TestSuite do

  defmodule NS do
    use RDF.Vocabulary.Namespace

    defvocab MF,
      base_iri: "http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#",
      terms: [], strict: false

    defvocab QT,
      base_iri: "http://www.w3.org/2001/sw/DataAccess/tests/test-query#",
      terms: [], strict: false

  end

  @compile {:no_warn_undefined, SPARQL.W3C.TestSuite.NS.MF}
  @compile {:no_warn_undefined, SPARQL.W3C.TestSuite.NS.QT}

  alias NS.{MF, QT}

  alias RDF.{Turtle, Graph, Description, IRI, BlankNode}

  import RDF.Sigils

  @query_forms %{
    nil                        => :select,
    RDF.iri(QT.QuerySelect)    => :select,
    RDF.iri(QT.QueryAsk)       => :ask,
    RDF.iri(QT.QueryConstruct) => :construct,
    RDF.iri(QT.QueryDescribe)  => :describe,
  }

  def dir(),      do: SPARQL.TestData.dir() |> Path.join("w3c-test-suites")
  def dir("1.0"), do: dir() |> Path.join("data-r2")
  def dir("1.1"), do: dir() |> Path.join("data-sparql11")
  def dir({version, sub}), do: dir(version) |> Path.join(to_string(sub))

  def file(filename, test_suite), do: test_suite |> dir() |> Path.join(filename)

  def manifest_path(test_suite, filename), do: file(filename, test_suite)

  def manifest_document_url, do: "file://manifest.ttl"

  def manifest_test_suite_property, do: ~I<https://hex.pm/packages/rdf#manifest_test_suite>

  def manifest_uri(manifest_graph), do: manifest_description(manifest_graph).subject

  def manifest_description(manifest_graph) do
    description = Graph.description(manifest_graph, manifest_document_url())

    if Description.include?(description, {RDF.type, MF.Manifest}) do
      description
    else
      {manifest_resource, _, _} =
        manifest_graph
        |> Enum.find(fn {_, p, o} -> p == RDF.type and o == RDF.iri(MF.Manifest) end)
      Graph.description(manifest_graph, manifest_resource)
    end
  end

  def manifest_graph(test_suite, opts \\ []) do
    opts = Keyword.put_new(opts, :base, manifest_document_url())
    test_suite
    |> manifest_path(Keyword.get(opts, :manifest, "manifest.ttl"))
    |> Turtle.read_file!(opts)
    |> add_test_suite(test_suite)
  end

  defp add_test_suite(graph, test_suite) do
    Graph.add(graph, {
      manifest_document_url(),
      manifest_test_suite_property(),
      test_suite |> Tuple.to_list |> Enum.join(",")
    })
  end
  defp test_suite(manifest_graph) do
    manifest_graph
    |> Graph.description(manifest_document_url())
    |> Description.first(manifest_test_suite_property())
    |> to_string
    |> String.split(",")
    |> List.to_tuple
  end

  def test_cases(test_suite_or_manifest_graph, test_type, opts \\ [])

  def test_cases(%Graph{} = manifest_graph, test_type, _opts) do
    manifest_entries =
      manifest_graph
      |> manifest_description()
      |> Description.first(MF.entries)
      |> RDF.List.new(manifest_graph)
      |> RDF.List.values()
      |> MapSet.new

    manifest_graph
    |> Graph.descriptions
    |> Enum.filter(fn description ->
        description.subject in manifest_entries and
          RDF.iri(test_type) in Description.get(description, RDF.type, [])
       end)
  end

  def test_cases(test_suite, test_type, opts) do
    test_suite
    |> manifest_graph(opts)
    |> test_cases(test_type, opts)
  end

  def test_name(test_case), do: value(test_case, MF.name)

  def test_title(test_case),
# Unfortunately OTP < 20 doesn't support unicode characters in atoms,
# so we can't put the description in the test name
#    do: test_name(test_case) <> ": " <> value(test_case, RDFS.comment)
    do: test_name(test_case)

  def test_input_file(test_case),
    do: test_case |> Description.first(MF.action) |> IRI.parse

  def test_input_files(test_case, manifest_graph) do
    with %BlankNode{} = action_node <- Description.first(test_case, MF.action) do
      Graph.description(manifest_graph, action_node)
    end
  end

  def test_output_file(test_case),
    do: test_case |> Description.first(MF.result) |> IRI.parse

  def test_input_file_path(test_case, test_suite),
    do: test_case |> test_input_file() |> file_path(test_suite)

  def test_input_query_file_path(test_case, manifest_graph) do
    test_case
    |> test_input_files(manifest_graph)
    |> Description.first(QT.query)
    |> file_path(test_suite(manifest_graph))
  end

  def test_input_query(test_case, manifest_graph) do
    test_input_query_file_path(test_case, manifest_graph)
    |> File.read!()
  end


  def test_input_data_file_path(test_case, manifest_graph) do
    test_case
    |> test_input_files(manifest_graph)
    |> Description.first(QT.data)
    |> file_path(test_suite(manifest_graph))
  end

  def test_input_data(test_case, manifest_graph) do
    test_input_data_file_path(test_case, manifest_graph)
    |> RDF.read_file!()
  end

  def test_result_file_path(test_case, %Graph{} = manifest_graph),
    do: test_result_file_path(test_case, test_suite(manifest_graph))

  def test_result_file_path(test_case, test_suite),
    do: test_case |> test_output_file() |> file_path(test_suite)

  def test_query_form(test_case) do
    Map.get(@query_forms, Description.first(test_case, QT.queryForm))
  end


  defp value(description, property),
    do: Description.first(description, property) |> to_string

  defp file_path(%URI{path: path}, test_suite),
    do: path |> Path.basename |> file(test_suite)

  defp file_path(%IRI{} = iri, test_suite),
    do: iri |> IRI.parse() |> file_path(test_suite)

end
