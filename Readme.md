# Carefull

## don't delete ELASTICSEARCH_SERVICEACCOUNTTOKEN

that's a token give to kibana for use it back to elasticsearch, and elasticsearch will trust kibana
every thing depens on secure that's why if you delete it you must generate new one `manually`.

`service_token <<- turst ->> ELASTICSEARCH_SERVICEACCOUNTTOKEN`

## http.p12

that's a CA (Certificate Authenticate) generate from `elasticsearch` that have two path to use

- use on website certificate for rendering everything in https with TSL/SSL
- use for communicate with each container secure

if you delete it you have to generate it again `manually`
and you have to set **SERVER_SSL_KEYSTORE_PASSWORD** again follow config when you generate cert
