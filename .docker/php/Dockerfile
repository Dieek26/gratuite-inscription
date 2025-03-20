#####################
### STAGE 0: Base ###
#####################

FROM php:8.4-fpm AS base

## Install dependencies
RUN apt update \
    && apt install -y git rsync libzip-dev zip libpq-dev libicu-dev \
    # Install pdo & pgsql
    && docker-php-ext-install pdo pgsql pdo_pgsql \
    # Install intl
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    # Install redis
    && pecl install redis \
    && docker-php-ext-enable redis \
    # Install opcache
    && docker-php-ext-install opcache \
    # Instal zip
    && docker-php-ext-install zip \
    # Instal pcntl
    && docker-php-ext-configure pcntl \
    && docker-php-ext-install pcntl

## Add php.ini configuration and the entrypoint script
ADD .docker/php/php.ini /usr/local/etc/php/php.ini
ADD .docker/php/entrypoint.sh /entrypoint.sh

WORKDIR /var/www/app

## Copy App files
#COPY composer.json composer.lock symfony.lock .env* package.json webpack.config.js ./
COPY composer.json composer.lock symfony.lock .env* ./
#COPY assets assets/
COPY bin bin/
COPY config config/
#COPY migrations migrations/
COPY public public/
COPY src src/
#COPY templates templates/
#COPY translations translations/

## Create empty var cache and var log directory
RUN mkdir -p /var/www/app/var/cache /var/www/app/var/log

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm", "-F"]

######################
### STAGE 1: Build ###
######################

FROM base AS build

## Install composer 2
ADD ["https://getcomposer.org/installer", "https://composer.github.io/installer.sig", "./"]
RUN php ./installer --2 --install-dir="/usr/local/bin/" --filename="composer" && rm -f installer installer.sig
RUN mkdir -p /var/www/.composer/cache && chown -R www-data /var/www/.composer

## Install App dependencies (using composer in PROD env)
ARG APP_ENV=prod
ENV APP_ENV=${APP_ENV}
RUN set -eux; \
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-scripts --no-suggest --no-interaction --no-dev --prefer-dist --optimize-autoloader; \
    composer dump-autoload --optimize --classmap-authoritative;

## Install App assets
RUN php /var/www/app/bin/console assets:install

## Install node and npm using nvm
ENV NVM_DIR=/usr/local/nvm
ENV NODE_VERSION=24

## Build assets
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash -
#RUN . $NVM_DIR/nvm.sh \
#    && nvm install $NODE_VERSION \
#    && nvm alias default $NODE_VERSION \
#    && nvm use default \
#    && npm install --global yarn \
#    && yarn --version \
#    && yarn install \
#    && yarn encore production

ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

####################
### STAGE 2: Dev ###
####################

FROM build AS dev

## Install xDebug (putted at the end - CLUDGE)
RUN pecl install xdebug-3.4.2 && docker-php-ext-enable xdebug

#####################
### STAGE 3: Prod ###
#####################

FROM base AS prod

## Define environment vars
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}
ARG APP_ENV=prod
ENV APP_ENV=${APP_ENV}

## Copy built vendors
COPY --from=build /var/www/app/vendor /var/www/app/vendor

## Copy built assets and bundles in order to use and share them (entrypoint)
COPY --from=build /var/www/app/public/build /usr/local/share/public/build/
COPY --from=build /var/www/app/public/bundles /usr/local/share/public/bundles/

## Define volumes
VOLUME /var/www/app/var/cache
VOLUME /var/www/app/var/log
VOLUME /var/www/app/var/import
VOLUME /var/www/app/public/build
VOLUME /var/www/app/public/bundles
VOLUME /tmp
