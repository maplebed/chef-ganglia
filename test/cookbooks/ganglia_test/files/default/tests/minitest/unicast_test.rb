require File.expand_path('../support/helpers', __FILE__)
describe "ganglia_test::unicast" do
  include Helpers::GangliaTest
  describe 'creates the gmond configuration' do
    it 'must exist' do
        file('/etc/ganglia/gmond.conf').must_exist
    end
    it 'must include at least one udp_send stanza' do
        file('/etc/ganglia/gmond.conf').must_include("udp_send_channel")
    end
    it 'should be in unicast mode' do
        file('/etc/ganglia/gmond.conf').must_include("host = ")
    end
  end

  describe 'starts the gmond daemon' do
    # this doesn't work because 'service ganglia-monitor status' is not supported.
    # should test using 'ps' instead
    it 'must be running' do
      result = assert_sh("ps -ef")
      assert_includes result, "gmond"
        #       ps_output = shell_out("ps -ef")
        # ps_output.must_include("gmond")
    end
    # it 'must be running' do
    #     service("ganglia-monitor").must_be_running
    # end
    it 'must_be_listening_on_8649' do
        TCPSocket.open("localhost", 8649) do |client|
            assert_instance_of TCPSocket, client
            client.close
        end
    end
  end
end
