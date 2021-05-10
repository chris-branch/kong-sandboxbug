local typedefs = require "kong.db.schema.typedefs"

return {
  name = "my-custom-plugin",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { foobaz = { type = "string", default = "Not-Used" }, },
        },
      },
    },
  },
}
