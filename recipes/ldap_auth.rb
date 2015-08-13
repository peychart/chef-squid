#
# Cookbook Name:: chef-squid_ldap_auth
# Recipe:: default
#
# Copyright (C) 2014 PE, pf.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

package 'libldap2-dev' do
  action :upgrade
end

cookbook_file '/usr/local/sbin/basic_ldap_auth' do
  source "#{node['platform']}-#{node['platform_version']}"
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

