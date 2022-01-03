Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include: '../../gx/gx.bi'
Const MAX_SPEED = 175 ' This is the max player speed
Const ACCELERATION = 3 ' Player acceleration
Const JUMP_SPEED = -200
Const BULLET = 1
Const NPC = 2
Const HEALTHBAR = 3
Const LEFT = 1
Const RIGHT = 2
Const FIRE = 3
Const JUMP = 4
Const RIGHT_IDLE = 1
Const LEFT_IDLE = 2
Const RIGHT_RUN = 3
Const LEFT_RUN = 4
Const RIGHT_JUMP = 5
Const LEFT_JUMP = 6
Const RIGHT_FALL = 7
Const LEFT_FALL = 8
Const COLLISION_LAYER = 3
Const MAX_TIME = 120

Type NPC
    id As Integer
    healthBar As Integer
    points As Integer
End Type

Dim Shared controlMode As Integer
Dim Shared cpress As Integer
Dim Shared player As Integer
Dim Shared playerDirection As Integer: playerDirection = RIGHT
Dim Shared bullets(30) As Long
Dim Shared npcs(16) As NPC
Dim Shared sleigh As Integer
Dim Shared shooting As Integer
Dim Shared bidx: bidx = 1
Dim Shared sndJump As Long
Dim Shared sndToss As Long
Dim Shared sndIntro As Long
Dim Shared sndSuccess As Long
Dim Shared sndWin As Long
Dim Shared sndLose As Long
Dim Shared sndBG As Long
Dim Shared timeRemaining As Integer
Dim Shared kidsComplete As Integer
Dim Shared gameFont As Integer
Dim Shared started As Integer
Dim Shared gameOver As Integer
Dim Shared startFrame As _Unsigned Long
Dim Shared fpress As Integer
Dim Shared controls(4) As GXDeviceInput

_Title "Sleighless!"

GXHardwareAcceleration GX_TRUE
GXFrameRate 60
GXSceneCreate 512, 288
GXSceneScale 2
Init
GXSceneStart
System

Sub GXOnGameEvent (e As GXEvent)
    Select Case e.event
        Case GXEVENT_UPDATE: OnUpdate
        Case GXEVENT_DRAWSCREEN: OnDrawScreen
        Case GXEVENT_COLLISION_ENTITY: OnTestCollisionEntity e
        Case GXEVENT_COLLISION_TILE: OnTestCollisionTile e
    End Select
End Sub

