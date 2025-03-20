stack_name = gratuite_inscription
source_tag = dev
php_image_name = github.com/dieek26/gratuite-inscription/php-fpm

php_sources = src/
php_container_id = $(shell docker ps --filter name="$(stack_name)_php" -q)
user = $(shell id -u)

node_version = 24

default: console

# SHELL
.PHONY: shell
shell:
	docker exec -it $(php_container_id) /bin/sh

.PHONY: bash
bash:
	docker exec -it $(php_container_id) /bin/bash

.PHONY: command
command:
	docker exec -it $(php_container_id) $(cmd)

# UTILS
.PHONY: cs-check
cs-check:
	docker run --rm -i -v `pwd`:`pwd` -w `pwd` cytopia/php-cs-fixer --rules=@Symfony --verbose fix $(php_sources) --dry-run

.PHONY: cs-fix
cs-fix:
	docker run --rm -i -v `pwd`:`pwd` -w `pwd` cytopia/php-cs-fixer --rules=@Symfony --verbose fix $(php_sources)

.PHONY: test-unit
test-unit:
	docker exec -u www-data -it "$(php_container_id)" php vendor/bin/phpunit $(options)

# SYMFONY
.PHONY: console
console:
	docker exec -u www-data -it "$(php_container_id)" php $(php_options) bin/console $(cmd)

.PHONY: composer
composer:
	docker exec -u www-data -it "$(php_container_id)" php -d memory_limit=-1 /usr/local/bin/composer $(cmd)

.PHONY: composer-update
composer-update:
	docker exec -u www-data -it "$(php_container_id)" php -d memory_limit=-1 /usr/local/bin/composer update $(cmd)

.PHONY: composer-install
composer-install:
	docker exec -u www-data -it "$(php_container_id)" php -d memory_limit=-1 /usr/local/bin/composer install --no-interaction

# NODE
.PHONY: yarn
yarn:
	docker run --rm -it -v `pwd`:/usr/src/app -w /usr/src/app node:$(node_version) yarn $(cmd)

.PHONY: encore
encore:
	docker run --rm -it -v `pwd`:/usr/src/app -w /usr/src/app node:$(node_version) yarn encore dev $(options)

.PHONY: encore-production
encore-production:
	docker run --rm -it -v `pwd`:/usr/src/app -w /usr/src/app node:$(node_version) yarn encore production $(options)

# IMAGES
.PHONY: build-image
build-image:
	docker build --target=$(source_tag) -t $(php_image_name):$(source_tag) -f .docker/php/Dockerfile .

.PHONY: push-image
push-image:
	docker push $(php_image_name):$(source_tag)

# PROJECT
.PHONY: start
start:
	docker stack deploy -c .docker/docker-compose.yaml $(stack_name)

.PHONY: stop
stop:
	docker stack rm $(stack_name)