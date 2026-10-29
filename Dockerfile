FROM ubuntu
RUN apt update -y
RUN apt install apache2 -y
RUN apt install apache2-utils -y
COPY index.html/ /var/www/html/
RUN sed -i 's/Listen 80/Listen 8081/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8081>/' /etc/apache2/sites-enabled/000-default.conf
EXPOSE 8081 
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"] 