Sub Init
    ' Initialize the background
    Dim bgid As Integer: bgid = GXBackgroundAdd("img/bg.png", GXBG_SCROLL)
    GXMapLoad "map/level1.gxm"
    GXMapLayerVisible COLLISION_LAYER, GX_FALSE

    ' Initialize the non-player characters
    Dim i As Integer
    For i = 1 To UBound(npcs)
        npcs(i).healthBar = GXEntityCreate("img/health-bar.png", 48, 32, 5)
        GXEntityType npcs(i).healthBar, HEALTHBAR
        GXEntityAnimateMode npcs(i).healthBar, GXANIMATE_SINGLE

        npcs(i).id = GXEntityCreate("img/kids.png", 20, 32, 6)
        GXEntityType npcs(i).id, NPC
        GXEntityCollisionOffset npcs(i).id, 4, 12, 5, 0
        GXEntityAnimate npcs(i).id, 2, 8
    Next i
    GXEntityPos npcs(1).id, 775, 1504
    GXEntityPos npcs(2).id, 980, 1504
    GXEntityPos npcs(3).id, 1540, 896
    GXEntityPos npcs(4).id, 850, 1248
    GXEntityPos npcs(5).id, 1357, 1504
    GXEntityPos npcs(6).id, 1640, 1440
    GXEntityPos npcs(7).id, 1790, 1376
    GXEntityPos npcs(8).id, 2290, 1472
    GXEntityPos npcs(9).id, 2322, 1472
    GXEntityPos npcs(10).id, 2650, 1280
    GXEntityPos npcs(11).id, 2460, 960
    GXEntityPos npcs(12).id, 3045, 1152
    GXEntityPos npcs(13).id, 2275, 832
    GXEntityPos npcs(14).id, 2200, 960
    GXEntityPos npcs(15).id, 1345, 992
    GXEntityPos npcs(16).id, 1990, 768
    For i = 1 To UBound(npcs)
        GXEntityPos npcs(i).healthBar, GXEntityX(npcs(i).id) - 14, GXEntityY(npcs(i).id)
    Next i

    ' Initialize the sleigh
    sleigh = GXEntityCreate("img/sleigh.png", 48, 20, 8)
    GXEntityPos sleigh, 90, 1110

    ' Initialize the player entity
    player = GXEntityCreate("img/santa.png", 24, 24, 6)
    GXEntityPos player, 64, 1150
    GXEntityCollisionOffset player, 4, 3, 4, 2
    GXEntityFrameSet player, RIGHT_FALL, 1
    GXSceneFollowEntity player, GXSCENE_FOLLOW_ENTITY_CENTER
    GXSceneConstrain GXSCENE_CONSTRAIN_TO_MAP

    ' Initialize the "bullets"
    For i = 1 To UBound(bullets)
        If i Mod 8 = 0 Then
            bullets(i) = GXEntityCreate("img/tree.png", 16, 19, 4)
            GXEntityType bullets(i), BULLET
            GXEntityVisible bullets(i), GX_FALSE
            GXEntityCollisionOffset bullets(i), 3, 0, 3, 0
            GXEntityAnimate bullets(i), 1, 15
        Else
            bullets(i) = GXEntityCreate("img/presents.png", 16, 16, 1)
            GXEntityType bullets(i), BULLET
            GXEntityVisible bullets(i), GX_FALSE
            GXEntityCollisionOffset bullets(i), 3, 3, 3, 0
            GXEntityAnimate bullets(i), 1, 15
            GXEntityFrameSet bullets(i), (i - 1) Mod 6 + 1, 1
        End If
    Next i

    ' Load the game sounds
    sndJump = GXSoundLoad("snd/jump.mp3")
    sndToss = GXSoundLoad("snd/toss.mp3")
    sndBG = GXSoundLoad("snd/main.mp3")
    sndIntro = GXSoundLoad("snd/intro.mp3")
    sndSuccess = GXSoundLoad("snd/success.mp3")
    sndWin = GXSoundLoad("snd/win.mp3")
    sndLose = GXSoundLoad("snd/lose.mp3")

    ' Initialize the game font
    gameFont = GXFontCreate("img/font.png", 8, 9, "0123456789ABCDEF" + GX_CRLF + _
                                                  "GHIJKLMNOPQRSTUV" + GX_CRLF + _
                                                  "WXYZc>-x'!/")
    GXFontLineSpacing gameFont, 2

    timeRemaining = MAX_TIME
    GXSoundPlay sndIntro
    InitControls
End Sub

Sub InitControls
    ' Initialize the default key controls
    GXKeyInput GXKEY_A, controls(LEFT)
    GXKeyInput GXKEY_D, controls(RIGHT)
    GXKeyInput GXKEY_J, controls(FIRE)
    GXKeyInput GXKEY_K, controls(JUMP)

    ' Attempt to load a saved control configuration
    ControlConfigLoad
End Sub

Sub ControlConfigSave
    Open "control.cfg" For Binary As #1
    Dim i As Integer
    Put #1, , controls(LEFT)
    Put #1, , controls(RIGHT)
    Put #1, , controls(FIRE)
    Put #1, , controls(JUMP)
    Close #1
End Sub

Sub ControlConfigLoad
    If _FileExists("control.cfg") Then
        Open "control.cfg" For Binary As #1
        Get #1, , controls(LEFT)
        Get #1, , controls(RIGHT)
        Get #1, , controls(FIRE)
        Get #1, , controls(JUMP)
        Close #1
    End If
