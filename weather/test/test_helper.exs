ExUnit.start()

Mox.defmock(ExternalApiBehaviourMock, for: Weather.ExternalAPIBehaviour)

Application.put_env(:weather, :http_client, ExternalApiBehaviourMock)
