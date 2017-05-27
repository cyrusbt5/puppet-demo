# Class: config
# ===========================

class config (

  $consul_ip = hiera('docker_swarm::backend_ip', '172.17.8.101')

){

  class { 'config::dns': } ->
  class { 'config::consul_config': } ->
  class { 'config::swarm': } ->
  class { 'config::compose': } ->
  class { 'config::run_containers': }

  contain 'config::dns'
  contain 'config::consul_config'
  contain 'config::swarm'
  contain 'config::compose'
  contain 'config::run_containers'

  Class['config::dns'] ->
  Class['config::consul_config'] ->
  Class['config::swarm'] ->
  Class['config::compose'] ->
  Class['config::run_containers']

}
