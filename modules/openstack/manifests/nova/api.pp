# This is the api service for Openstack Nova.
# It provides a REST api that  Wikitech and Horizon use to manage VMs.
class openstack::nova::api($novaconfig, $openstack_version='liberty') {

    # include ::openstack::repo

    package { 'nova-api':
        ensure  => present,
    }

    service { 'nova-api':
        ensure    => running,
        subscribe => File['/etc/nova/nova.conf'],
        require   => Package['nova-api'];
    }

    # file { '/etc/nova/policy.json':
    #     source  => "puppet:///modules/openstack/${openstack_version}/nova/policy.json",
    #    mode    => '0644',
    #    owner   => 'root',
    #    group   => 'root',
    #    notify  => Service['nova-api'],
    #    require => Package['nova-api'];
    #}
}
