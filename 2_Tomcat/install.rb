##########################################################################
# Install and configure tomcat
##########################################################################
#

if %w(redhat centos).include?(node['platform'])
#Install OpenJDK 7 JDK using yum
  yum_package 'java-1.7.0-openjdk-devel'

elsif %w(debian ubuntu).include?(node['platform'])
# Install via apt
  execute 'repo update' do
    command 'sudo add-apt-repository ppa:openjdk-r/ppa'
  end
  execute 'apt get update' do
    command 'sudo apt-get update'
  end
  apt_package 'openjdk-7-jdk' do
    options '--assume-yes'
  end

else
  print "Unsuported OS"
end


#Create a user and group for tomcat

group 'tomcat'

user 'tomcat' do
  shell '/bin/nologin'
  gid 'tomcat'
  home '/opt/tomcat'
end


#Download the Tomcat Binary

remote_file '/tmp/apache-tomcat-8.5.28.tar.gz' do
  source 'http://apache.cs.utah.edu/tomcat/tomcat-8/v8.5.28/bin/apache-tomcat-8.5.28.tar.gz'
  action :create_if_missing
end

#Extract the Tomcat Binary

directory '/opt/tomcat'
execute 'tar' do
  cwd '/tmp'
  action :run
  command 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'
end

#Update the Permissions

execute 'recursive group ownership' do
  command 'chgrp -R tomcat /opt/tomcat'
end

execute 'recursive group read' do
  command 'sudo chmod -R g+r conf'
  cwd '/opt/tomcat'
end

execute 'group exec' do
  command 'sudo chmod g+x conf'
  cwd '/opt/tomcat'
end

%w[ /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs ].each do |path|
  directory path do
    owner 'tomcat'
    recursive true
  end
end

if %w(debian ubuntu).include?(node['platform'])
  #A link has to be made for Ubuntu
  link '/usr/lib/jvm/jre' do
    to '/usr/lib/jvm/java-7-openjdk-amd64'
  end 
end

#Install the Systemd Unit File

systemd_unit 'tomcat.service' do
  content <<-EOU.gsub(/^\s+/, '') 
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=syslog.target network.target

  [Service]
  Type=forking

  Environment=JAVA_HOME=/usr/lib/jvm/jre
  Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
  Environment=CATALINA_HOME=/opt/tomcat
  Environment=CATALINA_BASE=/opt/tomcat
  Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
  Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

  ExecStart=/opt/tomcat/bin/startup.sh
  ExecStop=/bin/kill -15 $MAINPID

  User=tomcat
  Group=tomcat
  UMask=0007
  RestartSec=10
  Restart=always

  [Install]
  WantedBy=multi-user.target 
  EOU

  action [ :create, :enable, :start ]
end
