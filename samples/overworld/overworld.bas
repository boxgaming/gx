Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
Const RIGHT = 1
Const LEFT = 2
Const DOWN = 3
Const UP = 4
Const SPEED = 60

GXSceneCreate 500, 282
GXSceneScale 2
GXMapLoad "map/overworld.gxm"

Dim flag As Integer
flag = GXEntityCreate("img/flag.png", 32, 64, 5)
GXEntityPos flag, 30, 20
GXEntityAnimate flag, 1, 10

Dim fire As Integer
fire = GXEntityCreate("img/fire.png", 16, 16, 7)
GXEntityPos fire, 267, 135
GXEntityAnimate fire, 1, 10

Const ETYPE_COIN = 1000

Dim coin As Integer
coin = GXEntityCreate("img/coin.png", 16, 16, 4)
GXEntityPos coin, 265, 70
GXEntityAnimate coin, 1, 8
GXEntityType coin, ETYPE_COIN
GXEntityCollisionOffset coin, 4, 5, 4, 3

Dim Shared player As Integer
player = GXEntityCreate("img/character.png", 16, 20, 4)
GXEntityPos player, GXSceneWidth / 2 - 8, GXSceneHeight / 2 - 10
GXEntityCollisionOffset player, 3, 10, 3, 0

GXSceneFollowEntity player, GXSCENE_FOLLOW_ENTITY_CENTER
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP

Dim Shared movetiles(24) As Integer
SetMoveTiles

GXSceneStart
System 0

Dim Shared toggleDebug As Integer

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event

        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop

            ' Toggle debug mode when F1 key is pressed
            If GXKeyDown(GXKEY_F1) Then toggleDebug = GX_TRUE
            If Not GXKeyDown(GXKEY_F1) And toggleDebug Then
                GXDebug Not GXDebug
                toggleDebug = GX_FALSE
            End If

            HandlePlayerControls

        Case GXEVENT_COLLISION_TILE
            If IsMoveTile(e) <> 1 Then e.collisionResult = 1

        Case GXEVENT_COLLISION_ENTITY
            If GXEntityType(e.collisionEntity) = ETYPE_COIN Then e.collisionResult = 1

    End Select
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

Function IsMoveTile (e As GXEvent)
    Dim tile As Integer
    tile = GXMapTile(e.collisionTileX, e.collisionTileY, 1)
    IsMoveTile = 0
    Dim i As Integer
    For i = 1 To UBound(movetiles)
        If tile = movetiles(i) Then
            IsMoveTile = 1
            Exit For
        End If
    Next i
End Function

Sub SetMoveTiles
    movetiles(1) = 1
    movetiles(2) = 445
    movetiles(3) = 446
    movetiles(4) = 447
    movetiles(5) = 361
    movetiles(6) = 690
    movetiles(7) = 683
    movetiles(8) = 283
    movetiles(9) = 291
    movetiles(10) = 290
    movetiles(11) = 285
    movetiles(12) = 691
    movetiles(13) = 405
    movetiles(14) = 329
    movetiles(16) = 691
    movetiles(17) = 362
    movetiles(18) = 289
    movetiles(19) = 402
    movetiles(20) = 441
    movetiles(21) = 442
    movetiles(22) = 407
    movetiles(23) = 406
    movetiles(24) = 366
End Sub


'$Include:'../../gx/gx.bm'
