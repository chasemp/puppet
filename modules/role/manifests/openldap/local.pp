# LDAP servers for lab local setup

# Dump and restore for ldap testing

# if needed you can set 
# /etc/ldap/slapd.conf
# rootpw     test
# service slapd restart

# service slapd stop
# slapcat -f /etc/ldap/slapd.conf -l dump.ldif

# verify perms here are correct:
# ls -al /var/lib/ldap/labs

# apply role
# service slapd stop
# sudo -u openldap slapindex
# ls -al /var/lib/ldap/labs
# sudo -u openldap slapadd -v -c -l dump.ldiff -f /etc/ldap/slapd.conf
# sudo -u openldap slapindex
# service slapd start

# ldapvi -D uid=novaadmin,ou=people,dc=wikimedia,dc=org -w foopass


class role::openldap::local {

    include passwords::openldap::local

    $ldapconfig = hiera_hash('labsldapconfig', {})
    $ldap_labs_hostname = $ldapconfig['hostname']

    system::role { 'role::openldap::labtest':
        description => 'LDAP servers for labs test cluster (based on OpenLDAP)'
    }

    class { '::openldap':
        server_id     => 1,
        suffix        => 'dc=wikimedia,dc=org',
        datadir       => '/var/lib/ldap/labs',
        extra_schemas => ['dnsdomain2.schema', 'nova_sun.schema', 'openssh-ldap.schema',
                          'puppet.schema', 'sudo.schema'],
        extra_indices => 'openldap/labs-indices.erb',
        extra_acls    => 'openldap/labs-acls.erb',
    }
}
