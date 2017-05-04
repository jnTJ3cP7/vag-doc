Vagrant.configure("2") do |config|
  # 以下の２項目はアップデートしたいときは逆のbooleanにする
  config.vbguest.auto_update = false
  config.vbguest.no_remote = true

  config.vm.box = "bento/centos-7.3"
  config.vm.box_check_update = false

  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder "./", "/vagrant", mount_options: ['dmode=777', 'fmode=777']
  # config.hostsupdater.aliases = ["local.co.jp"]

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3078"
    vb.cpus = "2"
  end

  config.vm.provision "firstRunning", type: "shell", run: "never", path: "first_running.sh"

  config.vm.provision "oracle", type: "shell", run: "never", privileged: false, path: "oracle/initialOnVagrant.sh"
  
  config.vm.provision "p2", type: "shell", run: "never", inline: "echo two"
  config.vm.provision "p3", type: "shell", run: "never", inline: "echo three"

end
