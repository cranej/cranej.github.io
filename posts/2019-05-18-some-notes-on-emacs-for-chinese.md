---
layout: post
title:  "针对中文用户的一些 Emacs 设置备忘"
date: 2019-05-19
tags:
- emacs
- tooling
---

### 中文输入法在 Emacs 里面无法调出

需要在启动 Emacs 时确保 `LC_CTYPE` 的值是 `zh_CN.UTF-8` 。

* 从 teminal 启动 emacs 只要启动前保证环境变量设置正确即可，比如这样启动：
    ```bash
    $ LC_CTYPE="zh_CN.UTF-8" emacs
    ```
* 从 Gnome 的 Desktop file 启动 - 在 gnome 3 里面全局快捷搜索启动就是这种启动方式 - 可以编辑 `/usr/share/applications/emacs.desktop` 文件， 把
    ```
    Exec=emacs %F
    ```
    改成
    ```
    Exec=env LC_CTYPE="zh_CN.UTF-8" emacs %F
    ```
  这种方法有个缺陷是每次你升级了 Emacs 之后，这个 desktop 文件会被覆盖，需要重复这个改动。 一种可能的解决办法是按照 [Gnome doc](https://developer.gnome.org/integration-guide/stable/desktop-files.html.en) 所说，把这个 desktop file 放到 `~/.local/share/applications` 下面，这样只对当前用户生效，但升级不会覆盖。

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

变量 `org-emphasis-regexp-components` 顾名思义是 org mode 用来识别有效的 `emphasis` 的规则， `C-h v org-emphasis-regexp-components` 可以看到 `list` 中每个部分分别是什么意思。

**注意**这个设置必须在任何 OrgMode 代码执行之前， 也就是说:
1. 如果你不用 [use-package](https://github.com/jwiegley/use-package) 来加载 package ，那么这个设置要出现在 `(require 'org)` 之前；
2. 如果使用 `use-package` 必须加在 `:init` section 的**最开始**，确保它在所有 org-mode 相关代码之前被执行。

需要重启 Emacs 生效。
