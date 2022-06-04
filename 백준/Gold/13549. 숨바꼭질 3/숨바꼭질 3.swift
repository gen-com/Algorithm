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
let start = fileIO.readInt()
let destination = fileIO.readInt()

// MARK: - Solution

func solution(start: Int, destination: Int) -> Int {
    var distance = Array(repeating: Int.max, count: 100_001)
    distance[start] = 0
    var queue = [start]
    var currentIndex = 0
    while currentIndex < queue.endIndex {
        let front = queue[currentIndex]
        if 2 * front <= 100_000, distance[front] < distance[2 * front] {
            distance[2 * front] = distance[front]
            queue.append(2 * front)
            if 2 * front == destination { break }
        }
        if 0 <= front - 1, distance[front] + 1 < distance[front - 1] {
            distance[front - 1] = distance[front] + 1
            queue.append(front - 1)
            if front - 1 == destination { break }
        }
        if front + 1 <= 100_000, distance[front] + 1 < distance[front + 1] {
            distance[front + 1] = distance[front] + 1
            queue.append(front + 1)
            if front + 1 == destination { break }
        }
        currentIndex += 1
    }
    
    return distance[destination]
}
print(solution(start: start, destination: destination))