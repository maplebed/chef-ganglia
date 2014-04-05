require 'spec_helper'

describe 'ganglia::default' do
  let(:chef_run) do
    # runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04', log_level: :debug)
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
    runner.converge(described_recipe) 
  end

  it 'installs the ganglia monitor package' do
    expect(chef_run).to install_package('ganglia-monitor')
  end

  it 'starts the ganglia-monitor service' do
    expect(chef_run).to start_service('ganglia-monitor')
  end

  it 'writes the gmond.conf' do
    template = chef_run.template('/etc/ganglia/gmond.conf')
    expect(template).to be
    # expect(template.mode).to eq('0644')
    # expect(template.owner).to eq('root')
    # expect(template.group).to eq('root')
  end

end
