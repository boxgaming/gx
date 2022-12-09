Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include: '..\..\gx\gx.bi'
_Title "Enemy Space"

Const False = 0, True = Not False
Const THEPLAYER = 1
Const ENEMY = 2
Const BULLET = 3
Const EBULLET = 4
Const WAYPOINT = 5
Const WORMHOLE = 6
Const PZONE = 7
Const TRANSPORT = 8
Const POWERUP = 9
Const EXPLOSION = 10
Const SHIELDS_MAX = 30

Type Position
    x As Double
    y As Double
End Type

Type Ship
    id As Long
    mode As Integer
    firing As Integer
    transporting As Integer
    position As Integer
    frame As Integer
    turningRight As Integer
    turningLeft As Integer
    shieldsId As Long
    shieldsLevel As Integer
    shieldsHit As Integer
    dead As Integer
    home As Position
    targetId As Integer
    lastTargetId As Integer
    maxSpeed As Integer
End Type

Type Planet
    id As Long
    position As Position
    rebels As Integer
    enemies As Integer
    hideOnMap As Integer
End Type

Randomize Timer

Dim Shared accel(16) As Position

Dim Shared message As String
Dim Shared messageStart As _Unsigned Long
Dim Shared messageDuration As _Unsigned Long
Dim Shared gameOver As Integer

Dim Shared pinfo(6) As Planet
Dim Shared planet(UBound(pinfo)) As Long
Dim Shared planetDefense As Integer
Dim Shared lastPlanet As Integer
Dim Shared cwp As Integer ' Current waypoint
Dim Shared overWaypoint As Integer
Dim Shared waypoints(UBound(planet)) As Position
Dim Shared locFinder As Integer
Dim Shared ploc(UBound(planet)) As Integer
Dim Shared locPos As Integer
Dim Shared ping As Long
Dim Shared pingLoc As Long
Dim Shared bullets(10) As Long
Dim Shared powerups(5) As Long
Dim Shared ebullets(50) As Long
Dim Shared explosions(5) As Long
Dim Shared enemies(15) As Ship
Dim Shared entityMap(200) As Integer
Dim Shared activeEnemies As Integer
Dim Shared player As Ship
Dim Shared healthbar As Integer
Dim Shared title As Long
Dim Shared controls As Long
Dim Shared gameFont As Integer
Dim Shared passengers As Integer
Dim Shared timeRemaining As Integer
Dim Shared score As Integer: score = 0
Dim Shared pingDelay As Integer
Dim Shared whshrink As Long

Dim Shared sndAlarm As Long
Dim Shared sndCoin As Long
Dim Shared sndGameOver As Long
Dim Shared sndError As Long
Dim Shared sndExplode As Long
Dim Shared sndLaser(UBound(bullets)) As Long
Dim Shared sndPowerup As Long
Dim Shared sndThruster As Long
Dim Shared sndTransport As Long
Dim Shared sndMusic As Long
Dim Shared sndIntro As Long
Dim Shared sndPing As Long
Dim Shared sndVictory As Long

Dim Shared introMode As Integer


'GXDebug True
GXHardwareAcceleration GX_TRUE
GXSceneCreate 960, 600
InitGameObjects
'GXFullScreen True
GXSceneStart

Sub GXOnGameEvent (e As GXEvent)

    Select Case e.event
        Case GXEVENT_UPDATE: OnUpdate
        Case GXEVENT_COLLISION_ENTITY: OnCollision e
        Case GXEVENT_ANIMATE_COMPLETE: OnAnimateComplete e
        Case GXEVENT_DRAWSCREEN: OnDrawScreen
    End Select
End Sub

Sub OnUpdate
    If introMode Then
        If GXKeyDown(GXKEY_J) Then
            player.firing = True
            StartGame
        End If
        Exit Sub
    End If

    If gameOver Then Exit Sub

    ' Determine location position
    Dim i As Integer
    TrackEntity player.id, locPos
    For i = 1 To UBound(planet)
        If Not pinfo(i).hideOnMap Then TrackEntity planet(i), ploc(i)
    Next i

    If GXKeyDown(GXKEY_ESC) Then
        GXSceneStop
        GXSoundStop sndMusic
    End If

    HandlePlayerMovement
    HandlePlayerFire
    HandlePlayerTransport
    HandleEnemyMovement

    timeRemaining = timeRemaining - 1

    If pingDelay > 0 Then
        If GXFrame - pingDelay > 300 Then
            ShowWaypoint
        End If
    End If

    If timeRemaining = 3600 Then
        SetMessage "WORMHOLE CLOSING IN 1 MINUTE!"
        GXSoundPlay sndAlarm

    ElseIf timeRemaining = 1800 Then
        SetMessage "WORMOLE CLOSING IN 30 SECONDS"
        GXSoundPlay sndAlarm

    ElseIf timeRemaining < 1 Then
        gameOver = True
        SetMessage "OUT OF TIME - WORMHOLE IS CLOSING!"
        GXEntityVisible player.id, False
        GXEntityVisible ping, False
        GXEntityVisible whshrink, True
        GXEntityVisible planet(6), False
        GXEntityPos planet(6), -20000, -20000
        GXEntityAnimateMode whshrink, GXANIMATE_SINGLE
        GXEntityAnimate whshrink, 1, 40
        GXSoundPlay sndGameOver
    End If
