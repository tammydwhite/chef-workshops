describe service 'tomcat.service' do
  it { should be_running }
end

describe file '/etc/systemd/system/tomcat.service' do
  its ('content') { should match 'JAVA_HOME=/usr/lib/jvm/jre' }
end


