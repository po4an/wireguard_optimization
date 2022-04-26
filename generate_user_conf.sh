wireguard_path=`whereis wireguard | awk -F ": " '{print $2}'`
tech_user_name='main_interface'
addresses_data_path=$wireguard_path'/addresses_data.txt'
all_users=`cat $addresses_data_path | awk -v tech_user_name="$tech_user_name" '$1!=tech_user_name {print$1}'`
all_users_with_delimiter=`echo $all_users | xargs -o | tr -s ' ' '|'`
user_name=$1


if [ -z $user_name ]; then
	while [ `echo $user_name | grep -E -ie '^('+$all_users_with_delimiter+')$' | wc -w` != 1 ]; do
		echo "List of active users: $all_users"
		read -p "Enter the user name you want to generate the configuration file: " user_name
	done
fi


user_seq_num=`cat $addresses_data_path | awk -v user_name="$user_name" '$1==user_name {print$2}'`
user_priv_key=`cat $addresses_data_path | awk -v user_name="$user_name" '$1==user_name {print$3}'`
main_pub_key=`cat $addresses_data_path | awk -v user_name="$tech_user_name" '$1==user_name {print$4}'`


new_user_config_text="\n[Interface]
\nPrivateKey = $user_priv_key
\nAddress = 10.0.0.$user_seq_num/32
\nDNS = 8.8.8.8
\n
\n[Peer]
\nPublicKey = $main_pub_key
\nEndpoint = 3.71.205.243:51830
\nAllowedIPs = 0.0.0.0/0
\nPersistentKeepalive = 20"

#reminder: add genereate file
#reminder: test it
