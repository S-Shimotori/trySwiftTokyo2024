# Chapter 1. Socket

プロセスは他のプロセスと協調して動作することがあります。このとき必要になるのがプロセス間通信（IPC：InterProcess Communication）のしくみです。  
IPCのおかげで複数のプロセスが適切に共有資源へアクセスしたり互いにデータをやりとりしたりすることができます。IPCのうちTCP/IPネットワーク上の他のホストのプロセスと通信できるものとしてインターネットドメインソケットがあります。

インターネットドメインソケットを用いてネットワーク上のサーバと通信をすることを考えます。ソケットを利用するにはまずソケットを作成し利用が終わったらクローズします。これは私たちが普段ファイルの読み書きをする前後でファイルを開いたり閉じたりするのに似ています。

ソケットの作成に成功するとファイルディスクリプタ（記述子）を得ます。ファイルディスクリプタは正数の値で対象のファイルを特定するものです。UNIXにはEverything is a fileという思想があるのでソケットもファイルディスクリプタを使って管理しています。

ソケットの操作を行う関数にはファイルディスクリプタを受け取る引数があります。メッセージを送信する関数はファイルディスクリプタが指すソケットで送信します。ソケットをクローズする関数はファイルディスクリプタが指すソケットをクローズします。

インターネットドメインソケットには種類がいくつかあります。それぞれ用途や使い方が異なります。

- ストリームソケット
- データグラムソケット
- （rawソケット）

信頼性を重視するならTCP通信を行うストリームソケットを、速度を重視するならUDP通信を行うデータグラムソケットを利用します。

今回はソケット通信を試すためにPingを題材として取り上げます。理由は次のとおりです。

- Pingが送受信するICMP Echo Request・Echo Replyはとても短く単純なメッセージなのでデータの準備も送受信も簡単である
- コネクション確立が不要なのでデータグラムソケットで実現でき実装が簡単である
- 既存のホスト（コンピュータ・サーバ・ネットワーク機器など）を通信相手にすることができる
- 実用性がある

次章ではPingコマンドについて紹介します。