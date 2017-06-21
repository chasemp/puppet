# su -s /bin/sh -c "neutron-db-manage \
#    --config-file /etc/neutron/neutron.conf \
#    --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

# neutron agent-list

class openstack::neutron::net {

    notify {'neutron':}

    package { [
            'neutron-server',
            'neutron-dhcp-agent',
            'neutron-metadata-agent',
            'neutron-common',
            'mariadb-client-core-5.5',
            'neutron-plugin-ml2',
            'neutron-plugin-linuxbridge-agent',
            'neutron-l3-agent',
            'python-neutronclient']:
        ensure => present,
    }

    # for config reasons need to decouple openstack::nova::common from
    # nova and shared hiera
    include role::labs::openstack::nova::common
    $novaconfig = $role::labs::openstack::nova::common::novaconfig

    sysctl::parameters { 'neutron_net':
        values   => {
          'net.ipv4.ip_forward' => '1',
          'net.ipv4.conf.all.rp_filter'     => '1',
          'net.ipv4.conf.default.rp_filter' => '1',
        },
        priority => 90,
      }

    file { '/etc/neutron/neutron.conf':
        content => template('openstack/neutron/neutron.conf.erb'),
        owner   => 'neutron',
        require => Package['neutron-server'],
        notify  => Service['neutron-server'],
    }

    file { '/etc/neutron/dhcp_agent.ini':
        content => template('openstack/neutron/dhcp_agent.ini.erb'),
        owner   => 'neutron',
        require => Package['neutron-server'],
        notify  => Service['neutron-dhcp-agent'],
    }

    file { '/etc/neutron/metadata_agent.ini':
        content => template('openstack/neutron/metadata_agent.ini.erb'),
        owner   => 'neutron',
        require => Package['neutron-server'],
        notify  => Service['neutron-metadata-agent'],
    }

    file { '/etc/neutron/plugins/ml2/ml2_conf.ini':
        content => template('openstack/neutron/ml2/ml2_conf.ini.erb'),
        owner   => 'neutron',
        require => Package['neutron-server'],
        notify  => Service['neutron-server'],
    }

    file { '/etc/neutron/plugins/ml2/linuxbridge_agent.ini':
        content => template('openstack/neutron/ml2/linuxbridge_agent.ini.erb'),
        owner   => 'neutron',
        require => Package['neutron-plugin-linuxbridge-agent'],
    }

    file { '/etc/neutron/l3_agent.ini':
        content => template('openstack/neutron/l3_agent.ini.erb'),
        owner   => 'neutron',
        require => Package['neutron-l3-agent'],
        notify  => Service['neutron-l3-agent'],
    }

    service {'neutron-plugin-linuxbridge-agent':
        ensure => 'running',
    }

    service {'neutron-server':
        ensure => running,
    }

    service {'neutron-metadata-agent':
        ensure => running,
    }

    service {'neutron-dhcp-agent':
        ensure => running,
    }
    service {'neutron-l3-agent':
        ensure => running,
    }
}