End Sub

Sub OnDrawScreen
    Dim As Integer min, sec
    min = Fix(timeRemaining / 60 / 60)
    sec = Fix((timeRemaining / 60) Mod 60)
    'If sec = 60 Then sec = 59

    GXDrawText gameFont, 260, 10, "SCORE"
    GXDrawText gameFont, 425, 10, "TIME REMAINING"
    GXDrawText gameFont, 625, 10, "PASSENGERS"
    If introMode Then
        GXDrawText gameFont, 55, 465, "GAME CONTROLS"
        GXDrawText GXFONT_DEFAULT, 82, 491, "Thrusters"
        GXDrawText GXFONT_DEFAULT, 50, 565, "Turn Left"
        GXDrawText GXFONT_DEFAULT, 118, 565, "Turn Right"
        GXDrawText GXFONT_DEFAULT, 180, 520, "Fire"
        GXDrawText GXFONT_DEFAULT, 205, 565, "Transport"
        If GXFrame > 300 Then
            If GXFrame Mod 100 < 50 Then GXDrawText gameFont, 400, 400, "PRESS FIRE TO START!"
        End If
    Else
        GXDrawText gameFont, 260, 25, _Trim$(Str$(score))
        GXDrawText gameFont, 425, 25, "     " + GXSTR_LPad(_Trim$(Str$(min)), "0", 2) + ":" + GXSTR_LPad(_Trim$(Str$(sec)), "0", 2)
        GXDrawText gameFont, 625, 25, GXSTR_LPad(_Trim$(Str$(passengers)), " ", 10)
    End If

    If GXFrame - messageStart < messageDuration Then
        Dim swidth As Integer
        swidth = Len(message) * 8
        GXDrawText gameFont, GXSceneWidth / 2 - swidth / 2, 55, message
    End If

    If gameOver Then
        GXSoundStop sndMusic
        Dim msg As String
        msg = "GAME OVER"
        If gameOver = 2 Then msg = "YOU ESCAPED!"
        GXDrawText gameFont, GXSceneWidth / 2 - 32, GXSceneHeight / 2, msg
    End If
End Sub

Sub OnAnimateComplete (e As GXEvent)
    ' The only entity this would apply to at present is the explosion
    ' Once the animate is complete we will make the entity hidden
    ' which will make it available to the pool.
    GXEntityVisible e.entity, False
End Sub

