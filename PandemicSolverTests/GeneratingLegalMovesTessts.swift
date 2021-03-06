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
    
    func testShuttleFlights()
    {
        let currentLocation = BoardLocation(city: City(name: .atlanta)).addResearchStation()
        let currentHand = Hand()
        let locationGraph = LocationGraph()
        let locationGraphWithResearchStation = locationGraph.addResearchStation(to: .atlanta)
        let twoResearchStations = locationGraphWithResearchStation.addResearchStation(to: .algiers)
        let manyResearchStations = twoResearchStations.addResearchStation(to: .miami).addResearchStation(to: .tokyo)
            .addResearchStation(to: .sydney)
        
        Pawn.allCases.forEach
        { pawn in
            let actions = pawn.getOtherTransportationActions(from: currentLocation, currentHand: currentHand, locationGraph: locationGraph)
            XCTAssertTrue(actions.isEmpty)
        }
        
        Pawn.allCases.forEach
        { pawn in
            let actions = pawn.getOtherTransportationActions(from: currentLocation, currentHand: currentHand,
                                               locationGraph: locationGraphWithResearchStation)
            XCTAssertTrue(actions.isEmpty)
        }
        
        Pawn.allCases.forEach
        { pawn in
            let actions = pawn.getOtherTransportationActions(from: currentLocation, currentHand: currentHand, locationGraph: twoResearchStations)
            XCTAssertEqual(actions.count, 1)
            XCTAssertTrue(actions.contains(Action.general(action: .shuttleFlight(to: .algiers))))
        }
        
        Pawn.allCases.forEach
        { pawn in
            let actions = pawn.getOtherTransportationActions(from: currentLocation, currentHand: currentHand, locationGraph: manyResearchStations)
            XCTAssertEqual(actions.count, 4)
            [CityName.algiers, .miami, .tokyo, .sydney].map { Action.general(action: .shuttleFlight(to: $0)) }.forEach
            { action in
                XCTAssertTrue(actions.contains(action))
            }
        }
    }
    
    func testGetCuringActions()
    {
        let cities = CityName.allCases.reduce([]) { $0 + [$1] }
        let locationWithResearchStation = BoardLocation(city: City(name: .atlanta)).addResearchStation()
        let locationWithoutResearchStation = BoardLocation(city: City(name: .atlanta))
        let scientist = Pawn(role: .scientist)
        let relevantPawns = Pawn.allCases.filter { $0 != scientist }
        
        //Test being able to cure all the diseases
        DiseaseColor.allCases.forEach
        { disease in
            relevantPawns.forEach
            { pawn in
                let cards = Array(cities.filter {$0.color == disease}[0..<5]).map{Card(cityName: $0)}
                let hand = Hand().draw(cards: cards).1
                let curingActions = pawn.getCuringActions(from: hand, currentLocation: locationWithResearchStation)
                XCTAssertEqual(curingActions.count, 1)
                XCTAssertTrue(curingActions.contains(Action.general(action: .cure(disease: disease))))
            }
        }
        
        //Test not being able to cure because not in a research station
        DiseaseColor.allCases.forEach
        { disease in
            relevantPawns.forEach
            { pawn in
                let cards = Array(cities.filter {$0.color == disease}[0..<5]).map{Card(cityName: $0)}
                let hand = Hand().draw(cards: cards).1
                let curingActions = pawn.getCuringActions(from: hand, currentLocation: locationWithoutResearchStation)
                XCTAssertTrue(curingActions.isEmpty)
            }
        }
        
        //Test not being able to cure because not enough cards
        DiseaseColor.allCases.forEach
        { color in
            relevantPawns.forEach
            { pawn in
                let cards = Array(cities.filter { $0.color == color}[0..<4]).map { Card(cityName: $0) }
                let hand = Hand().draw(cards: cards).1
                let curingActions = pawn.getCuringActions(from: hand, currentLocation: locationWithResearchStation)
                XCTAssertTrue(curingActions.isEmpty)
            }
        }
        
        //Test not being able to cure disease because not in research station and not enough cards
        DiseaseColor.allCases.forEach
        { disease in
            relevantPawns.forEach
            { pawn in
                let cards = Array(cities.filter {$0.color == disease }[0..<4]).map {Card(cityName: $0)}
                let hand = Hand().draw(cards: cards).1
                let curingActions = pawn.getCuringActions(from: hand, currentLocation: locationWithoutResearchStation)
                XCTAssertTrue(curingActions.isEmpty)
            }
        }
    }
    
    func testGetCuringActionsForScientist()
    {
        let cities = CityName.allCases.reduce([]) {$0 + [$1]}
        let locationWithResearchStation = BoardLocation(city: City(name: .atlanta)).addResearchStation()
        let locationWithoutResearchStation = BoardLocation(city: City(name: .atlanta))
        let scientist = Pawn(role: .scientist)
        
        //Test being able to cure all the diseases
        DiseaseColor.allCases.forEach
        { disease in
            let cards = Array(cities.filter {$0.color == disease}[0..<4]).map{Card(cityName: $0)}
            let hand = Hand().draw(cards: cards).1
            let curingActions = scientist.getCuringActions(from: hand, currentLocation: locationWithResearchStation)
            XCTAssertEqual(curingActions.count, 1)
            XCTAssertTrue(curingActions.contains(Action.general(action: .cure(disease: disease))))
        }
        
        //Test not being able to cure because not in a research station
        DiseaseColor.allCases.forEach
        { disease in
            let cards = Array(cities.filter {$0.color == disease}[0..<4]).map{Card(cityName: $0)}
            let hand = Hand().draw(cards: cards).1
            let curingActions = scientist.getCuringActions(from: hand, currentLocation: locationWithoutResearchStation)
            XCTAssertTrue(curingActions.isEmpty)
        }
        
        //Test not being able to cure because not enough cards
        DiseaseColor.allCases.forEach
        { color in
            let cards = Array(cities.filter { $0.color == color}[0..<3]).map { Card(cityName: $0) }
            let hand = Hand().draw(cards: cards).1
            let curingActions = scientist.getCuringActions(from: hand, currentLocation: locationWithResearchStation)
            XCTAssertTrue(curingActions.isEmpty)
        }
        
        //Test not being able to cure disease because not in research station and not enough cards
        DiseaseColor.allCases.forEach
        { disease in
            let cards = Array(cities.filter {$0.color == disease }[0..<4]).map {Card(cityName: $0)}
            let hand = Hand().draw(cards: cards).1
            let curingActions = scientist.getCuringActions(from: hand, currentLocation: locationWithoutResearchStation)
            XCTAssertTrue(curingActions.isEmpty)
        }
    }
    
    func testGetShareKnowledgeActions()
    {
        let currentLocation = BoardLocation(city: City(name: .atlanta))
        let currentHand = Hand(card1: Card(cityName: .atlanta), card2: Card(cityName: .algiers))
        var otherPawnHands = [Pawn: HandProtocol]()
        var otherPawnLocations = [Pawn: CityName]()
        let relevantPawns = Pawn.allCases.filter { $0 != Pawn(role: .researcher) }
        
        //Testing that they can share knowledge if they have the card of the city they are in.
        relevantPawns.forEach
        { pawn in
            otherPawnHands = [Pawn: HandProtocol]()
            otherPawnLocations = [Pawn: CityName]()
            let otherPawns = Pawn.allCases.filter { $0 != pawn }
            otherPawns.forEach{ otherPawnHands[$0] = Hand(); otherPawnLocations[$0] = .atlanta }
            let actions = pawn.getShareKnowledgeActions(with: currentHand,
                                                        otherPawnHands: otherPawnHands,
                                                        currentLocation: currentLocation.city.name,
                                                        otherPawnLocations: otherPawnLocations)
            XCTAssertEqual(actions.count, 4)
            otherPawns.forEach
            { pawn in
                XCTAssertTrue(actions.contains(Action.general(action: .shareKnowledge(card: Card(cityName: .atlanta),
                                                                                      pawn: pawn))))
            }
        }
        
        //Testing that they can take a card from another pawn if they are in the same city.
        relevantPawns.forEach
        { pawn in
            otherPawnHands = [Pawn: HandProtocol]()
            otherPawnLocations = [Pawn: CityName]()
            let otherPawns = Pawn.allCases.filter { $0 != pawn }
            otherPawns.forEach{ otherPawnHands[$0] = Hand().draw(card: Card(cityName: .atlanta)).1; otherPawnLocations[$0] = .atlanta }
            let actions = pawn.getShareKnowledgeActions(with: Hand(), otherPawnHands: otherPawnHands,
                                                        currentLocation: currentLocation.city.name,
                                                        otherPawnLocations: otherPawnLocations)
            XCTAssertEqual(actions.count, otherPawns.count)
            otherPawns.forEach
            { otherPawns in
                XCTAssertTrue(actions.contains(Action.general(action: .shareKnowledge(card: Card(cityName: .atlanta),
                                                                                      pawn: otherPawns))))
            }
        }
        
        //Test that they can't share knowledge if they have the card of the city they are in but no one else is there.
        Pawn.allCases.forEach
        { pawn in
            otherPawnHands = [Pawn: HandProtocol]()
            otherPawnLocations = [Pawn: CityName]()
            let otherPawns = Pawn.allCases.filter { $0 != pawn }
            otherPawns.forEach {otherPawnHands[$0] = Hand(); otherPawnLocations[$0] = .chennai}
            let actions = pawn.getShareKnowledgeActions(with: currentHand, otherPawnHands: otherPawnHands, currentLocation: currentLocation.city.name, otherPawnLocations: otherPawnLocations)
            XCTAssertTrue(actions.isEmpty)
        }
        
        //Test that they can't share knowledge if someone has a card of a city they are in but they aren't in the same city.
        Pawn.allCases.forEach
        { pawn in
            otherPawnHands = [Pawn: HandProtocol]()
            otherPawnLocations = [Pawn: CityName]()
            let otherPawns = Pawn.allCases.filter { $0 != pawn }
            otherPawns.forEach {
                otherPawnHands[$0] = Hand(card1: Card(cityName: .tokyo), card2: Card(cityName: .baghdad))
                otherPawnLocations[$0] = .tokyo
            }
            let actions = pawn.getShareKnowledgeActions(with: currentHand, otherPawnHands: otherPawnHands,
                                                        currentLocation: currentLocation.city.name,
                                                        otherPawnLocations: otherPawnLocations)
            XCTAssertTrue(actions.isEmpty)
        }
        
        //Check can't share info if no one has the right card.
        relevantPawns.forEach
        { pawn in
            otherPawnHands = [Pawn: HandProtocol]()
            otherPawnLocations = [Pawn: CityName]()
            let otherPawns = Pawn.allCases.filter { $0 != pawn }
            otherPawns.forEach {
                otherPawnHands[$0] = Hand(card1: Card(cityName: .tokyo), card2: Card(cityName: .taipei))
                otherPawnLocations[$0] = .atlanta
            }
            let actions = pawn.getShareKnowledgeActions(with: Hand(card1: Card(cityName: .baghdad), card2: Card(cityName: .seoul)),
                                                        otherPawnHands: otherPawnHands,
                                                        currentLocation: currentLocation.city.name,
                                                        otherPawnLocations: otherPawnLocations)
            XCTAssertTrue(actions.isEmpty)
        }
    }
    
    func testShareKnowledgeActionsWithResearcher()
    {
        //Test can give any card in hand to any player in the same city
        let researcher = Pawn(role: .researcher)
        let relevantPawns = Pawn.allCases.filter { $0 != researcher }
        var otherPawnHands = [Pawn: HandProtocol]()
        var otherPawnLocations = [Pawn: CityName]()
        relevantPawns.forEach {
            otherPawnHands[$0] = Hand(card1: Card(cityName: .algiers), card2: Card(cityName: .baghdad))
            otherPawnLocations[$0] = .atlanta
        }
        let actions = researcher.getShareKnowledgeActions(with: Hand(card1: Card(cityName: .algiers), card2: Card(cityName: .tokyo)),
                                                          otherPawnHands: otherPawnHands,
                                                          currentLocation: .atlanta,
                                                          otherPawnLocations: otherPawnLocations)
        XCTAssertEqual(actions.count, 8)
        relevantPawns.forEach
        { pawn in
            XCTAssertTrue(actions.contains(Action.general(action: .shareKnowledge(card: Card(cityName: .algiers), pawn: pawn))))
            XCTAssertTrue(actions.contains(Action.general(action: .shareKnowledge(card: Card(cityName: .tokyo), pawn: pawn))))
        }
    }
    
    func testDispatcherMoves()
    {
        var otherPawnLocations = [Pawn: CityName]()
        let currentHand = Hand().draw(cards: [Card(cityName: .algiers), Card(cityName: .baghdad)]).1
        let cities = [CityName.santiago, .saoPaulo, .sydney, .mumbai]
        var position = 0
        let dispatcher = Pawn(role: .dispatcher)
        otherPawnLocations[dispatcher] = .atlanta
        Pawn.allCases.filter { $0 != dispatcher }.forEach { otherPawnLocations[$0] = cities[position]; position += 1 }
        let locationGraph = LocationGraph().addResearchStation(to: .baghdad).addResearchStation(to: .tehran)
            .addResearchStation(to: .sanFrancisco)
        
        //Test that if you aren't the dispatcher you don't have any moves
        Pawn.allCases.filter { $0 != dispatcher }.forEach
        { pawn in
            XCTAssertTrue(pawn.getDispatcherMoves(otherPawnLocations: otherPawnLocations,
                                                  currentHand: currentHand,
                                                  on: locationGraph).isEmpty)
        }
        
        //Test dispatcher moves with empty hand
        let actions = dispatcher.getDispatcherMoves(otherPawnLocations: otherPawnLocations,
                                                    currentHand: Hand(), on: locationGraph)
        XCTAssertEqual(actions.count, cities.reduce(0)
        { result, city -> Int in
            return result + locationGraph.edges[city]!.count
        } + Pawn.allCases.count * (Pawn.allCases.count - 1))
        
        position = 0
        Pawn.allCases.forEach
        { pawn in
            if pawn != dispatcher
            {
                locationGraph.edges[cities[position]]!.forEach
                { city in
                        XCTAssertTrue(actions.contains(Action.dispatcher(action:
                            .control(pawn: pawn, action: Action.general(action: .drive(to: city))))),
                                      "\(pawn), \(city)")
                }
                position += 1
            }
        }
        Pawn.allCases.forEach
        { pawn in
            Pawn.allCases.forEach
            { otherPawn in
                if pawn != otherPawn
                {
                    XCTAssertTrue(actions.contains(Action.dispatcher(action: .snap(pawn: pawn, to: otherPawn))))
                }
            }
        }
        
        //Test flying with cards in dispatcher hand
        otherPawnLocations = [Pawn: CityName]()
        let medic = Pawn(role: .medic)
        otherPawnLocations[medic] = .baghdad
        otherPawnLocations[dispatcher] = .miami
        let actions2 = dispatcher.getDispatcherMoves(otherPawnLocations: otherPawnLocations, currentHand: currentHand,
                                                     on: locationGraph)
        // There should be one where dispatchers snaps to medic and one for the oposite.
        let snappingActions = 2
        //The other card will be used for the non-direct flights
        let directFlights = currentHand.cards.count - 1
        //Charter flights, should be all cities except for the one they are in
        let charterFlights = CityName.allCases.count - 1
        //Also adding a shuttle flight should have two options
        let shuttleFlight = 2
        //Regular moves.
        let regularMoves = locationGraph.edges[.baghdad]!.count
        XCTAssertEqual(actions2.count, snappingActions + directFlights + charterFlights + shuttleFlight + regularMoves)
        XCTAssertTrue(actions2.contains(Action.dispatcher(action: .snap(pawn: medic, to: dispatcher))))
        XCTAssertTrue(actions2.contains(Action.dispatcher(action: .snap(pawn: dispatcher, to: medic))))
        XCTAssertTrue(actions2.contains(Action.dispatcher(action: .control(pawn: medic, action: .general(action: .directFlight(to: .algiers))))))
        CityName.allCases.forEach
        { city in
            if city != .baghdad
            {
                XCTAssertTrue(actions2.contains(Action.dispatcher(action:
                    .control(pawn: medic, action: .general(action: .charterFlight(to: city))))))
            }
        }
        locationGraph.getAllResearchStations().forEach
        { location in
            if location.city.name != .baghdad
            {
                XCTAssertTrue(actions2.contains(Action.dispatcher(action:
                    .control(pawn: medic, action: .general(action: .shuttleFlight(to: location.city.name))))))
            }
        }
        locationGraph.edges[.baghdad]!.forEach
        { city in
            XCTAssertTrue(actions2.contains(Action.dispatcher(action:
                .control(pawn: medic, action: .general(action: .drive(to: city))))))
        }
    }
    
    func testBuildingResearchStations()
    {
        var hands = [Pawn: HandProtocol]()
        let hand = Hand(card1: Card(cityName: .atlanta), card2: Card(cityName: .baghdad))
        var otherPawnLocation = [Pawn: CityName]()
        Pawn.allCases.forEach
        { pawn in
            hands[pawn] = Hand(card1: Card(cityName: .atlanta), card2: Card(cityName: .baghdad))
            otherPawnLocation[pawn] = .atlanta
        }
        let locationGraph = LocationGraph()
        let currentLocation = BoardLocation(city: City(name: .atlanta))
        
        //Check that they all can when they are in the city where their card is
        Pawn.allCases.forEach
        { pawn in
            XCTAssertTrue(pawn.getLegalMoves(for: locationGraph, with: hand, currentLocation: currentLocation, otherPawnLocations: otherPawnLocation, pawnHands: hands).contains(.general(action: .buildResearchStation)))
        }
        
        //Check that they all cannot when they are not in the city with their card (except ops expert)
        Pawn.allCases.filter{ $0.role != .operationsExpert }.forEach
        { pawn in
            XCTAssertFalse(pawn.getLegalMoves(for: locationGraph, with: hand,
                                              currentLocation: BoardLocation(city: City(name: .bangkok)),
                                              otherPawnLocations: otherPawnLocation,
                                              pawnHands: hands).contains(.general(action: .buildResearchStation)))
        }
        
        //Check that the ops expert can build a research station without a card in his hand
        XCTAssertTrue(Pawn(role: .operationsExpert).getLegalMoves(for: locationGraph, with: hand,
                                                                  currentLocation: BoardLocation(city: City(name: .cairo)),
                                                                  otherPawnLocations: otherPawnLocation,
                                                                  pawnHands: hands).contains(.general(action: .buildResearchStation)))
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
