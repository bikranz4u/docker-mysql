As this is a testing environment ,I have placed mysql credentials in ENV .Please take a special care if you are using in production.

Docker Image Build:- docker build -t put-your-image-name .

#Login to docker container to verify if mysql is running
Docker Run: docker run -it put-your-image-name

cmd:- /etc/init.d/mysql status | start | restart | stop
