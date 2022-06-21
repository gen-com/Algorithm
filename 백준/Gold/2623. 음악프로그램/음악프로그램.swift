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
let numberOfSinger = fileIO.readInt()
let numberOfProducer = fileIO.readInt()
var producerOrder = Array(repeating: [Int](), count: numberOfProducer)
var postOrder = Array(repeating: [Int](), count: numberOfSinger + 1)
var preOrderCount = Array(repeating: 0, count: numberOfSinger + 1)
for index in 0 ..< numberOfProducer {
    let count = fileIO.readInt()
    for _ in 0 ..< count {
        producerOrder[index].append(fileIO.readInt())
    }
    for producerIndex in 0 ..< producerOrder[index].count - 1 {
        for nextIndex in producerIndex + 1 ..< producerOrder[index].count {
            postOrder[producerOrder[index][producerIndex]].append(producerOrder[index][nextIndex])
            preOrderCount[producerOrder[index][nextIndex]] += 1
        }
    }
}
    
// MARK: - Solution

private func solution(_ postOrder: inout [[Int]], _ preOrderCount: inout [Int]) -> String {
    var queue: [Int] = []
    for index in  1 ..< preOrderCount.endIndex {
        if preOrderCount[index] == 0 {
            queue.append(index)
        }
    }
    var currentIndex = 0
    while currentIndex < queue.endIndex {
        for next in postOrder[queue[currentIndex]] {
            preOrderCount[next] -= 1
            if preOrderCount[next] == 0 {
                queue.append(next)
            }
        }
        currentIndex += 1
    }
    
    return queue.count == numberOfSinger ? queue.reduce("") { $0 + "\($1)\n" } : "0"
}
print(solution(&postOrder, &preOrderCount))