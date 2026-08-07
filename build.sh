#!/bin/sh

# ARG BASE_IMAGE=docker.io/library/nginx
# ARG BASE_IMAGE_TAG=mainline

# ARG BUILD_BASE_IMAGE=docker.io/library/nginx
# ARG BUILD_BASE_IMAGE_TAG=mainline

# ARG SOURCE_CODE_PATH=/usr/src
# ARG NGINX_PREFIX=/etc/nginx
# ARG LUA_MODULE_PATH=${NGINX_PREFIX}/lua
# ARG COMPILED_INSTALL_PREFIX=/usr/local

# If the user is in an environment where GitHub is blocked, they can use a mirror by setting this ARG. (If they can find a mirror.)
# ARG GITHUB_URL=github.com
# ARG GITHUB_API_URL=api.${GITHUB_URL}

# ARG CUSTOM_PRE_BUILD_CMD=":"

${CUSTOM_PRE_BUILD_CMD}

### ----------
### FUNCTIONS
### ----------

print_info() {
    case "${PRINT_INFO}" in
        "true"|"True")
        printf "\033[32m[INFO]\033[0m %s \n" "${1}"
        ;;
    esac
}

print_warning() {
    printf "\033[33m[WARNING]\033[0m %s \n" "${1}"
}

print_error() {
    printf "\033[31m[ERROR]\033[0m %s \n" "${1}"
}

print_error_exit(){
    print_error "${1}"
    exit "${2}"
}

branch_empty_notice(){
    print_error_exit "${1} is required. Please set ${1} to a valid branch name." "2"
}

arg_empty_notice(){
    print_error_exit "${1} ${2} required. Please set ${1} to a valid ${3}."
}

if_invalid_notice(){
    print_error_exit "${1} must be set to either \"true\", \"True\", \"false\", or \"False\". Other values are not accepted." "2"
}

git_clone(){
    print_info "Downloading ${2}, branch ${1}, into ${SOURCE_CODE_PATH}/${3}/"
    git clone --depth 1 --single-branch --branch "${1}" "${2}" "${SOURCE_CODE_PATH}/${3}/"
}

get_releases(){

    # 1. Get releases from api
    # 2. Use jq to extract the required download URL
    # 3. Use curl to download the file
    # 4. Check digest
    # 5. Retry if not correct
    # 6. Fail if the second attempt fails

    print_info "Downloading ${1} release tag ${2}, into ${SOURCE_CODE_PATH}/${3}, ${4}"

    __github_api_key_result="$(curl -fsSL "https://${GITHUB_API_URL}/repos/${1}/releases/${2}")"
    
    curl -LSo "/tmp/__${2}_${3}_releases.tar.gz" "$(printf "%s \n" "${__github_api_key_result}" | jq -r '.assets[0].browser_download_url')"

    # REMEMBER: ${1} includes a path separator!

    printf "%s  %s \n" "$(printf "%s \n" "${__github_api_key_result}" | jq -r '.assets[0].digest'| cut -d ':' -f 2)" "/tmp/__${2}_${3}_releases.tar.gz" > "/tmp/__${1}_${2}.sha256"


    if ! sha256sum -c "/tmp/__${1}_${2}.sha256"; then
        case "${4}" in
            "")
            print_warning "We detected a checksum mismatch. Retrying"
            get_releases "${1}" "${2}" "${3}" "__retry"
            ;;
            "__retry")
            print_error_exit "We have a problem downloading repo ${1} release tag ${2}. The checksum does not match. Please check your Internet connection or run this script again." "1"
            ;;
        esac
    fi

    mkdir -p "${SOURCE_CODE_PATH}/${3}"
    tar -xf "/tmp/__${2}_${3}_releases.tar.gz"  -C "${SOURCE_CODE_PATH}/${3}/" --strip-components=1
    
}

print_info "Hello!"

case "${QUIT_WHEN_ERROR}" in
    "true"|"True")
    # Exit when error
    set -e
    ;;
    *)
    set +e
esac

# ARG PACKAGE_MANAGER=apt-get
# ARG CUSTOM_PACKAGE_MIRROR_SETUP=":"

"${CUSTOM_PACKAGE_MIRROR_SETUP}"

if [ -z "${PACKAGE_MANAGER}" ]; then
    arg_empty_notice "PACKAGE_MANAGER" "a" "package manager"
fi

if [ -z "${SOURCE_CODE_PATH}" ] || [ -z "${NGINX_PREFIX}" ] || [ -z "${LUA_MODULE_PATH}" ] || [ -z "${COMPILED_INSTALL_PREFIX}" ]; then
    arg_empty_notice "All of SOURCE_CODE_PATH, NGINX_PREFIX, LUA_MODULE_PATH, or COMPILED_INSTALL_PREFIX" "are" "path"
