$CONSOLE:ONLY
'$INCLUDE:'../../gx/gx.bi'
_DEST _CONSOLE

'GXSceneEmbedded GX_TRUE
'GXSceneCreate 640, 480

IF NOT _FILEEXISTS(COMMAND$) THEN
    PRINT "Specified file does not exists"
    SYSTEM 0
END IF

GXMapLoad COMMAND$
PRINT "Version:   "; GXMapVersion
PRINT "Rows:      "; GXMapRows
PRINT "Columns:   "; GXMapColumns
PRINT "Layers:    "; GXMapLayers
PRINT "Isometric: "; GXMapIsometric
SYSTEM

SUB GXOnGameEvent (e AS GXEvent): END SUB
'$INCLUDE:'../../gx/gx.bm'

