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
}

// MARK: - Input

let fileIO = FileIO()
let n = fileIO.readInt()
let m = fileIO.readInt()
var maze = Array(repeating: Array(repeating: 0, count: m), count: n)
var visited = Array(repeating: Array(repeating: false, count: m), count: n)
for row in 0 ..< n {
    let rowStrings = fileIO.readString().map { Int(String($0))! }
    for column in 0 ..< m {
        maze[row][column] = rowStrings[column]
    }
}

// MARK: - BFS

var queue: [(row: Int, column: Int, step: Int)] = [(0, 0, 1)]
visited[0][0] = true
var currentIndex = 0
let moveX = [0, 1, 0, -1]
let moveY = [1, 0, -1, 0]
var arrived = false
while currentIndex < queue.count {
    let front = queue[currentIndex]
    for index in 0 ..< 4 {
        let next = (row: front.row + moveX[index], column: front.column + moveY[index], step: front.step + 1)
        if 0 <= next.row, next.row < n, 0 <= next.column, next.column < m,
           maze[next.row][next.column] == 1, visited[next.row][next.column] == false {
            if next.row == n - 1, next.column == m - 1 {
                arrived = true
                print(next.step)
                break
            }
            queue.append(next)
            visited[next.row][next.column] = true
        }
    }
    if arrived {
        break
    }
    currentIndex += 1
}