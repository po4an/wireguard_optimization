#!/bin/bash
wireguard_path=`whereis wireguard | awk -F ": " '{print $2}'`
addresses_data_path=$wireguard_path'/addresses_data.txt'
main_conf_path=$wireguard_path'/wg0.conf'
main_pub_key_path=$wireguard_path'/publickey'
port=51830
tech_user_name='main_interface'
all_users=`cat $addresses_data_path | awk -v tech_user_name="$tech_user_name" '$1!=tech_user_name {print$1}'`
all_users_with_delimiter=`echo $all_users | xargs -o | tr -s ' ' '|'`

# Let's read the name of the new user and check if there is already one
new_user_name=""
while [ -n $new_user_name && `echo $new_user_name | grep -E -ie '^('+$all_users_with_delimiter+')$' | wc -w` == 0 ]; do
	echo "List of active users: $all_users
	The username must be unique"
	read -p "Please set the name of the new user: " new_user_name
done

# Define the number of the new user
new_user_seq_num=`awk 'BEGIN{a=0}{if ($2>a) a = $2} END{print a+1}' $addresses_data_path`
priv_key_path=$wireguard_path$new_user_name'_privatekey'
pub_key_path=$wireguard_path$new_user_name'_publickey'

# Generate the keys for the new user
wg genkey | tee $priv_key_path | wg pubkey | tee $pub_key_path > /dev/null
chmod 600 $priv_key_path

# Write the metadata for the new user
echo $new_user_name' '$new_user_seq_num' '`cat $priv_key_path`' '`cat $pub_key_path` >> $addresses_data_path

# Let's write the information about the new user in the main config file
new_user_peer_text="\n[Peer]
\nPublicKey = `cat $pub_key_path`
\nAllowedIPs = 10.0.0.$new_user_seq_num/32"

echo $new_user_peer_text >> $main_conf_path

# Restart wireguard and check its status
systemctl restart wg-quick@wg0
if [ `systemctl status wg-quick@wg0.service | awk '$1=="Active:" {print tolower($2)}'` == "active" ]; then
	echo "The Wireguard service has active status"
else
	echo "The Wireguard service has inactive status"
fi

echo "The user $new_user_name successfully added!"

# Let's ask the user if he wants to make a configuration file
conf_file_adding_answer="null"
while [ `echo $conf_file_adding_answer | grep -E -ie '^(yes|no)$' | wc -w` != 1 ]; do
	read -p "Do you want to add a configuration file for a new user right now (yes/no)?" conf_file_adding_answer
done

if [ echo $conf_file_adding_answer | tr '[:upper:]' '[:lower:]' == 'yes' ]; then
	echo "Ok, running the generate_user_conf.sh script"
	sh generate_user_conf.sh $new_user_name
else
	echo "Ok, you can add a configuration file whenever you want by running the generate_user_conf.sh script"
fi