Sub OnCollision (e As GXEvent)
    If Not GXEntityVisible(e.entity) Or Not GXEntityVisible(e.collisionEntity) Then Exit Sub

    Dim As Integer etype, cetype
    etype = GXEntityType(e.entity)
    cetype = GXEntityType(e.collisionEntity)

    If etype = BULLET And (cetype = ENEMY Or cetype = TRANSPORT) Then
        ' Hide the bullet
        GXEntityVisible e.entity, False
        GXEntityPos e.entity, -10000, -10000

        ' Handle collision
        Dim eidx As Integer
        eidx = entityMap(e.collisionEntity)
        If enemies(eidx).shieldsLevel < 1 Then
            If enemies(eidx).dead = False Then
                enemies(eidx).dead = GXFrame
                score = score + 10
                GXEntityVisible enemies(eidx).shieldsId, False
                GXEntityPos enemies(eidx).shieldsId, -10000, -10000
                Dim ex As Integer
                ex = NextObject(explosions(), EXPLOSION)
                If ex Then
                    GXSoundPlay sndExplode
                    GXEntityPos explosions(ex), GXEntityX(e.collisionEntity) - 110, GXEntityY(e.collisionEntity) - 110
                    GXEntityVX explosions(ex), GXEntityVX(e.collisionEntity)
                    GXEntityVY explosions(ex), GXEntityVY(e.collisionEntity)
                    GXEntityAnimateMode explosions(ex), GXANIMATE_SINGLE
                    GXEntityFrameSet explosions(ex), 1, 1
                    GXEntityAnimate explosions(ex), 1, 60
                    GXEntityVisible explosions(ex), True
                    If cetype = TRANSPORT Then
                        ex = NextObject(powerups(), POWERUP)
                        GXEntityPos powerups(ex), GXEntityX(e.collisionEntity) + 16, GXEntityY(e.collisionEntity) + 16
                        GXEntityVX powerups(ex), GXEntityVX(e.collisionEntity) * .5
                        GXEntityVY powerups(ex), GXEntityVY(e.collisionEntity) * .5
                        GXEntityVisible powerups(ex), True
                        GXSoundPlay sndCoin
                    End If
                End If
            End If
        ElseIf enemies(eidx).dead = 0 Then
            enemies(eidx).shieldsHit = GXFrame
            enemies(eidx).shieldsLevel = enemies(eidx).shieldsLevel - 1
        End If


    ElseIf etype = EBULLET And cetype = THEPLAYER Then
        ' Hide the bullet
        GXEntityVisible e.entity, False
        GXEntityPos e.entity, -10000, -10000
        player.shieldsLevel = player.shieldsLevel - 1
        If player.shieldsLevel < 0 Then
            player.shieldsLevel = 0
            GXSoundPlay sndExplode
            GXSoundPlay sndGameOver
            GXEntityVisible player.id, False
            GXEntityVisible player.shieldsId, False
            gameOver = True
        End If
        player.shieldsHit = GXFrame


    ElseIf etype = TRANSPORT And cetype = PZONE Then
        eidx = entityMap(e.entity)
        If e.collisionEntity = enemies(eidx).targetId Then
            Dim newTargetId As Integer
            Do
                Dim pidx As Integer
                pidx = Fix(Rnd * UBound(planet)) + 1
                newTargetId = planet(pidx)
            Loop Until newTargetId <> enemies(eidx).targetId
            enemies(eidx).targetId = newTargetId
        End If

    ElseIf etype = THEPLAYER And (cetype = PZONE Or cetype = WORMHOLE) Then
        If planetDefense = 0 And lastPlanet <> e.collisionEntity Then
            Dim idx As Integer
            idx = entityMap(e.collisionEntity)
            ScrambleDefense pinfo(idx).enemies, e.collisionEntity
        Else
            If activeEnemies = 0 Then planetDefense = 0
        End If

    ElseIf etype = THEPLAYER And cetype = POWERUP Then
        GXSoundPlay sndPowerup
        player.shieldsLevel = player.shieldsLevel + 15
        If player.shieldsLevel > SHIELDS_MAX Then player.shieldsLevel = SHIELDS_MAX
        GXEntityVisible e.collisionEntity, False
        GXEntityPos e.collisionEntity, -10000, -10000
    End If

End Sub

Sub ScrambleDefense (ecount As Integer, pid As Integer)
    SetMessage "Planetary Defenses Alerted!"
    GXSoundPlay sndAlarm
    Dim i As Integer
    For i = 1 To ecount
        GXEntityPos enemies(i).id, GXEntityX(pid) - (Rnd * 1000) - 500, GXEntityY(pid) - (Rnd * 1000) - 500
        GXEntityPos enemies(i).shieldsId, GXEntityX(enemies(i).id), GXEntityY(enemies(i).id)
        GXEntityVisible enemies(i).id, True
        enemies(i).shieldsLevel = 3
        enemies(i).dead = False
    Next i
    planetDefense = pid
    lastPlanet = pid
End Sub

Sub HandlePlayerFire
    Dim fire As Integer
    fire = False

    If GXKeyDown(GXKEY_J) Then
        If player.firing = False Then fire = True
        player.firing = True
    Else
        player.firing = False
    End If

    If fire Then
        Shoot player, bullets()
    End If

    ' disable any bullets that are offscreen
    DisableSpentBullets bullets()
    DisableSpentBullets ebullets()
End Sub

Sub DisableSpentBullets (b() As Long)
    Dim i As Integer
    For i = 1 To UBound(b)
        If Abs(GXEntityX(b(i)) - GXEntityX(player.id)) > GXSceneWidth Or _
           Abs(GXEntityY(b(i)) - GXEntityY(player.id)) > GXSceneHeight Then
            GXEntityVisible b(i), False
        End If
    Next i
End Sub

