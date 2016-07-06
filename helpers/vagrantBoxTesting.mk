define functest
 @ # $< is the fist dependency of the target
 @echo functional testing for $< box
 @vagrant box add --name $1 $2 $(TEE)
 @vagrant init $1 $(TEE)
 @vagrant up $(TEE)
 @vagrant ssh -c "sudo apt-get --quiet --yes install figlet \
     && ( lsb_release --release --codename ) | figlet" $(TEE)
 @vagrant ssh -c "test -f /vagrant/Makefile \
     && echo -e $(tput bold) syncing successfull !" $(TEE)
 @vagrant halt $(TEE)
 @vagrant destroy --force $(TEE)
 @vagrant box remove $1 $(TEE)
 @rm Vagrantfile $(TEE)
endef

define forcecleantest
	-vagrant halt --force
	-vagrant destroy --force
	-$(RM) Vagrantfile
	-vagrant box remove $1
endef
