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
let testcase = fileIO.readInt()
var answer = ""
for _ in 0 ..< testcase {
    let numberOfRow = fileIO.readInt()
    let numberOfColumn = fileIO.readInt()
    var map = Array(repeating: Array(repeating: ".", count: numberOfColumn + 2), count: numberOfRow + 2)
    for row in 1 ... numberOfRow {
        let rows = fileIO.readString().map { String($0) }
        for column in 1 ... numberOfColumn {
            map[row][column] = rows[column - 1]
        }
    }
    var currentKeys = Set<String>()
    fileIO.readString().forEach { currentKeys.insert(String($0)) }
    answer += "\(solution(numberOfRow, numberOfColumn, &map, &currentKeys))\n"
}
print(answer)

// MARK: - Solution

typealias Position = (row: Int, column: Int)

private func solution(_ numberOfRow: Int, _ numberOfColumn: Int, _ map: inout [[String]], _ currentKeys: inout Set<String>) -> Int {
    let moves: [(row: Int, column: Int)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    var answer = 0
    var visited = Array(repeating: Array(repeating: false, count: numberOfColumn + 2), count: numberOfRow + 2)
    var queue: [Position] = [(0, 0)]
    var currentQueueIndex = 0
    visited[0][0] = true
    while currentQueueIndex < queue.endIndex {
        let front = queue[currentQueueIndex]
        for move in moves {
            let next: Position = (front.row + move.row, front.column + move.column)
            if next.row < 0 || numberOfRow + 1 < next.row || next.column < 0 || numberOfColumn + 1 < next.column { continue }
            if map[next.row][next.column] == "*" { continue }
            if visited[next.row][next.column] { continue }
            if Character(map[next.row][next.column]).isLetter {
                if Character(map[next.row][next.column]).isUppercase{
                    if currentKeys.contains(map[next.row][next.column].lowercased()) {
                        queue.append(next)
                        visited[next.row][next.column] = true
                    } else {
                        continue
                    }
                } else {
                    if currentKeys.contains(map[next.row][next.column]) == false {
                        currentKeys.insert(map[next.row][next.column])
                        queue.append(next)
                        visited = Array(repeating: Array(repeating: false, count: numberOfColumn + 2), count: numberOfRow + 2)
                        visited[next.row][next.column] = true
                    }
                }
            }
            if map[next.row][next.column] == "$" {
                map[next.row][next.column] = "."
                answer += 1
            }
            queue.append(next)
            visited[next.row][next.column] = true
        }
        currentQueueIndex += 1
    }
    
    return answer
}