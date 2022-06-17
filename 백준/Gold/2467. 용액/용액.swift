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
let numberOfSolution = fileIO.readInt()
var solutions: [Int] = []
for _ in 0 ..< numberOfSolution {
    solutions.append(fileIO.readInt())
}

// MARK: - Solution

var startIndex = 0
var endIndex = solutions.endIndex - 1
var answer = [1_000_000_000, 1_000_000_000]

while startIndex < endIndex {
    if abs(solutions[startIndex] + solutions[endIndex]) <= abs(answer.reduce(0, +)) {
        answer[0] = solutions[startIndex]
        answer[1] = solutions[endIndex]
    }
    if abs(solutions[startIndex] + solutions[endIndex - 1]) < abs(solutions[endIndex] + solutions[startIndex + 1]) {
        endIndex -= 1
    } else if abs(solutions[endIndex] + solutions[startIndex + 1]) < abs(solutions[startIndex] + solutions[endIndex - 1]) {
        startIndex += 1
    } else {
        startIndex += 1
        endIndex -= 1
    }
}
print("\(answer[0]) \(answer[1])")