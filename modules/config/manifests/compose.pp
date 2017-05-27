# == Class: config::compose

class config::compose {

  file_line { 'sysctl default disable ipv6':
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv6.conf.default.disable_ipv6 = 1',
  }

  file_line { 'sysctl all disable ipv6':
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv6.conf.all.disable_ipv6 = 1',
  }

  file_line { 'sysctl enable ipv4 forwarding':
    ensure => present,
    path   => '/etc/sysctl.conf',
    line   => 'net.ipv4.conf.all.forwarding = 1',
  }

  exec { 'sysctl':
    command     => '/sbin/sysctl -qp',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    subscribe   => [
      File_line['sysctl default disable ipv6'],
      File_line['sysctl all disable ipv6'],
      File_line['sysctl enable ipv4 forwarding']
    ],
    refreshonly => true,
  }

  if $::hostname =~ /^swarm-master*/ {
    notify { 'MASTER message':
      message => 'This server is the Swarm Manager.'
    }
  }
  else {

    class {'docker::compose':
      ensure  => present,
      version => '1.8.1',
    } ->

    file { '/root/docker-compose.yml':
      ensure  => file,
      mode    => '0640',
      content => template('config/registrator.yml.erb'),
    } ->

    docker_compose { '/root/docker-compose.yml':
      ensure => present,
    }
  }
}
