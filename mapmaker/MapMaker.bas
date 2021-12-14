Option _Explicit
$ExeIcon:'./../gx/resource/gx.ico'
'$Include:'../gx/gx.bi'

Const FD_OPEN = 1
Const FD_SAVE = 2

Dim Shared scale As Integer '             - Scale used to apply zoom level to map
Dim Shared tscale As Integer '            - Scale used to apply zoom level to tileset
Dim Shared gxloaded As Integer '          - Indicates when the GX engine is initialized
Dim Shared mapLoaded As Integer '         - True when a map is currently loaded
Dim Shared mapFilename As String '        - Name of the map file currently loaded
Dim Shared tilesetPos As GXPosition '     - Tileset screen position for scrolling the tileset window
Dim Shared tileSelStart As GXPosition '   - Tile selection start position
Dim Shared tileSelEnd As GXPosition '     - Tile selection end position
Dim Shared tileSelSizing As Integer '     - Tile selection sizing flag
Dim Shared mapSelSizing As Integer '      - Map selection sizing flag
Dim Shared mapSelMode As Integer '        - Map selection mode (True=map, False=tileset)
Dim Shared saving As Integer '            - Set to True when the map is currently being saved
Dim Shared deleting As Integer '          - When true the delete key is pressed but not yet released
Dim Shared dialogMode As Integer '        - Indicates whethere a dialog is currently being displayed
Dim Shared fileDialogMode As Integer '    - Type of file dialog opened (Open, Save)
Dim Shared fileDialogPath As String '     - Current/last path selected in the file dialog
Dim Shared fileDialogTargetForm As Long ' - Control which opened the file dialog
Dim Shared lastControlClicked As Long '   - Used for capturing double-click events
Dim Shared lastClick As Double '          - Used for capturing double-click events
Dim Shared animationMode As Integer
Dim Shared resizeMode As Integer
ReDim Shared hiddenLayers(0) As Integer


': This program uses
': InForm - GUI library for QB64 - v1.2
': Fellippe Heitor, 2016-2020 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------
' Menus and Menu Items
Dim Shared MainForm As Long
Dim Shared FileMenu As Long
Dim Shared FileMenuNew As Long
Dim Shared FileMenuOpen As Long
Dim Shared FileMenuSave As Long
Dim Shared FileMenuSaveAs As Long
Dim Shared FileMenuExit As Long
Dim Shared MapMenu As Long
Dim Shared MapMenuZoomIn As Long
Dim Shared MapMenuZoomOut As Long
Dim Shared MapMenuResize As Long
Dim Shared TilesetMenu As Long
Dim Shared TilesetMenuReplace As Long
Dim Shared TilesetMenuZoomIn As Long
Dim Shared TilesetMenuZoomOut As Long
Dim Shared HelpMenu As Long
Dim Shared HelpMenuView As Long
Dim Shared HelpMenuAbout As Long

' Map control
Dim Shared Map As Long
Dim Shared lblLayer As Long
Dim Shared lblEditLayer As Long
Dim Shared cboLayer As Long
Dim Shared cboEditLayer As Long
Dim Shared chkLayerHidden As Long
Dim Shared lblMapInfo As Long
Dim Shared btnLayerAdd As Long
Dim Shared btnLayerRemove As Long

' Tile control
Dim Shared Tiles As Long
Dim Shared frmTile As Long
Dim Shared lblTileId As Long
Dim Shared lblTileIdValue As Long
Dim Shared lblTileAnimated As Long
Dim Shared tglTileAnimate As Long
Dim Shared lblTileAnimationSpeed As Long
Dim Shared txtTileAnimationSpeed As Long
Dim Shared lblTileFrames As Long
Dim Shared lstTileFrames As Long
Dim Shared btnTileAddFrame As Long

' Tile Frame Context Menu
Dim Shared TileFrameMenu As Long
Dim Shared TileFrameMenuRemove As Long

' Status bar
Dim Shared lblStatus As Long

' New Map Dialog
Dim Shared frmNewMap As Long
Dim Shared lblColumns As Long
Dim Shared txtColumns As Long
Dim Shared lblRows As Long
Dim Shared txtRows As Long
Dim Shared lblLayers As Long
Dim Shared txtLayers As Long
Dim Shared lblTilesetImage As Long
Dim Shared txtTilesetImage As Long
Dim Shared btnSelectTilesetImage As Long
Dim Shared lblTileHeight As Long
Dim Shared txtTileHeight As Long
Dim Shared lblTileWidth As Long
Dim Shared txtTileWidth As Long
Dim Shared lblIsometric As Long
Dim Shared tglIsometric As Long
Dim Shared lblLine As Long
Dim Shared btnCreateMap As Long
Dim Shared btnCancel As Long

' Replace Tileset Dialog
Dim Shared frmReplaceTileset As Long
Dim Shared lblRTTileWidth As Long
Dim Shared txtRTTileWidth As Long
Dim Shared lblRTTileHeight As Long
Dim Shared txtRTTileHeight As Long
Dim Shared lblRTTilesetImage As Long
Dim Shared txtRTTilesetImage As Long
Dim Shared btnRTSelectTilesetImage As Long
Dim Shared lblRTLine As Long
Dim Shared btnRTReplaceImage As Long
Dim Shared btnRTCancel As Long

' Resize Map Dialog
Dim Shared frmResizeMap As Long
Dim Shared lblResizeColumns As Long
Dim Shared lblResizeRows As Long
Dim Shared txtResizeColumns As Long
Dim Shared txtResizeRows As Long
Dim Shared lblResizeSeparator As Long
Dim Shared btnResizeMap As Long
Dim Shared btnResizeCancel As Long

' File Dialog
Dim Shared frmFile As Long
Dim Shared lblFDFilename As Long
Dim Shared txtFDFilename As Long
Dim Shared lblFDPath As Long
Dim Shared lblFDPathValue As Long
Dim Shared lblFDFiles As Long
Dim Shared lblFDPaths As Long
Dim Shared lstFDFiles As Long
Dim Shared lstFDPaths As Long
Dim Shared chkFDFilterExt As Long
Dim Shared btnFDOK As Long
Dim Shared btnFDCancel As Long


': External modules: ---------------------------------------------------------------
'$Include:'./inform/InForm.ui'
'$Include:'./inform/xp.uitheme'
'$Include:'MapMaker.frm'

': Event procedures: ---------------------------------------------------------------
Sub __UI_BeforeInit
End Sub

