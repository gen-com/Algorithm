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
let width = fileIO.readInt()
var board = Array(repeating: Array(repeating: 0, count: width), count: width)
for row in 0 ..< width {
    for column in 0 ..< width {
        board[row][column] = fileIO.readInt()
    }
}
print(solution(&board))

// MARK: - Solution

private func backTracking(_ board: inout [[Int]], _ row: Int, _ column: Int, _ bishopCount: Int, _ maxCount: inout Int) {
    var row = row
    var column = column
    if board.count <= column {
        row += 1
        column = column % 2 == 0 ? 1 : 0
        if board.count <= row {
            return
        }
    }
    if board[row][column] == 1 {
        var possiblePosition = true
        var prevRow = row - 1
        var prevColumn = column - 1
        while 0 <= prevRow && 0 <= prevColumn {
            if 1 < board[prevRow][prevColumn] {
                possiblePosition = false
                break
            } else {
                prevRow -= 1
                prevColumn -= 1
            }
        }
        if possiblePosition {
            prevRow = row - 1
            prevColumn = column + 1
            while 0 <= prevRow && prevColumn < board.count {
                if 1 < board[prevRow][prevColumn] {
                    possiblePosition = false
                    break
                } else {
                    prevRow -= 1
                    prevColumn += 1
                }
            }
        }
        if possiblePosition {
            board[row][column] = 2
            maxCount = max(maxCount, bishopCount + 1)
            backTracking(&board, row, column + 2, bishopCount + 1, &maxCount)
            board[row][column] = 1
        }
    }
    backTracking(&board, row, column + 2, bishopCount, &maxCount)
}

private func solution(_ board: inout [[Int]]) -> Int {
    var answer = 0
    var tmp = 0
    backTracking(&board, 0, 0, 0, &tmp)
    backTracking(&board, 0, 1, 0, &answer)
    answer += tmp
    
    return answer
}