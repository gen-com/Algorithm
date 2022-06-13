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

typealias Position = (row: Int, column: Int)

let fileIO = FileIO()
let numberOfRow = fileIO.readInt()
let numberOfColumn = fileIO.readInt()
var map = Array(repeating: Array(repeating: 0, count: numberOfColumn), count: numberOfRow)
for row in 0 ..< numberOfRow {
    for column in 0 ..< numberOfColumn {
        let input = fileIO.readInt()
        map[row][column] = input
    }
}

let move: [Position] = [(1, 0), (-1, 0), (0, 1), (0, -1)]
let outside = 3
let melting = 2

func separateOutside() -> Bool {
    var notVisited = Array(repeating: Array(repeating: true, count: numberOfColumn), count: numberOfRow)
    var queue: [Position] = [(0, 0)]
    var meltQueue: [Position] = []
    map[0][0] = outside
    notVisited[0][0] = true
    var currentIndex = 0
    while currentIndex < queue.endIndex {
        let front = queue[currentIndex]
        for moveIndex in move.indices {
            let next: Position = (front.row + move[moveIndex].row, front.column + move[moveIndex].column)
            if 0 <= next.row, next.row < numberOfRow, 0 <= next.column, next.column < numberOfColumn, notVisited[next.row][next.column] {
                notVisited[next.row][next.column] = false
                if map[next.row][next.column] != 1 {
                    map[next.row][next.column] = outside
                    queue.append(next)
                } else {
                    meltQueue.append(next)
                }
            }
        }
        currentIndex += 1
    }
    
    currentIndex = 0
    while currentIndex < meltQueue.endIndex {
        let front = meltQueue[currentIndex]
        var count = 0
        for moveIndex in move.indices {
            let side: Position = (front.row + move[moveIndex].row, front.column + move[moveIndex].column)
            if 0 <= side.row, side.row < numberOfRow, 0 <= side.column, side.column < numberOfColumn {
                if map[side.row][side.column] == 3 {
                    count += 1
                }
            }
        }
        if 1 < count {
            map[front.row][front.column] = melting
        }
        currentIndex += 1
    }
    
    return meltQueue.isEmpty
}

var answer = 0
while separateOutside() == false {
    answer += 1
}
print(answer)