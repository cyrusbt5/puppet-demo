# == Class: config::run_containers

class config::run_containers {
  # resources
  if $::hostname =~ /^swarm-master-02$/ {

    # Chapter 8
    swarm_run {'logstash':
      ensure  => present,
      image   => 'scottyc/logstash',
      network => 'swarm-private',
      ports   => ['9998:9998', '9999:9999/udp', '5000:5000', '5000:5000/udp'],
      env     => ['ES_HOST=elasticsearch', 'ES_PORT=9200'],
      command => 'logstash -f /opt/logstash/conf.d/logstash.conf --debug',
      require => Class['config::swarm']
    }

    swarm_run {'elasticsearch':
      ensure     => present,
      image      => 'elasticsearch:2.4.5',
      network    => 'swarm-private',
      volumes    => ['/etc/esdata:/usr/share/elasticsearch/data'],
      command    => 'elasticsearch -Des.network.host=0.0.0.0',
      log_driver => 'syslog',
      log_opt    => 'syslog-address=tcp://logstash-5000.service.consul:5000',
      depends    => 'logstash',
      require    => Class['config::swarm']
    }

    swarm_run {'kibana':
      ensure     => present,
      image      => 'kibana:4.6.4',
      network    => 'swarm-private',
      ports      => ['80:5601'],
      env        => ['ELASTICSEARCH_URL=http://elasticsearch:9200', 'reschedule:on-node-failure'],
      log_driver => 'syslog',
      log_opt    => 'syslog-address=tcp://logstash-5000.service.consul:5000',
      depends    => 'logstash',
      require    => Class['config::swarm']
    }

    # Chapter 7 set to absent
    swarm_run { 'jenkins':
      ensure  => absent,
      image   => 'jenkins',
      ports   => ['8080:8080'],
      require => Class['config::swarm'],
    }

    swarm_run { 'nginx':
      ensure     => absent,
      image      => 'nginx',
      ports      => ['80:80', '443:443'],
      log_driver => 'syslog',
      network    => 'swarm-private',
      require    => Class['config::swarm'],
    }

    swarm_run { 'redis':
      ensure  => absent,
      image   => 'redis',
      network => 'swarm-private',
      require => Class['config::swarm'],
    }
  }
}
