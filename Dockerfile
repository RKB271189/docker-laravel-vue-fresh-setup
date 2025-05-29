FROM php:8.2-fpm-alpine

ARG ENVIRONMENT=production
ENV ENVIRONMENT=${ENVIRONMENT}

WORKDIR /var/www

RUN apk add --no-cache \
    bash \
    curl \
    git \
    unzip \
    libzip-dev \
    zlib-dev \
    icu-dev \
    oniguruma-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    mysql-client \
    postgresql-dev \
    libxml2-dev \
    shadow \
    supervisor \
    nodejs \
    npm

RUN docker-php-ext-configure zip \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        zip \
        intl \
        mbstring \
        exif \
        pcntl \
        bcmath \
        opcache

RUN if [ "$ENVIRONMENT" = "local" ]; then \
    apk add --no-cache autoconf gcc g++ make linux-headers; \
    pecl install xdebug && docker-php-ext-enable xdebug; \
    fi

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY ./ /var/www

RUN usermod -u 1000 www-data && \
    chown -R www-data:www-data /var/www && \
    chmod -R 755 /var/www/storage /var/www/bootstrap/cache || true

EXPOSE 9000

CMD ["php-fpm"]

COPY entry.sh /usr/local/bin/entry.sh
RUN chmod +x /usr/local/bin/entry.sh

ENTRYPOINT ["entry.sh"]