$EXEICON:'./../../gx/resource/gx.ico'
'$include: '../../gx/gx.bi'
_TITLE "Default Font Test"

GXSceneCreate 355, 200
GXSceneStart
SYSTEM 0

SUB GXOnGameEvent (e AS GXEvent)
    SELECT CASE e.event

        CASE GXEVENT_UPDATE
            IF GXKeyDown(GXKEY_ESC) THEN GXSceneStop

        CASE GXEVENT_DRAWSCREEN
            GXDrawText GXFONT_DEFAULT, 20, 20, _
                "This is the default font:" + GX_CRLF + GX_CRLF + _
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + GX_CRLF + _
                "abcdefghijklmnopqrstuvwxyz" + GX_CRLF + _
                "01234567890" + GX_CRLF + _
                "~@#$%^&*_-+=/|\:;,.?!()<>{}[]`'" + CHR$(34)

            LINE (0, 100)-(355, 200), _RGB(255, 255, 255), BF
            GXDrawText GXFONT_DEFAULT_BLACK, 20, 120, _
                "Here is the black version:" + GX_CRLF + GX_CRLF + _
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + GX_CRLF + _
                "abcdefghijklmnopqrstuvwxyz" + GX_CRLF + _
                "01234567890" + GX_CRLF + _
                "~@#$%^&*_-+=/|\:;,.?!()<>{}[]`'" + CHR$(34)
    END SELECT
END SUB

'$include: '../../gx/gx.bm'

