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

// MARK: - Direction

enum Direction {
    
    case forward
    case backward
}

enum Command: String {
    
    case reverse = "R"
    case delete = "D"
    case unknown
    
    static func verify(_ value: String) -> Command {
        Command(rawValue: value) ?? .unknown
    }
}

// MARK: - Input

let fileIO = FileIO()
let testCase = fileIO.readInt()
for _ in 0 ..< testCase {
    let commandString = fileIO.readString()
    let commands = commandString.map { String($0) }
    let _ = fileIO.readInt()
    let elementsString = fileIO.readString()
    let elements = elementsString.components(separatedBy: ["[", ",", "]"]).filter { 0 < $0.count }
    var direction: Direction = .forward
    var error = false
    var start = elements.startIndex
    var end = elements.endIndex
    var answer = "["
    for command in commands {
        switch Command.verify(command) {
        case .reverse:
            direction = direction == .forward ? .backward : .forward
        case .delete:
            switch direction {
            case .forward:
                start += 1
            case .backward:
                end -= 1
            }
            error = end < start
        case .unknown: break
        }
        if error {
            break
        }
    }
    
    if error {
        print("error")
    } else {
        switch direction {
        case .forward:
            for value in elements[start ..< end] {
                answer += (value + ",")
            }
        case .backward:
            for value in elements[start ..< end].reversed() {
                answer += (value + ",")
            }
        }
        if let last = answer.last, last == "," {
            let _ = answer.popLast()
        }
        answer.append("]")
        print(answer)
    }
}