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

typealias Point = (x: Int, y: Int)

let fileIO = FileIO()
let testcase = fileIO.readInt()
var answer = ""
for _ in 0 ..< testcase {
    let numberOfPoint = fileIO.readInt()
    var points = Array(repeating: Point(0, 0), count: numberOfPoint)
    for index in points.indices {
        points[index] = Point(fileIO.readInt(), fileIO.readInt())
    }
    answer += "\(solution(numberOfPoint, points))\n"
}
let _ = answer.popLast()
print(answer)

// MARK: - Solution

private func vectorSum(_ points: [Point], _ visited: [Bool]) -> Double {
    var vector = Point(0, 0)
    for index in points.indices {
        if visited[index] {
            vector.x -= points[index].x
            vector.y -= points[index].y
        } else {
            vector.x += points[index].x
            vector.y += points[index].y
        }
    }
    
    return sqrt(pow(Double(vector.x), 2) + pow(Double(vector.y), 2))
}

private func dfs(_ points: [Point], _ visited: inout [Bool], _ currentIndex: Int, _ current: Int, _ answer: inout Double) {
    if current == points.count / 2 {
        answer = min(answer, vectorSum(points, visited))
        return
    }
    for index in currentIndex ..< visited.count {
        visited[index] = true
        dfs(points, &visited, index + 1, current + 1, &answer)
        visited[index] = false
    }
}

private func solution(_ numberOfPoint: Int, _ points: [Point]) -> Double {
    var answer = Double.infinity
    var visited = Array(repeating: false, count: numberOfPoint)
    dfs(points, &visited, 0, 0, &answer)
    
    return answer
}