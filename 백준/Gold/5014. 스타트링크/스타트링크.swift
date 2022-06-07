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
let totalFloor = fileIO.readInt()
let startingPoint = fileIO.readInt()
let destination = fileIO.readInt()
let up = fileIO.readInt()
let down = fileIO.readInt()

// MARK: - Solution

var answer = "use the stairs"
var visited = Array(repeating: false, count: totalFloor + 1)
visited[startingPoint] = true
var queue = [(current: startingPoint, step: 0)]
var currentIndex = 0
while currentIndex < queue.endIndex {
    let front = queue[currentIndex]
    if front.current + up == destination || front.current - down == destination {
        answer = "\(front.step + 1)"
        break
    }
    if front.current + up < totalFloor, visited[front.current + up] == false {
        visited[front.current + up] = true
        queue.append((front.current + up, front.step + 1))
    }
    if 0 < front.current - down, visited[front.current - down] == false {
        visited[front.current - down] = true
        queue.append((front.current - down, front.step + 1))
    }
    currentIndex += 1
}
print(startingPoint == destination ? 0 : answer)