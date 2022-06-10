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

typealias Position = (row: Int, column: Int)

let fileIO = FileIO()
let mapWidth = fileIO.readInt()
var map = Array(repeating: Array(repeating: 0, count: mapWidth), count: mapWidth)
var dpMap = Array(repeating: Array(repeating: Array(repeating: 0, count: PipeMove.all.count), count: mapWidth), count: mapWidth)
for row in 0 ..< mapWidth {
    for column in 0 ..< mapWidth {
        map[row][column] = fileIO.readInt()
    }
}

// MARK: - Solution

enum PipeMove: Int {
    
    case moveHorizontally
    case moveVertically
    case moveDiagonally
    
    static func nextPosition(from current: Position, _ move: PipeMove) -> Position {
        switch move {
        case .moveHorizontally:
            return (current.row, current.column + 1)
        case .moveVertically:
            return (current.row + 1, current.column)
        case .moveDiagonally:
            return (current.row + 1, current.column + 1)
        }
    }
    
    static let all = [PipeMove.moveHorizontally, .moveVertically, .moveDiagonally]
}

var answer = 0
let destination: Position = (mapWidth - 1, mapWidth - 1)
dpMap[0][1][0] = 1

for i in 0 ..< mapWidth {
    for j in 2 ..< mapWidth {
        if map[i][j] == 0 {
            dpMap[i][j][0] = dpMap[i][j - 1][0] + dpMap[i][j - 1][2]
            if 0 < i {
                dpMap[i][j][1] = dpMap[i - 1][j][1] + dpMap[i - 1][j][2]
                if map[i - 1][j] == 0, map[i][j - 1] == 0 {
                    dpMap[i][j][2] = dpMap[i - 1][j - 1][0] + dpMap[i - 1][j - 1][1] + dpMap[i - 1][j - 1][2]
                }
            }
        }
    }
}

for move in 0 ..< PipeMove.all.count {
    answer += dpMap[destination.row][destination.column][move]
}
print(answer)