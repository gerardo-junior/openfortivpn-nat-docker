#!/bin/sh

mkdir -p /etc/openfortivpn

if [ ! -z "$HOST" ] && [ ! -z "$PORT" ] && [ ! -z "$USERNAME" ] && [ ! -z "$PASSWORD" ]; then
    echo  "host=$HOST
           port=$PORT
           username=$USERNAME
           password=$PASSWORD" > /etc/openfortivpn/config

elif [ -f /openfortivpn.conf ];then
    cp /openfortivpn.conf /etc/openfortivpn/config
fi 

if [ ! -z "$TRUST_ALL" ];then
    echo "trusted-cert=$(openfortivpn | grep 'trusted-cert =' | head -n 1 | awk '{print $4}')" >> /etc/openfortivpn/config
fi

if [ ! -z "$PORT_BINDS" ];then

    echo $PORT_BINDS | tr ";" "\n" | while read line; do
        if [ ! -z "$line" ];then

            PORT_BIND=$(echo $line | tr ":" " ")
            PORT_BIND_PORT=$(echo $PORT_BIND | awk '{print $1}' | head -n 1)
            PORT_BIND_TO_HOST=$(echo $PORT_BIND | awk '{print $2}' | head -n 1)
            PORT_BIND_TO_PORT=$(echo $PORT_BIND | awk '{print $3}' | head -n 1)

            if ! expr "$PORT_BIND_TO_HOST" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
                PORT_BIND_TO_HOST=$(host -t a $PORT_BIND_TO_HOST | awk '{print $4}' | head -n 1)
            fi

            iptables -t nat -A PREROUTING -p tcp --dport $PORT_BIND_PORT -j DNAT --to-destination $PORT_BIND_TO_HOST:$PORT_BIND_TO_PORT

            echo "INFO:   Port binding $(hostname -i):$PORT_BIND_PORT -> $PORT_BIND_TO_HOST:$PORT_BIND_TO_PORT"
            
        fi
    done
    
    iptables -t nat -A POSTROUTING -j MASQUERADE

fi

if [ ! -z "$@" ];then
    exec $@
else
    openfortivpn
fi

