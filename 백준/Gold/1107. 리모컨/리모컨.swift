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
let targetChannel = fileIO.readInt()
let numebrOfBrokenButton = fileIO.readInt()
var availableButtons = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
for _ in 0 ..< numebrOfBrokenButton {
    let brokenButton = fileIO.readInt()
    if let targetIndex = availableButtons.firstIndex(of: brokenButton) {
        availableButtons.remove(at: targetIndex)
    }
}

var answer = abs(targetChannel - 100)
func combination(current: String) {
    if 6 < current.count {
        return
    } else {
        let candidate = abs(targetChannel - Int(current)!) + current.count
        answer = min(answer, candidate)
        availableButtons.forEach { combination(current: current + "\($0)") }
    }
}
if answer == 0 {
    print(0)
} else if numebrOfBrokenButton == 0 {
    answer = min(answer, "\(targetChannel)".count)
    print(answer)
} else {
    availableButtons.forEach { combination(current: "\($0)") }
    print(answer)
}