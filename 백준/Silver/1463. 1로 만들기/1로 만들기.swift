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
let targetNumber = fileIO.readInt()

// MARK: - Solution

func solution(_ number: Int) -> Int {
    var visited = Array(repeating: Int.max, count: targetNumber + 1)
    var queue = [(number: number, steps: 0)]
    var currentIndex = 0
    visited[number] = 0
    while currentIndex < queue.endIndex {
        let front = queue[currentIndex]
        if front.number == 1 { break }
        if front.number % 3 == 0, front.steps + 1 < visited[front.number / 3] {
            visited[front.number / 3] = front.steps + 1
            queue.append((front.number / 3, front.steps + 1))
        }
        if front.number % 2 == 0, front.steps + 1 < visited[front.number / 2] {
            visited[front.number / 2] = front.steps + 1
            queue.append((front.number / 2, front.steps + 1))
        }
        if front.steps + 1 < visited[front.number - 1] {
            visited[front.number - 1] = front.steps + 1
            queue.append((front.number - 1, front.steps + 1))
        }
        currentIndex += 1
    }
    
    return visited[1]
}
print(solution(targetNumber))