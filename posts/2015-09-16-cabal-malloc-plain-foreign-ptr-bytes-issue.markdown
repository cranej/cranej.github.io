---
layout: post
title:  "Haskell platform cabal mallocPlainForeignPtrBytes issue"
date: 2015-09-16 09:51
tags:
- haskell
- cabal
- tips
---

# mallocPlainForeignPtrBytes: size must be >= 0 on Windows#

The issue happens on Windows 8 and later when you run `cabal install`. The simplest solution is to set environment `HTTP_PROXY` and `HTTPS_PROXY` to a working proxy.  For example in PowerShell you can run:

````bash
$env:HTTP_PROXY="http://yourproxy1"
$env:HTTPS_PROXY="http://yourproxy"
````

The root cause seems to be that on Windows 8 or later http library of Haskell cannot detect system proxy configuration anymore. See [this issue](https://github.com/haskell/HTTP/issues/72) for details.
