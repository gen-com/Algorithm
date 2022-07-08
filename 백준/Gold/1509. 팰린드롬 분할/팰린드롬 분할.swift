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
let input = fileIO.readString()
print(solution(input))

// MARK: - Solution

private func solution(_ input: String) -> Int {
    let inputArray = input.map { String($0) }
    var palindromeDP = Array(repeating: Array(repeating: false, count: input.count), count: input.count)
    for index in inputArray.indices {
        palindromeDP[index][index] = true
    }
    for index in 0 ..< inputArray.count - 1 {
        if inputArray[index] == inputArray[index + 1] {
            palindromeDP[index][index + 1] = true
        }
    }
    if 1 < inputArray.count {
        for length in 2 ... inputArray.count {
            var start = 0
            while start + length - 1 < inputArray.count {
                if inputArray[start] == inputArray[start + length - 1], palindromeDP[start + 1][start + length - 2] {
                    palindromeDP[start][start + length - 1] = true
                }
                start += 1
            }
        }
    }
    var dpSplit = Array(repeating: Int.max, count: input.count + 1)
    dpSplit[0] = 0
    for end in 0 ..< input.count {
        for start in 0 ... end {
            if palindromeDP[start][end] {
                dpSplit[end + 1] = min(dpSplit[end + 1], dpSplit[start]  + 1)
            }
        }
    }
    
    return dpSplit[input.count]
}