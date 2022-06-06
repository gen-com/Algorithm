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
var number = fileIO.readInt()

// MARK: - Solution

func multiple(_ lhs: [[Int]], _ rhs: [[Int]]) -> [[Int]] {
    var result = Array(repeating: Array(repeating: 0, count: 2), count: 2)
    for i in 0 ..< 2 {
        for j in 0 ..< 2 {
            for k in 0 ..< 2 {
                result[i][j] += lhs[i][k] * rhs[k][j]
            }
            result[i][j] %= 1_000_000_007
        }
    }
    
    return result
}

var answer = [[1, 0], [0, 1]]
var origin = [[1, 1], [1, 0]]
while 0 < number {
    if number % 2 == 1 {
        answer = multiple(answer, origin)
    }
    origin = multiple(origin, origin)
    number /= 2
}
print(answer[0][1])