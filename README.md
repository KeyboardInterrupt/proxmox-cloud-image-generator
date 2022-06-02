# proxmox-cloud-image-generator
Highly configurable script that automates generation of ubuntu's cloud image templates. 
Customize the cloud image using the script without manually editing settings using GUI. 

Script allows you to specify:
- Ubuntu Release: 20.04 / 21.10 / 22.04 / 22.10 (Default: 22.04)
- Template name (Default: ubuntu-22.04-cloudimg)
- Proxmox's Storage Pool where template will be saved (Default: local-lvm)
- Template VM ID (Default 10000)
- Credentials (Default: boris/secret)
- Packages that you would like to add to the final image such as `htop` (Default: qemu-guest-agent)

# Usage:

## Download the script
```shell
wget -O proxmox-cloud-image-generator.sh "https://raw.githubusercontent.com/bermanboris/proxmox-cloud-image-generator/main/proxmox-cloud-image-generator.sh"
```

## Configure the script using provided variables
```shell
nano proxmox-cloud-image-generator.sh
```

```shell
export UBUNTU_RELEASE="22.04" # Available versions: 20.04, 21.10, 22.04, 22.10
export VM_NAME="ubuntu-${UBUNTU_RELEASE}-cloudimg"
export STORAGE_POOL="local-lvm"
export VM_ID="10000"
export USERNAME="boris"
export PASSWORD="secret"

# You can add your own packages by splitting them with comma between
export PACKAGES_TO_INSTALL="qemu-guest-agent,htop"
```

## Run the script
```shell
bash proxmox-cloud-image-generator.sh
```

> Approximate size of downloaded Ubuntu image is `597M`. 


# Roadmap

- [x] Set credentials
- [x] Set VM name 
- [x] Choose ubuntu release easily
- [ ] Provide SSH key using the script  
- [ ] Remove temp directory created by the script
