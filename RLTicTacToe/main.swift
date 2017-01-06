//
//  main.swift
//  RLTicTacToe
//
//  Created by Jeff Tang on 10/16/16.
//  Copyright © 2016 Jeff Tang. All rights reserved.
//

import Foundation



let dimension = 3 // maybe we can play 4x4 or 5x5 TicTacToeT..
let alpha : Float = 0.1 // learning rate, or step size parameter in RL


// save/retrieve the state array unique_states with NSUserDefaults
class State : NSObject{
    var pieces: [Int] = [] // decides what a state looks like
    var my_move: Bool // this is not really needed as it can be inferred from the number of non-0's in pieces
    var value: Float = 0.0 // initial value for all states, meaning 50% of winning from the state; value means the latest estimate of the probability of our X's winning from that state.
    
    // the constructor used ONLY when creating the initial state
    init(pieces: [Int], my_move: Bool, value: Float) {
        self.pieces = pieces
        self.my_move = my_move
        self.value = value
    }
    
    // the contructor used when we need to make a copy of a state to, e.g., add to a list of states to decide the move with the highest value from all possible next moves
    init(state: State) {
        self.pieces = state.pieces
        self.my_move = state.my_move
        self.value = state.value
    }
    
    override var hashValue: Int {
        var hval = pieces[0].hashValue
        for i in 1...pieces.count-1 {
            hval = hval ^ pieces[i].hashValue
        }
        return hval
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? State {
            if other.pieces == self.pieces {
                return true
            }
        }
        return false
    }
    
    init(coder decoder: NSCoder) {
        self.pieces = decoder.decodeObjectForKey("pieces") as! [Int]
        self.my_move = decoder.decodeBoolForKey("my_move")
        self.value = decoder.decodeFloatForKey("value")
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.pieces, forKey: "pieces")
        coder.encodeBool(Bool(self.my_move), forKey: "my_move")
        coder.encodeFloat(Float(self.value), forKey: "value")
    }
}


var unique_states = [State]()
var game_states = [State]()
var initial_state: State?


func win(state: State, byme: Bool) -> Bool {
    var result = true
    let v = (byme ? 1 : 2)

    // 8 (dimension*2+2) cases of win or lose
    for i in 0...dimension-1 {
        result = result && (state.pieces[i] == v) // first row
    }
    if result {
        return true
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[dimension + i] == v) // second row
    }
    if result {
        return true
    }

    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[dimension*2 + i] == v) // third row
    }
    if result {
        return true
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[i*dimension] == v) // first column
    }
    if result {
        return true
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[1 + i*dimension] == v) // second column
    }
    if result {
        return true
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[2 + i*dimension] == v) // third column
    }
    if result {
        return true
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[i*(dimension+1)] == v) // forward slash diagnoal (0,4,8)
    }
    if result {
        return true
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[(i+1)*(dimension-1)] == v) // backward slash diagnoal (2,4,6)
    }
    if result {
        return true
    }
    
    
    return false;
}

// value means the latest estimate of the probability of our X's winning from that state.
func valueOfState(state: State) -> Float {
    var result = true
    let v = (state.my_move ? 2 : 1)
    
    // 8 (dimension*2+2) cases of win or lose
    for i in 0...dimension-1 {
        result = result && (state.pieces[i] == v) // first row
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[dimension + i] == v) // second row
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[dimension*2 + i] == v) // third row
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[i*dimension] == v) // first column
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[1 + i*dimension] == v) // second column
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[2 + i*dimension] == v) // third column
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[i*(dimension+1)] == v) // forward slash diagnoal (0,4,8)
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    result = true
    for i in 0...dimension-1 {
        result = result && (state.pieces[(i+1)*(dimension-1)] == v) // backward slash diagnoal (2,4,6)
    }
    if result {
        return state.my_move ? 0.0 : 1.0
    }
    
    
    return 0.5
}



func next_states( current_state: State) -> [State] {
    var states = [State]()
    let state = current_state  // Swift 3.0 - has to use a local variable to modify the parameter
    
    for i in 0...(dimension*dimension-1) {
        if state.pieces[i] == 0 { // found a blank piece
            // set a next possible state based on the current state
            state.pieces[i] = state.my_move ? 1 : 2 // 1 is X and 2 is O
            state.value = valueOfState(state) // possible values are 1.0, 0.0, or 0.5
            state.my_move = !state.my_move
            
            // only add non-terminal states
            if state.value == 0.5 && blank_count(state) > 0 {
                states.append(State(state: state))
            }
            
            // restore current state to set the next possible move
            state.pieces[i] = 0
            state.my_move = !state.my_move
        }
    }
    
    return states
}

