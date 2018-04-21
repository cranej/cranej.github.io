---
layout: post
title:  "Yet another article of python 2 Unicode"
date: 2017-09-06 22:00
tags:
- unicode
- python
---

# Yet another article of python 2 Unicode

## Internal representation of python string

Python string actually is byte string - just an array of raw bytes.

1. Source code
2. It's just byte array

## What is actually stored in python string depends on file encoding/In which encoding python interpreter interpret your source code.

1. Tell python interpreter to use 'utf-8' and 'gb2312', and compare the bytes stored in python string with code point table.
2. Or it is because "Editor" saved the source code in 'utf-8'/'gb2312'? (use `xxd` to dump hex and compare)

## What encode/decode does

1. Is just follow the code point table to translate Unicode to bytes, and vice vise.
