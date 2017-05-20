---
layout: post
title:  "The power of GnuPG: Use a gpg key as a ssh key, with gpg-agent"
date: 2017-05-20 20:49
tags:
- gpg
- ssh
- tips
---

In GnuPG 2.0 and 2.1, we are able to use `gpg-agent` to fully replace `ssh-agent`. And since 2.1, use a gpg key as a ssh key with gpg-agent becomes much easier than in previous versions. No need to convert/export gpg keys as ssh keys via other tools anymore. For me, the biggest benefit is that in this way, I can manage my gpg and ssh keys the same way in gnupg keyring.

## Properly configure and start up `gpg-agent`

### Configure

Firstly we need to tell `gpg-agent` to **enable ssh support** by adding the following lines to `~/.gnupg/gpg-agent.conf`:

    enable-ssh-support

And optionally, to **avoid typing passphrase every time**, add the following lines also:

    default-cache-ttl-ssh 10800
    max-cache-ttl-ssh 10800

These two lines set both maximum and default ssh key cache time to 3 hours.

### Start `gpg-agent` at startup

Although GnuPG programs are able to start `gpg-agent` on demand, we still have to ensure the agent is started when we logged into the system as ssh client has no way to know that it needs to start `gpg-agent` nor how to do it. My choice is to add the following lines into `.zshrc`, you can adjust the script and where to put it in based on your need:

```bash
#Gnupg
export GPG_TTY=$(tty)

unset SSH_AGENT_PID
if ! pgrep -x -u "${USER}" gpg-agent >/dev/null 2>&1; then
  gpg-connect-agent /bye >/dev/null 2>&1
fi

export SSH_AUTH_SOCK=/run/user/$UID/gnupg/S.gpg-agent.ssh
```

The `GPG_TTY` line has nothing to do with `gpg-agent` but is necessary if you want curses based Pinentry to work without problems.

### Make sure `ssh-agent` does not start automatically any more

If you are using a full featured desktop environment like Gnome or KDE, `ssh-agent` must already be configured to run automatically at system startup. You need to consult the documentations of Gnome or KDE to remove it from the auto-start list.

If you are using [Arch Linux][1] with a minimalist window manager like [i3wm][2] as me, nothing needs to be done.

## Create an authentication purposed gpg key and use it for ssh authentication

### Create a gpg key with the sole purpose

Assume you already have a gpg key, if not please create one via `gpg --gen-key` first. Now add a new key which has only one capability - authentication:

1. Run `gpg --expert --edit-key [your key id here]`
2. In the interactive shell run `addkey`
3. Select `RSA (set your own capabilities)`
4. Select `S` then `E` to turn off the default sign and encrypt capabilities, then select `A` to turn on authentication.
5. Select `Q` to finish capabilities selection and finish other steps.

### Use the new created key for ssh authentication

Prior to gpg version 2.1, you will have to use some third party tools to convert the gpg key to ssh key and use it as other ordinary ssh keys. Start from version 2.1 things became much easier.

1. Find out *keygrip* of the new created key by running `gpg2 --with-keygrip -k [your key id]`.
2. Write it into `~/.gnupg/sshcontrol` as a separate line.

Now if you run `ssh-add -l` you should be able to see the new added key.

To export the public key in a correct form for `~/.ssh/authorized_keys` and github etc., use `ssh-add -L` instead.


[1]: https://www.archlinux.org/
[2]: https://i3wm.org/
