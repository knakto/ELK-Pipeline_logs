#! /bin/sh

#=================
### color code
#=================
RESET="\e[0m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"

#=================
### setup .env
#=================
if [ ! -f .env ]; then
  echo -e $YELLOW"Generate .env file . . ."$RESET

  ELASTIC_USER=elastic
  ELASTIC_PASSWORD=iamElastic

  echo "ELASTIC_USER=$ELASTIC_USER" > .env
  echo "ELASTIC_PASSWORD=$ELASTIC_PASSWORD" >> .env

  echo -e $GREEN"Generate .env file success"$RESET
else
  echo -e $GREEN"Already have .env file"$RESET
fi

#==================
### setup directory
#==================
mkdir -p ./certs/ && echo -e $GREEN"create directory [ cert ] success"$RESET
mkdir -p ./elastic_data/ && echo -e $GREEN"create directory [ elastic_data ] success"$RESET
mkdir -p ./config/ && echo -e $GREEN"create directory [ config ] success"$RESET

#==================
### setup logstash
#==================
if [ ! -f ./config/logstash.conf ]; then
echo -e $YELLOW"Generate logstash.conf file . . ."$RESET

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
    password => "\${ELASTIC_PASSWORD}"
    ssl_enabled => true
    ssl_certificate_authorities => ["/usr/share/logstash/config/certs/ca.crt"]
    ssl_verification_mode => "full"
  }
}
EOF

  echo -e $GREEN"Generate logstash.conf file success"$RESET
else
  echo -e $GREEN"Already have logstash.conf file"$RESET
fi

#==================
### setup Cert Auth
#==================
if [ ! -f ./certs/ca.crt ]; then
  echo -e $YELLOW"Generating certificate . . ."$RESET
  cd ./certs/

  # create ca.crt and ca.key for a parent cert
  openssl req -x509 -new -nodes -newkey rsa:2048 -keyout ca.key -sha256 -days 3650 -out ca.crt -subj "/CN=MyKey-CA"

  # make a child cert (server.crt, sertver.csr and server.key) from parent
  openssl req -new -nodes -newkey rsa:2048 -keyout server.key -out server.csr -subj "/CN=elasticsearch"
  # add SAN -> DNS, Ip, keyUsage, extendedKeyUsage
  openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256 -extfile <(printf "subjectAltName=DNS:localhost,DNS:elasticsearch,DNS:kibana,IP:127.0.0.1\nkeyUsage=digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth,clientAuth")

  cd ..
  echo -e $GREEN"Generate certificate success"$RESET
else
  echo -e $GREEN"Already have certificate"$RESET
fi

#==================
### setup access token
#==================
if [ ! -f ./certs/service_tokens ]; then
  echo -e $YELLOW"Setting up elasticsearch access token . . ."$RESET
  sed -i '/service_tokens/s/^/# /' docker-compose.yml

  docker-compose up -d elasticsearch

  ALL_TOKEN=$(docker exec -i elasticsearch /usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token)
  echo "ELASTICSEARCH_SERVICEACCOUNTTOKEN=$(echo $ALL_TOKEN | awk '{print $4}')" >> .env

  docker exec -it elasticsearch cat ./config/service_tokens > ./certs/service_tokens

  sed -i '/service_tokens/s/^# //' docker-compose.yml
  echo -e $GREEN"Generate access token success"$RESET
else
  echo -e $GREEN"Already have access token"$RESET
fi

docker-compose up -d
