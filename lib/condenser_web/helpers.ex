defmodule CondenserWeb.Helpers do
  def stringify_ip(remote_ip) do
    remote_ip
    |> Tuple.to_list()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(".")
  end
end
