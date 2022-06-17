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

typealias EdgeInformation = (lhsNode: Int, rhsNode: Int, weight: Int)

let fileIO = FileIO()
let numberOfNode = fileIO.readInt()
let numberOfEdge = fileIO.readInt()
var edge: [EdgeInformation] = []
for _ in 0 ..< numberOfEdge {
    edge.append((fileIO.readInt(), fileIO.readInt(), fileIO.readInt()))
}
edge.sort(by: { $0.weight < $1.weight })
    
// MARK: - Solution

var parentOf = Array(repeating: 0, count: numberOfNode + 1)
for node in 1 ... numberOfNode {
    parentOf[node] = node
}

private func parent(of node: Int) -> Int {
    if parentOf[node] == node {
        return node
    } else {
        parentOf[node] = parent(of: parentOf[node])
        return parentOf[node]
    }
}

private func find(lhs: Int, rhs: Int) -> Bool {
    let lhsParent = parent(of: lhs)
    let rhsParent = parent(of: rhs)
    if lhsParent == rhsParent {
        return false
    } else {
        union(lhs: lhsParent, rhs: rhsParent)
        return true
    }
}

private func union(lhs: Int, rhs: Int) {
    if lhs < rhs {
        parentOf[rhs] = lhs
    } else {
        parentOf[lhs] = rhs
    }
}

private func solution() -> Int {
    var answer = 0
    var currentIndex = 0
    var connectedEdges = 0
    
    while currentIndex < edge.endIndex {
        if connectedEdges == numberOfNode - 1 { break }
        let front = edge[currentIndex]
        if find(lhs: front.lhsNode, rhs: front.rhsNode) {
            answer += front.weight
            connectedEdges += 1
        }
        currentIndex += 1
    }
    
    return answer
}
print(solution())