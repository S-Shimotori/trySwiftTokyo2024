/// # Chapter 7. ICMP + Socket
///
/// 本章では実際にデータグラムソケットを用いてICMP Echo Requestを送信し、別のデータグラムソケットでICMP Echo Replyを受信します。

import Foundation

/// ソケットを2つ用意します。 `socketA` からICMP Echo Requestを送信し `socketB` でICMP Echo Replyを受信します。
/// ソケットによるICMP Echo Replyの分類や区別が不可能だとすると `socketA` から送信しても `socketB` で問題なく受信できるはずです。

let socketA = socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)
let socketB = socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)

/// 同じパラメータを与えましたが異なるファイルディスクリプタが得られるはずです。
/// `socketA` と `socketB` は別のソケットです。

assert(socketA != socketB)

/// 今回は自分宛にPingを送信します。127.0.0.1宛の `sockaddr_in` オブジェクトを作成します。

let destinationAddress = sockaddr_in(
    sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size),
    sin_family: sa_family_t(AF_INET),
    sin_port: 0,
    sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")),
    sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
)

/// identifier = 4, sequence number = 5でICMP Echo Requestメッセージを作成します。

let message = ICMPEchoRequest(identifier: 4, sequenceNumber: 5).rawData

/// `destinationAddress` 宛に `message` を送信します。

let sizeOfSentData = message.withUnsafeBytes { rawBufferPointerToMessage in
    withUnsafePointer(to: destinationAddress) { pointerToDestinationAddress in
        pointerToDestinationAddress.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointerToAddress in
            sendto(
                socketA,
                rawBufferPointerToMessage.baseAddress,
                message.count,
                0,
                pointerToAddress,
                socklen_t(destinationAddress.sin_len)
            )
        }
    }
}

/// `sendto(::::::)` の戻り値は送信バイト数です。 `sizeOfSentData` にも送信バイト数が入ります。

assert(sizeOfSentData == message.count)

/// 対のICMP Echo Replyを受信します。 `socketA` ではなく `socketB` を使い受信メッセージを読めるようになるまで待ちます。

var pollfds = [pollfd(fd: socketB, events: Int16(POLLIN), revents: 0)]
while true {
    let result = poll(&pollfds, 1, 1)
    guard result != -1 else { continue }
    guard result != 0 else {
        fatalError()
        break
    }
    guard Int32(pollfds[0].revents) & POLLIN == POLLIN else {
        fatalError()
        break
    }
    break
}

/// データを読めるようになったので `recvfrom` 関数で読み取ります。

let sizeOfBufferData = Int(BUFSIZ)
var bufferData = Data(Array(repeating: UInt8(0), count: sizeOfBufferData))
var sizeOfSockaddrIn = socklen_t(MemoryLayout<sockaddr_in>.size)
var sockaddrIn = sockaddr_in()

let siseOfReceivedData = withUnsafeMutablePointer(to: &sockaddrIn) { unsafeSockaddrIn in
    unsafeSockaddrIn.withMemoryRebound(
        to: sockaddr.self,
        capacity: 1
    ) { unsafeSockaddr in
        bufferData.withUnsafeMutableBytes { bufferDataPointer in
            recvfrom(
                socketB,
                bufferDataPointer.baseAddress,
                sizeOfBufferData,
                0,
                unsafeSockaddr,
                &sizeOfSockaddrIn
            )
        }
    }
}

/// `recvfrom(::::::)` の戻り値は受信したデータのバイト数です。

assert(siseOfReceivedData > 0)

/// `bufferData` 内のメッセージをデコードしidentifier = 4, sequence number = 5のICMP Echo Replyであることを確認します。

/// 受信したデータの先頭にはIPv4ヘッダがついています。
/// まずIPv4ヘッダをデコードしてIPv4ヘッダのバイト長を読み取ります。

guard let ipv4Header = IPv4Header(Data(bufferData[0 ..< MemoryLayout<IPv4Header>.size])) else {
    fatalError()
}

let sizeOfIPv4Header = ipv4Header.ihl * 4
let sizeOfICMPHeader = MemoryLayout<ICMPEchoHeader>.size

/// IPv4ヘッダから先のデータを見てみましょう。
let receivedICMPEchoHeader = ICMPEchoHeader(bufferData[sizeOfIPv4Header ..< sizeOfIPv4Header + sizeOfICMPHeader])

/// 次の値が得られるはずです：
///
/// - type = `00000000` = `ICMP_ECHOREPLY`
/// - identifier = `00000000 00000100` = 4
/// - sequence number = `00000000 00000101` = 5
///
/// ネットワークバイトオーダつまりビッグエンディアンで格納されていることを踏まえて値を確認します。

assert(receivedICMPEchoHeader?.type.rawValue == UInt8(ICMP_ECHOREPLY))
assert(receivedICMPEchoHeader?.identifier == 4)
assert(receivedICMPEchoHeader?.sequenceNumber == 5)

/// `socketA` から送ったICMP Echo Requestの返信を `socketB` で受信できました。

close(socketA)
close(socketB)

/// 実際のPingプログラムでデータグラムソケットを複数持つ必要はなく、ひとつのソケットで全ICMP Echo Replyを受信すればよいです。
/// Swiftプログラム上で送信元ホストごとにICMP Echo Replyを取りまとめてPing結果をインターフェースに出力することになります。
