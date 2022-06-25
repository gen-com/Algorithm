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
let lengthOfSequence = fileIO.readInt()
let targetSum = fileIO.readInt()
var sequence = Array(repeating: 0, count: lengthOfSequence)
for index in sequence.indices {
    sequence[index] = fileIO.readInt()
}
print(solution(sequence, targetSum))

// MARK: - Solution

private func leftCombinationSum(_ map: inout [Int: Int], _ sequence: [Int], _ current: Int, _ sum: Int) {
    if current == sequence.count / 2 {
        if let count = map[sum] {
            map[sum] = count + 1
        } else {
            map[sum] = 1
        }
        return
    }
    
    leftCombinationSum(&map, sequence, current + 1, sum + sequence[current])
    leftCombinationSum(&map, sequence, current + 1, sum)
}

private func rightCombinationSum(_ map: inout [Int: Int], _ sequence: [Int], _ current: Int, _ sum: Int, _ target: Int, _ answer: inout Int) {
    if current == sequence.count {
        if let count = map[target - sum] {
            answer += count
        }
        return
    }
    
    rightCombinationSum(&map, sequence, current + 1, sum + sequence[current], target, &answer)
    rightCombinationSum(&map, sequence, current + 1, sum, target, &answer)
}

private func solution(_ sequence: [Int], _ targetSum: Int) -> Int {
    var map: [Int: Int] = [:]
    var answer = 0
    
    leftCombinationSum(&map, sequence, 0, 0)
    rightCombinationSum(&map, sequence, sequence.count / 2, 0, targetSum, &answer)
    
    return targetSum == 0 ? answer - 1 : answer
}