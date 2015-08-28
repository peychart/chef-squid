squid Cookbook
==============

Configures squid as a caching proxy.


Recipes
-------
### default

```text
All default attributes can be modified.

The optionals (`node['squid']['cache_peer']` and `node['squid']['directives']`), if set, will be written verbatim to the template.

node['squid']['cache_peer']: can be a string or an array of strings,
node['squid']['directives']: can be a string, an array of strings, a hash (Hash[0] will be a comment in conf) or an array of hashs (hashs contain strings or strings arrays).

Example:

 node['squid']['directives']['REDIRECT_PROGRAM'] = [
        "redirect_program /usr/bin/squidGuard",
        "redirect_children 60"
 ]
 node['squid']['directives']['LOGS'] = [
        "## Logs format for awstats ##",
        "logformat combined %>a %ui %un [%{%d/%b/%Y:%H:%M:%S +0000}tl] \"%rm %ru HTTP/%rv\" %Hs %<st \"%{Referer}>h\" \"%{User-Agent}>h\" %Ss:%Sh",
        "access_log stdio:/var/log/squid3/access.log combined"
 ]
```

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
        "basic program /usr/local/sbin/basic_ldap_auth -v 3 -b dc=my,dc=pf -f \"(uid=%s)\" -F \"cn=proxyAccess,cn=squid,ou=applications,dc=my,dc=domain\" ldap.srv.my.domain",
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
Coming soon...
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
