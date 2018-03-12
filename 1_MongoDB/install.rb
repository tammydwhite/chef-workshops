##########################################################################
# Cookbook Name:: mongodb
# Recipe:: install
#
##########################################################################
#
if %w(redhat centos).include?(node['platform'])
# Create a /etc/yum.repos.d/mongodb.repo file to hold the following configuration information for the MongoDB repository:
#
  file '/etc/yum.repos.d/mongodb.repo' do
    content '
    [mongodb]
    name=MongoDB Repository
    baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
    gpgcheck=0
    enabled=1 '
    action :create_if_missing
  end
# Install the MongoDB packages and associated tools.

  yum_package 'mongodb-org'
elsif %w(debian ubuntu).include?(node['platform'])
#Create the apt resource list

  file '/etc/apt/sources.list.d/mongodb-org-3.2.list' do
    content '
    deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse '
  end
#Install the mongodb packages
  execute 'apt update' do
    command 'sudo apt-get update'
  end
  apt_package 'mongodb-org' do
    options '--allow-unauthenticated'
  end
else 
print "Unsupported OS"
end

# Start MongoDB and ensure it will start following a system reboot

service 'mongod' do
  action [ :enable, :start ]
end
