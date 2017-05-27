# == Class: config::consul_config

class config::consul_config {
  # resources
  if $::hostname =~ /^*101*$/ {
    class { 'consul':
      config_hash => {
        'datacenter'       => 'dev',
        'data_dir'         => '/opt/consul',
        'ui_dir'           => '/opt/consul/ui',
        'bind_addr'        => $::ipaddress_eth1,
        'client_addr'      => '0.0.0.0',
        'node_name'        => $::hostname,
        'advertise_addr'   => '172.17.8.101',
        'bootstrap_expect' => '1',
        'log_level'        => 'INFO',
        'server'           => true,
      }
    }
  }
  else {
    class { 'consul':
      config_hash => {
        'bootstrap'      => false,
        'datacenter'     => 'dev',
        'data_dir'       => '/opt/consul',
        'ui_dir'         => '/opt/consul/ui',
        'bind_addr'      => $::ipaddress_eth1,
        'client_addr'    => '0.0.0.0',
        'node_name'      => $::hostname,
        'advertise_addr' => $::ipaddress_eth1,
        'start_join'     => ['172.17.8.101', '172.17.8.102', '172.17.8.103'],
        'server'         => false,
      }
    }
  }

  ::consul::service { 'docker-service':
    checks  => [
      {
        script   => 'service docker status',
        interval => '10s',
        tags     => ['docker-service'],
      }
    ],
    address => $::ipaddress_eth1,
  }

  if $::hostname =~ /^swarm-master*/ {
    ::consul::service { 'swarm-master-01':
      checks  => [
        {
          script   => 'docker -H tcp://172.17.8.114:4000 info',
          interval => '10s',
          tags     => ['swarm-master-01'],
        }
      ],
      address => $::ipaddress_eth1,
    }

    ::consul::service { 'swarm-master-02':
      checks  => [
        {
          script   => 'docker -H tcp://172.17.8.115:4000 info',
          interval => '10s',
          tags     => ['swarm-master-02'],
        }
      ],
      address => $::ipaddress_eth1,
    }
  }
}
