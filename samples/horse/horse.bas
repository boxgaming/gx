$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
_Title "Horse Runner!"

GXHardwareAcceleration GX_TRUE
GXFrameRate 90
GXSceneCreate 1280, 720
GXMapLoad "map/horse.map"

Dim bg, bg2
bg = GXBackgroundAdd("img/scroll_bg_far.png", GXBG_SCROLL)
bg2 = GXBackgroundAdd("img/hills-scroll.png", GXBG_WRAP)
GXBackgroundY bg2, GXSceneHeight - 256
GXBackgroundHeight bg2, 256

GXEntityCreate "img/girl.png", 55, 87, 5, "girl"
GXEntityPos GX("girl"), 11565, 595
GXEntityAnimateMode GX("girl"), GXANIMATE_SINGLE

GXEntityCreate "img/horse.png", 192, 144, 7, "horse"
GXEntityPos GX("horse"), -300, 548
GXEntityAnimate GX("horse"), 2, 20

For i% = 1 To 4
    tree = GXEntityCreate("img/foreground_tree.png", 207, 382, 1)
    GXEntityPos tree, i% * 3000, 350
Next i%

GXSceneFollowEntity GX("horse"), GXSCENE_FOLLOW_ENTITY_CENTER_X
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP
GXEntityVX GX("horse"), 700

GXDebugFont GXFONT_DEFAULT_BLACK
GXDebugTileBorderColor _RGB32(0, 0, 0)
GXDebugEntityBorderColor _RGB32(0, 0, 0)

GXSceneStart
System 0


Sub GXOnGameEvent (e As GXEvent)
    Shared toggleDebug, done, finish, gameOver

    Select Case e.event

        Case GXEVENT_UPDATE

            If GXEntityX(GX("horse")) > 11400 And done = 0 Then
                done = GXFrame + 30
                GXEntityFrameSet GX("horse"), 4, 1
                GXEntityAnimateStop GX("horse")
                GXEntityVX GX("horse"), 0

            ElseIf GXFrame = done Then
                GXEntityAnimateMode GX("horse"), GXANIMATE_SINGLE
                GXEntityFrameSet GX("horse"), 4, 1
                GXEntityAnimate GX("horse"), 4, 9
                finish = GXFrame + 50

            ElseIf GXFrame = finish Then
                GXEntityAnimate GX("girl"), 1, 8
            End If

            If GXKeyDown(GXKEY_ESC) Then
                GXSceneStop
            End If

            ' Toggle debug mode when F1 key is pressed
            If GXKeyDown(GXKEY_F1) Then toggleDebug = GX_TRUE
            If Not GXKeyDown(GXKEY_F1) And toggleDebug Then
                GXDebug Not GXDebug
                toggleDebug = GX_FALSE
            End If

        Case GXEVENT_ANIMATE_COMPLETE
            If e.entity = GX("girl") Then gameOver = GX_TRUE

        Case GXEVENT_DRAWSCREEN
            If gameOver Then GXDrawText GXFONT_DEFAULT_BLACK, 675, 550, "GAME OVER"


    End Select

End Sub


'$Include:'../../gx/gx.bm'
