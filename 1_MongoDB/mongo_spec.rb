describe service 'mongod' do
  it { should be_running }
end

if %w(redhat centos).include?(os['family'])

  describe file '/etc/yum.repos.d/mongodb.repo' do
    its ('content') { should match 'enabled=1' }
  end

elsif %w(debian ubuntu).include?(os['family'])

  describe file '/etc/apt/sources.list.d/mongodb-org-3.2.list' do
    its ('content') { should match 'multiverse' }
  end
end
