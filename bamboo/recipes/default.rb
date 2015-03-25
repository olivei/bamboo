
user node[:bamboo][:user] do
  home node[:bamboo][:installpath]
  shell "/bin/bash"
end

directory node[:bamboo][:installpath] do
  mode 0755
  owner node[:bamboo][:user]
  action :create
end


remote_file "#{node['bamboo']['installpath']}/atlassian-bamboo-5.8.1.tar.gz" do
  source "https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-5.8.1.tar.gz"
  owner 'root'
  mode '0755'
  action :create_if_missing 
end



bash "install_bamboo" do
  user node[:bamboo][:user]
  cwd node[:bamboo][:installpath]
  code <<-EOH
    tar -xvzf atlassian-bamboo-5.8.1.tar.gz
    ln -s atlassian-bamboo-5.8.1/ current
  EOH
  not_if do
    File.exists?("#{node['bamboo']['installpath']}/atlassian-bamboo-5.8.1.tar.gz")
  end
end

template "#{node['bamboo']['installpath']}/atlassian-bamboo-5.8.1/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties" do
  mode 00644
  source 'bamboo.erb'
end


template "/etc/init.d/bamboo" do
  source "bamboo.sh.erb"
  mode 0755
  owner 'root'
  group 'root'
end


bash "install_bamboo2" do
  user "root"
  code <<-EOH
    /sbin/chkconfig --add bamboo
  EOH
  not_if do
    File.exists?("/etc/init.d/bamboo")
  end
end

