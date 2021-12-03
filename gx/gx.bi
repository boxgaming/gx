$If GXBI = UNDEFINED Then
    'OPTION _EXPLICIT

    ' GX System Constants
    ' ------------------------------------------------------------------------
    Const GX_FALSE = 0
    Const GX_TRUE = Not GX_FALSE

    Const GXEVENT_INIT = 1
    Const GXEVENT_UPDATE = 2
    Const GXEVENT_DRAWBG = 3
    Const GXEVENT_DRAWMAP = 4
    Const GXEVENT_DRAWSCREEN = 5
    Const GXEVENT_MOUSEINPUT = 6
    Const GXEVENT_PAINTBEFORE = 7
    Const GXEVENT_PAINTAFTER = 8
    Const GXEVENT_COLLISION_TILE = 9
    Const GXEVENT_COLLISION_ENTITY = 10
    Const GXEVENT_PLAYER_ACTION = 11
    Const GXEVENT_ANIMATE_COMPLETE = 12

    Const GXANIMATE_LOOP = 0
    Const GXANIMATE_SINGLE = 1

    Const GXBG_STRETCH = 1
    Const GXBG_SCROLL = 2
    Const GXBG_WRAP = 3

    Const GXKEY_ESC = 2
    Const GXKEY_1 = 3
    Const GXKEY_2 = 4
    Const GXKEY_3 = 5
    Const GXKEY_4 = 6
    Const GXKEY_5 = 7
    Const GXKEY_6 = 8
    Const GXKEY_7 = 9
    Const GXKEY_8 = 10
    Const GXKEY_9 = 11
    Const GXKEY_0 = 12
    Const GXKEY_DASH = 13
    Const GXKEY_EQUALS = 14
    Const GXKEY_BACKSPACE = 15
    Const GXKEY_TAB = 16
    Const GXKEY_Q = 17
    Const GXKEY_W = 18
    Const GXKEY_E = 19
    Const GXKEY_R = 20
    Const GXKEY_T = 21
    Const GXKEY_Y = 22
    Const GXKEY_U = 23
    Const GXKEY_I = 24
    Const GXKEY_O = 25
    Const GXKEY_P = 26
    Const GXKEY_LBRACKET = 27
    Const GXKEY_RBRACKET = 28
    Const GXKEY_ENTER = 29
    Const GXKEY_LCTRL = 30
    Const GXKEY_A = 31
    Const GXKEY_S = 32
    Const GXKEY_D = 33
    Const GXKEY_F = 34
    Const GXKEY_G = 35
    Const GXKEY_H = 36
    Const GXKEY_J = 37
    Const GXKEY_K = 38
    Const GXKEY_L = 39
    Const GXKEY_SEMICOLON = 40
    Const GXKEY_QUOTE = 41
    Const GXKEY_BACKQUOTE = 42
    Const GXKEY_LSHIFT = 43
    Const GXKEY_BACKSLASH = 44
    Const GXKEY_Z = 45
    Const GXKEY_X = 46
    Const GXKEY_C = 47
    Const GXKEY_V = 48
    Const GXKEY_B = 49
    Const GXKEY_N = 50
    Const GXKEY_M = 51
    Const GXKEY_COMMA = 52
    Const GXKEY_PERIOD = 53
    Const GXKEY_SLASH = 54
    Const GXKEY_RSHIFT = 55
    Const GXKEY_NUMPAD_MULTIPLY = 56
    Const GXKEY_SPACEBAR = 58
    Const GXKEY_CAPSLOCK = 59
    Const GXKEY_F1 = 60
    Const GXKEY_F2 = 61
    Const GXKEY_F3 = 62
    Const GXKEY_F4 = 63
    Const GXKEY_F5 = 64
    Const GXKEY_F6 = 65
    Const GXKEY_F7 = 66
    Const GXKEY_F8 = 67
    Const GXKEY_F9 = 68
    Const GXKEY_PAUSE = 70
    Const GXKEY_SCRLK = 71
    Const GXKEY_NUMPAD_7 = 72
    Const GXKEY_NUMPAD_8 = 73
    Const GXKEY_NUMPAD_9 = 74
    Const GXKEY_NUMPAD_MINUS = 75
    Const GXKEY_NUMPAD_4 = 76
    Const GXKEY_NUMPAD_5 = 77
    Const GXKEY_NUMPAD_6 = 78
    Const GXKEY_NUMPAD_PLUS = 79
    Const GXKEY_NUMPAD_1 = 80
    Const GXKEY_NUMPAD_2 = 81
    Const GXKEY_NUMPAD_3 = 82
    Const GXKEY_NUMPAD_0 = 83
    Const GXKEY_NUMPAD_PERIOD = 84
    Const GXKEY_F11 = 88
    Const GXKEY_F12 = 89
    Const GXKEY_NUMPAD_ENTER = 285
    Const GXKEY_RCTRL = 286
    Const GXKEY_NUMPAD_DIVIDE = 310
    Const GXKEY_NUMLOCK = 326
    Const GXKEY_HOME = 328
    Const GXKEY_UP = 329
    Const GXKEY_PAGEUP = 330
    Const GXKEY_LEFT = 332
    Const GXKEY_RIGHT = 334
    Const GXKEY_END = 336
    Const GXKEY_DOWN = 337
    Const GXKEY_PAGEDOWN = 338
    Const GXKEY_INSERT = 339
    Const GXKEY_DELETE = 340
    Const GXKEY_LWIN = 348
    Const GXKEY_RWIN = 349
    Const GXKEY_MENU = 350




    Const GXACTION_MOVE_LEFT = 1
    Const GXACTION_MOVE_RIGHT = 2
    Const GXACTION_MOVE_UP = 3
    Const GXACTION_MOVE_DOWN = 4
    Const GXACTION_JUMP = 5
    Const GXACTION_JUMP_RIGHT = 6
    Const GXACTION_JUMP_LEFT = 7

    Const GXSCENE_FOLLOW_NONE = 0 '                no automatic scene positioning (default)
    Const GXSCENE_FOLLOW_ENTITY_CENTER = 1 '       center the view on a specified entity
    Const GXSCENE_FOLLOW_ENTITY_CENTER_X = 2 '     center the x axis of the scene on the specified entity
    Const GXSCENE_FOLLOW_ENTITY_CENTER_Y = 3 '     center the y axis of the scene on the specified entity
    Const GXSCENE_FOLLOW_ENTITY_CENTER_X_POS = 4 ' center the x axis of the scene only when moving to the right
    Const GXSCENE_FOLLOW_ENTITY_CENTER_X_NEG = 5 ' center the x axis of the scene only when moving to the left

    Const GXSCENE_CONSTRAIN_NONE = 0 '   no checking on scene position: can be negative, can exceed map size (default)
    Const GXSCENE_CONSTRAIN_TO_MAP = 1 ' do not allow screen position outside the bounds of the map size

    Const GXFONT_DEFAULT = 1 '       default bitmap font (white)
    Const GXFONT_DEFAULT_BLACK = 2 ' default bitmap font (black

    Const GXDEVICE_KEYBOARD = 1
    Const GXDEVICE_MOUSE = 2
    Const GXDEVICE_CONTROLLER = 3
    Const GXDEVICE_BUTTON = 4
    Const GXDEVICE_AXIS = 5
    Const GXDEVICE_WHEEL = 6

    Const GXTYPE_ENTITY = 1
    Const GXTYPE_FONT = 2

    ' GX System Types
    ' ------------------------------------------------------------------------
    Type GXPosition
        x As Long '              x position - unit may vary based on context
        y As Long '              y position - unit may vary based on context
    End Type

    Type GXImage
        id As Long '             the image handle
        filename As String '     the name of the file from which the image was loaded
    End Type

    Type GXFont
        eid As Integer '         id of the entity defining the font sprite
        charSpacing As Integer ' defines amount of (in pixels) between characters
        lineSpacing As Integer ' defines amount of space (in pixels) between lines
    End Type

    Type GXDeviceInput
        deviceId As Integer '    id of the input device
        deviceType As Integer '  type of input device (keyboard, mouse, or game controller)
        inputType As Integer '   type of input (button, axis, or wheel)
        inputId As Integer '     id of the input
        inputValue As Integer '  the value of the input - varies based on input type: (-1 or 0 for buttons, -1, 0 or 1 for wheel)
    End Type '                       - button: 0 or -1
    '                                - wheel:  -1, 0, or 1
    '                                - axis:   decimal value between -1 and 1
    Type GXScene
        x As Integer '           x position in pixels
        y As Integer '           y position in pixels
        width As Integer '       scene width in pixels
        height As Integer '      scene height in pixels
        columns As Integer '     number of tiled map columns viewable in the scene (0 if no map loaded)
        rows As Integer '        number of tiled map rows viewable in the scene (0 if no map loaded)
        image As Long
        active As Integer
        embedded As Integer
        followMode As Integer
        followEntity As Integer
        constrainMode As Integer
        frame As _Unsigned Long
        fullscreen As Integer
        scaleX As Single
        scaleY As Single
        customImage As Long
        customHWImage As Long
    End Type

    Type GXEvent
        event As Integer
        action As Integer
        player As Integer
        entity As Integer
        collisionEntity As Integer
        collisionTileX As Integer
        collisionTileY As Integer
        collisionResult As Integer
    End Type

    Type GXObject
        uid As String * 10 ' the object's unique identifier
        id As Integer '      the object's index in the type-specific array
        type As Integer '    the object type
    End Type

    Type GXEntity
        x As Double '             the entity's x position in the world (or scene if screen==true)
        y As Double '             the entity's y position in the world (or scene if screen==true)
        height As Integer '       the entity's sprite height
        width As Integer '        the entity's sprite width
        image As Long '           the entity's spritesheet image handle
        spriteSeq As Integer '    the entity's current sprite sequence
        spriteFrame As Integer '  the entity's current sprite animation frame
        prevFrame As Integer '    the entity's previous frame
        seqFrames As Integer '    the number of frames in the current sequence
        animate As Integer '      the animation speed in FPS, 0 = no animation
        animateMode As Integer '  animation mode (loop vs single play)
        screen As Integer '       if true entity is rendered with screen coordinates on topmost layer
        hidden As Integer '       if true, disables rendering (TODO: and collision detection?)
        type As Integer '         user-defined type id
        coLeft As Integer '       left collision offset
        coTop As Integer '        top collision offset
        coRight As Integer '      right collision offset
        coBottom As Integer '     bottom collision offset
        applyGravity As Integer ' used for applying gravity
        ' TODO: some clarification may be needed here as the following
        '       two variables are used both falling and jumping
        jumping As Integer '      used for applying gravity
        jumpstart As Integer '    used for applying gravity
        vx As Double '            move vector x
        vy As Double '            move vector y
    End Type

    Type GXBackground
        image As Long
        mode As Integer
        x As Integer
        y As Integer
        width As Integer
        height As Integer
    End Type

    Type GXTileset
        width As Integer
        height As Integer
        columns As Integer
        rows As Integer
        image As Long
        filename As String
    End Type

    Type GXTile
        id As Integer
        animationId As Integer
        animationSpeed As Integer
        animationFrame As Integer
    End Type

    Type GXTileFrame
        tileId As Integer
        firstFrame As Integer
        nextFrame As Integer
    End Type

    Type GXMap
        rows As Integer
        columns As Integer
        layers As Integer
        isometric As Integer
        version As Integer
    End Type

    Type GXMapTile
        tile As Integer
    End Type

    Type GXMapLayer
        id As Integer
        hidden As Integer
    End Type

    Type GXPlayer
        eid As Integer
        jumpSpeed As Integer
        walkSpeed As Integer
        runSpeed As Integer
    End Type

    Type GXAction
        type As Integer
        diDeviceId As Integer
        diDeviceType As Integer
        diInputType As Integer
        diInputId As Integer
        diInputValue As Integer
        animationSeq As Integer
        animationFrame As Integer
        animationMode As Integer
        animationSpeed As Integer
        disabled As Integer
    End Type

    Type GXDebug
        enabled As Integer
        screenEntities As Integer
        tileBorderColor As _Unsigned Long
        entityBorderColor As _Unsigned Long
        entityCollisionColor As _Unsigned Long
        font As Integer
    End Type


    ' System Private Globals
    ' ------------------------------------------------------------------------
    Dim Shared __gx_framerate As Integer
    __gx_framerate = 60

    Dim Shared __gx_tileset As GXTileset
    ReDim Shared __gx_tileset_tiles(0) As GXTile
    ReDim Shared __gx_tileset_animations(0) As GXTileFrame

    Dim Shared __gx_map As GXMap
    ReDim Shared __gx_map_layer_info(0) As GXMapLayer
    ReDim Shared __gx_map_layers(0, 0) As GXMapTile
    Dim Shared __gx_map_loading As Integer

    ReDim Shared __gx_images(0) As GXImage
    Dim Shared __gx_image_count As Integer

    Dim Shared __gx_scene As GXScene
    Dim Shared __gx_img_blank As Long
    Dim Shared __gx_img_blank_s As Long

    ReDim Shared __gx_bg(0) As GXBackground
    Dim Shared __gx_bg_count As Integer

    Dim Shared __gx_entity_count As Integer
    ReDim Shared __gx_entities(0) As GXEntity

    ReDim Shared __gx_fonts(2) As GXFont
    ReDim Shared __gx_font_charmap(256, 2) As GXPosition
    Dim Shared __gx_font_count As Integer
    __gx_font_count = 2

    ReDim Shared __gx_players(0) As GXPlayer
    ReDim Shared __gx_player_keymap(0, 10) As GXAction
    Dim Shared __gx_player_count As Integer

    ReDim Shared __gx_objects(0) As GXObject

    Dim Shared __gx_sound_muted As Integer

    Dim Shared __gx_gravity As Single
    __gx_gravity = 9.8 * 8
    Dim Shared __gx_terminal_velocity As Integer
    __gx_terminal_velocity = 300

    Dim Shared __gx_debug As GXDebug
    __gx_debug.font = GXFONT_DEFAULT
    __gx_debug.tileBorderColor = _RGB32(255, 255, 255)
    __gx_debug.entityBorderColor = _RGB32(255, 255, 255)
    __gx_debug.entityCollisionColor = _RGB32(255, 255, 0)

    Dim Shared __gx_draw_events(GXEVENT_DRAWBG To GXEVENT_DRAWSCREEN) As Integer

    Dim Shared __gx_hardware_acceleration

    ' TODO: Remove this section if keyboard device input fixed for linux and macos
    ' TODO: Conditionally include this section if not windows
    Type KeyEntry
        value As Long
        shift As Long
    End Type
    Dim Shared __gx_keymap(350) As KeyEntry
    __gx_keymap(GXKEY_ESC).value = 27
    __gx_keymap(GXKEY_1).value = 49
    __gx_keymap(GXKEY_1).shift = 33
    __gx_keymap(GXKEY_2).value = 50
    __gx_keymap(GXKEY_2).shift = 64
    __gx_keymap(GXKEY_3).value = 51
    __gx_keymap(GXKEY_3).shift = 35
    __gx_keymap(GXKEY_4).value = 52
    __gx_keymap(GXKEY_4).shift = 36
    __gx_keymap(GXKEY_5).value = 53
    __gx_keymap(GXKEY_5).shift = 37
    __gx_keymap(GXKEY_6).value = 54
    __gx_keymap(GXKEY_6).shift = 94
    __gx_keymap(GXKEY_7).value = 55
    __gx_keymap(GXKEY_7).shift = 38
    __gx_keymap(GXKEY_8).value = 56
    __gx_keymap(GXKEY_8).shift = 42
    __gx_keymap(GXKEY_9).value = 57
    __gx_keymap(GXKEY_9).shift = 40
    __gx_keymap(GXKEY_0).value = 48
    __gx_keymap(GXKEY_0).shift = 41
    __gx_keymap(GXKEY_DASH).value = 45
    __gx_keymap(GXKEY_DASH).shift = 95
    __gx_keymap(GXKEY_EQUALS).value = 61
    __gx_keymap(GXKEY_EQUALS).shift = 43
    __gx_keymap(GXKEY_BACKSPACE).value = 8
    __gx_keymap(GXKEY_TAB).value = 9
    __gx_keymap(GXKEY_Q).value = 113
    __gx_keymap(GXKEY_Q).shift = 81
    __gx_keymap(GXKEY_W).value = 119
    __gx_keymap(GXKEY_W).shift = 87
    __gx_keymap(GXKEY_E).value = 101
    __gx_keymap(GXKEY_E).shift = 69
    __gx_keymap(GXKEY_R).value = 114
    __gx_keymap(GXKEY_R).shift = 82
    __gx_keymap(GXKEY_T).value = 116
    __gx_keymap(GXKEY_T).shift = 84
    __gx_keymap(GXKEY_Y).value = 121
    __gx_keymap(GXKEY_Y).shift = 89
    __gx_keymap(GXKEY_U).value = 117
    __gx_keymap(GXKEY_U).shift = 85
    __gx_keymap(GXKEY_I).value = 105
    __gx_keymap(GXKEY_I).shift = 73
    __gx_keymap(GXKEY_O).value = 111
    __gx_keymap(GXKEY_O).shift = 79
    __gx_keymap(GXKEY_P).value = 112
    __gx_keymap(GXKEY_P).shift = 80
    __gx_keymap(GXKEY_LBRACKET).value = 91
    __gx_keymap(GXKEY_LBRACKET).shift = 123
    __gx_keymap(GXKEY_RBRACKET).value = 93
    __gx_keymap(GXKEY_RBRACKET).shift = 125
    __gx_keymap(GXKEY_ENTER).value = 13
    __gx_keymap(GXKEY_LCTRL).value = 100306
    __gx_keymap(GXKEY_A).value = 97
    __gx_keymap(GXKEY_A).shift = 65
    __gx_keymap(GXKEY_S).value = 115
    __gx_keymap(GXKEY_S).shift = 83
    __gx_keymap(GXKEY_D).value = 100
    __gx_keymap(GXKEY_D).shift = 68
    __gx_keymap(GXKEY_F).value = 102
    __gx_keymap(GXKEY_F).shift = 70
    __gx_keymap(GXKEY_G).value = 103
    __gx_keymap(GXKEY_G).shift = 71
    __gx_keymap(GXKEY_H).value = 104
    __gx_keymap(GXKEY_H).shift = 72
    __gx_keymap(GXKEY_J).value = 106
    __gx_keymap(GXKEY_J).shift = 74
    __gx_keymap(GXKEY_K).value = 107
    __gx_keymap(GXKEY_K).shift = 75
    __gx_keymap(GXKEY_L).value = 108
    __gx_keymap(GXKEY_L).shift = 76
    __gx_keymap(GXKEY_SEMICOLON).value = 59
    __gx_keymap(GXKEY_SEMICOLON).shift = 58
    __gx_keymap(GXKEY_QUOTE).value = 39
    __gx_keymap(GXKEY_QUOTE).shift = 34
    __gx_keymap(GXKEY_BACKQUOTE).value = 96
    __gx_keymap(GXKEY_BACKQUOTE).shift = 126
    __gx_keymap(GXKEY_LSHIFT).value = 100304
    __gx_keymap(GXKEY_BACKSLASH).value = 92
    __gx_keymap(GXKEY_BACKSLASH).shift = 124
    __gx_keymap(GXKEY_Z).value = 122
    __gx_keymap(GXKEY_Z).shift = 90
    __gx_keymap(GXKEY_X).value = 120
    __gx_keymap(GXKEY_X).shift = 88
    __gx_keymap(GXKEY_C).value = 99
    __gx_keymap(GXKEY_C).shift = 67
    __gx_keymap(GXKEY_V).value = 118
    __gx_keymap(GXKEY_V).shift = 86
    __gx_keymap(GXKEY_B).value = 98
    __gx_keymap(GXKEY_B).shift = 66
    __gx_keymap(GXKEY_N).value = 110
    __gx_keymap(GXKEY_N).shift = 78
    __gx_keymap(GXKEY_M).value = 109
    __gx_keymap(GXKEY_M).shift = 77
    __gx_keymap(GXKEY_COMMA).value = 44
    __gx_keymap(GXKEY_COMMA).shift = 60
    __gx_keymap(GXKEY_PERIOD).value = 46
    __gx_keymap(GXKEY_PERIOD).shift = 62
    __gx_keymap(GXKEY_SLASH).value = 47
    __gx_keymap(GXKEY_SLASH).shift = 63
    __gx_keymap(GXKEY_RSHIFT).value = 100303
    __gx_keymap(GXKEY_NUMPAD_MULTIPLY).value = 100268
    __gx_keymap(GXKEY_SPACEBAR).value = 32
    __gx_keymap(GXKEY_CAPSLOCK).value = 100301
    __gx_keymap(GXKEY_F1).value = 15104
    __gx_keymap(GXKEY_F2).value = 15360
    __gx_keymap(GXKEY_F3).value = 15616
    __gx_keymap(GXKEY_F4).value = 15872
    __gx_keymap(GXKEY_F5).value = 16128
    __gx_keymap(GXKEY_F6).value = 16384
    __gx_keymap(GXKEY_F7).value = 16640
    __gx_keymap(GXKEY_F8).value = 16896
    __gx_keymap(GXKEY_F9).value = 17152
    __gx_keymap(GXKEY_PAUSE).value = 100019
    __gx_keymap(GXKEY_SCRLK).value = 100302
    __gx_keymap(GXKEY_NUMPAD_7).value = 100263
    __gx_keymap(GXKEY_NUMPAD_7).shift = 200007
    __gx_keymap(GXKEY_NUMPAD_8).value = 100264
    __gx_keymap(GXKEY_NUMPAD_8).shift = 200008
    __gx_keymap(GXKEY_NUMPAD_9).value = 100265
    __gx_keymap(GXKEY_NUMPAD_9).value = 200009
    __gx_keymap(GXKEY_NUMPAD_MINUS).value = 100269
    __gx_keymap(GXKEY_NUMPAD_4).value = 100260
    __gx_keymap(GXKEY_NUMPAD_4).shift = 200004
    __gx_keymap(GXKEY_NUMPAD_5).value = 100261
    __gx_keymap(GXKEY_NUMPAD_6).value = 100262
    __gx_keymap(GXKEY_NUMPAD_6).shift = 200006
    __gx_keymap(GXKEY_NUMPAD_PLUS).value = 100270
    __gx_keymap(GXKEY_NUMPAD_1).value = 100257
    __gx_keymap(GXKEY_NUMPAD_1).shift = 200001
    __gx_keymap(GXKEY_NUMPAD_2).value = 100258
    __gx_keymap(GXKEY_NUMPAD_2).shift = 200002
    __gx_keymap(GXKEY_NUMPAD_3).value = 100259
    __gx_keymap(GXKEY_NUMPAD_3).shift = 200003
    __gx_keymap(GXKEY_NUMPAD_0).value = 100256
    __gx_keymap(GXKEY_NUMPAD_0).shift = 200000
    __gx_keymap(GXKEY_NUMPAD_PERIOD).value = 100266
    __gx_keymap(GXKEY_NUMPAD_PERIOD).shift = 200010
    __gx_keymap(GXKEY_F11).value = 34048
    __gx_keymap(GXKEY_F12).value = 34304
    __gx_keymap(GXKEY_NUMPAD_ENTER).value = 100271
    __gx_keymap(GXKEY_RCTRL).value = 100305
    __gx_keymap(GXKEY_NUMPAD_DIVIDE).value = 100267
    __gx_keymap(GXKEY_NUMLOCK).value = 100300
    __gx_keymap(GXKEY_HOME).value = 18176
    __gx_keymap(GXKEY_UP).value = 18432
    __gx_keymap(GXKEY_PAGEUP).value = 18688
    __gx_keymap(GXKEY_LEFT).value = 19200
    __gx_keymap(GXKEY_RIGHT).value = 19712
    __gx_keymap(GXKEY_END).value = 20224
    __gx_keymap(GXKEY_DOWN).value = 20480
    __gx_keymap(GXKEY_PAGEDOWN).value = 20736
    __gx_keymap(GXKEY_INSERT).value = 20992
    __gx_keymap(GXKEY_DELETE).value = 21248
    __gx_keymap(GXKEY_LWIN).value = 100311
    __gx_keymap(GXKEY_RWIN).value = 100312
    __gx_keymap(GXKEY_MENU).value = 100319


    $Let GXBI = TRUE
$End If
