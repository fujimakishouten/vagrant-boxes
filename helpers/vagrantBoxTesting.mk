define functest
 @echo functional testing for $< box
 @vagrant box add --name $1 $2 --provider $3 $(TEE)
 @ # this will also test that sync is working
 @cp ../helpers/package_report . $(TEE)
 @vagrant init $1 $(TEE)
 @vagrant up --provider $3 $(TEE)
 @vagrant ssh -c "sh /vagrant/package_report" $(TEE)
 @$(RM) package_report $(TEE)
 @vagrant ssh -c "sudo apt-get --quiet --yes install figlet \
     && ( lsb_release --release --codename ) | figlet" $(TEE)
 @vagrant halt $(TEE)
 @vagrant destroy --force $(TEE)
 @vagrant box remove $1 --provider $3 $(TEE)
 @rm Vagrantfile $(TEE)
endef

define forcecleantest
	-vagrant halt --force
	-vagrant destroy --force
	-$(RM) Vagrantfile
	-vagrant box remove $1 --provider $2
endef

clean::
	rm -rf .vagrant/
