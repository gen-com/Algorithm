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
let numberOfCity = fileIO.readInt()
var costFor = Array(repeating: [Int](), count: numberOfCity)
for city in 0 ..< numberOfCity {
    for _ in 0 ..< numberOfCity {
        costFor[city].append(fileIO.readInt())
    }
}
print(solution(numberOfCity, costFor))

// MARK: - Solution

private func tsp(_ currentCity: Int, _ currentBit: Int, _ costFor: [[Int]], _ cost: inout [[Int]]) -> Int {
    if currentBit == ((1 << costFor.count) - 1) {
        return costFor[currentCity][0] == 0 ? Int.max : costFor[currentCity][0]
    }
    if cost[currentCity][currentBit] != 0 {
        return cost[currentCity][currentBit]
    }
    cost[currentCity][currentBit] = Int.max
    for next in costFor[currentCity].indices {
        if costFor[currentCity][next] == 0 { continue }
        if 0 < currentBit & (1 << next) { continue }
        let nextBit = currentBit | (1 << next)
        let candidate = tsp(next, nextBit, costFor, &cost)
        if candidate != Int.max {
            cost[currentCity][currentBit] = min(cost[currentCity][currentBit], candidate + costFor[currentCity][next])
        }
    }
    
    return cost[currentCity][currentBit]
}

private func solution(_ numberOfCity: Int, _ edgeFor: [[Int]]) -> Int {
    var cost = Array(repeating: Array(repeating: 0, count: (1 << numberOfCity)), count: numberOfCity)
    
    return tsp(0, 1, edgeFor, &cost)
}