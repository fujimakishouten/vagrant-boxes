## Local configuration

`make` need to be run as root (i.e. `sudo make`).

a file named `config.mk` in this directory will be sourced by the Makefile. You
can use to e.g. set a local APT proxy for creating the images:

```
export http_proxy=http://localhost:3142
```
