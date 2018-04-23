if [ ! -f /v2raybin/v2ray-v$V2RAY_VER-linux-64 ]; then
  rm -rf /v2raybin
  cd /v2raybin
  wget -O v2ray.zip http://github.com/v2ray/v2ray-core/releases/download/v$V2RAY_VER/v2ray-linux-64.zip
  unzip v2ray.zip 
  cd /v2raybin/v2ray-v$V2RAY_VER-linux-64
  chmod +x v2ray
  chmod +x v2ctl
fi

if [ ! -f /caddybin/caddy_v$CADDY_VER ]; then
  rm -rf /caddybin
  mkdir /caddybin/caddy_v$CADDY_VER
  cd /caddybin/caddy_v$CADDY_VER
  wget -O caddy.tar.gz https://github.com/mholt/caddy/releases/download/v0.10.13/caddy_v$CADDY_VER_linux_amd64.tar.gz
  tar -zxvf caddy.tar.gz 
  chmod +x caddy
fi

if [ ! -f $CADDY_ROOT ]; then
  mkdir $CADDY_ROOT
  cd $CADDY_ROOT
  wget -O wallet.bitshares.org-gh-pages.zip https://github.com/bitshares/wallet.bitshares.org/archive/gh-pages.zip
  unzip wallet.bitshares.org-gh-pages.zip
fi

cd /caddybin/caddy_v$CADDY_VER
echo 0.0.0.0:$PORT { > HerokuCaddyfile
echo root $CADDY_ROOT/wallet.bitshares.org-gh-pages >> HerokuCaddyfile
echo gzip $CADDY_GZIP >> HerokuCaddyfile
echo index $CADDY_INDEX >> HerokuCaddyfile
echo forwardproxy { >> HerokuCaddyfile
echo basicauth $CADDY_H2_PROXY_USER $CADDY_H2_PROXY_PWD >> HerokuCaddyfile
echo } >> HerokuCaddyfile
echo proxy $V2_WS_PATH 127.0.0.1:$V2_WS_PORT { >> HerokuCaddyfile
echo websocket >> HerokuCaddyfile
echo header_upstream -Origin >> HerokuCaddyfile
echo } >> HerokuCaddyfile
echo } >> HerokuCaddyfile
cat HerokuCaddyfile
./caddy -conf="HerokuCaddyfile"

cd /v2raybin/v2ray-v$V2RAY_VER-linux-64
echo -e -n "$CONFIG_JSON1" > config.json
echo -e -n "$V2_WS_PORT" >> config.json
echo -e -n "$CONFIG_JSON2" >> config.json
echo -e -n "$UUID" >> config.json
echo -e -n "$CONFIG_JSON3" >> config.json
cat config.json
./v2ray