else
    mkdir -p "${SOURCE_CODE_PATH}"
    mkdir -p "${NGINX_PREFIX}"
    mkdir -p "${LUA_MODULE_PATH}"
    mkdir -p "${COMPILED_INSTALL_PREFIX}"
fi


case "${PACKAGE_MANAGER}" in
    "apt-get"|"apt")
    "${PACKAGE_MANAGER}" update -y
    "${PACKAGE_MANAGER}" upgrade -y
    "${PACKAGE_MANAGER}" install --no-install-recommends --no-install-suggests -y \
    curl \
    jq \
    tar \
    git \
    golang \
    gcc \
    make \
    libc6-dev \
    libtool \
    libpcre2-dev \
    libssl-dev \
    apt-utils \
    autoconf \
    automake \
    build-essential \
    libcurl4-openssl-dev \
    libgeoip-dev \
    liblmdb-dev \
    libxml2-dev \
    libyajl-dev \
    pkgconf \
    zlib1g-dev \
    ca-certificates # \
    # wget \
    ;;

    "apk")
    "${PACKAGE_MANAGER}" update
    "${PACKAGE_MANAGER}" add --no-cache --virtual .build-deps \
    curl \
    jq \
    tar \
    git \
    go \
    gcc \
    g++ \
    make \
    musl-dev \
    libtool \
    build-base \
    curl-dev \
    geoip-dev \
    lmdb-dev \
    pcre-dev \
    pcre2-dev \
    libxml2-dev \
    yajl-dev \
    pkgconf \
    zlib-dev \
    zlib-dev \
    openssl-dev \
    linux-headers \
    autoconf \
    m4 \
    automake \
    ca-certificates #\
    # bash \
    # wget
    ;;

    "dnf")
    print_warning "This part has not been tested and is very likely to fail."
    # Never tested
    "${PACKAGE_MANAGER}" update -y
    "${PACKAGE_MANAGER}" install -y \
    curl \
    jq \
    tar \
    git \
    golang \
    gcc \
    gcc-c++ \
    make \
    glibc-devel \
    libtool \
    pcre2-devel \
    zlib-devel \
    openssl-devel \
    autoconf \
    automake \
    libcurl-devel \
    GeoIP-devel \
    lmdb-devel \
    pcre-devel \
    yajl-devel \
    pkgconf \
    zlib-devel \
    ca-certificates # \
    # wget \
    ;;

    "skip")
    :
    ;;

    *)
    print_warning "${PACKAGE_MANAGER} is unsupported, we will try, but it is very likely to fail."
    "${PACKAGE_MANAGER}" update
    "${PACKAGE_MANAGER}" install -y \
    curl \
    jq \
    git \
    golang \
    gcc \
    make \
    libc6-dev \
    libtool \
    libpcre2-dev \
    zlib1g-dev \
    libssl-dev \
    autoconf \
    automake \
    build-essential \
    libcurl4-openssl-dev \
    libgeoip-dev \
    liblmdb-dev \
    libpcre++-dev \
    libxml2-dev \
    libyajl-dev \
    pkgconf \
    ca-certificates #\
    # wget \
    ;;

esac

# --- Compiling and Installing Coraza for NGINX ---
# Download and build https://github.com/corazawaf/libcoraza
# ARG IF_LIBCORAZA=true
# ARG LIBCORAZA_BRANCH=main

case "${IF_LIBCORAZA}" in

    "true"|"True")

    case "${LIBCORAZA_BRANCH}" in
        "")
        branch_empty_notice "LIBCORAZA_BRANCH"
        ;;
        "latest"|"master"|"default")
        # Rewrite non-standard branch name
        export LIBCORAZA_BRANCH=main
        ;;
        *)
        # Keep user-provided branch
        :
        ;;
    esac

    git_clone "${LIBCORAZA_BRANCH}" "https://${GITHUB_URL}/corazawaf/libcoraza.git" "libcoraza"

    cd "${SOURCE_CODE_PATH}/libcoraza"

    ./build.sh
    ./configure --prefix="${COMPILED_INSTALL_PREFIX}"
    make -j"$(nproc)"
    make install

    ;;

    "false"|"False")
    :
    ;;

    *)
    if_invalid_notice "IF_LIBCORAZA"
    ;;

esac

# Download https://github.com/corazawaf/coraza-nginx
# ARG CORAZA_NGINX_BRANCH=main
# ARG IF_CORAZA_NGINX=true
cd "${SOURCE_CODE_PATH}/"

