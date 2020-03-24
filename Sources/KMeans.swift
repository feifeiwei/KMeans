//
//  KMeans.swift
//  KMeans
//
//  Created by Tatsuya Tanaka on 20171207.
//  Copyright © 2017年 tattn. All rights reserved.
//
import Foundation

public protocol KMeansElement {
    static var zeroValue: Self { get }

    static func + (left: Self, right: Self) -> Self
    static func / (left: Self, right: Int) -> Self

    func squareDistance(to: Self) -> Float
}

public struct KMeans<T: KMeansElement> {
    public static var defaultMaxIteration: Int { return 300 }

    public let numberOfCentroids: Int
    public let maxIteration: Int
    public let convergeDistance: Float?
    public var feat_index:[Int]
    // index for each feature
    

    public private(set) var centroids: [T]!

    public init(elements: [T],
                numberOfCentroids: Int,
                maxIteration: Int = defaultMaxIteration,
                convergeDistance: Float? = nil,
                feat_index:[Int]) {
        assert(numberOfCentroids > 1, "k-means (k > 1)")
        assert(maxIteration >= 0, "maxIteration >= 0)")
        self.numberOfCentroids = numberOfCentroids
        self.maxIteration = maxIteration
        self.convergeDistance = convergeDistance
        self.feat_index = feat_index
        centroids = fitPredict(elements: elements) // 方法，返回聚类中心。
    }

    private mutating func fitPredict(elements: [T]) -> [T] {
        guard !elements.isEmpty else { return [] }

        let convergeSquareDistance = convergeDistance.map { $0 * $0 }
        let zero = T.zeroValue
        var centroids = elements.randomElements(numberOfCentroids) //随机初始化 聚类中心
        // print("**", centroids)

        for _ in 0..<maxIteration {
            var predictions: [[T]] = .init(repeating: [], count: numberOfCentroids)

            // find k centroids
            for (idx,element) in elements.enumerated() {
                
                let index = self.index(of: element, in: centroids)
                // 更新index
                self.feat_index[idx] = index
                predictions[index].append(element)
            }

            // calculate the average of the centroids
            var newCentroids: [T] = []
            for prediction in predictions {
                let count = prediction.count
                if count > 0 {
                    newCentroids.append(prediction.reduce(zero, +) / count)
                } else {
                    newCentroids.append(zero)
                }
            }

            // calculate the distance from the last centroid position
            var centerMoveSquareDistance: Float = 0.0
            for (index, centroid) in centroids.enumerated() {
                centerMoveSquareDistance += centroid.squareDistance(to: newCentroids[index])
            }

            centroids = newCentroids

            if let converge = convergeSquareDistance,
                centerMoveSquareDistance <= converge { break }
        }

        return centroids
    }

    public func findCentroid(of element: T) -> T {
        let index = self.index(of: element, in: centroids)
        return centroids[index]
    }

    private func index(of element: T, in centroids: [T]) -> Int {
        var nearestDistance = Float.greatestFiniteMagnitude // 3.4028235e+38
        //print(nearestDistance)
        var minIndex = 0

        for (index, centroid) in centroids.enumerated() {
            let distance = element.squareDistance(to: centroid)
            if distance < nearestDistance {
                minIndex = index
                nearestDistance = distance
            }
        }
        return minIndex
    }
}

private extension Array {
    func randomElements(_ count: Int) -> [Element] {
        var result = Array(repeating: self[0], count: count)
        for index in 0..<count {
            let randomIndex = Int(arc4random_uniform(UInt32(self.count - 1)))
            result[index] = self[randomIndex]
        }
        return result
    }
}
