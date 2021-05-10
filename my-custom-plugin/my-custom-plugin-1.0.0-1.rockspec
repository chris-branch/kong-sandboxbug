package = "my-custom-plugin"
version = "1.0.0-1"

source = {
  url = "http://github.com/Kong/kong-plugin.git",
  tag = "1.0.0"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.my-custom-plugin.handler"] = "./handler.lua",
    ["kong.plugins.my-custom-plugin.schema"] = "./schema.lua",
  }
}
