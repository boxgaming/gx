Option _Explicit
$Console:Only
$ExeIcon:'./../gx/resource/gx.ico'
'$include: '../gx/gx.bi'

ReDim args(0) As String
Dim argc As Integer
argc = GXSTR_Split(Command$, " ", args())

GXMapLoad args(1) '"../samples/cashflow/map/factory.gxm"
GXMapSaveWeb args(2) '"test.gxm.json"
System

Sub GXOnGameEvent (e As GXEvent): End Sub
'$include: '../gx/gx.bm'