Sub Shoot (s As Ship, b() As Long)
    Dim As Integer i, frame, btype
    If s.id = player.id Then btype = BULLET Else btype = EBULLET
    i = NextObject(b(), btype)
    If i > 0 Then
        frame = s.position
        If frame > 8 Then frame = frame - 8
        GXEntityFrameSet b(i), frame, 1
        GXEntityPos b(i), GXEntityX(s.id) + GXEntityWidth(s.id) * .3, GXEntityY(s.id) + GXEntityHeight(s.id) * .3
        GXEntityVX b(i), accel(s.position).x * 750 + GXEntityVX(s.id)
        GXEntityVY b(i), accel(s.position).y * 750 + GXEntityVY(s.id)
        GXEntityVisible b(i), True
        GXSoundPlay sndLaser(i)
    End If
End Sub

Sub HandlePlayerTransport
    Dim isKeyPress As Integer

    If GXKeyDown(GXKEY_K) Then
        If player.transporting = False Then isKeyPress = True
        player.transporting = True
    Else
        player.transporting = False
    End If

    overWaypoint = GXEntityCollide(player.id, ping)
    If isKeyPress Then
        If overWaypoint Then
            If Abs(GXEntityVX(player.id)) > 12 Or Abs(GXEntityVY(player.id) > 12) Then
                SetMessage "Too fast!"
                GXSoundPlay sndError
            Else
                NextWaypoint
            End If
        Else
            SetMessage "Not close enough!"
            GXSoundPlay sndError
        End If
    End If
End Sub


Sub HandleEnemyMovement
    Dim As Integer i
    activeEnemies = 0
    For i = 1 To UBound(enemies)
        ' Continue to show "dying" enemies for several frames while the explosion animation starts
        If enemies(i).dead > 0 Then
            If GXFrame - enemies(i).dead > 10 Then
                GXEntityVisible enemies(i).id, False
                enemies(i).dead = True
                _Continue
            End If
        ElseIf enemies(i).dead = True Then
            _Continue
        End If

        If GXEntityType(enemies(i).id) = ENEMY Then activeEnemies = activeEnemies + 1

        If enemies(i).turningRight = 0 And enemies(i).turningLeft = 0 Then

            Dim targetPos As Integer
            targetPos = GetTargetPos(enemies(i).id, enemies(i).targetId)

            If targetPos = enemies(i).position Then
                If GXEntityType(enemies(i).id) = ENEMY Then
                    ' we are facing the right way - FIRE
                    If Abs(GXEntityX(enemies(i).id) - GXEntityX(player.id)) < enemies(i).maxSpeed And Abs(GXEntityY(enemies(i).id) - GXEntityY(player.id)) < enemies(i).maxSpeed Then
                        If GXFrame - enemies(i).firing > 20 And Fix(Rnd * 10) = 1 Then
                            Shoot enemies(i), ebullets()
                            enemies(i).firing = GXFrame
                        End If
                    End If
                End If
            Else
                Dim dif As Integer
                If targetPos > enemies(i).position Then
                    dif = (targetPos + 16) - (enemies(i).position + 16)

                    If dif > 9 Then
                        enemies(i).turningLeft = GXFrame
                    Else
                        enemies(i).turningRight = GXFrame
                    End If
                Else
                    dif = (targetPos + 16) - (enemies(i).position + 16)
                    If dif > 8 Then
                        enemies(i).turningRight = GXFrame
                    Else
                        enemies(i).turningLeft = GXFrame
                    End If
                End If
            End If

        Else
            If enemies(i).turningRight > 0 Then
                If GXFrame - enemies(i).turningRight > 1 Then
                    enemies(i).position = enemies(i).position + 1
                    If enemies(i).position > 16 Then enemies(i).position = 1
                    enemies(i).turningRight = 0
                End If

            ElseIf enemies(i).turningLeft > 0 Then
                If GXFrame - enemies(i).turningLeft > 1 Then
                    enemies(i).position = enemies(i).position - 1
                    If enemies(i).position < 1 Then enemies(i).position = 16
                    enemies(i).turningLeft = 0
                End If
            End If
        End If

        GXEntityFrameSet enemies(i).id, enemies(i).position, 1
        Dim As Double vx, vy
        vx = GXEntityVX(enemies(i).id)
        vy = GXEntityVY(enemies(i).id)
        If (vx >= 0 And vx < enemies(i).maxSpeed) Or (vx < 0 And vx > -enemies(i).maxSpeed) Then
            GXEntityVX enemies(i).id, vx + accel(enemies(i).position).x * 10
        Else
            GXEntityVX enemies(i).id, vx - 10 * Sgn(vx)
        End If
        If (vy >= 0 And vy < enemies(i).maxSpeed) Or (vy < 0 And vy > -enemies(i).maxSpeed) Then
            GXEntityVY enemies(i).id, vy + accel(enemies(i).position).y * 10
        Else
            GXEntityVY enemies(i).id, vy - 10 * Sgn(vy)
        End If

        If GXFrame - enemies(i).shieldsHit < 15 Then
            GXEntityVisible enemies(i).shieldsId, True
            GXEntityPos enemies(i).shieldsId, GXEntityX(enemies(i).id), GXEntityY(enemies(i).id)
            GXEntityVX enemies(i).shieldsId, GXEntityVX(enemies(i).id)
            GXEntityVY enemies(i).shieldsId, GXEntityVY(enemies(i).id)
        Else
            GXEntityVisible enemies(i).shieldsId, False
            GXEntityPos enemies(i).shieldsId, -10000, -10000
        End If

    Next i

