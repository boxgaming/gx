$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
Option _Explicit

Const MAX_SPEED = 100
Const ACCELERATION = 2
Const JUMP_SPEED = -200
Const BULLET = 1
Const RED = _RGB32(255, 0, 0)
Const BLUE = _RGB32(100, 255, 255)
Const LEFT = 1
Const RIGHT = 2

'GXDebug GX_TRUE
GXSceneCreate 320, 200
GXSceneScale 2
GXMapLoad "map/test.gxm"

Dim Shared player As Long
player = GXEntityCreate("img/character.png", 16, 20, 4)
GXEntityPos player, 20, 0
GXEntityCollisionOffset player, 3, 10, 3, 0
GXEntityApplyGravity player, GX_TRUE
Dim Shared playerDirection As Integer
playerDirection = RIGHT

Dim Shared platform1 As Long
platform1 = GXEntityCreate("", 100, 20, 1)
'GXEntityCollisionOffset platform1, 5, 5, 5, 5
'GXEntityCollisionOffset platform1, -5, -5, -5, -5
GXEntityPos platform1, 40, 140
Dim Shared platform2 As Long
platform2 = GXEntityCreate("", 100, 20, 1)
GXEntityPos platform2, 200, 80


Dim Shared floor As Long
floor = GXEntityCreate("", 320, 8, 1)
GXEntityPos floor, 0, 192

ReDim Shared bullets(10) As Long
Dim i As Integer
For i = 1 To 10
    bullets(i) = GXEntityCreate("img/coin.png", 16, 16, 4)
    GXEntityType bullets(i), BULLET
    GXEntityVisible bullets(i), GX_FALSE
    GXEntityCollisionOffset bullets(i), 3, 0, 3, 0
    GXEntityAnimate bullets(i), 1, 15
Next i
Dim Shared shooting As Integer
Dim Shared bidx
bidx = 1

GXSceneStart
System

'$Include: '../../gx/gx.bm'
Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event

        Case GXEVENT_UPDATE
            If GXKeyDown(GXKEY_ESC) Then GXSceneStop

            HandlePlayerControls player

            If GXKeyDown(GXKEY_LEFT) Then GXSceneMove -1, 0
            If GXKeyDown(GXKEY_RIGHT) Then GXSceneMove 1, 0
            If GXKeyDown(GXKEY_UP) Then GXSceneMove 0, -1
            If GXKeyDown(GXKEY_DOWN) Then GXSceneMove 0, 1

            If GXKeyDown(GXKEY_J) And Not shooting Then shooting = GX_TRUE: Shoot
            If Not GXKeyDown(GXKEY_J) And shooting Then shooting = GX_FALSE

            Dim i As Integer
            For i = 1 To 10
                If GXEntityVX(bullets(i)) = 0 And GXEntityVY(bullets(i)) = 0 Then
                    GXEntityVisible bullets(i), GX_FALSE
                    GXEntityPos bullets(i), -100, -100
                End If
            Next i

        Case GXEVENT_DRAWMAP
            DrawPlatform floor
            DrawPlatform platform1
            DrawPlatform platform2


        Case GXEVENT_COLLISION_ENTITY
            If e.collisionEntity = player Then 'OR GXEntityType(e.collisionEntity) = BULLET OR GXEntityType(e.entity) = BULLET THEN
                ' no collision
            ElseIf (e.entity = player Or GXEntityType(e.entity) = BULLET) And GXEntityType(e.collisionEntity) = BULLET Then
                ' no collision
            Else
                e.collisionResult = GX_TRUE
            End If

        Case GXEVENT_COLLISION_TILE
            Dim t As Integer
            t = GXMapTile(e.collisionTileX, e.collisionTileY, 1)
            If t > 0 Then e.collisionResult = GX_TRUE

        Case GXEVENT_DRAWSCREEN
            GXDrawText GXFONT_DEFAULT, 1, 1, "Move: WSAD" + GX_CRLF + "Jump: K" + GX_CRLF + "Fire: J"

    End Select
