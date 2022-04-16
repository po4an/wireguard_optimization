#!/bin/bash
user_name=$1
data_path='./data.txt'
conf_path='./wireguard/wg0.conf'
keys_path='./wireguard/'
num=`awk 'BEGIN{a=0}{if ($2>a) a = $2} END{print a+1}' $data_path`
priv_key_path=$keys_path$user_name'_privatekey'
pub_key_path=$keys_path$user_name'_publickey'
echo $priv_key_path
echo $pub_key_path
echo $user_name'_privatekey' >  $priv_key_path ; echo $user_name'_publickey' > $pub_key_path 

echo $user_name' '$num' '`cat $priv_key_path`' '`cat $pub_key_path` >> data.txt

new_peer_text="\n[Peer]
\nPublicKey = `cat $pub_key_path`
\nAllowedIPs = 10.0.0.$num/32"

echo $new_peer_text >> $conf_path
