FROM ubuntu
RUN apt update -y
RUN apt install apache2 -y
RUN apt install apache2-utils -y
COPY index.html/ /var/www/html/
RUN service apache2 restart 
EXPOSE 8081 
CMD ["/usr/sbin/apachectl", "-D", "FOREGROUND"] 
