import Foundation

// MARK: - Input

var preorderNotation: [Int] = []
while let nodeString = readLine(), let nodeNumber = Int(nodeString) {
    preorderNotation.append(nodeNumber)
}

// MARK: - Solution

var answer = ""

func binarySearch(start: Int, end: Int, rootIndex: Int) -> Int {
    if end <= start {

        return end
    } else {
        let midIndex = (start + end) / 2
        if preorderNotation[rootIndex] < preorderNotation[midIndex] {

            return binarySearch(start: start, end: midIndex, rootIndex: rootIndex)
        } else {

            return binarySearch(start: midIndex + 1, end: end, rootIndex: rootIndex)
        }
    }
}

func postorderNotation(start: Int, end: Int) {
    if end <= start {
        return
    } else {
        let rightChildIndex = binarySearch(start: start + 1, end: end, rootIndex: start)
        postorderNotation(start: start + 1, end: rightChildIndex)
        postorderNotation(start: rightChildIndex, end: end)
        answer += "\(preorderNotation[start])\n"
    }
}

postorderNotation(start: preorderNotation.startIndex, end: preorderNotation.endIndex)
print(answer)