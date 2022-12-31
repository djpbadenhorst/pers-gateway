# INITIAL JSON FILE
mkdir -p /www/data/json/
echo '{"status":"success","payload":{"status":"Tailscale Down"}}' > /www/data/json/tailscale.log.json

# HTML FILE
mkdir -p /www/data/html/
cat <<EOT >> /www/data/html/status.html
<!DOCTYPE html>
<html>
  <head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.1/jquery.min.js"></script>
    <script>
      async function init() {
          updateTailscaleStatus();
      }
      async function updateTailscaleStatus() {
 	  \$("#tailscale-status").text("loading");
	  fetch('/gateway/api/tailscale/status').then(resp=> {
	      resp.json().then(data => {
 	          \$("#tailscale-status").text(data.payload.status.toLowerCase());
	      });
	  });
      }
    </script>
  </head>

  <body onload="init()">
    <form>
      <div style="margin: 20px;">
	<p style="display:inline; float:left; margin: 0; margin-right: 10px;"><b>Tailscale Status:</b></p>
	<p style="display:inline; float:left; margin: 0; margin-right: 10px;" id="tailscale-status">loading</p>
	<button type="button" onclick="updateTailscaleStatus()">Refresh Status</button>
      </div>
      <div style="margin: 20px;">
	<button type="button" onclick="window.location.href='shell/'">Access Gateway Shell</button>
      </div>
      <div style="margin: 20px;">
	<button type="button" onclick="window.location.href='router/status'">Access Router</button>
      </div>
    </form>
  </body>
</html>
EOT

# NGINX CONFIG
mkdir -p /etc/nginx/conf.d/
cat <<EOT >> /etc/nginx/conf.d/nginx.conf
server {
    server_name ${gateway_ip};
    root /www/data/;
    listen 80;

    location = /gateway/ {
        return 302 https://djpb.info/status;
    }

    location /gateway/status {
        try_files /html/status.html = 404;
    }

    location /gateway/api/status {
        add_header Content-Type text/json;
        return 200 '{"status":"success", "payload": { "message" : "API Up"}}';
    }

    location /gateway/api/tailscale/status {
        add_header Content-Type text/json;
        try_files /json/tailscale.log.json = 404;
    }

    location /gateway/shell/ {
        proxy_pass https://localhost:4200/;
    }

    location /gateway/ {
        add_header Content-Type text/plain;
        return 200 'here1';
        #proxy_pass http://10.0.0.0/gateway/;
    }
}
EOT

# LOOP SCRIPT
cat <<EOT >> loop.sh
count=0
while true
do
  status=\$(tailscale status --json | jq -r .BackendState)
  echo '{"status":"success","payload":{"status":"Tailscale '\$status'"}}' > /www/data/json/tailscale.log.json

  load=\$(uptime | grep -oP '(?<=average: ).*?(?=,)')
  check=\$(awk 'BEGIN{ print "'\$load'"<"0.5" }')

  if [ \$check -eq 1 ];then
    ((count+=1))
  else
    count=0
  fi

  if (( \$count>60 ))
  then
    poweroff
  fi

  sleep 60
done
EOT

# SHELLINABOX
adduser --gecos "" --disabled-password djpb
chpasswd <<<"djpb:${ssh_password}"
echo '   PasswordAuthentication yes' > /etc/ssh/ssh_config

apt update
apt install -y shellinabox

# INSTALLS
apt-get install -y nginx curl jq

# TAILSCALE
curl -fsSL https://tailscale.com/install.sh | sh
tailscaled --state=mem:
tailscale up --accept-routes --authkey=${tailscale_authkey} --hostname=gateway

# MAIN LOOP
bash loop.sh

# TODO
#echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
#echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
#sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
#tailscale up --accept-routes --authkey=${tailscale_authkey} --hostname=gateway --advertise-exit-node
#sudo tailscale up 

