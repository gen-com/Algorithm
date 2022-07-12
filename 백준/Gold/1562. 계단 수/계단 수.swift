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
let length = Int(fileIO.readString())!
let mod = 1_000_000_000
print(solution(length))

// MARK: - Solution

private func dfs(_ dp: inout [[[Int]]], _ index: Int, _ currentNumber: Int, _ bit: Int, _ maxIndex: Int) -> Int {
    if index == maxIndex {
        return bit == (1 << 10) - 1 ? 1 : 0
    }
    if 0 < dp[index][currentNumber][bit] {
        return dp[index][currentNumber][bit]
    }
    if 0 < currentNumber {
        dp[index][currentNumber][bit] += dfs(&dp, index + 1, currentNumber - 1, bit | (1 << (currentNumber - 1)), maxIndex)
        dp[index][currentNumber][bit] %= mod
    }
    if currentNumber < 9 {
        dp[index][currentNumber][bit] += dfs(&dp, index + 1, currentNumber + 1, bit | (1 << (currentNumber + 1)), maxIndex)
        dp[index][currentNumber][bit] %= mod
    }
    
    return dp[index][currentNumber][bit]
}

private func solution(_ length: Int) -> Int {
    var answer = 0
    var dp = Array(repeating: Array(repeating: Array(repeating: 0, count: 1 << 10), count: 10) , count: length + 1)
    for number in 1 ... 9 {
        answer += dfs(&dp, 1, number, 1 << number, length)
        answer %= mod
    }
    
    return answer
}