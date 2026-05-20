# 2048 Godot

A small Godot 4.6 implementation of the classic 2048 mobile puzzle.

## Research Notes

- 2048 was created by Gabriele Cirulli and released as an open-source web game in March 2014.
- The board is a 4 by 4 grid. A move slides every tile as far as it can go in one direction.
- Equal adjacent tiles merge into one tile with the combined value, and each tile can merge only once per move.
- A new tile appears after every valid move: usually `2`, sometimes `4`.
- The player wins when a `2048` tile appears, but can keep playing for higher scores.
- The game ends when the board is full and no adjacent equal tiles remain.

Sources:

- https://github.com/gabrielecirulli/2048
- https://en.wikipedia.org/wiki/2048_(video_game)
- https://play2048.co/

## Run

```sh
godot --path /Users/bill/Documents/2048
```

Use arrow keys, WASD, mouse drag, or mobile swipe.

## iPhone Build

This project includes an iOS export preset and a helper script that packs the
project for the generated Xcode template:

```sh
godot --headless --path /Users/bill/Documents/2048 --script res://tools/pack_ios.gd
```

The Xcode project is generated under:

```text
/Users/bill/Documents/2048/build/ios_project/godot_apple_embedded.xcodeproj
```
