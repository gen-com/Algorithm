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

struct SharkInfo {
    
    var id: Int
    var row: Int
    var column: Int
    let speed: Int
    var direction: Int
    let size: Int
    var isAlive = true
}

let fileIO = FileIO()
let numberOfRow = fileIO.readInt()
let numberOfColumn = fileIO.readInt()
let numberOfShark = fileIO.readInt()
var sharkInfos: [SharkInfo] = []
if numberOfShark == 0 {
    print(0)
} else {
    for id in 1 ... numberOfShark {
        sharkInfos.append(
            SharkInfo(
                id: id,
                row: fileIO.readInt(),
                column: fileIO.readInt(),
                speed: fileIO.readInt(),
                direction: fileIO.readInt(),
                size: fileIO.readInt()
            )
        )
    }
    print(solution(&sharkInfos, numberOfRow, numberOfColumn))
}

// MARK: - Solution

private func solution(_ sharkInfos: inout [SharkInfo], _ numberOfRow: Int, _ numberOfColumn: Int) -> Int {
    var answer = 0
    var map = Array(repeating: Array(repeating: 0, count: numberOfColumn + 1), count: numberOfRow + 1)
    for sharkInfo in sharkInfos {
        map[sharkInfo.row][sharkInfo.column] = sharkInfo.id
    }
    for fishermanColumn in 1 ... numberOfColumn {
        for row in 1 ... numberOfRow {
            if 0 < map[row][fishermanColumn], sharkInfos[map[row][fishermanColumn] - 1].isAlive {
                answer += sharkInfos[map[row][fishermanColumn] - 1].size
                sharkInfos[map[row][fishermanColumn] - 1].isAlive = false
                break
            }
        }
        map = Array(repeating: Array(repeating: 0, count: numberOfColumn + 1), count: numberOfRow + 1)
        for index in sharkInfos.indices {
            if sharkInfos[index].isAlive == false { continue }
            var move = 0
            if sharkInfos[index].direction < 3 {
                move = sharkInfos[index].speed % ((numberOfRow - 1) * 2)
            } else {
                move = sharkInfos[index].speed % ((numberOfColumn - 1) * 2)
            }
            while 0 < move {
                switch sharkInfos[index].direction {
                case 1: sharkInfos[index].row -= 1
                case 2: sharkInfos[index].row += 1
                case 3: sharkInfos[index].column += 1
                case 4: sharkInfos[index].column -= 1
                default: break
                }
                if sharkInfos[index].direction < 3, (sharkInfos[index].row < 1 || numberOfRow < sharkInfos[index].row) {
                    sharkInfos[index].direction = (sharkInfos[index].direction == 1) ? 2 : 1
                    switch sharkInfos[index].direction {
                    case 1: sharkInfos[index].row -= 2
                    case 2: sharkInfos[index].row += 2
                    default: break
                    }
                }
                if 2 < sharkInfos[index].direction, (sharkInfos[index].column < 1 || numberOfColumn < sharkInfos[index].column) {
                    sharkInfos[index].direction = (sharkInfos[index].direction == 3) ? 4 : 3
                    switch sharkInfos[index].direction {
                    case 3: sharkInfos[index].column += 2
                    case 4: sharkInfos[index].column -= 2
                    default: break
                    }
                }
                move -= 1
            }
            if 0 < map[sharkInfos[index].row][sharkInfos[index].column] {
                if sharkInfos[map[sharkInfos[index].row][sharkInfos[index].column] - 1].size < sharkInfos[index].size {
                    sharkInfos[map[sharkInfos[index].row][sharkInfos[index].column] - 1].isAlive = false
                    map[sharkInfos[index].row][sharkInfos[index].column] = sharkInfos[index].id
                } else {
                    sharkInfos[index].isAlive = false
                }
            } else {
                map[sharkInfos[index].row][sharkInfos[index].column] = sharkInfos[index].id
            }
        }
    }

    return answer
}