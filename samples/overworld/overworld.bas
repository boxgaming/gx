Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'

GXSceneCreate 500, 282
GXMapLoad "map/overworld.map"
GXFullScreen GX_TRUE

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


Dim bob As Integer
bob = GXEntityCreate("img/character.png", 16, 20, 4)
GXEntityPos bob, GXSceneWidth / 2 - 8, GXSceneHeight / 2 - 10
GXEntityCollisionOffset bob, 3, 10, 3, 0

Dim player As Integer
player = GXPlayerCreate(bob)
GXPlayerMoveSpeed player, 90
MapPlayerMoveAction player, GXACTION_MOVE_LEFT, GXKEY_A, 2, 10
MapPlayerMoveAction player, GXACTION_MOVE_RIGHT, GXKEY_D, 1, 10
MapPlayerMoveAction player, GXACTION_MOVE_UP, GXKEY_W, 4, 10
MapPlayerMoveAction player, GXACTION_MOVE_DOWN, GXKEY_S, 3, 10

GXSceneFollowEntity bob, GXSCENE_FOLLOW_ENTITY_CENTER
GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP


Dim Shared movetilecount As Integer
ReDim Shared movetiles(movetilecount) As Integer
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

        Case GXEVENT_COLLISION_TILE
            If IsMoveTile(e) <> 1 Then e.collisionResult = 1

        Case GXEVENT_COLLISION_ENTITY
            If GXEntityType(e.collisionEntity) = ETYPE_COIN Then e.collisionResult = 1

    End Select
End Sub

Sub MapPlayerMoveAction (pid As Integer, action As Integer, akey As Integer, animationSeq As Integer, animationSpeed As Integer)
    GXPlayerActionKey pid, action, akey
    GXPlayerActionAnimationSeq pid, action, animationSeq
    GXPlayerActionAnimationSpeed pid, action, animationSpeed
End Sub

Function IsMoveTile (e As GXEvent)
    Dim tile As Integer
    tile = GXMapTile(e.collisionTileX, e.collisionTileY, 1)
    IsMoveTile = 0
    Dim i As Integer
    For i = 1 To movetilecount
        If tile = movetiles(i) Then
            IsMoveTile = 1
            Exit For
        End If
    Next i
End Function

Sub SetMoveTiles
    movetilecount = 24
    ReDim movetiles(movetilecount) As Integer
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
