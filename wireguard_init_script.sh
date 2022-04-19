#!/bin/bash
#change path to /etc/wireguard
wireguard_path='/home/'$USER'/wireguard/'
port=51830
user_name='main_interface'
user_seq_num=1
addresses_data_path=$wireguard_path'addresses_data.txt'
main_conf_path=$wireguard_path'wg0.conf'
priv_key_path=$wireguard_path'privatekey'
pub_key_path=$wireguard_path'publickey'
network_interface=`ip -br a show | awk '$1!="lo"{print $1}'`



wg genkey | tee $priv_key_path | wg pubkey | tee $pub_key_path
chmod 600 $priv_key_path



init_interface_text="\n[Interface]
\nPrivateKey = `cat $priv_key_path`
\nAddress = 10.0.0.$user_seq_num/24
\nListenPort = $port
\nPostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $network_interface -j MASQUERADE
\nPostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $network_interface -j MASQUERADE"

echo $init_interface_text >> $main_conf_path



echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p



systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
systemctl status wg-quick@wg0.service



touch $addresses_data_path
chmod 600 $addresses_data_path
echo $user_name' '$user_seq_num' '`cat $priv_key_path`' '`cat $pub_key_path` >> $addresses_data_path
