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
let targetTime = fileIO.readInt()
var room = Array(repeating: Array(repeating: 0, count: numberOfColumn), count: numberOfRow)
var airCleaner: [(row: Int, column: Int)] = []
for row in 0 ..< numberOfRow {
    for column in 0 ..< numberOfColumn {
        let input = fileIO.readInt()
        room[row][column] = input
        if input == -1 {
            airCleaner.append((row, column))
        }
    }
}

// MARK: - Solution

let moves: [(row: Int, column: Int)] = [(1, 0), (-1, 0), (0, 1), (0, -1)]

func cleanAir() {
    var prev = 0
    var tmp = 0
    for column in 1 ..< numberOfColumn {
        tmp = room[airCleaner[0].row][column]
        room[airCleaner[0].row][column] = prev
        prev = tmp
    }
    if 0 < airCleaner[0].row {
        for row in stride(from: airCleaner[0].row - 1, through: 0, by: -1) {
            tmp = room[row][numberOfColumn - 1]
            room[row][numberOfColumn - 1] = prev
            prev = tmp
        }
        for column in stride(from: numberOfColumn - 2, through: 0, by: -1) {
            tmp = room[0][column]
            room[0][column] = prev
            prev = tmp
        }
    }
    if 1 < airCleaner[0].row {
        for row in 1 ... airCleaner[0].row - 1 {
            tmp = room[row][airCleaner[0].column]
            room[row][airCleaner[0].column] = prev
            prev = tmp
        }
    }

    prev = 0
    tmp = 0
    for column in 1 ..< numberOfColumn {
        tmp = room[airCleaner[1].row][column]
        room[airCleaner[1].row][column] = prev
        prev = tmp
    }
    for row in airCleaner[1].row + 1 ..< numberOfRow {
        tmp = room[row][numberOfColumn - 1]
        room[row][numberOfColumn - 1] = prev
        prev = tmp
    }
    for column in stride(from: numberOfColumn - 2, through: 0, by: -1) {
        tmp = room[numberOfRow - 1][column]
        room[numberOfRow - 1][column] = prev
        prev = tmp
    }
    for row in stride(from: numberOfRow - 2, to: airCleaner[1].row, by: -1) {
        tmp = room[row][airCleaner[1].column]
        room[row][airCleaner[1].column] = prev
        prev = tmp
    }
}

func countDust() -> Int {
    var sum = 2
    for row in 0 ..< numberOfRow {
        for column in 0 ..< numberOfColumn {
            sum += room[row][column]
        }
    }
    
    return sum
}

for _ in 0 ..< targetTime {
    var nextRoom = Array(repeating: Array(repeating: 0, count: numberOfColumn), count: numberOfRow)
    for row in 0 ..< numberOfRow {
        for column in 0 ..< numberOfColumn {
            if 0 < room[row][column] {
                let front = (row: row, column: column)
                let diffusion = room[front.row][front.column] / 5
                var diffusionCount = 0
                for move in moves {
                    let next = (row: front.row + move.row, column: front.column + move.column)
                    if 0 <= next.row, next.row < numberOfRow, 0 <= next.column,
                        next.column < numberOfColumn, room[next.row][next.column] != -1 {
                        diffusionCount += 1
                        nextRoom[next.row][next.column] += diffusion
                    }
                }
                nextRoom[front.row][front.column] += (room[front.row][front.column] - (diffusion * diffusionCount))
            } else if room[row][column] < 0 {
                nextRoom[row][column] = room[row][column]
            }
        }
    }
    room = nextRoom
    cleanAir()
}
print(countDust())