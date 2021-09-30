'$INCLUDE:'../../gx/gx.bi'
DIM SHARED toggleDebug

GXSceneCreate 320, 200
GXSceneScale 3
GXMapLoad "interior-test.gxm"
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP

' Hide the collision layer from view
GXMapLayerVisible 5, GX_FALSE

CreatePlayer

GXSceneStart

SUB GXOnGameEvent (e AS GXEvent)
    SELECT CASE e.event
        CASE GXEVENT_UPDATE
            IF GXKeyDown(GXKEY_ESC) THEN GXSceneStop
            TestToggleDebug

        CASE GXEVENT_COLLISION_TILE
            DIM tile AS INTEGER
            tile = GXMapTile(e.collisionTileX, e.collisionTileY, 5)
            IF tile > 0 THEN e.collisionResult = 1

    END SELECT
END SUB

SUB CreatePlayer
    GXEntityCreate "../overworld/img/character.png", 16, 20, 4, "player"
    DIM playerEntity AS LONG
    playerEntity = GX("player")

    GXEntityAnimate playerEntity, 3, 0
    GXEntityPos playerEntity, 100, 100
    GXEntityCollisionOffset playerEntity, 4, 12, 4, 0
    GXSceneFollowEntity playerEntity, GXSCENE_FOLLOW_ENTITY_CENTER

    DIM player AS LONG
    player = GXPlayerCreate(playerEntity)
    GXPlayerMoveKey player, GXACTION_MOVE_LEFT, GXKEY_LEFT, 2, 10
    GXPlayerMoveKey player, GXACTION_MOVE_RIGHT, GXKEY_RIGHT, 1, 10
    GXPlayerMoveKey player, GXACTION_MOVE_UP, GXKEY_UP, 4, 10
    GXPlayerMoveKey player, GXACTION_MOVE_DOWN, GXKEY_DOWN, 3, 10
END SUB

SUB TestToggleDebug
    ' Toggle debug mode when F1 key is pressed
    IF GXKeyDown(GXKEY_F1) THEN toggleDebug = GX_TRUE
    IF NOT GXKeyDown(GXKEY_F1) AND toggleDebug THEN
        GXDebug NOT GXDebug
        GXMapLayerVisible 5, GXDebug
        toggleDebug = GX_FALSE
    END IF
END SUB


'$INCLUDE:'../../gx/gx.bm'

