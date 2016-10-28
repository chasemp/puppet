class role::kubernetes::worker {
    include standard
    include base::firewall

    # Sets up docker on the machine
    include ::profile::docker::storage
    include ::profile::docker::engine
}