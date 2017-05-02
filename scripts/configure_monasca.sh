#!/bin/bash

source /home/ubuntu/scripts/admin-openrc.sh
public_ip=$(hostname -I | xargs)
#export OS_AUTH_URL="http://$public_ip:35357/v3/"
#echo "OS_AUTH_URL=$OS_AUTH_URL"

pyc_files="/opt/stack/horizon/openstack_dashboard/local/local_settings.pyc "`
	`"/opt/stack/monasca-ui/monitoring/config/local_settings.pyc"

for pyc in $pyc_files
do
	rm $pyc
done

config_dirs="/home/ubuntu/.my.cnf "`
	`"/home/ubuntu/devstack "`
	`"/etc/keystone "`
	`"/etc/monasca "`
	`"/etc/profile.d "`
	`"/etc/openstack "`
	`"/opt/stack/elasticsearch/config "`
	`"/opt/stack/kibana/config "`
	`"/opt/stack/horizon "`
	`"/opt/stack/monasca-log-agent "`
	`"/opt/stack/monasca-log-metrics "`
	`"/opt/stack/monasca-log-persister "`
	`"/opt/stack/monasca-log-transformer "`
	`"/opt/stack/monasca-ui"
for config in $config_dirs
do
	sudo find $config -type f -print0 |xargs -0 sudo sed -i "s/144\.217\.244\.18/$public_ip/g"
done

sudo systemctl start mysql
sudo systemctl start apache2

# Configure endpoints
service_ids=$(openstack endpoint list -c ID -f value)
for service in $service_ids
do
        new_url=$(openstack endpoint show -c url -f value $service |sed "s/144\.217\.244\.18/$public_ip/")
        openstack endpoint set --url $new_url $service
done


