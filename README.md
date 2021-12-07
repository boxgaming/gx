GX is a basic game engine... literally. This is a Game(G) Engine(X) built with and for QB64, a QBasic/QuickBASIC IDE and compiler with modern extensions.

GX supports basic 2D gaming: platformer, top-down, etc.... you know, classic NES/SNES type games.  The engine also provides support for isometric tiled games as well.

The goal here is to create a flexible, event-based game engine. Based on your game requirements you can use as much or as little of it as you need, but the engine will take care of the main tasks of managing the game loop and screen buffering for the display.

The current alpha build has support for:
- Scene(viewport) management
- Entity(sprite) management
- Tiled map creation and management
  - Including a world/map editor
  - Support for layered tiles
  - Support for animated tiles
  - Support for orthogonal and isometric tilesets
- Bitmap font support
- Collision detection
- Basic physics/gravity
- Device input management
  - Keyboard, mouse, and game controller
- Interactive debugging
- Export to Web (Experimental)
