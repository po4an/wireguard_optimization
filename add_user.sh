#!/bin/bash
#change path to /etc/wireguard
wireguard_path='/home/'$USER'/wireguard/'
addresses_data_path=$wireguard_path'addresses_data.txt'
main_conf_path=$wireguard_path'wg0.conf'


read -p "Please set the name of the new user: " new_user_name


new_user_seq_num=`awk 'BEGIN{a=0}{if ($2>a) a = $2} END{print a+1}' $addresses_data_path`
priv_key_path=$wireguard_path$new_user_name'_privatekey'
pub_key_path=$wireguard_path$new_user_name'_publickey'

wg genkey | tee $priv_key_path | wg pubkey | tee $pub_key_path
chmod 600 $priv_key_path

echo $new_user_name' '$new_user_seq_num' '`cat $priv_key_path`' '`cat $pub_key_path` >> $addresses_data_path

new_user_peer_text="\n[Peer]
\nPublicKey = `cat $pub_key_path`
\nAllowedIPs = 10.0.0.$new_user_seq_num/32"

systemctl restart wg-quick@wg0
systemctl status wg-quick@wg0

echo $new_user_peer_text >> $main_conf_path