case "${IF_CORAZA_NGINX}" in 
    "true"|"True")

    case "${CORAZA_NGINX_BRANCH}" in 
        "")
        branch_empty_notice "CORAZA_NGINX_BRANCH"
        ;;
        "latest"|"master"|"default")
        # Rewrite non-standard branch name
        export CORAZA_NGINX_BRANCH=main
        ;;
    
    *)
    # Keep user-provided branch
    :
    ;;

    esac

    git_clone "${CORAZA_NGINX_BRANCH}" "https://${GITHUB_URL}/corazawaf/coraza-nginx.git" "coraza-nginx"

    ;;

    "false"|"False")
    :
    ;;

    *)
    if_invalid_notice "IF_CORAZA_NGINX"
    ;;

esac

# Download and Compile the ngx-lua module
# ARG IF_LUAJIT=true
# ARG LUAJIT_BRANCH=v2.1-agentzh

case "${IF_LUAJIT}" in 
    "true"|"True")

    case "${LUAJIT_BRANCH}" in
        "")
        branch_empty_notice "LUAJIT_BRANCH"
        ;;

        "default")
        export LUAJIT_BRANCH=v2.1-agentzh
        ;;

        "master"|"main")
        print_warning "LuaJit does not have a main or master branch, the default branch is v2.1-agentzh. We will still try, but it is very likely to fail."
        ;;

        *)
        # Keep user-provided branch
        :
        ;;

    esac

    git_clone "${LUAJIT_BRANCH}" "https://${GITHUB_URL}/openresty/luajit2.git" "luajit2"

    cd "${SOURCE_CODE_PATH}/luajit2/"

    make -j"$(nproc)" && make install

    ;;

    "false"|"False")
    :
    ;;

    *)
    if_invalid_notice "IF_LUAJIT"
    ;;

esac

# Download the lua modules
# ARG IF_NGX_DEVEL_KIT=true
# ARG NGX_DEVEL_KIT_BRANCH=master

cd "${SOURCE_CODE_PATH}"

case "${IF_NGX_DEVEL_KIT}" in 
    "true"|"True")

    case "${NGX_DEVEL_KIT_BRANCH}" in 
        "")
        branch_empty_notice "NGX_DEVEL_KIT_BRANCH"
        ;;

        "main"|"latest"|"default")
        # Rewrite non-standard branch name
        export NGX_DEVEL_KIT_BRANCH=master
        ;;

        *)
        # Keep user-provided branch
        :
        ;;

    esac

    git_clone "${NGX_DEVEL_KIT_BRANCH}" "https://${GITHUB_URL}/vision5/ngx_devel_kit.git" "ngx_devel_kit"

    ;;

    "false"|"False")
    :
    ;;

    *)
    if_invalid_notice "IF_NGX_DEVEL_KIT"
    ;;

esac

# Download https://github.com/openresty/lua-nginx-module
# ARG IF_LUA_NGINX_MODULE
# ARG LUA_NGINX_MODULE_BRANCH=master

cd "${SOURCE_CODE_PATH}"

case "${IF_LUA_NGINX_MODULE}" in 
    "true"|"True")

    case "${LUA_NGINX_MODULE_BRANCH}" in
        "")
        branch_empty_notice "LUA_NGINX_MODULE_BRANCH"
        ;;
        "main"|"latest"|"default")
        # Rewrite non-standard branch name
        export LUA_NGINX_MODULE_BRANCH=master
        ;;
        *)
        # Keep user-provided branch
        :
        ;;
    esac

    git_clone "${LUA_NGINX_MODULE_BRANCH}" "https://${GITHUB_URL}/openresty/lua-nginx-module.git" "lua-resty-core"
    ;;

    "false"|"False")
    :
    ;;

    *)
    if_invalid_notice "IF_LUA_NGINX_MODULE"
    ;;
    
esac

# Download https://github.com/openresty/lua-resty-core
# ARG IF_LUA_RESTY_CORE=true
# ARG LUA_RESTY_CORE_BRANCH=master

cd "${SOURCE_CODE_PATH}/"

case "${IF_LUA_RESTY_CORE}" in
    "true"|"True")
    
    case "${LUA_RESTY_CORE_BRANCH}" in
        "")
        branch_empty_notice "LUA_RESTY_CORE_BRANCH"
        ;;
        "main"|"latest"|"default")
        # Rewrite non-standard branch name
        export LUA_RESTY_CORE_BRANCH=master
        ;;
        *)
        # Keep user-provided branch
        :
        ;;
    esac

    git_clone "${LUA_RESTY_CORE_BRANCH}" "https://${GITHUB_URL}/openresty/lua-resty-core.git" "lua-nginx-module"

    cd "${SOURCE_CODE_PATH}/lua-resty-core/"

    make install PREFIX="${LUA_MODULE_PATH}"
    ;;

    "false"|"False")
    :
    ;;

    *)
    if_invalid_notice "IF_LUA_RESTY_CORE"
    ;;
esac


cd "${SOURCE_CODE_PATH}/"

