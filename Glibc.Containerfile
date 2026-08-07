# Dockerfile or Containerfile, the name doesn't matter.
# This dockerfile compiles the modules using the builder stage, and puts it in the production stage.
# The stage name should be lowercase according to StageNameCasing (https://docs.docker.com/reference/build-checks/stage-name-casing/).

ARG BASE_IMAGE=docker.io/library/nginx
ARG BASE_IMAGE_TAG=mainline

ARG BUILD_BASE_IMAGE=docker.io/library/nginx
ARG BUILD_BASE_IMAGE_TAG=mainline

ARG SOURCE_CODE_PATH=/usr/src
ARG NGINX_PREFIX=/etc/nginx
ARG LUA_MODULE_PATH=${NGINX_PREFIX}
ARG COMPILED_INSTALL_PREFIX=/usr/local

FROM ${BUILD_BASE_IMAGE}:${BUILD_BASE_IMAGE_TAG} AS builder

# If the user is in an environment where GitHub is blocked, they can use a mirror by setting this ARG. (If they can find a mirror.)
ARG GITHUB_URL=github.com
ARG GITHUB_API_URL=api.${GITHUB_URL}

ARG SOURCE_CODE_PATH
ARG NGINX_PREFIX
ARG LUA_MODULE_PATH
ARG COMPILED_INSTALL_PREFIX

ARG PRINT_INFO=true
ARG QUIT_WHEN_ERROR=true
ARG IF_CLEANUP=true

ARG CUSTOM_PRE_BUILD_CMD=":"
ARG CUSTOM_EXIT_CMD=":"

# The command is specifically designed for apt-get and apk; dnf and others may work, but I never tested them.
ARG PACKAGE_MANAGER=apt-get

# This ARG is only for users in stricted environment.
# Read more & get the commands at https://mirrorz.org (Under: CC BY-NC-SA 4.0, MirrorZ Project)
ARG CUSTOM_PACKAGE_MIRROR_SETUP=":"

ARG IF_LIBCORAZA=true
ARG LIBCORAZA_BRANCH=main

ARG IF_CORAZA_NGINX=true
ARG CORAZA_NGINX_BRANCH=main

# Planned
# ARG MODSECURITY_BRANCH= 

ARG IF_LUAJIT=true
ARG LUAJIT_BRANCH=v2.1-agentzh

ARG IF_NGX_DEVEL_KIT=true
ARG NGX_DEVEL_KIT_BRANCH=master

ARG IF_LUA_NGINX_MODULE=true
ARG LUA_NGINX_MODULE_BRANCH=master

ARG IF_LUA_RESTY_CORE=true
ARG LUA_RESTY_CORE_BRANCH=master

ARG IF_LUA_RESTY_LRUCACHE=true
ARG LUA_RESTY_LRUCACHE_BRANCH=master

ARG IF_LUA_RESTY_LOCK=true
ARG LUA_RESTY_LOCK_BRANCH=master

ARG IF_LUA_RESTY_LIMIT_TRAFFIC=true
ARG LUA_RESTY_LIMIT_TRAFFIC_BRANCH=master

ARG IF_LUA_RESTY_REDIS=true
ARG LUA_RESTY_REDIS_BRANCH=master

ARG IF_LUA_RESTY_COOKIE=true
ARG LUA_RESTY_COOKIE_BRANCH=master

ARG IF_LUA_RESTY_UPSTREAM_HEALTHCHECK=true
ARG LUA_RESTY_UPSTREAM_HEALTHCHECK_BRANCH=master

ARG IF_LUA_RESTY_HTTP=true
ARG LUA_RESTY_HTTP_BRANCH=master

ARG IF_LUA_RESTY_STRING=true
ARG LUA_RESTY_STRING_BRANCH=master

ARG IF_LUA_RESTY_OPENSSL=true
ARG LUA_RESTY_OPENSSL_BRANCH=master

ARG IF_LUA_RESTY_SESSION=true
ARG LUA_RESTY_SESSION_BRANCH=master
ARG LUA_VERSION=5.1

ARG IF_LUA_RESTY_JWT=true
ARG LUA_RESTY_JWT_BRANCH=master

ARG IF_LUA_CJSON=true
ARG LUA_CJSON_BRANCH=master

ARG IF_NGX_HTTP_GEOIP2_MODULE=true
ARG NGX_HTTP_GEOIP2_MODULE_BRANCH=master

ARG IF_LIBMAXMINDDB=true
ARG LIBMAXMINDDB_VERSION=master

ARG IF_NGX_FANCYINDEX=true
ARG NGX_FANCYINDEX_BRANCH=master

ARG IF_NJS=true
ARG NJS_BRANCH=master

ARG IF_HEADERS_MORE_NGINX_MODULE=true
ARG HEADERS_MORE_NGINX_MODULE_BRANCH=master

ARG IF_NGINX_RTMP_MODULE=true
ARG NGINX_RTMP_MODULE_BRANCH=master

ARG IF_ZSTD_NGINX_MODULE=true
ARG ZSTD_NGINX_MODULE_BRANCH=master

ADD --chmod=0755 ./build.sh /build.sh

RUN /build.sh
