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
for row in 0 ..< mapWidth {
    for column in 0 ..< mapWidth {
        map[row][column] = fileIO.readInt()
    }
}

// MARK: - Solution

enum PipeMove {
    
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

let destination: Position = (mapWidth - 1, mapWidth - 1)
var answer = 0

func backTracking(current: Position, lastMove: PipeMove) {
    if current == destination {
        answer += 1
    } else {
        for move in PipeMove.all {
            if move == .moveHorizontally, lastMove == .moveVertically { continue }
            if move == .moveVertically, lastMove == .moveHorizontally { continue }
            let next = PipeMove.nextPosition(from: current, move)
            if 0 <= next.row, next.row < mapWidth, 0 <= next.column, next.column < mapWidth {
                if map[next.row][next.column] == 0 {
                    if move == .moveDiagonally {
                        if map[next.row][current.column] == 0, map[current.row][next.column] == 0 {
                            backTracking(current: next, lastMove: move)
                        }
                    } else {
                        backTracking(current: next, lastMove: move)
                    }
                }
            }
        }
    }
}

backTracking(current: (0, 1), lastMove: .moveHorizontally)
print(answer)