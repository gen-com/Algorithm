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
let n = fileIO.readInt()
let m = fileIO.readInt()
var candidates: [Int] = []
for i in 1 ... n {
    candidates.append(i)
}

// MARK: - Solution

var answer = ""
var visited: [String: Bool] = [:]
func solution(current: String) {
    if m <= current.count {
        if visited[current] == nil {
            for c in current {
                answer += "\(c) "
            }
            answer += "\n"
            visited[current] = true
        }
        return
    } else {
        if let last = current.last, let lastNumber = Int(String(last)) {
            for index in lastNumber - 1 ..< candidates.endIndex {
                var next = current
                next.append("\(candidates[index])")
                solution(current: next)
            }
        } else {
            for candidate in candidates {
                var next = current
                next.append("\(candidate)")
                solution(current: next)
            }
        }
    }
}
solution(current: "")
print(answer)