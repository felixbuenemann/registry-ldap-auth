# ![NGINX logo](https://raw.github.com/felixbuenemann/registry-ldap-auth/master/images/NginxLogo.gif)

## Introduction

This image provides an LDAP and Active Directory authentication proxy for a [Docker registry](https://hub.docker.com/_/registry/). It uses an [NGINX web server](https://github.com/nginx/nginx) with builtin [LDAP](https://github.com/kvspb/nginx-auth-ldap) and SSL support. It is based on [felixbuenemann/nginx-ldap](https://hub.docker.com/r/felixbuenemann/nginx-ldap/).

The sources including the sample files used in this description can be found on [GitHub](https://github.com/g17/registry-ldap-auth).

The Docker image can be downloaded at [Docker Hub](https://hub.docker.com/r/felixbuenemann/registry-ldap-auth/).

## Prerequisites

The authentication proxy works with different LDAP servers like ApacheDS or OpenLDAP. It also works with Active Directory. So a container with a running LDAP server is expected. If you need information about creating a container with a test LDAP server please refer to [h3nrik/nginx-ldap](https://registry.hub.docker.com/u/h3nrik/nginx-ldap/).

A running Docker registry container is required. Details about the Docker registry can be found at the [official Docker registry project page](https://github.com/docker/docker-registry/blob/master/README.md).

You need a valid SSL certificate. It must be known by a trusted CA! No self-signed ones are allowed. Theoretically you could also use self-signed certificates. Therefore the Docker daemon need to be started with the *--insecure-registry* command line parameter. But this is not recommended.

If you plan to use an LDAP host that is not represented by a Docker container you might want to have a look at the [Docker ambassador pattern](https://docs.docker.com/articles/ambassador_pattern_linking/).

## Installation

Assuming your running Docker registry container is named *registry* and the LDAP container is named *ldap*. The following steps will add LDAP authentication to your registry.

1. The SSL certificate files must be copied into a local folder (e.g. /ssl/cert/path). It will be mounted as a volume into the proxy server later. The certificate file must be named *docker-registry.crt* and the private key file *docker-registry.key*.

2. Create an LDAP configuration file named *ldap.conf*. A [sample-ldap.conf](https://github.com/g17/registry-ldap-auth/blob/master/sample-ldap.conf) file is provided with the image sources. It could look like:

		url ldap://ldap/dc=example,dc=com?samaccountname?sub?(objectClass=user);
		binddn ldap@example.com;
		binddn_passwd secretPassword;
		group_attribute uniquemember;
		group_attribute_is_dn on;
		require group 'cn=docker,ou=groups,dc=example,dc=com';
		require valid_user;
		satisfy all;	

3. Create a Docker container for the authentication proxy. The proxy container expects the registry container to be linked with the name *docker-registry*. The used NGINX web server configuration can be found [in the config folder](https://github.com/felixbuenemann/registry-ldap-auth/blob/master/config).

		docker run --name registry-ldap-auth --link ldap:ldap --link registry:docker-registry -v /ssl/cert/path:/etc/ssl/docker:ro -v `pwd`/sample-ldap.conf:/etc/nginx/ldap.conf:ro -p 443:443 -p 5000:5000 -d felixbuenemann/registry-ldap-auth

## Licenses

This docker image contains compiled binaries for:

1. The NGINX web server. Its license can be found on the [NGINX website](http://nginx.org/LICENSE).
2. The nginx-auth-ldap module. Its license can be found on the [nginx-auth-ldap module project site](https://github.com/kvspb/nginx-auth-ldap/blob/master/LICENSE).
