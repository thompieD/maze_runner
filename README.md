# maze_runner
A simple dungeon explorer game made with flame engine.

## Prototype
The prototype is a simple dungeon explorer with basic combat mechanics. The player can move around the dungeon and fight enemies. 
For the movement the player can use the arrow keys and for combat the player can use the space bar. The player also has hearts that represents their lifes. The player can lose lifes by being hit by enemies if the player loses all their lifes the game is over. 

The player can win the game by defeating all the enemies in the dungeon.

## Planning
The project will be broken down into 4 main parts:
1. The dungeon generation
2. The player movement and combat
3. The enemy movement and combat
4. Polish

## Dungeon Generation - 2 Hours
The dungeon will be generated using a simple algorithm that will create a grid of rooms. The rooms will be connected by hallways. We will pick a path tile from the grid and spawn the player there. We will also pick a path tile to spawn the enemies.

## Player Movement and Combat - 2 Hours
The player will be able to move around the dungeon using the arrow keys. The player will be able to attack enemies using the space bar. The player will have a lifes that will decrease when the player is hit by an enemy. 

## Enemy Movement and Combat - 2 Hours
The enemies will walk towards the player when the player gets close by, if the player is in the same tile as the enemy the enemy will attack the player. The enemies are now one hit kill and will be recycled if the player defeats them.

## UI - 30 Minutes
A simple UI will be added to the game to show the player lifes, also a game over/win screen will be added with a simple replay button.

## Polish - 1 Hours
In the polish we are going to add all of the effects and audio. 

## deployment - 30 Minutes
The game will be deployed to a github pages site. 
The page: https://thompied.github.io/dungeon-explorer/