func state_value(state: State) -> Float {
    // search in unique_states for state's value
    for s in unique_states {
        if s.pieces == state.pieces {
            return s.value
        }
    }
    
    return valueOfState(state)
}

// most of the time, select the move with the highest value from all possible next moves - so-called exploitation.
// TODO: add exploration occasionally.
func select_next_best_move(current_state: State) -> State {
    let state = current_state
    var max_val: Float = 0.0
    
    var states = [State]()
    
    for i in 0...(dimension*dimension-1) {
        if state.pieces[i] == 0 {
            state.pieces[i] = state.my_move ? 1 : 2 // 1 is X and 2 is O
            state.my_move = !state.my_move
            state.value = state_value(state)
            
            if state.value == 0.0 || state.value == 1.0 {
                return state
            }
            
            if state.value >= max_val {
                max_val = state.value
                if states.count == 0 || states[0].value == state.value {
                    states.append(State(state: state))
                }
                else { // found a new max, so only keep it (and others with the same value)
                    states.removeAll()
                    states.append(State(state: state))
                }
            }
            
            // restore current state to set the next possible move
            state.pieces[i] = 0
            state.my_move = !state.my_move
        }
    }
    
    // most of the time, select the highest value among states
    let random = arc4random_uniform(UInt32(states.count)) // if states has more than one state with the same value, randomly pick one
    return states[Int(random)]
    
    // TODO: occasionally, select randomly from other moves with lower values
}


func select_next_random_move(current_state: State) -> State {
    let state = current_state
    var states = [State]()
    
    for i in 0...(dimension*dimension-1) {
        if state.pieces[i] == 0 {
            state.pieces[i] = state.my_move ? 1 : 2 // 1 is X and 2 is O
            state.my_move = !state.my_move
            state.value = state_value(state)
            
            states.append(State(state: state))
            
            // restore current state to set the next possible move
            state.pieces[i] = 0
            state.my_move = !state.my_move
        }
    }
    
    let random = arc4random_uniform(UInt32(states.count))
    return states[Int(random)]
}


// recursive func starting with initial state ending with final state (win, loss, or draw)
// also for each func call, do the TD(0) update backwards on the previous state, if any, of next state
func self_play(state: State, random_move: Bool, value_update: Bool) -> Float {
    let next_state = random_move ? select_next_random_move(State(state: state)) : select_next_best_move(State(state: state))
//    print("<<<\(next_state.pieces), \(next_state.value), \(next_state.my_move)")
    
    // update value one-step (not all the way) backwards (in unique_states) after each move (mine or the opponent's)
    // AND only update the moves made by my move
    if next_state.my_move == false {
        game_states.append(next_state)
    }
    if value_update && game_states.count > 1 {
        for s1 in unique_states {
            if s1.pieces == next_state.pieces {
                let current_state = game_states[game_states.count - 2] // current_state is the state before next_state
                for (index, s2) in unique_states.enumerate() {
                    if s2.pieces == current_state.pieces {
//                        print("$$$\(unique_states[index].pieces), \(unique_states[index].value)")
                        unique_states[index].value = s2.value + alpha * (s1.value - s2.value) // the TD(0) update with Reward=0, gamma = 1 (no discount)
                        break
                    }
                }
                break
            }
        }
    }
    
    if next_state.value == 0.0 || next_state.value == 1.0  || blank_count(next_state) == 0 {
        
        if next_state.value == 0.0 {
            return 0.0
        }
        else if next_state.value == 1.0 {
            return 1.0
        }
        else {
            return 0.5
        }
    }
    
    return self_play(next_state, random_move: random_move, value_update: value_update)
}