End Sub


Sub OnUpdate
    ' If the user presses Esc, exit the game
    If GXKeyDown(GXKEY_ESC) Then GXSceneStop

    ' If control config mode is enabled, detect the current control input
    If controlMode > 0 Then
        DetectControlInput
        Exit Sub
    End If

    ' If F key is pressed, toggle full screen mode
    If GXKeyDown(GXKEY_F) Then
        fpress = GX_TRUE
    ElseIf fpress Then
        GXFullScreen Not GXFullScreen
        fpress = GX_FALSE
    End If

    ' If C key is pressed, enter the config control input mode
    If Not started And GXKeyDown(GXKEY_C) Then
        cpress = GX_TRUE
    ElseIf cpress Then
        cpress = GX_FALSE
        controlMode = LEFT
        Exit Sub
    End If

    ' If the Enter key is pressed, start the game
    If Not started Then
        If GXKeyDown(GXKEY_ENTER) Then StartGame
        Exit Sub
    End If

    ' If we are in the game over state exit here and do not process any more game events
    If gameOver Then Exit Sub

    ' Handle the play input controls
    HandlePlayerControls player

    ' If the user has pressed the input mapped to the FIRE action, shoot a projectile
    If GXDeviceInputTest(controls(FIRE)) And Not shooting Then
        shooting = GX_TRUE:
        Shoot
    End If
    If Not GXDeviceInputTest(controls(FIRE)) And shooting Then shooting = GX_FALSE

    ' If the projectile has stopped moving, remove it from view
    Dim i As Integer
    For i = 1 To UBound(bullets)
        If GXEntityVX(bullets(i)) = 0 And GXEntityVY(bullets(i)) = 0 Then
            GXEntityVisible bullets(i), GX_FALSE
            GXEntityPos bullets(i), -100, -100
        End If
    Next i

    ' Calculate the number of seconds remaining in the game
    timeRemaining = _Round(MAX_TIME - ((GXFrame - startFrame) / GXFrameRate))
End Sub

Sub DetectControlInput
    ' Wait for the next device input
    GXDeviceInputDetect controls(controlMode)
    ' Give the user a brief pause so we don't catch repeated input
    GXSleep .25
    ' Advance to the next control to detect
    controlMode = controlMode + 1
    ' If we have finished mapping the last control, take us out of control config mode
    ' and save the current configuration
    If controlMode > JUMP Then
        controlMode = 0
        ControlConfigSave
    End If
End Sub

Sub StartGame
    GXSoundRepeat sndBG
    GXEntityApplyGravity player, GX_TRUE
    GXEntityVY player, 100
    GXEntityVX sleigh, 300
    GXEntityAnimate sleigh, 1, 10
    startFrame = GXFrame
    started = GX_TRUE
End Sub

Sub StopGame (win As Integer)
    GXSoundStop sndBG
    If win Then
        GXSoundPlay sndWin
    Else
        GXSoundPlay sndLose
    End If
    GXEntityVX player, 0
    GXEntityVY player, 0
    GXEntityApplyGravity player, GX_FALSE
    GXEntityAnimateStop player

    ' freeze all of the bullets
    Dim i As Integer
    For i = 1 To UBound(bullets)
        GXEntityApplyGravity bullets(i), GX_FALSE
        GXEntityVX bullets(i), 0
        GXEntityVY bullets(i), 0
    Next i
    gameOver = GX_TRUE
End Sub

