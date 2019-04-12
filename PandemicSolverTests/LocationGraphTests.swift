//
//  LocationGraphTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class LocationGraphTests: XCTestCase {
    var edges: [CityName: [CityName]]!
    var locations: [CityName: BoardLocation]!
    var sut: LocationGraph!
    
    override func setUp()
    {
        self.edges = GameStartHelper.generateEdgeDictionary()
        self.locations = GameStartHelper.generateLocationsMap()
        sut = LocationGraph()
    }
    
    func testInitEdges()
    {
        edges.forEach
        { (key: CityName, value: [CityName]) in
            value.forEach
            { name in
                if (!(edges[name]?.contains(key) ?? true))
                {
                    print(name, key)
                }
                XCTAssertTrue(edges[name]?.contains(key) ?? false)
            }
        }
    }
    
    func testInitLocatitons()
    {
        XCTAssertEqual(locations.count, 48)
        locations.forEach
        { (cityName, location) in
            XCTAssertEqual(cityName, location.city.name)
            XCTAssertEqual(cityName.color, location.city.color)
            XCTAssertEqual(location.cubes.red, .zero)
            XCTAssertEqual(location.cubes.yellow, .zero)
            XCTAssertEqual(location.cubes.blue, .zero)
            XCTAssertEqual(location.cubes.black, .zero)
        }
    }
    
    func testAddingCubes()
    {
        let (outbreakCities, sut1) = sut.place(CubeCount.one, of: DiseaseColor.blue, on: CityName.atlanta)
        XCTAssertTrue(outbreakCities.isEmpty)
        assertDiseaseCounts(of: sut1.locations[.atlanta]!, blue: .one)
        CityName.allCases.forEach
        { name in
            if name != .atlanta
            {
                assertDiseaseCounts(of: sut1.locations[name]!)
            }
        }
        
        
        let (outbreakCities1, sut2) = sut1.place(CubeCount.three, of: .blue, on: .atlanta)
        XCTAssertEqual(outbreakCities1, [.atlanta])
        assertDiseaseCounts(of: sut2.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.chicago]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.washington]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.miami]!, blue: .one)
        CityName.allCases.forEach 
        { city in
            if city != .atlanta && city != .chicago && city != .washington && city != .miami
            {
                assertDiseaseCounts(of: sut2.locations[city]!)
            }
        }
    }
    
    func testDoubleOutbreakOfSameColor()
    {
        let (_, sut1) = sut.place(.three, of: .blue, on: .atlanta).1.place(.three, of: .blue, on: .chicago)
        let (outbreakCities1, sut2) = sut1.place(.one, of: .blue, on: .atlanta)
        XCTAssertEqual(outbreakCities1, [.atlanta, .chicago])
        assertDiseaseCounts(of: sut2.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.chicago]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.washington]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.miami]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.sanFrancisco]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.losAngeles]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.mexicoCity]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.toronto]!, blue: .one)
        CityName.allCases.forEach
            { city in
                if city != .atlanta && city != .chicago && city != .washington && city != .miami && city != .sanFrancisco
                    && city != .losAngeles && city != .mexicoCity && city != .toronto
                {
                    assertDiseaseCounts(of: sut2.locations[city]!)
                }
        }
    }
    
    func testTripleOutbreakSameColor()
    {
        let (_, sut1) = sut.place(.three, of: .blue, on: .atlanta).1.place(.three, of: .blue, on: .chicago)
            .1.place(.three, of: .blue, on: .washington)
        let (outbreaks, sut2) = sut1.place(.one, of: .blue, on: .chicago)
        XCTAssertEqual(outbreaks, [.chicago, .atlanta, .washington])
        assertDiseaseCounts(of: sut2.locations[.chicago]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.washington]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.miami]!, blue: .two)
        assertDiseaseCounts(of: sut2.locations[.newYork]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.sanFrancisco]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.losAngeles]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.mexicoCity]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.toronto]!, blue: .two)
        CityName.allCases.forEach
        { city in
            if ![CityName.chicago, .washington, .atlanta, .miami, .newYork, .sanFrancisco, .losAngeles, .mexicoCity, .toronto].contains(city)
            {
                assertDiseaseCounts(of: sut2.locations[city]!)
            }
        }
    }
    
    func testBasicMutliCityInfection()
    {
        let (_, sut1) = sut.place(cubes: [CubePlacement(city: .atlanta, disease: .blue, cubes: .three),
                                          CubePlacement(city: .tehran, disease: .black, cubes: .three),
                                          CubePlacement(city: .tokyo, disease: .red, cubes: .three)])
        assertDiseaseCounts(of: sut1.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut1.locations[.tehran]!, black: .three)
        assertDiseaseCounts(of: sut1.locations[.tokyo]!, red: .three)
        CityName.allCases.forEach
        { city in
            if ![CityName.atlanta, .tehran, .tokyo].contains(city)
            {
                assertDiseaseCounts(of: sut1.locations[city]!)
            }
        }
    }
    
    func testDoubleOutbreakWithOutbreakCausedByOneInfection()
    {
        let(_, sut1) = sut.place(cubes: [CubePlacement(city: .atlanta, disease: .blue, cubes: .three),
                                         CubePlacement(city: .chicago, disease: .blue, cubes: .three)])
        let (outbreaks, sut2) = sut1.place(cubes: [CubePlacement(city: .tehran, disease: .black, cubes: .one),
                                                   CubePlacement(city: .atlanta, disease: .blue, cubes: .three)])
        XCTAssertEqual(outbreaks, [.atlanta, .chicago])
        assertDiseaseCounts(of: sut2.locations[.tehran]!, black: .one)
        assertDiseaseCounts(of: sut2.locations[.chicago]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.miami]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.washington]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.sanFrancisco]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.losAngeles]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.mexicoCity]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.toronto]!, blue: .one)
        CityName.allCases.forEach
        { city in
            if ![CityName.atlanta, .tehran, .chicago, .miami, .washington, .sanFrancisco, .losAngeles, .mexicoCity, .toronto].contains(city)
            {
                assertDiseaseCounts(of: sut2.locations[city]!)
            }
        }
    }
    
    func testDoubleOutbreakCausedByTwoInfection()
    {
        let(_, sut1) = sut.place(cubes: [CubePlacement(city: .atlanta, disease: .blue, cubes: .three),
                                         CubePlacement(city: .chicago, disease: .blue, cubes: .three)])
        let (outbreaks, sut2) = sut1.place(cubes: [CubePlacement(city: .tehran, disease: .black, cubes: .one),
                                                   CubePlacement(city: .atlanta, disease: .blue, cubes: .one),
                                                   CubePlacement(city: .chicago, disease: .blue, cubes: .one)])
        XCTAssertEqual(outbreaks, [.atlanta, .chicago])
        assertDiseaseCounts(of: sut2.locations[.tehran]!, black: .one)
        assertDiseaseCounts(of: sut2.locations[.chicago]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.miami]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.washington]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.sanFrancisco]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.losAngeles]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.mexicoCity]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.toronto]!, blue: .one)
        CityName.allCases.forEach
            { city in
                if ![CityName.atlanta, .tehran, .chicago, .miami, .washington, .sanFrancisco, .losAngeles, .mexicoCity, .toronto].contains(city)
                {
                    assertDiseaseCounts(of: sut2.locations[city]!)
                }
        }
    }
    
    func testThreeCitiesOutbreakInOneInfectionStage()
    {
        let(_, sut1) = sut.place(cubes: [CubePlacement(city: .atlanta, disease: .blue, cubes: .three),
                                         CubePlacement(city: .toronto, disease: .blue, cubes: .three),
                                         CubePlacement(city: .washington, disease: .blue, cubes: .three)])
        let (outbreaks, sut2) = sut1.place(cubes: [CubePlacement(city: .atlanta, disease: .blue, cubes: .one),
                                                   CubePlacement(city: .washington, disease: .blue, cubes: .one),
                                                   CubePlacement(city: .toronto, disease: .blue, cubes: .one)])
        XCTAssertEqual(outbreaks, [.atlanta, .washington, .toronto])
        assertDiseaseCounts(of: sut2.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.toronto]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.washington]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.newYork]!, blue: .two)
        assertDiseaseCounts(of: sut2.locations[.chicago]!, blue: .two)
        assertDiseaseCounts(of: sut2.locations[.miami]!, blue: .two)
        CityName.allCases.forEach
        { city in
            if ![CityName.atlanta, .toronto, .washington, .newYork, .chicago, .miami].contains(city)
            {
                assertDiseaseCounts(of: sut2.locations[city]!)
            }
        }
    }
    
    func testRemoveCubes()
    {
        let(_, sut1) = sut.place(cubes: [CubePlacement(city: .atlanta, disease: .blue, cubes: .three),
                                         CubePlacement(city: .toronto, disease: .blue, cubes: .three),
                                         CubePlacement(city: .washington, disease: .blue, cubes: .one)])
        let sut2 = sut1.removeCubes(.two, of: .blue, on: .toronto)
        assertDiseaseCounts(of: sut2.locations[.toronto]!, blue: .one)
        assertDiseaseCounts(of: sut2.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut2.locations[.washington]!, blue: .one)
        CityName.allCases.forEach
        { city in
            if ![CityName.toronto, .atlanta, .washington].contains(city)
            {
                assertDiseaseCounts(of: sut2.locations[city]!)
            }
        }
        
        let sut3 = sut1.removeCubes(.three, of: .blue, on: .washington)
        assertDiseaseCounts(of: sut3.locations[.toronto]!, blue: .three)
        assertDiseaseCounts(of: sut3.locations[.atlanta]!, blue: .three)
        assertDiseaseCounts(of: sut3.locations[.washington]!, blue: .zero)
        CityName.allCases.forEach
            { city in
                if ![CityName.toronto, .atlanta, .washington].contains(city)
                {
                    assertDiseaseCounts(of: sut3.locations[city]!)
                }
        }
    }
    
    func testAddingResearchStations()
    {
        sut.locations.values.forEach
        { location in
            XCTAssertFalse(location.hasResearchStation)
        }
        
        let sut1 = sut.addResearchStation(to: .algiers)
        sut1.locations.values.forEach
        { location in
            if location.city.name != .algiers
            {
                XCTAssertFalse(location.hasResearchStation)
            }
        }
        XCTAssertTrue(sut1.locations[.algiers]!.hasResearchStation)
        
        let sut2 = sut1.addResearchStation(to: .atlanta)
        sut2.locations.values.forEach
        { location in
            if location.city.name != .atlanta && location.city.name != .algiers
            {
                XCTAssertFalse(location.hasResearchStation, "\(location.city.name)")
            }
        }
        XCTAssertTrue(sut2.locations[.algiers]!.hasResearchStation)
        XCTAssertTrue(sut2.locations[.atlanta]!.hasResearchStation)
    }
    
    func testResearchStations()
    {
        XCTAssertTrue(sut.getAllResearchStations().isEmpty)
        let sut1 = sut.addResearchStation(to: .atlanta)
        var researchStations = sut1.getAllResearchStations()
        XCTAssertEqual(researchStations.count, 1)
        XCTAssertEqual(researchStations[0].city.name, .atlanta)
        XCTAssertTrue(researchStations[0].hasResearchStation)
        
        let sut2 = sut1.addResearchStation(to: .madrid)
        researchStations = sut2.getAllResearchStations()
        XCTAssertEqual(researchStations.count, 2)
        XCTAssertTrue(researchStations.contains(where: {$0.city.name == .atlanta}))
        XCTAssertTrue(researchStations.contains(where: {$0.city.name == .madrid}))
        researchStations.forEach
        { location in
            XCTAssertTrue(location.hasResearchStation)
        }
    }
    
    func testCubesRemaining()
    {
        XCTAssertEqual(sut.cubesRemaining[.red]!, 24)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 24)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 24)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 24)
        
        sut = sut.place(.one, of: .blue, on: .madrid).graph
        XCTAssertEqual(sut.cubesRemaining[.red]!, 24)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 24)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 24)
        
        sut = sut.place(.three, of: .yellow, on: .saoPaulo).graph
        XCTAssertEqual(sut.cubesRemaining[.red]!, 24)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 21)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 24)
        
        sut = sut.place(.two, of: .black, on: .karachi).graph
        XCTAssertEqual(sut.cubesRemaining[.red]!, 24)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 21)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 22)
        
        sut = sut.place(.two, of: .red, on: .tokyo).graph
        XCTAssertEqual(sut.cubesRemaining[.red]!, 22)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 21)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 22)
        
        sut = sut.place(.three, of: .blue, on: .washington).graph
        XCTAssertEqual(sut.cubesRemaining[.red]!, 22)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 21)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 20)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 22)
        
        sut = sut.removeCubes(.two, of: .blue, on: .washington)
        XCTAssertEqual(sut.cubesRemaining[.red]!, 22)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 21)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 22)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 22)
        
        sut = sut.removeCubes(.one, of: .red, on: .tokyo)
        XCTAssertEqual(sut.cubesRemaining[.red]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 21)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 22)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 22)
        
        sut = sut.removeCubes(.two, of: .yellow, on: .saoPaulo)
        XCTAssertEqual(sut.cubesRemaining[.red]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 22)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 22)
        
        sut = sut.removeCubes(.two, of: .black, on: .karachi)
        XCTAssertEqual(sut.cubesRemaining[.red]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.yellow]!, 23)
        XCTAssertEqual(sut.cubesRemaining[.blue]!, 22)
        XCTAssertEqual(sut.cubesRemaining[.black]!, 24)
    }
    
    func testHasValidCubeCount()
    {
        XCTAssertTrue(sut.hasValidCubeCount)
        
        var newSut = sut.place(.three, of: .blue, on: .washington).graph
        newSut = newSut.place(.three, of: .blue, on: .newYork).graph
        newSut = newSut.place(.three, of: .blue, on: .chicago).graph
        newSut = newSut.place(.three, of: .blue, on: .sanFrancisco).graph
        newSut = newSut.place(.three, of: .blue, on: .madrid).graph
        newSut = newSut.place(.three, of: .blue, on: .london).graph
        newSut = newSut.place(.three, of: .blue, on: .stPetersburg).graph
        newSut = newSut.place(.three, of: .blue, on: .toronto).graph
        
        XCTAssertEqual(newSut.cubesRemaining[.blue]!, 0)
        XCTAssertFalse(newSut.hasValidCubeCount)
        
        newSut = sut.place(.three, of: .yellow, on: .saoPaulo).graph
        newSut = newSut.place(.three, of: .yellow, on: .buenosAres).graph
        newSut = newSut.place(.three, of: .yellow, on: .losAngeles).graph
        newSut = newSut.place(.three, of: .yellow, on: .santiago).graph
        newSut = newSut.place(.three, of: .yellow, on: .johannesburg).graph
        newSut = newSut.place(.three, of: .yellow, on: .khartoum).graph
        newSut = newSut.place(.three, of: .yellow, on: .lima).graph
        newSut = newSut.place(.three, of: .yellow, on: .lagos).graph
        
        XCTAssertEqual(newSut.cubesRemaining[.yellow]!, 0)
        XCTAssertFalse(newSut.hasValidCubeCount)
        
        newSut = sut.place(.three, of: .red, on: .tokyo).graph
        newSut = newSut.place(.three, of: .red, on: .beijing).graph
        newSut = newSut.place(.three, of: .red, on: .shanghai).graph
        newSut = newSut.place(.three, of: .red, on: .hongKong).graph
        newSut = newSut.place(.three, of: .red, on: .manila).graph
        newSut = newSut.place(.three, of: .red, on: .sydney).graph
        newSut = newSut.place(.three, of: .red, on: .jakarta).graph
        newSut = newSut.place(.three, of: .red, on: .bangkok).graph
        
        XCTAssertEqual(newSut.cubesRemaining[.red]!, 0)
        XCTAssertFalse(newSut.hasValidCubeCount)
        
        newSut = sut.place(.three, of: .black, on: .baghdad).graph
        newSut = newSut.place(.three, of: .black, on: .algiers).graph
        newSut = newSut.place(.three, of: .black, on: .moscow).graph
        newSut = newSut.place(.three, of: .black, on: .tehran).graph
        newSut = newSut.place(.three, of: .black, on: .karachi).graph
        newSut = newSut.place(.three, of: .black, on: .delhi).graph
        newSut = newSut.place(.three, of: .black, on: .chennai).graph
        newSut = newSut.place(.three, of: .black, on: .riyadh).graph
        
        XCTAssertEqual(newSut.cubesRemaining[.black]!, 0)
        XCTAssertFalse(newSut.hasValidCubeCount)
    }
    
    private func assertDiseaseCounts(of boardLocation: BoardLocation, red: CubeCount = .zero,
                                     yellow: CubeCount = .zero,
                                     blue: CubeCount = .zero,
                                     black: CubeCount = .zero)
    {
        XCTAssertEqual(boardLocation.cubes.red, red)
        XCTAssertEqual(boardLocation.cubes.yellow, yellow)
        XCTAssertEqual(boardLocation.cubes.blue, blue)
        if (boardLocation.cubes.blue != blue)
        {
            print(boardLocation.city.name)
        }
        XCTAssertEqual(boardLocation.cubes.black, black)
    }
}
