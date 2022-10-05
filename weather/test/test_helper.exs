ExUnit.start()

Mox.defmock(APIClientBehaviourMock, for: Weather.APIClientBehaviour)

Application.put_env(:weather, :http_client, APIClientBehaviourMock)
