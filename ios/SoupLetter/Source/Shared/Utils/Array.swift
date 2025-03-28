/// Extension on Array providing chunking functionality
extension Array {
  /// Splits an array into smaller arrays of specified size.
  ///
  /// This method divides the original array into multiple subarrays (chunks),
  /// each containing at most the specified number of elements. The last chunk may contain
  /// fewer elements if the array's count is not evenly divisible by the chunk size.
  ///
  /// - Parameter size: The maximum number of elements each chunk should contain.
  /// - Returns: An array of arrays, where each inner array is a chunk of the original array.
  ///
  /// - Example:
  ///   ```
  ///   let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  ///   let chunked = numbers.chunked(into: 3)
  ///   // chunked = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [10]]
  ///   ```
  func chunked(into size: Int) -> [[Element]] {
    let chunkSize = count / size + (count % size > 0 ? 1 : 0)
    return stride(from: 0, to: count, by: chunkSize).map {
      Array(self[$0..<Swift.min($0 + chunkSize, count)])
    }
  }
}
