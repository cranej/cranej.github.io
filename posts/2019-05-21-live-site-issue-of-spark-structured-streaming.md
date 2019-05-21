---
layout: post
title:  "一次 Spark Structured Streaming 程序 bug 导致的熬夜"
date: 2019-05-21
tags:
- spark
- streaming
---

由于一个线上问题，昨天夜里也就是今天凌晨接近三点才睡觉……

这是一个 Spark Structured Streaming 写的流式计费出帐程序。 昨天晚上九点多监控报警，上线查看发现一个 micro batch 花了 40 分钟才跑完，接下来的一个 batch 花了一个小时， 而正在运行的那个 batch 已经超过了 70
 分钟仍然无望结束。

这个出帐程序需要处理 session 数据，所以使用了 `flatMapGroupsWithStates` 来自己管理 session 相关的逻辑。 Session state 是一个类似下面的结构：
```scala
case class SessionState(
    field1: String,
    field2: Int,
    // more fields...
    sessionDataList: List[SessionData]
)
```
考虑到可能以后升级这个结构会有字段的改动，为了保正不 break Spark 的 checkpoint 数据兼容， 在这个结构上又包了一层：
```scala
case class WrappedState(
    stateContent: Array[Byte],
    // other meta fields...
)
```
这样对于 Spark 来说我们的 state 就永远是一个字节数组。 在 `flatMapGroupsWithStates` function 里面处理 `SessionState` 和 `WrappedState` 的转化 - 通过 `json4s` 做序列化/反序列化。

那么昨天的问题出在哪里呢？

1. 流程序的数据源出现了一个非常极端的状况 - 有一个 session 在两个多小时内产生了 几百万 条 SessionData；
2. 程序先按照 session id 分组，然后每个组会有自己的 state ，每个组会调一下 `flatMapGroupsWithStates` 我们指定的 function 来做 session 处理;
3. 每个组只会由一个 executor 一个 partition 来处理 - 这一点应该是显而易见的，否则就无法正确处理 session 逻辑了;
4. 那么这种异常巨大的 session 就会被一个**单个的 function 实例**来处理;
5. 而由于每个 micro batch 处理到这个 session 的时候 session 都未到终态，那每次处理都会是： `读出上个 batch 保存的 WrappedState` -> `json 反序列化成 SessionState` -> `添加当前数据到 SessionState` -> `json 序列化并保存状态`;
6. 这里相当于在 session 未结束之前每个 micro batch 都要 反序列化/序列化 一个几百万条的 `List[SessionData]` - `json4s` 反序列化这么大的数据是非常非常慢的;
7. 就出现了每个 micro batch 处理的速度越来越慢，并且进入一个恶性循环，最终没有希望能够在 SLA 内追上进度。

昨天夜里的临时解决方案是临时简单改代码逻辑，强行把这个 session id 的状态过滤掉以免 block 所有 session 的正常处理，后续再通过其它手段单独处理这个 session 。

今天紧急上了一个 patch 彻底解决这个问题 - 在每一次 `flatMapGroupsWithStates` function 处理状态数据的时候，提前把本来放在 session 到终态时才做的聚合逻辑针对 SessionState 里的 sessionDataList 先做一下。
也就是保证 `List[SessionData]` 不会变的过大导致反序列化的性能问题。 这么做有个前提，就是我们的聚合逻辑是一个 `Monoid` 操作，可以把聚合逻辑提前，否则只能想其它办法了。
