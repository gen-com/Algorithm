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
let rows = fileIO.readInt()
let columns = fileIO.readInt()
var map = Array(repeating: Array(repeating: 0, count: columns), count: rows)
for row in 0 ..< rows {
    for column in 0 ..< columns {
        map[row][column] = fileIO.readInt()
    }
}

// MARK: - Solution

let candidates = [[(1, 0), (2, 0), (3, 0)], [(0, 1), (0, 2), (0, 3)], [(1, 0), (0, 1), (1, 1)], [(0, 1), (0, 2), (1, 2)],
                  [(-1, 0), (-2, 0), (-2, 1)], [(0, -1), (0, -2), (-1, -2)], [(1, 0), (2, 0), (2, -1)], [(0, 1), (0, 2), (-1, 2)],
                  [(-1, 0), (-2, 0), (-2, -1)], [(0, -1), (0, -2), (1, -2)], [(1, 0), (2, 0), (2, 1)], [(0, 1), (1, 1), (1, 2)],
                  [(-1, 0), (-1, 1), (-2, 1)], [(0, 1), (-1, 1), (-1, 2)], [(-1, 0), (-1, -1), (-2, -1)], [(1, 0), (2, 0), (1, -1)],
                  [(0, 1), (0, 2), (1, 1)], [(-1, 0), (-2, 0), (-1, 1)], [(0, -1), (0, -2), (-1, -1)]]

var answer = 0
for row in 0 ..< rows {
    for column in 0 ..< columns {
        var sum = 0
        var impossible = false
        for candidate in candidates {
            sum = map[row][column]
            impossible = false
            for next in candidate {
                if 0 <= row + next.0, row + next.0 < rows, 0 <= column + next.1, column + next.1 < columns {
                    sum += map[row + next.0][column + next.1]
                } else {
                    impossible = true
                    break
                }
            }
            if impossible == false {
                answer = max(answer, sum)
            }
        }
    }
}
print(answer)