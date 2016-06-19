---
layout: post
title:  Use arbitrary key for given email address in GPGMail
date:   2015-10-04 20:58:00
tags:
- tips
- mac
- gpg
---

Recently I picked up my old MacBook Pro which has been idle for at least one year and start to setup necessary softwares on it. These two days, I have been struggling to make **GPGMail** work as what I expected.  I'm not saying **GPGMail** is bad that to make it work I have to "struggle". It made some assumptions, which in my opinion do not make much sense:

  1. It assumes that everyone will add all email addresses they have to user IDs of their gpg key. Thus it find secret key to sign email by the email address of the `from` field when you composing a email. If there is no such key found, the *sign* icon will be greyed.
  2. It assumes that you always want to encrypt to yourself when composing a encrypted email. Frankly speaking, it's a good assumption. But consider the first assumption together, if you didn't add your email address to the user IDs of your key, you can never find a public key to encrypt to yourself because it use the same way to find a public key. Thus the *encrypt* icon is always grey no matter you have the public key for the recipient or not. And there is no way to change this behavior on the UI.

The first solution came out is to use Thunderbird with **Enigmail** as the email client, because **Enigmail** does not try to match the secret key with email address, it just let you configure it in preferences. Unfortunately, Thunderbird has some annoying bugs with mail at outlook.com. I could not fix them after searching on the web and trying to uninstall-reinstall several times.

Then I thought I could create a service for Apple Mail using Automator. When composing a new email message, this service pass the message content to a shell script which sign and encrypt the content, and then paste back to the mail message.  Most parts of the service are easy to implement. You can easily get the message content and copy it to clipboard by some Automator built in functionalities, then use a simple command like `pbpaste | gpg -u $1 -e $2 -s -e | pbcopy` to sign and encrypt
it and copy the result back to clipboard.  To avoid to input recipient (`$2`) and user id (`$1`) parameter for `gpg` every time, we need to read these information from the `to` and `from` field of the new message composing window. This is what stuck me. There is no built in actions from Automator to do such things, and I could not find a way to do so in AppleScript editor.

And finally I found the article [GPGMail 2 hidden settings](https://gpgtools.tenderapp.com/kb/gpgmail-faq/gpgmail-2-hidden-settings#add-a-mapping-for-a-missing-uid-to-a-public-key). All problems are solved just after I added a custom emial-keyid mapping.

```shell
defaults write org.gpgtools.common KeyMapping -dict-add email fingerprint
```
