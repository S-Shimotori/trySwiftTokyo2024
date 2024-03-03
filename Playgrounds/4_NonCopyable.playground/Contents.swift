/// # Chapter 4. ~Copyable

import Foundation

/// ファイルディスクリプタといえば `~Copyable` です。Swift Evolutionの `~Copyable` を見てみましょう。
/// https://github.com/apple/swift-evolution/blob/main/proposals/0390-noncopyable-structs-and-enums.md
/// `~Copyable` の例にファイルディスクリプタが採用されています。

/// ファイルディスクリプタはプログラムの上では `Int` 型の値で表されます。

let rawFileDescriptor: Int32 = socket(PF_INET, SOCK_DGRAM, 0)

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

/// `Int` 型の値をそのまま扱うのではなく、ファイルディスクリプタの状態を表現・管理しつつ適切なタイミングで後始末する仕組みがあると安全です。
/// そのようなケースでは `~Copyable` が便利です。 `~Copyable` により次に示す実装が可能です。
///
/// - すでに消費したかしていないかでソケットがオープン状態かクローズ状態かを表現する。
/// - 消費済み、すなわちクローズ済みのソケットを操作してしまう実装をコンパイルの段階で発見できる。
/// - `deinit` と併用することで適切なタイミングで忘れずにソケットをクローズできる。
/// - ソケットへの参照が1つに制限されるので想定しない操作を防ぐことができる。

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

/// 手動でクローズしなかった場合はオブジェクトが破棄される際に `deinit` がクローズします。

do {
    let fileDescriptor = FileDescriptor(fd: socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP))
}

/// 手動でクローズした際は `discard self` が `deinit` による二重のクローズ操作を阻止します。
/// `consuming` のおかげでクローズ後に誤ってソケットを操作することもありません。

do {
    let fileDescriptor = FileDescriptor(fd: socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP))

    // まだconsumeしていないのでOK
    fileDescriptor.send(message: "Hello")

    try fileDescriptor.close()

    // consumeしたあとなのでNG

    // 'fileDescriptor' used after consume
//    fileDescriptor.send(message: "Hello")

    // 'fileDescriptor' consumed more than once
//    try fileDescriptor.close()
}
