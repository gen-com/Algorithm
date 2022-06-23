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
let numberOfMatrix = fileIO.readInt()
var matrices = Array(repeating: (row: 0, column: 0), count: numberOfMatrix)
for index in 0 ..< numberOfMatrix {
    matrices[index] = (fileIO.readInt(), fileIO.readInt())
}
print(solution(matrices))

// MARK: - Solution

private func solution(_ matrices: [(row: Int, column: Int)]) -> Int {
    var dp = Array(repeating: Array(repeating: 0, count: matrices.count + 1), count: matrices.count + 1)
    for i in 1 ..< matrices.count {
        for j in 1 ... matrices.count - i {
            dp[j][i + j] = Int.max
            for k in j ..< i + j {
                dp[j][i + j] = min(dp[j][i + j], dp[j][k] + dp[k + 1][i + j] + matrices[j - 1].row * matrices[k - 1].column * matrices[i + j - 1].column)
            }
        }
    }
    
    return dp[1][matrices.count]
}