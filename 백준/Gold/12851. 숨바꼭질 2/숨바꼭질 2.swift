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
let startingPoint = fileIO.readInt()
let destination = fileIO.readInt()

// MARK: - Solution

typealias PositionInformation = (position: Int, time: Int)

var answer = [Int.max, 0]
var queue: [PositionInformation] = [(startingPoint, 0)]
var distanceArray = Array(repeating: Int.max, count: 200_001)
var currentIndex = 0
distanceArray[startingPoint] = 0

while currentIndex < queue.endIndex {
    let front = queue[currentIndex]
    if front.position == destination {
        if answer[0] < front.time { break }
        answer[0] = front.time
        answer[1] += 1
    }
    if 0 <= front.position - 1, front.time + 1 <= distanceArray[front.position - 1] {
        distanceArray[front.position - 1] = front.time + 1
        queue.append((front.position - 1, front.time + 1))
    }
    if front.position + 1 < 200_001, front.time + 1 <= distanceArray[front.position + 1] {
        distanceArray[front.position + 1] = front.time + 1
        queue.append((front.position + 1, front.time + 1))
    }
    if front.position * 2 < 200_001, front.time + 1 <= distanceArray[front.position * 2] {
        distanceArray[front.position * 2] = front.time + 1
        queue.append((front.position * 2, front.time + 1))
    }
    currentIndex += 1
}
answer.forEach { print($0) }