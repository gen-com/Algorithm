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

typealias Edge = (lhs: Int, rhs: Int)

let fileIO = FileIO()
let targetNumber = fileIO.readInt()
print(solution(targetNumber))

// MARK: - Solution

private func primeNumbers(_ targetNumber: Int) -> [Int] {
    var aristotleFilter = Array(repeating: true, count: targetNumber + 1)
    aristotleFilter[0] = false
    aristotleFilter[1] = false
    for outerIndex in 2 ... targetNumber {
        if aristotleFilter[outerIndex] {
            for innerIndex  in stride(from: outerIndex * 2, through: targetNumber, by: outerIndex) {
                aristotleFilter[innerIndex] = false
            }
        }
    }
    
    return aristotleFilter.indices.filter { aristotleFilter[$0] }
}

private func solution(_ targetNumber: Int) -> Int {
    if targetNumber == 1 { return 0 }
    let primeNumbers = primeNumbers(targetNumber)
    var answer = 0
    var start = 0
    var end = 0
    var sum = primeNumbers[start]
    while end < primeNumbers.endIndex {
        if start == end {
            end += 1
            if end < primeNumbers.endIndex {
                sum += primeNumbers[end]
            }
        }
        if sum == targetNumber {
            answer += 1
            sum -= primeNumbers[start]
            start += 1
        } else if sum < targetNumber {
            end += 1
            if end < primeNumbers.endIndex {
                sum += primeNumbers[end]
            }
        } else {
            sum -= primeNumbers[start]
            start += 1
        }
    }
    
    return answer
}