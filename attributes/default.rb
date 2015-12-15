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

default['chef-squid']['port'] = 3128
default['chef-squid']['network'] = nil
default['chef-squid']['timeout'] = '10'
default['chef-squid']['opts'] = ''
default['chef-squid']['directives'] = ''

default['chef-squid']['package'] = 'squid'
default['chef-squid']['version'] = '3.1'
default['chef-squid']['config_dir'] = '/etc/squid'
default['chef-squid']['config_file'] = '/etc/squid/squid.conf'
default['chef-squid']['log_dir'] = '/var/log/squid'
default['chef-squid']['cache_dir'] = '/var/spool/squid'
default['chef-squid']['coredump_dir'] = '/var/spool/squid'
default['chef-squid']['service_name'] = 'squid3'
default['chef-squid']['acl_element'] = 'url_regex'

default['chef-squid']['listen_interface'] = node['network']['interfaces'].dup.reject { |k, v| k == 'lo' }.keys.first
default['chef-squid']['cache_mem'] = '2048'
default['chef-squid']['cache_size'] = '100'
default['chef-squid']['max_obj_size'] = 1024
default['chef-squid']['max_obj_size_unit'] = 'MB'
default['chef-squid']['enable_cache_dir'] = true

default['chef-squid']['auth_param']['definition'] = []
default['chef-squid']['auth_param']['acl_exception'] = {}

default['chef-squid']['acl'] = nil
default['chef-squid']['http_access']['deny']  = nil
default['chef-squid']['http_access']['allow'] = nil

default['chef-squid']['squidGuard']['enable'] = false
default['chef-squid']['squidGuard']['squid3_confile'] = '/etc/squid3/squid.conf'
default['chef-squid']['squidGuard']['blacklists_path'] = '/var/lib/squidguard/db'
default['chef-squid']['squidGuard']['blacklists_urls'] = 'ftp://ftp.univ-tlse1.fr/pub/reseau/cache/squidguard_contrib/blacklists.tar.gz'

default['chef-squid']['squidGuard']['src']['databag_name'] = 'squidGuard_src'
default['chef-squid']['squidGuard']['dest']['databag_name']= 'squidGuard_dest'
default['chef-squid']['squidGuard']['acl']['databag_name'] = 'squidGuard_acl'

case platform_family

when 'debian'
  case platform
  when 'debian'
    if node['platform_version'] == '6.0.3'
      default['chef-squid']['package'] = 'squid3'
      default['chef-squid']['config_dir'] = '/etc/squid3'
      default['chef-squid']['config_file'] = '/etc/squid3/squid.conf'
      default['chef-squid']['service_name'] = 'squid3'
    end

  when 'ubuntu'
    if node['platform_version'] == '10.04'
      default['chef-squid']['version'] = '2.7'
    elsif node['platform_version'] == '12.04' || node['platform_version'] =~ /1[34]\./
      default['chef-squid']['package'] = 'squid3'
      default['chef-squid']['version'] = '3.1' if node['platform_version'] =~ /13\./
      default['chef-squid']['version'] = '3.3' if node['platform_version'] =~ /14\./
      default['chef-squid']['config_dir'] = '/etc/squid3'
      default['chef-squid']['config_file'] = '/etc/squid3/squid.conf'
      default['chef-squid']['log_dir'] = '/var/log/squid3'
      default['chef-squid']['cache_dir'] = '/var/spool/squid3'
      default['chef-squid']['coredump_dir'] = '/var/spool/squid3'
      default['chef-squid']['service_name'] = 'squid3'
    end
  end

when 'rhel'
  rhel_version = node['platform_version'].to_f
  default['squid']['version'] = '2.6' if rhel_version >= 5 && rhel_version < 6

when 'fedora'
  default['squid']['version'] = '3.2'

when 'smartos'
  default['squid']['listen_interface'] = 'net0'

end
