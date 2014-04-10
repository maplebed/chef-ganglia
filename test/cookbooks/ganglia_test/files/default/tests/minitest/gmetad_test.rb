require File.expand_path('../support/helpers', __FILE__)
describe "ganglia_test::gmetad" do
  include Helpers::GangliaTest
  describe 'creates the gmetad configuration' do
    it 'must exist' do
        file('/etc/ganglia/gmetad.conf').must_exist
    end
    # it 'must include at least one udp_send stanza' do
    #     file('/etc/ganglia/gmond.conf').must_include("udp_send_channel")
    # end
    # it 'should be in multicast mode' do
    #     file('/etc/ganglia/gmond.conf').must_include("mcast_join = 239.2.11.71")
    # end
  end

  describe 'starts the gmetad daemon' do
    # this doesn't work because 'service ganglia-monitor status' is not supported.
    # should test using 'ps' instead
    it 'must be running' do
      result = assert_sh("ps -ef")
      assert_includes result, "gmetad"
        #       ps_output = shell_out("ps -ef")
        # ps_output.must_include("gmond")
    end
    # it 'must be running' do
    #     service("ganglia-monitor").must_be_running
    # end
    it 'must_be_listening_on_8651' do
        TCPSocket.open("localhost", 8651) do |client|
            assert_instance_of TCPSocket, client
            client.close
        end
    end
  end
end
