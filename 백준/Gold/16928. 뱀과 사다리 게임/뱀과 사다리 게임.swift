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
let numberOfLadders = fileIO.readInt()
let numberOfSnakes = fileIO.readInt()
var moveDict: [Int: Int] = [:]
for _ in 0 ..< numberOfLadders + numberOfSnakes {
    moveDict[fileIO.readInt()] = fileIO.readInt()
}

// MARK: - Solution

var map = Array(repeating: 101, count: 101)
var queue = [(position: 1, steps: 0)]
var current = 0
while current < queue.count {
    let front = (position: moveDict[queue[current].position] ?? queue[current].position, steps: queue[current].steps)
    if front.position == 100 {
        print(front.steps)
        break
    } else {
        for dice in 1 ... 6 {
            if front.position + dice <= 100, front.steps + 1 < map[front.position + dice] {
                queue.append((position: front.position + dice, steps: front.steps + 1))
                map[front.position + dice] = front.steps + 1
            }
        }
        current += 1
    }
}