End Sub

Function GetTargetPos% (entity As Long, target As Long)
    Dim As Long ex, ey, px, py
    Dim As Double angle
    ex = GXEntityX(entity)
    ey = GXEntityY(entity)
    px = GXEntityX(target)
    py = GXEntityY(target)
    angle = _Atan2(ey - py, ex - px) * 180 / _Pi

    Dim targetPos As Integer
    If angle >= 78.75 And angle < 101.25 Then
        targetPos = 1
    ElseIf angle >= 101.25 And angle < 123.75 Then
        targetPos = 2
    ElseIf angle >= 123.75 And angle < 146.25 Then
        targetPos = 3
    ElseIf angle >= 146.25 And angle < 168.25 Then
        targetPos = 4
    ElseIf (angle >= 168.25 And angle <= 180) Or (angle < -168.25 And angle >= -180) Then
        targetPos = 5
    ElseIf angle >= -168.25 And angle < -146.25 Then
        targetPos = 6
    ElseIf angle >= -146.25 And angle < -123.75 Then
        targetPos = 7
    ElseIf angle >= -123.75 And angle < -101.25 Then
        targetPos = 8
    ElseIf angle >= -101.25 And angle < -78.75 Then
        targetPos = 9
    ElseIf angle >= -78.75 And angle < -56.25 Then
        targetPos = 10
    ElseIf angle >= -56.25 And angle < -33.75 Then
        targetPos = 11
    ElseIf angle >= -33.75 And angle < -11.25 Then
        targetPos = 12
    ElseIf (angle >= -11.25 And angle <= 0) Or (angle < 11.25 And angle > 0) Then
        targetPos = 13
    ElseIf angle >= 11.25 And angle < 33.75 Then
        targetPos = 14
    ElseIf angle >= 33.75 And angle < 56.25 Then
        targetPos = 15
    ElseIf angle >= 56.25 And angle < 78.75 Then
        targetPos = 16
    End If

    GetTargetPos = targetPos
End Function


Sub SetMessage (msgText As String)
    message = UCase$(msgText)
    messageStart = GXFrame
    messageDuration = 180
End Sub

Sub NextWaypoint
    passengers = passengers + pinfo(cwp).rebels
    score = score + pinfo(cwp).rebels * 5 * cwp
    cwp = cwp + 1
    If cwp > UBound(waypoints) Then
        gameOver = 2
        GXEntityVisible player.id, False
        GXEntityVisible player.shieldsId, False
        GXEntityVisible ping, False
        GXEntityVisible whshrink, True
        GXEntityVisible planet(6), False
        GXEntityPos planet(6), -20000, -20000
        GXEntityAnimateMode whshrink, GXANIMATE_SINGLE
        GXEntityAnimate whshrink, 1, 40
        GXSoundPlay sndVictory
    Else
        SetMessage "Transport successful!"
        GXSoundPlay sndTransport
        GXEntityPos ping, -10000, -10000
        pingDelay = GXFrame
    End If
End Sub

Function NextObject% (e() As Long, etype As Integer)
    Dim As Integer i, eidx
    For i = 1 To UBound(e)
        If GXEntityType(e(i)) = etype And Not GXEntityVisible(e(i)) Then
            eidx = i
            Exit For
        End If
    Next i
    NextObject% = eidx
End Function

