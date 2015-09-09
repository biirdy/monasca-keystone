if ! grep -q "monasca" /etc/hosts; then
	echo "Monasca host does not exist. Please add to /etc/hosts"
	exit 0
fi

if ! grep -q "keystone" /etc/hosts; then
	echo "keystone host does not exist. Please add to /etc/hosts"
	exit 0
fi

export OS_IDENTITY_API_VERSION=3
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_AUTH_URL=http://keystone:35357/v3

## agent users service and endpoint  
openstack project create --description 'Monasca project' monasca
openstack user create --project monasca --password password monasca
openstack user create --project monasca --password password monasca-agent
openstack role create monasca-agent
openstack role create monasca-user
openstack role add --user monasca-agent --project monasca monasca-agent
openstack role add --user monasca --project monasca monasca-user
openstack service create --name monitoring --description "Monasca monitoring service" monitoring 
openstack endpoint create monitoring admin http://monasca:8080/v2.0
openstack endpoint create monitoring public http://monasca:8080/v2.0
openstack endpoint create monitoring internal http://monasca:8080/v2.0

## to allow cross tenant metric submission
openstack role create monitoring-delegate
openstack role add --user monasca-agent --project monasca monitoring-delegate
