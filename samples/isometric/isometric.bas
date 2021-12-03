Option _Explicit
'$Include:'../../gx/gx.bi'

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

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop
        Case GXEVENT_DRAWSCREEN
            Dim p As GXPosition
            DrawCursor
    End Select
End Sub
'$Include:'../../gx/gx.bm'




Sub DrawCursor
    Dim p As GXPosition
    GXMapTilePosAt _MouseX, _MouseY, p
    GXDrawText GXFONT_DEFAULT, _MouseX, _MouseY, "(" + Str$(p.x) + "," + Str$(p.y) + ")"

    If Not GXMapIsometric Then
        Line (p.x * GXTilesetWidth, p.y * GXTilesetHeight)-(p.x * GXTilesetWidth + GXTilesetWidth, p.y * GXTilesetHeight + GXTilesetHeight), _RGB32(200, 200, 200), B
    Else
        Dim columnOffset As Long
        If p.y Mod 2 = 1 Then
            columnOffset = 0 'GXTilesetWidth
        Else
            columnOffset = GXTilesetWidth / 2
        End If

        Dim rowOffset As Long
        rowOffset = (p.y + 1) * (GXTilesetHeight * .75)

        Dim tx As Long: tx = p.x * GXTilesetWidth - columnOffset
        Dim ty As Long: ty = p.y * GXTilesetHeight - rowOffset

        'LINE (tx, ty)-(tx + GXTilesetWidth, ty + GXTilesetHeight), _RGB32(200, 200, 200), B

        Dim topY As Long: topY = ty + GXTilesetHeight * .5
        Dim midY As Long: midY = ty + GXTilesetHeight * .75
        Dim midX As Long: midX = tx + GXTilesetWidth * .5
        Dim rightX As Long: rightX = tx + GXTilesetWidth
        Dim bottomY As Long: bottomY = ty + GXTilesetHeight

        Line (tx, midY)-(midX, topY), _RGB32(255, 255, 255)
        Line (midX, topY)-(rightX, midY), _RGB(255, 255, 255)
        Line (rightX, midY)-(midX, bottomY), _RGB(255, 255, 255)
        Line (midX, bottomY)-(tx, midY), _RGB(255, 255, 255)
    End If
End Sub

