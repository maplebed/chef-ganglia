require 'spec_helper'

describe 'ganglia::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      platform: 'ubuntu',
      version: '12.04'
    )
    runner.converge(described_recipe)
  end

  it 'installs the ganglia monitor package' do
    expect(chef_run).to install_package('ganglia-monitor')
  end

  it 'starts the ganglia-monitor service' do
    expect(chef_run).to start_service('ganglia-monitor')
  end

  context "multicast mode" do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(
        platform: 'ubuntu',
        version: '12.04'
      )
      runner.converge(described_recipe)
    end
    it 'writes the gmond.conf' do
      expect(chef_run).to create_template('/etc/ganglia/gmond.conf').with(
        variables: {
          :cluster_name => "default",
          :ports => [18649]
        }
      )
    end
  end
  context "unicast mode" do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(
        platform: 'ubuntu',
        version: '12.04'
      )
      runner.node.set['ganglia']['unicast'] = true
      runner.converge(described_recipe)
    end
    it 'writes the gmond.conf' do
      expect(chef_run).to create_template('/etc/ganglia/gmond.conf').with(
        variables: {
          :cluster_name=>"default",
          :gmond_collectors=>["127.0.0.1"],
          :ports=>[18649],
          :spoof_hostname=>false,
          :hostname=>"Fauxhai"
        }
      )
    end
  end
  context "unicast mode with specifc server_host" do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(
        platform: 'ubuntu',
        version: '12.04'
      )
      runner.node.set['ganglia']['unicast'] = true
      runner.node.set['ganglia']['server_host'] = 'ganglia.example.com'
      runner.converge(described_recipe)
    end
    it 'writes the gmond.conf' do
      expect(chef_run).to create_template('/etc/ganglia/gmond.conf').with(
        variables: {
          :cluster_name=>"default",
          :gmond_collectors=>["ganglia.example.com"],
          :ports=>[18649],
          :spoof_hostname=>false,
          :hostname=>"Fauxhai"
        }
      )
    end
  end
  context "unicast mode with specifc gmond_collector search" do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(
        platform: 'ubuntu',
        version: '12.04',
        #log_level: :debug
      )
      runner.node.set['ganglia']['unicast'] = true
      runner.converge(described_recipe)
    end
    before do
      ChefSpec::Server.create_role('ganglia', { default_attributes: {} })
      ['host1', 'host2'].each do |host|
        n = stub_node(platform: 'ubuntu', version: '12.04') do |node|
          node.run_list(['role[ganglia]'])
          node.name(host)
          node.automatic['ipaddress'] = host
        end
        ChefSpec::Server.create_node(n)
      end
    end
    it 'writes the gmond.conf' do
      expect(chef_run).to create_template('/etc/ganglia/gmond.conf').with(
        variables: {
          :cluster_name=>"default",
          :gmond_collectors=>["host1", "host2"],
          :ports=>[18649],
          :spoof_hostname=>false,
          :hostname=>"Fauxhai"
        }
      )
    end
  end
end
