import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

const int PATH_TILE = 0;
const int WALL_TILE = 1;
const int VOID_TILE = 2;

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
          addTile(x, y, 1, 1, priority: 0);
        } else {
          // Wall or Corner
          addWallOrCornerTile(x, y);
        }
      }
    }
  }

void _generateDungeon() {
  final random = Random();
  final minRoomSize = 3; // Minimum room size
  final maxRoomSize = 6; // Maximum room size
  final numRooms = 3; // Number of rooms to generate
  final buffer = 3; // Buffer space between rooms

  // Ensure the dungeon dimensions are greater than or equal to the room size plus buffer
  if (width < minRoomSize + buffer || height < minRoomSize + buffer) {
    throw ArgumentError('Dungeon dimensions must be greater than or equal to the minimum room size plus buffer.');
  }

  // List to store room positions
  List<Rect> rooms = [];

  // Place rooms
  for (int i = 0; i < numRooms; i++) {
    int roomWidth = random.nextInt(maxRoomSize - minRoomSize + 1) + minRoomSize;
    int roomHeight = random.nextInt(maxRoomSize - minRoomSize + 1) + minRoomSize;
    int roomX, roomY;
    bool overlap;

    // Ensure rooms do not overlap and have buffer space
    do {
      overlap = false;
      roomX = random.nextInt(width - roomWidth - buffer * 2) + buffer;
      roomY = random.nextInt(height - roomHeight - buffer * 2) + buffer;
      Rect newRoom = Rect.fromLTWH(roomX.toDouble(), roomY.toDouble(), roomWidth.toDouble(), roomHeight.toDouble());

      for (Rect room in rooms) {
        if (newRoom.overlaps(room.inflate(buffer.toDouble()))) {
          overlap = true;
          break;
        }
      }
    } while (overlap);

    rooms.add(Rect.fromLTWH(roomX.toDouble(), roomY.toDouble(), roomWidth.toDouble(), roomHeight.toDouble()));

    // Mark the room space as paths
    for (int y = roomY; y < roomY + roomHeight; y++) {
      for (int x = roomX; x < roomX + roomWidth; x++) {
        dungeon[y][x] = PATH_TILE;
      }
    }
  }

  // Connect rooms with straight hallways
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
      if (!_isOverlappingRoom(x, startY, rooms, roomA, roomB)) {
        dungeon[startY][x] = PATH_TILE;
      }
    }

    // Create vertical hallway
    for (int y = min(startY, endY); y <= max(startY, endY); y++) {
      if (!_isOverlappingRoom(endX, y, rooms, roomA, roomB)) {
        dungeon[y][endX] = PATH_TILE;
      }
    }
  }
}

bool _isOverlappingRoom(int x, int y, List<Rect> rooms, Rect roomA, Rect roomB) {
  for (Rect room in rooms) {
    if (room != roomA && room != roomB && room.contains(Offset(x.toDouble(), y.toDouble()))) {
      return true;
    }
  }
  return false;
}

void addWallOrCornerTile(int x, int y) {
  // Only add a wall if it's adjacent to a path within a 3x3 radius
  bool adjacentToPath = false;
  for (int dy = -1; dy <= 1; dy++) {
    for (int dx = -1; dx <= 1; dx++) {
      if (x + dx >= 0 && x + dx < width && y + dy >= 0 && y + dy < height && dungeon[y + dy][x + dx] == PATH_TILE) {
        adjacentToPath = true;
      }
    }
  }

  if (!adjacentToPath) {
    // Change it from WALL_TILE to VOID_TILE
    dungeon[y][x] = VOID_TILE;
    addTile(x, y, 7, 8, priority: 1); // Assuming (7, 8) is the void tile sprite coordinates
    return;
  }

  int spriteX = 1;
  int spriteY = 1;

  // Determine the type of wall or corner to place based on the surrounding tiles
  bool left = (x > 0 && dungeon[y][x - 1] == PATH_TILE);
  bool right = (x < width - 1 && dungeon[y][x + 1] == PATH_TILE);
  bool top = (y > 0 && dungeon[y - 1][x] == PATH_TILE);
  bool bottom = (y < height - 1 && dungeon[y + 1][x] == PATH_TILE);

  bool wallLeft = (x > 0 && dungeon[y][x - 1] == WALL_TILE);
  bool wallRight = (x < width - 1 && dungeon[y][x + 1] == WALL_TILE);
  bool wallTop = (y > 0 && dungeon[y - 1][x] == WALL_TILE);
  bool wallBottom = (y < height - 1 && dungeon[y + 1][x] == WALL_TILE);

  int key = (left ? 1 : 0) | (right ? 2 : 0) | (top ? 4 : 0) | (bottom ? 8 : 0);

  switch (key) {
    case 3: // left && right && !top && !bottom
      spriteX = 4; // Horizontal wall
      spriteY = 2;
      break;
    case 12: // top && bottom && !left && !right
      spriteX = 2; // Vertical wall
      spriteY = 0;
      break;
    case 1: // left && !right && !top && !bottom
      spriteX = 3; // Vertical wall (left)
      spriteY = 5;
      break;
    case 2: // right && !left && !top && !bottom
      spriteX = 2; // Vertical wall (right)
      spriteY = 0;
      break;
    case 4: // top && !bottom && !left && !right
      spriteX = 4; // Horizontal wall (Bottom)
      spriteY = 2;
      break;
    case 8: // bottom && !top && !left && !right
      spriteX = 0; // Horizontal wall (Top)
      spriteY = 1;
      break;
    case 5: // left && top && !right && !bottom
      spriteX = 5; // Top-left corner
      spriteY = 4;
      break;
    case 6: // right && top && !left && !bottom
      spriteX = 5; // Top-right corner
      spriteY = 3;
      break;
    case 9: // left && bottom && !right && !top
      spriteX = 0; // Bottom-left corner
      spriteY = 1;
      break;
    case 10: // right && bottom && !left && !top
      spriteX = 0; // Bottom-right corner
      spriteY = 1;
      break;
    default:
      // Identify outer corners based on wall adjacency
      if (wallLeft && wallTop) {
        spriteX = 4; // Top-left outer corner
        spriteY = 5;
      } else if (wallRight && wallTop) {
        spriteX = 4; // Top-right outer corner
        spriteY = 0;
      } else if (wallLeft && wallBottom) {
        spriteX = 0; // Bottom-left outer corner
        spriteY = 5;
      } else if (wallRight && wallBottom) {
        spriteX = 0; // Bottom-right outer corner
        spriteY = 0;
      } else {
        spriteX = 1;
        spriteY = 1;
      }
      break;
  }

  addTile(x, y, spriteX, spriteY, priority: 1); // Higher priority for walls
}

  // Add a tile to the game
  void addTile(int x, int y, int spriteX, int spriteY, {int priority = 0}) {
    final tile = SpriteComponent()
      ..sprite = spriteSheet.getSprite(spriteX, spriteY)
      ..size = Vector2(tileSize.toDouble(), tileSize.toDouble())
      ..position = Vector2(x * tileSize.toDouble(), y * tileSize.toDouble())
      ..priority = priority;
    add(tile);
  }
}