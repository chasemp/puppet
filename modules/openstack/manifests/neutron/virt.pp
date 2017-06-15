class openstack::neutron::virt {

    notify {'neutron':}

    package { [
            'neutron-plugin-ml2'],
        ensure => present,
    }

    # for config reasons need to decouple openstack::nova::common from
    # nova and shared hiera
    include role::labs::openstack::nova::common
    $novaconfig = $role::labs::openstack::nova::common::novaconfig
}
    
