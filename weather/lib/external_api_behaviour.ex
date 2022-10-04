defmodule Weather.ExternalAPIBehaviour do
  alias Finch.Response
  alias Finch.Request

  @callback request(Request.t(), Weather.ExternalAPI) ::
              {:ok, result :: Response} | {:error, reason :: term}
end
