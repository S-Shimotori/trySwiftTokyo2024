/// POSIXソケット通信では次の構造体や関数などを使用します。
///
/// - netinet
///   - in.h
///     - `IPPROTO_ICMP`（定数）
///     - `sendto`（関数）
/// - poll
///   - poll.h
///     - `poll`（関数）
/// - sys
///   - socket.h
///     - `AF_INET`（定数）
///     - `recvfrom`（関数）
///     - `sockaddr`（構造体）

/// macOSやiOSでもこれらを使うことができます。
/// Swiftから利用するには何のモジュールをインポートすればよいでしょうか。
/// システムモジュールでヘッダをインポートしてもよいのですが、 `Darwin.POSIX` をインポートすれば足ります。

import var Darwin.POSIX.netinet.IPPROTO_ICMP
import func Darwin.POSIX.poll.poll
import var Darwin.POSIX.sys.socket.AF_INET

/// FoundationはDarwinをインポートしているので、 `Data` などと合わせて `import Foundation` としてもよいです。

//import func Darwin.POSIX.sys.socket.sendto
import Foundation

/// POSIXの関数を呼ぶことを考えます。ここではソケットでメッセージの送信をする `sendto(::::::)` 関数を例にします。
/// `sendto(::::::)` には6つの引数があります。
///
/// ```
/// sendto(<#T##Int32#>, <#T##UnsafeRawPointer!#>, <#T##Int#>, <#T##Int32#>, <#T##UnsafePointer<sockaddr>!#>, <#T##socklen_t#>)
/// ```
///
/// - `Int32`：ソケットファイルディスクリプタ
/// - `UnsafeRawPointer`：送信したいメッセージへのポインタ
/// - `Int`：上記メッセージのバイト数
/// - `Int32`：フラグ
/// - `UnsafePointer<sockaddr>`：送信先のアドレスへのポインタ
/// - `socklen_t`：上記 `sockaddr` の長さ
///
/// `man sendto` を見ると元のシグネチャがわかります。
///
/// ```
/// sendto(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);
/// ```
///
/// `Int32` や `socklen_t` 型の引数にはその型のインスタンスを渡せばよいです。
/// しかし2番目と5番目にはポインタを渡す必要があります。

/// 2番目の引数に渡すポインタを用意しましょう。
/// メッセージを `Data` 型で用意したなら次の手順で `UnsafeRawPointer` を取得できます。
///
/// 1. `withUnsafeBytes(_:)` で `UnsafeRawBufferPointer` を取得する
/// 2. `baseAddress` で先頭のアドレスを取得する
///
/// 1章で作成した `StructureA` を例に確かめてみましょう。
/// ここでは `sendto(::::::)` を呼ぶ代わりに `StructureA` インスタンスを復元することでアドレスが有効なものであることを確かめます。

struct StructureA {
    let property0: UInt8
}
var structureA = StructureA(property0: 0b11111111)
let data = Data(bytes: &structureA, count: MemoryLayout<StructureA>.size)
let length = data.count

data.withUnsafeBytes { pointerToStructureA in
    let unsafeRawPointer = pointerToStructureA.baseAddress

    // Call `sendto(::::::)` here
    let instance = unsafeRawPointer?.load(as: StructureA.self)
    print("\(String(describing: instance)): from \(String(describing: unsafeRawPointer)) with \(length) bytes")
}

/// 実行すると `StructureA` インスタンスが出力されるはずです。

/// 5番目の引数に渡すポインタを用意しましょう。
/// `sockaddr` とありますが実際には `sockaddr_in` というインターネットアドレスを表す構造体を使用します。

let destinationAddress: sockaddr_in = sockaddr_in(/* configure address here */)

/// この `destinationAddress` を `UnsafePointer<sockaddr>` にして `sendto(::::::)` に渡します。
/// 以下の2つの作業が必要です。
///
/// - `UnsafePointer<_>` 型のポインタを取得する
/// - `sockaddr_in` から `sockaddr` にキャストする

/// `withUnsafePointer(to:_:)` と `withMemoryRebound(to:capacity:_:)` を使ってみます。
/// クロージャの範囲がポインタのライフタイムを表すようになっています。

withUnsafePointer(to: destinationAddress) { pointerToDestinationAddress in
    pointerToDestinationAddress.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointerToAddress in
        // Call `sendto(::::::)` here
        pointerToAddress is UnsafePointer<sockaddr>
    }
}

/// `sendto(::::::)` の求める `UnsafePointer<sockaddr>` が得られたはずです。
