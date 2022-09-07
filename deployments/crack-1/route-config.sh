# Comandi per configurare come gateway il container con suricata

# Da eseguire nel container con suricata
# Abilita l'inoltro del traffico sull'interfaccia eth0 (quella di default)
docker exec suricata sysctl -w net.ipv4.conf.eth0.route_localnet=1
# Il container deve avere la proprieta' privileged=true e capability "NET_ADMIN" attiva
# docker exec suricata iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
# Fa passare il traffico dalla rete esterna (extnet) alla dmz
docker exec suricata iptables -I FORWARD -s 172.30.0.0/16 -d 192.168.88.0/21 -j ACCEPT
# Traffico dalla dmz a quella esterna
docker exec suricata iptables -I FORWARD -s 192.168.88.0/21 -d 172.30.0.0/16 -j ACCEPT
# Blocca traffico da rete esterna a quella interna
docker exec suricata iptables -I FORWARD -s 172.30.0.0/16 -d 192.168.80.0/21 -j DROP


# Host nella rete esterna
#ip route add 192.168.80.0/20 via [indirizzo container suricata in sharednet]
docker exec client ip route add 192.168.88.0/21 via 172.30.0.2
docker exec client ip route add 192.168.80.0/20 via 172.30.0.2

# Host nella DMZ
docker exec webserver ip route add 172.30.0.0/16 via 192.168.88.2
docker exec webserver ip route add 192.168.80.0/21 via 192.168.88.2
docker exec dns ip route add 172.30.0.0/16 via 192.168.88.2
docker exec pyjail ip route add 172.30.0.0/16 via 192.168.88.2


# Host nella rete interna
docker exec postgres ip route add 192.168.88.0/21 via 192.168.80.8
