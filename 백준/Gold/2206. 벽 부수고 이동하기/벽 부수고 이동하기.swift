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

typealias NodeInformation = (destination: Int, distance: Int)

let fileIO = FileIO()
let rows = fileIO.readInt()
let columns = fileIO.readInt()
var map = Array(repeating: Array(repeating: 0, count: columns), count: rows)
for row in 0 ..< rows {
    let rowArray = fileIO.readString().map { Int(String($0))! }
    for column in 0 ..< columns {
        map[row][column] = rowArray[column]
    }
}

// MARK: - Solution

var answer = -1
let moveX = [0, -1, 0, 1]
let moveY = [1, 0, -1, 0]
var notVisited = Array(repeating: Array(repeating: Array(repeating: true, count: 2), count: columns), count: rows)
var queue = [(row: 0, column: 0, pass: 0, distance: 1)]
var currentIndex = 0

while currentIndex < queue.endIndex {
    let front = queue[currentIndex]
    for moveIndex in moveX.indices {
        var next = (row: front.row + moveX[moveIndex], column: front.column + moveY[moveIndex], pass: front.pass, distance: front.distance + 1)
        if next.row == rows - 1, next.column == columns - 1 {
            answer = next.distance
            break
        }
        if 0 <= next.row, next.row < rows, 0 <= next.column, next.column < columns, notVisited[next.row][next.column][next.pass] {
            if next.pass == 0, map[next.row][next.column] == 1 {
                next.pass = 1
                notVisited[next.row][next.column][next.pass] = false
                queue.append(next)
            } else if map[next.row][next.column] == 0 {
                notVisited[next.row][next.column][next.pass] = false
                queue.append(next)
            }
        }
    }
    if answer != -1 { break }
    currentIndex += 1
}
if rows == 1, columns == 1 {
    print(1)
} else {
    print(answer)
}