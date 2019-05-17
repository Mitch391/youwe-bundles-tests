#!/usr/bin/env bash

user=$(id -nu)
uid=$(id -u)
gid=$(id -g)

#Removing containers and images
docker-compose stop --volumes --remove-orphans --rmi all

#Removing var directories
bash -c "rm -rf vendor/ var/ web/var/ web/bundles/"

#Warming up var directories
bash -c "mkdir var/"
bash -c "cp -r app/Resources/docker/mysql/log var/mysql/"
bash -c "cp -r app/Resources/docker/php/log var/php/"
bash -c "cp -r app/Resources/docker/apache/log var/apache/"

#Building images
docker-compose build --build-arg user=${user} --build-arg uid=${uid} --build-arg gid=${gid} "mysql-${PIMCORE_VERSION}" "redis-${PIMCORE_VERSION}" "php-${PIMCORE_VERSION}" "apache-${PIMCORE_VERSION}"

#Starting containers
docker-compose up --no-build --remove-orphans -d "mysql-${PIMCORE_VERSION}" "redis-${PIMCORE_VERSION}" "php-${PIMCORE_VERSION}" "apache-${PIMCORE_VERSION}"

echo "Waiting for comtainers to boot..."
sleep 5

echo Installing composer packages
docker-compose exec php-${PIMCORE_VERSION} bash -c "COMPOSER_MEMORY_LIMIT=-1 composer install --no-suggest --no-interaction --dev -vvv"

echo Installing pimcore
docker-compose exec php-${PIMCORE_VERSION} bash -c "vendor/bin/pimcore-install --env=dev --ignore-existing-config --no-interaction -vvv"

echo Installing assets
docker-compose exec php-${PIMCORE_VERSION} bash -c "bin/console assets:install --env=dev --symlink -vvv"

echo clearing symfony cache
docker-compose exec php-${PIMCORE_VERSION} bash -c "bin/console cache:clear --env=dev --no-interaction --no-warmup -vvv"

echo clearing pimcore cache
docker-compose exec php-${PIMCORE_VERSION} bash -c "bin/console pimcore:cache:clear --env=dev --no-interaction -vvv"
