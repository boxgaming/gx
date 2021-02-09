'$RESIZE:ON
OPTION _EXPLICIT
'$include: '../../gx/gx.bi'

'GXSceneCreate 355, 200
GXSceneCreate 500, 282
'GXSceneCreate 710, 400
GXMapLoad "map/overworld.map"
GXFullScreen GX_TRUE
'GXDebug GX_TRUE

DIM flag AS INTEGER
flag = GXEntityCreate("img/flag.png", 32, 64, 5)
GXEntityPos flag, 30, 20
GXEntityAnimate flag, 1, 10

DIM fire AS INTEGER
fire = GXEntityCreate("img/fire.png", 16, 16, 7)
GXEntityPos fire, 267, 135
GXEntityAnimate fire, 1, 10

CONST ETYPE_COIN = 1000

DIM coin AS INTEGER
coin = GXEntityCreate("img/coin.png", 16, 16, 4)
'GXEntityPos coin, 265, 17
GXEntityPos coin, 265, 70
GXEntityAnimate coin, 1, 8
GXEntityType coin, ETYPE_COIN
GXEntityCollisionOffsetSet coin, 4, 5, 4, 3


DIM bob AS INTEGER
bob = GXEntityCreate("img/character.png", 16, 20, 4)
GXEntityPos bob, GXSceneWidth / 2 - 8, GXSceneHeight / 2 - 10
GXEntityCollisionOffsetSet bob, 3, 10, 3, 0

DIM player AS INTEGER
player = GXPlayerCreate(bob)
GXPlayerMoveSpeed player, 90
MapPlayerMoveAction player, GXACTION_MOVE_LEFT, GXKEY_A, 2, 10
MapPlayerMoveAction player, GXACTION_MOVE_RIGHT, GXKEY_D, 1, 10
MapPlayerMoveAction player, GXACTION_MOVE_UP, GXKEY_W, 4, 10
MapPlayerMoveAction player, GXACTION_MOVE_DOWN, GXKEY_S, 3, 10

GXSceneFollowEntity bob, GXSCENE_FOLLOW_ENTITY_CENTER
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP


DIM SHARED movetilecount AS INTEGER
REDIM SHARED movetiles(movetilecount) AS INTEGER
SetMoveTiles

GXSceneStart
SYSTEM 0

DIM SHARED toggleDebug AS INTEGER

SUB GXOnGameEvent (e AS GXEvent)
    SELECT CASE e.event

        CASE GXEVENT_UPDATE
            IF GXKeyDown(GXKEY_ESC) THEN GXSceneStop

            ' Toggle debug mode when F1 key is pressed
            IF GXKeyDown(GXKEY_F1) THEN toggleDebug = GX_TRUE
            IF NOT GXKeyDown(GXKEY_F1) AND toggleDebug THEN
                GXDebug NOT GXDebug
                toggleDebug = GX_FALSE
            END IF

        CASE GXEVENT_COLLISION_TILE
            IF IsMoveTile(e.collisionTile) <> 1 THEN e.collisionResult = 1

        CASE GXEVENT_COLLISION_ENTITY
            IF GXEntityType(e.collisionEntity) = ETYPE_COIN THEN e.collisionResult = 1

    END SELECT
END SUB

SUB MapPlayerMoveAction (pid AS INTEGER, action AS INTEGER, akey AS INTEGER, animationSeq AS INTEGER, animationSpeed AS INTEGER)
    GXPlayerActionKey pid, action, akey
    GXPlayerActionAnimationSeq pid, action, animationSeq
    GXPlayerActionAnimationSpeed pid, action, animationSpeed
END SUB

FUNCTION IsMoveTile (tile AS INTEGER)
    IsMoveTile = 0
    DIM i AS INTEGER
    FOR i = 1 TO movetilecount
        IF tile = movetiles(i) THEN
            IsMoveTile = 1
            EXIT FOR
        END IF
    NEXT i
END FUNCTION

SUB SetMoveTiles
    movetilecount = 18
    REDIM movetiles(movetilecount) AS INTEGER
    movetiles(1) = 0
    movetiles(2) = 444
    movetiles(3) = 445
    movetiles(4) = 446
    movetiles(5) = 360
    movetiles(6) = 689
    movetiles(7) = 682
    movetiles(8) = 282
    movetiles(9) = 290
    movetiles(10) = 289
    movetiles(11) = 284
    movetiles(12) = 690
    movetiles(13) = 404
    movetiles(14) = 328
    movetiles(16) = 690
    movetiles(17) = 361
    movetiles(18) = 288
END SUB



'$include: '../../gx/gx.bm'

