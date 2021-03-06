# All RPM packaging tools
# @api private
class slave::packaging::rpm (
  Stdlib::Absolutepath $homedir,
  Optional[String] $koji_certificate = undef,
  Optional[String] $copr_login = undef,
  Optional[String] $copr_username = undef,
  Optional[String] $copr_token = undef,
) {
  package { ['koji', 'rpm-build', 'git-annex', 'pyliblzma', 'createrepo']:
    ensure => latest,
  }

  # koji
  file { "${homedir}/bin":
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  file { "${homedir}/bin/kkoji":
    ensure => link,
    owner  => 'jenkins',
    group  => 'jenkins',
    target => '/usr/bin/koji',
  }

  file { "${homedir}/.koji":
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  file { "${homedir}/.koji/katello-config":
    ensure => absent,
  }

  file { "${homedir}/.koji/config":
    ensure => file,
    mode   => '0644',
    owner  => 'jenkins',
    group  => 'jenkins',
    source => 'puppet:///modules/slave/katello-config',
  }

  if $koji_certificate {
    file { "${homedir}/.katello.cert":
      ensure  => file,
      mode    => '0600',
      owner   => 'jenkins',
      group   => 'jenkins',
      content => $koji_certificate,
    }
  } else {
    file { '/home/jenkins/.katello.cert':
      ensure  => absent,
    }
  }

  file { "${homedir}/.katello-ca.cert":
    ensure => file,
    mode   => '0644',
    owner  => 'jenkins',
    group  => 'jenkins',
    source => 'puppet:///modules/slave/katello-ca.cert',
  }

  # tito
  package { 'tito':
    ensure => latest,
  }

  file { "${homedir}/.titorc":
    ensure => file,
    mode   => '0644',
    owner  => 'jenkins',
    group  => 'jenkins',
    source => 'puppet:///modules/slave/titorc',
  }

  file { '/tmp/tito':
    ensure => directory,
    owner  => 'jenkins',
    group  => 'jenkins',
  }

  # copr
  if $copr_login {
    package { 'copr-cli':
      ensure => latest,
    }

    file { "${homedir}/.config/copr":
      ensure  => file,
      mode    => '0640',
      owner   => 'jenkins',
      group   => 'jenkins',
      content => template('slave/copr.erb'),
    }
  }

  # specs-from-koji
  package { ['scl-utils-build', 'rpmdevtools']:
    ensure => present,
  }
}
