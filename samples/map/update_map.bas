$Console:Only
'$Include:'../../gx/gx.bi'
_Dest _Console

GXMapLoad Command$
Print "Version:   "; GXMapVersion
Print "Rows:      "; GXMapRows
Print "Columns:   "; GXMapColumns
Print "Layers:    "; GXMapLayers
Print "Isometric: "; GXMapIsometric

GXMapSave Command$ + ".updated.gxm"
System

Sub GXOnGameEvent (e As GXEvent): End Sub
'$Include:'../../gx/gx.bm'

