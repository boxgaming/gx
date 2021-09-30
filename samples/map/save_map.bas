'$INCLUDE:'../../gx/gx.bi'

GXSceneCreate 320, 200
GXTilesetCreate "../overworld/img/overworld.png", 16, 16
GXMapCreate 10, 10, 3

'GXMapTileAdd 0, 0, 1
'GXMapTileAdd 1, 0, 1
'GXMapTileAdd 1, 0, 2
GXMapTile 0, 0, 1, 1
GXMapTile 1, 0, 2, 2
GXMapTile 1, 0, 1, 1
GXMapTile 5, 5, 1, 1
GXMapTile 5, 5, 2, 2

GXSceneStart

SUB GXOnGameEvent (e AS GXEvent)
    SELECT CASE e.event
        CASE GXEVENT_UPDATE
            IF GXKeyDown(GXKEY_ESC) THEN
                GXSceneStop
                GXMapSave "test.gxm"
            END IF
    END SELECT
END SUB
'$INCLUDE:'../../gx/gx.bm'
