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

typealias Card = (value: Int, used: Bool)

let fileIO = FileIO()
var bulbs = Array(repeating: Array(repeating: false, count: 10), count: 10)
for row in 0 ..< 10 {
    let rows = fileIO.readString().map { String($0) }
    for column in 0 ..< 10 {
        bulbs[row][column] = (rows[column] == "O")
    }
}
let moves: [(row: Int, column: Int)] = [(0, 1), (1, 0), (-1, 0), (0, -1)]
print(solution(bulbs))

// MARK: - Solutions

private func solution(_ bulbs: [[Bool]]) -> Int {
    var answer = 101
    for bit in 0 ..< (1 << 10) {
        var count = 0
        var tmpBulbs = bulbs
        for column in 0 ..< 10 {
            if 0 < bit & (1 << column) {
                tmpBulbs[0][column].toggle()
                count += 1
                for move in moves {
                    let near = (row: 0 + move.row, column: column + move.column)
                    if near.row < 0 || 9 < near.row || near.column < 0 || 9 < near.column { continue }
                    tmpBulbs[near.row][near.column].toggle()
                }
            }
        }
        for row in 1 ..< 10 {
            for column in 0 ..< 10 {
                if tmpBulbs[row - 1][column] {
                    tmpBulbs[row][column].toggle()
                    count += 1
                    for move in moves {
                        let near = (row: row + move.row, column: column + move.column)
                        if near.row < 0 || 9 < near.row || near.column < 0 || 9 < near.column { continue }
                        tmpBulbs[near.row][near.column].toggle()
                    }
                }
            }
        }
        var isLightOn = false
        for row in 0 ..< 10 {
            for column in 0 ..< 10 {
                if tmpBulbs[row][column] {
                    isLightOn = true
                    break
                }
            }
            if isLightOn { break }
        }
        if isLightOn { continue }
        answer = min(answer, count)
    }
    
    return 100 < answer ? -1 : answer
}