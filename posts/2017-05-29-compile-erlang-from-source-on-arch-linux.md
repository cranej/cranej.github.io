---
layout: post
title:  "Unable to find openssl when compiling Erlang/OTP from source on Arch Linux"
date: 2017-05-29 20:49
tags:
- erlang
- archlinux
---

One important reason to choose Arch Linux is that you can always get newest versions of software:
> Arch Linux strives to maintain the latest stable release versions of its software.

However, today I learned that Arch Linux went *farther than stable versions* - currently in Arch Linux repository, the available version of Erlang is '20-rc1' which is not a stable version. Then I have troubles when trying [nerves-project][1] on my newly bought Raspberry Pi. Nerves-project did a great job though - it supports the **real** latest **stable** version of Erlang - 19.3.

I have to compile Erlang 19.3 from source on my laptop. [Kerl][2] is the tool recommended by Erlang official site to install and manage different versions of Erlang/OTP easily. So no reason to compile it from scratch. But `kerl` seems has problem with `open-ssl` installation on Arch Linux, as it complains the following:

```
APPLICATIONS DISABLED (See: /home/xxx/.kerl/builds/19.3/otp_build_19.3.log)
 * crypto         : No usable OpenSSL found
 * odbc           : ODBC library - link check failed
 * ssh            : No usable OpenSSL found
 * ssl            : No usable OpenSSL found
```

I have tried to specify `KERL_CONFIGURE_OPTIONS=--with-ssl=/usr/lib/openssl-1.0` with `kerl`, but had no luck. After some searches on the web, I found [this][3] helpful article, although it's to solve the problem when installing Erlang via `asdf`, the cause is the same:

> The issue is definitely that Erlang/OTP does not build with OpenSSL 1.1
> ArchLinux openssl 1.0 package directory structure does not play well with erlang --with-ssl flag. The directory structure should be something like DIR/lib/libssl.so for it to work with --with-ssl=DIR, but it is installed at /usr/lib/openssl-1.0/libssl.so

And finally got Erlang 19.3 complied by manually restructuring `open-ssl` directory:

```bash
mkdir -p $HOME/.openssl-1.0
cd $HOME/.openssl.1-0
ln -sf /usr/lib/openssl-1.0 lib
ln -sf /usr/include/openssl-1.0 include
```

And then explicitly specify `--with-ssl` option:

    KERL_CONFIGURE_OPTIONS="--with-ssl=$HOME/.openssl-1.0" kerl build 19.3 19.3

Hope this is helpful.

[1]: http://nerves-project.org/
[2]: https://github.com/kerl/kerl
[3]: https://bbs.archlinux.org/viewtopic.php?id=226174
