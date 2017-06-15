# su -s /bin/sh -c "neutron-db-manage \
    --config-file /etc/neutron/neutron.conf \
    --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

# neutron agent-list

class openstack::neutron::net {

    notify {'neutron':}

    package { [
            'neutron-server',
            'neutron-dhcp-agent',
            'neutron-metadata-agent',
            'neutron-plugin-ml2',
            'neutron-common',
            'mariadb-client-core-5.5',
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


    service {'neutron-server':
        ensure => running,
    }

    service {'neutron-metadata-agent':
        ensure => running,
    }

    service {'neutron-dhcp-agent':
        ensure => running,
    }

}
    
