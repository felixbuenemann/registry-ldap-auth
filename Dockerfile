FROM h3nrik/nginx-ldap

MAINTAINER Henrik Sachse <t3x7m3@posteo.de>

ADD config/* /etc/nginx/

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
