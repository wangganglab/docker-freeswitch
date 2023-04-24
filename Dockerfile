FROM debian:bullseye

# 安装编译FreeSwitch，所需要依赖环境
ENV TOKEN=pat_CKj8GjohjcGkU3JEMsuAzfri
ADD ./sources.list /etc/apt/sources.list
RUN apt-get clean && apt-get update && apt-get install -yq gnupg2 wget ca-certificates lsb-release vim sngrep
RUN wget --http-user=signalwire --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
RUN echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" > /etc/apt/auth.conf
RUN echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
RUN echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
RUN apt-get update -y && apt-get build-dep freeswitch -y

# 需要把下载freeswitch-1.10.9.tar.gz，解压到Dockerfile文件同级目录下，添加到docker镜像里
RUN cd /opt/ && wget -c https://files.freeswitch.org/releases/freeswitch/freeswitch-1.10.9.-release.tar.gz && tar -C /opt/ -xzvf freeswitch-1.10.9.-release.tar.gz

# 自定义安装freeswitch模块
COPY ./modules.conf /opt/freeswitch-1.10.9.-release/modules.conf
RUN cd /opt/freeswitch-1.10.9.-release && ./configure && make -j4 && make all install &&  make cd-sounds-install cd-moh-install

# 添加Lua
RUN cd /opt/ && wget -c https://luajit.org/download/LuaJIT-2.0.5.tar.gz && tar -C /opt/ -xzvf LuaJIT-2.0.5.tar.gz && cd /opt/LuaJIT-2.0.5/ && make -j4 && make install
RUN cd /opt/ && wget -com https://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz && \
    tar -C /opt/ -zxvf lua-cjson-2.1.0.tar.gz && cd /opt/lua-cjson-2.1.0 && \
    cc -c -O3 -Wall -pedantic -DNDEBUG -I/usr/local/include/luajit-2.0/ -fpic -o lua_cjson.o lua_cjson.c \
    && make -j4 && mkdir -p /usr/local/lib/lua/5.2/ && cp -rf cjson.so /usr/local/lib/lua/5.2/

# Limits Configuration
COPY ./freeswitch.limits.conf /etc/security/limits.d/

# 添加启动文件
ADD ./docker-entrypoint.sh /opt/docker-entrypoint.sh
RUN chmod +x /opt/docker-entrypoint.sh

SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  /usr/local/freeswitch/bin/fs_cli -x status | grep -q ^UP || exit 1

ENTRYPOINT ["/opt/docker-entrypoint.sh"]

CMD ["/usr/local/freeswitch/bin/freeswitch"]