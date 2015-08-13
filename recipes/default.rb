#
# Author:: Philippe EYCHART (<peychart@mail.pf>)
# Cookbook Name:: chef-squid
# Resource:: default
#
# Copyright 2015-2017, Philippe EYCHART
#
# Licensed under the GNU License, Version 3;
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.gnu.org/licenses/gpl-3.0.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Providionning:
# apt_get update
# apt_get install -y ruby ruby1.8-dev build-essential wget libruby1.8 rubygems
# gem update --no-rdoc --no-ri
# gem install ohai chef --no-rdoc --no-ri
##if chef-solo (see: https://docs.chef.io/chef_solo.html)
#cat >~/chef/node.json <<@@@
#{
#  "run_list": [ "recipe[chef-squid]" ]
#}
#@@@
#cat >~/chef/solo.rb <<@@@
#file_cache_path "/home/ubuntu/chef"
#cookbook_path "/home/ubuntu/chef/cookbooks"
#json_attribs "/home/ubuntu/chef/node.json"
#@@@
#cat >/var/chef-solo/environments/chef-squid <<@@@
#{
#  "name": "chef-squid",
#  "default_attributes": {
#    "apache2": {
#      "listen_ports": [
#        "80",
#        "443"
#      ]
#    }
#  },
#  "json_class": "Chef::Environment",
#    "description": "SQUID installation",
#    "cookbook_versions": {
#    "couchdb": "= 1.0.0"
#  },
#  "chef_type": "environment"
#  }
#@@@
#chef-solo -c ~/chef/solo.rb -E chef-squid
##endif
#**************************************************************

# packages
package node['chef-squid']['package']

# rhel_family sysconfig
template '/etc/sysconfig/squid' do
  source 'redhat/sysconfig/squid.erb'
  notifies :restart, "service[#{node['chef-squid']['service_name']}]", :delayed
  mode 00644
  only_if { platform_family? 'rhel', 'fedora' }
end

# squid config dir
directory node['chef-squid']['config_dir'] do
  action :create
  recursive true
  owner 'root'
  mode 00755
end

# squid mime config
cookbook_file "#{node['chef-squid']['config_dir']}/mime.conf" do
  source 'mime.conf'
  mode 00644
end

# TODO:
file "#{node['chef-squid']['config_dir']}/msntauth.conf" do
  action :delete
end

# squid config
template node['chef-squid']['config_file'] do
  source 'squid.conf.erb'
  notifies :reload, "service[#{node['chef-squid']['service_name']}]"
  mode 00644
  variables(
    :auth_param => node['chef-squid']['auth_param'],
    :acls => node['chef-squid']['acl'],
    :deny => node['chef-squid']['http_access']['deny'],
    :allow => node['chef-squid']['http_access']['allow'],
    :directives => node['chef-squid']['directives']
    )
end

# services
service node['chef-squid']['service_name'] do
  supports :restart => true, :status => true, :reload => true
  provider Chef::Provider::Service::Upstart if platform?('ubuntu')
  action [:enable, :start]
end
