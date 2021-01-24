OPTION _EXPLICIT
'$include: '../../gx/gx.bi'

'GXSceneCreate 355, 200
GXSceneCreate 500, 282
'GXSceneCreate 710, 400
GXMapLoad "map/z.map"
GXFullScreenOn

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

SUB GXOnGameEvent (e AS GXEvent)
    SELECT CASE e.event

        CASE GXEVENT_UPDATE
            IF _KEYDOWN(GXKEY_ESC) THEN GXSceneStop

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

'SUB DrawDebug
'    DIM tx, ty, t, td, t1, t2, t3, sx, sy, i, tpx, tpy, ex, ey
'    sx = GXSceneX
'    sy = GXSceneY
'    IF sx < 0 THEN sx = 0
'    IF sy < 0 THEN sy = 0


'    _FONT fnt
'    _PRINTMODE _KEEPBACKGROUND
'    COLOR _RGB(255, 255, 255)
'    _PRINTSTRING (1, 1), "E:" + STR$(GXEntityX(link)) + "," + STR$(GXEntityY(link))
'    _PRINTSTRING (1, 11), "S:" + STR$(GXSceneX) + "," + STR$(GXSceneY)
'    _PRINTSTRING (1, 21), "M:" + STR$(movex) + "," + STR$(movey)


'    tx = FIX((GXEntityX(link) + 0) / GXTilesetWidth)
'    ty = FIX((GXEntityY(link) + 0) / GXTilesetHeight)
'    td = GXMapTileDepth(tx, ty)
'    t1 = GXMapTile(tx, ty, 1)
'    t2 = GXMapTile(tx, ty, 2)
'    t3 = GXMapTile(tx, ty, 3)
'    _PRINTSTRING (1, 31), "T:" + STR$(tx) + "," + STR$(ty) + " - " + STR$(td) + ":" + STR$(t1) + "," + STR$(t2) + "," + STR$(t3)

'    DIM tcount AS INTEGER
'    REDIM tiles(0) AS GXPosition
'    CollisionTiles link, movex, movey, tiles(), tcount

'    FOR i = 0 TO tcount - 1
'        tx = tiles(i).x
'        ty = tiles(i).y

'        tpx = tx * GXTilesetWidth - GXSceneX
'        tpy = ty * GXTilesetHeight - GXSceneY
'        LINE (tpx, tpy)-(tpx + GXTilesetWidth, tpy + GXTilesetHeight), _RGB(255, 255, 255), B
'    NEXT i

'    ex = GXEntityX(link) - GXSceneX
'    ey = GXEntityY(link) - GXSceneY
'    LINE (ex, ey + 10)-(ex + GXEntityWidth(link), ey + GXEntityHeight(link)), _RGB(0, 255, 0), B
'END SUB

'FUNCTION TestMove (mx AS INTEGER, my AS INTEGER)
'    DIM tcount AS INTEGER
'    REDIM tiles(0) AS GXPosition
'    CollisionTiles link, mx, my, tiles(), tcount


'    DIM move AS INTEGER
'    move = 1

'    IF nocollision = 0 THEN
'        DIM i AS INTEGER, j AS INTEGER
'        DIM tile AS INTEGER
'        FOR i = 0 TO tcount - 1
'            FOR j = 1 TO GXMapTileDepth(tiles(i).x, tiles(i).y)
'                tile = GXMapTile(tiles(i).x, tiles(i).y, j)
'                IF IsMoveTile(tile) = 0 THEN
'                    move = 0
'                END IF
'            NEXT j
'        NEXT i
'    END IF

'    TestMove = move
'END FUNCTION


'SUB CollisionTiles (entity AS INTEGER, movex AS INTEGER, movey AS INTEGER, tiles() AS GXPosition, tcount AS INTEGER)
'    DIM tx AS INTEGER, ty AS INTEGER
'    DIM tx0 AS INTEGER, txn AS INTEGER
'    DIM ty0 AS INTEGER, tyn AS INTEGER
'    DIM x AS INTEGER, y AS INTEGER, i AS INTEGER

'    ' This is the starting point for defining a collision rect for an entity
'    ' At the moment the collision rect will be the size of the entity minus
'    ' the top 10 pixels.  This needs to be incorporated into the entity model.
'    DIM cy AS INTEGER
'    cy = 10

'    IF movex <> 0 THEN
'        DIM startx AS INTEGER
'        startx = -1
'        IF movex > 0 THEN startx = GXEntityWidth(entity) * movex + 1
'        tx = FIX((GXEntityX(entity) + startx) / GXTilesetWidth)

'        ' This is a real brute force way to find the intersecting tiles
'        ' We're basically testing every pixel along the edge of the entity's
'        ' collision rect and incrementing the collision tile count.
'        ' With a bit more math I'm sure we could avoid some extra loops here.
'        tcount = 0
'        ty0 = 0
'        'lastty = 0
'        FOR y = GXEntityY(entity) + cy TO GXEntityY(entity) + GXEntityHeight(entity)
'            ty = FIX(y / GXTilesetHeight)
'            IF tcount = 0 THEN ty0 = ty
'            IF NOT ty = tyn THEN
'                tcount = tcount + 1
'            END IF
'            tyn = ty
'        NEXT y

'        ' Add the range of detected tile positions to the return list
'        REDIM tiles(tcount) AS GXPosition
'        i = 0
'        FOR ty = ty0 TO tyn
'            tiles(i).x = tx
'            tiles(i).y = ty
'            i = i + 1
'        NEXT ty
'    END IF

'    IF movey <> 0 THEN
'        DIM starty AS INTEGER
'        starty = -1 + cy
'        IF movey > 0 THEN starty = GXEntityHeight(entity) * movey + 1
'        'tx = FIX((GXEntityX(entity) + 0) / GXTilesetWidth)
'        ty = FIX((GXEntityY(entity) + starty) / GXTilesetHeight)
'        'txn = tx + GXEntityWidth(entity) / GXTilesetWidth
'        'tcount = txn - tx + 1

'        ' This is a real brute force way to find the intersecting tiles
'        ' We're basically testing every pixel along the edge of the entity's
'        ' collision rect and incrementing the collision tile count.
'        ' With a bit more math I'm sure we could avoid some extra loops here.
'        tcount = 0
'        tx0 = 0
'        FOR x = GXEntityX(entity) TO GXEntityX(entity) + GXEntityWidth(entity)
'            tx = FIX(x / GXTilesetWidth)
'            IF tcount = 0 THEN tx0 = tx
'            IF NOT tx = txn THEN
'                tcount = tcount + 1
'            END IF
'            txn = tx
'        NEXT x


'        REDIM tiles(tcount) AS GXPosition
'        i = 0
'        'FOR tx = tx TO tx + GXEntityWidth(entity) / GXTilesetWidth
'        FOR tx = tx0 TO txn
'            tiles(i).x = tx
'            tiles(i).y = ty
'            i = i + 1
'        NEXT tx
'    END IF
'END SUB


'$include: '../../gx/gx.bm'

