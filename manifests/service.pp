# Candlepin Service and Initialization
class candlepin::service(
  Boolean $run_init = $::candlepin::run_init,
) {

  service { 'tomcat':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  if $run_init {
    exec { 'cpinit':
      # tomcat startup is slow - try multiple times (the initialization service is idempotent)
      command => '/usr/bin/wget --no-proxy --timeout=30 --tries=40 --wait=20 --retry-connrefused -qO- http://localhost:8080/candlepin/admin/init > /var/log/candlepin/cpinit.log 2>&1 && touch /var/lib/candlepin/cpinit_done',
      require => [Package['wget'], Service['tomcat']],
      creates => '/var/lib/candlepin/cpinit_done',
      # timeout is roughly "wait" * "tries" from above
      timeout =>  800,
    }
  }

}
