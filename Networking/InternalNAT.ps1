Get-NetAdapter

# Create an internal switch.
New-VMSwitch -Name "InternalAzure" -SwitchType Internal
Remove-VMSwitch -Name "InternalAzure" -Force


# Set Gateway and mask (PrefixLenght = 25 for 255.255.255.128) 255.255.255.192 = 26
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex 19
New-NetIPAddress –IPAddress 192.168.10.65 -PrefixLength 26 -InterfaceAlias "vEthernet (InternalNAT)"

Get-NetIPAddress -InterfaceIndex 10

Remove-NetIPAddress -IPAddress fe80::7978:e944:8164:7360%23 -PrefixLength 64 -InterfaceIndex 23

# Create the NAT network.  The NAT subnet prefix describes both the NAT Gateway IP prefix from above as well as the NAT Subnet Prefix Length from above. The generic form will be a.b.c.0/NAT Subnet Prefix Length.
Get-NetNat
New-NetNat -Name "InternalNat" -InternalIPInterfaceAddressPrefix 192.168.129.0/24

Remove-NetNat -Name "InternalNat"


# Port Forwarding
netsh interface portproxy add v4tov4 listenport=55551 listenaddress=192.168.10.73 connectport=3389 connectaddress=192.168.129.1
netstat -ano | findstr :55551
# Show all proxy forwards
netsh interface portproxy show all
# Remove Port Forwarding
netsh interface portproxy delete v4tov4 listenport=55551 listenaddress=192.168.10.73

# Test opend port
Test-NetConnection -ComputerName 192.168.10.73 -Port 55551
Test-NetConnection -ComputerName 10.0.0.4 -Port 55551
Test-NetConnection -Port 50001 "NadiaDev.mhshouse.local"



# Enable port on the firewall
netsh advfirewall firewall add rule name=”forwarded_RDPport_3340” protocol=TCP dir=in localip=10.0.0.4  localport=55551 action=allow

New-NetFirewallRule -DisplayName "NAT_RDP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 55551

