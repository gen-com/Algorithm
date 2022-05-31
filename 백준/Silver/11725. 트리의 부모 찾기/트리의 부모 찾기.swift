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
let numberOfNodes = fileIO.readInt()
var connectedNodesFor: [Int: [Int]] = [:]
for _ in 0 ..< numberOfNodes - 1 {
    let lhs = fileIO.readInt()
    let rhs = fileIO.readInt()
    if var nodes = connectedNodesFor[lhs] {
        nodes.append(rhs)
        connectedNodesFor[lhs] = nodes
    } else {
        connectedNodesFor[lhs] = [rhs]
    }
    if var nodes = connectedNodesFor[rhs] {
        nodes.append(lhs)
        connectedNodesFor[rhs] = nodes
    } else {
        connectedNodesFor[rhs] = [lhs]
    }
}

// MARK: - Solution

var answer = ""
var result: [Int: Int] = [:]
var notVisited = Array(repeating: true, count: numberOfNodes + 1)
notVisited[1] = false
var queue = [1]
var currentIndex = 0
while currentIndex < queue.endIndex {
    let front = queue[currentIndex]
    if let connectedNodes = connectedNodesFor[front] {
        for node in connectedNodes {
            if notVisited[node] {
                notVisited[node] = false
                result[node] = front
                queue.append(node)
            }
        }
    }
    currentIndex += 1
}
for node in 2 ... numberOfNodes {
    answer += "\(result[node]!)\n"
}
print(answer)