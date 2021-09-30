OPTION _EXPLICIT
'$INCLUDE:'../../gx/gx.bi'

GXSceneCreate 640, 400
GXTilesetCreate "./iso-tiles.png", 64, 64
GXMapCreate 50, 50, 2
GXMapIsometric GX_TRUE

GXMapTileAdd 0, 0, 1
GXMapTileAdd 1, 0, 1
GXMapTileAdd 2, 0, 1
GXMapTileAdd 0, 0, 59
GXMapTileAdd 1, 0, 59
GXMapTileAdd 2, 0, 59
GXMapTileAdd 0, 1, 2
GXMapTileAdd 1, 1, 2
GXMapTileAdd 2, 1, 2
GXMapTileAdd 0, 2, 83
GXMapTileAdd 1, 2, 83
GXMapTileAdd 2, 2, 83

GXSceneStart

SUB GXOnGameEvent (e AS GXEvent)
    SELECT CASE e.event
        CASE GXEVENT_UPDATE
            IF GXKeyDown(GXKEY_ESC) THEN GXSceneStop
        CASE GXEVENT_DRAWSCREEN
            DIM p AS GXPosition
            DrawCursor
    END SELECT
END SUB
'$INCLUDE:'../../gx/gx.bm'




SUB DrawCursor
    DIM p AS GXPosition
    GXMapTilePosAt _MOUSEX, _MOUSEY, p
    GXDrawText GXFONT_DEFAULT, _MOUSEX, _MOUSEY, "(" + STR$(p.x) + "," + STR$(p.y) + ")"

    IF NOT GXMapIsometric THEN
        LINE (p.x * GXTilesetWidth, p.y * GXTilesetHeight)-(p.x * GXTilesetWidth + GXTilesetWidth, p.y * GXTilesetHeight + GXTilesetHeight), _RGB32(200, 200, 200), B
    ELSE
        DIM columnOffset AS LONG
        IF p.y MOD 2 = 1 THEN
            columnOffset = 0 'GXTilesetWidth
        ELSE
            columnOffset = GXTilesetWidth / 2
        END IF

        DIM rowOffset AS LONG
        rowOffset = (p.y + 1) * (GXTilesetHeight * .75)

        DIM tx AS LONG: tx = p.x * GXTilesetWidth - columnOffset
        DIM ty AS LONG: ty = p.y * GXTilesetHeight - rowOffset

        'LINE (tx, ty)-(tx + GXTilesetWidth, ty + GXTilesetHeight), _RGB32(200, 200, 200), B

        DIM topY AS LONG: topY = ty + GXTilesetHeight * .5
        DIM midY AS LONG: midY = ty + GXTilesetHeight * .75
        DIM midX AS LONG: midX = tx + GXTilesetWidth * .5
        DIM rightX AS LONG: rightX = tx + GXTilesetWidth
        DIM bottomY AS LONG: bottomY = ty + GXTilesetHeight

        LINE (tx, midY)-(midX, topY), _RGB32(255, 255, 255)
        LINE (midX, topY)-(rightX, midY), _RGB(255, 255, 255)
        LINE (rightX, midY)-(midX, bottomY), _RGB(255, 255, 255)
        LINE (midX, bottomY)-(tx, midY), _RGB(255, 255, 255)
    END IF
END SUB

