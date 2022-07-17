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

typealias Position = (index: Int, x: Int, y: Int, z: Int)
typealias Tunnel = (lhs: Int, rhs: Int, cost: Int)

let fileIO = FileIO()
let numberOfPlanet = fileIO.readInt()
var planets = Array(repeating: Position(0, 0, 0, 0), count: numberOfPlanet)
for index in 0 ..< numberOfPlanet {
    planets[index] = (index, fileIO.readInt(), fileIO.readInt(), fileIO.readInt())
}
print(solution(numberOfPlanet, planets))

// MARK: - Solutions

private func cost(_ lhs: Position, _ rhs: Position) -> Int {
    min(abs(lhs.x - rhs.x), abs(lhs.y - rhs.y), abs(lhs.z - rhs.z))
}

private func findRoot(_ roots: inout [Int], _ current: Int) -> Int {
    if current == roots[current] {
        return current
    }
    roots[current] = findRoot(&roots, roots[current])
    return roots[current]
}

private func solution(_ numberOfPlanet: Int, _ planets: [Position]) -> Int {
    var answer = 0
    var tunnels: [Tunnel] = []
    let xSortedPlanets = planets.sorted { $0.x < $1.x }
    for index in 0 ..< xSortedPlanets.count - 1 {
        tunnels.append((xSortedPlanets[index].index, xSortedPlanets[index + 1].index, cost(xSortedPlanets[index], xSortedPlanets[index + 1])))
    }
    let ySortedPlanets = planets.sorted { $0.y < $1.y }
    for index in 0 ..< ySortedPlanets.count - 1 {
        tunnels.append((ySortedPlanets[index].index, ySortedPlanets[index + 1].index, cost(ySortedPlanets[index], ySortedPlanets[index + 1])))
    }
    let zSortedPlanets = planets.sorted { $0.z < $1.z }
    for index in 0 ..< zSortedPlanets.count - 1 {
        tunnels.append((zSortedPlanets[index].index, zSortedPlanets[index + 1].index, cost(zSortedPlanets[index], zSortedPlanets[index + 1])))
    }
    tunnels.sort { $0.cost < $1.cost }
    var roots = Array(repeating: 0, count: numberOfPlanet)
    for index in roots.indices { roots[index] = index }
    for tunnel in tunnels {
        let lhsRoot = findRoot(&roots, tunnel.lhs)
        let rhsRoot = findRoot(&roots, tunnel.rhs)
        if lhsRoot == rhsRoot { continue }
        answer += tunnel.cost
        if lhsRoot < rhsRoot {
            roots[rhsRoot] = lhsRoot
        } else {
            roots[lhsRoot] = rhsRoot
        }
    }
    
    return answer
}