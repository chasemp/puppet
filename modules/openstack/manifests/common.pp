# openstack role add --project admin --user novaadmin admin
# openstack service create --name nova --description "Nova" compute

# openstack endpoint create --region lablocal \
#     compute public http://192.168.1.200:8774/v2/%\(tenant_id\)s

# openstack endpoint create --region lablocal \
#     compute internal http://192.168.1.200:8774/v2/%\(tenant_id\)s

# openstack endpoint create --region lablocal \
#     compute admin http://192.168.1.200:8774/v2/%\(tenant_id\)s

# common packages and config for openstack
class openstack::common(
            $novaconfig,
            $wikitechstatusconfig,
            $openstack_version='liberty',
    ) {

    #    'mysql-common',
    #    'mysql-client-5.5',

    # include ::openstack::repo

    $packages = [
        'unzip',
        'nova-common',
        'vblade-persist',
        'bridge-utils',
        'ebtables',
        'python-mysqldb',
        'python-netaddr',
        'python-keystone',
        'python-novaclient',
        'python-openstackclient',
        'python-designateclient',
        'radvd',
    ]

    require_package($packages)

    # Allow unprivileged users to look at nova logs
    file { '/var/log/nova':
        ensure => directory,
        owner  => 'nova',
        group  => hiera('openstack::log_group', 'adm'),
        mode   => '0750',
    }
}
