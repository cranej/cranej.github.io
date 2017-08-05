---
layout: post
title:  "Frustrated issues of git setup on windows and the solution"
date:   2015-10-02 11:36:00
tags:   
- tips
---

Yesterday I spent more than 1 hour trying to upgrade my git to the latest version. I had been stuck on two issues. Fist, `git log` and `git clone` hanged forever. And `git commit -S` complained no secret key found while I do have the key on my machine.    

The second issue is easy to solve as the root cause is `git` uses the `gpg` program installed by git installation program which assumes gnupg home dir is ~/.gnupg. But in my case the gnupg home dir is not there because I installed gnupg by gpg4win.  I simply ran `git config --global gpg.program gpg2` to force git to use the one installed by gpg4win, and the problem solved.

The first one really frustrated me. I tried to uninstall-restart-reinstall a few times but no luck. **Which finally solved these problems** is that when the latest time I reinstall, I chose `Git only from Git Bash` option, and added `C:\Program Files (x86)\Git\bin\git.exe` to PATH manually after the installation.  
I cannot guarantee this approach also works for you because I didn't control the variable. I used 32 bit git installation program in the latest installation but 64 bit one for all other installations.  I cannot tell which part of the changes solved the problem, but it's still worth to try if you are also stuck on the same issue.
