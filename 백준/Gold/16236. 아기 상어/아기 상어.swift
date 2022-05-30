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

// MARK: - Heap

struct Heap<Element> where Element: Comparable {
    
    // MARK: Property(ies)
    
    var elements: [Element] = []
    private var comparator: (Element, Element) -> Bool
    var isEmpty: Bool {
        elements.isEmpty
    }
    var front: Element? {
        elements.first
    }
    
    // MARK: Initializer(s)
    
    init(comparator: @escaping (Element, Element) -> Bool) {
        self.comparator = comparator
    }
    
    // MARK: Method(s)
    
    mutating func insert(value: Element) {
        elements.append(value)
        compareWithParent(of: elements.endIndex - 1)
    }
    
    private mutating func compareWithParent(of currentIndex: Int) {
        let parentIndex = (currentIndex - 1) / 2
        if 0 <= parentIndex, comparator(elements[currentIndex], elements[parentIndex]) {
            elements.swapAt(parentIndex, currentIndex)
            compareWithParent(of: parentIndex)
        }
    }
    
    mutating func popFront() -> Element? {
        if elements.isEmpty == false {
            elements.swapAt(elements.startIndex, elements.endIndex - 1)
            let last = elements.popLast()
            compareWithChilds(of: elements.startIndex)
            
            return last
        }
        
        return nil
    }
    
    private mutating func compareWithChilds(of currentIndex: Int) {
        let leftChildIndex = currentIndex * 2 + 1
        let rightChildIndex = leftChildIndex + 1
        if rightChildIndex < elements.endIndex {
            if comparator(elements[rightChildIndex], elements[currentIndex]), comparator(elements[leftChildIndex], elements[currentIndex]) {
                if comparator(elements[leftChildIndex], elements[rightChildIndex]) {
                    elements.swapAt(currentIndex, leftChildIndex)
                    compareWithChilds(of: leftChildIndex)
                } else {
                    elements.swapAt(currentIndex, rightChildIndex)
                    compareWithChilds(of: rightChildIndex)
                }
            } else if comparator(elements[rightChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, rightChildIndex)
                compareWithChilds(of: rightChildIndex)
            } else if comparator(elements[leftChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, leftChildIndex)
                compareWithChilds(of: leftChildIndex)
            }
        } else if leftChildIndex < elements.endIndex {
            if comparator(elements[leftChildIndex], elements[currentIndex]) {
                elements.swapAt(currentIndex, leftChildIndex)
                compareWithChilds(of: leftChildIndex)
            }
        }
    }
}

// MARK: - Shark

struct Shark {
    
    var position: (xPos: Int, yPos: Int) = (0, 0)
    var size: Int = 2
    var exp: Int = 0
}

struct Fish {
    
    var xPos: Int
    var yPos: Int
    var distance: Int
}

extension Fish: Comparable {
    
    static func < (lhs: Fish, rhs: Fish) -> Bool {
        if lhs.distance != rhs.distance {
            
            return lhs.distance < rhs.distance
        } else {
            if lhs.yPos != rhs.yPos {
                
                return lhs.yPos < rhs.yPos
            } else {
                
                return lhs.xPos < rhs.xPos
            }
        }
    }
}

// MARK: - Input

let fileIO = FileIO()
let width = fileIO.readInt()
var map = Array(repeating: Array(repeating: 0, count: width), count: width)
var shark = Shark()
for yPos in 0 ..< width {
    for xPos in 0 ..< width {
        let input = fileIO.readInt()
        if input == 9 {
            shark.position = (xPos, yPos)
            map[yPos][xPos] = 0
        } else {
            map[yPos][xPos] = input
        }
    }
}

// MARK: - Solution

func distanceOfNearestEatableFishFromShark() -> Int? {
    let moveX = [0, 1, 0, -1]
    let moveY = [1, 0, -1, 0]
    var notVisited = Array(repeating: Array(repeating: true, count: width), count: width)
    var minHeap = Heap<Fish>(comparator: <)
    var queue = [Fish(xPos: shark.position.xPos, yPos: shark.position.yPos, distance: 0)]
    notVisited[shark.position.yPos][shark.position.xPos] = false
    var currentIndex = 0
    
    while currentIndex < queue.endIndex {
        let front = queue[currentIndex]
        for moveIndex in moveX.indices {
            let next = Fish(xPos: front.xPos + moveX[moveIndex], yPos: front.yPos + moveY[moveIndex], distance: front.distance + 1)
            if 0 <= next.xPos, next.xPos < width, 0 <= next.yPos, next.yPos < width,
               notVisited[next.yPos][next.xPos], map[next.yPos][next.xPos] <= shark.size {
                notVisited[next.yPos][next.xPos] = false
                if map[next.yPos][next.xPos] != 0, map[next.yPos][next.xPos] < shark.size {
                    minHeap.insert(value: Fish(xPos: next.xPos - shark.position.xPos, yPos: next.yPos - shark.position.yPos, distance: next.distance))
                }
                queue.append(next)
            }
        }
        currentIndex += 1
    }
    
    if let front = minHeap.front {
        map[front.yPos + shark.position.yPos][front.xPos + shark.position.xPos] = 0
        shark.position = (front.xPos + shark.position.xPos, front.yPos + shark.position.yPos)
        shark.exp += 1
        if shark.size == shark.exp {
            shark.size += 1
            shark.exp = 0
        }
        
        return front.distance
    } else {
        
        return nil
    }
}

func solution() -> Int {
    var time = 0
    while true {
        if let distance = distanceOfNearestEatableFishFromShark() {
            time += distance
        } else {
            break
        }
    }
    
    return time
}
print(solution())