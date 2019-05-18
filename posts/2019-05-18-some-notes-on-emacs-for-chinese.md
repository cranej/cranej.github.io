---
layout: post
title:  "针对中文用户的一些 Emacs 设置备忘"
date: 2019-05-18 15:10
tags:
- emacs
- tooling
---

### 中文输入法在 Emacs 里面无法调出

需要在启动 Emacs 时确保 `LC_CTYPE` 的值是 `zh_CN.UTF-8` 。

* 从 teminal 启动 emacs 只要启动前保证环境变量设置正确即可，比如 `LC_CTYPE="zh_CN.UTF-8" emacs` 这样启动。
* 从 Gnome 的 Desktop file 启动 - 在 gnome 3 里面全局快捷搜索启动就是这种启动方式 - 可以编辑 `/usr/share/applications/emacs.desktop` 文件， 把 `Exec=emacs %F` 改成 `Exec=env LC_CTYPE="zh_CN.UTF-8" emacs %F`。

### OrgMode 中文文档中使用 Bold/Italic/Underline/Verbatim/Code 等标记时必须前后加额外空格的问题

默认情况下 OrgMode 是用空格作为这些标记的前后分割符的，比如 `something =test= abc` 中的 test 会显示为 verbatim 格式 `test` 。 中文不是有效的分割符，你必须这么写才会生效： `中文 =系统= 友好`。
但是这样就会有不想要的空格出现在文档中。 可以这么绕过：

```lisp
(setq org-emphasis-regexp-components
      ;; markup 记号前后允许中文
      (list (concat " \t('\"{"            "[:nonascii:]")
            (concat "- \t.,:!?;'\")}\\["  "[:nonascii:]")
            " \t\r\n,\"'"
            "."
            1))
```

**注意** 这个设置必须在任何 OrgMode 代码执行之前， 也就是说如果你不用 `use-package` 来加载 package ，那么这个设置要出现在 `(require 'org)` 之前。 用 `use-package` 话必须加在 `:init` section 的**开头**。
需要重启 Emacs 生效。
