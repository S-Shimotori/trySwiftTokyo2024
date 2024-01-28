# Chapter 2. Ping

自分のパソコンが特定のサーバやネットワーク機器にアクセスできるかどうか調べる方法のひとつにPingコマンドがあります。

本章ではPingを実装するためにPingの紹介を行い、さらにソケット通信を用いたPingプログラムの実装方法について検討します。

## そもそもPingとは何か

`man ping` には次の説明があります。

> ping – send ICMP ECHO_REQUEST packets to network hosts

私たちはしばしば「pingを送信する」と言いますが、PingコマンドはICMP Echo Requestというメッセージを複数回送信するプログラムです。
pingの出力には `icmp_seq=n` という項目があります。これは `n` 回目に送ったICMP Echo Requestであることを表しています。

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

デフォルト設定のままであればpingは次の処理を繰り返し行います。

1. 指定のアドレスにICMO Echo Requestを1つ送る
2. 1秒待つ
  - 1秒経過する前にICMP Echo Replyを受信したら成功。
  - 1秒経過しても受信できなかったらタイムアウト。
3. 次のICMO Echo Requestを送る

0                    1                    2
|--------------------|--------------------|----------> T
 S(wait...)R          S(wait.............)TS(wait...

S: ICMP Echo Requestの送信
R: ICMP Echo Replyの受信
T: タイムアウト

"64 bytes from ..."という一行の出力を得るためにICMP Echo RequestおよびICMP Echo Replyの送受信が一往復行われています。
もし制限時間までにICMP Echo Replyが返ってこなければPingはタイムアウトのメッセージを表示します。

```
Request timeout for icmp_seq 0
Request timeout for icmp_seq 1
```

## ソケット通信によるICMP Echo Requestの送信とICMP Echo Replyの受信

ソケット通信ならICMP Echo Requestを送りICMP Echo Replyを受信することができます。

-----------------------> T
 S(wait...)R

データグラムソケットをオープンしたのち次の手順で一往復ぶんの処理を行います。

1. `sendto` 関数でICMP Echo Requestを送信する。
2. `poll` 関数でICMP Echo Replyの到着を待つ。
3. `recvfrom` 関数で到着したICMP Echo Replyを読む。

Pingのように複数回送信を行うなら一連の処理を繰り返せばよいです。

3章でSwiftからPOSIX関数を利用する方法を紹介します。

### ファイルディスクリプタの取り扱い

ファイルディスクリプタはCプログラムでは `Int` 型、Swiftプログラムでは `Int32` 型の値で表されます。 `Int32` 型の値をそのまま扱ってもPingプログラムを完成させることができますが `~Copyable` である構造体でラップすると安全に扱うことができます。
4章でファイルディスクリプタおよび `~Copyable` について紹介します。

### ICMP Echo Requestメッセージデータの作成とICMP Echo Replyメッセージデータのデコード

ソケットはバイナリデータを送受信します。送信するICMP Echo Requestはバイナリデータのかたちで用意しなければなりません。ICMP Echo Requestのフォーマットは単純なので構造体を利用することで簡単に用意することができます。受信したICMP Echo Replyのバイナリデータも構造体を利用してデコードすることが可能です。
5章でICMP Echo Requestのフォーマットについて紹介し、6章で構造体の利用方法を紹介します。

### エラー処理

ソケットを操作する関数は何らかの理由で失敗することがあり、その場合エラーを表す値を返却します。制限時間までにICMP Echo Replyを受け取れずタイムアウトしたときのことも想定しなくてはいけません。必要に応じて次の処理を実装するようにします。

- 関数がエラーの発生を示す値を返したり `errno` がエラーを指したりしていないか逐一確認する
- 制限時間内にサーバから応答がなければ何らかの障害があったとみなしてタイムアウト扱いにする

#### タイムアウトの判定

タイムアウトの判定はどのように行えばよいでしょうか。

最も簡単な実装は `poll` 関数の引数 `timeout` を利用することです。例えば `poll` 関数で最大1秒のポーリングを行い、その間に応答メッセージが読み込み可能にならず戻り値 `0` を得たらタイムアウトとします。

0                    1
|--------------------|----------> T
 S(polling..........)T

この方法は1往復しかメッセージを送らない場合や次のメッセージの処理を始める前にタイムアウト判定を完了するケースで有効です。
n回目のポーリング処理とn+1回目のポーリング処理を同時に行う可能性がある場合、具体的にはタイムアウトまでの猶予が長い場合などには向きません。

0                    1                    2
|--------------------|--------------------|----------> T
 S(polling...............................)T
                      S(polling......)R
                                           S(polling...

そういったケースを考慮すると次の2つの手法が浮かびます。

- 一往復ごとに異なるソケットを使用し、それぞれについて時間制限ありのポーリングを行う。
- ICMP Echo Requestを送信するたびに自分でタイマーをセットする。

一見すると1つ目の手法が簡単に思えます。しかしこの方法はうまくいきません。データグラムソケットは自プロセス宛のUDP通信メッセージなら全て受信できてしまうためソケットを複数用意しても意味がないからです。
そこで、1つのソケットが全てのポーリング処理を担い、タイムアウトはプログラム側で判定することにします。この方法であればタイムアウトまでの猶予を長く持つなどして同時に複数のICMP Echoをやりとりしても問題ありません。

## deadmanについて

Pingの発展形であるdeadmanについて紹介します。

https://github.com/upa/deadman

deadmanはPingでネットワークの死活監視を行うPython製ツールです。
Pingコマンドとの違いは複数の宛先にICMP Echo Requestを送信することができる点です。複数のサーバやネットワーク機器を監視する必要がある場合に便利なツールです。

deadmanはそれぞれの宛先に対し順繰りにICMP Echo Requestを送りポーリングを行っています。

          |----------------------------------------------------------------------------------------------> T
target A:  S(polling...)R                                                  S(polling...)R
target B:                S(polling..........)T                                           S(polling.......
target C:                                     S(polling...)R

同じ処理を実装すればSwift製のdeadmanを作ることができます。deadmanがインターフェースとして採用しているncursesもSwiftから使用可能ですし、もちろんSwiftUIでインターフェースを作ることもできます。

deadmanは順番に1つずつICMP Echo Requestを送っています。順繰りにICMP Echo Requestを送信するしくみでも監視ツールとしては十分ですが、せっかくなので複数の宛先に一斉にICMP Echo Requestを送ることを考えてみましょう。

一斉にICMP Echo Requestを送ると複数の宛先から一斉にICMP Echo Replyが返ってくる可能性があります。

          0                    1                    2
          |--------------------|--------------------|------------> T
target A:  S(polling...)R       S(polling...)R       S(polling...
target B:  S(polling..........)TS(polling..........)TS(polling...
target C:  S(polling.....)R     S(polling.....)R     S(polling...

先に述べたように、ひとつのデータグラムソケットで全てのICMP Echo Replyをポーリングし受け取る必要があります。幸いにも返ってきたメッセージデータを読むことで送信元のサーバを特定できますのでプログラム側で分類する処理を行えば問題ありません。
