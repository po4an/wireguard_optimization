<h1 align="center">WireGuard optimization bash scripts</h1>

## Description

The project is designed to make working with [WireGuard](https://www.wireguard.com/) easier: to quickly configure the server and add new users.

Simplification is realized by several simple bash scripts:
* wg_init.sh
* wg_add_user.sh
* wg_generate_user_conf.sh

The project was inspired by the [video](https://www.youtube.com/watch?v=5Aql0V-ta8A) from the channel [Диджитализируй!](https://www.youtube.com/channel/UC9MK8SybZcrHR3CUV4NMy2g)


## Scripts description
### `wg_init.sh`
* Configures the main interface
* Turn on the ip forwarding
* Starts WireGuard service
* Creates a metadata file with users, internal addresses and keys

### `wg_add_user.sh`
* Configures and creates a peer for the new user
* Restarts the service
* Updates the metadata file

### `wg_generate_user_conf.sh`
* Creates a configuration file for an existing user that he can use to connect to VPN on his device

## How to use it?
***
### Minimal use
> Connecting to the server (I tested on ubuntu 20.04)

```bash
# Upgrade packages, install wireguard
sudo apt update && sudo apt upgrade -y && sudo apt install -y wireguard

# Run the script wg_init.sh
sudo sh wg_init.sh
```
> At the end of the script answer "yes" and then enter the user name (the wg_add_user.sh script started working here)

> Next, answer "yes" when asked about creating a configuration file (the wg_generate_user_conf.sh script started working here)

**That's it, now the server is configured, the user is added and we can start using the VPN**

```bash
# Display the configured file to be used on the device where we want to connect our VPN
cat /home/root/wireguard_configs/<The user name we entered earlier>.conf
```
> Use this file on the desired device and use VPN!

***
### How do I add a user?
>It is necessary to run the script wg_add_user.sh, then click "yes" to make the configuration file for the user.
Then read this file and use it on the device

```bash
# Run the script, click yes
sudo sh wg_add_user.sh

# And read the file
cat /home/root/wireguard_configs/<The user name we entered earlier>.conf
```
***
