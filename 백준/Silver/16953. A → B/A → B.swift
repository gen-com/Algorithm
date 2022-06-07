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
var startingPoint = fileIO.readInt()
let destination = fileIO.readInt()

// MARK: - Solution

var answer = -1
var visited: [Int: Bool] = [startingPoint: true]
var currentIndex = 0
var queue = [(current: startingPoint, step: 1)]
while currentIndex < queue.endIndex {
    let front = queue[currentIndex]
    if front.current * 2 == destination || front.current * 10 + 1 == destination {
        answer = front.step + 1
        break
    }
    if front.current * 2 < destination, visited[front.current * 2] == nil {
        visited[front.current * 2] = true
        queue.append((front.current * 2, front.step + 1))
    }
    if front.current * 10 + 1 < destination, visited[front.current * 10 + 1] == nil {
        visited[front.current * 10 + 1] = true
        queue.append((front.current * 10 + 1, front.step + 1))
    }
    currentIndex += 1
}
print(answer)