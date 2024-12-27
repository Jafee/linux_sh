sudo sed -i 's/^#\?\(Port\s*\).*/\112222/' /etc/ssh/sshd_config
sudo sed -i 's/^UsePAM\s\+yes/UsePAM no/' /etc/ssh/sshd_config

PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7cc8mLX3jJYPVzzwu4ikt2lxtBG9+7tksPahCib20Mn6WkTlDaWBjpntZB3F+YWr6DHlAmfsPQltFNc4QYSyG+id/4pmAcaEoLO2y7hK7VjJvFLhREGuz6ZfsYldr58cMY3bR4829vD3xq7PQtNeB6V42k/uv+/O7caDqFlnDmt8JUQiKSq7v0jITk585Kk4c5wDfYkUG6Q/gBQu842dIFZVAkVp/0Wy/VLd3ditjahwmvTsYWnO5WLIn7wmYdicRpnyWmCMDSXpyCbp0M+GOkaYanxeYjGns6ehDmk9gBPfRBR/Kwbmmfzz59Z67Qsxcql2BPgJOCCWSStdwiVGCunZ6kABocfcp7Dp3J9pwe8gZbHGUOgT18RYSubkJq8JGL8HPT8LvTmtl2r7VopOBPU2I5aGocVqaQJlrm7/zMWmlXK2oFIPeoyLCjOnEN9Nlwsi74Dh5iVGDf5veKJyd++HlLZxCj6577ExufhjV1ls/hBOi77p/qm5Z6XRyEeizO9x4v8jpt19XoLqgcV7fFKVYF21Zi3oUywKIkY6NvOTBS4bZ9W5Ct34BwzUAOPCWhpIkDQaeoLblLkAG1RBcEjl9pxBktjXz7eSowHIZHnykmELqolVRBL1pkDErkM+7IBxZfZkYyqQmmWCyFIDaJTIGhc+MH1ee8L584f3Bhw== local"

sudo echo "$PUBLIC_KEY" > /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys
sudo rm -rf /home/admin/.ssh/authorized_keys
sudo reboot

# ========================================================================================

# remove ali
wget http://update.aegis.aliyun.com/download/uninstall.sh
chmod +x uninstall.sh
./uninstall.sh
wget http://update.aegis.aliyun.com/download/quartz_uninstall.sh
chmod +x quartz_uninstall.sh
./quartz_uninstall.sh
pkill aliyun-service
rm -fr /etc/init.d/agentwatch /usr/sbin/aliyun-service
rm -rf /usr/local/aegis*
iptables -I INPUT -s 140.205.201.0/28 -j DROP
iptables -I INPUT -s 140.205.201.16/29 -j DROP
iptables -I INPUT -s 140.205.201.32/28 -j DROP
iptables -I INPUT -s 140.205.225.192/29 -j DROP
iptables -I INPUT -s 140.205.225.200/30 -j DROP
iptables -I INPUT -s 140.205.225.184/29 -j DROP
iptables -I INPUT -s 140.205.225.183/32 -j DROP
iptables -I INPUT -s 140.205.225.206/32 -j DROP
iptables -I INPUT -s 140.205.225.205/32 -j DROP
iptables -I INPUT -s 140.205.225.195/32 -j DROP
iptables -I INPUT -s 140.205.225.204/32 -j DROP
systemctl stop aliyun.service
systemctl disable aliyun.service
/usr/local/share/assist-daemon/assist_daemon --stop
/usr/local/share/assist-daemon/assist_daemon --delete
rm -rf /usr/local/share/assist-daemon
sudo rpm -qa | grep aliyun_assist | xargs sudo rpm -e
rm -rf /usr/local/share/aliyun-assist
systemctl stop pmproxy.service
systemctl disable pmproxy.service
systemctl stop pmcd.service
systemctl disable pmcd.service
sed -i 's|http://mirrors\.cloud\.aliyuncs\.com|https://mirror.sg.gs|g' /etc/apt/sources.list

# swap
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sysctl vm.swappiness=10
echo -e "\nvm.swappiness=10" >> /etc/sysctl.conf
sysctl vm.vfs_cache_pressure=50
echo -e "\nvm.vfs_cache_pressure=50" >> /etc/sysctl.conf

# bbr
echo -e "net.core.default_qdisc=fq\nnet.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sysctl net.ipv4.tcp_congestion_control
lsmod | grep bbr

sudo reboot

# ========================================================================================

# install wrap
apt update
apt upgrade -y
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
sudo apt-get update && sudo apt-get install cloudflare-warp -y
warp-cli registration new
warp-cli mode proxy
warp-cli connect

# snap system
