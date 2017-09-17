Vagrant.configure("2") do |config|
  require 'yaml'
  settings = YAML.load_file 'settings.yml'

  config.vbguest.auto_update = settings['vbguest']['auto_update']
  config.vbguest.no_remote = settings['vbguest']['no_remote']

  config.vm.box = "bento/centos-7.3"
  config.vm.box_check_update = false

  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder "./", "/vagrant", mount_options: ['dmode=777', 'fmode=777'], disabled: true
  for dir in settings['mount']['vagrant']
    mounted=File.basename("#{dir}")
    config.vm.synced_folder "#{dir}", "/vagrant/#{mounted}", mount_options: ['dmode=777', 'fmode=777']
  end
  if Vagrant.has_plugin?("vagrant-gatling-rsync")
    config.gatling.latency = settings['rsync']['latency']
    config.gatling.time_format = "%H:%M:%S"
    config.gatling.rsync_on_startup = false
  end
  if File.exist?(settings['mount']['rsync']) then
    config.vm.synced_folder settings['mount']['rsync'], "/rsync", type: "rsync", rsync__args: ["--verbose", "--archive", "--delete", "--copy-links", "--times", "-z", "--chmod=Du=rwx,Dgo=rwx,Fu=rwx,Fgo=rwx"]
  end
  if File.exist?(settings['mount']['m2']) then
    config.vm.synced_folder settings['mount']['m2'], "/m2", mount_options: ['dmode=777', 'fmode=777']
  end
  if File.exist?(settings['mount']['workspace']) then
    config.vm.synced_folder settings['mount']['workspace'], "/workspace", mount_options: ['dmode=777', 'fmode=777']
  end
  
  
  config.hostsupdater.aliases = settings['hostsupdater']['aliases']

  config.vm.provider "virtualbox" do |vb|
    vb.memory = settings['vb']['memory']
    vb.cpus = settings['vb']['cpus']
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end

  config.vm.provision "firstRunning", type: "shell", run: "never", path: "first_running.sh"

  config.vm.provision "oracle", type: "shell", run: "never", privileged: false, path: "oracle/initialOnVagrant.sh", args: ["/vagrant/oracle"]
  
  config.vm.provision "p2", type: "shell", run: "never", inline: "echo two"
  config.vm.provision "p3", type: "shell", run: "never", inline: "echo three"

end
