# Chapter 5. Message

In this chapter, we will consider how to generate ICMP Echo Request data.
本章ではICMP Echo Requestの作成方法について検討します。

Ping sends a message known as ICMP Echo Request. We need to assign a value to each parameter as usual.
Additionally, we must prepare a message as binary string according to its format. Here is an example of such a binary string:
PingではICMP Echo Requestというメッセージを送信します。各パラメータごとの値を決めて送信する、という点では私たちが普段行っている通信と変わりません。  
しかしICMP Echo Requestをソケット通信で送るにはフォーマット通りにバイナリ列を用意しなければなりません。例えば以下のようなバイナリ列が必要です：

```
0000100000000000(16bit checksum)00000000000000000000000000000000......
```

To achieve the goal, follow these steps:
このようなバイナリ列を作成するには以下の2つの知識が必要です：

- What the ICMP Echo Request format is / ICMP Echo Requestのフォーマットはどのようなものか
- How to prepare such binary string using Swift / Swiftでバイナリ列をどのように用意するか

## What the ICMP Echo Request format is / ICMP Echo Requestのフォーマットはどのようなものか

You can find the following image when you search "ICMP Echo Request format".
It consists of some rows and has a 32-bit scale.
「ICMP Echo Request format」などで検索すると次のような画像が見つかります。  
いくつかの段があって幅32の目盛りがついています。

```
0    4   8   12  16  20  24  28  32
|    |   |   |   |   |   |   |   |
[  type  | code  |   checksum    ]
[   identifier   |sequence number]
```

This image describes the proper placement of parameters in a binary string.
If we let `data` be the binary sequence and `data[n]` be `n`th bit, the following formula is valid.
これはバイナリ列の何bit目になんの設定値を置くかを表しています。バイナリ列を `data` 、 `n` bit目を `data[n]` とすると以下の関係がなりたちます。

`data[n] = the (n%32)th bit in the (n/32)th row`
`data[n] = (n/32)段目の(n%32)bit目`

This is the binary string in the beginning of this chapter split by parameter.
冒頭のバイナリ列をパラメータごとに区切ってみます：

`00001000, 00000000, (16bit checksum), 0000000000000000, 0000000000000000`

Its parameter values are as follows. (I will omit what value we should assign to each parameter.)
冒頭のバイナリ列では各パラメータに次の値が設定されていることがわかります。（各パラメータにどんな値を設定するべきかはここでは省略します）

|  parameter   | value |
|     ---      |  ---  |
| type         |     8 |
| code         |     0 |
| checksum     |(16bit)|
| identifier   |     0 |
| sequence no. |     0 |

## How to prepare such binary string using Swift / Swiftでバイナリ列をどのように用意するか

How can we write a binary string of ICMP Echo Request using Swift?
Swift's structure helps us to generate it. Retrieve memory data of a defined structure below and send it as an ICMP Echo Request message.
冒頭で示したようなバイナリ列を手書きするのは大変です。何かいい方法はないでしょうか？  
ここで構造体を使用します。次のような構造体を作ってメモリ上の値を読み出してICMP Echo Requestとして送信します。

```swift
struct ICMPEchoRequest {
    let type: UInt8
    let code: UInt8
    let checksum: UInt16
    let identifier: UInt16
    let sequenceNumber: UInt16
}
```

Structure is also useful for decoding IP header and ICMP Echo Reply. Please note the following points:
構造体はICMP Echo Requestの作成のほかIPヘッダとICMP Echo Replyのデコードにも使えます。  
ただし以下の点に注意する必要があります。

- The network byte order is in big endian. / ネットワークバイトオーダはビッグエンディアン
- The length of some IPv4 header parameters does not match the bit width of any `UInt`. / IPv4ヘッダのパラメータの一部はSwiftのどの `UInt` ともbit桁数が一致しない

Specifically, you should do these tasks:
具体的には

- Assign values to properties in big endian order. / ビッグエンディアンの状態でプロパティに値を渡す
- Note that property values are in big endian order when you retrieve them from a received byte string. / 受信したバイナリ列からデータを読み出すときはそのバイナリ列がビッグエンディアンであることを踏まえて読む
- Assign multiple values to a single `UInt` parameter if need. / 必要であれば複数のパラメータの値をひとつの `UInt` 型プロパティで扱う

といった処理が必要です。
