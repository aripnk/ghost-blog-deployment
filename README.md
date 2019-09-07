# Running Ghost with Docker

## Overview

This is deployment scripts to deploy ghost blog to a Linux box with docker-compose. This script will run ghost, nginx and certbot to get the Let's Encrypt SSL.

## Installation

### Requirements

* Docker
* Docker Compose
* Openssl


### Steps

* Copy or clone this repo to you box
* Make sure that your domain A record is already configured to your box
* Modify the `config.conf` file
* execute `ghostssl.sh`
