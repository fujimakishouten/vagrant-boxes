These images can be used with QEMU-KVM, Virtualbox or any other virtualization
backend that supports raw images.

You can login as root on the VM console without a password (but not over SSH),
and there are no other users. You can add new users using adduser as usual, and
you probably want to add them to the `sudo` group.

If you want to build your own image with a customized default user, which will
be added to the sudo group, you can do something like this:

```
$ make jessie VMDEBOOTSTRAP_OPTIONS='--user myuser/mypassword'
```
