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
var sequence = Array(repeating: 0, count: numberOfInput + 1)
var sum = 0
for index in 1 ... numberOfInput {
    sequence[index] = fileIO.readInt()
}
let numberOfQuestion = fileIO.readInt()
var questions = Array(repeating: Array(repeating: 0, count: 2), count: numberOfQuestion)
for index in 0 ..< numberOfQuestion {
    questions[index][0] = fileIO.readInt()
    questions[index][1] = fileIO.readInt()
}
    
// MARK: - Solution

private func solution(_ sequence: [Int], _ questions: [[Int]]) -> String {
    var answer = ""
    var dp = Array(repeating: Array(repeating: false, count: sequence.count), count: sequence.count)
    for index in 1 ..< sequence.endIndex {
        dp[index][index] = true
        if index + 1 < sequence.endIndex, sequence[index] == sequence[index + 1] {
            dp[index][index + 1] = true
        }
    }
    for startIndex in stride(from: sequence.endIndex - 1, through: 1, by: -1) {
        for endIndex in startIndex ..< sequence.endIndex {
            if sequence[startIndex] == sequence[endIndex], startIndex + 1 < sequence.count, 0 < endIndex, dp[startIndex + 1][endIndex - 1] {
                dp[startIndex][endIndex] = true
            }
        }
    }
    for question in questions {
        answer += dp[question[0]][question[1]] ? "1\n" : "0\n"
    }
    let _ = answer.popLast()
    return answer
}

print(solution(sequence, questions))