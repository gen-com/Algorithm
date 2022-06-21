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
var solutions = Array(repeating: 0, count: numberOfSolution)
for index in 0 ..< numberOfSolution {
    solutions[index] = fileIO.readInt()
}
solutions.sort()
    
// MARK: - Solution

private func solution(_ solutions: [Int]) -> String {
    var answer = ""
    var minimumSolution = Int.max
    for fixed in 0 ..< solutions.endIndex - 2 {
        var start = fixed + 1
        var end = solutions.endIndex - 1
        while start < end {
            let candidate = solutions[fixed] + solutions[start] + solutions[end]
            if abs(candidate) < abs(minimumSolution) {
                minimumSolution = candidate
                answer = "\(solutions[fixed]) \(solutions[start]) \(solutions[end])"
            }
            if candidate == 0 {
                return answer
            } else if 0 < candidate {
                end -= 1
            } else {
                start += 1
            }
        }
    }
    
    return answer
}
print(solution(solutions))