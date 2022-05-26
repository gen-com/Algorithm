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

// MARK: Input

let fileIO = FileIO()

func gcd(_ x: Int, _ y: Int) -> Int {
    let max = max(x, y)
    let min = min(x, y)
    
    return max % min == 0 ? min : gcd(min, max % min)
}

func lcm(_ x: Int, _ y: Int) -> Int {
    x * y / gcd(x, y)
}

let testCase = fileIO.readInt()
for _ in 0 ..< testCase {
    let m = fileIO.readInt()
    let n = fileIO.readInt()
    let x = fileIO.readInt()
    let y = fileIO.readInt()
    var count = x
    var currentY = x % n == 0 ? n : x % n
    for _ in 0 ..< n {
        if currentY == y {
            break
        } else {
            currentY = (currentY + m) % n == 0 ? n : (currentY + m) % n
            count += m
        }
    }
    print(lcm(m, n) < count ? -1 : count)
}