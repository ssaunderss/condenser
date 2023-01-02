defmodule Condenser.CsvHelpersTest do
  use ExUnit.Case, async: true

  alias Condenser.CsvHelpers

  describe "[to_csv/2]" do
    test "empty input successfully generates csv" do
      id = Ecto.UUID.autogenerate()
      file_name = "priv/csvs/top-hits-#{inspect(id)}"

      CsvHelpers.to_csv([], file_name)

      assert File.exists?(Application.app_dir(:condenser, file_name)) == true
    end

    test "non-empty input generates csv" do
      sample_data = [
        %{count_hits: 2, long_url: "https://www.google.com", short_slug: "rGu2ae"},
        %{count_hits: 1, long_url: "https://austinsaunders.io", short_slug: "VmSdPV"}
      ]

      id = Ecto.UUID.autogenerate()
      file_name = "priv/csvs/top-hits-#{inspect(id)}"

      CsvHelpers.to_csv(sample_data, file_name)

      assert File.exists?(Application.app_dir(:condenser, file_name)) == true
    end
  end
end
