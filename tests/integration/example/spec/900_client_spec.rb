require "spec_helper"

describe server(:client1) do
  it "connects to argus server on server" do
    r = current_server.ssh_exec("ra -S #{server(:server1).server.address}:561 -n -N 1 -- ip")
    expect(r).to match(/^\s+StartTime\s+Flgs\s+Proto\s+SrcAddr\s+Sport\s+Dir\s+DstAddr\s+Dport\s+TotPkts\s+TotBytes\s+State/)
  end
end
