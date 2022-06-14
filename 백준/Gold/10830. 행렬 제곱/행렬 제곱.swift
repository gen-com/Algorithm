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
var n = fileIO.readInt()
var square = fileIO.readInt()
var matrix = Array(repeating: Array(repeating: 0, count: n), count: n)
for row in 0 ..< n {
    for column in 0 ..< n {
        matrix[row][column] = fileIO.readInt()
    }
}

// MARK: - Solution

func multiple(_ matrix_01: [[Int]], _ matrix_02: [[Int]], _ n: Int) -> [[Int]] {
    var result: [[Int]] = Array(repeating: Array(repeating: 0, count: n), count: n)
    for i in 0 ..< n {
        for j in 0 ..< n {
            for k in 0 ..< n {
                result[i][j] += matrix_01[i][k] * matrix_02[k][j]
                result[i][j] %= 1000
            }
        }
    }

    return result
}

func printMatrix(_ matrix: [[Int]], _ n: Int) {
    for i in 0 ..< n {
        var line: String = ""
        for j in 0 ..< n {
            line += "\(matrix[i][j] % 1000) "
        }
        print(line)
    }
}

var odd: [[Int]] = []
while 1 < square {
    if square % 2 == 1 {
        if odd.isEmpty {
            odd = matrix
        } else {
            odd = multiple(matrix, odd, n)
        }
    }
    matrix = multiple(matrix, matrix, n)
    square /= 2
}

if odd.isEmpty {
    printMatrix(matrix, n)
} else {
    matrix = multiple(matrix, odd, n)
    printMatrix(matrix, n)
}