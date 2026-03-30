ELASTIC_PATH = elasticsearch
ELASTIC_DATA_PATH = $(ELASTIC_PATH)/elastic_data

up:
	docker-compose up -d

down:
	docker-compose down

restart: down up

prune:
	docker system prune -a

clean: prune clean_elastic


#---------------- Elasticsearch --------------#

clean_elastic:
	rm -rf $(ELASTIC_DATA_PATH)/*
