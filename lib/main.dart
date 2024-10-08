import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(FlappyBird());

class FlappyBird extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird Clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static double birdY = 0; // bird's vertical position
  double initialPosition = birdY;
  double height = 0;
  double time = 0;
  double gravity = -4.9; // gravity force
  double velocity = 2.5; // upward velocity
  bool gameHasStarted = false;

  static double pipeX = 1;
  double pipeWidth = 0.2; // width of the pipe
  List<double> pipeHeights = [0.6, 0.4]; // varying pipe heights

  int score = 0; // keep track of the score
  bool isGameOver = false; // track game-over state

  int highScore = 0; // variable to store high score

  @override
  void initState() {
    super.initState();
    _loadHighScore(); // load high score on start
  }

  // Function to load the high score from SharedPreferences
  void _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0; // load high score or set 0
    });
  }

  // Function to update the high score in SharedPreferences
  void _updateHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      await prefs.setInt('highScore', highScore); // save high score
    }
  }

  // Function to reset the game
  void resetGame() {
    _updateHighScore(); // update high score before resetting
    setState(() {
      birdY = 0;
      pipeX = 1;
      score = 0;
      isGameOver = false;
      gameHasStarted = false;
      time = 0;
      initialPosition = birdY;
    });
  }

  // Function to handle jumping
  void jump() {
    if (isGameOver) return; // no jump allowed when game is over
    setState(() {
      time = 0;
      initialPosition = birdY;
    });
  }

  // Function to detect collisions with pipes or screen boundaries
  bool checkCollision() {
    // Check if bird hits the bottom or top of the screen
    if (birdY > 1 || birdY < -1) {
      return true;
    }

    // Check if bird is within the x range of the pipe
    if (pipeX < 0.2 && pipeX > -0.2) {
      // Check if bird hits the pipes vertically
      if (birdY < -1 + pipeHeights[0] || birdY > 1 - pipeHeights[1]) {
        return true; // collision detected
      }
    }

    return false;
  }

  // Start the game loop
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = gravity * time * time + velocity * time;

      setState(() {
        birdY = initialPosition - height;

        // move the pipes
        if (pipeX < -1.1) {
          pipeX = 1;
          pipeHeights.shuffle();
          score++; // increase score after passing each pipe
        } else {
          pipeX -= 0.05;
        }
      });

      // Check for collisions or game-over condition
      if (checkCollision()) {
        timer.cancel();
        gameHasStarted = false;
        isGameOver = true; // set game over state
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else if (isGameOver) {
          resetGame(); // restart the game on tap after game over
        } else {
          startGame();
        }
      },
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Stack(
                children: <Widget>[
                  AnimatedContainer(
                    alignment: Alignment(0, birdY),
                    duration: Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: MyBird(),
                  ),
                  Container(
                    alignment: Alignment(pipeX, 1.1),
                    child: MyPipe(
                      pipeHeight: pipeHeights[0],
                      pipeWidth: pipeWidth,
                      isBottomPipe: false,
                    ),
                  ),
                  Container(
                    alignment: Alignment(pipeX, -1.1),
                    child: MyPipe(
                      pipeHeight: pipeHeights[1],
                      pipeWidth: pipeWidth,
                      isBottomPipe: true,
                    ),
                  ),
                  Container(
                    alignment: Alignment(0, -0.3),
                    child: gameHasStarted
                        ? Text("")
                        : isGameOver
                            ? Text(
                                "GAME OVER\nSCORE: $score\nTAP TO RESTART",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "TAP TO PLAY",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.green,
                child: Center(
                  child: Text(
                    "Score: $score",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyBird extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      child: Image.asset('assets/images/bird.png'), // bird image
    );
  }
}

class MyPipe extends StatelessWidget {
  final double pipeHeight;
  final double pipeWidth;
  final bool isBottomPipe;

  MyPipe({
    required this.pipeHeight,
    required this.pipeWidth,
    required this.isBottomPipe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * pipeWidth,
      height: MediaQuery.of(context).size.height * 0.5 * pipeHeight,
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(width: 10, color: Colors.green[800]!),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