Sub HandlePlayerMovement
    If GXKeyDown(GXKEY_D) Then
        If player.turningRight > 0 Then
            If GXFrame - player.turningRight > 1 Then
                player.position = player.position + 1
                If player.position > 16 Then player.position = 1
                GXEntityFrameSet player.id, player.position, player.frame
                player.turningRight = 0
            End If
        Else
            player.turningRight = GXFrame
        End If
    Else
        player.turningRight = 0
    End If

    If GXKeyDown(GXKEY_A) Then
        If player.turningLeft > 0 Then
            If GXFrame - player.turningLeft > 1 Then
                player.position = player.position - 1
                If player.position < 1 Then player.position = 16
                GXEntityFrameSet player.id, player.position, player.frame
                player.turningLeft = 0
            End If
        Else
            player.turningLeft = GXFrame
        End If
    Else
        player.turningLeft = 0
    End If

    If GXKeyDown(GXKEY_W) Then
        GXEntityVX player.id, GXEntityVX(player.id) + accel(player.position).x * 5
        GXEntityVY player.id, GXEntityVY(player.id) + accel(player.position).y * 5
        player.frame = 2
        GXEntityFrameSet player.id, player.position, player.frame
        GXSoundPlay sndThruster
    Else
        player.frame = 1
        GXEntityFrameSet player.id, player.position, player.frame
        GXSoundStop sndThruster
    End If

    If GXFrame - player.shieldsHit < 10 Then
        GXEntityVisible player.shieldsId, True
        GXEntityPos player.shieldsId, GXEntityX(player.id) - 20, GXEntityY(player.id) - 20
    Else
        GXEntityVisible player.shieldsId, False
    End If

    Dim sframe As Integer
    sframe = _Round(player.shieldsLevel / SHIELDS_MAX * 8) + 1
    GXEntityFrameSet healthbar, sframe, 1
End Sub

Sub TrackEntity (eid As Integer, locEid As Integer)
    Dim As Integer x, y, ox, oy
    ox = GXEntityWidth(locEid) / 2
    oy = GXEntityHeight(locEid) / 2

    x = (GXEntityX(eid) / 250) + GXEntityWidth(locFinder) / 2 + GXEntityX(locFinder) - ox
    y = (GXEntityY(eid) / 250) + GXEntityHeight(locFinder) / 2 - oy
    GXEntityPos locEid, x, y
End Sub

Sub StartGame
    GXSoundRepeat sndMusic
    GXEntityVisible title, False
    GXEntityVisible controls, False

    ' initialize the transport positions
    Dim i As Integer
    For i = 1 To UBound(enemies)
        If i > 10 Then
            GXEntityPos enemies(i).id, Rnd * -5000 + 2500, Rnd * -5000 + 2500
            enemies(i).shieldsLevel = 3
        End If
    Next i

    ' reset the player position
    GXSceneFollowEntity player.id, GXSCENE_FOLLOW_ENTITY_CENTER
    GXEntityVisible player.id, True
    player.position = 1
    GXEntityVisible player.shieldsId, False
    player.shieldsLevel = SHIELDS_MAX

    passengers = 0
    timeRemaining = 18000

    ' initialize the waypoint
    cwp = 1
    pingDelay = GXFrame

    GXSoundStop sndIntro

    introMode = False
End Sub

Sub ShowWaypoint
    GXSoundPlay sndPing
    SetMessage "Rebel Transmission Detected"
    GXEntityVisible ping, True
    GXEntityVisible pingLoc, True
    GXEntityPos ping, waypoints(cwp).x, waypoints(cwp).y
    TrackEntity ping, pingLoc
    pingDelay = 0
End Sub

