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
var board = Array(repeating: Array(repeating: 0, count: numberOfColumn), count: numberOfRow)
let alphabetPool = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
for row in 0 ..< numberOfRow {
    let rows = fileIO.readString().map { alphabetPool.firstIndex(of: String($0))! }
    for column in 0 ..< numberOfColumn {
        board[row][column] = rows[column]
    }
}
print(solution(board))

// MARK: - Solution

typealias Position = (row: Int, column: Int)

private func backTracking(_ board: [[Int]], _ current: Position, _ currentSet: inout [Bool], _ count: Int, _ answer: inout Int) {
    let moves: [Position] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    for move in moves {
        let next: Position = (current.row + move.row, current.column + move.column)
        if next.row < 0 || board.count <= next.row || next.column < 0 || board[0].count <= next.column { continue }
        if currentSet[board[next.row][next.column]] { continue }
        currentSet[board[next.row][next.column]] = true
        answer = max(answer, count + 1)
        backTracking(board, next, &currentSet, count + 1, &answer)
        currentSet[board[next.row][next.column]] = false
    }
}

private func solution(_ board: [[Int]]) -> Int {
    var answer = 1
    var alphabet = Array(repeating: false, count: 26)
    alphabet[board[0][0]] = true
    backTracking(board, (0, 0), &alphabet, 1, &answer)
    
    return answer
}