ELASTIC_USER=elastic
ELASTIC_PASSWORD=iamElastic

echo "ELASTIC_USER=$ELASTIC_USER" > .env
echo "ELASTIC_PASSWORD=$ELASTIC_PASSWORD" >> .env

mkdir -p ./certs/
mkdir -p ./elastic_data/
mkdir -p ./config/

cat > ./config/logstash.conf <<EOF
input {
  tcp {
    port => 5000
  }
}
output {
  stdout{}
  elasticsearch {
    hosts => ["https://elasticsearch:9200"]
    index => "my-logs-%{+YYYY.MM.dd}"
    user => "\${ELASTIC_USER}"
    password => "s\${ELASTIC_PASSWORD}"
    ssl_enabled => true
    ssl_certificate_authorities => ["/usr/share/logstash/config/certs/ca.crt"]
    ssl_verification_mode => "full"
  }
}
EOF

cd ./certs/

# create ca.crt and ca.key for a parent cert
openssl req -x509 -new -nodes -newkey rsa:2048 -keyout ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=MyKey-CA"

# make a child cert (server.crt, sertver.csr and server.key) from parent
openssl req -new -nodes -newkey rsa:2048 -keyout server.key -out server.csr -subj "/CN=elasticsearch"
# add SAN -> DNS, Ip, keyUsage, extendedKeyUsage
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256 -extfile <(printf "subjectAltName=DNS:localhost,DNS:elasticsearch,DNS:kibana,IP:127.0.0.1\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth,clientAuth")

cd ..


sed -i '/service_tokens/s/^[[:space:]]*/&# /' docker-compose.yml

docker-compose up -d elasticsearch

ALL_TOKEN=$(docker exec -it elasticsearch /usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token)
echo "ELASTICSEARCH_SERVICEACCOUNTTOKEN=$(echo $ALL_TOKEN | awk '{print $4}')" >> .env
echo "ELASTICSEARCH_SERVICEACCOUNTTOKEN=$(echo $ALL_TOKEN | awk '{print $4}')"
echo "ELASTICSEARCH_SERVICEACCOUNTTOKEN=$TOKEN"

docker exec -it elasticsearch cat ./config/service_tokens > ./certs/service_tokens

sed -i '/service_tokens/s/^# //' docker-compose.yml

docker-compose up -d
