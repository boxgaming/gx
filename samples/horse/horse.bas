Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
_Title "Horse Runner!"

Dim Shared toggleDebug As Integer
Dim Shared done As Integer
Dim Shared finish As Integer
Dim Shared gameOver As Integer
Dim Shared endy As Integer
endy = 550

GXHardwareAcceleration GX_TRUE
GXFrameRate 90
GXSceneCreate 1280, 720
GXMapLoad "map/horse.map"

Dim bg1 As Integer
Dim bg2 As Integer
Dim bg3 As Integer
bg1 = GXBackgroundAdd("img/scroll_bg_far.png", GXBG_WRAP)
GXBackgroundWrapFactor bg1, .1
bg2 = GXBackgroundAdd("img/hills-scroll.png", GXBG_WRAP)
GXBackgroundWrapFactor bg2, .25
bg3 = GXBackgroundAdd("img/hills-scroll.png", GXBG_WRAP)
GXBackgroundWrapFactor bg3, .5

Dim Shared girl As Integer
girl = GXEntityCreate("img/girl.png", 55, 87, 5)
GXEntityPos girl, 11565, 595
GXEntityAnimateMode girl, GXANIMATE_SINGLE

Dim Shared horse As Integer
horse = GXEntityCreate("img/horse.png", 192, 144, 7)
GXEntityPos horse, -300, 548
GXEntityAnimate horse, 2, 20

Dim i As Integer
Dim tree As Integer
For i = 1 To 4
    tree = GXEntityCreate("img/foreground_tree.png", 207, 382, 1)
    GXEntityPos tree, i * 3000, 350
Next i

GXSceneFollowEntity horse, GXSCENE_FOLLOW_ENTITY_CENTER_X
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP
GXEntityVX horse, 700

GXDebugFont GXFONT_DEFAULT_BLACK
GXDebugTileBorderColor _RGB32(0, 0, 0)
GXDebugEntityBorderColor _RGB32(0, 0, 0)

GXSceneStart
System 0


Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event

        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_UP) Then
                GXEntityPos horse, GXEntityX(horse), GXEntityY(horse) - 1
            End If


            If GXEntityX(horse) > 11400 And done = 0 Then
                done = GXFrame + 30
                GXEntityFrameSet horse, 4, 1
                GXEntityAnimateStop horse
                GXEntityVX horse, 0

            ElseIf GXFrame = done Then
                GXEntityAnimateMode horse, GXANIMATE_SINGLE
                GXEntityFrameSet horse, 4, 1
                GXEntityAnimate horse, 4, 9
                finish = GXFrame + 50

            ElseIf GXFrame = finish Then
                GXEntityAnimate girl, 1, 8
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
            If e.entity = girl Then gameOver = GX_TRUE

        Case GXEVENT_DRAWSCREEN
            If gameOver Then
                GXDrawText GXFONT_DEFAULT_BLACK, 675, endy, "GAME OVER"
                If endy > 350 Then endy = endy - 2
            End If

    End Select

End Sub


'$Include:'../../gx/gx.bm'
