# The 'nova compute' service does the actual VM management
#  within nova.
# https://wiki.openstack.org/wiki/Nova
class openstack::nova::compute(
    $novaconfig,
    $openstack_version='liberty'
){
    # include ::openstack::repo

    include openstack::compute_nova

    # XXX: lablocal unsure yet of effect: not much it seems except sasl auth
    file { '/etc/libvirt/libvirtd.conf':
         notify  => Service['libvirt-bin'],
         owner   => 'root',
         group   => 'root',
         mode    => '0444',
         content => template('openstack/common/nova/libvirtd.conf.erb'),
    }

    file { '/etc/default/libvirt-bin':
        notify  => Service['libvirt-bin'],
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('openstack/common/nova/libvirt-bin.default.erb'),
    }

    file { '/etc/nova/nova-compute.conf':
        notify  => Service['nova-compute'],
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('openstack/common/nova/nova-compute.conf.erb'),
    }

    # XXX: This seems like a leaky abstraction.

    # nova-compute won't ever check the policy file, but nova-common
    #  seems to expect it to be here, so install to make apt happy.
    # file { '/etc/nova/policy.json':
    #    source => "puppet:///modules/openstack/${openstack_version}/nova/policy.json",
    #    mode   => '0644',
    #    owner  => 'root',
    #    group  => 'root',
    #}

    # ssh::userkey { 'nova':
    #    content => secret('ssh/nova/nova.pub'),
    #}

    service { 'libvirt-bin':
        ensure  => running,
        enable  => true,
        require => Package['nova-common'],
    }

    # Check for buggy kernels.  There are a lot of them!
    if os_version('ubuntu >= trusty') and (versioncmp($::kernelrelease, '3.13.0-46') < 0) {
        # see: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1346917
        fail('nova-compute not installed on buggy kernels.  Old versions of 3.13 have a KSM bug.  Try installing linux-image-generic-lts-xenial')
    } elsif $::kernelrelease =~ /^3\.13\..*/ {
        fail('nova-compute not installed on buggy kernels.  On 3.13 series kernels, instance suspension causes complete system lockup.  Try installing linux-image-generic-lts-xenial')
    } elsif $::kernelrelease =~ /^3\.19\..*/ {
        fail('nova-compute not installed on buggy kernels.  On 3.19 series kernels, instance clocks die after resuming from suspension.  Try installing linux-image-generic-lts-xenial')
    } else {
        package { [
                      'nova-compute',
                      'nova-compute-kvm',
                      'spice-html5',
                      'websockify',
                      'virt-top',
                ]:
            ensure  => present,
        }
    }

    # By default trusty allows the creation of user namespaces by unprivileged users
    # (Debian defaulted to disallowing these since the feature was introduced for security reasons)
    # Unprivileged user namespaces are not something we need in general (and especially
    # not in trusty where support for namespaces is incomplete) and was the source for
    # several local privilege escalation vulnerabilities. The 4.4 HWE kernel for trusty
    # contains a backport of the Debian patch allowing to disable the creation of user
    # namespaces via a sysctl, so disable to limit the attack footprint
    if os_version('ubuntu == trusty') and (versioncmp($::kernelversion, '4.4') >= 0) {
        sysctl::parameters { 'disable-unprivileged-user-namespaces-labvirt':
            values => {
                'kernel.unprivileged_userns_clone' => 0,
            },
        }
    }

    # Without qemu-system, apt will install qemu-kvm by default,
    # which is somewhat broken.
    package { 'qemu-system':
        ensure  => present,
    }

    # qemu-kvm and qemu-system are alternative packages to meet the needs of
    # libvirt.
    #  Lately, Precise has been installing qemu-kvm by default.  That's
    #  different
    #  from our old, existing servers, and it also defaults to use spice for vms
    #  even though spice is not installed.  Messy.

    #### XXX: seems no longer true after precise/kilo?
    ## package { [ 'qemu-kvm' ]:
    ##    ensure  => absent,
    ##    require => Package['qemu-system'],
    ##}

    # nova-compute adds the user with /bin/false, but resize, live migration,
    # etc.
    # need the nova use to have a real shell, as it uses ssh.
    #user { 'nova':
    #    ensure  => present,
    #    shell   => '/bin/bash',
    #    require => Package['nova-common'],
    #}

    service { 'nova-compute':
        ensure    => running,
        subscribe => File['/etc/nova/nova.conf'],
        require   => Package['nova-compute'],
    }

    # XXX: Why?
    #file { '/etc/libvirt/qemu/networks/autostart/default.xml':
    #        ensure  => absent,
    #}
}
