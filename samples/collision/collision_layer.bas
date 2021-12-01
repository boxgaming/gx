'$Include: '../../gx/gx.bi'
Dim Shared toggleDebug

GXSceneCreate 320, 200
GXSceneScale 3
GXMapLoad "map/interior-test.gxm"
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP

' Hide the collision layer from view
GXMapLayerVisible 5, GX_FALSE

CreatePlayer

GXSceneStart

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop
            TestToggleDebug

        Case GXEVENT_COLLISION_TILE
            Dim tile As Integer
            tile = GXMapTile(e.collisionTileX, e.collisionTileY, 5)
            If tile > 0 Then e.collisionResult = 1

    End Select
End Sub

Sub CreatePlayer
    GXEntityCreate "../overworld/img/character.png", 16, 20, 4, "player"
    Dim playerEntity As Long
    playerEntity = GX("player")

    GXEntityAnimate playerEntity, 3, 0
    GXEntityPos playerEntity, 100, 100
    GXEntityCollisionOffset playerEntity, 4, 12, 4, 0
    GXSceneFollowEntity playerEntity, GXSCENE_FOLLOW_ENTITY_CENTER

    Dim player As Long
    player = GXPlayerCreate(playerEntity)
    GXPlayerMoveKey player, GXACTION_MOVE_LEFT, GXKEY_LEFT, 2, 10
    GXPlayerMoveKey player, GXACTION_MOVE_RIGHT, GXKEY_RIGHT, 1, 10
    GXPlayerMoveKey player, GXACTION_MOVE_UP, GXKEY_UP, 4, 10
    GXPlayerMoveKey player, GXACTION_MOVE_DOWN, GXKEY_DOWN, 3, 10
End Sub

Sub TestToggleDebug
    ' Toggle debug mode when F1 key is pressed
    If GXKeyDown(GXKEY_F1) Then toggleDebug = GX_TRUE
    If Not GXKeyDown(GXKEY_F1) And toggleDebug Then
        GXDebug Not GXDebug
        GXMapLayerVisible 5, GXDebug
        toggleDebug = GX_FALSE
    End If
End Sub


'$Include: '../../gx/gx.bm'