End Sub

Sub DrawPlayer (eid As Long, c As Long)
    If __gx_entities(eid).hidden Then Exit Sub
    Line (GXEntityX(eid) - GXSceneX, GXEntityY(eid) - GXSceneY)-(GXEntityX(eid) + GXEntityWidth(eid) - 1 - GXSceneX, GXEntityY(eid) + GXEntityHeight(eid) - 1 - GXSceneY), c, BF '_RGB32(255, 0, 0), BF
End Sub

Sub DrawPlatform (eid As Long)
    Line (GXEntityX(eid) - GXSceneX, GXEntityY(eid) - GXSceneY)-(GXEntityX(eid) + GXEntityWidth(eid) - 1 - GXSceneX, GXEntityY(eid) + GXEntityHeight(eid) - 1 - GXSceneY), _RGB32(255, 255, 255), B
End Sub


Sub Shoot
    Dim vx As Integer
    Dim x As Integer
    If playerDirection = RIGHT Then
        x = GXEntityX(player) + GXEntityWidth(player) - 8
        vx = 300
    Else
        x = GXEntityX(player) - GXEntityWidth(bullets(bidx)) + 8
        vx = -300
    End If
    GXEntityType bullets(bidx), BULLET
    GXEntityPos bullets(bidx), x, GXEntityY(player)
    GXEntityVY bullets(bidx), -10
    GXEntityVX bullets(bidx), vx
    GXEntityVisible bullets(bidx), GX_TRUE
    GXEntityApplyGravity bullets(bidx), GX_TRUE
    bidx = bidx + 1
    If bidx > 10 Then bidx = 1
End Sub

Sub HandlePlayerControls (eid As Long)
    If GXEntityApplyGravity(eid) Then
        If GXKeyDown(GXKEY_K) And GXEntityVY(eid) = 0 Then GXEntityVY eid, JUMP_SPEED
    End If

    Dim speed As Double
    If GXKeyDown(GXKEY_D) Then
        speed = GXEntityVX(eid) + ACCELERATION
        If GXEntityVX(eid) < 0 Then speed = speed + ACCELERATION
        If speed > MAX_SPEED Then speed = MAX_SPEED
        GXEntityVX eid, speed
        GXEntityAnimate eid, 1, 10
        playerDirection = RIGHT
    ElseIf GXKeyDown(GXKEY_A) Then
        speed = GXEntityVX(eid) - ACCELERATION
        If speed < -MAX_SPEED Then speed = -MAX_SPEED
        GXEntityVX eid, speed
        GXEntityAnimate eid, 2, 10
        playerDirection = LEFT
    Else
        If GXEntityVX(eid) > 0 Then
            speed = GXEntityVX(eid) - ACCELERATION
            If GXEntityVX(eid) > 0 Then speed = speed - ACCELERATION
            If speed < 0 Then speed = 0
        Else
            speed = GXEntityVX(eid) + ACCELERATION
            If speed > 0 Then speed = 0
        End If
        GXEntityVX eid, speed
    End If
    If Not GXEntityApplyGravity(eid) Then
        If GXKeyDown(GXKEY_S) Then
            speed = GXEntityVY(eid) + 1
            If speed > MAX_SPEED Then speed = MAX_SPEED
            GXEntityVY eid, speed
        ElseIf GXKeyDown(GXKEY_W) Then
            speed = GXEntityVY(eid) - 1
            If speed < -MAX_SPEED Then speed = -MAX_SPEED
            GXEntityVY eid, speed
        Else
            If GXEntityVY(eid) > 0 Then
                speed = GXEntityVY(eid) - 2
                If speed < 0 Then speed = 0
            Else
                speed = GXEntityVY(eid) + 2
                If speed > 0 Then speed = 0
            End If
            GXEntityVY eid, speed
        End If
    End If

    If GXEntityVX(eid) = 0 Or GXEntityVY(eid) <> 0 Then
        GXEntityAnimateStop eid
    End If

End Sub