Sub InitGameObjects
    Dim As Long bg1, bg2, bg3
    bg1 = GXBackgroundAdd("img/bgstars.png", GXBG_WRAP)
    GXBackgroundWrapFactor bg1, .5
    bg2 = GXBackgroundAdd("img/spr_stars01.png", GXBG_WRAP)
    GXBackgroundWrapFactor bg2, .55
    bg3 = GXBackgroundAdd("img/spr_stars02.png", GXBG_WRAP)
    GXBackgroundWrapFactor bg3, .6

    ' Acceleration factors based on ship position
    accel(1).x = 0: accel(1).y = -1
    accel(2).x = .25: accel(2).y = -.75
    accel(3).x = .5: accel(3).y = -.5
    accel(4).x = .75: accel(4).y = -.25
    accel(5).x = 1: accel(5).y = 0
    accel(6).x = .75: accel(6).y = .25
    accel(7).x = .5: accel(7).y = .5
    accel(8).x = .25: accel(8).y = .75
    accel(9).x = 0: accel(9).y = 1
    accel(10).x = -.25: accel(10).y = .75
    accel(11).x = -.5: accel(11).y = .5
    accel(12).x = -.75: accel(12).y = .25
    accel(13).x = -1: accel(13).y = 0
    accel(14).x = -.75: accel(14).y = -.25
    accel(15).x = -.5: accel(15).y = -.5
    accel(16).x = -.25: accel(16).y = -.75


    pinfo(1).rebels = 26
    pinfo(2).rebels = 59
    pinfo(3).rebels = 278
    pinfo(4).rebels = 173
    pinfo(5).rebels = 346
    pinfo(6).hideOnMap = True


    ' Initialize planet entities
    Dim i As Integer
    i = 1
    InitPlanet "img/planet1.png", 247, 247, 1, -100, -100, i, 2: i = i + 1
    InitPlanet "img/planet2.png", 475, 475, 1, 2000, 2000, i, 3: i = i + 1
    InitPlanet "img/planet3.png", 954, 739, 1, 5000, -5000, i, 4: i = i + 1
    InitPlanet "img/planet4.png", 475, 475, 1, -8000, 8000, i, 4: i = i + 1
    InitPlanet "img/planet5.png", 475, 475, 1, -8500, -7000, i, 5: i = i + 1
    InitPlanet "img/wormhole.png", 400, 300, 64, -4000, -4000, i, 6
    GXEntityType planet(i), WORMHOLE
    GXEntityAnimate planet(i), 1, 8

    whshrink = GXEntityCreate("img/wormhole-shrink.png", 400, 300, 12)
    GXEntityPos whshrink, -4000, -4000
    GXEntityVisible whshrink, False

    ' Initialize the map view
    locFinder = GXScreenEntityCreate("img/location.png", 155, 96, 1)
    GXEntityPos locFinder, GXSceneWidth - GXEntityWidth(locFinder), 0

    ' Planet map position tracker
    For i = 1 To UBound(ploc)
        ploc(i) = GXScreenEntityCreate("img/position-planet.png", 2, 2, 1)
    Next i

    ' Player map postion tracker
    locPos = GXScreenEntityCreate("img/position.png", 2, 2, 1)

    ' Initialize waypoints
    i = 1
    waypoints(i).x = -50: waypoints(i).y = -50: i = i + 1
    waypoints(i).x = 2200: waypoints(i).y = 2200: i = i + 1
    waypoints(i).x = 5450: waypoints(i).y = -4800: i = i + 1
    waypoints(i).x = -7800: waypoints(i).y = 8200: i = i + 1
    waypoints(i).x = -8150: waypoints(i).y = -6650: i = i + 1
    waypoints(i).x = -3825: waypoints(i).y = -3875: i = i + 1
    cwp = 0

    ping = GXEntityCreate("img/ping.png", 64, 64, 38)
    GXEntityType ping, WAYPOINT
    GXEntityAnimate ping, 1, 15
    GXEntityCollisionOffset ping, 27, 27, 27, 27
    GXEntityVisible ping, False
    pingLoc = GXScreenEntityCreate("img/ping-small.png", 8, 8, 10)
    GXEntityAnimate pingLoc, 1, 10
    GXEntityFrameSet pingLoc, 1, 4
    GXEntityVisible pingLoc, False

    healthbar = GXScreenEntityCreate("img/health-bar.png", 155, 35, 1)
    GXEntityPos healthbar, GXSceneWidth - GXEntityWidth(healthbar), GXEntityHeight(locFinder)
    GXEntityFrameSet healthbar, 9, 1

    Dim statsBar As Long
    statsBar = GXScreenEntityCreate("img/stats-bar.png", 595, 96, 1)
    GXEntityPos statsBar, 210, 0

    title = GXScreenEntityCreate("img/title.png", 304, 144, 1)
    GXEntityPos title, 328, 228

    controls = GXScreenEntityCreate("img/controls.png", 184, 68, 1)
    GXEntityPos controls, 60, 500


    ' Initialize the bullets
    InitializeBullets bullets(), BULLET, "img/bullet1.png", 32, 32
    InitializeBullets ebullets(), EBULLET, "img/bullet2.png", 32, 32


    ' Initialize the enemy entities
    For i = 1 To UBound(enemies)
        If i <= 10 Then
            enemies(i).id = GXEntityCreate("img/enemy1.png", 48, 48, 1)
            GXEntityType enemies(i).id, ENEMY
            GXEntityPos enemies(i).id, -10000, -10000
            enemies(i).dead = True
            GXEntityVisible enemies(i).id, False
            enemies(i).maxSpeed = 300

            enemies(i).shieldsLevel = 3
            enemies(i).shieldsId = GXEntityCreate("img/shields2.png", 48, 48, 20)
            GXEntityAnimate enemies(i).shieldsId, 1, 20
        Else
            enemies(i).id = GXEntityCreate("img/transport.png", 64, 64, 1)
            GXEntityType enemies(i).id, TRANSPORT
            GXEntityPos enemies(i).id, Rnd * -5000 + 2500, Rnd * -5000 + 2500
            Dim idx As Integer
            idx = Fix(Rnd * UBound(planet)) + 1
            enemies(i).targetId = planet(idx)
            enemies(i).maxSpeed = 75

            enemies(i).shieldsLevel = 3
            enemies(i).shieldsId = GXEntityCreate("img/shields3.png", 64, 64, 11)
            GXEntityAnimate enemies(i).shieldsId, 1, 11
        End If

        enemies(i).position = 1
        entityMap(enemies(i).id) = i

        GXEntityPos enemies(i).shieldsId, -10000, -10000
        GXEntityVisible enemies(i).shieldsId, False
    Next i

    ' Initialize the powerups
    For i = 1 To UBound(powerups)
        powerups(i) = GXEntityCreate("img/powerup.png", 32, 32, 1)
        GXEntityType powerups(i), POWERUP
        GXEntityVisible powerups(i), False
        GXEntityPos powerups(i), -10000, -10000
        GXEntityCollisionOffset powerups(i), 8, 8, 8, 8
    Next i

    ' Initialize enemy explosions
    For i = 1 To UBound(explosions)
        explosions(i) = GXEntityCreate("img/explosion1.png", 256, 256, 65)
        GXEntityType explosions(i), EXPLOSION
        GXEntityVisible explosions(i), False
        GXEntityPos explosions(i), -10000, -10000
    Next i


    ' Initialize the player entity
    player.id = GXEntityCreate("img/ship1.png", 80, 80, 1)
    GXEntityType player.id, THEPLAYER
    GXEntityPos player.id, 200, 200
    GXEntityCollisionOffset player.id, 12, 12, 12, 12
    GXSceneFollowEntity player.id, GXSCENE_FOLLOW_ENTITY_CENTER
    GXEntityVisible player.id, False
    player.position = 1
    player.shieldsId = GXEntityCreate("img/shields1.png", 119, 119, 11)
    GXEntityAnimate player.shieldsId, 1, 11
    GXEntityPos player.shieldsId, -10000, -10000 ' GXEntityX(player.id) - 20, GXEntityY(player.id) - 20
    GXEntityVisible player.shieldsId, False
    player.shieldsLevel = SHIELDS_MAX
    GXEntityVY player.id, -3

    For i = 1 To UBound(enemies)
        If GXEntityType(enemies(i).id) = ENEMY Then
            enemies(i).targetId = player.id
        End If
    Next i

    gameFont = GXFontCreate("img/nfont.png", 8, 8, _
                            "0123456789ABCDEF" + GX_CRLF + _
                            "GHIJKLMNOPQRSTUV" + GX_CRLF + _
                            "WXYZ©>: -x !    ")

    sndAlarm = GXSoundLoad("snd/alarm.wav")
    sndCoin = GXSoundLoad("snd/coin.wav")
    sndError = GXSoundLoad("snd/error.wav")
    sndExplode = GXSoundLoad("snd/explode.wav")
    sndGameOver = GXSoundLoad("snd/game-over.wav")
    sndIntro = GXSoundLoad("snd/intro-music.ogg")
    sndMusic = GXSoundLoad("snd/bg-music.ogg")
    sndPing = GXSoundLoad("snd/ping.wav")
    sndPowerup = GXSoundLoad("snd/powerup.wav")
    sndThruster = GXSoundLoad("snd/thruster.mp3")
    sndTransport = GXSoundLoad("snd/transport.wav")
    sndVictory = GXSoundLoad("snd/victory.ogg")
    For i = 1 To UBound(sndLaser)
        sndLaser(i) = GXSoundLoad("snd/laser.wav")
    Next i

    GXSoundRepeat sndIntro
    introMode = True
End Sub

Sub InitPlanet (img As String, w As Integer, h As Integer, frames As Integer, x As Integer, y As Integer, idx As Integer, enemies As Integer)
    Dim id As Long
    id = GXEntityCreate(img, w, h, frames)
    GXEntityPos id, x, y
    GXEntityType id, PZONE
    pinfo(idx).enemies = enemies
    entityMap(id) = idx
    planet(idx) = id
End Sub

Sub InitializeBullets (b() As Long, btype As Integer, img As String, w As Integer, h As Integer)
    Dim i
    For i = 1 To UBound(b)
        b(i) = GXEntityCreate(img, w, h, 1)
        GXEntityType b(i), btype
        GXEntityCollisionOffset b(i), 5, 5, 5, 5
        GXEntityVisible b(i), False
    Next i

End Sub

'$Include: '..\..\gx\gx.bm'

