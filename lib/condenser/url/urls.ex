defmodule Condenser.URLs do
  @moduledoc """
  Set of functions for interacting with the `urls` table.
  """
  require Logger

  alias Condenser.Repo
  alias Condenser.URL

  @doc """
  Given a long url and stringified client ip,
  attempts to create a short url if the long_url doesn't
  already exist in the `urls` table. If it does exist, just return
  existing short url.

  Has a unique approach to encountering collisions - recursively slides
  along the generated long hash with a window size of `slug_length/0`
  until we come across a short_url that is new - if one can't be found
  that means the table is reaching its capacity and we should consider
  bumping up slug length.
  """
  @spec create_short_url(String.t(), String.t()) :: {:ok, URL.t()} | {:error, String.t()}
  def create_short_url(url, creator_ip) do
    with {:valid, true} <- {:valid, valid_url?(url)},
         # if we don't check first, can lead to an n+1 insertion situation where the unique
         # constraint on short_slug is checked and fails before the long_url unique constraint
         {:preexisting, {:error, _msg}} <- {:preexisting, get_by_long_url(url)},
         hashed <- hash_url(url) do
      slug_length = slug_length()

      params = %{
        long_url: url,
        creator_ip: creator_ip,
        short_slug: String.slice(hashed, 0..(slug_length - 1))
      }

      changeset = URL.changeset(%URL{}, params)

      insert_url(changeset, hashed)
    else
      {:valid, false} -> {:error, "Invalid URL, urls must be of the format https://domain.tld"}
      {:preexisting, val} -> val
    end
  end

  @doc """
  Given a long url, fetches the short url value from the `urls` table.
  Used for checking whether a long_url already exists.
  """
  @spec get_by_long_url(String.t()) :: {:ok, URL.t()} | {:error, String.t()}
  def get_by_long_url(long_url) do
    case Repo.get_by(URL, long_url: long_url) do
      nil -> {:error, "Long URL #{inspect(long_url)} does not exist."}
      val -> {:ok, val}
    end
  end

  @doc """
  Given a short_slug, looks up corresponding row in db.
  Used for redirection.
  """
  @spec get_by_short_slug(String.t()) :: {:ok, URL.t()} | {:error, String.t()}
  def get_by_short_slug(short_slug) do
    case Repo.get_by(URL, short_slug: short_slug) do
      nil -> {:error, "Shortened URL /#{inspect(short_slug)} does not exist."}
      val -> {:ok, val}
    end
  end

  defp insert_url(changeset, long_hash) do
    case Repo.insert(changeset) do
      {:ok, row} ->
        {:ok, row}

      {:error, changeset} ->
        traverse_changeset_errors(changeset, long_hash)
    end
  end

  defp traverse_changeset_errors(changeset, long_hash) do
    {errored_col, _reason} = Enum.at(changeset.errors, 0)

    case errored_col do
      # the long url has already been recorded, secondary check in case there is a race condition
      :long_url ->
        get_by_long_url(changeset.changes.long_url)

      # the short slug has already been taken, try again
      :short_slug ->
        updated_long_hash = String.slice(long_hash, 1..-1)
        slide_hash(changeset, updated_long_hash)

      :creator_ip ->
        {:error, "Invalid client IP."}

      # all other unknown errors, just return :error tuple
      _ ->
        Logger.error("[urls] Encountered unknown url error: #{inspect(changeset)}")
        {:error, "Our system ran into a problem :("}
    end
  end

  @spec hash_url(String.t()) :: String.t()
  defp hash_url(long_url) do
    :crypto.hash(:sha256, long_url)
    |> Base.url_encode64(padding: false)
  end

  @spec valid_url?(String.t()) :: boolean()
  defp valid_url?(url) do
    uri = URI.parse(url)
    uri.scheme != nil && uri.host =~ "."
  end

  defp slide_hash(changeset, long_hash) do
    slug_length = slug_length()

    case String.length(long_hash) >= slug_length do
      false ->
        Logger.critical(
          "[urls] could not find unused short slug, URLs table reaching high collision frequency. Consider updating slug size to #{inspect(slug_length() + 1)}"
        )

        {:error, "Uh oh! Our system is running into unexpected behavior, please come back later."}

      true ->
        updated_params = %{
          long_url: changeset.changes.long_url,
          creator_ip: changeset.changes.creator_ip,
          short_slug: String.slice(long_hash, 0..(slug_length - 1))
        }

        updated = URL.changeset(%URL{}, updated_params)

        insert_url(updated, long_hash)
    end
  end

  defp slug_length(), do: Application.fetch_env!(:condenser, :short_slug_length)
end
