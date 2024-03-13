/// # Chapter 3. POSIX
///
/// This chapter is an overview of the use of POSIX functions.
/// 本章ではPOSIX関数の利用方法を確認します。

/// These are part of POSIX functions to communicate over sockets.
/// POSIXソケット通信では次の構造体や関数などを使用します。
///
/// - netinet
///   - in.h
///     - `IPPROTO_ICMP`（A constant / 定数）
///     - `sendto`（A function / 関数）
/// - poll
///   - poll.h
///     - `poll`（A function / 関数）
/// - sys
///   - socket.h
///     - `AF_INET`（A constant / 定数）
///     - `recvfrom`（A function / 関数）
///     - `sockaddr`（A structure / 構造体）

/// You can use them in macOS and iOS.
/// Import their headers using a system module, or simply import `Darwin.POSIX`.
/// macOSやiOSでもこれらを使うことができます。
/// Swiftから利用するには何のモジュールをインポートすればよいでしょうか。
/// システムモジュールでヘッダをインポートしてもよいのですが、 `Darwin.POSIX` をインポートすれば足ります。

import var Darwin.POSIX.netinet.IPPROTO_ICMP
import func Darwin.POSIX.poll.poll
import var Darwin.POSIX.sys.socket.AF_INET

/// Foundation contains Darwin. I recommend you to import Foundation also for `Data`.
/// FoundationはDarwinをインポートしているので、 `Data` などと合わせて `import Foundation` としてもよいです。

import Foundation

/// I will explain using `sendto(::::::)` as an example of a POSIX function call.
/// This function takes six parameters and sends a message through a socket.
/// POSIXの関数を呼ぶことを考えます。ここではソケットでメッセージの送信をする `sendto(::::::)` 関数を例にします。
/// `sendto(::::::)` には6つの引数があります。
///
/// ```
/// sendto(<#T##Int32#>, <#T##UnsafeRawPointer!#>, <#T##Int#>, <#T##Int32#>, <#T##UnsafePointer<sockaddr>!#>, <#T##socklen_t#>)
/// ```
///
/// - `Int32`：A socket file descriptor / ソケットファイルディスクリプタ
/// - `UnsafeRawPointer`：A pointer to a message you want to send / 送信したいメッセージへのポインタ
/// - `Int`：The byte length of the message / 上記メッセージのバイト数
/// - `Int32`：Flags / フラグ
/// - `UnsafePointer<sockaddr>`：A pointer to a destination address / 送信先のアドレスへのポインタ
/// - `socklen_t`：The length of the address / 上記 `sockaddr` の長さ
///
/// This is the original signature introduced with `man sendto`:
/// `man sendto` を見ると元のシグネチャがわかります。
///
/// ```
/// sendto(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);
/// ```
///
/// Pass an `Int32` value and a `socklen_t` value to arguments.
/// However, the second and the fifth arguments take pointers, not values.
/// `Int32` や `socklen_t` 型の引数にはその型のインスタンスを渡せばよいです。
/// しかし2番目と5番目にはポインタを渡す必要があります。

/// Let's prepare a pointer for the second argument.
/// You can retrieve an `UnsafeRawPointer` from a `Data` type message by following these steps:
/// 2番目の引数に渡すポインタを用意しましょう。
/// メッセージを `Data` 型で用意したなら次の手順で `UnsafeRawPointer` を取得できます。
///
/// 1. Call `withUnsafeBytes(_:)` to get an `UnsafeRawBufferPointer` / `withUnsafeBytes(_:)` で `UnsafeRawBufferPointer` を取得する
/// 2. Get a base address with `baseAddress` / `baseAddress` で先頭のアドレスを取得する
///
///
/// Let's try it out using the `StructureA` created in Chapter 1 as an example.
/// This time, we will confirm `UnsafeRawPointer` is a valid pointer by restoring a `StructureA` object instead of executing the `sendto(::::::)` system call.
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

/// `print` will display information about the `StructureA` object.
/// 実行すると `StructureA` インスタンスが出力されるはずです。

/// Next, prepare a pointer for the fifth argument.
/// The placeholder in the function shows `sockaddr`, but actually `sendto` needs a `sockaddr_in` representing an internet address.
/// 5番目の引数に渡すポインタを用意しましょう。
/// `sockaddr` とありますが実際には `sockaddr_in` というインターネットアドレスを表す構造体を使用します。

let destinationAddress: sockaddr_in = sockaddr_in(/* configure address here */)

/// Change `destinationAddress` to `UnsafePointer<sockaddr>` and pass it to `sendto(::::::)` by following these steps:
/// この `destinationAddress` を `UnsafePointer<sockaddr>` にして `sendto(::::::)` に渡します。
/// 以下の2つの作業が必要です。
///
/// - Get an `UnsafePointer<_>` pointer / `UnsafePointer<_>` 型のポインタを取得する
/// - Cast from `sockaddr_in` to `sockaddr`  / `sockaddr_in` から `sockaddr` にキャストする

/// Use `withUnsafePointer(to:_:)` and `withMemoryRebound(to:capacity:_:)`.
/// The range of their closures represents lifetime of pointers.
/// `withUnsafePointer(to:_:)` と `withMemoryRebound(to:capacity:_:)` を使ってみます。
/// クロージャの範囲がポインタのライフタイムを表すようになっています。

withUnsafePointer(to: destinationAddress) { pointerToDestinationAddress in
    pointerToDestinationAddress.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointerToAddress in
        // Call `sendto(::::::)` here
        pointerToAddress is UnsafePointer<sockaddr>
    }
}

/// We got an `UnsafePointer<sockaddr>` to pass to `sendto(::::::)`.
/// `sendto(::::::)` の求める `UnsafePointer<sockaddr>` が得られたはずです。

/// Functions for socket communication may fail.
/// ソケット通信で用いる関数は失敗することがあります。
///
/// The `socket` function takes configurations and returns a file descriptor.
/// It returns a value other than `-1` if it succeeds. `errno` should be `0` because there is no error.
/// `socket` 関数はファイルディスクリプタを得るための関数で、用途に応じた設定値を渡します。
/// 作成に成功すれば `-1` 以外の値を得られます。エラーは発生していないので `errno` は `0` を指します。

let validFileDescriptor = socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)
assert(validFileDescriptor != -1 && errno == 0)

/// You will get `-1` if it fails.
/// ソケット作成に失敗すると `-1` が返ります。

let invalidFileDescriptor = socket(PF_INET, SOCK_DGRAM, -1)
print("file descriptor = \(invalidFileDescriptor), errno = \(errno)")

/// The reason is the non-existent protocol in the third argument.
/// `errno` contains `43`, which is `EPROTONOSUPPORT`.
/// 今回失敗した原因は第3引数に存在しないプロトコルを渡したことなので `errno` は `43` すなわち `EPROTONOSUPPORT` を指します。
