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
var commands: [Int] = []
var input = fileIO.readInt()
while 0 != input {
    commands.append(input)
    input = fileIO.readInt()
}
print(solution(commands))

// MARK: - Solution

enum Direction: Int {
    
    case center = 0
    case up = 1
    case left = 2
    case down = 3
    case right = 4
    case unknown
    
    static func verify(_ value: Int) -> Direction {
        Direction(rawValue: value) ?? .unknown
    }
}

private func cost(from: Int, to: Int) -> Int {
    if from == to { return 1 }
    switch Direction.verify(from) {
    case .center: return 2
    case .up: return Direction.verify(to) == .down ? 4 : 3
    case .left: return Direction.verify(to) == .right ? 4 : 3
    case .down: return Direction.verify(to) == .up ? 4 : 3
    case .right: return Direction.verify(to) == .left ? 4 : 3
    case .unknown: return 0
    }
}

private func step(_ commands: [Int], _ dp: inout [[[Int]]], _ left: Int, _ right: Int, _ count: Int) -> Int {
    if commands.count == count { return 0 }
    if dp[left][right][count] == 0 {
        dp[left][right][count] = min(
            step(commands, &dp, commands[count], right, count + 1) + cost(from: left, to: commands[count]),
            step(commands, &dp, left, commands[count], count + 1) + cost(from: right, to: commands[count])
        )
    }
    
    return dp[left][right][count]
}

private func solution(_ commands: [Int]) -> Int {
    var dp = Array(repeating: Array(repeating: Array(repeating: 0, count: commands.count), count: 5), count: 5)
    
    return step(commands, &dp, 0, 0, 0)
}