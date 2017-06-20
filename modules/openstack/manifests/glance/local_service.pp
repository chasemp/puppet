# CREATE DATABASE glance;
# GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'password';
# GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'password';

# openstack service create --name glance --description "OpenStack Image service" image
# openstack endpoint create --region lablocal image public http://192.168.1.200:9292
# openstack endpoint create --region lablocal image internal http://192.168.1.200:9292
# openstack endpoint create --region lablocal image admin http://192.168.1.200:9292

# su -s /bin/sh -c "glance-manage db_sync" glance

# rm -f /var/lib/glance/glance.sqlite

# openstack role add --user novaadmin --project admin glanceadmin

# verify role assignment
# openstack role assignment list --user novaadmin  | grep `openstack role list | grep glanceadmin | awk '{print $2}'`

# service glance-registry restart
# service glance-api restart

# openstack image create --container-format bare --public --disk-format "qcow2" --file /root/trusty-server-cloudimg-amd64-disk1.img "trusty-test-image"
# openstack image list

class openstack::glance::local_service {

    $keystoneconfig = hiera('keystoneconfig')
    $glanceconfig   = hiera('glanceconfig')
    $openstack_version='liberty'

    $glance_data = '/srv/glance/'
    $glance_images_dir = "${glance_data}/images"
    $keystone_host_ip  = $keystoneconfig['hostname']
    $keystone_auth_uri = "http://${keystoneconfig['hostname']}:5000/v2.0"

    user { 'glancesync':
        ensure     => present,
        name       => 'glancesync',
        shell      => '/bin/sh',
        comment    => 'glance rsync user',
        gid        => 'glance',
        managehome => true,
        require    => Package['glance'],
        system     => true,
    }

    package { 'glance':
        ensure  => present,
    }

    file { '/srv/images/':
        ensure => directory,
        owner   => 'glance',
        group   => 'glance',
        require => Package['glance'],
    }        

    file { $glance_data:
        ensure  => directory,
        mode    => '0755',
    }

    file {
        '/etc/glance/glance-api.conf':
            content => template("openstack/${openstack_version}/glance/glance-api.conf.erb"),
            owner   => 'glance',
            group   => 'nogroup',
            notify  => Service['glance-api'],
            require => Package['glance'],
            mode    => '0440';
        '/etc/glance/glance-registry.conf':
            content => template("openstack/${openstack_version}/glance/glance-registry.conf.erb"),
            owner   => 'glance',
            group   => 'nogroup',
            notify  => Service['glance-registry'],
            require => Package['glance'],
            mode    => '0440';
        '/etc/glance/policy.json':
            source  => "puppet:///modules/openstack/${openstack_version}/glance/policy.json",
            mode    => '0644',
            owner   => 'root',
            group   => 'root',
            notify  => Service['glance-api'],
            require => Package['glance'];
    }

    service { 'glance-api':
        ensure  => running,
        require => Package['glance'],
    }

    service { 'glance-registry':
        ensure  => running,
        require => Package['glance'],
    }

    # XXX: don't mock sync
    # file { '/home/glancesync/.ssh':
    #     ensure  => directory,
    #     owner   => 'glancesync',
    #     group   => 'glance',
    #     mode    => '0700',
    #    require => User['glancesync'],
    #}
    # 
    # file { '/home/glancesync/.ssh/id_rsa':
    #    content => secret('ssh/glancesync/glancesync.key'),
    #    owner   => 'glancesync',
    #    group   => 'glance',
    #    mode    => '0600',
    #    require => File['/home/glancesync/.ssh'],
    #}
    #
    #  This is 775 so that the glancesync user can rsync to it.
    #file { $glance_images_dir:
    #    ensure  => directory,
    #    owner   => 'glance',
    #    group   => 'glance',
    #    require => Package['glance'],
    #    mode    => '0775',
    #}
    # ssh::userkey { 'glancesync':
    #    ensure  => present,
    #    require => User['glancesync'],
    #    content => secret('ssh/glancesync/glancesync.pub'),
    #}

}
