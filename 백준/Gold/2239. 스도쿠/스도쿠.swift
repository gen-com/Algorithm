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
var sudoku = Array(repeating: Array(repeating: 0, count: 9), count: 9)
var found = false
var answer = ""
for row in 0 ..< 9 {
    let rowValues = fileIO.readString().map { Int(String($0))! }
    for column in 0 ..< 9 {
        sudoku[row][column] = rowValues[column]
    }
}
    
// MARK: - Solution

private func isPossible(_ sudoku: [[Int]], _ row: Int, _ column: Int, _ candidate: Int) -> Bool {
    let smallRow = row / 3 * 3
    let smallColumn = column / 3 * 3
    for index in 0 ..< 9 {
        if sudoku[row][index] == candidate { return false }
        if sudoku[index][column] == candidate { return false }
        if sudoku[smallRow + index / 3][smallColumn + index % 3] == candidate { return false }
    }
    
    return true
}

private func solution(_ sudoku: inout [[Int]], _ index: Int) {
    if found { return }
    for i in index ..< 81 {
        let row = i / 9
        let column = i % 9
        
        if sudoku[row][column] == 0 {
            for candidate in 1 ... 9 {
                if isPossible(sudoku, row, column, candidate) {
                    sudoku[row][column] = candidate
                    solution(&sudoku, index + 1)
                }
            }
            sudoku[row][column] = 0
            return
        }
    }
    
    found = true
    for row in 0 ..< 9 {
        for column in 0 ..< 9 {
            answer += "\(sudoku[row][column])"
        }
        if row < 8 {
            answer += "\n"
        }
    }
}

solution(&sudoku, 0)
print(answer)