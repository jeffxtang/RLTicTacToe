# RLTicTacToe
Reinforcement Learning in TicTacToe - Swift Implementation of TD(0)

This app implements the TD(0) algorithm, described in Sutton's classic book [Reinforcement Learning: An Introduction](https://webdocs.cs.ualberta.ca/~sutton/book/the-book.html), in Swift.

There're 6046 unique states in total and the code trains by self-play using the TD(0) to update the state values for the states. In the first run of the app, the unique states are serialized and saved to user default.

## How to Run
Simply double click the RLTicTacToe.xcodeproj file to open the project in Xcode, then hit the Run button and you should see results similar to the following (note the first time it runs, it takes about 3-5 minutes to build all the 5400 unique non-terminal states - the total number of unique TicTacToe states is 6046):
```
after random move without learning 100, win: 56, loss: 30, draw: 14
after random move without learning 200, win: 57, loss: 29, draw: 14
after random move without learning 300, win: 52, loss: 35, draw: 13
after random move without learning 400, win: 60, loss: 29, draw: 11
after random move without learning 500, win: 63, loss: 31, draw: 6
after random move without learning 600, win: 61, loss: 25, draw: 14
after random move without learning 700, win: 62, loss: 27, draw: 11
after random move without learning 800, win: 60, loss: 32, draw: 8
after random move without learning 900, win: 56, loss: 31, draw: 13
after random move without learning 1000, win: 52, loss: 32, draw: 16

after best move without learning 100, win: 67, loss: 29, draw: 4
after best move without learning 200, win: 74, loss: 25, draw: 1
after best move without learning 300, win: 64, loss: 30, draw: 6
after best move without learning 400, win: 79, loss: 18, draw: 3
after best move without learning 500, win: 70, loss: 28, draw: 2
after best move without learning 600, win: 64, loss: 31, draw: 5
after best move without learning 700, win: 65, loss: 30, draw: 5
after best move without learning 800, win: 65, loss: 27, draw: 8
after best move without learning 900, win: 72, loss: 24, draw: 4
after best move without learning 1000, win: 63, loss: 31, draw: 6

after random move with learning 100, win: 58, loss: 28, draw: 14
after random move with learning 200, win: 60, loss: 28, draw: 12
after random move with learning 300, win: 61, loss: 24, draw: 15
after random move with learning 400, win: 56, loss: 33, draw: 11
after random move with learning 500, win: 60, loss: 33, draw: 7
after random move with learning 600, win: 64, loss: 25, draw: 11
after random move with learning 700, win: 63, loss: 29, draw: 8
after random move with learning 800, win: 59, loss: 28, draw: 13
after random move with learning 900, win: 57, loss: 34, draw: 9
after random move with learning 1000, win: 62, loss: 32, draw: 6

after best move with learning 100, win: 80, loss: 18, draw: 2
after best move with learning 200, win: 96, loss: 3, draw: 1
after best move with learning 300, win: 94, loss: 3, draw: 3
after best move with learning 400, win: 91, loss: 9, draw: 0
after best move with learning 500, win: 91, loss: 9, draw: 0
after best move with learning 600, win: 95, loss: 2, draw: 3
after best move with learning 700, win: 93, loss: 5, draw: 2
after best move with learning 800, win: 96, loss: 3, draw: 1
after best move with learning 900, win: 99, loss: 1, draw: 0
after best move with learning 1000, win: 95, loss: 4, draw: 1
```

###The results above show that:
1. If the app selects its move randomly, and the opponent (also part of the app - this is why it's called self play) selects move randomly too, then the player that makes the first move wins about 60 games out of 100, and the other player wins about 30 out of 100;

2. If the app always selects the best possible move (with no learning), then the player making the first move wins a few more games out of 100 than case 1 - this makes sense as at the end of the game, the player would choose the winning move instead of the random one;

3. If the app makes the random moves, even with learning occurred, it certainly has about the same winning percentage as case 1;

4. With learning enabled, selecting the best moves should improve the first player's winning percentage - this is exactly what we expect to see. In the code, line 340 `unique_states[index].value = s2.value + alpha * (s1.value - s2.value)` implements the TD(0) value update algorithm.

## TODO
1. save and restore trained model (states with values)- right now, only states with initial values are saved and restored;

2. implement the TD(lambda) and NN for value function for TicTacToe in TensorFlow in Python, then use the trained model in iOS, and compare the winning percentage of game plays using the TD(lambda) and NN trained model with the TD(0) and state-value model here.
