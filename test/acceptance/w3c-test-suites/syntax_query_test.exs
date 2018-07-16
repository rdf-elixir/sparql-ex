defmodule SPARQL.W3C.TestSuite.SyntaxQueryTest do
  @moduledoc """
  The W3C SPARQL 1.0 and 1.1 Query Syntax tests.

  <http://w3c.github.io/rdf-tests/sparql11/data-sparql11/syntax-query/index.html>
  <https://www.w3.org/2001/sw/DataAccess/tests/data-r2/syntax-sparql1/>
  """

  use SPARQL.W3C.TestSuite.Case, async: false

  @base "http://example.org/"


  describe "SPARQL 1.1 syntax-query test suite" do
    @test_suite {"1.1", "syntax-query"}

    TestSuite.test_cases(@test_suite, MF.PositiveSyntaxTest11)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert %SPARQL.Query{} =
                    (test_case
                     |> TestSuite.test_input_file_path(@test_suite)
                     |> File.read!()
                     |> SPARQL.Query.new(base: @base)
                    )
         end
       end)

    TestSuite.test_cases(@test_suite, MF.NegativeSyntaxTest11)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         [
          "test_43",
          "test_44",
          "test_45",
          "test_60",
          "test_61a",
          "test_62a",
          "test_65"
         ]
         |> Enum.each(fn test_subject ->
              if test_case.subject |> to_string() |> String.ends_with?(test_subject),
                do: @tag skip: "TODO"
            end)
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert {:error, _} =  (test_case
                   |> TestSuite.test_input_file_path(@test_suite)
                   |> File.read!()
                   |> SPARQL.Query.new(base: @base)
                  )
         end
       end)
  end

  describe "SPARQL 1.0 syntax-query test suite part 1" do
    @test_suite {"1.0", "syntax-sparql1"}

    TestSuite.test_cases(@test_suite, MF.PositiveSyntaxTest)
    |> Enum.filter(fn test_case ->
         # Decimal format changed in SPARQL 1.1
         not (test_case.subject |> to_string() |> String.ends_with?("syntax-lit-08"))
       end)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert %SPARQL.Query{} =
                    (test_case
                     |> TestSuite.test_input_file_path(@test_suite)
                     |> File.read!()
                     |> SPARQL.Query.new(base: @base)
                    )
         end
       end)
  end

  describe "SPARQL 1.0 syntax-query test suite part 2" do
    @test_suite {"1.0", "syntax-sparql2"}

    TestSuite.test_cases(@test_suite, MF.PositiveSyntaxTest)
    |> Enum.filter(fn test_case ->
         # PNAME_LN changed in SPARQL 1.1
         not (test_case.subject |> to_string() |> String.ends_with?("syntax-esc-04") or
              test_case.subject |> to_string() |> String.ends_with?("syntax-esc-05"))
       end)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert %SPARQL.Query{} =
                    (test_case
                     |> TestSuite.test_input_file_path(@test_suite)
                     |> File.read!()
                     |> SPARQL.Query.new(base: @base)
                    )
         end
       end)
  end

  describe "SPARQL 1.0 syntax-query test suite part 3" do
    @test_suite {"1.0", "syntax-sparql3"}

    TestSuite.test_cases(@test_suite, MF.PositiveSyntaxTest)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert %SPARQL.Query{} =
                    (test_case
                     |> TestSuite.test_input_file_path(@test_suite)
                     |> File.read!()
                     |> SPARQL.Query.new(base: @base)
                    )
         end
       end)

    TestSuite.test_cases(@test_suite, MF.NegativeSyntaxTest)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         [
          "blabel-cross-graph-bad",
          "blabel-cross-optional-bad",
          "blabel-cross-union-bad",
         ]
         |> Enum.each(fn test_subject ->
              if test_case.subject |> to_string() |> String.ends_with?(test_subject),
                do: @tag skip: "TODO"
            end)
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert {:error, _} =  (test_case
                   |> TestSuite.test_input_file_path(@test_suite)
                   |> File.read!()
                   |> SPARQL.Query.new(base: @base)
                  )
         end
       end)
  end

  describe "SPARQL 1.0 syntax-query test suite part 4" do
    @test_suite {"1.0", "syntax-sparql4"}

    TestSuite.test_cases(@test_suite, MF.PositiveSyntaxTest)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert %SPARQL.Query{} =
                    (test_case
                     |> TestSuite.test_input_file_path(@test_suite)
                     |> File.read!()
                     |> SPARQL.Query.new(base: @base)
                    )
         end
       end)

# TODO: all failing
#    TestSuite.test_cases(@test_suite, MF.NegativeSyntaxTest)
#    |> Enum.each(fn test_case ->
#         @tag test_case: test_case
#         test TestSuite.test_title(test_case), %{test_case: test_case} do
#           assert {:error, _} =  (test_case
#                   |> TestSuite.test_input_file_path(@test_suite)
#                   |> File.read!()
#                   |> SPARQL.Query.new(base: @base)
#                  )
#         end
#       end)
  end

  describe "SPARQL 1.0 syntax-query test suite part 5" do
    @test_suite {"1.0", "syntax-sparql5"}

    TestSuite.test_cases(@test_suite, MF.PositiveSyntaxTest)
    |> Enum.each(fn test_case ->
         @tag test_case: test_case
         test TestSuite.test_title(test_case), %{test_case: test_case} do
           assert %SPARQL.Query{} =
                    (test_case
                     |> TestSuite.test_input_file_path(@test_suite)
                     |> File.read!()
                     |> SPARQL.Query.new(base: @base)
                    )
         end
       end)
  end

end
