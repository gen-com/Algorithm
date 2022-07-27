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
let mod = fileIO.readInt()
var array = Array(repeating: 0, count: numberCount + 1)
for index in 1 ... numberCount {
    array[index] = (array[index - 1] + fileIO.readInt()) % mod
}

// MARK: - Solution

private func solution(_ array: [Int], _ mod: Int) -> Int {
    var answer = 0
    var remainderCount = Array(repeating: 0, count: mod)
    for index in 1 ..< array.endIndex {
        remainderCount[array[index]] += 1
    }
    for index in remainderCount.indices {
        answer += (remainderCount[index] * (remainderCount[index] - 1) / 2)
    }
    
    return answer + remainderCount[0]
}
print(solution(array, mod))