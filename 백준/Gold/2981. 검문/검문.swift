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
let numberCount = fileIO.readInt()
var numbers = Array(repeating: 0, count: numberCount)
for index in numbers.indices {
    numbers[index] = fileIO.readInt()
}
numbers.sort()

// MARK: - Solution

private func gcd(_ lhs: Int, _ rhs: Int) -> Int {
    0 < lhs % rhs ? gcd(rhs, lhs % rhs) : rhs
}

private func solution(_ numbers: [Int]) -> String {
    var answer: [Int] = []
    var tmpGCD = numbers[1] - numbers[0]
    for index in 2 ..< numbers.endIndex {
        tmpGCD = gcd(tmpGCD, numbers[index] - numbers[index - 1])
    }
    var candidate = 1
    while candidate * candidate <= tmpGCD {
        if tmpGCD % candidate == 0 {
            answer.append(candidate)
            if candidate != tmpGCD / candidate {
                answer.append(tmpGCD / candidate)
            }
        }
        candidate += 1
    }
    answer.sort()
    var answerString = ""
    for index in answer.indices {
        if 1 < answer[index] {
            answerString += "\(answer[index])"
            if index < answer.endIndex - 1 {
                answerString += " "
            }
        }
    }
    
    return answerString
}
print(solution(numbers))