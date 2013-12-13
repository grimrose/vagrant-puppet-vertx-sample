exec { 'apt-get-update':
  command => '/usr/bin/apt-get update'
}

include stdlib
include java

$gvm_etc_config = "/home/vagrant/.gvm/etc/config"

class gvm {

  package { ['unzip', 'curl', 'bash']:
    ensure => installed,
    require => Exec['apt-get-update'],
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
      Package['bash']
    ]
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
    unless => "test -e /home/vagrant/.gvm/vertx/current",
    require => Exec['selfupdate'],
  }

}

include vertx

class deploy {

  $user_name = 'World'
  $app_name = 'hello_world'

  file { [ '/opt/app', '/opt/app/webapp' ]:
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0755',
    ensure => directory
  }

  file {
    "config":
      path    => "/opt/app/conf.json",
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => '0644',
      ensure  => present,
      content => template('/tmp/vagrant-puppet/templates/conf.json.erb');

    "index":
      path    => "/opt/app/webapp/index.html",
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => '0644',
      ensure  => present,
      content => template('/tmp/vagrant-puppet/templates/index.html.erb');

    "app":
      path    => "/opt/app/App.groovy",
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => '0644',
      ensure  => present,
      content => template('/tmp/vagrant-puppet/templates/App.groovy');

    "init.d":
      path    => "/etc/init.d/vertx-app",
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => "0755",
      ensure  => present,
      content => template('/tmp/vagrant-puppet/templates/vertx-app.sh.erb'),
      require => [ Class['vertx'], File['config'], File['index'], File['app']];
  }

  service { "vertx-app":
    ensure  => "running",
    require => File["init.d"],
  }

}

include deploy
