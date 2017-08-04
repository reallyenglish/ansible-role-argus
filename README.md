# ansible-role-argus

Installs and configures `argus(8)`.

## Missing Ubuntu support

`deb` packages for our targeted Ubuntu releases are version 2.x, which has been
officially discouraged.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `argus_user` | user of `argus` | `{{ __argus_user }}` |
| `argus_group` | group of `argus` | `{{ __argus_group }}` |
| `argus_log_dir` | path to log directory | `/var/log/argus` |
| `argus_log_dir_mode` | permission of log directory | `0755` |
| `argus_log_dir_group` | group of log directory | `{{ argus_group }}` |
| `argus_service` | service name of `argus` | `{{ __argus_service }}` |
| `argus_package` | package name of `argus` | `{{ __argus_package }}` |
| `argus_conf_dir` | path to directory where `argus.conf` resides | `{{ __argus_conf_dir }}` |
| `argus_conf_file` | path to `argus.conf` | `{{ __argus_conf_dir }}/argus.conf` |
| `argus_pid_dir` | path to PID directory | `{{ __argus_pid_dir }}` |
| `argus_pid_file` | path to PID file | `{{ __argus_pid_dir }}/{{ argus_service }}.pid` |
| `argus_service_enable` | enable `argus` service when `true` | `true` |
| `argus_include_role_cyrus_sasl` | when `yes`, the role includes and execute `reallyenglish.cyrus_sasl` (see below) | `no` |
| `argus_flags` | not used yet | `""` |
| `argus_config` | a dict of `argus.conf` (see below) | `{}` |

## `argus_include_role_cyrus_sasl`

When `yes`, the role includes and execute
[`reallyenglish.cyrus-sasl`](https://github.com/reallyenglish/ansible-role-cyrus-sasl)
during the play, which makes it possible to manage SASL database without ugly
hacks. This is only supported in `ansible` version _at least_ 2.2 and later.

## `argus_config`

The key is variable described in `argus.conf(5)` and the value is the value of
the variable. Example:

```yaml
argus_config:
  ARGUS_CHROOT: "{{ argus_log_dir }}"
  ARGUS_FLOW_TYPE: Bidirectional
  ARGUS_FLOW_KEY: CLASSIC_5_TUPLE
  ARGUS_DAEMON: "yes"
  ARGUS_MONITOR_ID: "{{ ansible_fqdn }}"
  ARGUS_ACCESS_PORT: 561
  ARGUS_BIND_IP: 127.0.0.1
  ARGUS_INTERFACE: "ind:{{ ansible_default_ipv4.interface }}"
  ARGUS_SETUSER_ID: "{{ argus_user }}"
  ARGUS_SETGROUP_ID: "{{ argus_group }}"
  ARGUS_OUTPUT_FILE: "{{ argus_log_dir }}/argus.ra"
  ARGUS_FLOW_STATUS_INTERVAL: 5
  ARGUS_MAR_STATUS_INTERVAL: 60
  ARGUS_DEBUG_LEVEL: 0
  ARGUS_GENERATE_RESPONSE_TIME_DATA: "yes"
  ARGUS_GENERATE_PACKET_SIZE: "yes"
  ARGUS_GENERATE_APPBYTE_METRIC: "yes"
  ARGUS_GENERATE_TCP_PERF_METRIC: "yes"
  ARGUS_GENERATE_BIDIRECTIONAL_TIMESTAMPS: "yes"
  ARGUS_FILTER: ip
  ARGUS_TRACK_DUPLICATES: "yes"
  ARGUS_SET_PID: "yes"
  ARGUS_PID_PATH: "{{ argus_pid_dir }}"
  ARGUS_MIN_SSF: 40
  ARGUS_MAX_SSF: 128
```

## FreeBSD

| Variable | Default |
|----------|---------|
| `__argus_user` | `argus` |
| `__argus_group` | `argus` |
| `__argus_service` | `argus` |
| `__argus_package` | `net-mgmt/argus3` |
| `__argus_conf_dir` | `/usr/local/etc` |
| `__argus_pid_dir` | `/var/run` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__argus_user` | `_argus` |
| `__argus_group` | `_argus` |
| `__argus_service` | `argus` |
| `__argus_package` | `argus` |
| `__argus_conf_dir` | `/etc` |
| `__argus_pid_dir` | `/var/run` |

## RedHat

| Variable | Default |
|----------|---------|
| `__argus_user` | `argus` |
| `__argus_group` | `argus` |
| `__argus_service` | `argus` |
| `__argus_package` | `argus` |
| `__argus_conf_dir` | `/etc` |
| `__argus_pid_dir` | `/var/run` |

# Dependencies

* reallyenglish.redhat-repo (RedHat only)

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - ansible-role-argus
    - reallyenglish.argus-clients
    - { role: reallyenglish.cyrus-sasl, when: ansible_os_family == 'FreeBSD' or ansible_os_family == 'RedHat' }
  vars:
    redhat_repo_extra_packages:
      - epel-release
    redhat_repo:
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes
    cyrus_sasl_config:
      argus:
        pwcheck_method: auxprop
        auxprop_plugin: sasldb
        mech_list: DIGEST-MD5
    cyrus_sasl_saslauthd_enable: no
    cyrus_sasl_user:
      foo:
        domain: reallyenglish.com
        appname: "argus"
        password: password
        state: present
    cyrus_sasl_sasldb_group: argus
    cyrus_sasl_sasldb_file_permission: "0640"
    argus_log_dir_mode: "0775"
    argus_config:
      ARGUS_CHROOT: "{{ argus_log_dir }}"
      ARGUS_FLOW_TYPE: Bidirectional
      ARGUS_FLOW_KEY: CLASSIC_5_TUPLE
      ARGUS_DAEMON: "yes"
      ARGUS_MONITOR_ID: "{{ ansible_fqdn }}"
      ARGUS_ACCESS_PORT: 561
      ARGUS_BIND_IP: 127.0.0.1
      ARGUS_INTERFACE: "ind:{{ ansible_default_ipv4.interface }}"
      ARGUS_SETUSER_ID: "{{ argus_user }}"
      ARGUS_SETGROUP_ID: "{{ argus_group }}"
      ARGUS_OUTPUT_FILE: "{{ argus_log_dir }}/argus.ra"
      ARGUS_FLOW_STATUS_INTERVAL: 5
      ARGUS_MAR_STATUS_INTERVAL: 60
      ARGUS_DEBUG_LEVEL: 0
      ARGUS_GENERATE_RESPONSE_TIME_DATA: "yes"
      ARGUS_GENERATE_PACKET_SIZE: "yes"
      ARGUS_GENERATE_APPBYTE_METRIC: "yes"
      ARGUS_GENERATE_TCP_PERF_METRIC: "yes"
      ARGUS_GENERATE_BIDIRECTIONAL_TIMESTAMPS: "yes"
      ARGUS_FILTER: ip
      ARGUS_TRACK_DUPLICATES: "yes"
      ARGUS_SET_PID: "yes"
      ARGUS_PID_PATH: "{{ argus_pid_dir }}"
      ARGUS_MIN_SSF: 40
      ARGUS_MAX_SSF: 128

    # XXX the default in rc.d script assumes the file name is "argus.pid", which is
    # not always the case
    argus_pid_file: "{{ argus_pid_dir }}/argus.em0.*.pid"
    argus_clients_config:
      RA_MIN_SSF: 40
      RA_MAX_SSF: 128
      RA_USER_AUTH: "foo@reallyenglish.com/foo@reallyenglish.com"
      RA_AUTH_PASS: "password"
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
