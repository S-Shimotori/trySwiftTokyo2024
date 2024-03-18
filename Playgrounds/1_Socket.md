# Chapter 1. Socket

Inter-process communication, or IPC, allows a process to collaborate with others. 
Multiple processes access shared resources and exchange data correctly using IPC. An Internet domain socket is an IPC that allows you to communicate with other processes on another host in the same TCP/IP network.
プロセスは他のプロセスと協調して動作することがあります。このとき必要になるのがプロセス間通信（IPC：InterProcess Communication）のしくみです。  
IPCのおかげで複数のプロセスが適切に共有資源へアクセスしたり互いにデータをやりとりしたりすることができます。IPCのうちTCP/IPネットワーク上の他のホストのプロセスと通信できるものとしてインターネットドメインソケットがあります。

Consider communicating with a server on the same network using an Internet domain socket. You need to create a socket, and close it when the communication is complete. This is similar to opening and closing a file for reading and writing.
インターネットドメインソケットを用いてネットワーク上のサーバと通信をすることを考えます。ソケットを利用するにはまずソケットを作成し利用が終わったらクローズします。これは私たちが普段ファイルの読み書きをする前後でファイルを開いたり閉じたりするのに似ています。

You get a file descriptor when you create a socket. A file descriptor is a positive value that specifies a target file. UNIX has the philosophy that "Everything is a file", so sockets are also managed using file descriptors.
ソケットの作成に成功するとファイルディスクリプタ（記述子）を得ます。ファイルディスクリプタは正数の値で対象のファイルを特定するものです。UNIXにはEverything is a fileという思想があるのでソケットもファイルディスクリプタを使って管理しています。

Functions that handle sockets have an argument that takes a file descriptor. Send functions send a message using a socket specified by a given file descriptor. The close function closes a socket specified by a given file descriptor.
ソケットの操作を行う関数にはファイルディスクリプタを受け取る引数があります。メッセージを送信する関数はファイルディスクリプタが指すソケットで送信します。ソケットをクローズする関数はファイルディスクリプタが指すソケットをクローズします。

There are several types of Internet domain sockets. Each is designed to work and used in a different way.
インターネットドメインソケットには種類がいくつかあります。それぞれ用途や使い方が異なります。

- Stream socket / ストリームソケット
- Datagram socket / データグラムソケット
- (Raw socket / rawソケット)

For reliability, use a stream socket that uses TCP communication. For speed, use a datagram socket that uses UDP communication.
信頼性を重視するならTCP通信を行うストリームソケットを、速度を重視するならUDP通信を行うデータグラムソケットを利用します。

This time, let me focus on Ping to try socket communication. These are its reasons:
今回はソケット通信を試すためにPingを題材として取り上げます。理由は次のとおりです。

- ICMP Echo Requests and Replies, which are messages exchanged by Ping, are so simple message that it is easy to prepare their data and exchange. / Pingが送受信するICMP Echo Request・Echo Replyはとても短く単純なメッセージなのでデータの準備も送受信も簡単である
- You can easily implement it using a datagram socket because Ping doesn't require a TCP connection. /  コネクション確立が不要なのでデータグラムソケットで実現でき実装が簡単である
- You can communicate with existing hosts, such as other computers, servers and network devices. / 既存のホスト（コンピュータ・サーバ・ネットワーク機器など）を通信相手にすることができる
- A ping tool is handy. / 実用性がある

The next chapter introduces the Ping command.
次章ではPingコマンドについて紹介します。
