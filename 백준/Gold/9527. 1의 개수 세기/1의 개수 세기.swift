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
var start = fileIO.readInt()
var end = fileIO.readInt()
print(solution(&start, &end))

// MARK: - Solution

private func oneCountFor(value: inout Int, with prefixSum: [Int]) -> Int {
    var count = value & 1
    for index in stride(from: String(value, radix: 2).count, to: 0, by: -1) {
        if 0 < value & (1 << index) {
            count += (prefixSum[index - 1] + (value - (1 << index) + 1))
            value -= (1 << index)
        }
    }
    
    return count
}

private func solution(_ start: inout Int, _ end: inout Int) -> Int {
    var prefixSum = Array(repeating: 0, count: String(end, radix: 2).count + 1)
    prefixSum[0] = 1
    for index in 1 ..< prefixSum.endIndex {
        prefixSum[index] = 2 * prefixSum[index - 1] + (1 << index)
    }
    start -= 1
    
    return oneCountFor(value: &end, with: prefixSum) - oneCountFor(value: &start, with: prefixSum)
}