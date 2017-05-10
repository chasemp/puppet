
class openstack::keystone::local($openstack_version = 'liberty') {

    $keystoneconfig = hiera('keystoneconfig')
    #include ::openstack::keystone::hooks

    $packages = [
        'python-ldappool',
        'python-ldap',
        'python-ldap3',
        'python-mwclient',
        'ldapvi',
        'alembic',
        'keystone',
        'nova-common',
        'python-alembic',
        'python-amqp',
        'python-castellan',
        'python-cliff',
        'python-cmd2',
        'python-concurrent.futures',
        'python-cryptography',
        'python-dateutil',
        'python-designateclient',
        'python-dogpile.cache',
        'python-eventlet',
        'python-funcsigs',
        'python-futurist',
        'python-glanceclient',
        'python-jinja2',
        'python-jsonschema',
        'python-keystone',
        'python-keystonemiddleware',
        'python-kombu',
        'memcached',
        'python-memcache',
        'python-migrate',
        'python-mock',
        'python-nova',
        'python-novaclient',
        'python-openssl',
        'python-openstackclient',
        'python-oslo.cache',
        'python-oslo.db',
        'python-oslo.log',
        'python-oslo.messaging',
        'python-oslo.middleware',
        'python-oslo.rootwrap',
        'python-oslo.service',
        'python-pika',
        'python-pkg-resources',
        'python-pyasn1',
        'python-pycadf',
        'python-pyinotify',
        'python-pymysql',
        'python-pyparsing',
        'python-pysaml2',
        'python-routes',
        'python-setuptools',
        'python-sqlalchemy',
        'python-unicodecsv',
        'python-warlock',
        'websockify',
        'python-mysql.connector',
    ]

    package { $packages:
        ensure  => 'present',
    }

    if $keystoneconfig['token_driver'] == 'redis' {
        package { 'python-keystone-redis':
            ensure => present;
        }
    }

    $labs_osm_host = hiera('labs_osm_host')

    # include ::network::constants
    # $prod_networks = $network::constants::production_networks
    # $labs_networks = $network::constants::labs_networks

    file {
        '/var/log/keystone':
            ensure => directory,
            owner  => 'keystone',
            group  => 'www-data',
            mode   => '0775',
            require => Package['keystone'];
        '/etc/keystone':
            ensure => directory,
            owner  => 'keystone',
            group  => 'keystone',
            mode   => '0755',
            require => Package['keystone'];
        '/etc/keystone/keystone.conf':
            content => template("openstack/${openstack_version}/keystone/keystone.conf.erb"),
            owner   => 'keystone',
            group   => 'keystone',
            mode    => '0444',
            require => Package['keystone'];
        '/etc/keystone/policy.json':
            source  => "puppet:///modules/openstack/${openstack_version}/keystone/policy.json",
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            require => Package['keystone'];
        '/etc/keystone/logging.conf':
            source  => "puppet:///modules/openstack/${openstack_version}/keystone/logging.conf",
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            require => Package['keystone'];
        '/usr/lib/python2.7/dist-packages/wmfkeystoneauth':
            source  => "puppet:///modules/openstack/${openstack_version}/keystone/wmfkeystoneauth",
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            recurse => true,
            require => Package['keystone'];
        '/usr/lib/python2.7/dist-packages/wmfkeystoneauth.egg-info':
            source  => "puppet:///modules/openstack/${openstack_version}/keystone/wmfkeystoneauth.egg-info",
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            recurse => true,
            require => Package['keystone'];
    }

    file { '/etc/keystone/admin-openrc':
        ensure  => present,
        owner   => 'keystone',
        group   => 'keystone',
        mode    => '0444',
        content => template('openstack/admin-openrc.erb'),
    }

    file { '/root/novaenv.sh':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('openstack/novaenv.sh.erb'),
    }

    file { '/usr/local/bin/bootstrap_keystone':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('openstack/bootstrap_keystone.erb'),
    }

    service { 'keystone':
        ensure    => running,
        subscribe => File['/etc/keystone/keystone.conf'],
        require   => Package['keystone'],
    }
}
