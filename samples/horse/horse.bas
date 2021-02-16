$EXEICON:'./../../gx/resource/gx.ico'
'$include: '../../gx/gx.bi'

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

GXEntityCreate "img/girl.png", 55, 87, 5, "girl"
GXEntityPos GX("girl"), 5865, 595
GXEntityAnimateMode GX("girl"), GXANIMATE_SINGLE

GXEntityCreate "img/horse.png", 192, 144, 7, "horse"
GXEntityPos GX("horse"), -300, 548
GXEntityAnimate GX("horse"), 2, 20

FOR i% = 1 TO 3
    tree = GXEntityCreate("img/foreground_tree.png", 207, 382, 1)
    GXEntityPos tree, i * 3100, 350
NEXT i%

GXSceneFollowEntity GX("horse"), GXSCENE_FOLLOW_ENTITY_CENTER_X
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP
GXEntityVX GX("horse"), 700

GXDebugFont GXFONT_DEFAULT_BLACK
GXDebugTileBorderColor _RGB32(0, 0, 0)
GXDebugEntityBorderColor _RGB32(0, 0, 0)

GXSceneStart
SYSTEM 0


SUB GXOnGameEvent (e AS GXEvent)
    SHARED toggleDebug, done, finish

    IF e.event = GXEVENT_UPDATE THEN

        IF GXEntityX(GX("horse")) > 5700 AND done = 0 THEN
            done = GXFrame + 30
            GXEntityFrameSet GX("horse"), 4, 1
            GXEntityAnimateOff GX("horse")
            GXEntityVX GX("horse"), 0

        ELSEIF GXFrame = done THEN
            GXEntityAnimateMode GX("horse"), GXANIMATE_SINGLE
            GXEntityFrameSet GX("horse"), 4, 1
            GXEntityAnimate GX("horse"), 4, 9
            finish = GXFrame + 50

        ELSEIF GXFrame = finish THEN
            GXEntityAnimate GX("girl"), 1, 8
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
