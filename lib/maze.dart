import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

const int PATH_TILE = 0;
const int WALL_TILE = 1;

class Maze extends Component {
  final int tileSize;
  final int width;
  final int height;
  final FlameGame gameRef;
  late SpriteSheet spriteSheet;
  late List<List<int>> dungeon;

  Maze(this.tileSize, this.width, this.height, this.gameRef);

  @override
  Future<void> onLoad() async {
    spriteSheet = SpriteSheet(
      image: await gameRef.images.load('dungeon_tileset.png'),
      srcSize: Vector2(16.0, 16.0), 
    );

    // Initialize the dungeon layout
    dungeon = List.generate(height, (_) => List.generate(width, (_) => WALL_TILE));

    // Generate the dungeon layout
    _generateDungeon();

    // Place the tiles based on the generated layout
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (dungeon[y][x] == PATH_TILE) {
          // Path
          addTile(x, y, 1, 1);
        } else {
          // Wall
          addWallTile(x, y);
        }
      }
    }
  }

  void _generateDungeon() {
    final random = Random();
    final roomSize = 4; // Adjust room size
    final numRooms = 5; // Number of rooms to generate

    // Ensure the dungeon dimensions are greater than or equal to the room size
    if (width < roomSize || height < roomSize) {
      throw ArgumentError('Dungeon dimensions must be greater than or equal to the room size.');
    }

    // List to store room positions
    List<Rect> rooms = [];

    // Place rooms
    for (int i = 0; i < numRooms; i++) {
      int roomX, roomY;
      bool overlap;

      // Ensure rooms do not overlap
      do {
        overlap = false;
        roomX = random.nextInt(width - roomSize - 2) + 1; 
        roomY = random.nextInt(height - roomSize - 2) + 1;
        Rect newRoom = Rect.fromLTWH(roomX.toDouble(), roomY.toDouble(), roomSize.toDouble(), roomSize.toDouble());

        for (Rect room in rooms) {
          if (newRoom.overlaps(room)) {
            overlap = true;
            break;
          }
        }
      } while (overlap);

      rooms.add(Rect.fromLTWH(roomX.toDouble(), roomY.toDouble(), roomSize.toDouble(), roomSize.toDouble()));

      // Mark the room space as paths
      for (int y = roomY.toInt(); y < roomY.toInt() + roomSize; y++) {
        for (int x = roomX.toInt(); x < roomX.toInt() + roomSize; x++) {
          dungeon[y][x] = PATH_TILE; 
        }
      }
    }

    // Connect rooms with hallways
    for (int i = 0; i < rooms.length - 1; i++) {
      Rect roomA = rooms[i];
      Rect roomB = rooms[i + 1];

      // Get the center points of both rooms
      int startX = (roomA.left + roomA.width / 2).toInt();
      int startY = (roomA.top + roomA.height / 2).toInt();
      int endX = (roomB.left + roomB.width / 2).toInt();
      int endY = (roomB.top + roomB.height / 2).toInt();

      // Create horizontal hallway
      for (int x = min(startX, endX); x <= max(startX, endX); x++) {
        if (startY > 0 && startY < height - 1) {
          dungeon[startY][x] = PATH_TILE; 
        }
        if (startY + 1 > 0 && startY + 1 < height - 1) {
          dungeon[startY + 1][x] = PATH_TILE; 
        }
      }

      // Create vertical hallway
      for (int y = min(startY, endY); y <= max(startY, endY); y++) {
        if (endX > 0 && endX < width - 1) {
          dungeon[y][endX] = PATH_TILE; 
        }
        if (endX + 1 > 0 && endX + 1 < width - 1) {
          dungeon[y][endX + 1] = PATH_TILE;
        }
      }
    }

    // Add different types of walls
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (dungeon[y][x] == WALL_TILE && random.nextBool()) {
          dungeon[y][x] = 2; 
        }
      }
    }
  }

  // Add a wall tile to the game
  void addWallTile(int x, int y) {
    // Only add a wall if it's adjacent to a path within a 3x3 radius
    bool adjacentToPath = false;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (x + dx >= 0 && x + dx < width && y + dy >= 0 && y + dy < height && dungeon[y + dy][x + dx] == PATH_TILE) {
          adjacentToPath = true;
          break;
        }
      }
      if (adjacentToPath) break;
    }

    if (!adjacentToPath) {
      addTile(x, y, 7, 8); 
      return;
    }

    int spriteX;
    int spriteY;

    // Determine the type of wall to place based on the surrounding tiles
    bool left = (x > 0 && dungeon[y][x - 1] == PATH_TILE);
    bool right = (x < width - 1 && dungeon[y][x + 1] == PATH_TILE);
    bool top = (y > 0 && dungeon[y - 1][x] == PATH_TILE);
    bool bottom = (y < height - 1 && dungeon[y + 1][x] == PATH_TILE);

    bool topLeft = (x > 0 && y > 0 && dungeon[y - 1][x - 1] == PATH_TILE);
    bool topRight = (x < width - 1 && y > 0 && dungeon[y - 1][x + 1] == PATH_TILE);
    bool bottomLeft = (x > 0 && y < height - 1 && dungeon[y + 1][x - 1] == PATH_TILE);
    bool bottomRight = (x < width - 1 && y < height - 1 && dungeon[y + 1][x + 1] == PATH_TILE);

    if (top && left && !right && !bottom) {
      spriteX = 0; // Top-left corner
      spriteY = 0;
    } else if (top && right && !left && !bottom) {
      spriteX = 0; // Top-right corner
      spriteY = 5;
    } else if (bottom && left && !right && !top) {
      spriteX = 4; // Bottom-left corner
      spriteY = 0;
    } else if (bottom && right && !left && !top) {
      spriteX = 4; // Bottom-right corner
      spriteY = 5;
    } else if (left && right && !top && !bottom) {
      spriteX = 4; // Horizontal wall
      spriteY = 2;
    } else if (top && bottom && !left && !right) {
      spriteX = 2; // Vertical wall
      spriteY = 0;
    } else if (left && !right && !top && !bottom) {
      spriteX = 3; // Vertical wall (left)
      spriteY = 5;
    } else if (right && !left && !top && !bottom) {
      spriteX = 2; // Vertical wall (right)
      spriteY = 0;
    } else if (top && !bottom && !left && !right) {
      spriteX = 4; // Horizontal wall (top)
      spriteY = 2;
    } else if (bottom && !top && !left && !right) {
      spriteX = 4; // Horizontal wall (bottom)
      spriteY = 1;
    } else if (left && bottom && right && !top) {
      spriteX = 5; // Bottom T-junction
      spriteY = 0;
    } else if (left && top && right && !bottom) {
      spriteX = 5; // Top T-junction
      spriteY = 1;
    } else if (top && bottom && left && !right) {
      spriteX = 5; // Left T-junction
      spriteY = 2;
    } else if (top && bottom && right && !left) {
      spriteX = 5; // Right T-junction
      spriteY = 3;
    } else if (left && bottom && !right && !top) {
      spriteX = 5; // Bottom-left angled corner
      spriteY = 5;
    } else if (right && bottom && !left && !top) {
      spriteX = 5; // Bottom-right angled corner
      spriteY = 1;
    } else if (left & top & !right & !bottom) {
      spriteX = 5; // Top-left angled corner
      spriteY = 3;
    } else if (right & top & !left & !bottom) {
      spriteX = 5; // Top-right angled corner
      spriteY = 4;
    } else if (!top && !left && topLeft) {
      spriteX = 5; // Inward top-left corner
      spriteY = 3;
    } else if (!top && !right && topRight) {
      spriteX = 5; // Inward top-right corner
      spriteY = 4;
    } else if (!bottom && !left && bottomLeft) {
      spriteX = 5; // Inward bottom-left corner
      spriteY = 5;
    } else if (!bottom && !right && bottomRight) {
      spriteX = 5; // Inward bottom-right corner
      spriteY = 1;
    } else {
      // placeholder to see if there are any missing cases
      spriteX = 1;
      spriteY = 1;
    }

    addTile(x, y, spriteX, spriteY); 
  }

  // Add a tile to the game
  void addTile(int x, int y, int spriteX, int spriteY) {
    final tile = SpriteComponent()
      ..sprite = spriteSheet.getSprite(spriteX, spriteY)
      ..size = Vector2(tileSize.toDouble(), tileSize.toDouble())
      ..position = Vector2(x * tileSize.toDouble(), y * tileSize.toDouble());
    add(tile);
  }
}