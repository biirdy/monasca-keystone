#!/bin/bash

echo 'Getting new policy file'
wget -O /etc/keystone/policy.json.v3

echo 'Changing policy file'
cp /etc/keystone/policy.json /etc/keystone/policy.json.v2
cp /etc/keystone/policy.json.v3 /etc/keystone/policy.json

id=$(mysql -uroot -proot -Dkeystone --disable-column-names -B -e 'select id from service where type="identity";')
public_url=$(mysql -uroot -proot -Dkeystone --disable-column-name -B -e 'select url from endpoint e, service s where s.id=e.service_id and s.type="identity" and interface="public";')
admin_url=$(mysql -uroot -proot -Dkeystone --disable-column-name -B -e 'select url from endpoint e, service s where s.id=e.service_id and s.type="identity" and interface="admin";')
internal_url=$(mysql -uroot -proot -Dkeystone --disable-column-name -B -e 'select url from endpoint e, service s where s.id=e.service_id and s.type="identity" and interface="internal";')

echo 'Saving current endpoint.'
echo "public_url $public_url\nadmin_url $admin_url\ninternal_url $internal_url" > /etc/keystone/v2_endpoints.txt

if [[ $public_url == *"/v3"* ]]; then
	echo 'Public url enpoint already set to v3. Not changing.'	
else
	n_public_url="${public_url%v2.0}v3"
	echo 'Changing public url endping to $n_public_url'
	mysql -uroot -proot -Dkeystone -e 'update endpoint set url="$n_public_url" where url="$public_url" and service_id="$id" and interface="public";'	
fi 

if [[ $admin_url == *"/v3"* ]]; then
        echo 'Admin url enpoint already set to v3. Not changing.'     
else
        n_admin_url="${admin_url%v2.0}v3"
        echo 'Changing admin url endping to $n_admin_url'
        mysql -uroot -proot -Dkeystone -e 'update endpoint set url="$n_admin_url" where url="$admin_url" and service_id="$id" and interface="admin";'
fi

if [[ $internal_url == *"/v3"* ]]; then
        echo 'Internal url enpoint already set to v3. Not chaning.'     
else
        n_internal_url="${internal_url%v2.0}v3"
        echo 'Changing internal url endping to $n_internal_url'
        mysql -uroot -proot -Dkeystone -e 'update endpoint set url="$n_internal_url" where url="$internal_url" and service_id="$id" and interface="internal";'
fi

echo 'Restarting keystone'
systemctl restart openstack-keystone 
