#! /bin/sh

docker-compose down

# for 42 PC issue
docker run --rm -v $(pwd):/data alpine sh -c "rm -rf /data/certs"
docker run --rm -v $(pwd):/data alpine sh -c "rm -rf /data/config"
docker run --rm -v $(pwd):/data alpine sh -c "rm -rf /data/elastic_data"

#rm -rf certs
#rm -rf config
#rm -rf elastic_data
rm -rf .env
