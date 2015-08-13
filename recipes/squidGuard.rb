#
# Cookbook Name:: chef-squidGuard
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

%w(wget squidGuard).each do |package|
  package package do
    action :upgrade
  end
end

chefSquidGuard = node['chef-squid']['squidGuard']

# chef-squidGuard/libraries/default.rb
template '/etc/squidguard/squidGuard.conf' do
  source 'etc_squidguard_squidGuard.conf.erb'
  mode 0644
  variables({
    :src => chef_squidGuard_load_values( chefSquidGuard, 'src' ),
    :dest=> chef_squidGuard_load_values( chefSquidGuard, 'dest' ),
    :acl => chef_squidGuard_load_values( chefSquidGuard, 'acl' ),
    :defaultAcl => chef_squidGuard_load_values( chefSquidGuard, 'acl', 'default' )
  })
end

confile = chefSquidGuard['squid3_confile']
dirname = chefSquidGuard['blacklists_path'].sub(/\/$/, '')

( (chefSquidGuard['blacklists_urls'].is_a? Array) ? chefSquidGuard['blacklists_urls'] : Array[chefSquidGuard['blacklists_urls']] ).uniq.each do |url|

  archname = url.sub(/^.*\//, '')

  bash "wget" do
    code "mkdir -p #{dirname}; cd #{dirname} && (wget #{url} || cp #{archname}.bck #{archname} || (rm -f #{archname} && false))"
    not_if do ::File.exists?("#{dirname}/#{archname}") end
  end
  puts "wget #{url} done..."

  bash "untar" do
    code "cd #{dirname} && rm -rf $(echo #{archname}| sed -e 's/\.tgz$//' -e 's/\.tar\.gz$//') && (tar xzf #{archname} && mv #{archname} #{archname}.bck; ERR=$?; rm -f #{archname}; [ $ERR -eq 0 ])"
  end

end if dirname

bash "createdb" do
  code "squidGuard -dC all # && $(which squid{,3}) -k reconfigure"
  only_if do ::File.exists?("#{dirname}") end
end

bash "chown" do
  code "usr=$(echo $(grep -s '^[^#]*cache_effective_user' #{confile})| cut -d' ' -f2); chown -R ${usr:=root} #{dirname}"
  only_if do ::File.exists?("#{dirname}/") end
end if dirname && confile

web_app "squid" do
  cookbook 'apache2'
  server_name 'squid'
  server_aliases [node['fqdn'], "squid"]
  docroot "/var/lib/squidguard/db/html"
  enable true
end
