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
let numberOfCard = fileIO.readInt()
let numberOfPlayingCard = fileIO.readInt()
let numberOfTurn = fileIO.readInt()
var playingCards = Array(repeating: Card(0, false), count: numberOfPlayingCard)
var turnCards = Array(repeating: 0, count: numberOfTurn)
for index in playingCards.indices {
    playingCards[index] = Card(fileIO.readInt(), false)
}
for index in turnCards.indices {
    turnCards[index] = fileIO.readInt()
}
playingCards.sort { $0.value < $1.value }
print(solution(&playingCards, turnCards))

// MARK: - Solutions

private func binarySearch(_ cards: [Card], _ start: Int, _ end: Int, _ target: Int) -> Int {
    if end <= start {
        return start
    }
    let mid = (start + end) / 2
    if target < cards[mid].value {
        return binarySearch(cards, start, mid, target)
    } else {
        return binarySearch(cards, mid + 1, end, target)
    }
}

private func findNext(_ nexts: inout [Int], _ current: Int) -> Int {
    if nexts[current] == current {
        return current
    }
    nexts[current] = findNext(&nexts, nexts[current])
    return nexts[current]
}

private func solution(_ playingCards: inout [Card], _ turnCards: [Int]) -> String {
    var answer = ""
    var nexts = Array(repeating: 0, count: playingCards.count)
    for index in nexts.indices {
        nexts[index] = index
    }
    for turnCard in turnCards {
        let index = binarySearch(playingCards, 0, playingCards.endIndex - 1, turnCard)
        if playingCards[index].used {
            let next = findNext(&nexts, index)
            playingCards[next].used = true
            answer += "\(playingCards[next].value)\n"
            nexts[next] = next + 1
        } else {
            playingCards[index].used = true
            nexts[index] = index + 1
            answer += "\(playingCards[index].value)\n"
        }
    }
    
    return answer
}