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
var safeArea: [(row: Int, column: Int)] = []
var virusQueueOrigin: [(row: Int, column: Int)] = []
for row in 0 ..< numberOfRow {
    for column in 0 ..< numberOfColumn {
        let input = fileIO.readInt()
        switch input {
        case 0: safeArea.append((row, column))
        case 2: virusQueueOrigin.append((row, column))
        default: break
        }
        map[row][column] = input
    }
}

// MARK: - Solution

var answer = 0
var minimumViruses = 65

func setWall() {
    for first in safeArea.indices {
        if first + 1 < safeArea.endIndex {
            for second in first + 1 ..< safeArea.endIndex {
                if second + 1 < safeArea.endIndex {
                    for third in second + 1 ..< safeArea.endIndex {
                        var tmpMap = map
                        tmpMap[safeArea[first].row][safeArea[first].column] = 1
                        tmpMap[safeArea[second].row][safeArea[second].column] = 1
                        tmpMap[safeArea[third].row][safeArea[third].column] = 1
                        answer = max(answer, startPandemic(&tmpMap))
                    }
                }
            }
        }
    }
    print(answer)
}

func startPandemic(_ map: inout [[Int]]) -> Int {
    let moveRow = [0, 0, 1, -1]
    let moveColumn = [1, -1, 0, 0]
    var virusQueue = virusQueueOrigin
    var safeAreaCount = safeArea.count - 3
    var currentIndex = 0
    while currentIndex < virusQueue.endIndex {
        let front = virusQueue[currentIndex]
        for moveIndex in moveRow.indices {
            let next = (row: front.row + moveRow[moveIndex], column: front.column + moveColumn[moveIndex])
            if 0 <= next.row, next.row < numberOfRow, 0 <= next.column, next.column < numberOfColumn, map[next.row][next.column] == 0 {
                map[next.row][next.column] = 2
                virusQueue.append(next)
                safeAreaCount -= 1
                if minimumViruses < virusQueue.count { return 0 }
            }
        }
        currentIndex += 1
    }
    minimumViruses = min(minimumViruses, virusQueue.count)

    return safeAreaCount
}
setWall()