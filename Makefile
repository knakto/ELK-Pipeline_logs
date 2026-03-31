all: setup

up:
	docker-compose up -d

down:
	docker-compose down

prune:
	docker system prune -a

clean: down prune uninstall

setup:
	bash setupELK.sh

uninstall:
	bash uninstallELK.sh

re: down up

.PHONY: up down prune clean setup uninstall re all
