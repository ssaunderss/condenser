defmodule Condenser.CsvHelpers do
  @spec to_csv([map()], String.t()) :: :ok
  def to_csv(query_result, file_name) when length(query_result) == 0 do
    file = file(file_name)

    query_result
    |> CSV.encode()
    |> Enum.each(&IO.write(file, &1))
  end

  def to_csv(query_result, file_name) do
    headers = headers(query_result)
    rows = rows(query_result)
    file = file(file_name)

    [headers | rows]
    |> CSV.encode()
    |> Enum.each(&IO.write(file, &1))
  end

  defp headers(query_result) do
    query_result
    |> Enum.at(0)
    |> Map.keys()
    |> Enum.map(&Atom.to_string/1)
  end

  defp rows(query_result) do
    query_result
    |> Enum.map(&Map.values/1)
  end

  defp file(file_name),
    do: File.open!(Application.app_dir(:condenser, file_name), [:write, :utf8])
end
