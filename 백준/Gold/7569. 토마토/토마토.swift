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
let columns = fileIO.readInt()
let rows = fileIO.readInt()
let heights = fileIO.readInt()
var tomatoBox = Array(repeating: Array(repeating: Array(repeating: 0, count: columns), count: rows), count: heights)
var visitied = Array(repeating: Array(repeating: Array(repeating: false, count: columns), count: rows), count: heights)
var queue: [(height: Int, row: Int, column: Int, day: Int)] = []
for height in 0 ..< heights {
    for row in 0 ..< rows {
        for column in 0 ..< columns {
            let input = fileIO.readInt()
            tomatoBox[height][row][column] = input
            switch input {
            case 1:
                queue.append((height, row, column, 0))
                visitied[height][row][column] = true
            case -1:
                visitied[height][row][column] = true
            default: break
            }
        }
    }
}

// MARK: - Solution

let moveX = [1, 0, -1, 0, 0, 0]
let moveY = [0, 1, 0, -1, 0, 0]
let moveZ = [0, 0, 0, 0, 1, -1]

var current = 0
var answer = 0
while current < queue.count {
    let front = queue[current]
    current += 1
    for index in moveX.indices {
        let next = (
            height: front.height + moveZ[index],
            row: front.row + moveX[index],
            column: front.column + moveY[index],
            day: front.day + 1
        )
        if 0 <= next.height, next.height < heights, 0 <= next.row, next.row < rows, 0 <= next.column, next.column < columns,
           visitied[next.height][next.row][next.column] == false {
            queue.append(next)
            answer = max(answer, next.day)
            visitied[next.height][next.row][next.column] = true
        }
    }
}
for height in 0 ..< heights {
    for row in 0 ..< rows {
        for column in 0 ..< columns {
            if visitied[height][row][column] == false {
                answer = -1
                break
            }
        }
        if answer == -1 { break }
    }
    if answer == -1 { break }
}
print(answer)