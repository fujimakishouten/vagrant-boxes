# Vanilla Debian Packer templates

The templates here are used to create the Debian Vagrant base boxes available at 
https://atlas.hashicorp.com/debian/

## Direct Download

	vagrant init debian/jessie64

## Prerequisites for rebuilding the base boxes

* Packer (>= 0.7.5)(http://www.packer.io/downloads.html)
* Vagrant (>= 1.6.5)(http://downloads.vagrantup.com/)
* Virtualbox

## Configure the vagrant box

Edit the debian-8-jessie-virtualbox.json (or the other one you prefer) and check the variables at the beginning of the file.

*Note*:

The debian iso file name contains the version number and, as soon as a new release will be out and the 770 will be removed from the debian servers, the debian-870-wheezy.json file will be outdated and you'll get the "ISO download failed" error after running the build command.
To fix the issue go on http://cdimage.debian.org/debian-cd/current/amd64/iso-cd/, check which is the latest net-inst version and copy its checksum from the MD5SUMS file. Then edit the .json file and update these variables at the beginning of the .json file:
* "iso_url": update the link to the iso file
* "iso_md5": insert the new MD5 checksum
* "vm_name": update the version

## Build vagrant box

```bash
$ packer build debian-8-jessie-virtualbox.json
```

### Install your new box

```bash
$ vagrant box add debian-8-jessie ./packer_virtualbox-iso_virtualbox.box
```

The VM image has been imported to vagrant, it's now available on your system.

### Create a new Vagrant env based on the box 

```bash
$  vagrant init debian-8-jessie
$  vagrant up
```



### Ignore vagrant boxes in git

```bash
$ echo ".vagrant" >> ~/.gitignore
```

## Credits

  Many thanks to [Mitchell Hashimoto](https://github.com/mitchellh/) for his awesome work on [Packer](https://github.com/mitchellh/packer) and [Vagrant](https://github.com/mitchellh/vagrant), [![Tech-Angels](http://media.tumblr.com/tumblr_m5ay3bQiER1qa44ov.png)](http://www.tech-angels.com)

  
