# kong-sandboxbug
Test case to reproduce a bug in Kong 2.3.x related to the sandboxing for the FaaS plugins (pre-function / post-function).  Follow these steps:

1. Clone this repo
2. `docker build -t kong-sandbox-bug . && docker run -p 8000:8000 -p 8001:8001 kong-sandbox-bug`
3. Open a web browser and navigate to `http://localhost:8000/route1`<br><br>
   `Hello World` should appear as the response in the browser<br><br>
   Kong's log will show the following output:
```
2021/05/10 04:36:18 [notice] 24#0: *50 [kong] handler.lua:8 [my-custom-plugin] #########################, client: 172.17.0.1, server: kong, request: "GET /route1 HTTP/1.1", host: "localhost:8000"

172.17.0.1 - - [10/May/2021:04:36:18 +0000] "GET /route1 HTTP/1.1" 200 11 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36"
```

4. In the web browser, navigate to `http://localhost:8000/route2`<br><br>
   `Success` should appear as the response in the browser<br><br>
   Kong's log will show the following output:
```
2021/05/10 04:36:30 [notice] 24#0: *50 [kong] [string "kong.log.notice('*** pre-function plugin was ..."]:1 [pre-function] *** pre-function plugin was called, client: 172.17.0.1, server: kong, request: "GET /route2 HTTP/1.1", host: "localhost:8000"

172.17.0.1 - - [10/May/2021:04:36:30 +0000] "GET /route2 HTTP/1.1" 200 7 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36"
```
5. In the web browser, navigate again to `http://localhost:8000/route1`<br><br>
   This time you will see an error as the response in the web browser:<br>
   `{"message":"An unexpected error occurred"}`<br><br>
   And the Kong's log will show the following:
```
2021/05/10 04:43:43 [error] 24#0: *2831 [kong] init.lua:271 [my-custom-plugin] .../share/lua/5.1/kong/plugins/my-custom-plugin/handler.lua:7: attempt to call field 'rep' (a nil value), client: 172.17.0.1, server: kong, request: "GET /route1 HTTP/1.1", host: "localhost:8000"

172.17.0.1 - - [10/May/2021:04:43:43 +0000] "GET /route1 HTTP/1.1" 500 42 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.85 Safari/537.36"
```

## Analysis

`/route1` is configured to run a custom plugin that calls Lua's `string.rep()` function and then returns a 200 response.  `/route2` is configured to run a "pre-function" FaaS plugin that simply writes output to the log file, then returns a 200.  However, once the FaaS plugin has executed at least one time, then the custom plugin stops working because `string.rep()` no longer exists.  The reason is that Kong's FaaS plugin creates a sandbox environment for the FaaS code that purposely disables string.rep() and a number of other functions.  This sandbox is only supposed to affect the FaaS code, but instead the changes are being applied globally so that all lua code is impacted.

## Bug Report
Issue is tracked here:
https://github.com/Kong/kong/issues/7133
