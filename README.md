squid Cookbook
==============

Configures squid as a caching proxy.


Recipes
-------
### default attributes

See: https://github.com/peychart/chef-squid/blob/master/attributes/default.rb

All default attributes can be modified.

The optionals (`node['chef-squid']['cache_peer']`, node['chef-squid']['auth_param']['definition'] and `node['chef-squid']['directives']`), if set, will be written verbatim to the template.

* node['chef-squid']['cache_peer']: can be a string or an array of strings,
* node['chef-squid']['auth_param']['definition']: can be a string or an array of strings,
* node['chef-squid']['directives']: can be a string, an array of strings, a hash (Hash[0] will be a comment in conf) or an array of hashs (hashs contain strings or strings arrays).

node['chef-squid']['auth_param']['acl_exception']: allows to sets, if needed, some acls which can be excluded from authentification.

Example:

```text
 node['chef-squid']['directives']['REDIRECT_PROGRAM'] = [
        "redirect_program /usr/bin/squidGuard",
        "redirect_children 60"
 ]
 ...
 node['chef-squid']['auth_param']['definition'] = [
        "basic program /usr/local/sbin/basic_ldap_auth -v 3 -b dc=gov,dc=pf -f \"(uid=%s)\" -F \"cn=proxyAccess,cn=squid,ou=applications,dc=gov,dc=pf\" ldap.srv.gov.pf",
        "basic children 70",
        "basic realm Authentification SIPf LDAP, merci de vous authentifier.",
        "basic credentialsttl 1 minutes"
 ]
 node['chef-squid']['auth_param']['acl_exception']['dstdomain'] = "squid"
 node['chef-squid']['auth_param']['acl_exception']['srcdomain'] = [ ".srv.gov.pf", ".dev.gov.pf" ]
 ...
 node['chef-squid']['directives']['LOGS'] = [
        "## Logs format for awstats ##",
        "logformat combined %>a %ui %un [%{%d/%b/%Y:%H:%M:%S +0000}tl] \"%rm %ru HTTP/%rv\" %Hs %<st \"%{Referer}>h\" \"%{User-Agent}>h\" %Ss:%Sh",
        "access_log stdio:/var/log/squid3/access.log combined"
 ]
```

node['chef-squid']['auth_param']

Usage
-----

...

### About LDAP Authentication

# squid_ldap_auth patch

```text
 This patch adds a role control (the "memberUid" attribute of an dedicated LDAP entry must contain the "userid") on the authorisation to connect a squid session...

## Patch compilation with role management

 Depends on 'libldap2-dev'.

    wget the last official source code release for squid-cache (see http://www.squid-cache.org/Download/),
    tar xzf squid-3.X.X.tar.gz
    cd squid-3.X.X/
    cd helpers/basic_auth/LDAP
    Apply the patch to the C source
    cd -
    ./configure --enable-basic-auth-helpers=LDAP ; make
    cd -
    Put the produced binary ('basic_ldap_auth') where you need it...

 Regarding this cookbook, binaries are in files whose names match the corresponding distribution...
```

## binary usage

```text
 Call example in "squid.conf" file:

    ...
    auth_param basic program basic_ldap_auth -v 3 -b dc=my,dc=domain -f "(uid=%s)" -F "cn=proxyAccess,ou=role,ou=application,dc=my,dc=domain" ldap.my.domain

## Attributes definition in cookbook

 Example:

 default['chef-squid']['auth_param']['definition'] = [ 
        "basic program /usr/local/sbin/basic_ldap_auth -v 3 -b dc=my,dc=domain -f \"(uid=%s)\" -F \"cn=proxyAccess,cn=squid,ou=applications,dc=my,dc=domain\" ldap.srv.my.domain",
        "basic children 70",
        "basic realm Authentification SI LDAP, merci de vous authentifier.",
        "basic credentialsttl 1 minutes"
]
 default['chef-squid']['auth_param']['acl_exception']['dstdomain'] = "me"
 default['chef-squid']['auth_param']['acl_exception']['srcdomain'] = [ 
        ".srv.my.domain",
        ".dev.my.domain"
]
```

### About squidGuard

```text
Coming soon...
```

Example Databag with chef-serviceAttributes
-------------------------------------------

