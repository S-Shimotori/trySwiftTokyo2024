# Chapter 2. Ping

The ping command is one way to find out if your computer can access a particular server or network device.
自分のパソコンが特定のサーバやネットワーク機器にアクセスできるかどうか調べる方法のひとつにPingコマンドがあります。

This chapter provides an introduction to ping for implementation, and also examines how to implement a ping program using socket communication.
本章ではPingを実装するためにPingの紹介を行い、さらにソケット通信を用いたPingプログラムの実装方法について検討します。

## What Ping is / そもそもPingとは何か

`man ping` has the following description:
`man ping` には次の説明があります。

> ping – send ICMP ECHO_REQUEST packets to network hosts

We often say "send a ping". The ping command is a program that sends ICMP Echo Request messages.
In the output of ping, there is an entry `icmp_seq=n`. This indicates that this is a reply to the `n`th ICMP Echo Request.
私たちはしばしば「pingを送信する」と言いますが、PingコマンドはICMP Echo Requestというメッセージを複数回送信するプログラムです。  
pingの出力には `icmp_seq=n` という項目があります。これは `n` 回目に送ったICMP Echo Requestの返信であることを表しています。

```
$ ping -c 3 example.com
PING example.com (93.184.216.34): 56 data bytes
64 bytes from 93.184.216.34: icmp_seq=0 ttl=52 time=106.954 ms
64 bytes from 93.184.216.34: icmp_seq=1 ttl=52 time=106.588 ms
64 bytes from 93.184.216.34: icmp_seq=2 ttl=52 time=108.068 ms

--- example.com ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 106.588/107.203/108.068/0.629 ms
```

Ping will repeat the following steps if you don't change its configuration.
デフォルト設定のままであればpingは次の処理を繰り返し行います。

1. Send an ICMP Echo Request to the specific address / 指定のアドレスにICMO Echo Requestを1つ送る
2. Wait one second / 1秒待つ
  - Success if the Ping command receives an ICMP Echo Reply within one second / 1秒経過する前にICMP Echo Replyを受信したら成功。
  - Timeout if the Ping command didn't receive / 1秒経過しても受信できなかったらタイムアウト。
3. Send an ICMP Echo Request again / 次のICMO Echo Requestを送る

```
0                    1                    2
|--------------------|--------------------|----------> T
 S(wait...)R          S(wait.............)TS(wait...
```

- S: Send an ICMP Echo Request / ICMP Echo Requestの送信
- R: Receive an ICMP Echo Reply / ICMP Echo Replyの受信
- T: Timeout / タイムアウト

To display a single line of output, "64 bytes from ...", Ping sends an ICMP Echo Request and receive an ICMP Echo Reply.
Ping will display a timeout message if it cannot receive an ICMP Echo Reply within the time limit.
"64 bytes from ..."という一行の出力を得るためにICMP Echo RequestおよびICMP Echo Replyの送受信が一往復行われています。  
もし制限時間までにICMP Echo Replyが返ってこなければPingはタイムアウトのメッセージを表示します。

```
Request timeout for icmp_seq 0
Request timeout for icmp_seq 1
```

## Exchanging an ICMP Echo Request and an ICMP Echo Reply using socket communication / ソケット通信によるICMP Echo Requestの送信とICMP Echo Replyの受信

Socket communication allows you to send an ICMP Echo Request and an ICMP Echo Reply.
ソケット通信ならICMP Echo Requestを送りICMP Echo Replyを受信することができます。

```
-----------------------> T
 S(wait...)R
```

Open a datagram socket and perform an exchange with the following steps:
データグラムソケットをオープンしたのち次の手順で一往復ぶんの処理を行います。

1. Send an ICMP Echo Request using `sendto` / `sendto` 関数でICMP Echo Requestを送信する。
2. Waiting for an ICMP Echo Reply with `poll` / `poll` 関数でICMP Echo Replyの到着を待つ。
3. Read data from a received ICMP Echo Reply using `recvfrom`. / `recvfrom` 関数で到着したICMP Echo Replyを読む。

