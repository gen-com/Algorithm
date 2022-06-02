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
let testCase = fileIO.readInt()
var answer = ""
for _ in 0 ..< testCase {
    let columns = fileIO.readInt()
    let rows = 2
    var stickers = Array(repeating: Array(repeating: 0, count: rows), count: columns)
    for row in 0 ..< rows {
    for column in 0 ..< columns {
            stickers[column][row] = fileIO.readInt()
        }
    }
    
    // MARK: - Solution
    
    var dp = Array(repeating: Array(repeating: 0, count: rows), count: columns)
    dp[0][0] = stickers[0][0]
    dp[0][1] = stickers[0][1]
    if 1 < columns {
        dp[1][0] = stickers[1][0] + dp[0][1]
        dp[1][1] = stickers[1][1] + dp[0][0]
    }
    if 2 < columns {
        for column in 2 ..< columns {
            for row in 0 ..< rows {
                if row == 0 {
                    dp[column][row] = max(dp[column - 1][row + 1], dp[column - 2][row + 1])
                    dp[column][row] += stickers[column][row]
                } else {
                    dp[column][row] = max(dp[column - 1][row - 1], dp[column - 2][row - 1])
                    dp[column][row] += stickers[column][row]
                }
            }
        }
    }
    answer += "\(max(dp[columns - 1][0], dp[columns - 1][1]))\n"
}
print(answer)