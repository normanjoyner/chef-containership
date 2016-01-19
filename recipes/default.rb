# apt get update
include_recipe "apt"

# start docker
docker_service "default" do
  action [:create]
end

# pull requisite containership docker images
node['containership']['requisite_images'].each do |image|
  docker_image image['name'] do
    tag image['tag']
    action :pull
  end
end

# install dependencies
["g++", "make"].each do |pkg|
  package pkg do
    action :install
  end
end

if node['containership']['btrfs']['enabled']
  # install btrfs-tools
  package "btrfs-tools" do
    action :install
  end

  # create containership btrfs directory
  directory "/mnt/containership/btrfs" do
    recursive true
    action :create
  end

  # enable btrfs kernel module
  execute "enables btrfs kernel module" do
    command "modprobe btrfs"
    action :run
  end
end

# install nodejs
include_recipe "nodejs"

# install containership
nodejs_npm "containership" do
  version node['containership']['version']
  not_if "cs -v | grep \"^v#{node['containership']['version']}$\""
end

# build required plugins
required_plugins = node['containership']['plugins']['default'].concat(node['containership']['plugins'][node['containership']['agent']['mode']])

required_plugins.each do |plugin|
  # install plugin
  execute "installing containership plugin: #{plugin['name']}" do
    command "cs plugin add #{plugin['name']}"
    action :run
  end

  # configure plugin if options exist
  unless plugin['options'].empty?
    configure_opts = plugin['options'].map do |opt, value|
      ["--", opt, "=", value].join("")
    end

    execute "configuring containership plugin: #{plugin['name']}" do
      command "cs plugin configure #{plugin['name']} #{configure_opts.join(" ")}"
    end
  end
end

# write cluster id file if specified
if node['containership']['agent']['cluster-id']
  file "create containership cluster_id file" do
    path "/tmp/cluster_id"
    content "{\"cluster_id\": \"#{node['containership']['agent']['cluster-id']}\"}"
    action :create
  end
end

agent_options = node['containership']['agent'].map do |option, value|
  if value.class == Chef::Node::ImmutableArray
    value_string = value.map do |val|
      ["--", option, "=", val].join("")
    end
    value_string.join(" ")
  elsif !value.empty?
    ["--", option, "=", value].join("")
  end
end

# write upstart job
template "/etc/init/containership.conf" do
  source "upstart.erb"
  variables({
    :agent_options => agent_options.compact.join(" ")
  })
  notifies :restart, 'service[containership]', :immediately
  action :create
end

# define containership service
service "containership" do
  provider Chef::Provider::Service::Upstart
  action :start
end
