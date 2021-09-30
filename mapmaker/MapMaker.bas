OPTION _EXPLICIT
$EXEICON:'./../gx/resource/gx.ico'
'$INCLUDE:'../gx/gx.bi'

CONST FD_OPEN = 1
CONST FD_SAVE = 2

DIM SHARED scale AS INTEGER '             - Scale used to apply zoom level to map
DIM SHARED tscale AS INTEGER '            - Scale used to apply zoom level to tileset
DIM SHARED gxloaded AS INTEGER '          - Indicates when the GX engine is initialized
DIM SHARED mapLoaded AS INTEGER '         - True when a map is currently loaded
DIM SHARED mapFilename AS STRING '        - Name of the map file currently loaded
DIM SHARED tilesetPos AS GXPosition '     - Tileset screen position for scrolling the tileset window
DIM SHARED tileSelStart AS GXPosition '   - Tile selection start position
DIM SHARED tileSelEnd AS GXPosition '     - Tile selection end position
DIM SHARED tileSelSizing AS INTEGER '     - Tile selection sizing flag
DIM SHARED mapSelSizing AS INTEGER '      - Map selection sizing flag
DIM SHARED mapSelMode AS INTEGER '        - Map selection mode (True=map, False=tileset)
DIM SHARED saving AS INTEGER '            - Set to True when the map is currently being saved
DIM SHARED deleting AS INTEGER '          - When true the delete key is pressed but not yet released
DIM SHARED dialogMode AS INTEGER '        - Indicates whethere a dialog is currently being displayed
DIM SHARED fileDialogMode AS INTEGER '    - Type of file dialog opened (Open, Save)
DIM SHARED fileDialogPath AS STRING '     - Current/last path selected in the file dialog
DIM SHARED fileDialogTargetForm AS LONG ' - Control which opened the file dialog
DIM SHARED lastControlClicked AS LONG '   - Used for capturing double-click events
DIM SHARED lastClick AS DOUBLE '          - Used for capturing double-click events
DIM SHARED animationMode AS INTEGER
DIM SHARED resizeMode AS INTEGER
REDIM SHARED hiddenLayers(0) AS INTEGER


': This program uses
': InForm - GUI library for QB64 - v1.2
': Fellippe Heitor, 2016-2020 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------
' Menus and Menu Items
DIM SHARED MainForm AS LONG
DIM SHARED FileMenu AS LONG
DIM SHARED FileMenuNew AS LONG
DIM SHARED FileMenuOpen AS LONG
DIM SHARED FileMenuSave AS LONG
DIM SHARED FileMenuSaveAs AS LONG
DIM SHARED FileMenuExit AS LONG
DIM SHARED MapMenu AS LONG
DIM SHARED MapMenuZoomIn AS LONG
DIM SHARED MapMenuZoomOut AS LONG
DIM SHARED MapMenuResize AS LONG
DIM SHARED TilesetMenu AS LONG
DIM SHARED TilesetMenuReplace AS LONG
DIM SHARED TilesetMenuZoomIn AS LONG
DIM SHARED TilesetMenuZoomOut AS LONG

' Map control
DIM SHARED Map AS LONG
DIM SHARED lblLayer AS LONG
DIM SHARED lblEditLayer AS LONG
DIM SHARED cboLayer AS LONG
DIM SHARED cboEditLayer AS LONG
DIM SHARED chkLayerHidden AS LONG
DIM SHARED lblMapInfo AS LONG
DIM SHARED btnLayerAdd AS LONG
DIM SHARED btnLayerRemove AS LONG

' Tile control
DIM SHARED Tiles AS LONG
DIM SHARED frmTile AS LONG
DIM SHARED lblTileId AS LONG
DIM SHARED lblTileIdValue AS LONG
DIM SHARED lblTileAnimated AS LONG
DIM SHARED tglTileAnimate AS LONG
DIM SHARED lblTileAnimationSpeed AS LONG
DIM SHARED txtTileAnimationSpeed AS LONG
DIM SHARED lblTileFrames AS LONG
DIM SHARED lstTileFrames AS LONG
DIM SHARED btnTileAddFrame AS LONG

' Tile Frame Context Menu
DIM SHARED TileFrameMenu AS LONG
DIM SHARED TileFrameMenuRemove AS LONG

' Status bar
DIM SHARED lblStatus AS LONG

' New Map Dialog
DIM SHARED frmNewMap AS LONG
DIM SHARED lblColumns AS LONG
DIM SHARED txtColumns AS LONG
DIM SHARED lblRows AS LONG
DIM SHARED txtRows AS LONG
DIM SHARED lblLayers AS LONG
DIM SHARED txtLayers AS LONG
DIM SHARED lblTilesetImage AS LONG
DIM SHARED txtTilesetImage AS LONG
DIM SHARED btnSelectTilesetImage AS LONG
DIM SHARED lblTileHeight AS LONG
DIM SHARED txtTileHeight AS LONG
DIM SHARED lblTileWidth AS LONG
DIM SHARED txtTileWidth AS LONG
DIM SHARED lblIsometric AS LONG
DIM SHARED tglIsometric AS LONG
DIM SHARED lblLine AS LONG
DIM SHARED btnCreateMap AS LONG
DIM SHARED btnCancel AS LONG

' Replace Tileset Dialog
DIM SHARED frmReplaceTileset AS LONG
DIM SHARED lblRTTileWidth AS LONG
DIM SHARED txtRTTileWidth AS LONG
DIM SHARED lblRTTileHeight AS LONG
DIM SHARED txtRTTileHeight AS LONG
DIM SHARED lblRTTilesetImage AS LONG
DIM SHARED txtRTTilesetImage AS LONG
DIM SHARED btnRTSelectTilesetImage AS LONG
DIM SHARED lblRTLine AS LONG
DIM SHARED btnRTReplaceImage AS LONG
DIM SHARED btnRTCancel AS LONG

' Resize Map Dialog
DIM SHARED frmResizeMap AS LONG
DIM SHARED lblResizeColumns AS LONG
DIM SHARED lblResizeRows AS LONG
DIM SHARED txtResizeColumns AS LONG
DIM SHARED txtResizeRows AS LONG
DIM SHARED lblResizeSeparator AS LONG
DIM SHARED btnResizeMap AS LONG
DIM SHARED btnResizeCancel AS LONG

' File Dialog
DIM SHARED frmFile AS LONG
DIM SHARED lblFDFilename AS LONG
DIM SHARED txtFDFilename AS LONG
DIM SHARED lblFDPath AS LONG
DIM SHARED lblFDPathValue AS LONG
DIM SHARED lblFDFiles AS LONG
DIM SHARED lblFDPaths AS LONG
DIM SHARED lstFDFiles AS LONG
DIM SHARED lstFDPaths AS LONG
DIM SHARED chkFDFilterExt AS LONG
DIM SHARED btnFDOK AS LONG
DIM SHARED btnFDCancel AS LONG


