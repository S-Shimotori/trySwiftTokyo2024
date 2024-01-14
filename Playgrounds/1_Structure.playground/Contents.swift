import Foundation

/// このPlaygroundでは構造体のメモリ上の様子を観察します。

/// こちらは `UInt8` 型のプロパティを1つだけ持つ構造体です。

struct StructureA {
    let property0: UInt8
}

/// `StructureA` 型オブジェクトはメモリ上でどのように表されているでしょうか。
/// 例として `255` を与えてオブジェクトを作成します。

var structureA_255 = StructureA(property0: 0b11111111)

/// Returns a byte array of an object that a given pointer refers.
/// - Parameters:
///   - pointer: A pointer to the object.
///   - type: The object's type.
/// - Returns: An array of bytes as string.
func binaryData<T>(pointer: UnsafeRawPointer, type: T.Type) -> [String] {
    Data(bytes: pointer, count: MemoryLayout<T>.size)
        .map { String($0, radix: 2) }
        .map { String(repeating: "0", count: 8 - $0.count) + $0 }
}

/// 結果は `11111111` になります。

print(binaryData(pointer: &structureA_255, type: StructureA.self))

/// 別の値を試してみましょう。

var structureA_189 = StructureA(property0: 0b10111101)

/// 結果は `10111101` になります。
/// `property0` の値がそのままメモリ上にあることがわかります。

print(binaryData(pointer: &structureA_189, type: StructureA.self))

/// プロパティを増やしてみます。

struct StructureB {
    let property0: UInt8
    let property1: UInt8
}
var structureB_189_66 = StructureB(property0: 0b10111101, property1: 0b01000010)

/// `[10111101, 01000010]` となりました。プロパティと同じ順番に値が並べられています。

print(binaryData(pointer: &structureB_189_66, type: StructureB.self))

/// タプル型を試してみます。

struct StructureC {
    let property0: (UInt8, UInt8)
}
var structureC_189_66 = StructureC(property0: (0b10111101, 0b01000010))

/// こちらも`[10111101, 01000010]` となりました。タプル内の要素も順番に並べられることがわかります。

print(binaryData(pointer: &structureC_189_66, type: StructureC.self))

/// `UInt16` も試します。

struct StructureD {
    let property0: UInt16
}
var structureD_48450 = StructureD(property0: 0b10111101_01000010)

/// `[01000010, 10111101]` となりました。 `.init(property0:)` に与えた数値リテラルとはバイト列の並びが逆になっています（いわゆるリトルエンディアン）。

print(binaryData(pointer: &structureD_48450, type: StructureD.self))

/// `bigEndian` を指定すれば `[10111101, 01000010]` になります。

struct StructureD_BigEndian {
    let property0: UInt16

    init(property0: UInt16) {
        self.property0 = property0.bigEndian
    }
}
var structureDB_48450 = StructureD_BigEndian(property0: 0b10111101_01000010)
print(binaryData(pointer: &structureDB_48450, type: StructureD_BigEndian.self))

/// さて、 `UInt8` と `UInt16` を組み合わせてみましょう。

struct StructureE {
    let property0: UInt8
    let property1: UInt16
}

var structureE_153_48450 = StructureE(property0: 0b10011001, property1: 0b10111101_01000010)

/// `[10011001, 00000000, 01000010, 10111101]` となります。
/// 順に `[property0, パディング, property1の2バイト目, property1の1バイト目]` です。
/// 途中のパディングはアライメント調整のためのものです。 `UInt16` （16bit）に合わせるために8bitぶん = 1バイトぶんの0が入っています。

print(binaryData(pointer: &structureE_153_48450, type: StructureE.self))

/// 0を何bit入れるかは型の組み合わせ次第です。
/// `UInt16` と `UInt32` の組み合わせなら `UInt32` （32bit）に合わせるために32-16=16つまり2バイトぶんの0が入ります。

struct StructureF {
    let property0: UInt16
    let property1: UInt32
}
var structureF_26214_1450744508 = StructureF(property0: 0b0001_0010_0011_0100, property1: 0b0101_0110_0111_1000_1001_1010_1011_1100)

/// `[00110100, 00010010, 00000000, 00000000, 10111100, 10011010, 01111000, 01010110]`
/// `property0: UInt16` → パディング → `property1: UInt32` と並びます。

print(binaryData(pointer: &structureF_26214_1450744508, type: StructureF.self))

/// 最後に、自作の構造体をプロパティに持つ構造体を試します。

struct StructureG {
    let property0: StructureA
    let property1: UInt16
}
var structureG_153_48450 = StructureG(property0: .init(property0: 0b10011001), property1: 0b10111101_01000010)

/// `[10011001, 00000000, 01000010, 10111101]` となります。
/// プロパティ順に並べてアライメント調整をするということに変わりはありません。

print(binaryData(pointer: &structureG_153_48450, type: StructureG.self))

/// ここまで作成したバイナリ列は `withUnsafeBytes(_:)` と `load(fromByteOffset:as:)` でデコードすることができます。

Data(bytes: &structureA_189, count: MemoryLayout<StructureA>.size)
    .withUnsafeBytes {
        $0.load(as: StructureA.self)
    }
