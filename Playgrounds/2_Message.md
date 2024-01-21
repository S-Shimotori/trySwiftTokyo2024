# Chapter 2. Message

本章ではICMP Echo Requestの作成方法について検討します。

PingではICMP Echo Requestというメッセージを送信します。各パラメータごとの値を決めて送信する、という点では私たちが普段行っている通信と変わりません。
しかしICMP Echo Requestをソケット通信で送るにはフォーマット通りにバイナリ列を用意しなければなりません。例えば以下のようなバイナリ列が必要です：

```
0000100000000000(16bit checksum)00000000000000000000000000000000......
```

このようなバイナリ列を作成するには以下の2つの知識が必要です：

- ICMP Echo Requestのフォーマットはどのようなものか
- Swiftでバイナリ列をどのように用意するか

## ICMP Echo Requestのフォーマットはどのようなものか

「ICMP Echo Request format」などで検索すると次のような画像が見つかります。
いくつかの段があって幅32の目盛りがついています。

```
0    4   8   12  16  20  24  28  32
|    |   |   |   |   |   |   |   |
[  type  | code  |   checksum    ]
[   identifier   |sequence number]
```

これはバイナリ列の何bit目になんの設定値を置くかを表しています。バイナリ列を `data` 、 `n` bit目を `data[n]` とすると以下の関係がなりたちます。

`data[n] = (n/32)段目の(n%32)bit目`

冒頭のバイナリ列をパラメータごとに区切ってみます：

`00001000, 00000000, (16bit checksum), 0000000000000000, 0000000000000000]`

冒頭のバイナリ列では各パラメータに次の値が設定されていることがわかります。（各パラメータにどんな値を設定するべきかはここでは省略します）

|  parameter   | value |
|     ---      |  ---  |
| type         |     8 |
| code         |     0 |
| checksum     |(16bit)|
| identifier   |     0 |
| sequence no. |     0 |

## Swiftでバイナリ列をどのように用意するか

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

この方法はICMP Echo Requestの作成のほかIPv4ヘッダの作成やICMP Echo Responseのデコードにも使えます。
ただし以下の点に注意する必要があります。

- ネットワークバイトオーダはビッグエンディアンだが構造体の各 `UInt` 型プロパティはリトルエンディアンがデフォルト
- IPv4ヘッダのパラメータの一部はSwiftの `UInt` ファミリーとbit桁数が異なる

具体的には

- ビッグエンディアンの状態でプロパティに値を渡す
- 受信したバイナリ列を `UInt` 型オブジェクトにデコードするときはそのバイナリ列がビッグエンディアンであることを踏まえてデコードする
- 必要であれば複数のパラメータの値をひとつの `UInt` 型プロパティで扱う
  - パラメータの値を読みたいときは各パラメータに分けて読む
  - パラメータの値を渡したいときは結合させたものを渡す

といった処理が必要です。