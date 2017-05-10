# == Class standard
# Class for *most* servers, standard includes

class standard(
    $has_default_mail_relay = false,
    $has_admin = false,
    $has_ganglia = false,
    ) {

    include ::profile::base

    class { '::apt':
        use_proxy => false,
    }
}