Sub __UI_OnLoad
    ' Hide the dialog forms
    Control(frmNewMap).Hidden = True
    Control(frmReplaceTileset).Hidden = True
    Control(frmFile).Hidden = True

    ' Set the initial zoom level (1=100%, actual size)
    scale = 1
    tscale = 1

    ' Disable menu items which are not valid yet
    Control(MapMenuZoomIn).Disabled = True
    Control(MapMenuZoomOut).Disabled = True
    Control(MapMenuResize).Disabled = True
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = True
    Control(TilesetMenuReplace).Disabled = True
    Control(TilesetMenuZoomIn).Disabled = True
    Control(TilesetMenuZoomOut).Disabled = True

    ' Disable the tile form
    Control(frmTile).Disabled = True
    Control(lblTileId).Disabled = True
    Control(lblTileIdValue).Disabled = True
    Control(lblTileAnimated).Disabled = True
    Control(tglTileAnimate).Disabled = True

    ' Initialize the map info
    Control(lblLayer).Disabled = True
    Control(cboLayer).Disabled = True
    Control(chkLayerHidden).Hidden = True
    Control(cboEditLayer).Hidden = True
    Control(lblEditLayer).Hidden = True
    Control(btnLayerAdd).Hidden = True
    Control(btnLayerRemove).Hidden = True
    SetCaption lblMapInfo, ""

    ' Hide the panel dialog(s)
    Control(frmResizeMap).Hidden = True

    ' Create the GX Scene for rendering the map
    GXSceneEmbedded True
    GXSceneCreate Control(Map).Width / 2, Control(Map).Height / 2

    ' Initialize the file dialog
    fileDialogPath = _CWD$
    Control(chkFDFilterExt).Value = True

    ' Size the window components for the current window size
    dialogMode = False
    ResizeControls

    ' Ok, we're ready to display screen updates now
    gxloaded = True

    ' Adjust GX framerate to account for difference in
    ' framerate handling with Inform to maintain tile animation speed
    SetFrameRate 60
    GXFrameRate 30

    If InStr(Command$, ".map") Or InStr(Command$, ".gxm") Then
        LoadMap Command$
    End If
End Sub

Sub __UI_BeforeUpdateDisplay
    If gxloaded = False Then Exit Sub ' We're not ready yet, abort!
    If dialogMode = True Then Exit Sub ' Nothing to do here


    Dim mc As Long
    mc = GetControlAtMousePos

    Dim tsHeight As Integer
    If GXMapIsometric Then
        tsHeight = GXTilesetWidth / 2
    Else
        tsHeight = GXTilesetHeight
    End If

    ' Use WASD or arrow keys to navigate around the map or tileset
    If GXKeyDown(GXKEY_S) Or GXKeyDown(GXKEY_DOWN) Then ' move down
        If mc = Map Then
            GXSceneMove 0, tsHeight 'GXTilesetHeight
        ElseIf mc = Tiles Then
            tilesetPos.y = tilesetPos.y + 1
        End If
        If (mapSelMode And mc = Map) Or (Not mapSelMode And mc = Tiles) Then
            tileSelStart.y = tileSelStart.y - 1: tileSelEnd.y = tileSelEnd.y - 1
        End If

    ElseIf GXKeyDown(GXKEY_W) Or GXKeyDown(GXKEY_UP) Then ' move up
        If mc = Map Then
            GXSceneMove 0, -tsHeight '-GXTilesetHeight
        ElseIf mc = Tiles Then
            tilesetPos.y = tilesetPos.y - 1
        End If
        If (mapSelMode And mc = Map) Or (Not mapSelMode And mc = Tiles) Then
            tileSelStart.y = tileSelStart.y + 1: tileSelEnd.y = tileSelEnd.y + 1
        End If

    ElseIf GXKeyDown(GXKEY_D) Or GXKeyDown(GXKEY_RIGHT) Then ' move right
        If mc = Map Then
            GXSceneMove GXTilesetWidth, 0
        ElseIf mc = Tiles Then
            tilesetPos.x = tilesetPos.x + 1
        End If
        If (mapSelMode And mc = Map) Or (Not mapSelMode And mc = Tiles) Then
            tileSelStart.x = tileSelStart.x - 1: tileSelEnd.x = tileSelEnd.x - 1
        End If

    ElseIf GXKeyDown(GXKEY_A) Or GXKeyDown(GXKEY_LEFT) Then ' move left
        If mc = Map Then
            GXSceneMove -GXTilesetWidth, 0
        ElseIf mc = Tiles Then
            tilesetPos.x = tilesetPos.x - 1
        End If
        If (mapSelMode And mc = Map) Or (Not mapSelMode And mc = Tiles) Then
            tileSelStart.x = tileSelStart.x + 1: tileSelEnd.x = tileSelEnd.x + 1
        End If
    End If

    ' Adjust the current selection if selection sizing is in progress
    If Not GXMapIsometric Then
        If tileSelSizing Then
            GetTilePosAt Tiles, _MouseX, _MouseY, tileSelEnd
        ElseIf mapSelSizing Then
            GetTilePosAt Map, _MouseX, _MouseY, tileSelEnd
        End If
    End If

    ' If X or DEL key is pressed, delete the tiles in the current selection
    If GXKeyDown(GXKEY_DELETE) Or GXKeyDown(GXKEY_X) Then deleting = 1
    If Not (GXKeyDown(GXKEY_X) Or GXKeyDown(GXKEY_X)) And deleting Then DeleteTile: deleting = 0

    ' Draw the map
    GXSceneUpdate
    GXSceneDraw

    ' Draw the tileset
    DrawTileset
End Sub

Sub __UI_BeforeUnload
    ' If the user is in the process of saving the map
    ' prevent the application from closing
    If saving Then __UI_UnloadSignal = False
End Sub

Sub __UI_Click (id As Long)

    Select Case id

        Case Map: OnMapClick

        Case FileMenuNew: ShowNewMapDialog
        Case FileMenuOpen: ShowFileDialog FD_OPEN, MainForm
        Case FileMenuSave: SaveMap mapFilename
        Case FileMenuSaveAs: ShowFileDialog FD_SAVE, MainForm
        Case FileMenuExit: System 0

        Case MapMenuZoomIn: ZoomMap 1
        Case MapMenuZoomOut: ZoomMap -1

        Case MapMenuResize: OnResizeMap
        Case btnResizeCancel: CancelResizeMap
        Case btnResizeMap: ResizeMap

        Case TilesetMenuZoomIn: ZoomTileset 1
        Case TilesetMenuZoomOut: ZoomTileset -1
        Case TilesetMenuReplace: ShowReplaceTilesetDialog

        Case HelpMenuView: ShowHelp
        Case HelpMenuAbout: ShowAbout

        Case btnCancel: CancelDialog frmNewMap
        Case btnRTCancel: CancelDialog frmReplaceTileset
        Case btnFDCancel: CancelDialog frmFile
        Case btnCreateMap: CreateMap
        Case btnRTReplaceImage: ReplaceTileset
        Case btnSelectTilesetImage: ShowFileDialog FD_OPEN, frmNewMap
        Case btnRTSelectTilesetImage: ShowFileDialog FD_OPEN, frmReplaceTileset
        Case btnFDOK: OnSelectFile
        Case btnLayerAdd: OnLayerAdd
        Case btnLayerRemove: OnLayerRemove

        Case lstFDFiles: OnFileListClick id
        Case lstFDPaths: OnPathListClick id

        Case btnTileAddFrame: OnTileFrameAdd

    End Select

    lastControlClicked = id
    lastClick = Timer
End Sub

Sub __UI_MouseEnter (id As Long)
    Select Case id
        Case Map: If Not dialogMode And mapLoaded Then _MouseHide
        Case Tiles: If Not dialogMode And mapLoaded Then _MouseHide
    End Select
End Sub

Sub __UI_MouseLeave (id As Long)
    Select Case id
        Case Map: _MouseShow
        Case Tiles: _MouseShow
    End Select
End Sub

Sub __UI_FocusIn (id As Long)
    Select Case id
    End Select
End Sub

Sub __UI_FocusOut (id As Long)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    Select Case id
    End Select
End Sub

