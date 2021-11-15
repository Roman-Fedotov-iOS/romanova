//
//  WaveformDataProcessor.swift
//  romanova
//
//  Created by Roman Fedotov on 04.09.2021.
//

import UIKit

typealias Matrix<T> = Array<Array<T>>

struct waveFormDataProcessorResult {
    let values: Array<Float>
    let columnsCount: Int
}

protocol WaveformDataProcessor {
    func process(partsCount: Int, imageData: [UInt8], columnsCount: Int) -> waveFormDataProcessorResult
}

class WaveformDataProcessorImpl: WaveformDataProcessor {
    
    func process(partsCount: Int, imageData: [UInt8], columnsCount: Int) -> waveFormDataProcessorResult {
        let matrix = imageData
            .toMatrix(columnsCount: columnsCount)
            .bolleanArray
        let transposed1 = transposed(matrix: matrix)
        let resultValues = transposed1.chunked(into: matrix.first!.count/partsCount).map { chunk -> Float in
            let joined = chunk.joined()
            return Float(joined.filter({ pixel in
                pixel
            }).count)/Float(joined.count)
        }
        return waveFormDataProcessorResult(values: resultValues.normalized.sigmoid, columnsCount: resultValues.count)
    }
    
}

extension Array {
    func toMatrix(columnsCount: Int) -> Matrix<Element> {
        var matrix: Matrix<Element?> = [[Element?]](
            repeating: [Element?](repeating: nil, count: columnsCount),
            count: self.count/columnsCount
        )
        for (index,value) in self.enumerated() {
            let x = index%columnsCount
            let y = index/columnsCount
            matrix[y][x] = value
        }
        return matrix.map { row in
            row.map { value in
                value!
            }
        }
    }
}

extension Matrix where Element == Array<UInt8> {
    var bolleanArray: Matrix<Bool> {
        get {
            var matrix: Matrix<Bool> = [[Bool]](
                repeating: [Bool](repeating: false, count: self.first!.count),
                count: self.count
            )
            for (y, row) in self.enumerated() {
                for (x, pixel) in row.enumerated() {
                    if pixel == 0 {
                        matrix[y][x] = true
                    }
                }
            }
            return matrix
        }
    }
}

func transposed(matrix: Matrix<Bool>) -> Matrix<Bool> {
    
    switch (matrix.filter { row in
        !row.isEmpty
    }) {
    case let filtered where filtered.isEmpty :
        return []
    case let filtered where !filtered.isEmpty :
        return plus(startElements: filtered.map({ row1 in
            row1.first!
        }), elements: transposed(matrix: filtered.map({ row1 in
            return Array(row1.dropFirst())
        })))
    default:
        return []
    }
}

func plus(startElements: Array<Bool>, elements: Matrix<Bool>) -> Matrix<Bool> {
    var matrix: Matrix<Bool> = []
    matrix.append(startElements)
    matrix += elements
    return matrix
}

extension Collection {
  public func chunked(into size: Int) -> [SubSequence] {
    var chunks: [SubSequence] = []
    var rest = self[...]
    while !rest.isEmpty {
      chunks.append(rest.prefix(size))
      rest = rest.dropFirst(size)
    }
    return chunks
  }
}

extension Array where Element == Float {
    var normalized: Array<Float> {
        get {
            self.map { element -> Float in
                let i1 = self.max()! / (self.max()! - self.min()!)
                let i2 = (i1 * (element - self.max()!) + self.max()!)
                if i2 < 0.1 {
                    return 0.1
                } else {
                    return i2
                }
            }
        }
    }
    var sigmoid: Array<Float> {
        get {
            self.map { element -> Float in
                let i1 = pow(Darwin.M_E, -5 * (Double(element) - 0.5))
                let i2 = 1.0 / (1.0 + i1)
                if i2 < 0.1 {
                    return 0.1
                } else {
                    return Float(i2)
                }
            }
        }
    }
}
