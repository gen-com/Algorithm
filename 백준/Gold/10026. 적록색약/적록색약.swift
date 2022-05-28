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
var pixels = Array(repeating: Array(repeating: "", count: width), count: width)
var visitied = Array(repeating: Array(repeating: false, count: width), count: width)
var queue: [(row: Int, column: Int)] = []
for row in 0 ..< width {
    let rowString = fileIO.readString().map { String($0) }
    for column in 0 ..< width {
        pixels[row][column] = rowString[column]
    }
}

// MARK: - Solution

let moveX = [1, 0, -1, 0,]
let moveY = [0, 1, 0, -1]

var current = 0
var normal = 0
var redGreenColorWeakness = 0

for row in 0 ..< width {
    for col in 0 ..< width {
        if visitied[row][col] == false {
            normal += 1
            queue.append((row, col))
            while current < queue.count {
                let front = queue[current]
                current += 1
                for index in moveX.indices {
                    let next = (row: front.row + moveX[index], column: front.column + moveY[index])
                    if 0 <= next.row, next.row < width, 0 <= next.column, next.column < width, visitied[next.row][next.column] == false,
                        pixels[next.row][next.column] == pixels[front.row][front.column] {
                        queue.append(next)
                        visitied[next.row][next.column] = true
                    }
                }
            }
        }
    }
}

visitied = Array(repeating: Array(repeating: false, count: width), count: width)
for row in 0 ..< width {
    for col in 0 ..< width {
        if visitied[row][col] == false {
            redGreenColorWeakness += 1
            queue.append((row, col))
            while current < queue.count {
                let front = queue[current]
                current += 1
                for index in moveX.indices {
                    let next = (row: front.row + moveX[index], column: front.column + moveY[index])
                    if 0 <= next.row, next.row < width, 0 <= next.column, next.column < width, visitied[next.row][next.column] == false,
                       ((pixels[front.row][front.column] == "B" && pixels[next.row][next.column] == "B") ||
                        (pixels[front.row][front.column] != "B" && pixels[next.row][next.column] != "B")) {
                        queue.append(next)
                        visitied[next.row][next.column] = true
                    }
                }
            }
        }
    }
}
print("\(normal) \(redGreenColorWeakness)")