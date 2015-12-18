#/bin/bash

set -x

which curl >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum install curl >/dev/null 2>&1
fi

# Install wget if not already installed 
which wget >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum install wget >/dev/null 2>&1
fi

# Install git if not already installed 
 
which git >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum install git >/dev/null 2>&1
fi

# Install python-pip  if not already installed 

which python-pip >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum install python-pip >/dev/null 2>&1
fi

which python-pip >/dev/null 2>&1
if  [ $? != 0 ]; then
  yum install python-devel >/dev/null 2>&1
fi

yum -y update

yum -y install httpd gcc gcc-c++ git pycairo mod_wsgi epel-release

yum -y install python-pip python-devel blas-devel lapack-devel libffi-devel

cd /usr/local/src

git clone https://github.com/graphite-project/graphite-web.git

git clone https://github.com/graphite-project/carbon.git
 
pip install -r /usr/local/src/graphite-web/requirements.txt
 
cd carbon

sudo python setup.py install

cd ..

cd graphite-web

python setup.py install

cp /opt/graphite/conf/carbon.conf.example /opt/graphite/conf/carbon.conf
cp /opt/graphite/conf/storage-schemas.conf.example /opt/graphite/conf/storage-schemas.conf
cp /opt/graphite/conf/storage-aggregation.conf.example /opt/graphite/conf/storage-aggregation.conf
cp /opt/graphite/conf/relay-rules.conf.example /opt/graphite/conf/relay-rules.conf
cp /opt/graphite/webapp/graphite/local_settings.py.example /opt/graphite/webapp/graphite/local_settings.py
cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
cp /opt/graphite/examples/example-graphite-vhost.conf /etc/httpd/conf.d/graphite.conf
 
cp /usr/local/src/carbon/distro/redhat/init.d/carbon-* /etc/init.d/

chmod +x /etc/init.d/carbon-*

cd /

cd /opt/graphite

#create database

sudo PYTHONPATH=/opt/graphite/webapp/ django-admin.py syncdb --settings=graphite.settings

#reply: "Yes" and enter
#user: root
#passwd: myPassword
 
#import static files

sudo PYTHONPATH=/opt/graphite/webapp/ django-admin.py collectstatic --settings=graphite.settings

# reply "yes"
 
#set permission

sudo chown -R apache:apache /opt/graphite/storage/

sudo chown -R apache:apache /opt/graphite/static/

sudo chown -R apache:apache /opt/graphite/webapp/

vim /etc/httpd/conf.d/graphite.conf
 
[...]
 Alias /static/ /opt/graphite/static/
 
   Require all granted
 
   Order allow,deny
   Allow from all
   Require all granted
 
[...]

sudo systemctl start carbon-cache
 
sudo systemctl enable httpd
sudo systemctl start httpd