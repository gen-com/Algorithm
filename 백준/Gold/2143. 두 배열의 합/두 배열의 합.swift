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
let targetNumber = fileIO.readInt()
let arrayACount = fileIO.readInt()
var arrayA = Array(repeating: 0, count: arrayACount + 1)
for index in arrayA.indices {
    if index == 0 { continue }
    arrayA[index] = fileIO.readInt()
}
let arrayBCount = fileIO.readInt()
var arrayB = Array(repeating: 0, count: arrayBCount + 1)
for index in arrayB.indices {
    if index == 0 { continue }
    arrayB[index] = fileIO.readInt()
}
print(solution(targetNumber, arrayA, arrayB))

// MARK: - Solution

private func solution(_ targetNumber: Int, _ arrayA: [Int], _ arrayB: [Int]) -> Int {
    var answer = 0
    var prefixSumA = Array(repeating: 0, count: arrayA.count)
    for index in arrayA.indices {
        if index == 0 { continue }
        prefixSumA[index] = prefixSumA[index - 1] + arrayA[index]
    }
    var prefixSumB = Array(repeating: 0, count: arrayB.count)
    for index in arrayB.indices {
        if index == 0 { continue }
        prefixSumB[index] = prefixSumB[index - 1] + arrayB[index]
    }
    
    var candidates: [Int: Int] = [:]
    for outerIndex in arrayA.indices {
        for innerIndex in arrayA.indices {
            if innerIndex <= outerIndex { continue }
            if let count = candidates[prefixSumA[innerIndex] - prefixSumA[outerIndex]] {
                candidates[prefixSumA[innerIndex] - prefixSumA[outerIndex]] = count + 1
            } else {
                candidates[prefixSumA[innerIndex] - prefixSumA[outerIndex]] = 1
            }
        }
    }
    for outerIndex in arrayB.indices {
        for innerIndex in arrayB.indices {
            if innerIndex <= outerIndex { continue }
            if let count = candidates[targetNumber - (prefixSumB[innerIndex] - prefixSumB[outerIndex])] {
                answer += count
            }
        }
    }
    
    return answer
}