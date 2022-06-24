$ExeIcon:'./../../gx/resource/gx.ico'
'$Include: '../../gx/gx.bi'
Const RIGHT = 1
Const LEFT = 2
Const DOWN = 3
Const UP = 4
Const SPEED = 60
Dim Shared toggleDebug As Integer
Dim Shared player As Integer

GXSceneCreate 320, 200
GXSceneScale 3
GXMapLoad "map/interior-test.gxm"
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP

' Hide the collision layer from view
GXMapLayerVisible 5, GX_FALSE

CreatePlayer

GXSceneStart
System

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop
            TestToggleDebug
            HandlePlayerControls

        Case GXEVENT_COLLISION_TILE
            Dim tile As Integer
            tile = GXMapTile(e.collisionTileX, e.collisionTileY, 5)
            If tile > 0 Then e.collisionResult = 1

        Case GXEVENT_DRAWSCREEN
            If Not GXDebug Then
                GXDrawText GXFONT_DEFAULT, 175, 1, "Press D to Toggle Debug" + Chr$(10) + "Press ESC to Quit"
            End If
    End Select
End Sub

Sub CreatePlayer
    player = GXEntityCreate("img/character.png", 16, 20, 4)

    GXEntityAnimate player, 3, 0
    GXEntityPos player, 100, 100
    GXEntityCollisionOffset player, 4, 12, 4, 0
    GXSceneFollowEntity player, GXSCENE_FOLLOW_ENTITY_CENTER
End Sub

Sub HandlePlayerControls

    If GXKeyDown(GXKEY_DOWN) Then
        GXEntityVX player, 0
        GXEntityVY player, SPEED
        GXEntityAnimate player, DOWN, 10

    ElseIf GXKeyDown(GXKEY_UP) Then
        GXEntityVX player, 0
        GXEntityVY player, -SPEED
        GXEntityAnimate player, UP, 10

    ElseIf GXKeyDown(GXKEY_RIGHT) Then
        GXEntityVX player, SPEED
        GXEntityVY player, 0
        GXEntityAnimate player, RIGHT, 10

    ElseIf GXKeyDown(GXKEY_LEFT) Then
        GXEntityVX player, -SPEED
        GXEntityVY player, 0
        GXEntityAnimate player, LEFT, 10

    Else
        GXEntityVX player, 0
        GXEntityVY player, 0
        GXEntityAnimateStop player
    End If
End Sub


Sub TestToggleDebug
    ' Toggle debug mode when F1 key is pressed
    If GXKeyDown(GXKEY_D) Then toggleDebug = GX_TRUE
    If Not GXKeyDown(GXKEY_D) And toggleDebug Then
        GXDebug Not GXDebug
        GXMapLayerVisible 5, GXDebug
        toggleDebug = GX_FALSE
    End If
End Sub


'$Include: '../../gx/gx.bm'
