#!/bin/bash

install_libvirt() {
    yay -Rdd --noconfirm iptables # we're installing iptables-nft below
    yay -S --noconfirm virt-manager qemu-desktop vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf
}

configure_libvirtd_conf() {
    # replace "# unix_sock_group = "libvirt"" with "unix_sock_group = "libvirt""
    sudo sed -i 's/# unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
    # replace "# unix_sock_rw_perms = "0770"" with "unix_sock_rw_perms = "0770""
    sudo sed -i 's/# unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf

    echo -e "log_filters=\"3:qemu 1:libvirt\"\nlog_outputs=\"2:file:/var/log/libvirt/libvirtd.log\"" | sudo tee -a /etc/libvirt/libvirtd.conf
}

configure_qemu_conf() {
    # replace "#user = "root"" with "user = "me""
    sudo sed -i "s/#user = \"root\"/user = \"$(whoami)\"/g" /etc/libvirt/qemu.conf
    # replace "#group = "root"" with "group = "me""
    sudo sed -i "s/#group = \"root\"/group = \"$(whoami)\"/g" /etc/libvirt/qemu.conf
}

create_rom() {
    sudo chmod +x amdvbflash

    sudo systemctl stop sddm
    sudo rmmod drm_kms_helper
    sudo rmmod amdgpu
    sudo rmmod radeon

    sudo ./amdvbflash -s 0 vbios.rom

    sudo modprobe drm_kms_helper
    sudo modprobe amdgpu
    sudo modprobe radeon

    sudo systemctl restart sddm

    sudo mkdir -p /usr/share/vgabios
    sudo cp vbios.rom /usr/share/vgabios/
    sudo chmod 755 /usr/share/vgabios/vbios.rom
}

setup_libvirt_scripts() {
    git clone https://gitlab.com/akshaycodes/vfio-script 

    cd vfio-script || exit 1

    # replace win10 to win11 in hooks/qemu
    sed -i 's/win10/win11/g' hooks/qemu

    # after:
    #     echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
    # add:
    #     echo 'device_specific' > /sys/bus/pci/devices/0000:0c:00.0/reset_method
    # sed -i 's/echo efi-framebuffer.0 > \/sys\/bus\/platform\/drivers\/efi-framebuffer\/unbind/echo efi-framebuffer.0 > \/sys\/bus\/platform\/drivers\/efi-framebuffer\/unbind\n\techo "device_specific" > \/sys\/bus\/pci\/devices\/0000:0c:00.0\/reset_method/g' hooks/qemu

    sudo chmod +x vfio_script_install.sh
    sudo ./vfio_script_install.sh
}

cd ~/passthrough || {
    echo "make a ~/passthrough directory, download the amdvbflash binary from TechPoweredUp and put it in that folder."
    exit 1
}

install_libvirt
configure_libvirtd_conf
configure_qemu_conf
setup_libvirt_scripts

create_rom

sudo virsh net-autostart default

sudo usermod -a -G libvirt "$(whoami)"

sudo systemctl enable --now libvirtd

echo "Keep following the steps listed in https://gitlab.com/risingprismtv/single-gpu-passthrough's wiki. This script only did steps 4, 6, and 7. The AMD GPU's flash has been placed in /usr/share/vgabios/vbios.rom. You must do the rest."
echo -e "\n\n"
echo "REMEMBER TO MAKE THE VIRTUAL MACHINE NAME 'win11'. IF THAT'S NOT THE NAME, YOU MUST CHANGE THE NAME IN /etc/libvirt/hooks/qemu."
