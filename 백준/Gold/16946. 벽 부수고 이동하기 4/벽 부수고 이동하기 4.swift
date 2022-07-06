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
let numberOfRow = fileIO.readInt()
let numberOfColumn = fileIO.readInt()
var map = Array(repeating: Array(repeating: 0, count: numberOfColumn), count: numberOfRow)
for row in 0 ..< numberOfRow {
    let rows = fileIO.readString().map { Int(String($0))! }
    for column in 0 ..< numberOfColumn {
        map[row][column] = rows[column]
    }
}
print(solution(map, numberOfRow, numberOfColumn))

// MARK: - Solution

typealias Position = (row: Int, column: Int)

private func solution(_ map: [[Int]], _ numberOfRow: Int, _ numberOfColumn: Int) -> String {
    var answer = ""
    var dpMap = Array(repeating: Array(repeating: (id: 0, count: 0), count: numberOfColumn), count: numberOfRow)
    var idGenerator = 1
    let moves: [Position] = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    for row in 0 ..< numberOfRow {
        for column in 0 ..< numberOfColumn {
            if map[row][column] == 0, dpMap[row][column].id == 0 {
                var queue: [Position] = [(row, column)]
                var current = 0
                dpMap[row][column].id = idGenerator
                while current < queue.endIndex {
                    let front = queue[current]
                    for move in moves {
                        let next: Position = (front.row + move.row, front.column + move.column)
                        if next.row < 0 || numberOfRow <= next.row || next.column < 0 || numberOfColumn <= next.column { continue }
                        if 0 < map[next.row][next.column] || 0 < dpMap[next.row][next.column].id { continue }
                        dpMap[next.row][next.column].id = idGenerator
                        queue.append(next)
                    }
                    current += 1
                }
                for position in queue {
                    dpMap[position.row][position.column].count = queue.count % 10
                }
                idGenerator += 1
            }
        }
    }
    
    for row in 0 ..< numberOfRow {
        for column in 0 ..< numberOfColumn {
            if map[row][column] == 1 {
                var tmp = 1
                var idSet = Set<Int>()
                for move in moves {
                    let next: Position = (row + move.row, column + move.column)
                    if next.row < 0 || numberOfRow <= next.row || next.column < 0 || numberOfColumn <= next.column { continue }
                    if idSet.contains(dpMap[next.row][next.column].id) { continue }
                    idSet.insert(dpMap[next.row][next.column].id)
                    tmp += dpMap[next.row][next.column].count
                }
                answer += "\(tmp % 10)"
            } else {
                answer += "0"
            }
        }
        answer += "\n"
    }
    let _ = answer.popLast()
    
    return answer
}