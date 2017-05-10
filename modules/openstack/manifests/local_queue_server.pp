# rabbitmqctl change_password nova avon

class openstack::local_queue_server(
    ) {

    $rabbit_monitor_username = hiera('rabbit_host')
    $rabbit_monitor_pass = hiera('rabbit_monitor_pass')

    package { [ 'rabbitmq-server' ]:
        ensure  => present,
    }

    # Turn up the number of allowed file handles for rabbitmq
    file { '/etc/default/rabbitmq-server':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => 'puppet:///modules/openstack/rabbitmq/labs-rabbitmq.default',
    }

    # Turn up the number of allowed file handles for rabbitmq
    file { '/usr/local/sbin/rabbitmqadmin':
        ensure => present,
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        source => 'puppet:///modules/openstack/rabbitmq/rabbitmqadmin',
    }

    if $::fqdn == hiera('labs_nova_controller') {
        service { 'rabbitmq-server':
            ensure  => running,
            require => Package['rabbitmq-server'];
        }
    } else {
        service { 'rabbitmq-server':
            ensure  => stopped,
            require => Package['rabbitmq-server'];
        }
    }
}
