#!/bin/sh

cd /var/www

mkdir -p src
cd src

if [ ! -f artisan ]; then
  echo "Laravel not found, creating project in /var/www/src..."
  composer create-project laravel/laravel . --prefer-dist "10.*"
  echo "Laravel 10 project created"

  if [ -f ../.env ]; then
    cp ../.env .env
    php artisan key:generate
  fi

  if [ -f ../package.json ]; then
    cp ../package.json .
    if [ ! -d node_modules ]; then
      echo "Installing node dependencies"
      npm install
      echo "Installed node dependencies"
    else
      echo "node_modules already exists, skipping npm install"
    fi
  fi

  echo "Copying Vue starter files..."
  mkdir -p resources/js/components
  mkdir -p resources/js/views
  mkdir -p resources/js/router
  cp ../vue/app.js resources/js/app.js
  cp ../vue/router.js resources/js/router/index.js
  cp ../vue/App.vue resources/js/views/App.vue
  cp ../vue/Home.vue resources/js/views/Home.vue  
  cp ../vue/welcome.blade.php resources/views/welcome.blade.php
  cp ../vue/vite.config.js .
  echo "Vue files copied."

fi



chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data .

php-fpm
