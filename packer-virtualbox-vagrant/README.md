## Releasing a new minor version:
* export VAGRANT_CLOUD_TOKEN=$(gpg --decrypt ../helpers/token.gpg)
* Call `make ${CODENAME}.uploaded` to build the box, sign the box, upload and release the box on 
  app.vagrantup.com
* Commit the new checksums and changelog, push to salsa
