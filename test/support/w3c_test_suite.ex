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

  alias NS.{MF, QT}

  alias RDF.{Turtle, Graph, Description, IRI}


  def dir(),      do: SPARQL.TestData.dir() |> Path.join("w3c-test-suites")
  def dir("1.0"), do: dir() |> Path.join("data-r2")
  def dir("1.1"), do: dir() |> Path.join("data-sparql11")
  def dir({version, sub}), do: dir(version) |> Path.join(to_string(sub))

  def file(filename, test_suite), do: test_suite |> dir() |> Path.join(filename)

  def manifest_document_url(test_suite), do: "file:/" <> dir(test_suite)

  def manifest_uri({"1.1", test_suite}),
    do: RDF.iri("http://www.w3.org/2009/sparql/docs/tests/data-sparql11/#{test_suite}/manifest#")
  def manifest_uri({"1.0", test_suite}),
    do: RDF.iri("http://www.w3.org/2001/sw/DataAccess/tests/data-r2/#{test_suite}/manifest#")

  def manifest_path(test_suite, filename), do: file(filename, test_suite)


  def manifest_graph(test_suite, opts \\ []) do
    opts = Keyword.put_new(opts, :base, manifest_document_url(test_suite))
    test_suite
    |> manifest_path(Keyword.get(opts, :manifest, "manifest.ttl"))
    |> Turtle.read_file!(opts)
  end


  def test_cases(test_suite, test_type, opts \\ []) do
    manifest_graph = manifest_graph(test_suite, opts)
    manifest_entries =
      manifest_graph
      |> Graph.description(manifest_document_url(test_suite))
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

  def test_name(test_case), do: value(test_case, MF.name)

  def test_title(test_case),
# Unfortunately OTP < 20 doesn't support unicode characters in atoms,
# so we can't put the description in the test name
#    do: test_name(test_case) <> ": " <> value(test_case, RDFS.comment)
    do: test_name(test_case)

  def test_input_file(test_case),
    do: test_case |> Description.first(MF.action) |> IRI.parse

  def test_output_file(test_case),
    do: test_case |> Description.first(MF.result) |> IRI.parse

  def test_input_file_path(test_case, test_suite),
    do: test_input_file(test_case).path |> Path.basename |> file(test_suite)

  def test_result_file_path(test_case, test_suite),
    do: test_output_file(test_case).path |> Path.basename |> file(test_suite)


  defp value(description, property),
    do: Description.first(description, property) |> to_string

end
