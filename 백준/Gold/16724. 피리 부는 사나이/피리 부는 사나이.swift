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
let numberOfRow = fileIO.readInt()
let numberOfColumn = fileIO.readInt()
var map = Array(repeating: Array(repeating: "", count: numberOfColumn), count: numberOfRow)
for row in 0 ..< numberOfRow {
    let rows = fileIO.readString().map{ String($0) }
    for column in 0 ..< numberOfColumn {
        map[row][column] = rows[column]
    }
}
print(solution(numberOfRow, numberOfColumn, map))

// MARK: - Solution

struct Position: Hashable {
    
    let row: Int
    let column: Int
}

enum Direction: String {
    
    case U
    case L
    case D
    case R
    
    static func move(_ input: String) -> Position {
        switch Direction(rawValue: input) {
        case .U: return Position(row: -1, column: 0)
        case .L: return Position(row: 0, column: -1)
        case .D: return Position(row: 1, column: 0)
        case .R: return Position(row: 0, column: 1)
        case .none: return Position(row: 0, column: 0)
        }
    }
}

private func dfs(_ map: [[String]], _ visitSet: inout Set<Position>, _ current: Position, _ reachable: inout [[Bool]], _ answer: inout Int) {
    if reachable[current.row][current.column] {
        if visitSet.contains(current) {
            answer += 1
        }
        return
    }
    visitSet.insert(current)
    reachable[current.row][current.column] = true
    let nextMove = Direction.move(map[current.row][current.column])
    let next = Position(row: current.row + nextMove.row, column: current.column + nextMove.column)
    dfs(map, &visitSet, next, &reachable, &answer)
}

private func solution(_ numberOfRow: Int, _ numberOfColumn: Int, _ map: [[String]]) -> Int {
    var answer = 0
    var reachable = Array(repeating: Array(repeating: false, count: numberOfColumn), count: numberOfRow)
    for row in 0 ..< numberOfRow {
        for column in 0 ..< numberOfColumn {
            var visitSet: Set<Position> = []
            if reachable[row][column] { continue }
            dfs(map, &visitSet, Position(row: row, column: column), &reachable, &answer)
        }
    }
    
    return answer
}