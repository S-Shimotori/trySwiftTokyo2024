/// # Chapter 4. ~Copyable

import Foundation

/// A file descriptor makes us think of `~Copyable`. Let's study `~Copyable` together.
/// ファイルディスクリプタといえば `~Copyable` です。Swift Evolutionの `~Copyable` を見てみましょう。
/// https://github.com/apple/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md
///
/// Swift Evolution takes a file descriptor as an example of `~Copyable`.
/// `~Copyable` の例にファイルディスクリプタが採用されています。

/// In a program, a file descriptor is represented as an `Int32` value.
/// ファイルディスクリプタはプログラムの上では `Int32` 型の値で表されます。

let rawFileDescriptor: Int32 = socket(PF_INET, SOCK_DGRAM, 0)

/// You are capable of handling opened sockets and files. Do not access them after closing.
/// However, a program can't determine whether a file descriptor is open or closed because its type is just `Int32`.
/// Sockets may be accessed accidentally without understanding their status.
/// ソケットやファイルはオープンの時のみ操作が可能です。クローズした後はソケットやファイルに対する操作ができません。
/// しかしソースコート上では記述子という番号で表されるためソケットの現在の状態がわかりません。
/// そのため現在の状態をよく把握しないまま不適切な操作をしてしまう恐れがあります。

func handle(fd: Int32) {
    // do something

    close(fd)
}
handle(fd: rawFileDescriptor)

// Close again without realizing handle(fd:) already closed
close(rawFileDescriptor)
assert(errno == EBADF /* Bad file descriptor */)

/// Instead of managing `Int32` values as they are, it is safer if you have an object to get a grasp of a status of a file descriptor and close it at the appropriate time.
/// `~Copyable` can help you to create such an object.
/// `Int32` 型の値をそのまま扱うのではなく、ファイルディスクリプタの状態を表現・管理しつつ適切なタイミングで後始末する仕組みがあると安全です。
/// そのようなケースでは `~Copyable` が便利です。 `~Copyable` により次に示す実装が可能です。
///
/// - Whether the object is consumed or not determines if a file descriptor is opened or closed. /  すでに消費したかしていないかでファイルディスクリプタがオープン状態かクローズ状態かを表現する。
/// - Swift Compiler can detect that you use a consumed (closed) file descriptor by mistake. / 消費済み、すなわちクローズ済みのファイルディスクリプタを操作してしまう実装をコンパイルの段階で発見できる。
/// - You can close a file descriptor properly using `deinit`.  / `deinit` と併用することで適切なタイミングで忘れずにソケットをクローズできる。
/// - `~Copyable` ensures there is only one reference to a file descriptor and it prevents from unintended operations. / ファイルディスクリプタへの参照が1つに制限されるので想定しない操作を防ぐことができる。

/// Swift Evolution provides an example of `~Copyable` structure that can be closed explicitly while `deinit` can close it automatically.
/// You can obtain result of a close operation when you call the `consuming` method to close a file descriptor.
/// Swift Evolutionでは手動でクローズすることも `deinit` で自動的にクローズすることもできる実装が紹介されています。
/// 手動でクローズする場合にはクローズに成功したかどうかも確認できるようになっています。

/// Information about an error condition from C Standard Library functions.
struct LibCError: Error {
    let errno: Int32

    init(_ errno: Int32) {
        self.errno = errno
    }
}

struct FileDescriptor: ~Copyable {
    private let fd: Int32

    init(fd: Int32) {
        self.fd = fd
    }

    deinit {
        // discard result because `deinit` cannot throw an error
        _ = Darwin.close(fd)
    }

    func send(message: String) {
        // send message with socket
    }

    consuming func close() throws {
        let fd = fd
        discard self

        if Darwin.close(fd) != 0 {
            throw LibCError(errno)
        }
    }
}

/// When you explicitly close a file descriptor, `deinit` will close it when an object is destroyed.
/// 手動でクローズしなかった場合はオブジェクトが破棄される際に `deinit` がクローズします。

do {
    let fileDescriptor = FileDescriptor(fd: socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP))
}

/// When `close()` is called, `deinit` won't be executed because of `discard self` to avoid double closing.
/// The `consuming` method also prevents accidental handling of a file descriptor.
/// 手動でクローズした際は `discard self` が `deinit` による二重のクローズ操作を阻止します。
/// `consuming` のおかげでクローズ後に誤ってソケットを操作することもありません。

do {
    let fileDescriptor = FileDescriptor(fd: socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP))

    // You can send a message because the `fileDescriptor` has not been closed yet.
    fileDescriptor.send(message: "Hello")

    try fileDescriptor.close()

    // You cannot send any more because the `close` method consumed `fileDescriptor`.

    // 'fileDescriptor' used after consume
//    fileDescriptor.send(message: "Hello")

    // 'fileDescriptor' consumed more than once
//    try fileDescriptor.close()
}
