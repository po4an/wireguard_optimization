#!/bin/bash
if [ "$USER" = "root" ]; then
	wireguard_path=`whereis wireguard | awk -F ": " '{print $2}'`
	tech_user_name='main_interface'
	addresses_data_path=$wireguard_path'/addresses_data.txt'
	config_path="/home/$USER/wireguard_configs"
	all_users=`cat $addresses_data_path | awk -v tech_user_name="$tech_user_name" '$1!=tech_user_name {print$1}'`
	all_users_with_delimiter=`echo $all_users | xargs -o | tr -s ' ' '|'`
	main_server_ip=`wget -qO- eth0.me`
	main_server_port=51830

	# Write the first argument to the user_name variable. If the argument is not given, specify for which user the configuration file should be made.
	# Validating whether there is such a user in the metadata
	user_name=$1
	if [ -z "$user_name" ]; then
		while [ `echo $user_name | grep -E -ie "^($all_users_with_delimiter)\$" | wc -w` != 1 ]; do
			echo "\nList of active users: \n$all_users"
			read -p "Enter the user name you want to generate the configuration file: " user_name
		done
	fi

	user_seq_num=`cat $addresses_data_path | awk -v user_name="$user_name" '$1==user_name {print$2}'`
	user_priv_key=`cat $addresses_data_path | awk -v user_name="$user_name" '$1==user_name {print$3}'`
	main_pub_key=`cat $addresses_data_path | awk -v user_name="$tech_user_name" '$1==user_name {print$4}'`

	# Defining the contents of the configuration file
	new_user_config_text="\n[Interface]
	\nPrivateKey = $user_priv_key
	\nAddress = 10.0.0.$user_seq_num/32
	\nDNS = 8.8.8.8
	\n
	\n[Peer]
	\nPublicKey = $main_pub_key
	\nEndpoint = $main_server_ip:$main_server_port
	\nAllowedIPs = 0.0.0.0/0
	\nPersistentKeepalive = 20"

	# Create a folder with all the configuration files, if it does not exist
	mkdir -p $config_path

	# Create a configuration file for the selected user and restrict access to it
	conf_file_path=$config_path"/"$user_name".conf"
	echo $new_user_config_text > $conf_file_path
	chmod 600 $conf_file_path

	echo "\nSuccessful! The configuration file was created and is located at the path: $conf_file_path
	\nUse it on the device where you want to use VPN"
else
	echo "\nThe script has to be run as root user
		\nAdd 'sudo' to the beginning of the script:
		\nsudo sh generate_user_conf.sh"
fi
