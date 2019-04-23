//
//  MonteCarloTreeSearch.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class MonteCarloPlannerSimpleExploration: PlannerProtocol
{
    private let utility: UtilityProtocol
    private let numberOfSimulations = 100
    
    init(utility: UtilityProtocol)
    {
        self.utility = utility
    }
    
    /**
     Evenly simulates each available action the same number of simulations and returns
     the action that leads to the best result.
    */
    func calcaulateAction(from game: PandemicSimulatorProtocol) -> Action
    {
        return game.legalActions().map
        { action -> (action: Action, successRatio: Double) in
            var wins = 0
            var trials = 0
            (0..<numberOfSimulations).forEach
            { _ in
                switch simulateRollout(for: action, in: game)
                {
                    case .win:
                        wins += 1
                        trials += 1
                    default:
                        trials += 1
                }
            }
            return (action, Double(wins) / Double(trials))
        }.max(by: { (action1, action2) -> Bool in
            return action1.successRatio > action2.successRatio
        })!.action
    }
    
    /**
     Uses the utility function to decide which actions to use in the rollout and then picks the least bad action
     based on the results.
     - Parameters:
         - action: the action being simulated
         - game: the game state where the action is being simulated.
     - Returns: the game status at the end of the game (either win or loss)
    */
    private func simulateRollout(for action: Action, in game: PandemicSimulatorProtocol) -> GameStatus
    {
        var currentGame = game
        while currentGame.gameStatus.isInProgress
        {
            currentGame = try! currentGame.execute(action: getMaxAction(for: currentGame)).0
        }
        return currentGame.gameStatus
    }
    
    /**
     Gets the action that has the highest utility based on the current utility.
     - Parameters:
        - game: the current game state
     - Returns: the action that maximizes the utilitty.
    */
    private func getMaxAction(for game: PandemicSimulatorProtocol) -> Action
    {
        return game.legalActions().map
        { action -> (action: Action, utility: UtilityValue) in
            return (action, self.utility.utility(of: try! game.execute(action: action).0))
        }.max(by:
        { (action1, action2) -> Bool in
            action1.utility < action2.utility
        })!.action
    }
}

class MonteCarloTreeSearchUCB: PlannerProtocol
{
    private let rolloutPolicy: PolicyProtocol
    ///Represents all of the visited nodes
    private var searchTree: MTSNode?
    private let iterations: Int = 10

    init(policy: PolicyProtocol)
    {
        rolloutPolicy = policy
    }
    
    func calcaulateAction(from game: PandemicSimulatorProtocol) -> Action
    {
        searchTree = MTSNode(gameState: game)
        //Handle all the simulation stuff here, including starting branches for cards
        (0..<iterations).forEach
        { _ in
            startRollout(for: getNextNode())
        }
        return searchTree!.children.max(by:
        { (actionPair1, actionPair2) -> Bool in
            return Double(actionPair1.1.totalReward) / Double(actionPair1.1.timesVisited)
                < Double(actionPair2.1.totalReward) / Double(actionPair2.1.timesVisited)
        })!.0
    }
    
    /**
     Gets the child node with the highest utc score.
    */
    private func getNextNode() -> MTSNode
    {
        return searchTree!.getBestChild()
    }
    
    private func startRollout(for node: MTSNode)
    {
        if let child = node.child(for: self.rolloutPolicy.action(for: node.gameState))
        {
            //The child has been visited before so recursively call this function on the child to find the end
            //of the visited nodes.
            startRollout(for: child)
        }
        else
        {
            //This will propogate the result up to the root node.
            node.addReward(finishRollout(node.gameState).reward)
        }
    }
    
    /**
     Computes the state of the game after following the rollout policy to a terminal state.
     - Parameters:
        - game: the current game state
     - Returns: the game status of the terminal state, either loss or a win.
    */
    private func finishRollout(_ game: PandemicSimulatorProtocol) -> GameStatus
    {
        var currentGame = game.createBranch()
        while currentGame.gameStatus.isInProgress
        {
            let action = rolloutPolicy.action(for: currentGame)
            currentGame = try! currentGame.execute(action: action).0
        }
        switch currentGame.gameStatus
        {
            case .win:
                print("there was a win")
            default:
                break
        }
        return currentGame.gameStatus
    }
}

extension GameStatus
{
    var reward: Int
    {
        switch self
        {
            case .loss:
                return -1
            case .win:
                return 1
            default:
                return 0
        }
    }
}

class MTSNode
{
    var totalReward: Int
    var timesVisited: Int
    private var parent: MTSNode?
    var children: [(Action, MTSNode)]
    var gameState: PandemicSimulatorProtocol
    private let utcConstant: Double = 1
    var fullyExplored: Bool
    {
        //This is going to be pretty slow
        if children.isEmpty
        {
            return false
        }
        return children.reduce(true)
        { result, actionPair -> Bool in
            return result && actionPair.1.timesVisited > 0
        }
    }
    
    init(gameState: PandemicSimulatorProtocol, parent: MTSNode? = nil)
    {
        self.gameState = gameState
        totalReward = 0
        timesVisited = 0
        self.parent = parent
        children = []
    }
    
    func addReward(_ reward: Int)
    {
        self.timesVisited += 1
        self.totalReward += reward
        //This will propogate it up to the root node.
        self.parent?.addReward(reward)
    }
    
    func addChild(action: Action, node: MTSNode)
    {
        self.children.append((action, node))
    }
    
    func child(for action: Action) -> MTSNode?
    {
        return self.children.first(where:
        { (action1, node) -> Bool in
            return action1 == action
        })?.1
    }
    
    var uct: Double
    {
        return Double(totalReward) / Double(timesVisited) +
            1 * sqrt(Double(log(Double(self.parent!.timesVisited))) / Double(timesVisited))
    }
    
    func getBestChild() -> MTSNode
    {
        if children.isEmpty
        {
            gameState.legalActions().forEach
            { action in
                children.append((action, MTSNode(gameState: try! gameState.execute(action: action).0, parent: self)))
            }
        }
        let bestChild = children.max(by:
            { (actionPair1, actionPair2) -> Bool in
                actionPair1.1.uct > actionPair2.1.uct
        })!.1
        if bestChild.fullyExplored
        {
            return bestChild.getBestChild()
        }
        else
        {
            return bestChild
        }
    }
}
