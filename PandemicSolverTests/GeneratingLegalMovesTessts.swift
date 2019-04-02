//
//  GeneratingLegalMovesTessts.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/2/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class GeneratingLegalMovesTessts: XCTestCase {
    func testGetTreatingActions()
    {
        var locations = [DiseaseColor: BoardLocation]()
        locations[.blue] = BoardLocation(city: City(name: .atlanta)).add(cubes: [.blue: .three]).1
        locations[.yellow] = BoardLocation(city: City(name: .mexicoCity)).add(cubes: .three, of: .yellow).1
        locations[.black] = BoardLocation(city: City(name: .algiers)).add(cubes: .three, of: .black).1
        locations[.red] = BoardLocation(city: City(name: .tokyo)).add(cubes: .three, of: .red).1
        Role.allCases.forEach
        { role in
            DiseaseColor.allCases.forEach
            { disease in
                let pawn = Pawn(role: role)
                let actions = pawn.getTreatingActions(from: locations[disease]!)
                XCTAssertEqual(actions.count, 1)
                XCTAssertEqual(actions[0], Action.general(action: .treat(disease: disease)))
            }
        }
    }
    
    func testGetTreatingActionsWithMoreThanOneTreat()
    {
        let fullDistribution = [DiseaseColor.blue: CubeCount.three, .yellow: .three,
                                .red: .three, .black: .three]
        var locations = [BoardLocation]()
        locations.append(BoardLocation(city: City(name: .atlanta)).add(cubes: fullDistribution).1)
        locations.append(BoardLocation(city: City(name: .baghdad)).add(cubes: fullDistribution).1)
        locations.append(BoardLocation(city: City(name: .tokyo)).add(cubes: fullDistribution).1)
        locations.append(BoardLocation(city: City(name: .miami)).add(cubes: fullDistribution).1)
        
        Role.allCases.forEach
        { role in
            let pawn = Pawn(role: role)
            locations.forEach
            { location in
                let actions = pawn.getTreatingActions(from: location)
                XCTAssertEqual(actions.count, 4)
                DiseaseColor.allCases.forEach
                { disease in
                        XCTAssertTrue(actions.contains(Action.general(action: .treat(disease: disease))))
                }
            }
        }
    }
    
    func testGetTreatingActionsForNoCubes()
    {
        let location = BoardLocation(city: City(name: .algiers))
        Role.allCases.forEach
        { role in
            let pawn = Pawn(role: role)
            let actions = pawn.getTreatingActions(from: location)
            XCTAssertTrue(actions.isEmpty)
        }
    }
    
    func testGetDrivingActions()
    {
        let locationGraph = LocationGraph()
        var currentLocation = locationGraph.locations[.atlanta]!
        assertCanDrive(from: currentLocation, to: [.chicago, .miami, .washington], on: locationGraph)
        
        currentLocation = locationGraph.locations[.santiago]!
        assertCanDrive(from: currentLocation, to: [.lima], on: locationGraph)
        
        currentLocation = locationGraph.locations[.istanbul]!
        assertCanDrive(from: currentLocation, to: [.moscow, .milan, .algiers, .cairo, .baghdad, .stPetersburg], on: locationGraph)
    }
    
    func testGetOtherTransportationActions()
    {
        //Testing direct flights
        let locationGraph = LocationGraph()
        let currentLocation = BoardLocation(city: City(name: .algiers))
        var currentHand: HandProtocol = Hand(card1: Card(cityName: .chicago), card2: Card(cityName: .baghdad))
        Pawn.allCases.forEach
        { pawn in
            let actions = pawn.getOtherTransportationActions(from: currentLocation, currentHand: currentHand, locationGraph: locationGraph)
            XCTAssertEqual(actions.count, 2)
            XCTAssertTrue(actions.contains(Action.general(action: .directFlight(to: .chicago))))
            XCTAssertTrue(actions.contains(Action.general(action: .directFlight(to: .baghdad))))
        }
        
        currentHand = Hand(card1: Card(cityName: .algiers), card2: Card(cityName: .baghdad))
        Pawn.allCases.forEach
        { pawn in
            let actions = pawn.getOtherTransportationActions(from: currentLocation, currentHand: currentHand, locationGraph: locationGraph)
            XCTAssertEqual(actions.count, 48)
            XCTAssertTrue(actions.contains(.general(action: .directFlight(to: .baghdad))))
            CityName.allCases.forEach
            { city in
                if city != .algiers
                {
                    XCTAssertTrue(actions.contains(.general(action: .charterFlight(to: city))), "\(city)")
                }
            }
            XCTAssertFalse(actions.contains(.general(action: .charterFlight(to: .algiers))))
        }
        
        currentHand = Hand(card1: Card(cityName: .atlanta), card2: Card(cityName: .bangkok))
        currentHand = currentHand.draw(cards: [Card(cityName: .beijing), Card(cityName: .mexicoCity),
                                               Card(cityName: .cairo), Card(cityName: .buenosAres),
                                               Card(cityName: .bogota)]).1
        Pawn.allCases.forEach
        { pawn in
            let actions = pawn.getOtherTransportationActions(from: currentLocation, currentHand: currentHand,
                                                             locationGraph: locationGraph)
            XCTAssertEqual(actions.count, 7)
            [CityName.atlanta, .bangkok, .beijing, .mexicoCity, .cairo, .buenosAres, .bogota].forEach
            { city in
                XCTAssertTrue(actions.contains(.general(action: .directFlight(to: city))), "\(city)")
            }
        }
    }
    
    func testGetCuringActions()
    {
        let cities = CityName.allCases.reduce([]) { $0 + [$1] }
        let blueCities = cities.filter {$0.color == .blue }
        let redCities = cities.filter { $0.color == .red }
        let yellowCities = cities.filter { $0.color == .yellow }
        let blackCities = cities.filter { $0.color == .black }
        
        var currentHnad = Hand().draw(cards: [])
    }
    
    func testGetCuringActionsForScientist()
    {
        
    }
    
    func testGetShareKnowledgeActions()
    {
        let currentLocation = BoardLocation(city: City(name: .atlanta))
        var currentHand = Hand(card1: Card(cityName: .atlanta), card2: Card(cityName: .algiers))
        var otherPawnHands = [Pawn: HandProtocol]()
        var otherPawnLocations = [Pawn: CityName]()
    }
    
    func testShareKnowledgeActionsWithResearcher()
    {
        
    }
    
    private func assertCanDrive(from currentLocation: BoardLocation, to cities: [CityName], on locationGraph: LocationGraph)
    {
        Role.allCases.forEach
        { role in
            let pawn = Pawn(role: role)
            let actions = pawn.getDrivingActions(from: currentLocation, on: locationGraph)
            XCTAssertEqual(actions.count, cities.count)
            cities.forEach
            { city in
                    XCTAssertTrue(actions.contains(Action.general(action: .drive(to: city))))
            }
        }
    }
}
