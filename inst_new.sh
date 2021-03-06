#!/bin/bash
set -e


# enable ipv4 packet forwarding
# sysctl -w net.ipv4.ip_forward=1
# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# install nodejs
# curl https://deb.nodesource.com/setup_10.x | bash
# apt-get install -y nodejs

# go into home folder
cd /opt
# delete wg-dashboard folder and wg-dashboard.tar.gz to make sure it does not exist
rm -rf wg-dashboard
rm -rf wg-dashboard.tar.gz
# download wg-dashboard latest release
curl -L https://github.com/$(wget https://github.com/wg-dashboard/wg-dashboard/releases/latest -O - | egrep '/.*/.*/.*tar.gz' -o) --output wg-dashboard.tar.gz
# create directory for dashboard
mkdir -p wg-dashboard
# unzip wg-dashboard
tar -xzf wg-dashboard.tar.gz --strip-components=1 -C wg-dashboard
# delete unpacked .tar.gz
rm -f wg-dashboard.tar.gz
# go into wg-dashboard folder
cd wg-dashboard
# install node modules
npm i --production --unsafe-perm

# create service unit file
echo "[Unit]
Description=wg-dashboard service
After=network.target

[Service]
Restart=always
WorkingDirectory=/opt/wg-dashboard
ExecStart=/usr/bin/node /opt/wg-dashboard/src/server.js

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/wg-dashboard.service

# reload systemd unit files
systemctl daemon-reload
# start wg-dashboard service on reboot
systemctl enable wg-dashboard
# start wg-dashboard service
systemctl start wg-dashboard

# enable port 22 in firewall for ssh
ufw allow 22
# enable firewall
ufw --force enable
# enable port 58210 in firewall for wireguard
ufw allow 58210
# enable port 53 in firewall for dns
ufw allow in on wg0 to any port 53


echo ""
echo ""
echo "=========================================================================="
echo ""
echo "> Done! WireGuard and wg-dashboard have been successfully installed"
echo "> You can now connect to the dashboard via ssh tunnel by visiting:"
echo ""
echo -e "\t\thttp://localhost:3000"
echo ""
echo "> You can open an ssh tunnel from your local machine with this command:"
echo ""
echo -e "\t\tssh -L 3000:localhost:3000 <your_vps_user>@<your_vps_ip>"
echo ""
echo "> Please save this command for later, as you will need it to access the dashboard"
echo ""
echo "=========================================================================="
echo ""
echo ""