Sub OnDrawScreen
    ' Display the HUD
    GXDrawText gameFont, 180, 8, "TIME " + GX_CRLF + " " + GXSTR_LPad(_Trim$(Str$(timeRemaining)), "0", 3)
    GXDrawText gameFont, 235, 8, "KIDS " + GX_CRLF + _
                                 _Trim$(Str$(kidsComplete)) + "/" + _
                                 _Trim$(Str$(ubound(npcs)))
    GXDrawText gameFont, 285, 8, "LEVEL" + GX_CRLF + " 1-1"

    ' Display the intro / menu
    If Not started Then
        GXDrawText gameFont, 75, 55, _
           "OH NO SANTA! YOU HAVE FALLEN FROM THE SLEIGH!" + GX_CRLF + _
           " IT'S UP TO YOU ALONE NOW TO SAVE CHRISTMAS!"

        GXDrawtext gameFont, 75, 135, _
           "         LEFT  -  " + FormatInput(LEFT) + "   RIGHT -  " + FormatInput(RIGHT) + GX_CRLF + GX_CRLF + _
           "         SHOOT -  " + FormatInput(FIRE) + "   JUMP  -  " + FormatInput(JUMP) + GX_CRLF + GX_CRLF + _
           "             FULLSCREEN  -  F" + GX_CRLF + GX_CRLF + _
           "             QUIT        -  ESC" + GX_CRLF + GX_CRLF + GX_CRLF + GX_CRLF + _
           "            PRESS ENTER TO PLAY!"
        ' "           CHANGE CONTROLS  -  C" + GX_CRLF + GX_CRLF + _

        ' Draw the control selector if in selection mode
        If controlMode > 0 Then
            Dim istring As String
            Dim ix As Integer
            Dim iy As Integer
            If controlMode = LEFT Then
                istring = "Press Left"
                ix = 190
                iy = 125
            ElseIf controlMode = RIGHT Then
                istring = "Press Right"
                ix = 327
                iy = 125
            ElseIf controlMode = FIRE Then
                istring = "Press Fire"
                ix = 190
                iy = 146
            ElseIf controlMode = JUMP Then
                istring = "Press Jump"
                ix = 327
                iy = 146
            End If
            GXDrawText GXFONT_DEFAULT_BLACK, ix + 1, iy + 1, istring
            GXDrawText GXFONT_DEFAULT, ix, iy, istring
        End If
    End If

    ' Display the game end state
    If started And kidsComplete = UBound(npcs) Then
        GXDrawText gameFont, 195, 110, "YOU SAVED CHRISTMAS!"
        If Not gameOver Then StopGame GX_TRUE
    End If

    If GXEntityY(player) > 1600 Then
        GXDrawText gameFont, 195, 110, "  GAME OVER" + GX_CRLF + "SANTA IS DEAD"
        If Not gameOver Then StopGame GX_FALSE
    End If

    If timeRemaining = 0 Then
        GXDrawText gameFont, 195, 110, "     TIME'S UP!" + GX_CRLF + "CHRISTMAS IS RUINED"
        If Not gameOver Then StopGame GX_FALSE
    End If
End Sub

' Format the selected device input for display
Function FormatInput$ (cid As Integer)
    Dim cstr As String
    If controls(cid).deviceType = GXDEVICE_KEYBOARD Then
        cstr = GXKeyButtonName(controls(cid).inputId)
    ElseIf controls(cid).deviceType = GXDEVICE_MOUSE Then
        If controls(cid).inputType = GXDEVICE_BUTTON Then
            cstr = "MB:" + _Trim$(Str$(controls(cid).inputId))
        End If
    ElseIf controls(cid).deviceType = GXDEVICE_CONTROLLER Then
        If controls(cid).inputType = GXDEVICE_AXIS Then
            cstr = "A" + _Trim$(Str$(controls(cid).inputId)) + ":" + _Trim$(Str$(controls(cid).inputValue))
        ElseIf controls(cid).inputType = GXDEVICE_BUTTON Then
            cstr = "B:" + _Trim$(Str$(controls(cid).inputId))
        End If
    End If

    FormatInput = GXSTR_RPad(UCase$(Left$(cstr, 5)), " ", 5)
End Function

