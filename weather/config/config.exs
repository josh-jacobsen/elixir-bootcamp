# config/config.exs

import Config

if config_env() == :test do
  import_config "test.exs"
end

# typically the above is `import_config("#{config_env()}")`
# but will require you to make empty files eg dev.exs

# TODO: Pass in as env var
config :weather, :api_key, "ZSZ4AJSLRE4WYN3NSVY9MEQ8H"
