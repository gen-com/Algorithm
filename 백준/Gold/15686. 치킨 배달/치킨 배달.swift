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
let mapWidth = fileIO.readInt()
let maximumStore = fileIO.readInt()
var residents: [Position] = []
var chickenStores: [Position] = []
for row in 0 ..< mapWidth {
    for column in 0 ..< mapWidth {
        let input = fileIO.readInt()
        switch input {
        case 1: residents.append((row, column))
        case 2: chickenStores.append((row, column))
        default: break
        }
    }
}

// MARK: - Solution

var answer = Int.max

func chooseMaxinum(_ current: [Position], currentIndex: Int) {
    if maximumStore == current.count {
        answer = min(answer, distanceCalculation(for: current))
        return
    } else {
        if currentIndex + 1 < chickenStores.endIndex {
            for index in currentIndex + 1 ..< chickenStores.endIndex {
                var next = current
                next.append(chickenStores[index])
                chooseMaxinum(next, currentIndex: index)
            }
        }
    }
}

func distanceCalculation(for candidate: [Position]) -> Int {
    var answerCandidate = 0
    for resident in residents {
        var minimumDistance = Int.max
        for store in candidate {
            minimumDistance = min(minimumDistance, abs(resident.row - store.row) + abs(resident.column - store.column))
        }
        answerCandidate += minimumDistance
    }
    
    return answerCandidate
}

chooseMaxinum([], currentIndex: -1)
print(answer)