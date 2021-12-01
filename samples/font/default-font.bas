$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
_Title "Default Font Test"

GXSceneCreate 355, 200
GXSceneScale 2
GXSceneStart
System 0

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event

        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop

        Case GXEVENT_DRAWSCREEN
            GXDrawText GXFONT_DEFAULT, 20, 20, _
                "This is the default font:" + GX_CRLF + GX_CRLF + _
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + GX_CRLF + _
                "abcdefghijklmnopqrstuvwxyz" + GX_CRLF + _
                "01234567890" + GX_CRLF + _
                "~@#$%^&*_-+=/|\:;,.?!()<>{}[]`'" + CHR$(34)

            Line (0, 100)-(355, 200), _RGB(255, 255, 255), BF
            GXDrawText GXFONT_DEFAULT_BLACK, 20, 120, _
                "Here is the black version:" + GX_CRLF + GX_CRLF + _
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + GX_CRLF + _
                "abcdefghijklmnopqrstuvwxyz" + GX_CRLF + _
                "01234567890" + GX_CRLF + _
                "~@#$%^&*_-+=/|\:;,.?!()<>{}[]`'" + CHR$(34)
    End Select
End Sub

'$Include:'../../gx/gx.bm'

