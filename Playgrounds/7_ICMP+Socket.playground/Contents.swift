/// # Chapter 7. ICMP + Socket
///
/// This chapter confirms that a datagram socket can receive an ICMP Echo Reply that is a response to a Request sent by another socket.
/// 本章では実際にデータグラムソケットを用いてICMP Echo Requestを送信し、別のデータグラムソケットでICMP Echo Replyを受信します。

import Foundation

/// Here are two file descriptors that refer datagram sockets, `fileDescriptorA` and `fileDescriptorB`.
/// The socket pointed to by `fileDescriptorA` will send an ICMP Echo Request and another socket will receive its Reply.
/// `fileDescriptorB` must be able to retrieve the reply if a datagram socket can retrieve all Replies, regardless of which socket sends and source hosts.
/// データグラムソケットを指すファイルディスクリプタ `fileDescriptorA` と `fileDescriptorB` を用意します。
/// `fileDescriptorA` を使ってICMP Echo Requestを送信し `fileDescriptorB` でICMP Echo Replyを受信します。
/// もし `fileDescriptorB` で受信に成功したら、データグラムソケットはICMP Echo Requestの送信に使ったソケットや送信元ホストに関わらずReplyを受け取れるといえます。

let fileDescriptorA = socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)
let fileDescriptorB = socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)

/// Although we passed the same parameters to the system call, it returned different values.
/// 同じパラメータを与えましたが異なる値のファイルディスクリプタが得られるはずです。

assert(fileDescriptorA != fileDescriptorB)

/// Let's send an ICMP Echo Request to your computer. `destinationAddress` is an instance of `sockaddr_in` that represents 127.0.0.1.
/// 今回は自分宛にICMP Echo Requestを送信します。127.0.0.1宛の `sockaddr_in` オブジェクトを作成します。

let destinationAddress = sockaddr_in(
    sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size),
    sin_family: sa_family_t(AF_INET),
    sin_port: 0,
    sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")),
    sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
)

/// This is an ICMP Echo Request data whose identifier is 4 and sequence number is 5.
/// identifier = 4, sequence number = 5でICMP Echo Requestメッセージを作成します。

let message = ICMPEchoRequest(identifier: 4, sequenceNumber: 5).rawData

/// Sends `message` to `destinationAddress`.
/// `destinationAddress` 宛に `message` を送信します。

let sizeOfSentData = message.withUnsafeBytes { rawBufferPointerToMessage in
    withUnsafePointer(to: destinationAddress) { pointerToDestinationAddress in
        pointerToDestinationAddress.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointerToAddress in
            sendto(
                fileDescriptorA,
                rawBufferPointerToMessage.baseAddress,
                message.count,
                0,
                pointerToAddress,
                socklen_t(destinationAddress.sin_len)
            )
        }
    }
}

/// The return value of `sendto(::::::)` function equals how long the sent message is. `sizeOfSentData` has the size in bytes.
/// `sendto(::::::)` の戻り値は送信バイト数です。 `sizeOfSentData` にも送信バイト数が入ります。

assert(sizeOfSentData == message.count)

/// Next, receive an ICMP Echo Reply. We will wait until we can read its message data using `fileDescriptorB`, not `fileDescriptorA`.
/// 対のICMP Echo Replyを受信します。 `fileDescriptorA` ではなく `fileDescriptorB` を使い受信メッセージを読めるようになるまで待ちます。

var pollfds = [pollfd(fd: fileDescriptorB, events: Int16(POLLIN), revents: 0)]
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

/// Now, we can read a received message with `recvfrom` function.
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
                fileDescriptorB,
                bufferDataPointer.baseAddress,
                sizeOfBufferData,
                0,
                unsafeSockaddr,
                &sizeOfSockaddrIn
            )
        }
    }
}

/// `recvfrom(::::::)` returns the size of the received data in bytes.
/// `recvfrom(::::::)` の戻り値は受信したデータのバイト数です。

assert(siseOfReceivedData > 0)

/// Let's decode `bufferData` to check that it is an ICMP Echo Reply with identifier = 4 and sequence number  = 5.
/// `bufferData` 内のメッセージをデコードしidentifier = 4, sequence number = 5のICMP Echo Replyであることを確認します。

/// `bufferData` contains an IPv4 header as a prefix of message. How long the header is?
/// 受信したデータの先頭にはIPv4ヘッダがついています。
/// まずIPv4ヘッダをデコードしてIPv4ヘッダのバイト長を読み取ります。

guard let ipv4Header = IPv4Header(Data(bufferData[0 ..< MemoryLayout<IPv4Header>.size])) else {
    fatalError()
}

let sizeOfIPv4Header = ipv4Header.ihl * 4
let sizeOfICMPHeader = MemoryLayout<ICMPEchoHeader>.size

/// We need to read data that is located behind the IPv4 header.
/// IPv4ヘッダから先のデータを見てみましょう。
let receivedICMPEchoHeader = ICMPEchoHeader(bufferData[sizeOfIPv4Header ..< sizeOfIPv4Header + sizeOfICMPHeader])

/// `receivedICMPEchoHeader` should contain these parameters:
/// 次の値が得られるはずです：
///
/// - type = `00000000` = `ICMP_ECHOREPLY`
/// - identifier = `00000000 00000100` = 4
/// - sequence number = `00000000 00000101` = 5
///
/// It is important to note that they are in big-endian order.
/// ネットワークバイトオーダつまりビッグエンディアンで格納されていることを踏まえて値を確認します。

assert(receivedICMPEchoHeader?.type.rawValue == UInt8(ICMP_ECHOREPLY))
assert(receivedICMPEchoHeader?.identifier == 4)
assert(receivedICMPEchoHeader?.sequenceNumber == 5)

/// Congratulations! We have received an ICMP Echo Request using `fileDescriptorB`, despite `fileDescriptorA` sent its request.
/// `socketA` から送ったICMP Echo Requestの返信を `socketB` で受信できました。

close(fileDescriptorA)
close(fileDescriptorB)

/// When implementing a Ping program, there is no need to create multiple datagram sockets.
/// Only one datagram socket is required to send and receive ICMP Echoes.
/// Separate ICMP Echo Replies by target hosts using Swift and display the results of Ping on views.
/// 実際のPingプログラムでデータグラムソケットを複数持つ必要はなく、ひとつのソケットで全ICMP Echo RequestとReplyを送受信すればよいです。
/// Swiftプログラム上で送信元ホストごとにICMP Echo Replyを取りまとめてPing結果をインターフェースに出力することになります。
