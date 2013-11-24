exec { 'apt-get-update':
  command => '/usr/bin/apt-get update'
}

include stdlib
include java

$gvm_etc_config = "/home/vagrant/.gvm/etc/config"

class gvm {

  package { ['unzip', 'curl', 'bash']:
    ensure => installed,
    require => Exec['apt-get-update'];
  }

  exec { "intall":
    command => "sudo su - vagrant -c 'curl -s get.gvmtool.net | bash'",
    cwd => "/var/tmp",
    user => "vagrant",
    logoutput => true,
    path => ["/usr/bin", "/usr/sbin", "/bin"],
    unless => "test -e $gvm_etc_config",
    before => Exec['selfupdate'],
    require => [ 
      Class['java'], 
      Package['unzip'], 
      Package['curl'],
      Package['bash'],
    ],
  }

  exec { "selfupdate":
    command => "sudo su - vagrant -c 'source /home/vagrant/.gvm/bin/gvm-init.sh && gvm selfupdate'",
    cwd => "/var/tmp",
    user => "vagrant",
    logoutput => true,
    path => ["/usr/bin", "/usr/sbin", "/bin", "/home/vagrant/.gvm/bin"],
    unless => "sudo su - vagrant -c 'gvm selfupdate'",
  }

}

include gvm

class vertx {

  exec { "install":
    command => "sudo su - vagrant -c 'gvm install vertx'",
    cwd => "/var/tmp",
    user => "vagrant",
    logoutput => true,
    path => ["/usr/bin", "/usr/sbin", "/bin", "/home/vagrant/.gvm/bin"],
    returns => ['1'],
    unless => "test -e /home/vagrant/.gvm/vertx/current",
    require => Exec['selfupdate'],
  }

}

include vertx