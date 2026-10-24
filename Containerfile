# Dockerfile or Containerfile, the name doesn't matter.
# This dockerfile compiles the modules using the builder stage, and puts it in the production stage.
# The stage name should be lowercase according to StageNameCasing (https://docs.docker.com/reference/build-checks/stage-name-casing/).

ARG BASE_IMAGE=docker.io/library/nginx
ARG BASE_IMAGE_TAG=mainline

ARG BUILD_BASE_IMAGE=docker.io/library/nginx
ARG BUILD_BASE_IMAGE_TAG=mainline

ARG SOURCE_CODE_PATH=/usr/src
ARG NGINX_PREFIX=/etc/nginx
ARG COMPILED_INSTALL_PREFIX=/usr/local
ARG LUA_MODULE_PATH=${COMPILED_INSTALL_PREFIX}

ARG LUA_VERSION=5.1

FROM ${BUILD_BASE_IMAGE}:${BUILD_BASE_IMAGE_TAG} AS builder

ARG VERSION="beta"

LABEL \
    org.opencontainers.image.authors="Lawrence <me@lawrenceshi.com>" \
    org.opencontainers.image.title="ModsNGX" \
    org.opencontainers.image.description="Nginx with third-party modules, built as dynamic modules." \
    org.opencontainers.image.source="https://github.com/lawrenceshi/ModsNGX.git" \
    org.opencontainers.image.version="${VERSION}" \
    org.opencontainers.image.licenses="Apache-2.0" \
    space.lawrenceshi.image.ModsNGX.stage="builder" \
    space.lawrenceshi.image.ModsNGX.copyright="Copyright © 2026 Lawrence." \
    space.lawrenceshi.image.ModsNGX.notice="This image is intended for testing and development. Do not use in production." \
    space.lawrenceshi.image.ModsNGX.easter_egg="I hereby grant myself the right to use this image in production, although such use is not recommended." \
    space.lawrenceshi.image.ModsNGX.warning="This software is provided 'AS IS', WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND." \
    space.lawrenceshi.image.ModsNGX.legal="Nginx is a registered trademark of F5, Inc. This image is not affiliated with or endorsed by F5, Inc. or the Nginx project." \
    space.lawrenceshi.image.ModsNGX.legal_summary="This is not an official Nginx image. Use at your own risk." \
    space.lawrenceshi.image.ModsNGX.previous_name="slim-lua-nginx" \
    space.lawrenceshi.image.ModsNGX.copyright.text="This project used a lot of lot of open source project. In fact, it is fully built of open source projects! View the project README.md on GitHub, or at /README.md in the image for more information."

COPY README.md /README.md

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

ARG IF_CORE_RULE_SET=true
ARG CORE_RULE_SET_VERSION=latest

# Planned
# ARG IF_MODSECURITY=true
# ARG MODSECURITY_BRANCH=master 

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
ARG LUA_VERSION

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

ARG IF_HEADERS_MORE_NGINX_MODULE=true
ARG HEADERS_MORE_NGINX_MODULE_BRANCH=master

ARG IF_NGINX_RTMP_MODULE=true
ARG NGINX_RTMP_MODULE_BRANCH=master

ARG IF_ZSTD_NGINX_MODULE=true
ARG ZSTD_NGINX_MODULE_BRANCH=master

ARG IF_NGX_BROTLI=true
ARG NGX_BROTLI_BRANCH=master

ARG IF_LUA_UPSTREAM_NGINX_MODULE=true
ARG LUA_UPSTREAM_NGINX_MODULE_BRANCH=master

ARG IF_CROWDSEC_NGINX_BOUNCER=true
ARG CROWDSEC_NGINX_BOUNCER_VERSION=latest

# Tell nginx's build system where to find LuaJIT 2.1 and more:
ARG LUAJIT_LIB=${COMPILED_INSTALL_PREFIX}/lib
ARG LUAJIT_INC=${COMPILED_INSTALL_PREFIX}/include/luajit-2.1

ENV NGINX_PORT=80

ENV NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx

## Handle Nginx Version ARG
# Default Nginx mainline version.
# Update periodically to keep dependencies current.
# The scripe will try the FORCE_NGINX_VERSION first, then the NGINX_VERSION in the offical Nginx Docker image, and finally the DEFAULT_NGINX_VERSION.
ARG IF_NGINX=true
ARG DEFAULT_NGINX_VERSION=1.31.4
ARG FORCE_NGINX_VERSION=""
# Flags Source: The official NGINX Docker image
ARG CONFIGURE_FLAGS="--prefix=${NGINX_PREFIX} --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/run/nginx.pid --lock-path=/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_v3_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module"
ARG NGINX_MODULE_OPTION="-dynamic"
ARG NGINX_MAKE_OPTION="modules"

ADD --chmod=0755 ./build.sh ${SOURCE_CODE_PATH}/build.sh

RUN ${SOURCE_CODE_PATH}/build.sh

RUN ldconfig


