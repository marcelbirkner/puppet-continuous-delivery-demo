node appserver {

  
  tomcat::deployment { "worblehat-web":
    path => '/etc/puppet/modules/tomcat/files/worblehat-web.war'
}
     
  mysql::worblehat{"create db":}
  tomcat::start{"StartTomcat":}

}
