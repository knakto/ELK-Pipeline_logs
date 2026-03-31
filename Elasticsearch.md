# elasticsearch

## what is elasticsearch

elasticsearch is a search-engine have an index to access to data

## setup elasticsearch secure

 - you must have `./cert/http.p12` if you don't have follow this

### generate cert

```bash
docker run --rm -it\
  -v $(pwd):/cert \
  elasticsearch:9.3.2 \
  /usr/share/elasticsearch/bin/elasticsearch-certutil http
```

they will ask you this question:

- CSR (Certificate Signing Request) its a certificate for comunicate to each node

```bash
Generate a CSR? [y/N]
# type [N]
```

- CA (Certificate Authenticate) its a SSL/TSL for use in https

```bash
Use an existing CA? [y/N]
# type [N]
```
- next it will ask you for password and how long this cert will valid

- generate certificate per node

```bash
Generate a certificate per node? [y/N]
# if you use a localhost to comunicate each node or use single node type [N]
# if not type [Y]
```

- next it will ask for DNS and IP you should type 
localhost, docker-service name to DNS and type
127.0.0.1 to IP

- next it will aks for password, in this case press Enter

- then it will show you path for certificate, type this path

```bash
/cert/elasticsearch-ssl-http.zip
```
and you can get cert http.p12 from elasticsearch/http.p12

### set env

set this to .env

- ELASTIC_PASSWORD="your_password_here"

- ELASTICSEARCH_SERVICEACCOUNTTOKEN="token_user_for_kibana"

### get service account token

you must do this manualy for get ELASTICSEARCH_SERVICEACCOUNTTOKEN

- comment this volume in elasticsearch service in docker-compose.yml

```yml
    - ./elasticsearch/service_tokens:/usr/share/elasticsearch/config/service_tokens
```
- run this command coppy token and press to ELASTICSEARCH_SERVICEACCOUNTTOKEN to .env

```bash
docker exec -it elasticsearch /usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token
```

- create new file in ./elasticsearch/service_tokens

- run this command and coppy output

```bash
docker exec -it elasticsearch cat ./config/service_tokens
```

- press output in ./elasticsearch/service_tokens

- uncomment in docker compose and restart docker-compose again
