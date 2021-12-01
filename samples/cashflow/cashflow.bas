Option _Explicit
'$INCLUDE: '../../gx/gx.bi'
Const MAX_SPEED = 175 ' This is the max player speed
Const ACCELERATION = 3 ' Player acceleration
Const JUMP_SPEED = -200
Const BULLET = 1
Const WORKER = 2
Const HEALTHBAR = 3
Const LEFT = 1
Const RIGHT = 2
Const RIGHT_IDLE = 1
Const LEFT_IDLE = 2
Const RIGHT_RUN = 3
Const LEFT_RUN = 4
Const RIGHT_JUMP = 5
Const LEFT_JUMP = 6
Const RIGHT_FALL = 7
Const LEFT_FALL = 8
Const COLLISION_LAYER = 3
Const MAX_MONEY = 30


Type Worker
    id As Long
    healthBar As Long
    moneyBar As Long
    points As Integer
    contentment As Integer
    money As Integer
End Type

Dim Shared debugMode As Integer
Dim Shared player As Long
Dim Shared playerDirection As Integer: playerDirection = RIGHT
ReDim Shared bullets(10) As Long
ReDim Shared workers(3) As Worker
Dim Shared shooting As Integer
Dim Shared bidx: bidx = 1

_Title "Cashflow!"

GXHardwareAcceleration GX_TRUE
GXFrameRate 60
GXSceneCreate 512, 288
GXSceneScale 2
'GXFullScreen GX_TRUE
GXSceneStart
System

'$INCLUDE: '../../gx/gx.bm'
Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_INIT: OnInit
        Case GXEVENT_UPDATE: OnUpdate
            'Case GXEVENT_DRAWSCREEN: OnDrawScreen
        Case GXEVENT_COLLISION_ENTITY: OnTestCollisionEntity e
        Case GXEVENT_COLLISION_TILE: OnTestCollisionTile e
    End Select
End Sub

Sub OnInit
    ' Initialize the background
    Dim bgid As Integer: bgid = GXBackgroundAdd("img/bg.png", GXBG_STRETCH)
    GXMapLoad "./map/factory.gxm"
    GXMapLayerVisible COLLISION_LAYER, GX_FALSE

    ' initialize the workers
    Dim i As Integer
    For i = 1 To UBound(workers)
        workers(i).id = GXEntityCreate("img/worker.png", 32, 32, 1)
        GXEntityType workers(i).id, WORKER
        GXEntityCollisionOffset workers(i).id, 10, 5, 10, 0
        GXEntityApplyGravity workers(i).id, GX_TRUE
        workers(i).healthBar = GXEntityCreate("img/content-bar.png", 32, 3, 1)
        GXEntityType workers(i).healthBar, HEALTHBAR
        workers(i).moneyBar = GXEntityCreate("img/money-bar.png", 32, 3, 1)
        GXEntityType workers(i).moneyBar, HEALTHBAR
    Next i
    GXEntityPos workers(1).id, 300, 150
    GXEntityPos workers(2).id, 670, 150
    GXEntityPos workers(3).id, 755, 150

    ' initialize the coin bullets
    For i = 1 To 10
        bullets(i) = GXEntityCreate("../overworld/img/coin.png", 16, 16, 4)
        GXEntityType bullets(i), BULLET
        GXEntityHide bullets(i)
        GXEntityCollisionOffset bullets(i), 3, 0, 3, 0
        GXEntityAnimate bullets(i), 1, 15
    Next i

    ' Initialize the player entity
    player = GXEntityCreate("img/owner.png", 32, 32, 8)
    GXEntityPos player, 20, 0
    GXEntityCollisionOffset player, 10, 5, 10, 0
    GXEntityApplyGravity player, GX_TRUE
    GXSceneFollowEntity player, GXSCENE_FOLLOW_ENTITY_CENTER
    GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP
End Sub

Sub OnUpdate
    If GXKeyDown(GXKEY_ESC) Then GXSceneStop
    If GXKeyDown(GXKEY_F1) Then
        debugMode = Not debugMode
        GXDebug debugMode
    End If

    HandlePlayerControls player

    If GXKeyDown(GXKEY_J) And Not shooting Then
        shooting = GX_TRUE:
        Shoot
    End If
    If Not GXKeyDown(GXKEY_J) And shooting Then shooting = GX_FALSE

    Dim i As Integer
    For i = 1 To 10
        If GXEntityVX(bullets(i)) = 0 And GXEntityVY(bullets(i)) = 0 Then
            GXEntityHide bullets(i)
            GXEntityPos bullets(i), -100, -100
        End If
    Next i

    UpdateWorkers
End Sub

Sub OnDrawScreen
    ShowPoints
End Sub

