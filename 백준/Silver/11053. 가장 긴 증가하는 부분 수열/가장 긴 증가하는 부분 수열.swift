import Foundation

guard let input = readLine(),
      let N = Int(input) else {
    fatalError("nil found")
}
var sequence = (readLine() ?? "").components(separatedBy: " ").map{ Int($0) ?? 0 }
var dp = Array(repeating: 1, count: N + 1)

for i in 1...N {
    for j in 1...i {
        if sequence[j - 1] < sequence[i - 1] {
            dp[i] = max(dp[i], dp[j] + 1)
        }
    }
}
dp.sort()
print(dp[N])