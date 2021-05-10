FROM kong:2.3.3-alpine

COPY ./test-config.yml /test-config.yml

# install custom plugin
USER root
COPY ./my-custom-plugin/* /my-custom-plugin/
WORKDIR /my-custom-plugin
RUN luarocks make my-custom-plugin-1.0.0-1.rockspec

ENV KONG_DECLARATIVE_CONFIG=/test-config.yml
ENV KONG_DATABASE=off
ENV KONG_ADMIN_LISTEN=0.0.0.0:8001
ENV KONG_PLUGINS=pre-function,my-custom-plugin

EXPOSE 8000 8001