Sub OnTestCollisionEntity (e As GXEvent)
    If e.collisionEntity = player Or GXEntityType(e.collisionEntity) = HEALTHBAR Then
        ' no collision
    ElseIf e.entity = player And GXEntityType(e.collisionEntity) = WORKER Then
        ' no collision
    ElseIf (e.entity = player Or GXEntityType(e.entity) = BULLET) And GXEntityType(e.collisionEntity) = BULLET Then
        ' no collision
    Else
        e.collisionResult = GX_TRUE
    End If

    If GXEntityType(e.entity) = BULLET And GXEntityType(e.collisionEntity) = WORKER Then
        Dim i As Integer
        i = WorkerIndex(e.collisionEntity)
        workers(i).points = workers(i).points + 1
        GXEntityVX e.entity, 0
        GXEntityVY e.entity, 0
        GXEntityHide e.entity
    End If
End Sub

Sub OnTestCollisionTile (e As GXEvent)
    Dim t As Integer
    t = GXMapTile(e.collisionTileX, e.collisionTileY, COLLISION_LAYER)
    If t > 0 Then e.collisionResult = GX_TRUE
    If t = 16 Then GXEntityMove e.entity, 1, 0
End Sub

Sub Shoot
    Dim vx As Integer
    Dim x As Integer
    If playerDirection = RIGHT Then
        x = GXEntityX(player) + GXEntityWidth(player) - 8
        vx = 200
    Else
        x = GXEntityX(player) - GXEntityWidth(bullets(bidx)) + 8
        vx = -200
    End If
    GXEntityType bullets(bidx), BULLET
    GXEntityPos bullets(bidx), x, GXEntityY(player)
    GXEntityVY bullets(bidx), -50
    GXEntityVX bullets(bidx), vx
    GXEntityShow bullets(bidx)
    GXEntityApplyGravity bullets(bidx), GX_TRUE
    bidx = bidx + 1
    If bidx > 10 Then bidx = 1
End Sub

Sub UpdateWorkers
    Dim i As Integer
    For i = 1 To UBound(workers)
        GXEntityPos workers(i).healthBar, GXEntityX(workers(i).id), GXEntityY(workers(i).id) - 10
        'GXEntityVX workers(i).healthBar, GXEntityVX(workers(i).id)
        'GXEntityVY workers(i).healthBar, GXEntityVY(workers(i).id)
        GXEntityAnimate workers(i).healthBar, 15, 0
        GXEntityPos workers(i).moneyBar, GXEntityX(workers(i).id), GXEntityY(workers(i).id) - 5
        'GXEntityVX workers(i).moneyBar, GXEntityVX(workers(i).id)
        'GXEntityVY workers(i).moneyBar, GXEntityVY(workers(i).id)

        If GXFrameRate Mod GXFrame = 1 Then workers(i).points = workers(i).points - 1
        If workers(i).points < 0 Then workers(i).points = 0

        Dim money As Integer
        money = workers(i).points + 1
        If money > 31 Then money = 31
        GXEntityAnimate workers(i).moneyBar, money, 0
    Next i
End Sub

Sub ShowPoints
    Dim i As Integer
    For i = 1 To UBound(workers)
        GXDrawText GXFONT_DEFAULT, GXEntityX(workers(i).id) + 5 - GXSceneX, GXEntityY(workers(i).id) - GXSceneY - 10, Str$(workers(i).points)
    Next i
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
        GXEntityAnimate eid, RIGHT_RUN, 15
        playerDirection = RIGHT
    ElseIf GXKeyDown(GXKEY_A) Then
        speed = GXEntityVX(eid) - ACCELERATION
        If GXEntityVX(eid) > 0 Then speed = speed - ACCELERATION
        If speed < -MAX_SPEED Then speed = -MAX_SPEED
        GXEntityVX eid, speed
        GXEntityAnimate eid, LEFT_RUN, 15
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

    If GXEntityVY(eid) < 0 Then
        If playerDirection = LEFT Then
            GXEntityAnimate eid, LEFT_JUMP, 15
        Else
            GXEntityAnimate eid, RIGHT_JUMP, 15
        End If
    ElseIf GXEntityVY(eid) > 0 Then
        If playerDirection = LEFT Then
            GXEntityAnimate eid, LEFT_FALL, 15
        Else
            GXEntityAnimate eid, RIGHT_FALL, 15
        End If
    Else
        If GXEntityVX(eid) = 0 Or GXEntityVY(eid) <> 0 Then
            If playerDirection = LEFT Then
                GXEntityAnimate eid, LEFT_IDLE, 15
            Else
                GXEntityAnimate eid, RIGHT_IDLE, 15
            End If
        End If
    End If
End Sub

Function WorkerIndex (id As Long)
    Dim i As Integer
    For i = 1 To UBound(workers)
        If workers(i).id = id Then
            WorkerIndex = i
            Exit Function
        End If
    Next i
    WorkerIndex = -1
End Function

Function TestFunc (arg1 As Integer, arg2 As String, arg3%)
    ' Do stuff
End Function

