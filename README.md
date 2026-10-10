# slim-lua-nginx
A slim Docker image based on NGINX Mainline and LuaJIT.

~ means not included
| Tag | ShortTags | Base Image | Webserver | Webserver Version | Lua module | Lua module Version | LuaJIT | LuaJIT version | Coraza | Coraza Version | libcoraza | libcoraza Version Crowdsec | Crowdsec Version |
| --- | --- | --- | --- | --- | --- | --- |
| `latest` | `l`, `t1` | [docker.io/library/nginx:mainline](https://hub.docker.com/_/nginx) (debian:trixie-slim) | Nginx Mainline latest| latest | latest | latest |
| `Nginx_mainline_LuaJIT` | `l`, `t2` | [docker.io/library/nginx:mainline](https://hub.docker.com/_/nginx) (debian:trixie-slim) | Nginx Mainline latest| latest | latest | latest |
| `Nginx_stable_latest` | `sl`, `t3` | [docker.io/library/nginx:mainline-alpine](https://hub.docker.com/_/nginx) (debian:trixie-slim) | Nginx Stable latest | latest | latest | latest |


ARG指定安装prefix
根据.py脚本根据不同chunk组合成完整文件
自动填充nginx.conf的环境变量
sudo sysctl fs.inotify.max_user_instances=1024
Use `sudo cscli decisions add -i <IP-ADDRESS> -t ban -d 4h` for testing ip blocking.
Learned ARG place

LABEL \
    org.opencontainers.image.authors="Lawrence <me@lawrenceshi.com>" \
    org.opencontainers.image.title="ModsNGX" \
    org.opencontainers.image.description="Nginx with third-party modules" \
    org.opencontainers.image.source="https://github.com/lawrenceshi/ModsNGX" \
    org.opencontainers.image.version="dev" \
    org.opencontainers.image.licenses="Apache 1.0"


   Copyright 2026 Lawrence

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
