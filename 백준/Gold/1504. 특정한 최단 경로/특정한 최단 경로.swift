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

typealias EdgeInformation = (node: Int, distance: Int)

let fileIO = FileIO()
let numberOfNode = fileIO.readInt()
let numberOfEdge = fileIO.readInt()
var edgeFor = Array(repeating: [EdgeInformation](), count: numberOfNode + 1)
for _ in 0 ..< numberOfEdge {
    let startingPoint = fileIO.readInt()
    let destination = fileIO.readInt()
    let distance = fileIO.readInt()
    edgeFor[startingPoint].append((destination, distance))
    edgeFor[destination].append((startingPoint, distance))
}
var needToVisit = [fileIO.readInt(), fileIO.readInt()]

// MARK: - Heap
struct Heap<Element> {
    
    // MARK: Property(ies)
    
    private var elements: [Element] = []
    private var comparator: (Element, Element) -> Bool
    var isEmpty: Bool {
        elements.isEmpty
    }
    
    // MARK: Initializer(s)
    
    init(comparator: @escaping (Element, Element) -> Bool) {
        self.comparator = comparator
    }
    
    // MARK: Method(s)
    
    mutating func removeAll() {
        elements.removeAll()
    }
    
    mutating func insert(_ value: Element) {
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
            let element = elements.popLast()
            compareWithChilds(of: elements.startIndex)
            
            return element
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


// MARK: - Solution

func dijkstraShortestPathSearch(from startingPoint: Int, to destination: Int) -> Int {
    var minHeap = Heap<EdgeInformation> { $0.distance < $1.distance }
    var distance = Array(repeating: Int.max, count: numberOfNode + 1)
    minHeap.insert((startingPoint, 0))
    distance[startingPoint] = 0
    while minHeap.isEmpty == false {
        if let front = minHeap.popFront() {
            if front.distance <= distance[front.node] {
                for next in edgeFor[front.node] {
                    if distance[front.node] + next.distance < distance[next.node] {
                        distance[next.node] = distance[front.node] + next.distance
                        minHeap.insert((next.node, distance[front.node] + next.distance))
                    }
                }
            }
        }
    }
    
    return distance[destination]
}

let firstVisit1 = dijkstraShortestPathSearch(from: 1, to: needToVisit[0])
let firstVisit2 = dijkstraShortestPathSearch(from: needToVisit[0], to: needToVisit[1])
let firstVisit3 = dijkstraShortestPathSearch(from: needToVisit[1], to: numberOfNode)

let secondVisit1 = dijkstraShortestPathSearch(from: 1, to: needToVisit[1])
let secondVisit2 = firstVisit2
let secondVisit3 = dijkstraShortestPathSearch(from: needToVisit[0], to: numberOfNode)

if firstVisit1 == Int.max || firstVisit2 == Int.max || firstVisit3 == Int.max ||
    secondVisit1 == Int.max || secondVisit3 == Int.max {
    print(-1)
} else {
    print(min(firstVisit1 + firstVisit2 + firstVisit3, secondVisit1 + secondVisit2 + secondVisit3))
}