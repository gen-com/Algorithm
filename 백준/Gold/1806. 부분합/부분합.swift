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

typealias EdgeInformation = (lhsNode: Int, rhsNode: Int, weight: Int)

let fileIO = FileIO()
let numberOfInput = fileIO.readInt()
let standard = fileIO.readInt()
var numbers = Array(repeating: 0, count: numberOfInput)
for index in 0 ..< numberOfInput {
    numbers[index] = fileIO.readInt()
}
    
// MARK: - Solution

private func solution() {
    var answer = numbers.count + 1
    var startIndex = 0
    var endIndex = 0
    var sum = numbers[startIndex]
    if standard <= sum {
        answer = 1
    }
    while endIndex < numberOfInput {
        if startIndex == endIndex {
            if standard <= sum {
                answer = 1
            }
            endIndex += 1
            if endIndex < numberOfInput {
                sum += numbers[endIndex]
            } else {
                break
            }
        } else {
            if standard <= sum {
                answer = min(answer, endIndex - startIndex + 1)
                sum -= numbers[startIndex]
                startIndex += 1
            } else {
                endIndex += 1
                if endIndex < numberOfInput {
                    sum += numbers[endIndex]
                } else {
                    break
                }
            }
        }
    }
    print(answer == numbers.count + 1 ? 0 : answer)
}
solution()