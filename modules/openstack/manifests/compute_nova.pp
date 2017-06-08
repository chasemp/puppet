class openstack::compute_nova {

    include role::labs::openstack::nova::common
    $novaconfig = $role::labs::openstack::nova::common::novaconfig

    file {
        '/etc/nova/nova.conf':
            content => template("openstack/liberty/nova/compute.nova.conf.erb"),
            owner   => 'nova',
            group   => 'nogroup',
            mode    => '0440',
            require => Package['nova-common'];
        '/etc/nova/api-paste.ini':
            content => template("openstack/liberty/nova/compute.api-paste.ini.erb"),
            owner   => 'nova',
            group   => 'nogroup',
            mode    => '0440',
            require => Package['nova-common'];
    }
}
