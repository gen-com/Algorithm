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

typealias Position = (x: Double, y: Double)
typealias EdgeInfo = (lhs: Int, rhs: Int, cost: Double)

let fileIO = FileIO()
let numberOfStar = fileIO.readInt()
var stars = Array(repeating: Position(0, 0), count: numberOfStar)
for index in 0 ..< numberOfStar {
    stars[index] = (Double(fileIO.readString())!, Double(fileIO.readString())!)
}
var edges: [EdgeInfo] = []
for outerIndex in stars.indices {
    for innerIndex in stars.indices {
        if innerIndex <= outerIndex { continue }
        edges.append(EdgeInfo(outerIndex, innerIndex, distance(stars[outerIndex], stars[innerIndex])))
    }
}
edges.sort { $0.cost < $1.cost }
print(solution(numberOfStar, edges))

// MARK: - Solution

private func distance(_ lhs: Position, _ rhs: Position) -> Double {
    sqrt(pow(abs(lhs.x - rhs.x), 2) + pow(abs(lhs.y - rhs.y), 2))
}

private func findRoot(_ root: inout [Int], _ current: Int) -> Int {
    if current == root[current] {
        return current
    } else {
        root[current] = findRoot(&root, root[current])
        return root[current]
    }
}

private func solution(_ numberOfStar: Int, _ edges: [EdgeInfo]) -> Double {
    var answer = 0.0
    var root = Array(repeating: 0, count: numberOfStar)
    for star in 0 ..< numberOfStar {
        root[star] = star
    }
    for edge in edges {
        let lhsRoot = findRoot(&root, edge.lhs)
        let rhsRoot = findRoot(&root, edge.rhs)
        if lhsRoot == rhsRoot { continue }
        if lhsRoot < rhsRoot {
            root[rhsRoot] = lhsRoot
        } else {
            root[lhsRoot] = rhsRoot
        }
        answer += edge.cost
    }
    
    return answer
}