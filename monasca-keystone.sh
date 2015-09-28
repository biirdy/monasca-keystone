$monasca=$(gethostip -d monasca)

if [ -z "$monasca"]; then 
	echo "monasca host not set."
	exit 1
fi 

if [ -z "$OS_AUTH_URL" ] && [ -z "$OS_TENANT_NAME" ] && [ -z "$OS_USERNAME" ] && [ -z "$OS_PASSWORD" ]; then 
	echo "Either OS_TENANT_NAME, OS_USERNAME, OS_PASSSWORD, OS_AUTH_URL or OS_IDENTITY_API_VERSION not set."
	exit 1
fi   

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
