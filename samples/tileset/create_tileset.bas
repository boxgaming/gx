Option _Explicit
'$Include:'../../gx/gx.bi'

Dim Shared toggleDebug As Integer

GXSceneCreate 64, 64
GXSceneWindowSize 192, 192
GXTilesetCreate "../overworld/img/overworld.png", 16, 16

GXTilesetAnimationCreate 41, 5
GXTilesetAnimationAdd 41, 42
GXTilesetAnimationAdd 41, 43
GXTilesetAnimationAdd 41, 81
GXTilesetAnimationAdd 41, 82
GXTilesetAnimationAdd 41, 83

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

GXTilesetSave "test.gxt"

GXSceneStart
System

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop
            ' Toggle debug mode when F1 key is pressed

            If GXKeyDown(GXKEY_F1) Then toggleDebug = GX_TRUE
            If Not GXKeyDown(GXKEY_F1) And toggleDebug Then
                GXDebug Not GXDebug
                toggleDebug = GX_FALSE
            End If
    End Select

End Sub

'$Include:'../../gx/gx.bm'

