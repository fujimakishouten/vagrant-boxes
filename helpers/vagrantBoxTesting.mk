define functest
 @ # $< is the fist dependency of the target
 @echo functional testing for $< box
 @vagrant box add --name $1 $2
 @vagrant init $1
 @vagrant up
 @vagrant ssh -c "sudo apt-get update"
 @vagrant ssh -c "sudo apt-get --quiet --yes install linuxlogo && linuxlogo"
 @vagrant ssh -c "test -f /vagrant/Makefile && echo -e $(tput bold) syncing successfull !"
 @vagrant halt
 @vagrant destroy --force
 @vagrant box remove $1
 @rm Vagrantfile
endef

define forcecleantest
	-vagrant halt --force
	-vagrant destroy --force
	-$(RM) Vagrantfile
	-vagrant box remove $1
endef
