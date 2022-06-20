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
let numberOfStudent = fileIO.readInt()
let numberOfComparison = fileIO.readInt()
var postStudentsFor = Array(repeating: [Int](), count: numberOfStudent + 1)
var preStudentsCount = Array(repeating: 0, count: numberOfStudent + 1)
for _ in 0 ..< numberOfComparison {
    let stand = fileIO.readInt()
    let post = fileIO.readInt()
    postStudentsFor[stand].append(post)
    preStudentsCount[post] += 1
}
    
// MARK: - Solution

private func solution(_ postStudentsFor: inout [[Int]], _ preStudentsCount: inout [Int]) -> String {
    var answer = ""
    var queue: [Int] = []
    for student in 1 ... numberOfStudent {
        if preStudentsCount[student] == 0 {
            queue.append(student)
            answer += "\(student) "
        }
    }
    var currentIndex = 0
    while currentIndex < queue.endIndex {
        for next in postStudentsFor[queue[currentIndex]] {
            preStudentsCount[next] -= 1
            if preStudentsCount[next] == 0 {
                queue.append(next)
                answer += "\(next) "
            }
        }
        currentIndex += 1
    }
    let _ = answer.popLast()
    
    return answer
}
print(solution(&postStudentsFor, &preStudentsCount))