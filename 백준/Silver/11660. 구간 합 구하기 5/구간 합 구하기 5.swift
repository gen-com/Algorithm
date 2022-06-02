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
let length = fileIO.readInt()
let testCase = fileIO.readInt()
var array = Array(repeating: Array(repeating: 0, count: length + 1), count: length)
for row in 0 ..< length {
    var sum = 0
    for column in 1 ... length {
        let input = fileIO.readInt()
        sum += input
        array[row][column] = sum
    }
}

// MARK: - Solution

var answer = ""
for _ in 0 ..< testCase {
    let firstX = fileIO.readInt() - 1
    let firstY = fileIO.readInt() - 1
    let secondX = fileIO.readInt() - 1
    let secondY = fileIO.readInt()
    var sum = 0
    for row in firstX ... secondX {
        sum += (array[row][secondY] - array[row][firstY])
    }
    answer += "\(sum)\n"
}
print(answer)