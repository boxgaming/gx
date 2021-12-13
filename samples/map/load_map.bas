'$Include:'../../gx/gx.bi'

GXSceneCreate 640, 400
GXMapLoad "../overworld/map/overworld.map"

GXSceneStart

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop
    End Select
End Sub
'$Include:'../../gx/gx.bm'

