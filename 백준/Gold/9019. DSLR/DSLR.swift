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

enum Command: String {
    
    case d = "D"
    case s = "S"
    case l = "L"
    case r = "R"
    
    static let all = [Command.d, .s, .l, .r]
}

var answer = ""
for _ in 0 ..< testCase {
    let current = fileIO.readInt()
    let destination = fileIO.readInt()
    var queue = [(current: current, command: "")]
    var visited = Array(repeating: false, count: 10000)
    var currentIndex = 0
    visited[current] = true
    while currentIndex < queue.count {
        let front = queue[currentIndex]
        if front.current == destination {
            answer += "\(front.command)\n"
            break
        } else {
            for command in Command.all {
                switch command {
                case .d:
                    let next = front.current * 2 % 10000
                    if visited[next] == false {
                        queue.append((next, front.command + command.rawValue))
                        visited[next] = true
                    }
                case .s:
                    if front.current == 0, visited[9999] == false {
                        queue.append((9999, front.command + command.rawValue))
                        visited[9999] = true
                    } else if 0 <= front.current - 1, visited[front.current - 1] == false {
                        queue.append((front.current - 1, front.command + command.rawValue))
                        visited[front.current - 1] = true
                    }
                case .l:
                    let next = front.current % 1000 * 10 + front.current / 1000
                    if visited[next] == false {
                        queue.append((next, front.command + command.rawValue))
                        visited[next] = true
                    }
                case .r:
                    let next = front.current % 10 * 1000 + front.current / 10
                    if visited[next] == false {
                        queue.append((next, front.command + command.rawValue))
                        visited[next] = true
                    }
                }
            }
            currentIndex += 1
        }
    }
}
print(answer)