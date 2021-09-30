$CONSOLE:ONLY
'$INCLUDE:'../../gx/gx.bi'
_DEST _CONSOLE

GXMapLoad COMMAND$
PRINT "Version:   "; GXMapVersion
PRINT "Rows:      "; GXMapRows
PRINT "Columns:   "; GXMapColumns
PRINT "Layers:    "; GXMapLayers
PRINT "Isometric: "; GXMapIsometric

GXMapSave COMMAND$ + ".updated.gxm"
SYSTEM

SUB GXOnGameEvent (e AS GXEvent): END SUB
'$INCLUDE:'../../gx/gx.bm'

