---
layout: post
title:  "Compile Erlang/OTP from source on Arch Linux"
date: 2017-05-29 20:49
tags:
- erlang
- archlinux
---

One important reason I choose Arch Linux is that you can always get newest version of software:
> Arch Linux strives to maintain the latest stable release versions of its software.

However, today I learned it goes *farer than stable versions* - currently in Arch Linux repository, the available version of Erlang is '20-rc1' which is not a stable version. Then I have throubles when trying [nerves-project][1] on my newly bought Raspberry Pi. Nerves-project did a great job though - it supports the **real** latest **stable** version of Erlang - 19.3.

I have to compile Erlang 19.3 from source on my laptop. [Kerl][2] is the tool recommended by Erlang offical site to install and manage different versions of Erlang/OTP easily. So no reason to do it by hand from scratch.

[1]: http://nerves-project.org/
[2]: https://github.com/kerl/kerl
