require "spec_helper"
require "serverspec"

package = "argus"
service = "argus"
config  = "/etc/argus.conf"
user    = "argus"
group   = "argus"
ports   = [ 561 ]
log_dir = "/var/log/argus"
pid_file = "/var/run/argus.em0.*.pid"
interface = "ind:eth0"
default_user = "root"
default_group = "root"
sasldb_file = "/etc/sasldb2.db"
sasldblistusers_command = "sasldblistusers"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/argus.conf"
  interface = "ind:em0"
  default_group = "wheel"
  package = "argus3"
  package = "argus-sasl"
  sasldb_file = "/usr/local/etc/sasldb2.db"
  sasldblistusers_command = "sasldblistusers2"
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/argus") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^argus_pidfile="#{ Regexp.escape(pid_file) }"$/) }
  end
end

describe package(package) do
  it { should be_installed }
end 

describe file(config) do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/^ARGUS_CHROOT="#{ Regexp.escape(log_dir) }"$/) }
  its(:content) { should match(/^ARGUS_FLOW_TYPE="Bidirectional"$/) }
  its(:content) { should match(/^ARGUS_FLOW_KEY="CLASSIC_5_TUPLE"$/) }
  its(:content) { should match(/^ARGUS_DAEMON="yes"$/) }
  its(:content) { should match(/^ARGUS_MONITOR_ID="default-freebsd-103-amd64"$/) }
  its(:content) { should match(/^ARGUS_ACCESS_PORT=561$/) }
  its(:content) { should match(/^ARGUS_BIND_IP="127\.0\.0\.1"$/) }
  its(:content) { should match(/^ARGUS_INTERFACE="#{ interface }"$/) }
  its(:content) { should match(/^ARGUS_SETUSER_ID="#{ user }"$/) }
  its(:content) { should match(/^ARGUS_SETGROUP_ID="#{ group }"$/) }
  its(:content) { should match(/^ARGUS_OUTPUT_FILE="#{ Regexp.escape(log_dir)}\/argus\.ra"$/) }
  its(:content) { should match(/^ARGUS_FLOW_STATUS_INTERVAL=5$/) }
  its(:content) { should match(/^ARGUS_MAR_STATUS_INTERVAL=60$/) }
  its(:content) { should match(/^ARGUS_DEBUG_LEVEL=0$/) }
  its(:content) { should match(/^ARGUS_GENERATE_RESPONSE_TIME_DATA="yes"$/) }
  its(:content) { should match(/^ARGUS_GENERATE_PACKET_SIZE="yes"$/) }
  its(:content) { should match(/^ARGUS_GENERATE_APPBYTE_METRIC="yes"$/) }
  its(:content) { should match(/^ARGUS_GENERATE_TCP_PERF_METRIC="yes"$/) }
  its(:content) { should match(/^ARGUS_GENERATE_BIDIRECTIONAL_TIMESTAMPS="yes"$/) }
  its(:content) { should match(/^ARGUS_FILTER="ip"$/) }
  its(:content) { should match(/^ARGUS_TRACK_DUPLICATES="yes"$/) }
  its(:content) { should match(/^ARGUS_SET_PID="yes"$/) }
  its(:content) { should match(/^ARGUS_PID_PATH="\/var\/run"$/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe file(sasldb_file) do
  it { should be_file }
  it { should be_mode 600 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe command(sasldblistusers_command) do
  its(:stdout) { should match(/^foo@reallyenglish\.com: userPassword$/) }
  its(:stderr) { should match(/^$/) }
  its(:exit_status) { should eq 0 }
end
