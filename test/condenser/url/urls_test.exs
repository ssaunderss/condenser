defmodule Condenser.URLsTest do
  use ExUnit.Case, async: true
  use Condenser.DataCase

  alias CondenserWeb.Helpers
  alias Condenser.URL
  alias Condenser.URLs

  setup do
    ip =
      {127, 0, 0, 1}
      |> Helpers.stringify_ip()

    %{ip: ip}
  end

  describe "[create_short_url/2]" do
    test "https returns %URL{} for valid long url", %{ip: client_ip} do
      valid_url = "https://austinsaunders.io"
      assert {:ok, %URL{}} = URLs.create_short_url(valid_url, client_ip)
    end

    test "can insert very long long url", %{ip: client_ip} do
      valid_url =
        "https://www.amazon.com/Kindle-Paperwhite-adjustable-Ad-Supported/dp/B08KTZ8249/ref=sr_1_1_sspa?crid=N73GKLBJCSHG&keywords=kidnle&qid=1672686974&sprefix=kindle%2Caps%2C143&sr=8-1-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUEyRVIwR1Y5R1NWRVFQJmVuY3J5cHRlZElkPUEwNzAxNDkyMU4wWDRSSlUyS0ZLNyZlbmNyeXB0ZWRBZElkPUEwNTgyOTE5MkVUUUMyUlhaUFBPWCZ3aWRnZXROYW1lPXNwX2F0ZiZhY3Rpb249Y2xpY2tSZWRpcmVjdCZkb05vdExvZ0NsaWNrPXRydWU="

      assert {:ok, %URL{}} = URLs.create_short_url(valid_url, client_ip)
    end

    test "http returns %URL{} for valid long url", %{ip: client_ip} do
      valid_url = "http://austinsaunders.io"
      assert {:ok, %URL{}} = URLs.create_short_url(valid_url, client_ip)
    end

    test "existing long url returns from db returns existing row", %{ip: client_ip} do
      valid_url = "https://austinsaunders.io"
      {:ok, url} = URLs.create_short_url(valid_url, client_ip)
      assert {:ok, url} == URLs.create_short_url(valid_url, client_ip)
    end

    test "blank url returns error", %{ip: client_ip} do
      blank_url = ""

      assert {:error, "Invalid URL, urls must be of the format https://domain.tld"} =
               URLs.create_short_url(blank_url, client_ip)
    end

    test "no TDL returns error", %{ip: client_ip} do
      no_tld = "https://austinsaunders"

      assert {:error, "Invalid URL, urls must be of the format https://domain.tld"} =
               URLs.create_short_url(no_tld, client_ip)
    end

    test "missing scheme returns error", %{ip: client_ip} do
      no_scheme = "austinsaunders.io"

      assert {:error, "Invalid URL, urls must be of the format https://domain.tld"} =
               URLs.create_short_url(no_scheme, client_ip)
    end

    test "invalid ip returns error" do
      valid_url = "https://austinsaunders.io"
      bad_ip = {127, 0, 0, 1}
      assert {:error, "Invalid client IP."} = URLs.create_short_url(valid_url, bad_ip)
    end
  end

  describe "[get_by_long_url/1]" do
    test "existing long url returns %URL{}", %{ip: client_ip} do
      valid_url = "https://www.google.com"
      assert {:ok, %URL{}} = URLs.create_short_url(valid_url, client_ip)
      assert {:ok, %URL{}} = URLs.get_by_long_url(valid_url)
    end

    test "non-existing long url returns error" do
      valid_url = "https://www.google.com"
      assert {:error, _msg} = URLs.get_by_long_url(valid_url)
    end
  end

  describe "[get_by_short_slug/1]" do
    test "existing short slug returns %URL{}", %{ip: client_ip} do
      valid_url = "https://a.b"
      assert {:ok, url} = URLs.create_short_url(valid_url, client_ip)
      assert {:ok, %URL{}} = URLs.get_by_short_slug(url.short_slug)
    end

    test "non-existing long url returns error" do
      assert {:error, _msg} = URLs.get_by_short_slug("abcdef")
    end
  end
end
