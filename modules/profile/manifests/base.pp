class profile::base(
    $puppetmaster  = hiera('puppetmaster'),
    $dns_alt_names = hiera('profile::base::dns_alt_names', false),
    $use_apt_proxy = hiera('profile::base::use_apt_proxy', true),
    $domain_search = hiera('profile::base::domain_search', $::domain),
    $remote_syslog = hiera('profile::base:remote_syslog', ['syslog.eqiad.wmnet', 'syslog.codfw.wmnet']),
    $monitoring = hiera('profile::base::monitoring', true),
    $core_dump_pattern = hiera('profile::base::core_dump_pattern', '/var/tmp/core/core.%h.%e.%p.%t'),
    $ssh_server_settings = hiera('profile::base::ssh_server_settings', {}),
    $nrpe_allowed_hosts = hiera('profile::base::nrpe_allowed_hosts', '127.0.0.1,208.80.154.14,208.80.153.74,208.80.155.119'),
    $group_contact = hiera('contactgroups', 'admins'),
    $check_disk_options = hiera('profile::base::check_disk_options', '-w 6% -c 3% -l -e -A -i "/srv/sd[a-b][1-3]" --exclude-type=tracefs'),
    $check_disk_critical = hiera('profile::base::check_disk_critical', false),
) {

    file { ['/usr/local/sbin', '/usr/local/share/bash']:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    class { '::base::standard_packages': }
    class { '::base::environment':
        core_dump_pattern => $core_dump_pattern,
    }

    class { '::base::kernel': }
}
