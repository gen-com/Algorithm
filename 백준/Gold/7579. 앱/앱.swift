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
let numberOfActive = fileIO.readInt()
let needMemory = fileIO.readInt()
var memoryForActive = Array(repeating: 0, count: numberOfActive + 1)
var costForReactivate = Array(repeating: 0, count: numberOfActive + 1)
for index in 1 ... numberOfActive {
    memoryForActive[index] = fileIO.readInt()
}
for index in 1 ... numberOfActive {
    costForReactivate[index] = fileIO.readInt()
}
print(solution(memoryForActive, costForReactivate, needMemory))
    
// MARK: - Solution

private func solution(_ memoryForActive: [Int], _ costForReactivate: [Int], _ needMemory: Int) -> Int {
    let costSum = costForReactivate.reduce(0, +)
    var dp = Array(repeating: Array(repeating: 0, count: costSum + 1), count: memoryForActive.count + 1)
    for app in 1 ..< memoryForActive.count {
        for cost in 0 ... costSum {
            if costForReactivate[app] <= cost {
                dp[app][cost] = max(dp[app][cost], dp[app - 1][cost - costForReactivate[app]] + memoryForActive[app])
            }
            dp[app][cost] = max(dp[app][cost], dp[app - 1][cost])
        }
    }
    for cost in 0 ... costSum {
        if needMemory <= dp[memoryForActive.count - 1][cost] {
            return cost
        }
    }
    
    return 0
}