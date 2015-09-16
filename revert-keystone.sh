#!/bin/bash

id=$(mysql -uroot -proot -Dkeystone --disable-column-names -B -e 'select id from service where type="identity";')
public_url=$(mysql -uroot -proot -Dkeystone --disable-column-name -B -e 'select url from endpoint e, service s where s.id=e.service_id and s.type="identity" and interface="public";')
admin_url=$(mysql -uroot -proot -Dkeystone --disable-column-name -B -e 'select url from endpoint e, service s where s.id=e.service_id and s.type="identity" and interface="admin";')
internal_url=$(mysql -uroot -proot -Dkeystone --disable-column-name -B -e 'select url from endpoint e, service s where s.id=e.service_id and s.type="identity" and interface="internal";')

changed=0

echo 'Saving current endpoint.'
printf "public_url $public_url\nadmin_url $admin_url\ninternal_url $internal_url \n" > /etc/keystone/v3_endpoints.txt

if [[ $public_url == *"/v2.0"* ]]; then
        echo 'Public url enpoint already set to v2.0. Not changing.'      
else
        n_public_url="${public_url%v3}v2.0"
        echo "Changing public url endping to $n_public_url"
        mysql -uroot -proot -Dkeystone -e "update endpoint set url='$n_public_url' where url='$public_url' and service_id='$id' and interface='public';"
        ((changed++))
fi

if [[ $admin_url == *"/v2.0"* ]]; then
        echo 'Admin url enpoint already set to v2.0. Not changing.'     
else
        n_admin_url="${admin_url%v3}v2.0"
        echo "Changing admin url endping to $n_admin_url"
        mysql -uroot -proot -Dkeystone -e "update endpoint set url='$n_admin_url' where url='$admin_url' and service_id='$id' and interface='admin';"
        ((changed++))
fi

if [[ $internal_url == *"/v2.0"* ]]; then
        echo 'Internal url enpoint already set to v2.0. Not chaning.'     
else
        n_internal_url="${internal_url%v3}v2.0"
        echo "Changing internal url endping to $n_internal_url"
        mysql -uroot -proot -Dkeystone -e "update endpoint set url='$n_internal_url' where url='$internal_url' and service_id='$id' and interface='internal';"
        ((changed++))
fi

if [ "$changed" -gt "0" ]; then
        echo 'Changing policy file to v2'
        cp /etc/keystone/policy.json.v2 /etc/keystone/policy.json

        echo 'Restarting keystone'
        systemctl restart openstack-keystone
fi
