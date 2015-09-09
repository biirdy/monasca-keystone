# monasca-keystone
Scripts for updating and configuring openstack-keystone for use with monasca

# update-keystone.sh
Updates keystone from v2.0 to v3.

- Assumes the mysql user and password are both 'root'.
- Current policy file is backed up at /etc/keystone/policy.json.v2
- Current endpoints are backed up at /etc/keystone/v2_endpoints.txt

# monasca-keystone.sh
Configures keystone with the monasca project, users, roles, services and endpoint.

- Requires both keystone and monasca hosts to be defined in /etc/hosts
- Assumes keystone auth user and password are both 'admin'.

#TODO
- update-keystone should take mysql user and password as flags or env variables.
- create script to revert back to v2.0 using v2_endpoints.txt
- monasca-keystone should use existing env variables for keystone auth.
