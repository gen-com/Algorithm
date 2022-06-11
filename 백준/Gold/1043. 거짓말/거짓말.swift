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
let numberOfPeople = fileIO.readInt()
let numberOfParty = fileIO.readInt()
let numberOfPeopleWhoKnowsTruth = fileIO.readInt()
var knowsTruth = Array(repeating: false, count: numberOfPeople + 1)
var peopleWhoKnowsTruthQueue: [Int] = []
for _ in 0 ..< numberOfPeopleWhoKnowsTruth {
    let input = fileIO.readInt()
    knowsTruth[input] = true
    peopleWhoKnowsTruthQueue.append(input)
}
var parties = Array(repeating: [Int](), count: numberOfParty)
for partyIndex in 0 ..< numberOfParty {
    for _ in 0 ..< fileIO.readInt() {
        parties[partyIndex].append(fileIO.readInt())
    }
}

// MARK: - Solution

var edgeFor = Array(repeating: Set<Int>(), count: numberOfPeople + 1)
for partyIndex in parties.indices {
    for lhs in parties[partyIndex] {
        for rhs in parties[partyIndex] {
            if lhs != rhs {
                edgeFor[lhs].insert(rhs)
                edgeFor[rhs].insert(lhs)
            }
        }
    }
}

var currentIndex = 0
while currentIndex < peopleWhoKnowsTruthQueue.endIndex {
    let front = peopleWhoKnowsTruthQueue[currentIndex]
    for person in edgeFor[front] {
        if knowsTruth[person] == false {
            knowsTruth[person] = true
            peopleWhoKnowsTruthQueue.append(person)
        }
    }
    currentIndex += 1
}

var answer = numberOfParty
for party in parties {
    for person in party {
        if knowsTruth[person] {
            answer -= 1
            break
        }
    }
}
print(answer)