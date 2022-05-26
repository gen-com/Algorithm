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

// MARK: - Commands

enum Command {
    
    case pop
    case insert
    
    static func verify(_ value: Int) -> Command {
        value == 0 ? .pop : .insert
    }
}

// MARK: - Heap

struct Heap {
    
    // MARK: Property(ies)
    
    private var elements: [Int] = []
    private(set) var result = ""
    private var comparator: (Int, Int) -> Bool
    var isEmpty: Bool {
        elements.isEmpty
    }
    
    // MARK: Initializer(s)
    
    init(comparator: @escaping (Int, Int) -> Bool) {
        self.comparator = comparator
    }
    
    // MARK: Method(s)
    
    mutating func insert(value: Int) {
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
    
    mutating func popFront() {
        if elements.isEmpty == false {
            elements.swapAt(elements.startIndex, elements.endIndex - 1)
            result += "\(elements.popLast() ?? 0)\n"
            compareWithChilds(of: elements.startIndex)
        } else {
            result += "0\n"
        }
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

// MARK: - Input

let fileIO = FileIO()
let numberOfCommands = fileIO.readInt()
var heap = Heap(comparator: { if abs($0) != abs($1) { return abs($0) < abs($1) } else { return $0 < $1 } })
for _ in 0 ..< numberOfCommands {
    let input = fileIO.readInt()
    switch Command.verify(input) {
    case .insert:
        heap.insert(value: input)
    case .pop:
        heap.popFront()
    }
}
print(heap.result)