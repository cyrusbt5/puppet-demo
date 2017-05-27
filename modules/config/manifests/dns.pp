# == Class: config::dns

class config::dns {
  # resources
  package { ['bind', 'bind-utils']:
    ensure => latest,
  } ->

  file { '/etc/named.conf':
    ensure  => file,
    content => template('config/named.conf.erb'),
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
    require => Package['bind'],
  } ~>

  file { '/etc/named/consul.conf':
    ensure  => file,
    content => template('config/consul.conf.erb'),
    group   => 'root',
    mode    => '0644',
    owner   => 'root',
    require => Package['bind'],
  } ~>

  service { 'named':
    ensure  => running,
    enable  => true,
    require => File['/etc/named.conf'],
  }

}
