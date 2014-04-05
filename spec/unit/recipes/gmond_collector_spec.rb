require 'spec_helper'

describe 'ganglia::gmond_collector' do
  context "default config" do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(
        platform: 'ubuntu',
        version: '12.04'
      )
      runner.converge(described_recipe)
    end
    it "writes only one gmond.conf" do
      [['default', 18649]].each do |clusterpair|
        cluster, port = clusterpair
        expect(chef_run).to create_template("/etc/ganglia/gmond_collector_#{cluster}.conf").with(
          variables: {
            :cluster_name => cluster,
            :port => port
          }
        )
      end
    end
    it "writes only one gmond init script" do
      [['default', 18649]].each do |clusterpair|
        cluster, port = clusterpair
        expect(chef_run).to create_template("/etc/init.d/ganglia-monitor-#{cluster}").with(
          variables: {
            :cluster_name => cluster,
            :port => port
          }
        )
      end
    end
    it "starts only one gmond" do
      ['default'].each do |cluster|
        expect(chef_run).to start_service("ganglia-monitor-#{cluster}")
      end
    end
  end
  context "two cluster config" do
    let(:chef_run) do
      runner = ChefSpec::Runner.new(
        platform: 'ubuntu',
        version: '12.04'
      )
      runner.node.set['ganglia']['clusterport']['test'] = 1234
      runner.converge(described_recipe)
    end
    it "writes one gmond.conf per cluster" do
      [['default', 18649], ['test', 1234]].each do |cluster, port|
        expect(chef_run).to create_template("/etc/ganglia/gmond_collector_#{cluster}.conf").with(
          variables: {
            :cluster_name => cluster,
            :port => port
          }
        )
      end
    end
    it "writes one gmond init script per cluster" do
      [['default', 18649], ['test', 1234]].each do |cluster, port|
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
end

