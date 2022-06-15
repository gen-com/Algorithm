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
let numberOfArea = fileIO.readInt()
let affordableBoundaries = fileIO.readInt()
let numberOfEdge = fileIO.readInt()

var dist = Array(repeating: Array(repeating: Int.max, count: numberOfArea + 1), count: numberOfArea + 1)
var itemsForArea = Array(repeating: 0, count: numberOfArea + 1)
for area in 1 ... numberOfArea {
    itemsForArea[area] = fileIO.readInt()
    dist[area][area] = 0
}
for _ in 0 ..< numberOfEdge {
    let lhs = fileIO.readInt()
    let rhs = fileIO.readInt()
    let distance = fileIO.readInt()
    dist[lhs][rhs] = distance
    dist[rhs][lhs] = distance
}

// MARK: - Solution

for passThrough in 1 ... numberOfArea {
    for startingPoint in 1 ... numberOfArea {
        for destination in 1 ... numberOfArea {
            if dist[startingPoint][passThrough] != Int.max, dist[passThrough][destination] != Int.max,
               dist[startingPoint][passThrough] + dist[passThrough][destination] < dist[startingPoint][destination] {
                dist[startingPoint][destination] = dist[startingPoint][passThrough] + dist[passThrough][destination]
            }
        }
    }
}

var answer = 0
for row in 1 ... numberOfArea {
    var candidate = 0
    for column in 1 ... numberOfArea {
        if dist[row][column] <= affordableBoundaries {
            candidate += itemsForArea[column]
        }
    }
    answer = max(answer, candidate)
}
print(answer)