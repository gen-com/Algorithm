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
let width = fileIO.readInt()

// MARK: - Solution

let queen: [Bool] = Array(repeating: false, count: width * width)
var result = 0

if 1 < width {
    for i in 0 ..< width {
        findQueen(width, makeQueen(i, queen), 1)
    }
    print(result)
} else {
    print(1)
}

func findQueen(_ now: Int, _ chess: [Bool], _ queenCounting: Int) {
    let layer = ((now / width) + 1) * width
    for i in now..<layer {
        if !chess[i] {
            if queenCounting == width - 1 {
                result += 1
                return
            } else {
                findQueen(layer, makeQueen(i, chess), queenCounting + 1)
            }
        }
    }
}

func makeQueen(_ now: Int, _ chess: [Bool]) -> [Bool] {
    var newChess = chess
    newChess[now] = true

    for i in stride(from: now + width, through: width * width - 1, by: width) {
        newChess[i] = true
    }

    var level = (now / width) + 1
    for i in stride(from: now + width + 1, through: width * width - 1, by: width + 1) {
        if i / width != level {
            break
        }
        level += 1
        newChess[i] = true
    }

    var level3 = (now / width) + 1
    for i in stride(from: now + width - 1, through: width * width - 1, by: width - 1) {
        if i / width != level3 {
            break
        }
        level3 += 1
        newChess[i] = true
    }

    return newChess
}