class tomcat {

  $installer="apache-tomcat-6.0.35.tar.gz"
  $tomcat_version="6.0.35"

  exec { "tomcat-download":
    command => "/usr/bin/wget http://jenkins:8081/artifactory/ext-release-local/apache-tomcat/apache-tomcat/6.0.35/${installer}",
    creates => "/var/tmp/${installer}",
    cwd => "/var/tmp",
  }

  file { "/usr/apache-tomcat-${tomcat_version}":
                    ensure => directory,
                    recurse => true,
                    purge => true,
                    force => true,
                    owner => root,
                    require => Exec[shutdown-tomcat],
  }

  exec { "unpack-tomcat":
    command => "/bin/tar -C /usr -x -z -f /var/tmp/${installer}",
    require => [Exec[tomcat-download],File["/var/tmp/${installer}"], File["/usr/apache-tomcat-${tomcat_version}"]],
  }

  exec { "chmod":
    command => "/bin/chmod u+x /usr/apache-tomcat-${tomcat_version}/bin/*.sh",
    require => Exec[unpack-tomcat],
  }

  file {
    "/var/tmp/${installer}":
  }

  file { "context.xml":
    require => Exec['unpack-tomcat'],
    owner => 'root',
    path => "/usr/apache-tomcat-${tomcat_version}/conf/context.xml",
    content => template('/etc/puppet/modules/tomcat/templates/context.xml.erb')
  }
  
  file { "server.xml":
    require => Exec['unpack-tomcat'],
    owner => 'root',
    path => "/usr/apache-tomcat-${tomcat_version}/conf/server.xml",
    content => template('/etc/puppet/modules/tomcat/templates/server.xml.erb')
  }

  file { "mysql-connector.jar":
    require => Exec['unpack-tomcat'],
    owner => 'root',
    path => "/usr/apache-tomcat-${tomcat_version}/lib/mysql-connector-java-5.1.15.jar",
    source => '/etc/puppet/modules/tomcat/files/mysql-connector-java-5.1.15.jar'
  }

  exec { "shutdown-tomcat":
    command => "/bin/sh /usr/apache-tomcat-${tomcat_version}/bin/shutdown.sh",
    onlyif => "/usr/bin/test -e /usr/apache-tomcat-${tomcat_version}/bin/shutdown.sh"
  }

}


define tomcat::deployment($path) {

  include tomcat

  file { "/usr/apache-tomcat-${tomcat::tomcat_version}/webapps/${name}.war":
    owner => 'root',
    source => $path,
    require => [ Exec[chmod],  File["mysql-connector.jar"]],
  }

}

define tomcat::start(){

  include tomcat

  exec { "start-tomcat":
    command => "/bin/sh /usr/apache-tomcat-${tomcat::tomcat_version}/bin/startup.sh",
    require => [Exec[create-worblehat-db], Tomcat::Deployment[worblehat-web]],
  }

}
 


