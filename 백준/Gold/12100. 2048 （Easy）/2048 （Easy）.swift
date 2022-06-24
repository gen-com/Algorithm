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
let numberOfWidth = fileIO.readInt()
var board = Array(repeating: Array(repeating: 0, count: numberOfWidth), count: numberOfWidth)
for row in 0 ..< numberOfWidth {
    for column in 0 ..< numberOfWidth {
        board[row][column] = fileIO.readInt()
    }
}

// MARK: - Solution

var answer = 0

enum Direction {
    
    case left
    case right
    case up
    case down
    
    static let all = [Direction.left, .right, .up, .down]
}

private func shift(direction: Direction, _ board: inout [[Int]]) {
    var queue: [Int] = []
    switch direction {
    case .left:
        for row in 0 ..< board.count {
            for column in 0 ..< board.count {
                if board[row][column] != 0 {
                    queue.append(board[row][column])
                    board[row][column] = 0
                }
            }
            var columnIndex = 0
            var queueIndex = 0
            while queueIndex < queue.endIndex {
                let front = queue[queueIndex]
                if board[row][columnIndex] == 0 {
                    board[row][columnIndex] = front
                } else if board[row][columnIndex] == front {
                    board[row][columnIndex] *= 2
                    columnIndex += 1
                } else {
                    columnIndex += 1
                    board[row][columnIndex] = front
                }
                queueIndex += 1
            }
            queue.removeAll()
        }
    case .right:
        for row in 0 ..< board.count {
            for column in stride(from: board.count - 1, through: 0, by: -1) {
                if board[row][column] != 0 {
                    queue.append(board[row][column])
                    board[row][column] = 0
                }
            }
            var columnIndex = board.count - 1
            var queueIndex = 0
            while queueIndex < queue.endIndex {
                let front = queue[queueIndex]
                if board[row][columnIndex] == 0 {
                    board[row][columnIndex] = front
                } else if board[row][columnIndex] == front {
                    board[row][columnIndex] *= 2
                    columnIndex -= 1
                } else {
                    columnIndex -= 1
                    board[row][columnIndex] = front
                }
                queueIndex += 1
            }
            queue.removeAll()
        }
    case .up:
        for column in 0 ..< board.count {
            for row in 0 ..< board.count {
                if board[row][column] != 0 {
                    queue.append(board[row][column])
                    board[row][column] = 0
                }
            }
            var rowIndex = 0
            var queueIndex = 0
            while queueIndex < queue.endIndex {
                let front = queue[queueIndex]
                if board[rowIndex][column] == 0 {
                    board[rowIndex][column] = front
                } else if board[rowIndex][column] == front {
                    board[rowIndex][column] *= 2
                    rowIndex += 1
                } else {
                    rowIndex += 1
                    board[rowIndex][column] = front
                }
                queueIndex += 1
            }
            queue.removeAll()
        }
    case .down:
        for column in 0 ..< board.count {
            for row in stride(from: board.count - 1, through: 0, by: -1) {
                if board[row][column] != 0 {
                    queue.append(board[row][column])
                    board[row][column] = 0
                }
            }
            var rowIndex = board.count - 1
            var queueIndex = 0
            while queueIndex < queue.endIndex {
                let front = queue[queueIndex]
                if board[rowIndex][column] == 0 {
                    board[rowIndex][column] = front
                } else if board[rowIndex][column] == front {
                    board[rowIndex][column] *= 2
                    rowIndex -= 1
                } else {
                    rowIndex -= 1
                    board[rowIndex][column] = front
                }
                queueIndex += 1
            }
            queue.removeAll()
        }
    }
}

private func backTracking(_ count: Int, _ board: inout [[Int]]) {
    if count == 5 {
        for row in 0 ..< board.count {
            for column in 0 ..< board.count {
                answer = max(answer, board[row][column])
            }
        }
        return
    }
    let copy = board
    for direction in Direction.all {
        shift(direction: direction, &board)
        backTracking(count + 1, &board)
        board = copy
    }
}

backTracking(0, &board)
print(answer)