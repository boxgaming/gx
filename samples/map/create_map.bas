'$Include:'../../gx/gx.bi'

GXSceneCreate 320, 200
GXTilesetCreate "../overworld/img/overworld.png", 16, 16
GXMapCreate 100, 100, 3

GXMapTileAdd 0, 0, 1
GXMapTileAdd 1, 0, 1
GXMapTileAdd 1, 0, 2

GXSceneStart

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop
    End Select
End Sub
'$Include:'../../gx/gx.bm'
