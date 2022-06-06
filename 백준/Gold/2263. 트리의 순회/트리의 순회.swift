import Foundation

// MARK: - Thanks to Wapas

final class FileIO {
    
    private let buffer:[UInt8]
    private var index: Int = 0

    init(fileHandle: FileHandle = FileHandle.standardInput) {
        buffer = Array(try! fileHandle.readToEnd()!)+[UInt8(0)]
    }

    @inline(__always) private func read() -> UInt8 {
        defer { index += 1 }

        return buffer[index]
    }

    @inline(__always) func readInt() -> Int {
        var sum = 0
        var now = read()
        var isPositive = true
        while now == 10 || now == 32 { now = read() }
        if now == 45 { isPositive.toggle(); now = read() }
        while now >= 48, now <= 57 {
            sum = sum * 10 + Int(now-48)
            now = read()
        }

        return sum * (isPositive ? 1 : -1)
    }

    @inline(__always) func readString() -> String {
        var now = read()
        while now == 10 || now == 32 { now = read() }
        let beginIndex = index-1
        while now != 10, now != 32, now != 0 { now = read() }

        return String(bytes: Array(buffer[beginIndex ..< (index-1)]), encoding: .ascii)!
    }
    
    @inline(__always) func readStirngSum() -> Int {
        var byte = read()
        while byte == 10 || byte == 32 { byte = read() }
        var sum = Int(byte)
        while byte != 10 && byte != 32 && byte != 0 { byte = read(); sum += Int(byte) }
        
        return sum - Int(byte)
    }
}

// MARK: - Input

let fileIO = FileIO()
let numberOfNode = fileIO.readInt()
var inorderNotation = Array(repeating: 0, count: numberOfNode + 1)
var postfixNotation = Array(repeating: 0, count: numberOfNode + 1)
var indexOfInorderNotation = Array(repeating: 0, count: numberOfNode + 1)

for index in 1 ... numberOfNode {
    inorderNotation[index] = fileIO.readInt()
    indexOfInorderNotation[inorderNotation[index]] = index
}
for index in 1 ... numberOfNode {
    postfixNotation[index] = fileIO.readInt()
}

// MARK: - Solution

var prefixNotation = ""

func traversal(_ inorderStart: Int, _ inorderEnd: Int, _ postfixStart: Int, _ postfixEnd: Int) {
    if inorderEnd < inorderStart || postfixEnd < postfixStart { return }
    prefixNotation += "\(postfixNotation[postfixEnd]) "
    let rootNodeIndex = indexOfInorderNotation[postfixNotation[postfixEnd]]
    traversal(inorderStart, rootNodeIndex - 1, postfixStart, postfixStart + rootNodeIndex - inorderStart - 1)
    traversal(rootNodeIndex + 1, inorderEnd, postfixStart + rootNodeIndex - inorderStart, postfixEnd - 1)
}

traversal(1, numberOfNode, 1, numberOfNode)
print(prefixNotation)