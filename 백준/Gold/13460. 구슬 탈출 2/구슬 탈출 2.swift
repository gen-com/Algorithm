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
let numberOfRow = fileIO.readInt()
let numberOfColumn = fileIO.readInt()
var board = Array(repeating: Array(repeating: "", count: numberOfColumn), count: numberOfRow)
var redBall: Position = (0, 0)
var blueBall: Position = (0, 0)
for row in 0 ..< numberOfRow {
    let rows = fileIO.readString().map { String($0) }
    for column in 0 ..< numberOfColumn {
        if rows[column] == "R" {
            redBall = (row, column)
            board[row][column] = "."
        } else if rows[column] == "B" {
            blueBall = (row, column)
            board[row][column] = "."
        } else {
            board[row][column] = rows[column]
        }
    }
}
print(solution(board, numberOfRow, numberOfColumn, redBall, blueBall))

// MARK: - Solution

private func solution(_ board: [[String]], _ numberOfRow: Int, _ numberOfColumn: Int, _ redBall: Position, _ blueBall: Position) -> Int {
    let moves: [Position] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    var visited = Array(repeating: Array(repeating: Array(repeating: Array(repeating: false, count: numberOfColumn), count: numberOfRow), count: numberOfColumn), count: numberOfRow)
    var queue: [(red: Position, blue: Position, count: Int)] = [(redBall, blueBall, 0)]
    var currentQueueIndex = 0
    visited[redBall.row][redBall.column][blueBall.row][blueBall.column] = false
    while currentQueueIndex < queue.endIndex {
        let front = queue[currentQueueIndex]
        if 10 <= front.count { break }
        for move in moves {
            var nextRed = front.red
            while board[nextRed.row][nextRed.column] != "#" && board[nextRed.row][nextRed.column] != "O" {
                nextRed = (nextRed.row + move.row, nextRed.column + move.column)
            }
            if board[nextRed.row][nextRed.column] == "#" {
                nextRed.row += (-1 * move.row)
                nextRed.column += (-1 * move.column)
            }
            var nextBlue = front.blue
            while board[nextBlue.row][nextBlue.column] != "#" && board[nextBlue.row][nextBlue.column] != "O" {
                nextBlue = (nextBlue.row + move.row, nextBlue.column + move.column)
            }
            if board[nextBlue.row][nextBlue.column] == "#" {
                nextBlue.row += (-1 * move.row)
                nextBlue.column += (-1 * move.column)
            }
            
            if board[nextRed.row][nextRed.column] == "O" {
                if board[nextBlue.row][nextBlue.column] == "O" {
                    continue
                } else {
                    return front.count + 1
                }
            }
            
            if nextRed == nextBlue {
                if move == (0, 1) {
                    if front.red.column < front.blue.column {
                        nextRed.column -= 1
                    } else {
                        nextBlue.column -= 1
                    }
                } else if move == (0, -1) {
                    if front.red.column < front.blue.column {
                        nextBlue.column += 1
                    } else {
                        nextRed.column += 1
                    }
                } else if move == (1, 0) {
                    if front.red.row < front.blue.row {
                        nextRed.row -= 1
                    } else {
                        nextBlue.row -= 1
                    }
                } else {
                    if front.red.row < front.blue.row {
                        nextBlue.row += 1
                    } else {
                        nextRed.row += 1
                    }
                }
            }
            
            if visited[nextRed.row][nextRed.column][nextBlue.row][nextBlue.column] { continue }
            queue.append((nextRed, nextBlue, front.count + 1))
            visited[nextRed.row][nextRed.column][nextBlue.row][nextBlue.column] = true
        }
        currentQueueIndex += 1
    }
    
    return -1
}