': External modules: ---------------------------------------------------------------
'$INCLUDE: './inform/InForm.ui'
'$INCLUDE: './inform/xp.uitheme'
'$INCLUDE: 'MapMaker.frm'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit
END SUB

SUB __UI_OnLoad
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

    IF INSTR(COMMAND$, ".map") OR INSTR(COMMAND$, ".gxm") THEN
        LoadMap COMMAND$
    END IF
END SUB

SUB __UI_BeforeUpdateDisplay
    IF gxloaded = False THEN EXIT SUB ' We're not ready yet, abort!
    IF dialogMode = True THEN EXIT SUB ' Nothing to do here

    IF mapFilename <> "" THEN
        _TITLE "GX Map Maker - " + GXFS_GetFilename(mapFilename)
    ELSEIF mapLoaded THEN
        _TITLE "GX Map Maker - <New Map>"
    END IF


    DIM mc AS LONG
    mc = GetControlAtMousePos

    DIM tsHeight AS INTEGER
    IF GXMapIsometric THEN
        tsHeight = GXTilesetWidth / 2
    ELSE
        tsHeight = GXTilesetHeight
    END IF

    ' Use WASD or arrow keys to navigate around the map or tileset
    IF GXKeyDown(GXKEY_S) OR GXKeyDown(GXKEY_DOWN) THEN ' move down
        IF mc = Map THEN
            GXSceneMove 0, tsHeight 'GXTilesetHeight
        ELSEIF mc = Tiles THEN
            tilesetPos.y = tilesetPos.y + 1
        END IF
        IF (mapSelMode AND mc = Map) OR (NOT mapSelMode AND mc = Tiles) THEN
            tileSelStart.y = tileSelStart.y - 1: tileSelEnd.y = tileSelEnd.y - 1
        END IF

    ELSEIF GXKeyDown(GXKEY_W) OR GXKeyDown(GXKEY_UP) THEN ' move up
        IF mc = Map THEN
            GXSceneMove 0, -tsHeight '-GXTilesetHeight
        ELSEIF mc = Tiles THEN
            tilesetPos.y = tilesetPos.y - 1
        END IF
        IF (mapSelMode AND mc = Map) OR (NOT mapSelMode AND mc = Tiles) THEN
            tileSelStart.y = tileSelStart.y + 1: tileSelEnd.y = tileSelEnd.y + 1
        END IF

    ELSEIF GXKeyDown(GXKEY_D) OR GXKeyDown(GXKEY_RIGHT) THEN ' move right
        IF mc = Map THEN
            GXSceneMove GXTilesetWidth, 0
        ELSEIF mc = Tiles THEN
            tilesetPos.x = tilesetPos.x + 1
        END IF
        IF (mapSelMode AND mc = Map) OR (NOT mapSelMode AND mc = Tiles) THEN
            tileSelStart.x = tileSelStart.x - 1: tileSelEnd.x = tileSelEnd.x - 1
        END IF

    ELSEIF GXKeyDown(GXKEY_A) OR GXKeyDown(GXKEY_LEFT) THEN ' move left
        IF mc = Map THEN
            GXSceneMove -GXTilesetWidth, 0
        ELSEIF mc = Tiles THEN
            tilesetPos.x = tilesetPos.x - 1
        END IF
        IF (mapSelMode AND mc = Map) OR (NOT mapSelMode AND mc = Tiles) THEN
            tileSelStart.x = tileSelStart.x + 1: tileSelEnd.x = tileSelEnd.x + 1
        END IF
    END IF

    ' Adjust the current selection if selection sizing is in progress
    IF tileSelSizing THEN
        'GetTilePosAt Tiles, _MOUSEX, _MOUSEY, tscale, tileSelEnd
        GetTilePosAt Tiles, _MOUSEX, _MOUSEY, tileSelEnd
    ELSEIF mapSelSizing THEN
        'GetTilePosAt Map, _MOUSEX, _MOUSEY, scale, tileSelEnd
        GetTilePosAt Map, _MOUSEX, _MOUSEY, tileSelEnd
    END IF

    ' If X or DEL key is pressed, delete the tiles in the current selection
    IF GXKeyDown(GXKEY_DELETE) OR GXKeyDown(GXKEY_X) THEN deleting = 1
    IF NOT (GXKeyDown(GXKEY_X) OR GXKeyDown(GXKEY_X)) AND deleting THEN DeleteTile: deleting = 0

    ' Draw the map
    GXSceneUpdate
    GXSceneDraw

    ' Draw the tileset
    DrawTileset
END SUB

SUB __UI_BeforeUnload
    ' If the user is in the process of saving the map
    ' prevent the application from closing
    IF saving THEN __UI_UnloadSignal = False
END SUB

SUB __UI_Click (id AS LONG)

    SELECT CASE id

        CASE Map: OnMapClick

        CASE FileMenuNew: ShowNewMapDialog
        CASE FileMenuOpen: ShowFileDialog FD_OPEN, MainForm
        CASE FileMenuSave: SaveMap mapFilename
        CASE FileMenuSaveAs: ShowFileDialog FD_SAVE, MainForm
        CASE FileMenuExit: SYSTEM 0

        CASE MapMenuZoomIn: ZoomMap 1
        CASE MapMenuZoomOut: ZoomMap -1

        CASE MapMenuResize: OnResizeMap
        CASE btnResizeCancel: CancelResizeMap
        CASE btnResizeMap: ResizeMap

        CASE TilesetMenuZoomIn: ZoomTileset 1
        CASE TilesetMenuZoomOut: ZoomTileset -1
        CASE TilesetMenuReplace: ShowReplaceTilesetDialog

        CASE btnCancel: CancelDialog frmNewMap
        CASE btnRTCancel: CancelDialog frmReplaceTileset
        CASE btnFDCancel: CancelDialog frmFile
        CASE btnCreateMap: CreateMap
        CASE btnRTReplaceImage: ReplaceTileset
        CASE btnSelectTilesetImage: ShowFileDialog FD_OPEN, frmNewMap
        CASE btnRTSelectTilesetImage: ShowFileDialog FD_OPEN, frmReplaceTileset
        CASE btnFDOK: OnSelectFile
        CASE btnLayerAdd: OnLayerAdd
        CASE btnLayerRemove: OnLayerRemove

        CASE lstFDFiles: OnFileListClick id
        CASE lstFDPaths: OnPathListClick id

        CASE btnTileAddFrame: OnTileFrameAdd

    END SELECT

    lastControlClicked = id
    lastClick = TIMER
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE Map: IF NOT dialogMode AND mapLoaded THEN _MOUSEHIDE
        CASE Tiles: IF NOT dialogMode AND mapLoaded THEN _MOUSEHIDE
    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE Map: _MOUSESHOW
        CASE Tiles: _MOUSESHOW
    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id

        CASE Map
            ' If the SHIFT key is pressed while clicking the map
            ' start resizing the selection cursor
            IF (GXKeyDown(GXKEY_LSHIFT) OR GXKeyDown(GXKEY_RSHIFT)) AND NOT GXMapIsometric THEN
                mapSelMode = True
                mapSelSizing = True
                '                GetTilePosAt Map, _MOUSEX, _MOUSEY, scale, tileSelStart
                GetTilePosAt Map, _MOUSEX, _MOUSEY, tileSelStart
                tileSelEnd = tileSelStart
            END IF


        CASE Tiles
            ' If we detect a mouse down event on the tileset control
            ' start resizing the tileset selection cursor
            mapSelMode = False
            tileSelSizing = True
            'GetTilePosAt Tiles, _MOUSEX, _MOUSEY, tscale, tileSelStart
            GetTilePosAt Tiles, _MOUSEX, _MOUSEY, tileSelStart
            tileSelEnd = tileSelStart

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE Tiles
            tileSelSizing = False
            OnTileSelection
        CASE tglTileAnimate: OnChangeTileAnimate
    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
        CASE txtTileAnimationSpeed: OnChangeTileAnimationSpeed
        CASE txtResizeColumns: OnChangeResize
        CASE txtResizeRows: OnChangeResize
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE chkFDFilterExt: RefreshFileList
        CASE cboLayer: OnChangeLayer
        CASE chkLayerHidden: OnChangeLayerHidden
    END SELECT