' Detect collisions when one entities position intersects with another
Sub OnTestCollisionEntity (e As GXEvent)
    If e.collisionEntity = player Or GXEntityType(e.collisionEntity) = HEALTHBAR Then
        ' no collision
    ElseIf e.entity = player And GXEntityType(e.collisionEntity) = NPC Then
        ' no collision
    ElseIf (e.entity = player Or GXEntityType(e.entity) = BULLET) And GXEntityType(e.collisionEntity) = BULLET Then
        ' no collision
    Else
        e.collisionResult = GX_TRUE
    End If

    If GXEntityType(e.entity) = BULLET And GXEntityType(e.collisionEntity) = NPC Then
        ' Determine which NPC was hit
        Dim i As Integer
        i = NPCIndex(e.collisionEntity)
        ' If this NPC already has the max points (presents), then do not register a collision
        If npcs(i).points = 10 Then
            e.collisionResult = GX_FALSE
        Else
            ' Otherwise, increment the points for the NPC and update the health bar (present stack)
            npcs(i).points = npcs(i).points + 1
            GXEntityVX e.entity, 0
            GXEntityVY e.entity, 0
            GXEntityVisible e.entity, GX_FALSE
            If (npcs(i).points) Mod 2 = 0 Then
                GXEntityFrameNext npcs(i).healthBar
            End If
            ' If this is the last point needed for the NPC, update the game status
            ' and play the success sound and animation
            If npcs(i).points = 10 Then
                kidsComplete = kidsComplete + 1
                GXEntityAnimate npcs(i).id, 1, 5
                GXSoundPlay sndSuccess
            End If
        End If
    End If
End Sub

' Determine whether a collision has occured when an entity's position intersects with a map tile
Sub OnTestCollisionTile (e As GXEvent)
    ' Rudolph is gone and he is not stopping for anything
    If e.entity = sleigh Then Exit Sub

    ' If there is a tile present in our collision layer, register a collision
    Dim t As Integer
    t = GXMapTile(e.collisionTileX, e.collisionTileY, COLLISION_LAYER)
    If t > 0 Then e.collisionResult = GX_TRUE
End Sub

' Shoot the next available projectile entitiy
Sub Shoot
    Dim vx As Integer
    Dim x As Integer
    If playerDirection = RIGHT Then
        x = GXEntityX(player) + GXEntityWidth(player) - 12
        vx = 100
    Else
        x = GXEntityX(player) - GXEntityWidth(bullets(bidx)) + 12
        vx = -100
    End If
    GXEntityType bullets(bidx), BULLET
    GXEntityPos bullets(bidx), x, GXEntityY(player)
    GXEntityVY bullets(bidx), -100
    GXEntityVX bullets(bidx), vx
    GXEntityVisible bullets(bidx), GX_TRUE
    GXEntityApplyGravity bullets(bidx), GX_TRUE
    bidx = bidx + 1
    If bidx > UBound(bullets) Then bidx = 1
    GXSoundPlay sndToss
End Sub

' Handle player movement controls
Sub HandlePlayerControls (eid As Long)
    If GXEntityApplyGravity(eid) Then
        If GXDeviceInputTest(controls(JUMP)) And GXEntityVY(eid) = 0 Then
            GXEntityVY eid, JUMP_SPEED
            GXSoundPlay sndJump
        End If
    End If

    Dim speed As Double
    If GXDeviceInputTest(controls(RIGHT)) Then
        speed = GXEntityVX(eid) + ACCELERATION
        If GXEntityVX(eid) < 0 Then speed = speed + ACCELERATION
        If speed > MAX_SPEED Then speed = MAX_SPEED
        GXEntityVX eid, speed
        GXEntityAnimate eid, RIGHT_RUN, 15
        playerDirection = RIGHT

    ElseIf GXDeviceInputTest(controls(LEFT)) Then
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

Function NPCIndex (id As Long)
    Dim i As Integer
    For i = 1 To UBound(npcs)
        If npcs(i).id = id Then
            NPCIndex = i
            Exit Function
        End If
    Next i
    NPCIndex = -1
End Function

'$Include: '../../gx/gx.bm'

