$IF GXBI = UNDEFINED THEN
    'OPTION _EXPLICIT

    ' GX System Constants
    ' ------------------------------------------------------------------------
    CONST GX_FALSE = 0
    CONST GX_TRUE = NOT GX_FALSE

    CONST GXEVENT_UPDATE = 1
    CONST GXEVENT_DRAWBG = 2
    CONST GXEVENT_DRAWMAP = 3
    CONST GXEVENT_DRAWSCREEN = 4
    CONST GXEVENT_MOUSEINPUT = 5
    CONST GXEVENT_PAINTBEFORE = 6
    CONST GXEVENT_PAINTAFTER = 7
    CONST GXEVENT_COLLISION_TILE = 8
    CONST GXEVENT_COLLISION_ENTITY = 9

    CONST GXANIMATE_LOOP = 0
    CONST GXANIMATE_SINGLE = 1

    CONST GXBG_STRETCH = 1
    CONST GXBG_SCROLL = 2
    CONST GXBG_WRAP = 3

    CONST GXKEY_ESC = 2
    CONST GXKEY_1 = 3
    CONST GXKEY_2 = 4
    CONST GXKEY_3 = 5
    CONST GXKEY_4 = 6
    CONST GXKEY_5 = 7
    CONST GXKEY_6 = 8
    CONST GXKEY_7 = 9
    CONST GXKEY_8 = 10
    CONST GXKEY_9 = 11
    CONST GXKEY_0 = 12
    CONST GXKEY_DASH = 13
    CONST GXKEY_EQUALS = 14
    CONST GXKEY_BACKSPACE = 15
    CONST GXKEY_TAB = 16
    CONST GXKEY_Q = 17
    CONST GXKEY_W = 18
    CONST GXKEY_E = 19
    CONST GXKEY_R = 20
    CONST GXKEY_T = 21
    CONST GXKEY_Y = 22
    CONST GXKEY_U = 23
    CONST GXKEY_I = 24
    CONST GXKEY_O = 25
    CONST GXKEY_P = 26
    CONST GXKEY_LBRACKET = 27
    CONST GXKEY_RBRACKET = 28
    CONST GXKEY_ENTER = 29
    CONST GXKEY_LCTRL = 30
    CONST GXKEY_A = 31
    CONST GXKEY_S = 32
    CONST GXKEY_D = 33
    CONST GXKEY_F = 34
    CONST GXKEY_G = 35
    CONST GXKEY_H = 36
    CONST GXKEY_J = 37
    CONST GXKEY_K = 38
    CONST GXKEY_L = 39
    CONST GXKEY_SEMICOLON = 40
    CONST GXKEY_QUOTE = 41
    CONST GXKEY_BACKQUOTE = 42
    CONST GXKEY_LSHIFT = 43
    CONST GXKEY_BACKSLASH = 44
    CONST GXKEY_Z = 45
    CONST GXKEY_X = 46
    CONST GXKEY_C = 47
    CONST GXKEY_V = 48
    CONST GXKEY_B = 49
    CONST GXKEY_N = 50
    CONST GXKEY_M = 51
    CONST GXKEY_COMMA = 52
    CONST GXKEY_PERIOD = 53
    CONST GXKEY_SLASH = 54
    CONST GXKEY_RSHIFT = 55
    CONST GXKEY_NUMPAD_ASTERISK = 56
    CONST GXKEY_SPACEBAR = 58
    CONST GXKEY_CAPSLOCK = 59
    CONST GXKEY_F1 = 60
    CONST GXKEY_F2 = 61
    CONST GXKEY_F3 = 62
    CONST GXKEY_F4 = 63
    CONST GXKEY_F5 = 64
    CONST GXKEY_F6 = 65
    CONST GXKEY_F7 = 66
    CONST GXKEY_F8 = 67
    CONST GXKEY_F9 = 68
    CONST GXKEY_PAUSE = 70
    CONST GXKEY_SCRLK = 71
    CONST GXKEY_NUMPAD_7 = 72
    CONST GXKEY_NUMPAD_8 = 73
    CONST GXKEY_NUMPAD_9 = 74
    CONST GXKEY_NUMPAD_MINUS = 75
    CONST GXKEY_NUMPAD_4 = 76
    CONST GXKEY_NUMPAD_5 = 77
    CONST GXKEY_NUMPAD_6 = 78
    CONST GXKEY_NUMPAD_PLUS = 79
    CONST GXKEY_NUMPAD_1 = 80
    CONST GXKEY_NUMPAD_2 = 81
    CONST GXKEY_NUMPAD_3 = 82
    CONST GXKEY_NUMPAD_0 = 83
    CONST GXKEY_NUMPAD_PERIOD = 84
    CONST GXKEY_F11 = 88
    CONST GXKEY_F12 = 89
    CONST GXKEY_NUMPAD_ENTER = 285
    CONST GXKEY_RCTRL = 286
    CONST GXKEY_NUMPAD_SLASH = 310
    CONST GXKEY_NUMLOCK = 326
    CONST GXKEY_HOME = 328
    CONST GXKEY_UP = 329
    CONST GXKEY_PAGEUP = 330
    CONST GXKEY_LEFT = 332
    CONST GXKEY_RIGHT = 334
    CONST GXKEY_END = 336
    CONST GXKEY_DOWN = 337
    CONST GXKEY_PAGEDOWN = 338
    CONST GXKEY_INSERT = 339
    CONST GXKEY_DELETE = 340
    CONST GXKEY_LWIN = 348
    CONST GXKEY_RWIN = 349
    CONST GXKEY_MENU = 350

    CONST GXACTION_MOVE_LEFT = 1
    CONST GXACTION_MOVE_RIGHT = 2
    CONST GXACTION_MOVE_UP = 3
    CONST GXACTION_MOVE_DOWN = 4
    CONST GXACTION_JUMP = 5
    CONST GXACTION_JUMP_RIGHT = 6
    CONST GXACTION_JUMP_LEFT = 7

    CONST GXSCENE_FOLLOW_NONE = 0 '                no automatic scene positioning (default)
    CONST GXSCENE_FOLLOW_ENTITY_CENTER = 1 '       center the view on a specified entity
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_X = 2 '     center the x axis of the scene on the specified entity
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_Y = 3 '     center the y axis of the scene on the specified entity
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_X_POS = 4 ' center the x axis of the scene only when moving to the right
    CONST GXSCENE_FOLLOW_ENTITY_CENTER_X_NEG = 5 ' center the x axis of the scene only when moving to the left

    CONST GXSCENE_CONSTRAIN_NONE = 0 '   no checking on scene position: can be negative, can exceed map size (default)
    CONST GXSCENE_CONSTRAIN_TO_MAP = 1 ' do not allow screen position outside the bounds of the map size

    CONST GXFONT_DEFAULT = 1 '       default bitmap font (white)
    CONST GXFONT_DEFAULT_BLACK = 2 ' default bitmap font (black

    CONST GX_DEVICE_KEYBOARD = 1
    CONST GX_DEVICE_MOUSE = 2
    CONST GX_DEVICE_CONTROLLER = 3
    CONST GX_DEVICE_BUTTON = 4
    CONST GX_DEVICE_AXIS = 5
    CONST GX_DEVICE_WHEEL = 6

    'CONST GX_BLACK = _RGB32(255, 255, 255)


    ' GX System Types
    ' ------------------------------------------------------------------------
    TYPE GXPosition
        x AS LONG
        y AS LONG
    END TYPE

    TYPE GXEntity
        x AS DOUBLE
        y AS DOUBLE
        height AS INTEGER
        width AS INTEGER
        image AS INTEGER
        spriteSeq AS INTEGER
        spriteFrame AS INTEGER
        seqFrames AS INTEGER
        animate AS INTEGER
        animateMode AS INTEGER
        screen AS INTEGER
        hidden AS INTEGER
        type AS INTEGER
        coLeft AS INTEGER ' left collision offset
        coTop AS INTEGER ' top collision offset
        coRight AS INTEGER ' right collision offset
        coBottom AS INTEGER ' bottom collision offset
        applyGravity AS INTEGER ' used for applying gravity
        ' TODO: some clarification may be needed here as these variables are used
        '       both falling and jumping
        jumping AS INTEGER ' used for applying gravity
        jumpstart AS INTEGER ' used for applying gravity
        uid AS STRING * 10
        vx AS INTEGER ' move vector x
        vy AS INTEGER ' move vector y
    END TYPE

    TYPE GXEvent
        event AS INTEGER
        action AS INTEGER
        player AS INTEGER
        entity AS INTEGER
        collisionEntity AS INTEGER
        collisionTile AS INTEGER
        collisionResult AS INTEGER
    END TYPE

    TYPE GXImage
        id AS LONG
        filename AS STRING
    END TYPE

    TYPE GXMapTile
        depth AS INTEGER
        layer1 AS INTEGER
        layer2 AS INTEGER
        layer3 AS INTEGER
    END TYPE

    TYPE GXTileset
        width AS INTEGER
        height AS INTEGER
        columns AS INTEGER
        rows AS INTEGER
        image AS LONG
        filename AS STRING
    END TYPE

    TYPE GXBackground
        image AS LONG
        mode AS INTEGER
        x AS INTEGER
        y AS INTEGER
        width AS INTEGER
        height AS INTEGER
    END TYPE

    TYPE GXMap
        rows AS INTEGER
        columns AS INTEGER
        isometric AS INTEGER
    END TYPE

    TYPE GXScene
        x AS INTEGER
        y AS INTEGER
        width AS INTEGER
        height AS INTEGER
        columns AS INTEGER
        rows AS INTEGER
        image AS LONG
        active AS INTEGER
        embedded AS INTEGER
        followMode AS INTEGER
        followEntity AS INTEGER
        constrainMode AS INTEGER
        frame AS _UNSIGNED LONG
        fullscreen AS INTEGER
    END TYPE

    TYPE GXFont
        eid AS INTEGER
        charSpacing AS INTEGER
        lineSpacing AS INTEGER
    END TYPE

    TYPE GXPlayer
        eid AS INTEGER
        jumpSpeed AS INTEGER
        walkSpeed AS INTEGER
        runSpeed AS INTEGER
    END TYPE

    TYPE GXAction
        type AS INTEGER
        'key AS LONG
        diDeviceId AS INTEGER
        diDeviceType AS INTEGER
        diInputType AS INTEGER
        diInputId AS INTEGER
        diInputValue AS INTEGER
        animationSeq AS INTEGER
        animationFrame AS INTEGER
        animationMode AS INTEGER
        animationSpeed AS INTEGER
        disabled AS INTEGER
    END TYPE

    TYPE GXDebug
        enabled AS INTEGER
        screenEntities AS INTEGER
        tileBorderColor AS _UNSIGNED LONG
        entityBorderColor AS _UNSIGNED LONG
        entityCollisionColor AS _UNSIGNED LONG
        font AS INTEGER
    END TYPE

    TYPE GXDeviceInput
        deviceId AS INTEGER
        deviceType AS INTEGER
        inputType AS INTEGER
        inputId AS INTEGER
        inputValue AS INTEGER
    END TYPE


    ' System Private Globals
    ' ------------------------------------------------------------------------
    DIM SHARED gx_framerate AS INTEGER
    gx_framerate = 90

    DIM SHARED gx_tileset AS GXTileset
    REDIM SHARED gx_map(0, 0) AS GXMapTile
    DIM SHARED gx_map_loading AS INTEGER

    REDIM SHARED gx_images(0) AS GXImage
    DIM SHARED gx_image_count AS INTEGER

    DIM SHARED gx_map AS GXMap
    DIM SHARED gx_scene AS GXScene
    DIM SHARED gx_img_blank AS LONG

    REDIM SHARED gx_bg(0) AS GXBackground
    DIM SHARED gx_bg_count AS INTEGER

    DIM SHARED gx_entity_count AS INTEGER
    REDIM SHARED gx_entities(0) AS GXEntity

    REDIM SHARED gx_fonts(2) AS GXFont
    REDIM SHARED gx_font_charmap(256, 2) AS GXPosition
    DIM SHARED gx_font_count AS INTEGER
    gx_font_count = 2

    REDIM SHARED gx_players(0) AS GXPlayer
    REDIM SHARED gx_player_keymap(0, 10) AS GXAction
    DIM SHARED gx_player_count AS INTEGER

    DIM SHARED gx_debug AS GXDebug
    gx_debug.font = GXFONT_DEFAULT
    gx_debug.tileBorderColor = _RGB32(255, 255, 255)
    gx_debug.entityBorderColor = _RGB32(255, 255, 255)
    gx_debug.entityCollisionColor = _RGB32(255, 255, 0)

    $LET GXBI = TRUE
$END IF
