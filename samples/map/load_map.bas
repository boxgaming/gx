'$Include:'../../gx/gx.bi'

GXSceneCreate 640, 400
GXMapLoad "../overworld/map/overworld.map"
'GXMapLoad "../../../sci/map/mario1-2.map"
'GXMapLoad "./smb1-2.map"
'GXMapLoad "test.map"
'PRINT "Rows:      "; GXMapRows
'PRINT "Columns:   "; GXMapColumns
'PRINT "Layers:    "; gx_map.layers
'PRINT "Isometric: "; GXMapIsometric
'DIM foo: INPUT foo

'GXMapTile 0, 0, 1, 3

'GXMapSave "./smb1-2.map"

GXSceneStart

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop
    End Select
End Sub
'$Include:'../../gx/gx.bm'

