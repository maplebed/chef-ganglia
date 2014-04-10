require 'spec_helper'
# require 'chefspec/server'

describe 'ganglia::gmetad' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      platform: 'ubuntu',
      version: '12.04'
    )
    runner.converge(described_recipe)
  end
  before do
    hosts = []
    ['host1', 'host2'].each do |host|
      n = stub_node(platform: 'ubuntu', version: '12.04') do |node|
        node.name(host)
        node.automatic['ipaddress'] = host
      end
      hosts << n
    end
    stub_search(:node, '*:*').and_return(hosts)
  end

  it 'installs the gmetad package' do
    expect(chef_run).to install_package('gmetad')
  end
  it 'creates the rrd dir' do
    expect(chef_run).to create_directory('/var/lib/ganglia/rrds').with(
      owner: 'nobody'
      )
  end
  context "default config" do
    it 'installs rrdcached' do
      expect(chef_run).to install_package('rrdcached')
    end
    it 'includes runit' do
      expect(chef_run).to include_recipe('runit')
    end
    # it 'creates rrdacched runit service' do
    #   # commented out until I figure out how to stub runit_service
    #   expect(chef_run).to create_runit_service('rrdcached')
    # end
    it 'installs socat package' do
      expect(chef_run).to install_package('socat')
    end
    it 'creates gmetad.conf' do
      expect(chef_run).to create_template("/etc/ganglia/gmetad.conf").with(
        variables: {
          :clusters => {"default" => 18649},
          :hosts => ["host1", "host2"],
          :grid_name => "default"
        }
      )
      expect(chef_run).to render_file("/etc/ganglia/gmetad.conf").with_content(
        %Q[data_source "default" host2:18649 host1:18649])
    end
  end
end