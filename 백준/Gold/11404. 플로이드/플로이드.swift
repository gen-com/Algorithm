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
let numberOfCity = fileIO.readInt()
let numberOfBus = fileIO.readInt()
var dp = Array(repeating: Array(repeating: Int.max, count: numberOfCity), count: numberOfCity)
for city in 0 ..< numberOfCity {
    dp[city][city] = 0
}
for _ in 0 ..< numberOfBus {
    let startingPoint = fileIO.readInt() - 1
    let destination = fileIO.readInt() - 1
    let cost = fileIO.readInt()
    dp[startingPoint][destination] = min(dp[startingPoint][destination], cost)
}

// MARK: - Solution

for pass in 0 ..< numberOfCity {
    for startingPoint in 0 ..< numberOfCity {
        for destination in 0 ..< numberOfCity {
            if dp[startingPoint][pass] != Int.max, dp[pass][destination] != Int.max {
                dp[startingPoint][destination] = min(dp[startingPoint][destination], dp[startingPoint][pass] + dp[pass][destination])
            }
        }
    }
}
var result = ""
for startingPoint in 0 ..< numberOfCity {
    for destination in 0 ..< numberOfCity {
        result += "\(dp[startingPoint][destination] == Int.max ? 0 : dp[startingPoint][destination]) "
    }
    result += "\n"
}
print(result)