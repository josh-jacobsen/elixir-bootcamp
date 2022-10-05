defmodule Weather.APIClientBehaviour do
  @moduledoc "Behaviour for API test mocks"

  alias Finch.Response
  alias Finch.Request

  @callback request(Request.t(), Weather.APIClient) ::
              {:ok, result :: Response} | {:error, reason :: term}
end
