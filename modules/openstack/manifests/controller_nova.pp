class openstack::controller_nova {

    # this gets weird
    include role::labs::openstack::nova::common
    $novaconfig = $role::labs::openstack::nova::common::novaconfig

    file {
        '/etc/nova/nova.conf':
            content => template("openstack/liberty/nova/controller.nova.conf.erb"),
            owner   => 'nova',
            group   => 'nogroup',
            mode    => '0440',
            require => Package['nova-common'];
        '/etc/nova/api-paste.ini':
            content => template("openstack/liberty/nova/controller.api-paste.ini.erb"),
            owner   => 'nova',
            group   => 'nogroup',
            mode    => '0440',
            require => Package['nova-common'];
    }
}