Sub __UI_MouseDown (id As Long)
    Select Case id

        Case Map
            ' If the SHIFT key is pressed while clicking the map
            ' start resizing the selection cursor
            If (GXKeyDown(GXKEY_LSHIFT) Or GXKeyDown(GXKEY_RSHIFT)) And Not GXMapIsometric Then
                mapSelMode = True
                mapSelSizing = True
                '                GetTilePosAt Map, _MOUSEX, _MOUSEY, scale, tileSelStart
                GetTilePosAt Map, _MouseX, _MouseY, tileSelStart
                tileSelEnd = tileSelStart
            End If


        Case Tiles
            ' If we detect a mouse down event on the tileset control
            ' start resizing the tileset selection cursor
            mapSelMode = False
            tileSelSizing = True
            GetTilePosAt Tiles, _MouseX, _MouseY, tileSelStart
            tileSelEnd = tileSelStart

    End Select
End Sub

Sub __UI_MouseUp (id As Long)
    Select Case id
        Case Tiles
            tileSelSizing = False
            OnTileSelection
        Case tglTileAnimate: OnChangeTileAnimate
    End Select
End Sub

Sub __UI_KeyPress (id As Long)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    Select Case id
    End Select
End Sub

Sub __UI_TextChanged (id As Long)
    Select Case id
        Case txtTileAnimationSpeed: OnChangeTileAnimationSpeed
        Case txtResizeColumns: OnChangeResize
        Case txtResizeRows: OnChangeResize
    End Select
End Sub

Sub __UI_ValueChanged (id As Long)
    Select Case id
        Case chkFDFilterExt: RefreshFileList
        Case cboLayer: OnChangeLayer
        Case chkLayerHidden: OnChangeLayerHidden
    End Select
End Sub

Sub __UI_FormResized
    ' The window has been resized so resize the child components accordingly
    ResizeControls
End Sub


' GX Events
' ----------------------------------------------------------------------------
Sub GXOnGameEvent (e As GXEvent)
    If e.event = GXEVENT_PAINTBEFORE Then BeginDraw Map
    If e.event = GXEVENT_PAINTAFTER Then EndDraw Map
    If e.event = GXEVENT_DRAWSCREEN Then
        If mapSelMode Then DrawSelected Map
        DrawMapBorder
        DrawCursor Map
    End If
End Sub

Sub DrawMapBorder
    ' draw a bounding rectangle around the border of the map
    Dim bheight As Long
    Dim bwidth As Long
    Dim rwidth As Long
    Dim rheight As Long
    If GXMapIsometric Then
        bheight = (GXMapRows - 1) * (GXTilesetWidth / 4)
        bwidth = GXMapColumns * GXTilesetWidth - (GXTilesetWidth / 2)
        rheight = (Control(txtResizeRows).Value - 1) * (GXTilesetWidth / 4)
        rwidth = Control(txtResizeColumns).Value * GXTilesetWidth - (GXTilesetWidth / 2)
    Else
        bheight = GXMapRows * GXTilesetHeight
        bwidth = GXMapColumns * GXTilesetWidth
        rheight = Control(txtResizeRows).Value * GXTilesetHeight
        rwidth = Control(txtResizeColumns).Value * GXTilesetWidth
    End If

    Line (-GXSceneX - 1, -GXSceneY - 1)-(bwidth - GXSceneX, bheight - GXSceneY), _RGB(100, 100, 100), B
    If resizeMode Then
        Line (-GXSceneX - 1, -GXSceneY - 1)-(rwidth - GXSceneX, rheight - GXSceneY), _RGB(255, 255, 100), B
    End If
End Sub

