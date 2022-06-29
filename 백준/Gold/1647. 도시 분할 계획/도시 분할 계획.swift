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

typealias RoadInfo = (lhs: Int, rhs: Int, cost: Int)

let fileIO = FileIO()
let numberOfHouse = fileIO.readInt()
let numberOfRoad = fileIO.readInt()
var roads: [RoadInfo] = []
for _ in 0 ..< numberOfRoad {
    roads.append((fileIO.readInt(), fileIO.readInt(), fileIO.readInt()))
}
roads.sort { $0.cost < $1.cost }
print(solution(numberOfHouse, roads))

// MARK: - Solution

private func findRoot(for house: Int, _ root: inout [Int]) -> Int {
    if house == root[house] {
        return house
    } else {
        root[house] = findRoot(for: root[house], &root)
        return root[house]
    }
}

private func solution(_ numberOfHouse: Int, _ roads: [RoadInfo]) -> Int {
    var cost = 0
    var maxCost = 0
    var root = Array(repeating: 0, count: numberOfHouse + 1)
    for house in 1 ... numberOfHouse {
        root[house] = house
    }
    for road in roads {
        let lhsRoot = findRoot(for: road.lhs, &root)
        let rhsRoot = findRoot(for: road.rhs, &root)
        if lhsRoot == rhsRoot {
            continue
        } else {
            if lhsRoot < rhsRoot {
                root[rhsRoot] = lhsRoot
            } else {
                root[lhsRoot] = rhsRoot
            }
            maxCost = max(maxCost, road.cost)
            cost += road.cost
        }
    }
    
    return cost - maxCost
}