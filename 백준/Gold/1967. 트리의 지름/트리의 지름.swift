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

typealias NodeInformation = (destination: Int, distance: Int)

let fileIO = FileIO()
let numberOfNodes = fileIO.readInt()
var edgesFor: [Int: [NodeInformation]] = [:]
for _ in 0 ..< numberOfNodes - 1 {
    let node = fileIO.readInt()
    let destination = fileIO.readInt()
    let distance = fileIO.readInt()
    
    if var edges = edgesFor[node] {
        edges.append((destination, distance))
        edgesFor[node] = edges
    } else {
        edgesFor[node] = [(destination, distance)]
    }
    if var edges = edgesFor[destination] {
        edges.append((node, distance))
        edgesFor[destination] = edges
    } else {
        edgesFor[destination] = [(node, distance)]
    }
}

// MARK: - Solution

func solution() -> Int {
    var answer = 0
    var farthestNode = 0
    var notVisited = Array(repeating: true, count: numberOfNodes + 1)
    
    func dfs(_ currentNode: Int, _ dist: Int) {
        if answer < dist {
            farthestNode = currentNode
            answer = dist
        }
        if let edges = edgesFor[currentNode] {
            for edge in edges {
                if notVisited[edge.destination] {
                    notVisited[edge.destination] = false
                    dfs(edge.destination, dist + edge.distance)
                }
            }
        }
    }
    
    notVisited[1] = false
    dfs(1, 0)
    notVisited = Array(repeating: true, count: numberOfNodes + 1)
    notVisited[farthestNode] = false
    answer = 0
    dfs(farthestNode, 0)
    
    return answer
}
print(solution())