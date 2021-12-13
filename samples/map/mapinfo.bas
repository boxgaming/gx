$Console:Only
'$Include:'../../gx/gx.bi'
_Dest _Console

If Not _FileExists(Command$) Then
    Print "Specified file does not exists"
    System 0
End If

GXMapLoad Command$
Print "Version:   "; GXMapVersion
Print "Rows:      "; GXMapRows
Print "Columns:   "; GXMapColumns
Print "Layers:    "; GXMapLayers
Print "Isometric: "; GXMapIsometric
System

Sub GXOnGameEvent (e As GXEvent): End Sub
'$Include:'../../gx/gx.bm'

