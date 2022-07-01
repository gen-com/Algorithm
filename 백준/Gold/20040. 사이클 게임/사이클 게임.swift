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

typealias Edge = (lhs: Int, rhs: Int)

let fileIO = FileIO()
let numberOfDot = fileIO.readInt()
let numberOfTurn = fileIO.readInt()
var edges = Array(repeating: Edge(0, 0), count: numberOfTurn)
for turn in 0 ..< numberOfTurn {
    edges[turn] = Edge(fileIO.readInt(), fileIO.readInt())
}
print(solution(numberOfDot, edges))

// MARK: - Solution

@discardableResult
private func findRoot(_ root: inout [Int], _ current: Int) -> Int {
    if root[current] == current {
        return current
    } else {
        root[current] = findRoot(&root, root[current])
        return root[current]
    }
}

private func solution(_ numberOfDot: Int, _ edges: [Edge]) -> Int {
    var root = Array(repeating: 0, count: numberOfDot)
    for dot in 0 ..< numberOfDot {
        root[dot] = dot
    }
    for index in edges.indices {
        let lhsRoot = findRoot(&root, edges[index].lhs)
        let rhsRoot = findRoot(&root, edges[index].rhs)
        if lhsRoot == rhsRoot {
            return index + 1
        } else if lhsRoot < rhsRoot {
            root[rhsRoot] = lhsRoot
        } else {
            root[lhsRoot] = rhsRoot
        }
    }
    
    return 0
}