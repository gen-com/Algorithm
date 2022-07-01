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

typealias RGB = (red: Int, green: Int, blue: Int)

let fileIO = FileIO()
let numberOfHouse = fileIO.readInt()
var houses = Array(repeating: RGB(0, 0, 0), count: numberOfHouse)
for index in 0 ..< numberOfHouse {
    houses[index] = (fileIO.readInt(), fileIO.readInt(), fileIO.readInt())
}
print(solution(numberOfHouse, houses))

// MARK: - Solution

private func solution(_ numberOfHouse: Int, _ houses: [RGB]) -> Int {
    var dp = Array(repeating: RGB(0, 0, 0), count: numberOfHouse)
    dp[0] = (houses[0].red, 10_000_000, 10_000_000)
    for index in 1 ..< numberOfHouse - 1 {
        dp[index].red = houses[index].red + min(dp[index - 1].green, dp[index - 1].blue)
        dp[index].green = houses[index].green + min(dp[index - 1].red, dp[index - 1].blue)
        dp[index].blue = houses[index].blue + min(dp[index - 1].red, dp[index - 1].green)
    }
    dp[numberOfHouse - 1].green = houses[numberOfHouse - 1].green + min(dp[numberOfHouse - 2].red, dp[numberOfHouse - 2].blue)
    dp[numberOfHouse - 1].blue = houses[numberOfHouse - 1].blue + min(dp[numberOfHouse - 2].red, dp[numberOfHouse - 2].green)
    let redCandidate = min(dp[numberOfHouse - 1].green, dp[numberOfHouse - 1].blue)
    
    dp = Array(repeating: RGB(0, 0, 0), count: numberOfHouse)
    dp[0] = (10_000_000, houses[0].green, 10_000_000)
    for index in 1 ..< numberOfHouse - 1 {
        dp[index].red = houses[index].red + min(dp[index - 1].green, dp[index - 1].blue)
        dp[index].green = houses[index].green + min(dp[index - 1].red, dp[index - 1].blue)
        dp[index].blue = houses[index].blue + min(dp[index - 1].red, dp[index - 1].green)
    }
    dp[numberOfHouse - 1].red = houses[numberOfHouse - 1].red + min(dp[numberOfHouse - 2].green, dp[numberOfHouse - 2].blue)
    dp[numberOfHouse - 1].blue = houses[numberOfHouse - 1].blue + min(dp[numberOfHouse - 2].red, dp[numberOfHouse - 2].green)
    let greenCandidate = min(dp[numberOfHouse - 1].red, dp[numberOfHouse - 1].blue)
    
    dp = Array(repeating: RGB(0, 0, 0), count: numberOfHouse)
    dp[0] = (10_000_000, 10_000_000, houses[0].blue)
    for index in 1 ..< numberOfHouse - 1 {
        dp[index].red = houses[index].red + min(dp[index - 1].green, dp[index - 1].blue)
        dp[index].green = houses[index].green + min(dp[index - 1].red, dp[index - 1].blue)
        dp[index].blue = houses[index].blue + min(dp[index - 1].red, dp[index - 1].green)
    }
    dp[numberOfHouse - 1].red = houses[numberOfHouse - 1].red + min(dp[numberOfHouse - 2].green, dp[numberOfHouse - 2].blue)
    dp[numberOfHouse - 1].green = houses[numberOfHouse - 1].green + min(dp[numberOfHouse - 2].red, dp[numberOfHouse - 2].blue)
    let blueCandidate = min(dp[numberOfHouse - 1].red, dp[numberOfHouse - 1].green)
    
    return min(redCandidate, greenCandidate, blueCandidate)
}
