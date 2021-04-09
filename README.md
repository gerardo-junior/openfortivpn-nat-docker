# to do -> create a decent readme


# Example

```bash
docker run -it \                                                      
            --rm \
            --cap-add=NET_ADMIN \
            --device=/dev/ppp \
            -e HOST=[VPN IP]\
            -e PORT='443' \
            -e USERNAME='[YOUR USER]' \
            -e PASSWORD='[YOUR PASSWORD]' \
            -e TRUSTALL=true \
            -e PORT_BINDS="[BIND TO CONTAINER PORT]:[IP OF REMOTE HOST]:[PORT OF REMOTE HOST]" \ # EX. PORT_BINDS="3389:192.168.0.15:3389" -> to this ip of remote network with [CONTAINER IP OU LOCALHOST]:3389
            gerardojunior/openfortivpn-nat
```