Repeat these steps to send multiple times as Ping.
Pingのように複数回送信を行うなら一連の処理を繰り返せばよいです。

I will show you how to use POSIX functions from Swift in Chapter 3.
3章でSwiftからPOSIX関数を利用する方法を紹介します。

### Handling a file descriptor / ファイルディスクリプタの取り扱い

File descriptors are represented by `Int32` values in Swift, while they are represented by `Int` values in C. Although it is possible to implement a Ping program using `Int32` values directly, it is safer to wrap them in a structure that conforms to `~Copyable`.
Chapter 4 introduces file descriptors and `~Copyable`.
ファイルディスクリプタはCプログラムでは `Int` 型、Swiftプログラムでは `Int32` 型の値で表されます。 `Int32` 型の値をそのまま扱ってもPingプログラムを完成させることができますが `~Copyable` である構造体でラップすると安全に扱うことができます。
4章でファイルディスクリプタおよび `~Copyable` について紹介します。

### Creating an ICMP Echo Request message data and decoding an ICMP Echo Reply message data / ICMP Echo Requestメッセージデータの作成とICMP Echo Replyメッセージデータのデコード

You need to prepare an ICMP Echo Request message as binary data. The format of an ICMP Echo Request is simple enough to be implemented using a structure. A received ICMP Echo Reply can be decoded using a structure too.
Chapter 5 introduces the ICMP Echo Request format, and Chapter 6 shows how to use a structure.
送信するICMP Echo Requestはバイナリデータのかたちで用意しなければなりません。ICMP Echo Requestのフォーマットは単純なので構造体を利用することで簡単に用意することができます。受信したICMP Echo Replyのバイナリデータも構造体を利用してデコードすることが可能です。  
5章でICMP Echo Requestのフォーマットについて紹介し、6章で構造体の利用方法を紹介します。

### Error handling / エラー処理

Socket functions return a value that represents error when they fails. You must assume a scenario when your program doesn't receive an ICMP Echo Reply within timeout. Implement this logic if necessary:
ソケットを操作する関数は何らかの理由で失敗することがあり、その場合エラーを表す値を返却します。制限時間までにICMP Echo Replyを受け取れずタイムアウトしたときのことも想定しなくてはいけません。必要に応じて次の処理を実装するようにします。

- Check if there are any errors by examining their return values and the 'errno' variable. / 関数がエラーの発生を示す値を返したり `errno` がエラーを指したりしていないか逐一確認する
- If the server does not respond within the specified time limit, it will be considered a failure and treated as a timeout. /  制限時間内にサーバから応答がなければ何らかの障害があったとみなしてタイムアウト扱いにする

#### Decision timeout / タイムアウトの判定

How can we determine timeout?
タイムアウトの判定はどのように行えばよいでしょうか。


The easiest way is to utilize the `timeout` parameter in the `poll` function. 
For instance, polling for a maximum of one second, and set timeout if the function returns `0` and you cannot read a reply message.
最も簡単な実装は `poll` 関数の引数 `timeout` を利用することです。例えば `poll` 関数で最大1秒のポーリングを行い、その間に応答メッセージが読み込み可能にならず戻り値 `0` を得たらタイムアウトとします。

```
0                    1
|--------------------|----------> T
 S(polling..........)T
```

This way is effective when sending a message only once or when the decision timeout has been finished before sending the next message.
However, it is not appropriate when the nth and n+1 polls may occur simultaneously, especially if the timeout period is too long.
この方法は1往復しかメッセージを送らない場合や次のメッセージの処理を始める前にタイムアウト判定を完了するケースで有効です。  
n回目のポーリング処理とn+1回目のポーリング処理を同時に行う可能性がある場合、具体的にはタイムアウトまでの猶予が長い場合などには向きません。

