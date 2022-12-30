# NGINX CONFIG
sudo mkdir -p /etc/nginx/conf.d/
cat <<EOT >> /etc/nginx/conf.d/nginx.conf
server {
    #server_name ${gateway_ip};
    server_name djpb.info;

    location /gateway/ {
        add_header Content-Type text/plain;
        return 200 'here1';
        #proxy_pass http://10.0.0.0/gateway/;
    }
}
server {
    server_name ${gateway_ip};

    location /gateway/ {
        add_header Content-Type text/plain;
        return 200 'here2';
        #proxy_pass http://10.0.0.0/gateway/;
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

#curl -fsSL https://tailscale.com/install.sh | sh
#sudo tailscaled --state=mem:
#sudo tailscale up --accept-routes --authkey=${tailscale_authkey} --hostname=gateway

bash idle_shutdown.sh
