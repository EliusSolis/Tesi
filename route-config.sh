# Comandi per configurare come gateway il container con suricata

# Da eseguire nel container con suricata
# Abilita l'inoltro del traffico sull'interfaccia eth0 (quella di default)
docker exec dsiem sysctl -w net.ipv4.conf.eth0.route_localnet=1
# Il container deve avere la proprieta' privileged=true e capability "NET_ADMIN" attiva
docker exec dsiem iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
# Fa passare il traffico dalla rete esterna (sharednet) a quella interna (siemnet)
docker exec dsiem iptables -I FORWARD -s 172.30.0.0/16 -d 192.168.80.0/20 -j ACCEPT
# Traffico dalla rete interna a quella esterna
docker exec dsiem iptables -I FORWARD -s 192.168.80.0/20 -d 172.30.0.0/16 -j ACCEPT


# Da eseguire sugli host che devono comunicare con la rete interna
#ip route add 192.168.80.0/20 via [indirizzo container suricata in sharednet]
docker exec client ip route add 192.168.80.0/20 via 172.30.0.2

# Da eseguire sugli host che devono comunicare con la rete interna
#ip route add 172.30.0.0/16 via [indirizzo container suricata in siemnet]
docker exec web-server ip route add 172.30.0.0/16 via 192.168.80.6
