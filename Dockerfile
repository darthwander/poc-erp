FROM php:8.3-fpm

ARG user=refuturiza
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm \
    supervisor

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets


# Instalar dependências necessárias para a extensão intl
RUN apt-get update && apt-get install -y libicu-dev

# Instalar a extensão intl
RUN docker-php-ext-install intl

# Instalar dependências para a extensão zip
RUN apt-get update && apt-get install -y libzip-dev

# Instalar a extensão zip
RUN docker-php-ext-install zip


# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Install redis
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

#Install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Instalar dependências necessárias para a extensão intl
RUN apt-get update && apt-get install -y libicu-dev

# Instalar a extensão intl
RUN docker-php-ext-install intl

# Instalar a extensão zip
RUN docker-php-ext-install zip


# Copiar configuração do Xdebug
COPY docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Set working directory
WORKDIR /var/www

# Copy custom configurations PHP
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini

# Copy supervisord configuration
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

USER $user

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


