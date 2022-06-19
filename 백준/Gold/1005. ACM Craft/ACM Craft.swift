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
let testCase = fileIO.readInt()
    
// MARK: - Solution

private func solution() -> String {
    var result = ""
    for _ in 0 ..< testCase {
        let numberOfBuilding = fileIO.readInt()
        let numberOfConstructionRule = fileIO.readInt()
        var constructionTime = Array(repeating: 0, count: numberOfBuilding + 1)
        for building in 1 ... numberOfBuilding {
            constructionTime[building] = fileIO.readInt()
        }
        
        var preBuiltCount = Array(repeating: 0, count: numberOfBuilding + 1)
        var postBuild = Array(repeating: [Int](), count: numberOfBuilding + 1)
        for _ in 1 ... numberOfConstructionRule {
            let before = fileIO.readInt()
            let after = fileIO.readInt()
            preBuiltCount[after] += 1
            postBuild[before].append(after)
        }
        let targetBuilding = fileIO.readInt()
        
        var queue: [Int] = []
        for building in 1 ... numberOfBuilding {
            if preBuiltCount[building] == 0 {
                queue.append(building)
            }
        }
        
        var currentIndex = 0
        var timeSpentFor = Array(repeating: 0, count: numberOfBuilding + 1)
        while 0 < preBuiltCount[targetBuilding] && currentIndex < queue.endIndex {
            let front = queue[currentIndex]
            for next in postBuild[front] {
                timeSpentFor[next] = max(timeSpentFor[next], timeSpentFor[front] + constructionTime[front])
                preBuiltCount[next] -= 1
                if preBuiltCount[next] == 0 {
                    queue.append(next)
                }
            }
            currentIndex += 1
        }
        result += "\(timeSpentFor[targetBuilding] + constructionTime[targetBuilding])\n"
    }
    let _ = result.popLast()
    
    return result
}
print(solution())