func play_with_human(state: State) {
    print("\(state.pieces[0]) \(state.pieces[1]) \(state.pieces[2])")
    print("\(state.pieces[3]) \(state.pieces[4]) \(state.pieces[5])")
    print("\(state.pieces[6]) \(state.pieces[7]) \(state.pieces[8])")
    
    // TODO: check if state is final (WIN, LOSS, DRAW) and if so, end.
    if valueOfState(state) == 1.0 {
        print("Computer Won!")
        return
    }
    else if valueOfState(state) == 0.0 {
        print("Computer Lost!")
        return
    }
    else if blank_count(state) == 0 {
        print("Draw")
        return
    }
    
    if state.my_move {
        let next_state = select_next_best_move(State(state: state))
        print("After Computer Move: ")
        
        play_with_human(next_state)
    }
    else {
        print("Enter your move: ")
        while true {
            let line = readLine()
            if let n = Int(line!) {
                if state.pieces[n-1] != 0 {
                    print("Position already occupied. Reenter: ")
                }
                else {
                    let next_state = State(state: state)
                    next_state.pieces[n-1] = 2
                    next_state.my_move = !state.my_move
                    next_state.value = 0.5
                    print("After Human Move:")
                    play_with_human(next_state)
                    break
                }
            }
            else {
                
                print("Enter a number 1-9")            }
        }
    }
    
}

func blank_count(state: State) -> Int {
    var zero_count = 0
    for i in 0...(dimension*dimension-1) {
        if state.pieces[i] == 0 {
            zero_count += 1
        }
    }
    return zero_count
}

// get all possible and unique states of the tic-tac-toe game
func get_all_states() {
    
    // initial state is all 0's for the 9-element array: [0,0,0...0]
    initial_state = State(pieces: [Int](), my_move: true, value: 0.5)
    for _ in 0...(dimension*dimension-1) {
        initial_state!.pieces.append(0)
        initial_state!.my_move = true
    }
    
    // if unique_states has been previously geneatered and archived in userdefaults, just unarchive it
    if let data = NSUserDefaults.standardUserDefaults().objectForKey("non_terminal_unique_states") as? NSData {
        unique_states = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [State]
        return
    }    
    
    // build unique_states, which takes about 5 minutes every time
    // use a queue to process each state in it
    var state_queue = [State]()
    
    state_queue.append(initial_state!)
    unique_states.append(initial_state!)
    
    while !state_queue.isEmpty {
        let state = state_queue.removeFirst()
        
        // check to see if the state is final: win, lose or a draw (every element is > 0, meaing all possible 9 moves are completed)
        // don't add next states of the current state to the queue if it's 100% a win, lose or draw state.
        if blank_count(state) > 0 && valueOfState(state) != 1.0 && valueOfState(state) != 0.0 {
            let states = next_states(State(state: state)) // pass by a reference to a copy of the object
            state_queue.appendContentsOf(states.filter { !state_queue.contains($0) })
            unique_states.appendContentsOf(states.filter { !unique_states.contains($0) })
        }
        else { // state is a final state (win, loss, or draw)
            state.value = valueOfState(state)
            if !unique_states.contains(state) {
                unique_states.append(State(state: state))
            }
        }
    }
    
    let data = NSKeyedArchiver.archivedDataWithRootObject(unique_states)
    NSUserDefaults.standardUserDefaults().setObject(data, forKey: "non_terminal_unique_states")
}

get_all_states()

// self play and train (train via self play)
func evaluate_self_play_mode(random_move: Bool, learning: Bool) {
    for i in 1...10 {
        let n = 100
        var win = 0
        var loss = 0
        var draw = 0
        for _ in 1...n {
            game_states.removeAll()
            let result = self_play(initial_state!, random_move: random_move, value_update: learning)
            if result == 1.0 { win += 1 }
            else if result == 0.0 { loss += 1 }
            else { draw += 1 }
        }
        let r = random_move ? "random" : "best"
        let w = learning ? "with" : "without"
        print("after \(r) move \(w) learning \(i*n), win: \(win), loss: \(loss), draw: \(draw)")
    }
}

// uncomment to play with human
//for _ in 1...10 {
//    print("")
//    print("Initial State:")
//    play_with_human(initial_state!)
//}


// selecting best move without learning is better than selecting random move but worse than selecting best move with learning
evaluate_self_play_mode(true, learning: false)
evaluate_self_play_mode(false, learning: false)
evaluate_self_play_mode(true, learning: true)
evaluate_self_play_mode(false, learning: true)

