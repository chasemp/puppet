class openstack::neutron::virt {

    notify {'neutron':}

    package { [
            'neutron-plugin-linuxbridge-agent',
            'neutron-plugin-ml2',
        ]:
        ensure => present,
    }

    # for config reasons need to decouple openstack::nova::common from
    # nova and shared hiera
    include role::labs::openstack::nova::common
    $novaconfig = $role::labs::openstack::nova::common::novaconfig

    file { '/etc/neutron/plugins/ml2/ml2_conf.ini':
        content => template('openstack/neutron/ml2/ml2_conf.ini.erb'),
        owner   => 'neutron',
        require => Package['neutron-plugin-linuxbridge-agent'],
    }

    file { '/etc/neutron/plugins/ml2/linuxbridge_agent.ini':
        content => template('openstack/neutron/ml2/linuxbridge_agent.ini.erb'),
        owner   => 'neutron',
        require => Package['neutron-plugin-linuxbridge-agent'],
        notify  => Service['neutron-plugin-linuxbridge-agent'],
    }

    file { '/etc/neutron/neutron.conf':
        content => template('openstack/neutron/neutron.conf.erb'),
        owner   => 'neutron',
        require => Package['neutron-plugin-linuxbridge-agent'],
        notify  => Service['neutron-plugin-linuxbridge-agent'],
    }

    service {'neutron-plugin-linuxbridge-agent':
        ensure => 'running',
    }
}
