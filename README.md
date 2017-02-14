# NGINX Host JIRA Unit [![Docker Pulls](https://img.shields.io/docker/pulls/handcraftedbits/nginx-unit-jira.svg?maxAge=2592000)](https://hub.docker.com/r/handcraftedbits/nginx-unit-jira)

A [Docker](https://www.docker.com) container that provides an
[Atlassian JIRA](https://www.atlassian.com/software/jira) unit for
[NGINX Host](https://github.com/handcraftedbits/docker-nginx-host).

# Features

* Atlassian JIRA 7.3.1
* NGINX Host SSL certificates are automatically imported into JIRA's JVM so Atlassian application links can easily be 
  created

# Support Notes

This container uses [OpenJDK](http://openjdk.java.net/) for its JVM and as such this unit is considered an **unsupported
platform** by Atlassian.

# Usage

## Prerequisites

### Database

Make sure you have a
[supported database](https://confluence.atlassian.com/jira/connecting-jira-to-an-external-database-289276815.html)
available either as a container or standalone.

### `NGINX_UNIT_HOSTS` Considerations

It is important that the value of your `NGINX_UNIT_HOSTS` environment variable is set to a single value and doesn't
include wildcards or regular expressions as this value will be used by JIRA to determine the hostname.

## Configuration

It is highly recommended that you use container orchestration software such as
[Docker Compose](https://www.docker.com/products/docker-compose) when using this NGINX Host unit as several Docker
containers are required for operation.  This guide will assume that you are using Docker Compose.  Additionally, we
will use the [official PostgreSQL Docker container](https://hub.docker.com/_/postgres/) for our database.

To begin, start with a basic `docker-compose.yml` file as described in the
[NGINX Host configuration guide](https://github.com/handcraftedbits/docker-nginx-host#configuration).  Then, add a
service for the database (named `db-jira`) and the NGINX Host JIRA unit (named `jira`):

```yaml
db-jira:
  image: postgres
  environment:
    - POSTGRES_USER=user
    - POSTGRES_PASSWORD=password
    - POSTGRES_DB=jira
  volumes:
    /home/me/db-jira:/var/lib/postgresql/data

jira:
  image: handcraftedbits/nginx-unit-jira
  environment:
    - NGINX_UNIT_HOSTS=mysite.com
    - NGINX_URL_PREFIX=/jira
  links:
    - db-jira
  volumes:
    - data:/opt/container/shared
    - /home/me/jira:/opt/data/jira
```

Observe the following:

* We create a link in `jira` to `db-jira` in order to allow JIRA to connect to our database.
* We mount `/opt/data/jira` using the local directory `/home/me/jira`.  This is the directory where JIRA stores its
  data.
* As with any other NGINX Host unit, we mount the volumes from our
  [NGINX Host data container](https://github.com/handcraftedbits/docker-nginx-host-data), in this case named `data`.

For more information on configuring the PostgreSQL container, consult its
[documentation](https://hub.docker.com/_/postgres/).

Finally, we need to create a link in our NGINX Host container to the `jira` container in order to proxy JIRA.  Here is
our final `docker-compose.yml` file:

```yaml
version: "2.1"

volumes:
  data:

services:
  db-jira:
    image: postgres
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=jira
    volumes:
      /home/me/db-jira:/var/lib/postgresql/data

  jira:
    image: handcraftedbits/nginx-unit-jira
    environment:
      - NGINX_UNIT_HOSTS=mysite.com
      - NGINX_URL_PREFIX=/jira
    links:
      - db-jira
    volumes:
      - data:/opt/container/shared
      - /home/me/jira:/opt/data/jira

  proxy:
    image: handcraftedbits/nginx-host
    depends_on:
      jira:
        condition: service_healthy
    ports:
      - "443:443"
    volumes:
      - data:/opt/container/shared
      - /etc/letsencrypt:/etc/letsencrypt
      - /home/me/dhparam.pem:/etc/ssl/dhparam.pem
```

This will result in making a JIRA instance available at `https://mysite.com/jira`.

## Running the NGINX Host JIRA Unit

Assuming you are using Docker Compose, simply run `docker-compose up` in the same directory as your
`docker-compose.yml` file.  Otherwise, you will need to start each container with `docker run` or a suitable
alternative, making sure to add the appropriate environment variables and volume references.

When configuring JIRA, be sure to select `PostgreSQL` as your database, `db-jira` as the database hostname, and `5432`
as the database port if you configured your database according to the previous section.

# Reference

## Environment Variables

Please see the NGINX Host [documentation](https://github.com/handcraftedbits/docker-nginx-host#units) for information
on the environment variables understood by this unit.
