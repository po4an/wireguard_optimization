#!/bin/bash
if [ "$USER" = "root" ]; then
	echo "\nCheck if wireguard is installed"
	wireguard_path=`whereis wireguard | awk -F ": " '{print $2}'`
	if [ -n "$wireguard_path" ]; then

		tech_user_name='main_interface'
		tech_user_seq_num=1
		port=51830
		addresses_data_path=$wireguard_path'/addresses_data.txt'
		main_conf_path=$wireguard_path'/wg0.conf'
		priv_key_path=$wireguard_path'/privatekey'
		pub_key_path=$wireguard_path'/publickey'
		network_interface=`ip -br a show | awk '$1!="lo"{print $1}'`

		# Check if the init script was previously run
		if [ `cat $addresses_data_path | awk -v tech_user_name="$tech_user_name" '$1==tech_user_name {print $1}' | wc -w 2>/dev/null` != 0 ]; then
			echo "\nThe wireguard is already installed and configured"
		else
			echo "\nWireguard is installed and on the path: $wireguard_path
				\nStart setting it up"
			# Lets generate the main server keys
			wg genkey | tee $priv_key_path | wg pubkey | tee $pub_key_path > /dev/null
			chmod 600 $priv_key_path

			# Write the interface definition in the main configuration file
			init_interface_text="\n[Interface]
			\nPrivateKey = `cat $priv_key_path`
			\nAddress = 10.0.0.$tech_user_seq_num/24
			\nListenPort = $port
			\nPostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $network_interface -j MASQUERADE
			\nPostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $network_interface -j MASQUERADE"
			echo $init_interface_text > $main_conf_path


			# Turn on the ip forwarding
			echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
			sysctl -p

			# Run the wireguard service and check its status
			systemctl enable wg-quick@wg0.service
			systemctl start wg-quick@wg0.service
			if [ `systemctl status wg-quick@wg0.service | awk '$1=="Active:" {print tolower($2)}'` = "active" ]; then
				echo "\nThe Wireguard service has active status"
			else
				echo "\nThe Wireguard service has inactive status"
			fi

			# Create a metadata file that contains information about internal addresses. And add there the data about the first interface address
			touch $addresses_data_path
			echo $tech_user_name' '$tech_user_seq_num' '`cat $priv_key_path`' '`cat $pub_key_path` >> $addresses_data_path
			chmod 600 $addresses_data_path

			# Let's ask the user if he wants to add a new user right now
			new_user_adding_answer="null"
			while [ `echo $new_user_adding_answer | grep -E -ie '^(yes|no)$' | wc -w` != 1 ]; do
				read -p "Do you wand to add the first wireguard user right now (yes/no)? " new_user_adding_answer
			done

			if [ `echo $new_user_adding_answer | tr '[:upper:]' '[:lower:]'` = 'yes' ]; then
				echo "\nOk, running the wireguard_add_user.sh script"
				sh wireguard_add_user.sh
			else
				echo "\nOk, you can add a user whenever you want by running the wireguard_add_user.sh script"
			fi
		fi
	else
		echo "\nWireguard is not installed
			\nTry to update packeges and install it using the command:
			\nsudo apt update && sudo apt upgrade -y && sudo apt install -y wireguard
			\nAnd then run this script again"
	fi
else
	echo "\nThe script has to be run as root user
		\nAdd 'sudo' to the beginning of the script:
		\nsudo sh wireguard_init_script.sh"
fi
