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
var answer = ""
for test in 0 ..< testCase {
    let numberOfStudent = fileIO.readInt()
    var choose = Array(repeating: 0, count: numberOfStudent)
    for student in 0 ..< numberOfStudent {
        choose[student] = fileIO.readInt() - 1
    }
    answer += "\(solution(choose))"
    if test < testCase - 1 {
        answer += "\n"
    }
}
print(answer)
    
// MARK: - Solution

private func dfs(_ choose: [Int], _ notVisited: inout [Bool], _ notDone: inout [Bool], _ start: Int, _ count: inout Int) {
    notVisited[start] = false
    let next = choose[start]
    
    if notVisited[next] {
        dfs(choose, &notVisited, &notDone, choose[start], &count)
    } else if notDone[next] {
        var current = next
        while current != start {
            count += 1
            current = choose[current]
        }
        count += 1
    }
    notDone[start] = false
}

private func solution(_ choose: [Int]) -> String {
    var count = 0
    var notVisited = Array(repeating: true, count: choose.count)
    var notDone = Array(repeating: true, count: choose.count)
    for start in choose.indices {
        if notVisited[start] == false { continue }
        dfs(choose, &notVisited, &notDone, start, &count)
    }
    
    return "\(choose.count - count)"
}