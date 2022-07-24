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
var rowCheck = Array(repeating: Array(repeating: false, count: 10), count: 9)
var columnCheck = Array(repeating: Array(repeating: false, count: 10), count: 9)
var squareCheck = Array(repeating: Array(repeating: false, count: 10), count: 9)
for row in 0 ..< 9 {
    for column in 0 ..< 9 {
        sudoku[row][column] = fileIO.readInt()
        rowCheck[row][sudoku[row][column]] = true
        columnCheck[column][sudoku[row][column]] = true
        squareCheck[square(row, column)][sudoku[row][column]] = true
    }
}

// MARK: - Solution

private func square(_ row: Int, _ column: Int) -> Int {
    (row / 3) * 3 + (column / 3)
}

@discardableResult
private func backTracking(for elementIndex: Int) -> Bool {
    if elementIndex < 81 {
        let row = elementIndex / 9
        let column = elementIndex % 9
        if sudoku[row][column] == 0 {
            for number in 1 ... 9 {
                if !rowCheck[row][number], !columnCheck[column][number], !squareCheck[square(row, column)][number] {
                    rowCheck[row][number] = true
                    columnCheck[column][number] = true
                    squareCheck[square(row, column)][number] = true
                    sudoku[row][column] = number
                    if backTracking(for: elementIndex + 1) {
                        return true
                    }
                    rowCheck[row][number] = false
                    columnCheck[column][number] = false
                    squareCheck[square(row, column)][number] = false
                    sudoku[row][column] = 0
                }
            }
        } else {
            return backTracking(for: elementIndex + 1)
        }
    } else if elementIndex == 81 {
        var result = ""
        for row in 0 ..< 9 {
            for column in 0 ..< 9 {
                result += "\(sudoku[row][column])"
                if column < 8 {
                    result += " "
                }
            }
            if row < 8 {
                result += "\n"
            }
        }
        print(result)
        return true
    }
    return false
}
backTracking(for: 0)