# Download https://github.com/openresty/lua-resty-lrucache
# ARG IF_LUA_RESTY_LRUCACHE=true
# ARG LUA_RESTY_LRUCACHE_BRANCH=master

case "${IF_LUA_RESTY_LRUCACHE}" in
    "true"|"True")
    case "${LUA_RESTY_LRUCACHE_BRANCH}" in
        "")
        branch_empty_notice "LUA_RESTY_LRUCACHE_BRANCH"
        ;;
        "main"|"latest"|"default")
        # Rewrite non-standard branch name
        export LUA_RESTY_LRUCACHE_BRANCH=master
        ;;
        *)
        # Keep user-provided branch
        :
        ;;
    esac

    git_clone "${LUA_RESTY_LRUCACHE_BRANCH}" "https://${GITHUB_URL}/openresty/lua-resty-lrucache.git " "lua-resty-lrucache"

    ;;

    "false"|"False")
    :
    ;;

    *)
    if_invalid_notice "IF_LUA_RESTY_LRUCACHE"
    ;;

esac

cd "${SOURCE_CODE_PATH}/"

# Download https://github.com/openresty/headers-more-nginx-module
# ARG IF_HEADERS_MORE_NGINX_MODULE=true
# ARG HEADERS_MORE_NGINX_MODULE_BRANCH=master


case "${IF_HEADERS_MORE_NGINX_MODULE}" in 
    "true"|"True")

    case "${HEADERS_MORE_NGINX_MODULE_BRANCH}" in 
        "")
        branch_empty_notice "HEADERS_MORE_NGINX_MODULE_BRANCH"
        ;;

        "main"|"latest"|"default")
        # Rewrite non-standard branch name
        export HEADERS_MORE_NGINX_MODULE_BRANCH=master
        ;;

        *)
        # Keep user-provided branch
        :
        ;;
    esac

    git_clone "${HEADERS_MORE_NGINX_MODULE_BRANCH}" "https://${GITHUB_URL}/openresty/headers-more-nginx-module.git" "headers-more-nginx-module"

    ;;

    "false"|"False")
    :    
    ;;

    *)
    if_invalid_notice "IF_HEADERS_MORE_NGINX_MODULE"
    ;;
esac



# Clean up
# ARG IF_CLEANUP=true
# This is in the builder stage, so we don't have to clean up, but we should.

case "${IF_CLEANUP}" in
    "true"|"True")
    case "${PACKAGE_MANAGER}" in
        "apt-get"|"apt")
        "${PACKAGE_MANAGER}" remove --purge --auto-remove -y \
        curl \
        jq \
        git \
        golang \
        gcc \
        make \
        libc6-dev \
        libtool \
        libpcre2-dev \
        zlib1g-dev \
        libssl-dev \
        apt-utils \
        autoconf \
        automake \
        build-essential \
        libcurl4-openssl-dev \
        libgeoip-dev \
        liblmdb-dev \
        libxml2-dev \
        libyajl-dev \
        pkgconf \
        ca-certificates #\
        # wget \
        rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/nginx.list
        ;;
        "apk")
        apk del .build-deps
        ;;
        "dnf")
        # Never tested
        "${PACKAGE_MANAGER}" remove -y \
        jq \
        tar \
        git \
        golang \
        gcc \
        gcc-c++ \
        make \
        glibc-devel \
        libtool \
        autoconf \
        automake \
        libcurl-devel \
        GeoIP-devel \
        lmdb-devel \
        pcre-devel \
        yajl-devel \
        zlib-devel \
        pcre2-devel #\
        # wget \
        "${PACKAGE_MANAGER}" clean all
        ;;

        "skip")
        :
        ;;

        *)
        print_warning "${PACKAGE_MANAGER} is unsupported, we will try, but it is very likely to fail."
        # Clean Up, so errors don't really matters.
        set +e
        "${PACKAGE_MANAGER}" remove -y \
        curl \
        jq \
        git \
        golang \
        gcc \
        make \
        libc6-dev \
        libtool \
        libpcre2-dev \
        zlib1g-dev \
        libssl-dev \
        autoconf \
        automake \
        build-essential \
        libcurl4-openssl-dev \
        libgeoip-dev \
        liblmdb-dev \
        libpcre++-dev \
        libxml2-dev \
        libyajl-dev \
        pkgconf \
        ca-certificates #\
        # wget \
        "${PACKAGE_MANAGER}" clean

        case "${QUIT_WHEN_ERROR}" in
            "true"|"True")
            # Exit when error
            set -e
            ;;
            *)
            set +e
        esac
        ;;
    esac

    # Clean up /tmp
    rm -rf /tmp/*
    # Delete the script itself.
    rm -rf "$0"
    ;;

esac

# ARG CUSTOM_EXIT_CMD=":"

${CUSTOM_EXIT_CMD}

print_info "Goodbye!"