#Download base image ubuntu 16.04
FROM ubuntu:16.04

# Update Software repository
RUN apt-get update -y

# Upgrade Software repository
RUN apt-get -y upgrade
#RUN DEBIAN_FRONTEND=noninteractive apt-get -y install -y --no-install-recommends apt-utils
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --assume-yes apt-utils
#Install Ubuntu Packages
RUN apt-get install openssh-server zsh htop curl wget -y


# Install python3 & pip
RUN apt-get install python3-venv python3-pip python3-dev -y

# Install dependencies
RUN apt-get install build-essential libssl-dev libffi-dev  -y

#Environmental values for Mysql
ENV MYSQL_ROOT_PASSWORD=rootpass
ENV MYSQL_USERNAME=mysql_user
ENV MYSQL_PASSWORD=password
ENV MYSQL_DATABASE=mydb

#MYSQL DB SETUP

RUN curl -LO http://dev.mysql.com/get/mysql-apt-config_0.3.2-1ubuntu14.04_all.deb
RUN dpkg -i mysql-apt-config_0.3.2-1ubuntu14.04_all.deb
ADD mysql.list /etc/apt/sources.list.d/mysql.list
RUN apt-get update && apt-get -y install mysql-server libevent-dev 
ADD my.cnf /etc/mysql/my.cnf
# Create zoneinfo.sql, fixing any broken entries
RUN mysql_tzinfo_to_sql /usr/share/zoneinfo | sed "s/Local time zone .*$/UNSET'\)/g" > /etc/mysql/zoneinfo.sql 
ADD run.sh /run.sh

