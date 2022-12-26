# NGINX CONFIG
sudo mkdir -p /etc/nginx/conf.d/
cat <<EOT >> /etc/nginx/conf.d/nginx.conf
server {
    server_name ${gateway_ip};
    
    location / {
        add_header Content-Type text/html;
        return 200 '<html><body>HELLO</body></html>';
    }
}
EOT

# IDLE_SHUTDOWN SCRIPT
cat <<EOT >> idle_shutdown.sh
count=0
while true
do
  load=\$(uptime | grep -oP '(?<=average: ).*?(?=,)')
  check=\$(awk 'BEGIN{ print "'\$load'"<"0.5" }')

  if [ \$check -eq 1 ];then
    ((count+=1))
  else
    count=0
  fi

  if (( \$count>60 ))
  then
    sudo poweroff
  fi

  sleep 60
done
EOT

cat idle_shutdown.sh
sudo apt-get install -y nginx curl

curl -fsSL https://tailscale.com/install.sh | sh
tailscaled --state=mem:
tailscale up --accept-routes --authkey=${tailscale_authkey} --hostname=gateway

bash idle_shutdown.sh
