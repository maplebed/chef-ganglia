require 'spec_helper'

describe 'ganglia::gmond_collector' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      platform: 'ubuntu',
      version: '12.04'
    )
    runner.node.set['ganglia']['clusterport']['test'] = 1234
    runner.node.set['ganglia']['host_cluster'] = {
      "default" => 0,
      "test" => 1
    }
    runner.converge(described_recipe)
  end

  it "writes one gmond.conf per cluster" do
    [['default', 18649], ['test', 1234]].each do |clusterpair|
      cluster, port = clusterpair
      expect(chef_run).to create_template("/etc/ganglia/gmond_collector_#{cluster}.conf").with(
        variables: {
          :cluster_name => cluster,
          :port => port
        }
      )
    end
  end
  it "writes one gmond init script per cluster" do
    [['default', 18649], ['test', 1234]].each do |clusterpair|
      cluster, port = clusterpair
      expect(chef_run).to create_template("/etc/init.d/ganglia-monitor-#{cluster}").with(
        variables: {
          :cluster_name => cluster,
          :port => port
        }
      )
    end
  end
  it "starts one gmond per cluster" do
    ['default', 'test'].each do |cluster|
      expect(chef_run).to start_service("ganglia-monitor-#{cluster}")
    end
  end
end

