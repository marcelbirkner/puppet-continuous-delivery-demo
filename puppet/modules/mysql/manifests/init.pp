class mysql {
 
  $mysql_password = "password"


 package { "mysql-server":
    ensure => installed
  }

 package  {"mysql":
   ensure => installed
 }

  service { "mysqld":
    enable => true,
    ensure => running,
    require => Package["mysql-server"],
  }

 exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$mysql_password status",
    path => ["/bin", "/usr/bin"],
    command => "mysqladmin -uroot password $mysql_password",
    require => Service["mysqld"],
  }



define  mysql::db() {
    include mysql
        exec { "create-${name}-db":
        unless => "/usr/bin/mysql -uroot -ppassword ${name}",
        command => "/usr/bin/mysql -uroot -ppassword -e \"create database ${name};\"",
        require => [Service["mysqld"],Exec[set-mysql-password]]
      }
}

define mysql::createuser($user, $password, $db, $host){
      include mysql
      exec { "grant-${name}-db":
        unless => "/usr/bin/mysql -u${user} -p${password} ${name}",
        command => "/usr/bin/mysql -uroot -ppassword -e \"grant all on *.* to ${user}@'${host}' identified by '$password' WITH GRANT OPTION; flush privileges;\"",
        require =>  Mysql::Mysql::Db[worblehat]
      }
  }
}
define mysql::worblehat(){
    include mysql

    mysql::db {"worblehat":}

    mysql::createuser{"worblehat":
      user => "worblehat",
      password => "worblehat",
      db => "worblehat",
      host => "localhost",
    }
    mysql::createuser {"liquibase":
      user => "liquibase",
      password => "liquibase",
      db => "worblehat",
      host => "%",
    }
}