' Create a new map from the parameters specified by the user on the new map dialog.
Sub CreateMap
    SetStatus "Creating new map..."
    Dim columns As Integer, rows As Integer, layers As Integer
    Dim tilesetImage As String
    Dim tileWidth As Integer, tileHeight As Integer
    Dim isometric As Integer
    Dim msgRes As Integer

    columns = Control(txtColumns).Value
    rows = Control(txtRows).Value
    layers = Control(txtLayers).Value
    tilesetImage = Text(txtTilesetImage)
    tileWidth = Control(txtTileWidth).Value
    tileHeight = Control(txtTileHeight).Value
    isometric = Control(tglIsometric).Value

    If columns < 1 Then msgRes = MessageBox("Map must have at least 1 column.", "Invalid Option", MsgBox_OkOnly): Exit Sub
    If rows < 1 Then msgRes = MessageBox("Map must have at least 1 row.", "Invalid Option", MsgBox_OkOnly): Exit Sub
    If layers < 1 Then msgRes = MessageBox("Map must have at least 1 layer.", "Invalid Option", MsgBox_OkOnly): Exit Sub
    If tilesetImage = "" Then msgRes = MessageBox("Please select a tileset image.", "Invalid Option", MsgBox_OkOnly): Exit Sub
    If tileWidth < 1 Then msgRes = MessageBox("Tile width must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): Exit Sub
    If tileHeight < 1 Then msgRes = MessageBox("Tile height must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): Exit Sub

    GXScenePos 0, 0
    GXMapCreate columns, rows, layers
    GXTilesetCreate tilesetImage, tileWidth, tileHeight
    GXMapIsometric isometric

    mapFilename = ""
    scale = 1
    tscale = 1
    tilesetPos.x = 0
    tilesetPos.y = 0
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = False
    Control(MapMenuZoomIn).Disabled = False
    Control(MapMenuZoomOut).Disabled = True
    Control(MapMenuResize).Disabled = False
    Control(TilesetMenuZoomIn).Disabled = False
    Control(TilesetMenuZoomOut).Disabled = True
    Control(TilesetMenuReplace).Disabled = False
    Control(frmNewMap).Hidden = True

    ReDim hiddenLayers(layers) As Integer

    SetDialogMode False
    SetMapFilename ""

    RefreshLayerDropdown
    RefreshMapInfo
    OnTileSelection
    ResizeControls
    SetStatus "Map created."
End Sub

' Load the map at the specified file location
Sub LoadMap (filename As String)
    SetStatus "Loading map..."

    EnableFileDialog False
    GXMapLoad filename
    SetMapFilename filename
    GXScenePos 0, 0
    tilesetPos.x = 0
    tilesetPos.y = 0

    Control(FileMenuSave).Disabled = False
    Control(FileMenuSaveAs).Disabled = False
    Control(MapMenuZoomIn).Disabled = False
    Control(MapMenuZoomOut).Disabled = True
    Control(MapMenuResize).Disabled = False
    Control(TilesetMenuZoomIn).Disabled = False
    Control(TilesetMenuZoomOut).Disabled = True
    Control(TilesetMenuReplace).Disabled = False
    scale = 1
    tscale = 1

    ReDim hiddenLayers(GXMapLayers) As Integer

    Control(frmFile).Hidden = True
    SetDialogMode False
    EnableFileDialog True

    RefreshLayerDropdown
    RefreshMapInfo
    OnTileSelection
    ResizeControls
    SetStatus "Map loaded."
    '_TITLE "GX Map Maker - " + __GXFS_GetFilename(filename)
End Sub

' Save the current map date to the specified file location
Sub SaveMap (filename As String)
    SetStatus "Saving map..."
    EnableFileDialog False

    saving = 1
    GXMapSave filename
    saving = 0
    SetMapFilename filename
    Control(FileMenuSave).Disabled = False

    Control(frmFile).Hidden = True
    SetDialogMode False
    EnableFileDialog True

    SetStatus "Map saved."
End Sub

Sub OnTileSelection
    If tileSelStart.x = tileSelEnd.x And tileSelStart.y = tileSelEnd.y Then
        Dim tile
        tile = tileSelStart.x + tilesetPos.x + (tileSelStart.y + tilesetPos.y) * GXTilesetColumns + 1

        If animationMode Then
            Dim animationSpeed As Integer
            GXTilesetAnimationAdd SelectedTile, tile
            RefreshTileFrameList
            animationMode = False
        Else
            ClearTileForm
            Caption(lblTileIdValue) = Str$(tile)
            Control(tglTileAnimate).Value = (GXTilesetAnimationSpeed(tile) > 0)
            Control(frmTile).Disabled = False
            Control(lblTileId).Disabled = False
            Control(lblTileIdValue).Disabled = False
            Control(lblTileAnimated).Disabled = False
            Control(tglTileAnimate).Disabled = False
            If Control(tglTileAnimate).Value = True Then
                Text(txtTileAnimationSpeed) = Str$(GXTilesetAnimationSpeed(tile))
                Control(lblTileAnimationSpeed).Disabled = False
                Control(txtTileAnimationSpeed).Disabled = False
                Control(lblTileFrames).Disabled = False
                Control(lstTileFrames).Disabled = False
                Control(btnTileAddFrame).Disabled = False
            End If
            RefreshTileFrameList
        End If
    Else
        ClearTileForm
    End If
End Sub

Function SelectedTile
    SelectedTile = Val(Caption(lblTileIdValue))
End Function

Sub DrawTileFrameSelection
    If SelectedTile = 0 Then Exit Sub

    Dim tileFrames(0) As Integer, frameCount As Integer, i As Integer
    frameCount = GXTilesetAnimationFrames(SelectedTile, tileFrames())
    For i = 1 To frameCount
        Dim tpos As GXPosition
        GXTilesetPos tileFrames(i), tpos

        ' Calculate the position of the tileset selection
        Dim swidth As Integer, sheight As Integer
        Dim startx As Integer, starty As Integer, endx As Integer, endy As Integer
        swidth = GXTilesetWidth * tscale
        sheight = GXTilesetHeight * tscale
        startx = (tpos.x - tilesetPos.x - 1) * swidth
        starty = (tpos.y - tilesetPos.y - 1) * sheight
        endx = (tpos.x - tilesetPos.x - 1) * swidth + swidth - 1
        endy = (tpos.y - tilesetPos.y - 1) * sheight + sheight - 1

        ' Draw the selection rectangle
        Line (startx, starty)-(endx, endy), _RGB(0, 0, 255), B ', &B1010101010101010
    Next i
End Sub

Sub ClearTileForm
    ' clear the values
    Caption(lblTileIdValue) = ""
    Control(tglTileAnimate).Value = False
    Control(txtTileAnimationSpeed).Value = 0
    ResetList lstTileFrames

    ' disable the controls
    Control(frmTile).Disabled = True
    Control(lblTileId).Disabled = True
    Control(lblTileIdValue).Disabled = True
    Control(lblTileAnimated).Disabled = True
    Control(tglTileAnimate).Disabled = True
    Control(lblTileAnimationSpeed).Disabled = True
    Control(txtTileAnimationSpeed).Disabled = True
    Control(lblTileFrames).Disabled = True
    Control(lstTileFrames).Disabled = True
    Control(btnTileAddFrame).Disabled = True
End Sub

Sub OnChangeTileAnimate
    If Control(tglTileAnimate).Value = False Then
        Control(lblTileAnimationSpeed).Disabled = False
        Control(txtTileAnimationSpeed).Disabled = False
        Control(btnTileAddFrame).Disabled = False
        Control(lblTileFrames).Disabled = False
        Control(lstTileFrames).Disabled = False

        Dim animationSpeed As Integer
        animationSpeed = 5
        Control(txtTileAnimationSpeed).Value = animationSpeed
        GXTilesetAnimationCreate SelectedTile, animationSpeed
        RefreshTileFrameList
    Else
        GXTilesetAnimationRemove SelectedTile

        ' clear the values
        Control(txtTileAnimationSpeed).Value = 0
        ResetList lstTileFrames

        ' disable the controls
        Control(lblTileAnimationSpeed).Disabled = True
        Control(txtTileAnimationSpeed).Disabled = True
        Control(lblTileFrames).Disabled = True
        Control(lstTileFrames).Disabled = True
        Control(btnTileAddFrame).Disabled = True
    End If
End Sub

Sub OnChangeTileAnimationSpeed
    GXTilesetAnimationSpeed SelectedTile, Val(Text(txtTileAnimationSpeed))
End Sub

Sub OnTileFrameAdd
    animationMode = True
End Sub


Sub RefreshTileFrameList
    Dim tileFrames(0) As Integer, frameCount As Integer
    frameCount = GXTilesetAnimationFrames(SelectedTile, tileFrames())

    ResetList lstTileFrames
    Dim i As Integer
    For i = 1 To frameCount
        AddItem lstTileFrames, GXSTR_LPad(Str$(i), "0", 2) + ": " + Str$(tileFrames(i))
    Next i
End Sub

' Replace the current tileset with one specified by the user on the replace
' tileset dialog.
Sub ReplaceTileset
    Dim tilesetImage As String
    Dim tileWidth As Integer, tileHeight As Integer
    Dim msgRes As Integer

    tilesetImage = Text(txtRTTilesetImage)
    tileWidth = Control(txtRTTileWidth).Value
    tileHeight = Control(txtRTTileHeight).Value

    If tilesetImage = "" Then msgRes = MessageBox("Please select a tileset image.", "Invalid Option", MsgBox_OkOnly): Exit Sub
    If tileWidth < 1 Then msgRes = MessageBox("Tile width must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): Exit Sub
    If tileHeight < 1 Then msgRes = MessageBox("Tile height must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): Exit Sub

    GXTilesetReplaceImage tilesetImage, tileWidth, tileHeight
    Control(frmReplaceTileset).Hidden = True

    SetDialogMode False
End Sub

Sub RefreshLayerDropdown
    Dim i As Integer
    ResetList cboLayer
    ResetList cboEditLayer
    AddItem cboLayer, "All"
    AddItem cboEditLayer, "All"
    For i = 1 To GXMapLayers
        AddItem cboLayer, Str$(i)
        AddItem cboEditLayer, Str$(i)
    Next i
    Control(cboLayer).Disabled = False
    Control(lblLayer).Disabled = False
    Control(cboEditLayer).Disabled = False
    Control(lblEditLayer).Disabled = False
    Control(chkLayerHidden).Disabled = False
    Control(cboLayer).Value = 1
    Control(cboEditLayer).Value = 1
End Sub

Sub RefreshMapInfo
    Caption(lblMapInfo) = _Trim$(Str$(GXMapColumns)) + "x" + _Trim$(Str$(GXMapRows))
End Sub

Function SelectedLayer
    SelectedLayer = Control(cboLayer).Value - 1
End Function

Function SelectedEditLayer
    Dim layer As Integer
    layer = SelectedLayer
    If layer = 0 Then
        layer = Control(cboEditLayer).Value - 1
    End If
    SelectedEditLayer = layer
End Function

Sub OnChangeLayerHidden
    If SelectedLayer = 0 Then Exit Sub
    Dim selected As Integer
    selected = Control(chkLayerHidden).Value
    If selected = True Then
        hiddenLayers(SelectedLayer) = 1
    Else
        hiddenLayers(SelectedLayer) = 0
    End If
End Sub

Sub OnChangeLayer
    Dim layer As Integer
    layer = SelectedLayer

    If layer = 0 Then
        Control(chkLayerHidden).Hidden = True
        Control(lblEditLayer).Hidden = False
        Control(cboEditLayer).Hidden = False
        Control(btnLayerAdd).Hidden = False
        ToolTip(btnLayerAdd) = "Add a new layer to the map"
        Control(btnLayerRemove).Hidden = True
    Else
        Control(chkLayerHidden).Hidden = False
        Control(lblEditLayer).Hidden = True
        Control(cboEditLayer).Hidden = True
        Control(btnLayerAdd).Hidden = False
        ToolTip(btnLayerAdd) = "Insert a new layer before the currently selected layer"
        Control(btnLayerRemove).Hidden = False

        If (hiddenLayers(layer) = 0) Then
            Control(chkLayerHidden).Value = False
        Else
            Control(chkLayerHidden).Value = True
        End If
    End If

    Dim i As Integer
    For i = 1 To GXMapLayers
        If (layer = 0 And hiddenLayers(i) = 0) Or layer = i Then
            GXMapLayerVisible i, True
        Else
            GXMapLayerVisible i, False
        End If
    Next i
End Sub

Sub OnLayerAdd
    ReDim _Preserve hiddenLayers(GXMapLayers + 1) As Integer
    If SelectedLayer = 0 Then
        GXMapLayerAdd
        SetStatus "New layer added."
    Else
        GXMapLayerInsert SelectedLayer
        SetStatus "New layer inserted."
    End If
    RefreshLayerDropdown
End Sub

Sub OnLayerRemove
    If SelectedLayer = 1 And GXMapLayers < 2 Then Exit Sub

    ReDim _Preserve hiddenLayers(GXMapLayers - 1) As Integer
    GXMapLayerRemove SelectedLayer
    SetStatus "Layer removed."
    RefreshLayerDropdown
End Sub


' Place selected tiles in the location indicated by the cursor.  The tile
' selection can be made either in the tileset window or from another location
' on the map.
Sub PutTile ()
    If resizeMode Then Exit Sub
    If GXMapIsometric Then
        PutTileIso
        Exit Sub
    End If

    Dim x As Integer, y As Integer, sx As Integer
    Dim tx As Integer, ty As Integer
    Dim mtx As Integer, mty As Integer
    Dim tile As Integer

    sx = Fix((_MouseX / scale - Control(Map).Left + GXSceneX) / GXTilesetWidth)
    y = Fix((_MouseY / scale - Control(Map).Top + GXSceneY) / GXTilesetHeight)

    For ty = tileSelStart.y To tileSelEnd.y
        x = sx
        For tx = tileSelStart.x To tileSelEnd.x
            If mapSelMode Then
                ' select the tile from the top layer of the map selection position
                mtx = tx + GXSceneX / GXTilesetWidth
                mty = ty + GXSceneY / GXTilesetHeight
                If SelectedEditLayer = 0 Then
                    tile = GXMapTile(mtx, mty, GXMapTileDepth(mtx, mty))
                Else
                    tile = GXMapTile(mtx, mty, SelectedEditLayer)
                End If
            Else
                ' calculate the tile id from the current selection position
                tile = tx + tilesetPos.x + (ty + tilesetPos.y) * GXTilesetColumns + 1
            End If
            ' add the tile to the map at the next unpopulated layer
            If SelectedEditLayer = 0 Then
                GXMapTileAdd x, y, tile
            Else
                GXMapTile x, y, SelectedEditLayer, tile
            End If
            x = x + 1
        Next tx
        y = y + 1
    Next ty
End Sub

Sub PutTileIso ()
    Dim x As Integer, y As Integer, sx As Integer
    Dim tx As Integer, ty As Integer
    'DIM mtx AS INTEGER, mty AS INTEGER
    Dim tile As Integer

    Dim tpos As GXPosition
    GetTilePosAt Map, _MouseX + GXSceneX * scale, _MouseY + GXSceneY * scale, tpos
    'SetStatus "(" + STR$(tpos.x) + "," + STR$(tpos.y) + ")"
    sx = tpos.x
    y = tpos.y

    For ty = tileSelStart.y To tileSelEnd.y
        x = sx
        For tx = tileSelStart.x To tileSelEnd.x
            tile = tx + tilesetPos.x + (ty + tilesetPos.y) * GXTilesetColumns + 1
            If SelectedEditLayer = 0 Then
                GXMapTileAdd x, y, tile
            Else
                GXMapTile x, y, SelectedEditLayer, tile
            End If
            x = x + 1
        Next tx
        y = y + 1
    Next ty

End Sub

' Delete the tiles in the location indicated by the cursor.  This will only
' remove the tile from the topmost layer in each selected position.
Sub DeleteTile ()
    If resizeMode Then Exit Sub
    If GXMapIsometric Then
        DeleteTileIso
        Exit Sub
    End If

    Dim x As Integer, y As Integer, sx As Integer
    Dim tx As Integer, ty As Integer
    sx = Fix((_MouseX / scale - Control(Map).Left + GXSceneX) / GXTilesetWidth)
    y = Fix((_MouseY / scale - Control(Map).Top + GXSceneY) / GXTilesetHeight)

    For ty = tileSelStart.y To tileSelEnd.y
        x = sx
        For tx = tileSelStart.x To tileSelEnd.x
            If SelectedEditLayer = 0 Then
                GXMapTileRemove x, y
            Else
                GXMapTile x, y, SelectedEditLayer, 0
            End If
            x = x + 1
        Next tx
        y = y + 1
    Next ty
End Sub

Sub DeleteTileIso ()
    Dim x As Integer, y As Integer, sx As Integer
    Dim tx As Integer, ty As Integer
    Dim tile As Integer

    Dim tpos As GXPosition
    GetTilePosAt Map, _MouseX + GXSceneX * scale, _MouseY + GXSceneY * scale, tpos
    sx = tpos.x
    y = tpos.y

    For ty = tileSelStart.y To tileSelEnd.y
        x = sx
        For tx = tileSelStart.x To tileSelEnd.x
            tile = tx + tilesetPos.x + (ty + tilesetPos.y) * GXTilesetColumns + 1
            If SelectedEditLayer = 0 Then
                GXMapTileRemove x, y
            Else
                GXMapTile x, y, SelectedEditLayer, 0
            End If
            x = x + 1
        Next tx
        y = y + 1
    Next ty
End Sub


' Draw the selection cursor
Sub DrawCursor (id As Long)
    Dim cx As Integer, cy As Integer
    Dim endx As Integer, endy As Integer
    Dim tpos As GXPosition
    Dim ccolor As _Unsigned Long: ccolor = _RGB(255, 255, 255)
    Dim cstyle As Integer: cstyle = &B1010101010101010

    If id = Map Then

        ' Calculate the position of the map cursor
        GetTilePosAt id, _MouseX, _MouseY, tpos
        If Not GXMapIsometric Then
            cx = tpos.x * GXTilesetWidth
            cy = tpos.y * GXTilesetHeight
            ' Display the cursor as a single tile sized sqaure while resizing the
            ' current selection
            If Not mapSelSizing Then
                endx = (tpos.x + tileSelEnd.x - tileSelStart.x + 1) * GXTilesetWidth - 1
                endy = (tpos.y + tileSelEnd.y - tileSelStart.y + 1) * GXTilesetHeight - 1
            Else
                endx = cx + GXTilesetWidth - 1
                endy = cy + GXTilesetHeight - 1
            End If
            ' Draw the cursor
            Line (cx, cy)-(endx, endy), ccolor, B , cstyle
        Else
            Dim columnOffset As Long
            If tpos.y Mod 2 = 1 Then
                columnOffset = 0
            Else
                columnOffset = GXTilesetWidth / 2
            End If

            Dim rowOffset As Long
            rowOffset = (tpos.y + 1) * _Round(GXTilesetHeight - GXTilesetWidth / 4)

            Dim tx As Long: tx = tpos.x * GXTilesetWidth - columnOffset
            Dim ty As Long: ty = tpos.y * GXTilesetHeight - rowOffset

            Dim topY As Long: topY = ty + (GXTilesetHeight - GXTilesetWidth / 2)
            Dim midY As Long: midY = ty + (GXTilesetHeight - GXTilesetWidth / 4)
            Dim midX As Long: midX = tx + GXTilesetWidth / 2
            Dim rightX As Long: rightX = tx + GXTilesetWidth
            Dim bottomY As Long: bottomY = ty + GXTilesetHeight
            Dim halfWidth As Long: halfWidth = GXTilesetWidth / 2

            ccolor = _RGB(200, 200, 200)

            Line (tx, midY - halfWidth)-(tx, midY), ccolor, , cstyle
            Line (rightX, midY - halfWidth)-(rightX, midY), ccolor, , cstyle
            Line (midX, topY - halfWidth)-(midX, bottomY), ccolor, , cstyle

            Line (tx, midY - halfWidth)-(midX, topY - halfWidth), ccolor, , cstyle
            Line (midX, topY - halfWidth)-(rightX, midY - halfWidth), ccolor, , cstyle
            Line (rightX, midY - halfWidth)-(midX, bottomY - halfWidth), ccolor, , cstyle
            Line (midX, bottomY - halfWidth)-(tx, midY - halfWidth), ccolor, , cstyle

            Line (tx, midY)-(midX, topY), ccolor
            Line (midX, topY)-(rightX, midY), ccolor
            Line (rightX, midY)-(midX, bottomY), ccolor
            Line (midX, bottomY)-(tx, midY), ccolor
        End If

    Else 'id = Tileset
        ' Calculate the position of the tileset cursor
        GetTilePosAt id, _MouseX, _MouseY, tpos
        cx = tpos.x * GXTilesetWidth * tscale
        cy = tpos.y * GXTilesetHeight * tscale
        endx = cx + GXTilesetWidth * tscale - 1
        endy = cy + GXTilesetHeight * tscale - 1

        ' Draw the cursor
        Line (cx, cy)-(endx, endy), _RGB(255, 255, 255), B , &B1010101010101010
    End If

End Sub

' Get the tile position at the specified window coordinates
Sub GetTilePosAt (id As Long, x As Integer, y As Integer, tpos As GXPosition)
    If id = Map Then
        If Not GXMapIsometric Then
            x = x / scale - Control(id).Left
            y = y / scale - Control(id).Top
            tpos.x = Fix(x / GXTilesetWidth)
            tpos.y = Fix(y / GXTilesetHeight)
        Else
            x = x / scale - Control(id).Left
            y = y / scale - Control(id).Top

            Dim tileWidthHalf As Integer: tileWidthHalf = GXTilesetWidth / 2
            Dim tileHeightHalf As Integer: tileHeightHalf = GXTilesetWidth / 2
            Dim sx As Long: sx = x / tileWidthHalf

            Dim offset As Integer
            If sx Mod 2 = 1 Then
                offset = tileWidthHalf
            Else
                offset = 0
            End If

            tpos.y = (2 * y) / tileHeightHalf
            tpos.x = (x - offset) / GXTilesetWidth
        End If

    Else
        x = x - Control(id).Left
        y = y - Control(id).Top
        tpos.x = Fix(x / (GXTilesetWidth * tscale))
        tpos.y = Fix(y / (GXTilesetHeight * tscale))
    End If
End Sub

' Draw a bounding rectangle around the tile selection
Sub DrawSelected (id As Long)
    Dim startx As Integer, starty As Integer, endx As Integer, endy As Integer

    If id = Map Then
        ' Calculate the position of the map selection
        startx = tileSelStart.x * GXTilesetWidth
        starty = tileSelStart.y * GXTilesetHeight
        endx = tileSelEnd.x * GXTilesetWidth + GXTilesetWidth - 1
        endy = tileSelEnd.y * GXTilesetHeight + GXTilesetHeight - 1

    Else ' id = Tileset
        ' Calculate the position of the tileset selection
        Dim swidth As Integer, sheight As Integer
        swidth = GXTilesetWidth * tscale
        sheight = GXTilesetHeight * tscale
        startx = tileSelStart.x * swidth
        starty = tileSelStart.y * sheight
        endx = tileSelEnd.x * swidth + swidth - 1
        endy = tileSelEnd.y * sheight + sheight - 1
    End If

    ' Draw the selection rectangle
    Line (startx, starty)-(endx, endy), _RGB(255, 255, 0), B
End Sub

' Draw the tileset window
Sub DrawTileset
    Dim tcol As Integer, trow As Integer
    Dim tx As Integer, ty As Integer
    Dim totalTiles As Integer
    Dim xoffset As Integer
    Dim yoffset As Integer

    xoffset = -tilesetPos.x * GXTilesetWidth * tscale
    yoffset = -tilesetPos.y * GXTilesetHeight * tscale

    totalTiles = GXTilesetColumns * GXTilesetRows
    Dim img As Long
    img = GXTilesetImage

    BeginDraw Tiles
    Cls
    For trow = 1 To GXTilesetRows
        tx = 0
        For tcol = 1 To GXTilesetColumns
            GXSpriteDrawScaled img, tx + xoffset, ty + yoffset, GXTilesetWidth * tscale, GXTilesetHeight * tscale, trow, tcol, GXTilesetWidth, GXTilesetHeight, 0
            tx = tx + GXTilesetWidth * tscale
        Next tcol
        ty = ty + GXTilesetHeight * tscale
    Next trow

    ' draw a bounding rectangle around the border of the tileset
    tx = -tilesetPos.x * GXTilesetWidth * tscale
    ty = -tilesetPos.y * GXTilesetHeight * tscale
    Line (tx - 1, ty - 1)-(GXTilesetColumns * GXTilesetWidth * tscale + tx, GXTilesetRows * GXTilesetHeight * tscale + ty), _RGB(100, 100, 100), B


    If Not mapSelMode Then DrawSelected Tiles
    DrawTileFrameSelection
    DrawCursor Tiles

    EndDraw Tiles
End Sub

' Handle map click events
Sub OnMapClick
    If Not mapSelSizing Then
        PutTile
    Else
        mapSelSizing = False
        _MouseMove tileSelStart.x * GXTilesetWidth * scale, (tileSelStart.y + 2) * GXTilesetHeight * scale
    End If
End Sub

' Update the status bar message
Sub SetStatus (msg As String)
    SetCaption lblStatus, msg
End Sub

' Zoom the map view
Sub ZoomMap (amount As Integer)
    scale = scale + amount
    If scale < 0 Then scale = 1
    If scale > 4 Then scale = 4
    Control(MapMenuZoomOut).Disabled = False
    If scale = 1 Then Control(MapMenuZoomOut).Disabled = True
    If scale = 4 Then Control(MapMenuZoomIn).Disabled = True
    ResizeControls
End Sub

' Zoom the map view
Sub ZoomTileset (amount As Integer)
    tscale = tscale + amount
    If tscale < 0 Then tscale = 1
    If tscale > 4 Then tscale = 4
    Control(TilesetMenuZoomOut).Disabled = False
    If tscale = 1 Then Control(TilesetMenuZoomOut).Disabled = True
    If tscale = 4 Then Control(TilesetMenuZoomIn).Disabled = True
    ResizeControls
End Sub

Sub OnResizeMap
    resizeMode = True
    Control(frmResizeMap).Hidden = False
    Control(Tiles).Hidden = True
    Control(frmTile).Hidden = True
    Control(FileMenu).Hidden = True
    Control(MapMenu).Hidden = True
    Control(TilesetMenu).Hidden = True
    Control(txtResizeColumns).Value = GXMapColumns
    Control(txtResizeRows).Value = GXMapRows
End Sub

Sub CancelResizeMap
    resizeMode = False
    Control(frmResizeMap).Hidden = True
    Control(Tiles).Hidden = False
    Control(frmTile).Hidden = False
    Control(FileMenu).Hidden = False
    Control(MapMenu).Hidden = False
    Control(TilesetMenu).Hidden = False
End Sub

Sub ResizeMap
    GXMapResize Control(txtResizeColumns).Value, Control(txtResizeRows).Value
    CancelResizeMap
    SetStatus "Map resized."
End Sub

Sub OnChangeResize
    Dim columns As Long
    Dim rows As Long
    columns = Control(txtResizeColumns).Value
    rows = Control(txtResizeRows).Value

    If (columns > 0 And Not columns = GXMapColumns) Or (rows > 0 And Not rows = GXMapRows) Then
        Control(btnResizeMap).Disabled = False
    Else
        Control(btnResizeMap).Disabled = True
    End If
End Sub

' Resize the application controls
Sub ResizeControls
    ' Position tileset control
    Dim twidth As Integer
    twidth = GXTilesetColumns * GXTilesetWidth * tscale
    Dim maxwidth As Integer
    Dim minwidth As Integer
    minwidth = 300
    maxwidth = Control(MainForm).Width / 3
    If maxwidth < minwidth Then maxwidth = minwidth
    If twidth < minwidth Then
        twidth = minwidth
    ElseIf twidth >= maxwidth Then
        twidth = maxwidth
    End If
    Control(Tiles).Top = 23
    Control(Tiles).Width = twidth
    Control(Tiles).Left = Control(MainForm).Width - twidth
    Control(Tiles).Height = Control(MainForm).Height - 207
    LoadImage Control(Tiles), ""

    ' Position Tile Form
    Control(frmTile).Top = Control(MainForm).Height - 174
    Control(frmTile).Left = Control(Tiles).Left + 2
    Control(frmTile).Width = twidth - 6

    ' Position map control
    Control(Map).Left = 0
    Control(Map).Top = 23
    Control(Map).Width = Control(MainForm).Width - twidth - 1
    Control(Map).Height = Control(MainForm).Height - 80
    GXSceneResize Control(Map).Width / scale, Control(Map).Height / scale
    LoadImage Control(Map), ""
    Control(lblLayer).Top = Control(MainForm).Height - 53
    Control(cboLayer).Top = Control(MainForm).Height - 53
    Control(chkLayerHidden).Top = Control(MainForm).Height - 53
    Control(lblEditLayer).Top = Control(MainForm).Height - 53
    Control(cboEditLayer).Top = Control(MainForm).Height - 53
    Control(btnLayerAdd).Top = Control(MainForm).Height - 53
    Control(btnLayerRemove).Top = Control(MainForm).Height - 53
    Control(lblMapInfo).Top = Control(MainForm).Height - 53
    Control(lblMapInfo).Left = Control(Map).Width - Control(lblMapInfo).Width - 6

    ' Position status bar
    Control(lblStatus).Left = -1
    Control(lblStatus).Top = Control(MainForm).Height - 26
    Control(lblStatus).Width = Control(MainForm).Width + 2

    ResizeDialog frmNewMap
    ResizeDialog frmReplaceTileset
    ResizeDialog frmFile

    ' Resize the right panel dialog(s)
    Control(frmResizeMap).Top = 23
    Control(frmResizeMap).Width = twidth - 3
    Control(frmResizeMap).Left = Control(MainForm).Width - twidth + 1
    Control(frmResizeMap).Height = Control(MainForm).Height - 53
    Control(lblResizeSeparator).Width = twidth - 40
End Sub

Function GetControlAtMousePos
    Dim mx As Long, my As Long
    mx = _MouseX
    my = _MouseY

    GetControlAtMousePos = 0

IF mx > Control(Map).Left AND mx < Control(Map).Left + Control(Map).Width AND _
my > Control(Map).Top AND my < Control(Map).Top + Control(Map).Height THEN
        GetControlAtMousePos = Map

elseIF mx > Control(Tiles).Left AND mx < Control(Tiles).Left + Control(Tiles).Width AND _
my > Control(Tiles).Top AND my < Control(Tiles).Top + Control(Tiles).Height THEN
        GetControlAtMousePos = Tiles
    End If
End Function

Sub SetMapFilename (filename As String)
    mapFilename = filename
    mapLoaded = True

    If mapFilename <> "" Then
        _Title "GX Map Maker - " + GXFS_GetFilename(mapFilename)
    Else
        _Title "GX Map Maker - <New Map>"
    End If
End Sub

Sub ShowHelp
    Dim url As String
    url = "https://github.com/boxgaming/gx/wiki/Map-Maker"
    $If WIN Then
        Shell _DontWait _Hide "start " + url
    $ElseIf MAC Then
        Shell _DontWait _Hide "open " + url
    $ElseIf LINUX Then
        Shell _DontWait _Hide "xdg-open " + url
    $End If
End Sub

Sub ShowAbout
    Dim result
    result = MessageBox("GX Map Maker" + GX_LF + "v0.2.0-alpha" + GX_LF + GX_LF + Chr$(169) + "2021 boxgaming", "About", MsgBox_OkOnly + MsgBox_Information)
End Sub

' General Dialog Methods
' ----------------------------------------------------------------------------
Sub SetDialogMode (newDialogMode As Integer)
    dialogMode = newDialogMode
    Control(FileMenu).Hidden = dialogMode
    Control(MapMenu).Hidden = dialogMode
    Control(TilesetMenu).Hidden = dialogMode
    Control(Map).Hidden = dialogMode
    Control(Tiles).Hidden = dialogMode
    Control(lblLayer).Hidden = dialogMode
    Control(cboLayer).Hidden = dialogMode
    Control(lblMapInfo).Hidden = dialogMode
    Control(frmTile).Hidden = dialogMode
    If dialogMode = True Then
        Control(cboEditLayer).Hidden = True
        Control(lblEditLayer).Hidden = True
        Control(chkLayerHidden).Hidden = True
        Control(btnLayerAdd).Hidden = True
        Control(btnLayerRemove).Hidden = True
    ElseIf SelectedLayer = 0 Then
        Control(cboEditLayer).Hidden = False
        Control(lblEditLayer).Hidden = False
        Control(btnLayerAdd).Hidden = False
    ElseIf SelectedLayer > 0 Then
        Control(chkLayerHidden).Hidden = False
        Control(btnLayerAdd).Hidden = False
        Control(btnLayerRemove).Hidden = False
    End If

End Sub

Sub ResizeDialog (dialogId As Long)
    Control(dialogId).Left = 5
    Control(dialogId).Top = 15
    Control(dialogId).Width = Control(MainForm).Width - 10
    Control(dialogId).Height = Control(MainForm).Height - 45

    If dialogId = frmFile Then
        Control(btnFDOK).Top = Control(MainForm).Height - 85
        Control(btnFDCancel).Top = Control(MainForm).Height - 85
        Control(lstFDFiles).Height = Control(MainForm).Height - 200
        Control(lstFDPaths).Height = Control(MainForm).Height - 230
        Control(chkFDFilterExt).Top = Control(MainForm).Height - 125
    End If
    __UI_ForceRedraw = True
End Sub

Sub CancelDialog (dialogId As Long)
    SetStatus ""
    Control(dialogId).Hidden = True
    SetDialogMode False
End Sub

Sub ShowNewMapDialog
    SetDialogMode True
    Control(txtColumns).Value = 0
    Control(txtRows).Value = 0
    Control(txtLayers).Value = 1
    Text(txtTilesetImage) = ""
    Control(txtTileWidth).Value = 0
    Control(txtTileHeight).Value = 0
    Control(tglIsometric).Value = False
    Control(frmNewMap).Hidden = False
    _MouseShow
End Sub

Sub ShowReplaceTilesetDialog
    dialogMode = True
    Control(frmReplaceTileset).Hidden = False
    Control(txtRTTileWidth).Value = GXTilesetWidth
    Control(txtRTTileHeight).Value = GXTilesetHeight
    SetDialogMode True
    _MouseShow
End Sub

' File Dialog Methods
' ----------------------------------------------------------------------------
Sub ShowFileDialog (mode As Integer, targetForm As Long)
    SetDialogMode (True)

    fileDialogMode = mode
    fileDialogTargetForm = targetForm
    If fileDialogTargetForm <> MainForm Then
        Control(fileDialogTargetForm).Hidden = True
    End If

    If fileDialogMode = FD_OPEN Then
        SetCaption frmFile, "Open"
    Else
        SetCaption frmFile, "Save"
    End If

    Text(txtFDFilename) = ""
    Control(frmFile).Hidden = False

    RefreshFileDialog
End Sub

Sub EnableFileDialog (enabled As Integer)
    Dim disabled As Integer
    disabled = Not enabled
    Control(txtFDFilename).Disabled = disabled
    Control(lstFDFiles).Disabled = disabled
    Control(lstFDPaths).Disabled = disabled
    Control(chkFDFilterExt).Disabled = disabled
    Control(btnFDOK).Disabled = disabled
    Control(btnFDCancel).Disabled = disabled
End Sub

Sub RefreshFileDialog
    Dim i As Integer
    Dim path As String
    Dim fitems(0) As String

    ' Set the last selected path
    SetCaption lblFDPathValue, fileDialogPath

    path = fileDialogPath

    ' Refresh the folder list
    ResetList lstFDPaths
    If GXFS_IsDriveLetter(path) Then
        path = path + GXFS_PathSeparator
    Else
        AddItem lstFDPaths, ".."
    End If
    For i = 1 To GXFS_DirList(path, True, fitems())
        AddItem lstFDPaths, fitems(i)
    Next i
    For i = 1 To GXFS_DriveList(fitems())
        AddItem lstFDPaths, fitems(i)
    Next i

    ' Refresh the file list
    RefreshFileList
End Sub

Sub RefreshFileList
    Dim i As Integer
    Dim path As String
    Dim fitems(0) As String

    path = fileDialogPath

    If GXFS_IsDriveLetter(path) Then path = path + GXFS_PathSeparator

    ' Refresh the folder list
    ResetList lstFDFiles
    For i = 1 To GXFS_DirList(path, False, fitems())
        If Not Control(chkFDFilterExt).Value Or ExtFilterMatch(fitems(i)) Then
            AddItem lstFDFiles, fitems(i)
        End If
    Next i
End Sub

Function ExtFilterMatch (filename As String)
    Dim match As Integer
    Dim ext As String
    ext = UCase$(GXFS_GetFileExtension(filename))

    If fileDialogTargetForm = MainForm Then
        If ext = "GXM" Or ext = "MAP" Then match = True
    Else
        If ext = "PNG" Or ext = "BMP" Or ext = "GIF" Or ext = "BMP" Or ext = "JPG" Or ext = "JPEG" Then match = True
    End If

    ExtFilterMatch = match
End Function

Sub OnChangeDirectory
    ' Change current path
    Dim dir As String
    dir = GetItem(lstFDPaths, Control(lstFDPaths).Value)
    If dir = ".." Then
        fileDialogPath = GXFS_GetParentPath(fileDialogPath)
    ElseIf GXFS_IsDriveLetter(dir) Then
        fileDialogPath = dir
    ElseIf fileDialogPath = GXFS_PathSeparator Then
        fileDialogPath = GXFS_PathSeparator + dir
    Else
        fileDialogPath = fileDialogPath + GXFS_PathSeparator + dir
    End If
    RefreshFileDialog
End Sub

Sub OnSelectFile
    Dim msgRes As Integer
    Dim filename As String
    filename = Text(txtFDFilename)

    If filename = "" Then
        msgRes = MessageBox("Please select a file.", "No File Selection", MsgBox_OkOnly + MsgBox_Exclamation)
        Exit Sub
    End If

    filename = fileDialogPath + GXFS_PathSeparator + filename

    If fileDialogMode = FD_OPEN Then
        If Not _FileExists(filename) Then
            msgRes = MessageBox("The specified file was not found.", "File Not Found", MsgBox_OkOnly + MsgBox_Exclamation)
            Exit Sub
        End If

        Select Case fileDialogTargetForm

            Case MainForm
                LoadMap filename

            Case frmNewMap
                Text(txtTilesetImage) = filename
                Control(frmNewMap).Hidden = False
                Control(frmFile).Hidden = True

            Case frmReplaceTileset
                Text(txtRTTilesetImage) = filename
                Control(frmReplaceTileset).Hidden = False
                Control(frmFile).Hidden = True

        End Select

    Else 'FD_SAVE
        Select Case fileDialogTargetForm
            Case MainForm:
                If _FileExists(filename) Then
                    msgRes = MessageBox("File exists, overwrite existing file?", "File Exists", MsgBox_YesNo + MsgBox_Question)
                    If msgRes = MsgBox_No Then Exit Sub
                End If

                SaveMap filename
        End Select
    End If

End Sub

' Handle file list click events
Sub OnFileListClick (id As Long)
    Text(txtFDFilename) = GetItem(lstFDFiles, Control(lstFDFiles).Value)
    If lastControlClicked = id And Timer - lastClick < .3 Then ' Double-click
        OnSelectFile
    End If
End Sub

' Handle path list click events
Sub OnPathListClick (id As Long)
    If lastControlClicked = id And Timer - lastClick < .3 Then ' Double-click
        OnChangeDirectory
    End If
End Sub


'$Include:'../gx/gx.bm'
