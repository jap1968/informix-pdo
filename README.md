# informix-pdo

Apache + PHP 7.2 + Informix Client SDK 4.50 + PDO_INFORMIX 1.3.3

Get Informix Client SDK (v4.50) from:
https://www-01.ibm.com/marketing/iwm/iwm/web/preLogin.do?source=ifxdl&S_PKG=450FC1linux&lang=en_US
Download the file ibm.csdk.4.50.FC1.LNX.tar and copy that file to /files/informix/

## Docker:
```
sudo docker build -t "hsap/informix-pdo" .

sudo docker run --rm -d -p 9098:80 --name informix-pdo_1 hsap/informix-pdo
sudo docker run --rm -d -p 9098:80 --name informix-pdo_1 hsap/informix-pdo /usr/sbin/apache2ctl -D FOREGROUND

sudo docker exec -it informix-pdo_1 /bin/bash
sudo docker stop informix-pdo_1
```
