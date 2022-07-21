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
let numberOfNode = fileIO.readInt()
var edges = Array(repeating: Edge(0, 0), count: numberOfNode - 1)
for index in edges.indices {
    edges[index] = Edge(fileIO.readInt(), fileIO.readInt())
}

// MARK: - Solution

private func traversal(_ current: Int, _ edgeFor: [[Int]], _ visited: inout [Bool], _ dp: inout [[Int]]) {
    visited[current] = true
    dp[current][0] = 1
    for node in edgeFor[current] {
        if visited[node] { continue }
        traversal(node, edgeFor, &visited, &dp)
        dp[current][0] += min(dp[node][0], dp[node][1])
        dp[current][1] += dp[node][0]
    }
}

private func solution(_ numberOfNode: Int, _ edges: [Edge]) -> Int {
    var edgeFor = Array(repeating: [Int](), count: numberOfNode + 1)
    var dp = Array(repeating: Array(repeating: 0, count: 2), count: numberOfNode + 1)
    var visited = Array(repeating: false, count: numberOfNode + 1)
    for edge in edges {
        edgeFor[edge.lhs].append(edge.rhs)
        edgeFor[edge.rhs].append(edge.lhs)
    }
    traversal(1, edgeFor, &visited, &dp)
    
    return min(dp[1][0], dp[1][1])
}
print(solution(numberOfNode, edges))