# =========================================


FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} AS production

ARG SOURCE_CODE_PATH
ARG NGINX_PREFIX
ARG COMPILED_INSTALL_PREFIX
ARG LUA_MODULE_PATH
ARG LUA_VERSION

ENV SOURCE_CODE_PATH=${SOURCE_CODE_PATH}
ENV NGINX_PREFIX=${NGINX_PREFIX}
ENV COMPILED_INSTALL_PREFIX=${COMPILED_INSTALL_PREFIX}
ENV LUA_MODULE_PATH=${LUA_MODULE_PATH}

ENV LUA_VERSION=${LUA_VERSION}

# COPY .so files
COPY --from=builder ${COMPILED_INSTALL_PREFIX}/lib/ ${COMPILED_INSTALL_PREFIX}/lib/

# ========================================
# Add comments for unnecessary software.
# ========================================

# COPY Coraza Nginx Module
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_http_coraza_module*.so* /usr/lib/nginx/modules/

# COPY Ngx-Devel-Kit
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ndk_http_module*.so* /usr/lib/nginx/modules/

# COPY Lua Nginx Module
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_http_lua_module*.so* /usr/lib/nginx/modules/

# COPY Lua Cjson
COPY --from=builder ${COMPILED_INSTALL_PREFIX}/lib/lua/${LUA_VERSION}/cjson*.so* ${COMPILED_INSTALL_PREFIX}/lib/lua/${LUA_VERSION}/

# COPY GeoIp2
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_*_geoip2_module*.so* /usr/lib/nginx/modules/

# COPY fancyindex
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_http_fancyindex_module*.so* /usr/lib/nginx/modules/

# COPY headersmore
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_http_headers_more_filter_module*.so* /usr/lib/nginx/modules/

# COPY rtmp
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_rtmp_module*.so* /usr/lib/nginx/modules/

# COPY zstd
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_http_zstd_*_module*.so* /usr/lib/nginx/modules/

# COPY ngx_brotli
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_http_brotli_*_module*.so* /usr/lib/nginx/modules/

# COPY ngx_http_lua_upstream_module
COPY --from=builder ${SOURCE_CODE_PATH}/nginx/objs/ngx_http_lua_upstream_module*.so* /usr/lib/nginx/modules/

# =================================================
# Remove comments for software that is not needed.
# =================================================

# REMOVE Lua Modules
# RUN rm -rf ${LUA_MODULE_PATH}/lib/lua/*

# REMOVE Libcoraza
# RUN rm -rf ${COMPILED_INSTALL_PREFIX}/lib/libcoraza*.so*

# REMOVE LuaJIT
# RUN rm -rf ${COMPILED_INSTALL_PREFIX}/lib/libluajit*.so*

# REMOVE libmaxminddb
# RUN rm -rf ${COMPILED_INSTALL_PREFIX}/lib/libmaxminddb*.so*

# Copy the crowdsec-nginx-bouncer
# Refer to https://github.com/crowdsecurity/cs-nginx-bouncer/blob/main/install.sh
# The user should handle /etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf file on there own in the crowdsec image.
ENV CROWDSEC_LIB_PATH=${COMPILED_INSTALL_PREFIX}"/lua/crowdsec"
ARG CROWDSEC_DATA_PATH="/var/lib/crowdsec/lua/"

RUN mkdir -p ${CROWDSEC_LIB_PATH}/plugins/crowdsec/ &&\
mkdir -p ${CROWDSEC_DATA_PATH}/templates/

COPY --from=builder ${SOURCE_CODE_PATH}/cs-nginx-bouncer/nginx/crowdsec_nginx.conf /etc/nginx/templates/conf.d/crowdsec_nginx.conf
COPY --from=builder ${SOURCE_CODE_PATH}/cs-nginx-bouncer/lua-mod/lib ${CROWDSEC_LIB_PATH}
COPY --from=builder ${SOURCE_CODE_PATH}/cs-nginx-bouncer/lua-mod/templates/ ${CROWDSEC_DATA_PATH}/templates/

COPY --from=builder /etc/coraza/ /etc/coraza/
COPY --from=builder /usr/src/coreruleset/rules /usr/src/coreruleset/rules

# COPY Lua Modules
COPY --from=builder ${LUA_MODULE_PATH}/lib/lua/${LUA_VERSION}/ ${LUA_MODULE_PATH}/lib/lua/${LUA_VERSION}

# Clean up .a, .la, and pkgconfig files
RUN rm -rf ${COMPILED_INSTALL_PREFIX}/lib/*.a ${COMPILED_INSTALL_PREFIX}/lib/*.la ${COMPILED_INSTALL_PREFIX}/lib/lua/pkgconfig/

# LEGAL
COPY --from=builder /usr/share/common-licenses/ /usr/share/common-licenses/
COPY --from=builder /usr/share/doc/ /usr/share/doc/


ENV NGINX_PORT=80

ENV NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx

# Fresh .so file cache
RUN ldconfig