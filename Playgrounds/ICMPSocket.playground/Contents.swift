import Foundation

/// 本Playgroundでは、ソケットでICMP Echoメッセージを区別することが不可能であることを確認します。

/// ソケットを2つ用意します。 `socketA` からICMP Echo Requestを送信し `socketB` でポーリングを行います。
/// ソケットによるICMP Echoメッセージの区別が不可能だとすると `socketA` から送信し `socketB` で受信できるはずです。

let socketA = socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)
let socketB = socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)

/// 同じパラメータを与えましたが異なるファイルディスクリプタが得られるはずです。

assert(socketA != socketB)

/// 今回は自分宛にPingを送信します。127.0.0.1宛の `sockaddr_in` インスタンスを作成します。

let destinationAddress = sockaddr_in(
    sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size),
    sin_family: sa_family_t(AF_INET),
    sin_port: 0,
    sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")),
    sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
)

/// identifier = 4, sequence number = 5でICMP Echo Requestメッセージを作成します。

let message = ICMPEchoRequest(id: 4, sequence: 5).rawData

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

/// 対のICMP Echo Replyを受信します。 `socketA` ではなく `socketB` が読めるようになるまで待ちます。

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
/// type 8bit, code 8bit, checksum 16bit, identifier 16bit, sequence number 16bitです。

let receivedRawMessage = Array(bufferData[sizeOfIPv4Header ..< sizeOfIPv4Header + sizeOfICMPHeader])
    .map { String($0, radix: 2) }
    .map { String(repeating: "0", count: 8 - $0.count) + $0 }

let type = receivedRawMessage[0]
let identifier = receivedRawMessage[4 ... 5].joined(separator: " ")
let sequenceNumber = receivedRawMessage[6 ... 7].joined(separator: " ")

/// 次の値が得られるはずです：
///
/// - type = `00000000`
/// - identifier = `00000000 00000100`
/// - sequence number = `00000000 00000101`
///
/// ネットワークバイトオーダつまりビッグエンディアンで格納されているのでそのまま読んで10進数に戻します。
///
/// - type = `0` すなわち `ICMP_ECHOREPLY`
/// - identifier = `4`
/// - sequence number = `5`
///
/// となります。
/// `socketA` から送ったICMP Echo Requestの返信を `socketB` で受信できました。

close(socketA)
close(socketB)
