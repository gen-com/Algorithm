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
let n = fileIO.readInt()
let m = fileIO.readInt()
var array = Array(repeating: 0, count: n)
for index in 0 ..< n {
    array[index] = fileIO.readInt()
}
array.sort()

// MARK: - Solution

var answer = ""
var visitedResult: [String: Bool] = [:]
func backTracking(current: [String], notVisited: [Bool]) {
    if current.count == m {
        if visitedResult[current.joined()] == nil {
            visitedResult[current.joined()] = true
            for value in current {
                answer += "\(value) "
            }
            answer += "\n"
        }
        
        return
    }
    for index in 0 ..< array.endIndex {
        if notVisited[index] {
            var nextNotVisited = notVisited
            nextNotVisited[index] = false
            var next = current
            next.append("\(array[index])")
            backTracking(current: next, notVisited: nextNotVisited)
        }
    }
}
backTracking(current: [], notVisited: Array(repeating: true, count: n))
print(answer)