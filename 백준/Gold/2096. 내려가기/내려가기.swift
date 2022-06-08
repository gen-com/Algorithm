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
let numberOfRow = fileIO.readInt()

// MARK: - Solution

var maxArr = Array(repeating: 0, count: 3)
var minArr = Array(repeating: 0, count: 3)
var maxPrev = Array(repeating: 0, count: 3)
var minPrev = Array(repeating: 0, count: 3)
var rowArr = Array(repeating: 0, count: 3)

for row in 0 ..< numberOfRow {
    rowArr[0] = fileIO.readInt()
    rowArr[1] = fileIO.readInt()
    rowArr[2] = fileIO.readInt()
    
    if row == 0 {
        for index in 0 ..< 3 {
            maxPrev[index] = rowArr[index]
            maxArr[index] = rowArr[index]
            
            minPrev[index] = rowArr[index]
            minArr[index] = rowArr[index]
        }
        continue
    }
    
    maxArr[0] = rowArr[0] + max(maxPrev[0], maxPrev[1])
    maxArr[1] = rowArr[1] + max(maxPrev[0], maxPrev[1], maxPrev[2])
    maxArr[2] = rowArr[2] + max(maxPrev[1], maxPrev[2])
    
    minArr[0] = rowArr[0] + min(minPrev[0], minPrev[1])
    minArr[1] = rowArr[1] + min(minPrev[0], minPrev[1], minPrev[2])
    minArr[2] = rowArr[2] + min(minPrev[1], minPrev[2])
    
    for index in 0 ..< 3 {
        maxPrev[index] = maxArr[index]
        minPrev[index] = minArr[index]
    }
}
print("\(maxArr.max()!) \(minArr.min()!)")