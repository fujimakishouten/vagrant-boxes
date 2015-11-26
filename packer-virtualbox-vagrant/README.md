# Vanilla Debian Packer templates

The templates here are used to create the Debian Vagrant base boxes available at 
https://atlas.hashicorp.com/debian/

## Direct Download

	vagrant init debian/jessie64
	vagrant init debian/wheezy64

## Rebuilding the base boxes
See https://wiki.debian.org/Teams/Cloud/RebuildVagrantBaseBoxes

## Releasing a new version:
1. Call the `make all` target
2. Update the version in atlas_tools/uploadBox.pl and call the script to upload to atlas
3. Release the boxes on atlas
4. Call `make release` to sign the boxes and upload the checksums to Alioth

## Credits

  Many thanks to [Mitchell Hashimoto](https://github.com/mitchellh/) for his awesome work on [Packer](https://github.com/mitchellh/packer) and [Vagrant](https://github.com/mitchellh/vagrant), [![Tech-Angels](http://media.tumblr.com/tumblr_m5ay3bQiER1qa44ov.png)](http://www.tech-angels.com)

  
