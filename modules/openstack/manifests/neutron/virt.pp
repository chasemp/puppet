class openstack::neutron::virt {

    notify {'neutron':}

    package { [
            'neutron-plugin-ml2',
            'neutron-plugin-linuxbridge-agent'],
        ensure => present,
    }

    # for config reasons need to decouple openstack::nova::common from
    # nova and shared hiera
    include role::labs::openstack::nova::common
    $novaconfig = $role::labs::openstack::nova::common::novaconfig

    file { '/etc/neutron/plugins/ml2/ml2_conf.ini':
        content => template('openstack/neutron/ml2/ml2_conf.ini'),
        owner   => 'neutron',
        require => Package['neutron-plugin-linuxbridge-agent'],
    }
}
    
