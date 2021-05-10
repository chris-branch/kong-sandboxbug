local MyCustomPlugin = {}

MyCustomPlugin.PRIORITY = 100
MyCustomPlugin.VERSION = "1.0.0"

function MyCustomPlugin:access(conf)
    local x = string.rep('#', 25)
    kong.log.notice(x)

    kong.response.exit(200, 'hello world')
end

return MyCustomPlugin
