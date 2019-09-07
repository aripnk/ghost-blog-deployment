#!/bin/bash
# Preparations
# To run this script without any modification, you should have mailgun account.
# This default script is using sql as database backend and mailgun as the email provider

function init() {
  # Useful paths
  readonly orig_cwd="$PWD"
  readonly script_path="${BASH_SOURCE[0]}"
  readonly script_dir="$(dirname "$script_path")"
  readonly script_name="$(basename "$script_path")"
  readonly config_file=$(dirname "$script_path")/config.conf
  readonly nginx_conf=${orig_cwd}/nginx/nginx.conf
  source ${config_file}
  while read LINE; do export "$LINE"; done < ${config_file}
}

function prepare_nginx_config(){
  sed -i "s/example.org/${domain_name}/g" ${nginx_conf}
  mkdir -p ${blog_root_directory}/ssl
  openssl dhparam -out ${blog_root_directory}/ssl/dhparams.pem 2048
}

function generate_dummy_certs() {
  path="/etc/letsencrypt/live/${domain_name}"
  mkdir -p "${blog_root_directory}/certbot/conf/live/${domain_name}"
  openssl req -x509 -nodes -newkey rsa:1024 -days 1 \
    -keyout ${blog_root_directory}/certbot/conf/live/${domain_name}/privkey.pem \
    -out ${blog_root_directory}/certbot/conf/live/${domain_name}/fullchain.pem \
    -subj /CN=localhost
}

function run_ghost_nginx() {
  docker-compose up --force-recreate -d ghost
  docker-compose up --force-recreate -d nginx
}

function certbot_cert_request() {
  docker-compose run --rm --entrypoint "\
    rm -rf /etc/letsencrypt/live/${domain_name} && \
    rm -rf /etc/letsencrypt/archive/${domain_name} && \
    rm -rf /etc/letsencrypt/renewal/${domain_name}.conf" certbot

  docker-compose run --rm --entrypoint "\
    certbot certonly --webroot -w /var/www/certbot \
      --register-unsafely-without-email \
      -d ${domain_name} \
      --rsa-key-size 2048 \
      --agree-tos \
      --force-renewal" certbot
}

init

if [[ ! -d "${blog_root_directory}/certbot" ]]; then
  prepare_nginx_config
  generate_dummy_certs
  run_ghost_nginx
  certbot_cert_request
fi

docker-compose down
docker-compose up -d



################################################################################
################################################################################