END SUB

SUB __UI_FormResized
    ' The window has been resized so resize the child components accordingly
    ResizeControls
END SUB


' GX Events
' ----------------------------------------------------------------------------
SUB GXOnGameEvent (e AS GXEvent)
    IF e.event = GXEVENT_PAINTBEFORE THEN BeginDraw Map
    IF e.event = GXEVENT_PAINTAFTER THEN EndDraw Map
    IF e.event = GXEVENT_DRAWSCREEN THEN
        IF mapSelMode THEN DrawSelected Map
        DrawMapBorder
        DrawCursor Map
    END IF
END SUB

SUB DrawMapBorder
    ' draw a bounding rectangle around the border of the map
    DIM bheight AS LONG
    DIM bwidth AS LONG
    DIM rwidth AS LONG
    DIM rheight AS LONG
    IF GXMapIsometric THEN
        bheight = (GXMapRows - 1) * (GXTilesetWidth / 4)
        bwidth = GXMapColumns * GXTilesetWidth - (GXTilesetWidth / 2)
        rheight = (Control(txtResizeRows).Value - 1) * (GXTilesetWidth / 4)
        rwidth = Control(txtResizeColumns).Value * GXTilesetWidth - (GXTilesetWidth / 2)
    ELSE
        bheight = GXMapRows * GXTilesetHeight
        bwidth = GXMapColumns * GXTilesetWidth
        rheight = Control(txtResizeRows).Value * GXTilesetHeight
        rwidth = Control(txtResizeColumns).Value * GXTilesetWidth
    END IF

    LINE (-GXSceneX - 1, -GXSceneY - 1)-(bwidth - GXSceneX, bheight - GXSceneY), _RGB(100, 100, 100), B
    IF resizeMode THEN
        LINE (-GXSceneX - 1, -GXSceneY - 1)-(rwidth - GXSceneX, rheight - GXSceneY), _RGB(255, 255, 100), B
    END IF
END SUB

