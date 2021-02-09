'$include: '../../gx/gx.bi'

DIM SHARED horse, girl, done, finish

GXSceneCreate 1280, 720
GXMapLoad "map/horse.map"

DIM bg
bg = GXBackgroundAdd("img/scroll_bg_far.png")
GXBackgroundMode bg, GXBG_SCROLL

'DIM bg2
'bg2 = GXBackgroundAdd("img/hills-scroll.png")
'GXBackgroundMode bg2, GXBG_WRAP
'GXBackgroundY bg2, GXSceneHeight / 2
'GXBackgroundHeight bg2, GXSceneHeight / 2

girl = GXEntityCreate("img/girl.png", 55, 87, 5)
GXEntityPos girl, 5865, 595
GXEntityAnimateMode girl, GXANIMATE_SINGLE

horse = GXEntityCreate("img/horse.png", 192, 144, 7)
'GXEntityPos horse, 530, 548
GXEntityPos horse, -300, 548
GXEntityAnimate horse, 2, 20

FOR i = 1 TO 3
    tree = GXEntityCreate("img/foreground_tree.png", 207, 382, 1)
    GXEntityPos tree, i * 3100, 350
NEXT i

GXSceneFollowEntity horse, GXSCENE_FOLLOW_ENTITY_CENTER_X
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP
GXEntityVX horse, 700

GXDebugFont GXFONT_DEFAULT_BLACK
GXDebugTileBorderColor _RGB32(0, 0, 0)
GXDebugEntityBorderColor _RGB32(0, 0, 0)

GXSceneStart
SYSTEM 0

DIM SHARED toggleDebug AS INTEGER

SUB GXOnGameEvent (e AS GXEvent)
    IF e.event = GXEVENT_UPDATE THEN

        IF GXEntityX(horse) > 5700 AND done = 0 THEN
            done = GXFrame + 30
            GXEntityFrameSet horse, 4, 1
            GXEntityAnimateOff horse
            GXEntityVX horse, 0

        ELSEIF GXFrame = done THEN
            GXEntityAnimateMode horse, GXANIMATE_SINGLE
            GXEntityFrameSet horse, 4, 1
            GXEntityAnimate horse, 4, 9
            finish = GXFrame + 50

        ELSEIF GXFrame = finish THEN
            GXEntityAnimate girl, 1, 8
        END IF

        IF _KEYDOWN(GXKEY_ESC) THEN
            GXSceneStop
        END IF

        ' Toggle debug mode when F1 key is pressed
        IF GXKeyDown(GXKEY_F1) THEN toggleDebug = GX_TRUE
        IF NOT GXKeyDown(GXKEY_F1) AND toggleDebug THEN
            GXDebug NOT GXDebug
            toggleDebug = GX_FALSE
        END IF

    END IF

END SUB


'$include: '../../gx/gx.bm'