```text
{
  "id": "squid",
  "apache": {
    "!listen_addresses": [
      "me"
    ],
    "!listen_ports": [
      8080
    ],
    "mpm": "prefork"
  },
  "chef-hostsfile": [
    {
      "127.0.1.1": {
        "action": "remove"
      }
    },
    {
      ":ipaddress": {
        "domain": ":fqdn",
        "aliases": [
          ":hostname",
          "me"
        ]
      }
    }
  ],
  "chef-squid": {
    "port": "me:3128",
    "log_dir": "/var/log/squid3",
    "cache_size": "65536",
    "cache_mem": "8192",
    "cache_dir": "/var/spool/squid3/cache1",
    "cache_peer": [
      "icp_port 3130",
      "icp_access allow all",
      "cache_peer squid2.toriki.srv.my.domain sibling 3128 3130"
    ],
    "acl": [
      "Safe_ports port 444",
      ...
      "Safe_ports port 18080",
      "",
      "deniedFiles url_regex -i \\.mp3$ \\.avi$ \\.xvid$ \\.mkv$"
    ],
    "http_access": {
      "deny": [
        "deniedFiles"
      ],
      "allow": [
      ]
    },
    "directives": {
      "OPTIMIZATIONS": [
        "dns_nameservers 192.168.1.100",
        "forwarded_for off",
        "error_directory /usr/share/squid3/errors/French",
        "cache_swap_low 90",
        "cache_swap_high 95",
        "memory_replacement_policy heap LFUDA",
        "cache_replacement_policy heap LFUDA",
        "maximum_object_size 50 MB",
        "memory_pools off",
        "maximum_object_size_in_memory 50 KB",
        "quick_abort_min 0 KB",
        "quick_abort_max 0 KB",
        "log_icp_queries off",
        "client_db off",
        "buffered_logs on",
        "half_closed_clients off",
        "",
        "cache_mgr root",
        "cache_effective_user proxy",
        "cache_effective_group proxy",
        "cache_store_log none",
        "debug_options ALL,1",
        "logfile_rotate 9",
        "hierarchy_stoplist cgi-bin ?",
        "",
        "# Complementary ACLs:",
        "acl MY_SERVERS srcdomain .srv.my.domain",
        "acl MY_SERVERS srcdomain .dev.my.domain",
        "cache deny MY_SERVERS",
        "always_direct allow MY_SERVERS"
      ],
      "SNMP": [
        "acl SRC_SNMP_AUTORISEES src 192.168.1.1 192.168.1.2",
        "acl SNMP_COMMUNITY_VALIDE snmp_community XXXXXXXXXX",
        "snmp_access allow SNMP_COMMUNITY_VALIDE SRC_SNMP_AUTORISEES",
        "snmp_access deny all",
        "snmp_port 3401"
      ],
      "REDIRECT_PROGRAM": [
        "redirect_program /usr/bin/squidGuard",
        "redirect_children 60"
      ],
      "LOGS": [
        "## Format des logs pour awstats ##",
        "logformat combined %>a %ui %un [%{%d/%b/%Y:%H:%M:%S +0000}tl] \"%rm %ru HTTP/%rv\" %Hs %<st \"%{Referer}>h\" \"%{User-Agent}>h\" %Ss:%Sh",
        "acl CHECK dstdomain squid",
        "access_log stdio:/var/log/squid3/access.log combined !CHECK"
      ]
    },
    "auth_param": {
      "definition": [
        "basic program /usr/local/sbin/basic_ldap_auth -v 3 -b dc=my,dc=domain -f \"(uid=%s)\" -F \"cn=proxyAccess,cn=squid,ou=applications,dc=my,dc=domain\" ldap.srv.my.domain",
        "basic children 70",
        "basic realm Authentification SIPf LDAP, merci de vous authentifier.",
        "basic credentialsttl 1 minutes"
      ],
      "acl_exception": {
        "dstdomain": "squid",
        "srcdomain": [
          ".srv.my.domain",
          ".dev.my.domain"
        ]
      }
    },
    "squidGuard": {
      "enable": true,
      "!blacklists_urls": [
        "http://repository.srv.my.domain/squidguard_contrib/blacklists.tgz",
        "http://repository.srv.my.domain/squidguard_contrib/sit.tgz"
      ]
    }
  },
  "limits": {
    "system_limits": [
      {
        "domain": "squid",
        "type": "-",
        "item": "nofile",
        "value": "65535"
      }
    ]
  },
  "sysctl": {
    "params": {
      "fs.file-max": "65535",
      "net.core.rmem_default": "262144",
      "net.core.rmem_max": "262144",
      "net.core.wmem_default": "262144",
      "net.core.wmem_max": "262144",
      "net.ipv4.tcp_rmem": "4096 87380 8388608",
      "net.ipv4.tcp_wmem": "4096 65536 8388608",
      "net.ipv4.tcp_mem": "50576 64768 98152",
      "net.ipv4.tcp_low_latency": "1",
      "net.core.netdev_max_backlog": "4000",
      "net.ipv4.ip_local_port_range": "1024 65000",
      "net.ipv4.tcp_max_syn_backlog": "16384",
      "net.ipv4.ip_forward": 1,
      "net.ipv4.ip_nonlocal_bind": 1
    }
  },
  "lvm_volume_group": [
    {
      "name": "ubuntu-1404-vg",
      "physical_volumes": [
        "/dev/sdb"
      ],
      "logical_volume": [
        {
          "name": "swap_1",
          "size": "100%FREE"
        }
      ]
    },
    {
      "name": "vg_data",
      "physical_volumes": [
        "/dev/sdc"
      ],
      "logical_volume": [
        {
          "name": "squid",
          "size": "80G",
          "filesystem": "reiserfs",
          "mount_point": {
            "location": "/var/spool/squid3",
            "options": "noatime,notail"
          }
        }
      ]
    }
  ],
  "chef-iptables": {
    "ipv4rules": {
      "filter": {
        "INPUT": {
          "ssh": "--source 192.168.1.11 --protocol tcp --dport 22 --match state --state NEW --jump ACCEPT",
          "squid": [
            "--destination squid --protocol tcp --dport 3128 --match state --state NEW --jump ACCEPT",
            "--destination me --protocol tcp --dport 3128 --match state --state NEW --jump ACCEPT"
          ]
        },
        "OUTPUT": {
          "default": "-j ACCEPT"
        }
      }
    }
  }
}
```

Example of role definition
--------------------------

```json
{
 "override_attributes": {
    "chef-serviceAttributes": {
      "service": [
        "squid"
      ]
    }
  },
  "run_list": [
    "recipe[chef-serviceAttributes]",	// See: https://github.com/peychart/chef-serviceAttributes
    "recipe[chef-lvm]",
    "recipe[chef-hostsfile]",
    "recipe[sysctl::apply]",
    "recipe[limits]",
    "recipe[chef-squid]",
    "recipe[apache2::mod_php5]",
    "recipe[chef-iptables]"
  ]
}
```

Use in Ubuntu charm
-------------------

```text
Coming soon...
```


License & Authors
-----------------

- Author:: Philippe Eychart (peychart@mail.pf)

```text
Licensed under the GNU License, Version 3;
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.gnu.org/licenses/gpl-3.0.html

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
