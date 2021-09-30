OPTION _EXPLICIT
'$INCLUDE:'../../gx/gx.bi'

DIM SHARED toggleDebug AS INTEGER

GXSceneCreate 64, 64
GXSceneWindowSize 192, 192
GXTilesetLoad "test.gxt"

GXMapCreate 10, 10, 1
GXMapTile 0, 0, 1, 243
GXMapTile 1, 0, 1, 244
GXMapTile 2, 0, 1, 245
GXMapTile 0, 1, 1, 283
GXMapTile 1, 1, 1, 41
GXMapTile 2, 1, 1, 285
GXMapTile 0, 2, 1, 323
GXMapTile 1, 2, 1, 324
GXMapTile 2, 2, 1, 325


GXSceneStart
SYSTEM

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
    END SELECT

END SUB


'$INCLUDE:'../../gx/gx.bm'