```
0                    1                    2
|--------------------|--------------------|----------> T
 S(polling...............................)T
                      S(polling......)R
                                           S(polling...
```

Considering the situations, we find these two ideas:
そういったケースを考慮すると次の2つの手法が浮かびます。

- Use different sockets for each request and poll each replies with timeout / 一往復ごとに異なるソケットを使用し、それぞれについて時間制限ありのポーリングを行う。
- Set a timer by yourself every time you send an ICMP Echo Request / ICMP Echo Requestを送信するたびに自分でタイマーをセットする。

At first glance, the first method seems simple. However, this method does not work. Datagram sockets receives all UDP messages sent to its own process, so there is no point in having multiple sockets.
Thus, a single socket is responsible for all polling operations, and your application determines timeout by itself. With this method, there is no problem even if multiple ICMP Echoes are exchanged at the same time, for example, by allowing a long timeout period.
一見すると1つ目の手法が簡単に思えます。しかしこの方法はうまくいきません。データグラムソケットは自プロセス宛のUDP通信メッセージなら全て受信できてしまうためソケットを複数用意しても意味がないからです。  
そこで、1つのソケットが全てのポーリング処理を担い、タイムアウトはアプリケーションが判定することにします。この方法であればタイムアウトまでの猶予を長く持つなどして同時に複数のICMP Echoをやりとりしても問題ありません。

## About deadman / deadmanについて

This section introduces deadman, an advanced ping program.
Pingの発展形であるdeadmanについて紹介します。

https://github.com/upa/deadman

deadman is a tool that monitors the heartbeat of network devices and is coded in Python.
Unlike the Ping command, it can send ICMP Echo Requests to multiple devices. It is useful for when you need to monitor multiple servers and devices.
deadmanはPingでネットワークの死活監視を行うPython製ツールです。  
Pingコマンドとの違いは複数の宛先にICMP Echo Requestを送信することができる点です。複数のサーバやネットワーク機器を監視する必要がある場合に便利なツールです。

deadman sends an ICMP Echo Request to each device and polls its Reply in sequence.
deadmanはそれぞれの宛先に対し順繰りにICMP Echo Requestを送りポーリングを行っています。

```
          |----------------------------------------------------------------------------------------------> T
target A:  S(polling...)R                                                  S(polling...)R
target B:                S(polling..........)T                                           S(polling.......
target C:                                     S(polling...)R
```

You can create a deadman with Swift if you implement the same flow. Swift can use ncurses, which is an interface adopted by deadman. Of course Swift has SwiftUI for creating views.
同じ処理を実装すればSwift製のdeadmanを作ることができます。deadmanがインターフェースとして採用しているncursesもSwiftから使用可能ですし、もちろんSwiftUIでインターフェースを作ることもできます。

It is enough to implemented the logic to send Requests sequentially, but let's try sending ICMP Echo Requests to multiple devices at once.
順繰りにICMP Echo Requestを送信するしくみでも監視ツールとしては十分ですが、せっかくなので複数の宛先に一斉にICMP Echo Requestを送ることを考えてみましょう。

Your program may receive ICMP Echo Replies at the same time.
一斉にICMP Echo Requestを送ると複数の宛先から一斉にICMP Echo Replyが返ってくる可能性があります。

```
          0                    1                    2
          |--------------------|--------------------|------------> T
target A:  S(polling...)R       S(polling...)R       S(polling...
target B:  S(polling..........)TS(polling..........)TS(polling...
target C:  S(polling.....)R     S(polling.....)R     S(polling...
```

As I said, a single datagram socket should poll all ICMP Echo Replies. Fortunately, you can use the message data to determine which device sent the Replies. Implement some logic to sort them by source host.
先に述べたように、ひとつのデータグラムソケットで全てのICMP Echo Replyをポーリングし受け取る必要があります。幸いにも返ってきたメッセージデータを読むことで送信元のサーバを特定できますのでプログラム側で分類する処理を行えば問題ありません。
