//
//  LocationSearchHelper.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class LocationSearchHelper
{
    static func distance(from city1: CityName, to city2: CityName, in graph: LocationGraph) -> Int
    {
        return path(from: city1, to: city2, in: graph)!.count - 1
    }
    
    static func path(from city1: CityName, to city2: CityName, in graph: LocationGraph) -> [CityName]?
    {
        return bfs(from: city1, to: city2, in: graph)
    }
    
    private static func bfs(from city1: CityName, to city2: CityName, in graph: LocationGraph) -> [CityName]?
    {
        var queue: [SearchNode] = [SearchNode(parent: nil, city: city1)]
        var finalNode: SearchNode?
        var seen: [CityName] = []
        while !queue.isEmpty
        {
            let node = queue.removeFirst()
            if node.city == city2
            {
                finalNode = node
                break
            }
            else
            {
                seen.append(node.city)
                graph.edges[node.city]!.forEach
                { city in
                    if !seen.contains(city)
                    {
                        queue.append(SearchNode(parent: node, city: city))
                    }
                }
            }
        }
        return finalNode?.getPath()
    }
}

private class SearchNode: Equatable
{
    var parent: SearchNode?
    var city: CityName
    
    init(parent: SearchNode? = nil, city: CityName) {
        self.parent = parent
        self.city = city
    }
    
    static func ==(lhs: SearchNode, rhs: SearchNode) -> Bool
    {
        return lhs.city == rhs.city
    }
    
    func getPath() -> [CityName]
    {
        return (parent?.getPath() ?? []) + [city]
    }
}
