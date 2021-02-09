$IF GXBI = UNDEFINED THEN
    'OPTION _EXPLICIT

    ' GX System Constants
    ' ------------------------------------------------------------------------
    CONST GX_FALSE = 0
    CONST GX_TRUE = NOT GX_FALSE

    'CONST GXEVENT_KEYDOWN = 1
    'CONST GXEVENT_KEYUP = 2
    'CONST GXEVENT_GAMELOOP = 3
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

    CONST GXKEY_ESC = 27
    CONST GXKEY_TAB = 9
    CONST GXKEY_ENTER = 13
    CONST GXKEY_F1 = 15104
    CONST GXKEY_F2 = 15360
    CONST GXKEY_F3 = 15616
    CONST GXKEY_F4 = 15872
    CONST GXKEY_F5 = 16128
    CONST GXKEY_F6 = 16384
    CONST GXKEY_F7 = 16640
    CONST GXKEY_F8 = 16896
    CONST GXKEY_F9 = 17152
    CONST GXKEY_F10 = 17408
    CONST GXKEY_F11 = 34048
    CONST GXKEY_F12 = 34304
    CONST GXKEY_LEFT = 19200
    CONST GXKEY_RIGHT = 19712
    CONST GXKEY_UP = 18432
    CONST GXKEY_DOWN = 20480
    CONST GXKEY_PGUP = 18688
    CONST GXKEY_PGDN = 20736
    CONST GXKEY_INS = 200000
    CONST GXKEY_DEL = 21248
    CONST GXKEY_HOME = 200007
    CONST GXKEY_END = 200001
    CONST GXKEY_LCTRL = 100306
    CONST GXKEY_RCTRL = 100305
    CONST GXKEY_LALT = 100308
    CONST GXKEY_RALT = 100307
    CONST GXKEY_LSHIFT = 100304
    CONST GXKEY_RSHIFT = 100303

    CONST GXKEY_0 = 48
    CONST GXKEY_1 = 49
    CONST GXKEY_2 = 50
    CONST GXKEY_3 = 51
    CONST GXKEY_4 = 52
    CONST GXKEY_5 = 53
    CONST GXKEY_6 = 54
    CONST GXKEY_7 = 55
    CONST GXKEY_8 = 56
    CONST GXKEY_9 = 57

    CONST GXKEY_A = 97
    CONST GXKEY_B = 98
    CONST GXKEY_C = 99
    CONST GXKEY_D = 100
    CONST GXKEY_E = 101
    CONST GXKEY_F = 102
    CONST GXKEY_G = 103
    CONST GXKEY_H = 104
    CONST GXKEY_I = 105
    CONST GXKEY_J = 106
    CONST GXKEY_K = 107
    CONST GXKEY_L = 108
    CONST GXKEY_M = 109
    CONST GXKEY_N = 110
    CONST GXKEY_O = 111
    CONST GXKEY_P = 112
    CONST GXKEY_Q = 113
    CONST GXKEY_R = 114
    CONST GXKEY_S = 115
    CONST GXKEY_T = 116
    CONST GXKEY_U = 117
    CONST GXKEY_V = 118
    CONST GXKEY_W = 119
    CONST GXKEY_X = 120
    CONST GXKEY_Y = 121
    CONST GXKEY_Z = 122

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
        key AS LONG
        movex AS INTEGER
        movey AS INTEGER
        animationSeq AS INTEGER
        animationFrame AS INTEGER
        animationMode AS INTEGER
        animationSpeed AS INTEGER
    END TYPE

    TYPE GXDebug
        enabled AS INTEGER
        screenEntities AS INTEGER
        tileBorderColor AS _UNSIGNED LONG
        entityBorderColor AS _UNSIGNED LONG
        entityCollisionColor AS _UNSIGNED LONG
        font AS INTEGER
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