' Create a new map from the parameters specified by the user on the new map dialog.
SUB CreateMap
    SetStatus "Creating new map..."
    DIM columns AS INTEGER, rows AS INTEGER, layers AS INTEGER
    DIM tilesetImage AS STRING
    DIM tileWidth AS INTEGER, tileHeight AS INTEGER
    DIM isometric AS INTEGER
    DIM msgRes AS INTEGER

    columns = Control(txtColumns).Value
    rows = Control(txtRows).Value
    layers = Control(txtLayers).Value
    tilesetImage = Text(txtTilesetImage)
    tileWidth = Control(txtTileWidth).Value
    tileHeight = Control(txtTileHeight).Value
    isometric = Control(tglIsometric).Value

    IF columns < 1 THEN msgRes = MessageBox("Map must have at least 1 column.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF rows < 1 THEN msgRes = MessageBox("Map must have at least 1 row.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF layers < 1 THEN msgRes = MessageBox("Map must have at least 1 layer.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tilesetImage = "" THEN msgRes = MessageBox("Please select a tileset image.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tileWidth < 1 THEN msgRes = MessageBox("Tile width must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tileHeight < 1 THEN msgRes = MessageBox("Tile height must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): EXIT SUB

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

    REDIM hiddenLayers(layers) AS INTEGER

    SetDialogMode False
    mapLoaded = True

    RefreshLayerDropdown
    RefreshMapInfo
    OnTileSelection
    ResizeControls
    SetStatus "Map created."
    '_TITLE "GX Map Maker - <New Map>"
END SUB

' Load the map at the specified file location
SUB LoadMap (filename AS STRING)
    SetStatus "Loading map..."

    EnableFileDialog False
    GXMapLoad filename
    mapFilename = filename
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
    mapLoaded = True
    scale = 1
    tscale = 1

    REDIM hiddenLayers(GXMapLayers) AS INTEGER

    Control(frmFile).Hidden = True
    SetDialogMode False
    EnableFileDialog True

    RefreshLayerDropdown
    RefreshMapInfo
    OnTileSelection
    ResizeControls
    SetStatus "Map loaded."
    '_TITLE "GX Map Maker - " + __GXFS_GetFilename(filename)
END SUB

' Save the current map date to the specified file location
SUB SaveMap (filename AS STRING)
    SetStatus "Saving map..."
    EnableFileDialog False

    saving = 1
    GXMapSave filename
    saving = 0
    mapFilename = filename
    Control(FileMenuSave).Disabled = False

    Control(frmFile).Hidden = True
    SetDialogMode False
    EnableFileDialog True

    SetStatus "Map saved."
    '_TITLE "GX Map Maker - " + __GXFS_GetFilename(filename)
END SUB

SUB OnTileSelection
    IF tileSelStart.x = tileSelEnd.x AND tileSelStart.y = tileSelEnd.y THEN
        DIM tile
        tile = tileSelStart.x + tilesetPos.x + (tileSelStart.y + tilesetPos.y) * GXTilesetColumns + 1

        IF animationMode THEN
            DIM animationSpeed AS INTEGER
            GXTilesetAnimationAdd SelectedTile, tile
            RefreshTileFrameList
            animationMode = False
        ELSE
            ClearTileForm
            Caption(lblTileIdValue) = STR$(tile)
            Control(tglTileAnimate).Value = (GXTilesetAnimationSpeed(tile) > 0)
            Control(frmTile).Disabled = False
            Control(lblTileId).Disabled = False
            Control(lblTileIdValue).Disabled = False
            Control(lblTileAnimated).Disabled = False
            Control(tglTileAnimate).Disabled = False
            IF Control(tglTileAnimate).Value = True THEN
                Text(txtTileAnimationSpeed) = STR$(GXTilesetAnimationSpeed(tile))
                Control(lblTileAnimationSpeed).Disabled = False
                Control(txtTileAnimationSpeed).Disabled = False
                Control(lblTileFrames).Disabled = False
                Control(lstTileFrames).Disabled = False
                Control(btnTileAddFrame).Disabled = False
            END IF
            RefreshTileFrameList
        END IF
    ELSE
        ClearTileForm
    END IF
END SUB

FUNCTION SelectedTile
    SelectedTile = VAL(Caption(lblTileIdValue))
END FUNCTION

SUB DrawTileFrameSelection
    IF SelectedTile = 0 THEN EXIT SUB

    DIM tileFrames(0) AS INTEGER, frameCount AS INTEGER, i AS INTEGER
    frameCount = GXTilesetAnimationFrames(SelectedTile, tileFrames())
    FOR i = 1 TO frameCount
        DIM tpos AS GXPosition
        GXTilesetPos tileFrames(i), tpos

        ' Calculate the position of the tileset selection
        DIM swidth AS INTEGER, sheight AS INTEGER
        DIM startx AS INTEGER, starty AS INTEGER, endx AS INTEGER, endy AS INTEGER
        swidth = GXTilesetWidth * tscale
        sheight = GXTilesetHeight * tscale
        startx = (tpos.x - tilesetPos.x - 1) * swidth
        starty = (tpos.y - tilesetPos.y - 1) * sheight
        endx = (tpos.x - tilesetPos.x - 1) * swidth + swidth - 1
        endy = (tpos.y - tilesetPos.y - 1) * sheight + sheight - 1

        ' Draw the selection rectangle
        LINE (startx, starty)-(endx, endy), _RGB(0, 0, 255), B ', &B1010101010101010
    NEXT i
END SUB

SUB ClearTileForm
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
END SUB

SUB OnChangeTileAnimate
    'DIM r: r = MessageBox("animate change", "", MsgBox_OkOnly)
    IF Control(tglTileAnimate).Value = False THEN
        Control(lblTileAnimationSpeed).Disabled = False
        Control(txtTileAnimationSpeed).Disabled = False
        Control(btnTileAddFrame).Disabled = False
        Control(lblTileFrames).Disabled = False
        Control(lstTileFrames).Disabled = False

        DIM animationSpeed AS INTEGER
        animationSpeed = 5
        Control(txtTileAnimationSpeed).Value = animationSpeed
        GXTilesetAnimationCreate SelectedTile, animationSpeed
        RefreshTileFrameList
    ELSE
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
    END IF
END SUB

SUB OnChangeTileAnimationSpeed
    GXTilesetAnimationSpeed SelectedTile, VAL(Text(txtTileAnimationSpeed))
END SUB

SUB OnTileFrameAdd
    animationMode = True
END SUB


SUB RefreshTileFrameList
    DIM tileFrames(0) AS INTEGER, frameCount AS INTEGER
    frameCount = GXTilesetAnimationFrames(SelectedTile, tileFrames())

    ResetList lstTileFrames
    DIM i AS INTEGER
    FOR i = 1 TO frameCount
        AddItem lstTileFrames, GXSTR_LPad(STR$(i), "0", 2) + ": " + STR$(tileFrames(i))
    NEXT i
END SUB

' Replace the current tileset with one specified by the user on the replace
' tileset dialog.
SUB ReplaceTileset
    DIM tilesetImage AS STRING
    DIM tileWidth AS INTEGER, tileHeight AS INTEGER
    DIM msgRes AS INTEGER

    tilesetImage = Text(txtRTTilesetImage)
    tileWidth = Control(txtRTTileWidth).Value
    tileHeight = Control(txtRTTileHeight).Value

    IF tilesetImage = "" THEN msgRes = MessageBox("Please select a tileset image.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tileWidth < 1 THEN msgRes = MessageBox("Tile width must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tileHeight < 1 THEN msgRes = MessageBox("Tile height must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): EXIT SUB

    'GXTilesetCreate tilesetImage, tileWidth, tileHeight
    GXTilesetReplaceImage tilesetImage, tileWidth, tileHeight
    Control(frmReplaceTileset).Hidden = True

    SetDialogMode False
END SUB

SUB RefreshLayerDropdown
    DIM i AS INTEGER
    ResetList cboLayer
    ResetList cboEditLayer
    AddItem cboLayer, "All"
    AddItem cboEditLayer, "All"
    FOR i = 1 TO GXMapLayers
        AddItem cboLayer, STR$(i)
        AddItem cboEditLayer, STR$(i)
    NEXT i
    Control(cboLayer).Disabled = False
    Control(lblLayer).Disabled = False
    Control(cboEditLayer).Disabled = False
    Control(lblEditLayer).Disabled = False
    Control(chkLayerHidden).Disabled = False
    Control(cboLayer).Value = 1
    Control(cboEditLayer).Value = 1
END SUB

SUB RefreshMapInfo
    Caption(lblMapInfo) = _TRIM$(STR$(GXMapColumns)) + "x" + _TRIM$(STR$(GXMapRows))
END SUB

FUNCTION SelectedLayer
    SelectedLayer = Control(cboLayer).Value - 1
END FUNCTION

FUNCTION SelectedEditLayer
    SelectedEditLayer = SelectedLayer
    IF SelectedEditLayer = 0 THEN
        SelectedEditLayer = Control(cboEditLayer).Value - 1
    END IF
END FUNCTION

SUB OnChangeLayerHidden
    IF SelectedLayer = 0 THEN EXIT SUB
    DIM selected AS INTEGER
    selected = Control(chkLayerHidden).Value
    IF selected = True THEN
        hiddenLayers(SelectedLayer) = 1
    ELSE
        hiddenLayers(SelectedLayer) = 0
    END IF
END SUB

SUB OnChangeLayer
    DIM layer AS INTEGER
    layer = SelectedLayer

    IF layer = 0 THEN
        Control(chkLayerHidden).Hidden = True
        Control(lblEditLayer).Hidden = False
        Control(cboEditLayer).Hidden = False
        Control(btnLayerAdd).Hidden = False
        ToolTip(btnLayerAdd) = "Add a new layer to the map"
        Control(btnLayerRemove).Hidden = True
    ELSE
        Control(chkLayerHidden).Hidden = False
        Control(lblEditLayer).Hidden = True
        Control(cboEditLayer).Hidden = True
        Control(btnLayerAdd).Hidden = False
        ToolTip(btnLayerAdd) = "Insert a new layer before the currently selected layer"
        Control(btnLayerRemove).Hidden = False

        IF (hiddenLayers(layer) = 0) THEN
            Control(chkLayerHidden).Value = False
        ELSE
            Control(chkLayerHidden).Value = True
        END IF
    END IF

    DIM i AS INTEGER
    FOR i = 1 TO GXMapLayers
        IF (layer = 0 AND hiddenLayers(i) = 0) OR layer = i THEN
            GXMapLayerVisible i, True
        ELSE
            GXMapLayerVisible i, False
        END IF
    NEXT i
END SUB

SUB OnLayerAdd
    REDIM _PRESERVE hiddenLayers(GXMapLayers + 1) AS INTEGER
    IF SelectedLayer = 0 THEN
        GXMapLayerAdd
        SetStatus "New layer added."
    ELSE
        GXMapLayerInsert SelectedLayer
        SetStatus "New layer inserted."
    END IF
    RefreshLayerDropdown
END SUB

SUB OnLayerRemove
    IF SelectedLayer = 1 AND GXMapLayers < 2 THEN EXIT SUB

    REDIM _PRESERVE hiddenLayers(GXMapLayers - 1) AS INTEGER
    GXMapLayerRemove SelectedLayer
    SetStatus "Layer removed."
    RefreshLayerDropdown
END SUB


' Place selected tiles in the location indicated by the cursor.  The tile
' selection can be made either in the tileset window or from another location
' on the map.
SUB PutTile ()
    IF resizeMode THEN EXIT SUB
    IF GXMapIsometric THEN
        PutTileIso
        EXIT SUB
    END IF

    DIM x AS INTEGER, y AS INTEGER, sx AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    DIM mtx AS INTEGER, mty AS INTEGER
    DIM tile AS INTEGER

    sx = FIX((_MOUSEX / scale - Control(Map).Left + GXSceneX) / GXTilesetWidth)
    y = FIX((_MOUSEY / scale - Control(Map).Top + GXSceneY) / GXTilesetHeight)

    FOR ty = tileSelStart.y TO tileSelEnd.y
        x = sx
        FOR tx = tileSelStart.x TO tileSelEnd.x
            IF mapSelMode THEN
                ' select the tile from the top layer of the map selection position
                mtx = tx + GXSceneX / GXTilesetWidth
                mty = ty + GXSceneY / GXTilesetHeight
                IF SelectedEditLayer = 0 THEN
                    tile = GXMapTile(mtx, mty, GXMapTileDepth(mtx, mty))
                ELSE
                    tile = GXMapTile(mtx, mty, SelectedEditLayer)
                END IF
            ELSE
                ' calculate the tile id from the current selection position
                'tile = tx + ty * GXTilesetColumns
                tile = tx + tilesetPos.x + (ty + tilesetPos.y) * GXTilesetColumns + 1
            END IF
            ' add the tile to the map at the next unpopulated layer
            IF SelectedEditLayer = 0 THEN
                GXMapTileAdd x, y, tile
            ELSE
                GXMapTile x, y, SelectedEditLayer, tile
            END IF
            x = x + 1
        NEXT tx
        y = y + 1
    NEXT ty
END SUB

SUB PutTileIso ()
    DIM x AS INTEGER, y AS INTEGER, sx AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    'DIM mtx AS INTEGER, mty AS INTEGER
    DIM tile AS INTEGER

    DIM tpos AS GXPosition
    GetTilePosAt Map, _MOUSEX + GXSceneX * scale, _MOUSEY + GXSceneY * scale, tpos
    'SetStatus "(" + STR$(tpos.x) + "," + STR$(tpos.y) + ")"
    sx = tpos.x
    y = tpos.y
    'SetStatus "(" + STR$(tileSelStart.x) + "," + STR$(tileSelStart.y) + ")-(" + STR$(tileSelEnd.x) + "," + STR$(tileSelEnd.y) + ")"

    FOR ty = tileSelStart.y TO tileSelEnd.y
        x = sx
        FOR tx = tileSelStart.x TO tileSelEnd.x
            tile = tx + tilesetPos.x + (ty + tilesetPos.y) * GXTilesetColumns + 1
            'SetStatus "(" + STR$(x) + "," + STR$(y) + ") " + STR$(tile)
            IF SelectedEditLayer = 0 THEN
                GXMapTileAdd x, y, tile
            ELSE
                GXMapTile x, y, SelectedEditLayer, tile
            END IF
            x = x + 1
        NEXT tx
        y = y + 1
    NEXT ty

END SUB

' Delete the tiles in the location indicated by the cursor.  This will only
' remove the tile from the topmost layer in each selected position.
SUB DeleteTile ()
    IF resizeMode THEN EXIT SUB
    IF GXMapIsometric THEN
        DeleteTileIso
        EXIT SUB
    END IF

    DIM x AS INTEGER, y AS INTEGER, sx AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    sx = FIX((_MOUSEX / scale - Control(Map).Left + GXSceneX) / GXTilesetWidth)
    y = FIX((_MOUSEY / scale - Control(Map).Top + GXSceneY) / GXTilesetHeight)

    FOR ty = tileSelStart.y TO tileSelEnd.y
        x = sx
        FOR tx = tileSelStart.x TO tileSelEnd.x
            IF SelectedEditLayer = 0 THEN
                GXMapTileRemove x, y
            ELSE
                GXMapTile x, y, SelectedEditLayer, 0
            END IF
            x = x + 1
        NEXT tx
        y = y + 1
    NEXT ty
END SUB

SUB DeleteTileIso ()
    DIM x AS INTEGER, y AS INTEGER, sx AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    'DIM mtx AS INTEGER, mty AS INTEGER
    DIM tile AS INTEGER

    DIM tpos AS GXPosition
    GetTilePosAt Map, _MOUSEX + GXSceneX * scale, _MOUSEY + GXSceneY * scale, tpos
    sx = tpos.x
    y = tpos.y

    FOR ty = tileSelStart.y TO tileSelEnd.y
        x = sx
        FOR tx = tileSelStart.x TO tileSelEnd.x
            tile = tx + tilesetPos.x + (ty + tilesetPos.y) * GXTilesetColumns + 1
            IF SelectedEditLayer = 0 THEN
                GXMapTileRemove x, y
            ELSE
                GXMapTile x, y, SelectedEditLayer, 0
            END IF
            x = x + 1
        NEXT tx
        y = y + 1
    NEXT ty
END SUB


' Draw the selection cursor
SUB DrawCursor (id AS LONG)
    DIM cx AS INTEGER, cy AS INTEGER
    DIM endx AS INTEGER, endy AS INTEGER
    DIM tpos AS GXPosition

    IF id = Map THEN

        ' Calculate the position of the map cursor
        'GetTilePosAt id, _MOUSEX, _MOUSEY, scale, tpos
        GetTilePosAt id, _MOUSEX, _MOUSEY, tpos
        IF NOT GXMapIsometric THEN
            cx = tpos.x * GXTilesetWidth
            cy = tpos.y * GXTilesetHeight
            ' Display the cursor as a single tile sized sqaure while resizing the
            ' current selection
            IF NOT mapSelSizing THEN
                endx = (tpos.x + tileSelEnd.x - tileSelStart.x + 1) * GXTilesetWidth - 1
                endy = (tpos.y + tileSelEnd.y - tileSelStart.y + 1) * GXTilesetHeight - 1
            ELSE
                endx = cx + GXTilesetWidth - 1
                endy = cy + GXTilesetHeight - 1
            END IF
            ' Draw the cursor
            LINE (cx, cy)-(endx, endy), _RGB(255, 255, 255), B , &B1010101010101010
        ELSE
            DIM columnOffset AS LONG
            IF tpos.y MOD 2 = 1 THEN
                'columnOffset = GXTilesetWidth
                columnOffset = 0
            ELSE
                columnOffset = GXTilesetWidth / 2
            END IF

            DIM rowOffset AS LONG
            rowOffset = (tpos.y + 1) * _ROUND(GXTilesetHeight - GXTilesetWidth / 4)
            'rowOffset = (tpos.y) * (GXTilesetHeight - GXTilesetWidth / 4)

            DIM tx AS LONG: tx = tpos.x * GXTilesetWidth - columnOffset
            DIM ty AS LONG: ty = tpos.y * GXTilesetHeight - rowOffset

            LINE (tx, ty)-(tx + GXTilesetWidth, ty + GXTilesetHeight), _RGB32(200, 200, 200), B

            DIM topY AS LONG: topY = ty + (GXTilesetHeight - GXTilesetWidth / 2)
            DIM midY AS LONG: midY = ty + (GXTilesetHeight - GXTilesetWidth / 4)
            DIM midX AS LONG: midX = tx + GXTilesetWidth / 2
            DIM rightX AS LONG: rightX = tx + GXTilesetWidth
            DIM bottomY AS LONG: bottomY = ty + GXTilesetHeight

            LINE (tx, midY)-(midX, topY), _RGB32(255, 255, 255)
            LINE (midX, topY)-(rightX, midY), _RGB(255, 255, 255)
            LINE (rightX, midY)-(midX, bottomY), _RGB(255, 255, 255)
            LINE (midX, bottomY)-(tx, midY), _RGB(255, 255, 255)

        END IF
    ELSE 'id = Tileset
        ' Calculate the position of the tileset cursor
        'GetTilePosAt id, _MOUSEX, _MOUSEY, tscale, tpos
        GetTilePosAt id, _MOUSEX, _MOUSEY, tpos
        cx = tpos.x * GXTilesetWidth * tscale
        cy = tpos.y * GXTilesetHeight * tscale
        endx = cx + GXTilesetWidth * tscale - 1
        endy = cy + GXTilesetHeight * tscale - 1

        ' Draw the cursor
        LINE (cx, cy)-(endx, endy), _RGB(255, 255, 255), B , &B1010101010101010
    END IF

END SUB

' Get the tile position at the specified window coordinates
SUB GetTilePosAt (id AS LONG, x AS INTEGER, y AS INTEGER, tpos AS GXPosition)
    'SUB GetTilePosAt (id AS LONG, x AS INTEGER, y AS INTEGER, scale AS INTEGER, tpos AS GXPosition)
    IF id = Map THEN
        IF NOT GXMapIsometric THEN
            x = x / scale - Control(id).Left
            y = y / scale - Control(id).Top
            tpos.x = FIX(x / GXTilesetWidth)
            tpos.y = FIX(y / GXTilesetHeight)
        ELSE
            x = x / scale - Control(id).Left
            y = y / scale - Control(id).Top

            DIM tileWidthHalf AS INTEGER: tileWidthHalf = GXTilesetWidth / 2
            'DIM tileHeightHalf AS INTEGER: tileHeightHalf = GXTilesetHeight / 2
            DIM tileHeightHalf AS INTEGER: tileHeightHalf = GXTilesetWidth / 2
            DIM sx AS LONG: sx = x / tileWidthHalf

            DIM offset AS INTEGER
            IF sx MOD 2 = 1 THEN
                offset = tileWidthHalf
            ELSE
                offset = 0
            END IF

            tpos.y = (2 * y) / tileHeightHalf
            tpos.x = (x - offset) / GXTilesetWidth
            'IF sx MOD 2 - 1 THEN tpos.x = tpos.x - 1
        END IF

        'IF GXMapIsometric THEN GXMapTilePosAt x, y, tpos
    ELSE
        x = x - Control(id).Left
        y = y - Control(id).Top
        tpos.x = FIX(x / (GXTilesetWidth * tscale))
        tpos.y = FIX(y / (GXTilesetHeight * tscale))
    END IF
END SUB

' Draw a bounding rectangle around the tile selection
SUB DrawSelected (id AS LONG)
    DIM startx AS INTEGER, starty AS INTEGER, endx AS INTEGER, endy AS INTEGER

    IF id = Map THEN
        ' Calculate the position of the map selection
        startx = tileSelStart.x * GXTilesetWidth
        starty = tileSelStart.y * GXTilesetHeight
        endx = tileSelEnd.x * GXTilesetWidth + GXTilesetWidth - 1
        endy = tileSelEnd.y * GXTilesetHeight + GXTilesetHeight - 1

    ELSE ' id = Tileset
        ' Calculate the position of the tileset selection
        DIM swidth AS INTEGER, sheight AS INTEGER
        swidth = GXTilesetWidth * tscale
        sheight = GXTilesetHeight * tscale
        startx = tileSelStart.x * swidth
        starty = tileSelStart.y * sheight
        endx = tileSelEnd.x * swidth + swidth - 1
        endy = tileSelEnd.y * sheight + sheight - 1
    END IF

    ' Draw the selection rectangle
    LINE (startx, starty)-(endx, endy), _RGB(255, 255, 0), B
END SUB

' Draw the tileset window
SUB DrawTileset
    DIM tcol AS INTEGER, trow AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    DIM totalTiles AS INTEGER
    DIM xoffset AS INTEGER
    DIM yoffset AS INTEGER

    xoffset = -tilesetPos.x * GXTilesetWidth * tscale
    yoffset = -tilesetPos.y * GXTilesetHeight * tscale

    totalTiles = GXTilesetColumns * GXTilesetRows
    DIM img AS LONG
    img = GXTilesetImage

    BeginDraw Tiles
    CLS
    FOR trow = 1 TO GXTilesetRows
        tx = 0
        FOR tcol = 1 TO GXTilesetColumns
            GXSpriteDrawScaled img, tx + xoffset, ty + yoffset, GXTilesetWidth * tscale, GXTilesetHeight * tscale, trow, tcol, GXTilesetWidth, GXTilesetHeight, 0
            tx = tx + GXTilesetWidth * tscale
        NEXT tcol
        ty = ty + GXTilesetHeight * tscale
    NEXT trow

    ' draw a bounding rectangle around the border of the tileset
    tx = -tilesetPos.x * GXTilesetWidth * tscale
    ty = -tilesetPos.y * GXTilesetHeight * tscale
    LINE (tx - 1, ty - 1)-(GXTilesetColumns * GXTilesetWidth * tscale + tx, GXTilesetRows * GXTilesetHeight * tscale + ty), _RGB(100, 100, 100), B


    IF NOT mapSelMode THEN DrawSelected Tiles
    DrawTileFrameSelection
    DrawCursor Tiles

    EndDraw Tiles
END SUB

' Handle map click events
SUB OnMapClick
    IF NOT mapSelSizing THEN
        PutTile
    ELSE
        mapSelSizing = False
        _MOUSEMOVE tileSelStart.x * GXTilesetWidth * scale, (tileSelStart.y + 2) * GXTilesetHeight * scale
    END IF
END SUB

' Update the status bar message
SUB SetStatus (msg AS STRING)
    SetCaption lblStatus, msg
END SUB

' Zoom the map view
SUB ZoomMap (amount AS INTEGER)
    scale = scale + amount
    IF scale < 0 THEN scale = 1
    IF scale > 4 THEN scale = 4
    Control(MapMenuZoomOut).Disabled = False
    IF scale = 1 THEN Control(MapMenuZoomOut).Disabled = True
    IF scale = 4 THEN Control(MapMenuZoomIn).Disabled = True
    ResizeControls
END SUB

' Zoom the map view
SUB ZoomTileset (amount AS INTEGER)
    tscale = tscale + amount
    IF tscale < 0 THEN tscale = 1
    IF tscale > 4 THEN tscale = 4
    Control(TilesetMenuZoomOut).Disabled = False
    IF tscale = 1 THEN Control(TilesetMenuZoomOut).Disabled = True
    IF tscale = 4 THEN Control(TilesetMenuZoomIn).Disabled = True
    ResizeControls
END SUB

SUB OnResizeMap
    resizeMode = True
    Control(frmResizeMap).Hidden = False
    Control(Tiles).Hidden = True
    Control(frmTile).Hidden = True
    Control(FileMenu).Hidden = True
    Control(MapMenu).Hidden = True
    Control(TilesetMenu).Hidden = True
    Control(txtResizeColumns).Value = GXMapColumns
    Control(txtResizeRows).Value = GXMapRows
END SUB

SUB CancelResizeMap
    resizeMode = False
    Control(frmResizeMap).Hidden = True
    Control(Tiles).Hidden = False
    Control(frmTile).Hidden = False
    Control(FileMenu).Hidden = False
    Control(MapMenu).Hidden = False
    Control(TilesetMenu).Hidden = False
END SUB

SUB ResizeMap
    GXMapResize Control(txtResizeColumns).Value, Control(txtResizeRows).Value
    CancelResizeMap
    SetStatus "Map resized."
END SUB

SUB OnChangeResize
    DIM columns AS LONG
    DIM rows AS LONG
    columns = Control(txtResizeColumns).Value
    rows = Control(txtResizeRows).Value

    IF (columns > 0 AND NOT columns = GXMapColumns) OR (rows > 0 AND NOT rows = GXMapRows) THEN
        Control(btnResizeMap).Disabled = False
    ELSE
        Control(btnResizeMap).Disabled = True
    END IF
END SUB

' Resize the application controls
SUB ResizeControls
    ' Position tileset control
    DIM twidth AS INTEGER
    twidth = GXTilesetColumns * GXTilesetWidth * tscale
    DIM maxwidth AS INTEGER
    DIM minwidth AS INTEGER
    minwidth = 300
    maxwidth = Control(MainForm).Width / 3
    IF maxwidth < minwidth THEN maxwidth = minwidth
    IF twidth < minwidth THEN
        twidth = minwidth
    ELSEIF twidth >= maxwidth THEN
        twidth = maxwidth
    END IF
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
END SUB

FUNCTION GetControlAtMousePos
    DIM mx AS LONG, my AS LONG
    mx = _MOUSEX
    my = _MOUSEY

    GetControlAtMousePos = 0

    IF mx > Control(Map).Left AND mx < Control(Map).Left + Control(Map).Width AND _
       my > Control(Map).Top AND my < Control(Map).Top + Control(Map).Height THEN
        GetControlAtMousePos = Map

    elseIF mx > Control(Tiles).Left AND mx < Control(Tiles).Left + Control(Tiles).Width AND _
           my > Control(Tiles).Top AND my < Control(Tiles).Top + Control(Tiles).Height THEN
        GetControlAtMousePos = Tiles
    END IF
END FUNCTION

' General Dialog Methods
' ----------------------------------------------------------------------------
SUB SetDialogMode (newDialogMode AS INTEGER)
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
    IF dialogMode = True THEN
        Control(cboEditLayer).Hidden = True
        Control(lblEditLayer).Hidden = True
        Control(chkLayerHidden).Hidden = True
        Control(btnLayerAdd).Hidden = True
        Control(btnLayerRemove).Hidden = True
    ELSEIF SelectedLayer = 0 THEN
        Control(cboEditLayer).Hidden = False
        Control(lblEditLayer).Hidden = False
        Control(btnLayerAdd).Hidden = False
    ELSEIF SelectedLayer > 0 THEN
        Control(chkLayerHidden).Hidden = False
        Control(btnLayerAdd).Hidden = False
        Control(btnLayerRemove).Hidden = False
    END IF

END SUB

SUB ResizeDialog (dialogId AS LONG)
    Control(dialogId).Left = 5
    Control(dialogId).Top = 15
    Control(dialogId).Width = Control(MainForm).Width - 10
    Control(dialogId).Height = Control(MainForm).Height - 45

    IF dialogId = frmFile THEN
        Control(btnFDOK).Top = Control(MainForm).Height - 85
        Control(btnFDCancel).Top = Control(MainForm).Height - 85
        Control(lstFDFiles).Height = Control(MainForm).Height - 200
        Control(lstFDPaths).Height = Control(MainForm).Height - 230
        Control(chkFDFilterExt).Top = Control(MainForm).Height - 125
    END IF
    __UI_ForceRedraw = True
END SUB

SUB CancelDialog (dialogId AS LONG)
    SetStatus ""
    Control(dialogId).Hidden = True
    SetDialogMode False
END SUB

SUB ShowNewMapDialog
    SetDialogMode True
    Control(txtColumns).Value = 0
    Control(txtRows).Value = 0
    Control(txtLayers).Value = 1
    Text(txtTilesetImage) = ""
    Control(txtTileWidth).Value = 0
    Control(txtTileHeight).Value = 0
    Control(tglIsometric).Value = False
    Control(frmNewMap).Hidden = False
    _MOUSESHOW
END SUB

SUB ShowReplaceTilesetDialog
    dialogMode = True
    Control(frmReplaceTileset).Hidden = False
    Control(txtRTTileWidth).Value = GXTilesetWidth
    Control(txtRTTileHeight).Value = GXTilesetHeight
    SetDialogMode True
    _MOUSESHOW
END SUB

' File Dialog Methods
' ----------------------------------------------------------------------------
SUB ShowFileDialog (mode AS INTEGER, targetForm AS LONG)
    SetDialogMode (True)

    fileDialogMode = mode
    fileDialogTargetForm = targetForm
    IF fileDialogTargetForm <> MainForm THEN
        Control(fileDialogTargetForm).Hidden = True
    END IF

    IF fileDialogMode = FD_OPEN THEN
        SetCaption frmFile, "Open"
    ELSE
        SetCaption frmFile, "Save"
    END IF

    Text(txtFDFilename) = ""
    Control(frmFile).Hidden = False

    RefreshFileDialog
END SUB

SUB EnableFileDialog (enabled AS INTEGER)
    DIM disabled AS INTEGER
    disabled = NOT enabled
    Control(txtFDFilename).Disabled = disabled
    Control(lstFDFiles).Disabled = disabled
    Control(lstFDPaths).Disabled = disabled
    Control(chkFDFilterExt).Disabled = disabled
    Control(btnFDOK).Disabled = disabled
    Control(btnFDCancel).Disabled = disabled
END SUB

SUB RefreshFileDialog
    DIM i AS INTEGER
    DIM path AS STRING
    DIM fitems(0) AS STRING

    ' Set the last selected path
    SetCaption lblFDPathValue, fileDialogPath

    path = fileDialogPath

    ' Refresh the folder list
    ResetList lstFDPaths
    IF GXFS_IsDriveLetter(path) THEN
        path = path + GXFS_PathSeparator
    ELSE
        AddItem lstFDPaths, ".."
    END IF
    FOR i = 1 TO GXFS_DirList(path, True, fitems())
        AddItem lstFDPaths, fitems(i)
    NEXT i
    FOR i = 1 TO GXFS_DriveList(fitems())
        AddItem lstFDPaths, fitems(i)
    NEXT i

    ' Refresh the file list
    RefreshFileList
END SUB

SUB RefreshFileList
    DIM i AS INTEGER
    DIM path AS STRING
    DIM fitems(0) AS STRING

    path = fileDialogPath

    IF GXFS_IsDriveLetter(path) THEN path = path + GXFS_PathSeparator

    ' Refresh the folder list
    ResetList lstFDFiles
    FOR i = 1 TO GXFS_DirList(path, False, fitems())
        IF NOT Control(chkFDFilterExt).Value OR ExtFilterMatch(fitems(i)) THEN
            AddItem lstFDFiles, fitems(i)
        END IF
    NEXT i
END SUB

FUNCTION ExtFilterMatch (filename AS STRING)
    DIM match AS INTEGER
    DIM ext AS STRING
    ext = UCASE$(GXFS_GetFileExtension(filename))

    IF fileDialogTargetForm = MainForm THEN
        IF ext = "GXM" OR ext = "MAP" THEN match = True
    ELSE
        IF ext = "PNG" OR ext = "BMP" OR ext = "GIF" OR ext = "BMP" OR ext = "JPG" OR ext = "JPEG" THEN match = True
    END IF

    ExtFilterMatch = match
END FUNCTION

SUB OnChangeDirectory
    ' Change current path
    DIM dir AS STRING
    dir = GetItem(lstFDPaths, Control(lstFDPaths).Value)
    IF dir = ".." THEN
        fileDialogPath = GXFS_GetParentPath(fileDialogPath)
    ELSEIF GXFS_IsDriveLetter(dir) THEN
        fileDialogPath = dir
    ELSEIF fileDialogPath = GXFS_PathSeparator THEN
        fileDialogPath = GXFS_PathSeparator + dir
    ELSE
        fileDialogPath = fileDialogPath + GXFS_PathSeparator + dir
    END IF
    RefreshFileDialog
END SUB

SUB OnSelectFile
    DIM msgRes AS INTEGER
    DIM filename AS STRING
    filename = Text(txtFDFilename)

    IF filename = "" THEN
        msgRes = MessageBox("Please select a file.", "No File Selection", MsgBox_OkOnly + MsgBox_Exclamation)
        EXIT SUB
    END IF

    filename = fileDialogPath + GXFS_PathSeparator + filename

    IF fileDialogMode = FD_OPEN THEN
        IF NOT _FILEEXISTS(filename) THEN
            msgRes = MessageBox("The specified file was not found.", "File Not Found", MsgBox_OkOnly + MsgBox_Exclamation)
            EXIT SUB
        END IF

        SELECT CASE fileDialogTargetForm

            CASE MainForm
                LoadMap filename

            CASE frmNewMap
                Text(txtTilesetImage) = filename
                Control(frmNewMap).Hidden = False
                Control(frmFile).Hidden = True

            CASE frmReplaceTileset
                Text(txtRTTilesetImage) = filename
                Control(frmReplaceTileset).Hidden = False
                Control(frmFile).Hidden = True

        END SELECT

    ELSE 'FD_SAVE
        SELECT CASE fileDialogTargetForm
            CASE MainForm:
                IF _FILEEXISTS(filename) THEN
                    msgRes = MessageBox("File exists, overwrite existing file?", "File Exists", MsgBox_YesNo + MsgBox_Question)
                    IF msgRes = MsgBox_No THEN EXIT SUB
                END IF

                SaveMap filename
        END SELECT
    END IF

END SUB

' Handle file list click events
SUB OnFileListClick (id AS LONG)
    Text(txtFDFilename) = GetItem(lstFDFiles, Control(lstFDFiles).Value)
    IF lastControlClicked = id AND TIMER - lastClick < .3 THEN ' Double-click
        OnSelectFile
    END IF
END SUB

' Handle path list click events
SUB OnPathListClick (id AS LONG)
    IF lastControlClicked = id AND TIMER - lastClick < .3 THEN ' Double-click
        OnChangeDirectory
    END IF
END SUB


'$include:'../gx/gx.bm'
