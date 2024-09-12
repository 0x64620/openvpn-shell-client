#!/usr/bin/env bash

source ~/.config/openvpn/config.conf

openvpn-connect() {
    sudo screen -dmS openvpn-session openvpn $openVpnConfigFile
    sleep 5
    sudo resolvectl dns tun0 $DNS_ADDR
    sudo resolvectl domain tun0 "~domain.lan"
    echo "OpenVPN connected."
}

openvpn-status() {
    if ip a show tun0 &>/dev/null; then
        echo "Interface tun0 is active"
        ip_addr=$(ip -o -f inet addr show tun0 | awk '{print $4}' | cut -d/ -f1)
        conn_time=$(sudo screen -ls | grep openvpn-session | awk '{print $1}')
        echo "IP: $ip_addr"
        echo "Screen session: $conn_time"
    else
        echo "OpenVPN not connected."
    fi
}

openvpn-disconnect() {
    sudo resolvectl revert tun0
    sudo screen -S openvpn-session -X quit
    echo "OpenVPN disconnected."
}
