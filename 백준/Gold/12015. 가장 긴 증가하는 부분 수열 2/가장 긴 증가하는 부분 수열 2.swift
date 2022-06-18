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
let numberOfInput = fileIO.readInt()
var sequence = Array(repeating: 0, count: numberOfInput)
for index in 0 ..< numberOfInput {
    sequence[index] = fileIO.readInt()
}
    
// MARK: - Solution

private func binarySearch(_ sequence: [Int], _ start: Int, _ end: Int, _ target: Int) -> Int? {
    if end <= start {
        return end
    } else {
        let mid = (start + end) / 2
        if target < sequence[mid] {
            return binarySearch(sequence, start, mid, target)
        } else if target == sequence[mid] {
            return nil
        } else {
            return binarySearch(sequence, mid + 1, end, target)
        }
    }
}

private func solution(_ sequence: [Int]) -> Int {
    var answer: [Int] = []
    for value in sequence {
        if answer.isEmpty {
            answer.append(value)
        } else {
            if answer.last! < value {
                answer.append(value)
            } else {
                if let index = binarySearch(answer, 0, answer.endIndex - 1, value) {
                    answer[index] = value
                }
                
            }
        }
    }
    
    return answer.count
}
print(solution(sequence))