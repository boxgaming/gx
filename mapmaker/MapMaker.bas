OPTION _EXPLICIT
$EXEICON:'./map.ico'
'$include:'../gx/gx.bi'

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
DIM SHARED ViewMenu AS LONG
DIM SHARED ViewMenuZoomIn AS LONG
DIM SHARED ViewMenuZoomOut AS LONG
DIM SHARED TilesetMenu AS LONG
DIM SHARED TilesetMenuReplace AS LONG
DIM SHARED TilesetMenuZoomIn AS LONG
DIM SHARED TilesetMenuZoomOut AS LONG

' Map picture control
DIM SHARED Map AS LONG

' Tiles picture control
DIM SHARED Tiles AS LONG

' Status bar
DIM SHARED lblStatus AS LONG

' New Map Dialog
DIM SHARED frmNewMap AS LONG
DIM SHARED lblColumns AS LONG
DIM SHARED txtColumns AS LONG
DIM SHARED lblRows AS LONG
DIM SHARED txtRows AS LONG
DIM SHARED lblTilesetImage AS LONG
DIM SHARED txtTilesetImage AS LONG
DIM SHARED btnSelectTilesetImage AS LONG
DIM SHARED lblTileHeight AS LONG
DIM SHARED txtTileHeight AS LONG
DIM SHARED lblTileWidth AS LONG
DIM SHARED txtTileWidth AS LONG
DIM SHARED lblIsometric AS LONG
DIM SHARED toggleIsometric AS LONG
DIM SHARED lblLine2 AS LONG
DIM SHARED btnCreateMap AS LONG
DIM SHARED btnCancel AS LONG

' Replace Tileset Dialog
DIM SHARED frmReplaceTileset AS LONG
DIM SHARED lblTileWidth2 AS LONG
DIM SHARED txtRTTileWidth AS LONG
DIM SHARED lblTileHeight2 AS LONG
DIM SHARED txtRTTileHeight AS LONG
DIM SHARED lblTilesetImage2 AS LONG
DIM SHARED txtRTTilesetImage AS LONG
DIM SHARED btnRTSelectTilesetImage AS LONG
DIM SHARED lblLine AS LONG
DIM SHARED btnReplaceTileset AS LONG
DIM SHARED btnRTCancel AS LONG

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
    Control(ViewMenuZoomIn).Disabled = True
    Control(ViewMenuZoomOut).Disabled = True
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = True
    Control(TilesetMenuReplace).Disabled = True
    Control(TilesetMenuZoomIn).Disabled = True
    Control(TilesetMenuZoomOut).Disabled = True

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

    ' Set a higher frame rate for smoother cursor movement
    SetFrameRate 60
END SUB

SUB __UI_BeforeUpdateDisplay
    IF gxloaded = False THEN EXIT SUB ' We're not ready yet, abort!
    IF dialogMode = True THEN EXIT SUB ' Nothing to do here

    DIM mc AS LONG
    mc = GetControlAtMousePos

    ' Use WASD or arrow keys to navigate around the map or tileset
    IF GXKeyDown(GXKEY_S) OR GXKeyDown(GXKEY_DOWN) THEN ' move down
        IF mc = Map THEN
            GXSceneMove 0, GXTilesetHeight
        ELSEIF mc = Tiles THEN
            tilesetPos.y = tilesetPos.y + 1
        END IF
        IF (mapSelMode AND mc = Map) OR (NOT mapSelMode AND mc = Tiles) THEN
            tileSelStart.y = tileSelStart.y - 1: tileSelEnd.y = tileSelEnd.y - 1
        END IF

    ELSEIF GXKeyDown(GXKEY_W) OR GXKeyDown(GXKEY_UP) THEN ' move up
        IF mc = Map THEN
            GXSceneMove 0, -GXTilesetHeight
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
        GetTilePosAt Tiles, _MOUSEX, _MOUSEY, tscale, tileSelEnd
    ELSEIF mapSelSizing THEN
        GetTilePosAt Map, _MOUSEX, _MOUSEY, scale, tileSelEnd
    END IF

    ' If X or DEL key is pressed, delete the tiles in the current selection
    IF GXKeyDown(GXKEY_DEL) OR GXKeyDown(GXKEY_X) THEN deleting = 1
    IF NOT (GXKeyDown(GXKEY_X) OR GXKeyDown(GXKEY_X)) AND deleting THEN DeleteTile: deleting = 0

    ' Draw the map
    GXSceneDraw

    ' Draw the tileset
    DrawTileset

    ' Draw the tileset cursor
    BeginDraw Tiles
    IF NOT mapSelMode THEN DrawSelected Tiles
    DrawCursor Tiles
    EndDraw Tiles
END SUB

SUB __UI_BeforeUnload
    ' If the user is in the process of saving the map
    ' prevent the application from closing
    IF saving THEN __UI_UnloadSignal = False
END SUB

SUB __UI_Click (id AS LONG)
    'DIM filename AS STRING, msgResult
    'DIM msgResult AS INTEGER

    SELECT CASE id

        CASE Map: OnMapClick

        CASE FileMenuNew: ShowNewMapDialog
        CASE FileMenuOpen: ShowFileDialog FD_OPEN, MainForm
        CASE FileMenuSave: SaveMap mapFilename
        CASE FileMenuSaveAs: ShowFileDialog FD_SAVE, MainForm
        CASE FileMenuExit: SYSTEM 0

        CASE ViewMenuZoomIn: ZoomMap 1
        CASE ViewMenuZoomOut: ZoomMap -1

        CASE TilesetMenuZoomIn: ZoomTileset 1
        CASE TilesetMenuZoomOut: ZoomTileset -1
        CASE TilesetMenuReplace: ShowReplaceTilesetDialog

        CASE btnCancel: CancelDialog frmNewMap
        CASE btnRTCancel: CancelDialog frmReplaceTileset
        CASE btnFDCancel: CancelDialog frmFile
        CASE btnCreateMap: CreateMap
        CASE btnReplaceTileset: ReplaceTileset
        CASE btnSelectTilesetImage: ShowFileDialog FD_OPEN, frmNewMap
        CASE btnRTSelectTilesetImage: ShowFileDialog FD_OPEN, frmReplaceTileset
        CASE btnFDOK: OnSelectFile

        CASE lstFDFiles: OnFileListClick id
        CASE lstFDPaths: OnPathListClick id

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
            IF GXKeyDown(GXKEY_LSHIFT) OR GXKeyDown(GXKEY_RSHIFT) THEN
                mapSelMode = True
                mapSelSizing = True
                GetTilePosAt Map, _MOUSEX, _MOUSEY, scale, tileSelStart
                tileSelEnd = tileSelStart
            END IF


        CASE Tiles
            ' If we detect a mouse down event on the tileset control
            ' start resizing the tileset selection cursor
            mapSelMode = False
            tileSelSizing = True
            GetTilePosAt Tiles, _MOUSEX, _MOUSEY, tscale, tileSelStart
            tileSelEnd = tileSelStart

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE Tiles: tileSelSizing = False
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
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
        CASE chkFDFilterExt: RefreshFileList
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
        DrawCursor Map
        ' draw a bounding rectangle around the border of the map
        LINE (-GXSceneX - 1, -GXSceneY - 1)-(GXMapColumns * GXTilesetWidth - GXSceneX, GXMapRows * GXTilesetHeight - GXSceneY), _RGB(100, 100, 100), B
    END IF
END SUB


' Create a new map from the parameters specified by the user on the new map dialog.
SUB CreateMap
    SetStatus "Creating new map..."
    DIM columns AS INTEGER, rows AS INTEGER
    DIM tilesetImage AS STRING
    DIM tileWidth AS INTEGER, tileHeight AS INTEGER
    DIM isometric AS INTEGER
    DIM msgRes AS INTEGER

    columns = Control(txtColumns).Value
    rows = Control(txtRows).Value
    tilesetImage = Text(txtTilesetImage)
    tileWidth = Control(txtTileWidth).Value
    tileHeight = Control(txtTileHeight).Value
    isometric = Control(toggleIsometric).Value

    IF columns < 1 THEN msgRes = MessageBox("Map must have at least 1 column.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF rows < 1 THEN msgRes = MessageBox("Map must have at least 1 row.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tilesetImage = "" THEN msgRes = MessageBox("Please select a tileset image.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tileWidth < 1 THEN msgRes = MessageBox("Tile width must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): EXIT SUB
    IF tileHeight < 1 THEN msgRes = MessageBox("Tile height must be at least 1 pixel.", "Invalid Option", MsgBox_OkOnly): EXIT SUB

    GXScenePos 0, 0
    GXMapCreate columns, rows
    GXTilesetCreate tilesetImage, tileWidth, tileHeight
    IF isometric THEN
        GXMapIsometric True
    ELSE
        GXMapIsometric False
    END IF

    mapFilename = ""
    scale = 1
    tscale = 1
    tilesetPos.x = 0
    tilesetPos.y = 0
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = False
    Control(ViewMenuZoomIn).Disabled = False
    Control(ViewMenuZoomOut).Disabled = True
    Control(TilesetMenuZoomIn).Disabled = False
    Control(TilesetMenuZoomOut).Disabled = True
    Control(TilesetMenuReplace).Disabled = False
    Control(frmNewMap).Hidden = True

    SetDialogMode False
    mapLoaded = True

    ResizeControls
    SetStatus "Map created."
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
    Control(ViewMenuZoomIn).Disabled = False
    Control(ViewMenuZoomOut).Disabled = True
    Control(TilesetMenuZoomIn).Disabled = False
    Control(TilesetMenuZoomOut).Disabled = True
    Control(TilesetMenuReplace).Disabled = False
    mapLoaded = True
    scale = 1
    tscale = 1

    Control(frmFile).Hidden = True
    SetDialogMode False
    EnableFileDialog True

    ResizeControls
    SetStatus "Map loaded."
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

    GXTilesetCreate tilesetImage, tileWidth, tileHeight
    Control(frmReplaceTileset).Hidden = True

    SetDialogMode False
END SUB

' Place selected tiles in the location indicated by the cursor.  The tile
' selection can be made either in the tileset window or from another location
' on the map.
SUB PutTile ()
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
                tile = GXMapTile(mtx, mty, GXMapTileDepth(mtx, mty))
            ELSE
                ' calculate the tile id from the current selection position
                'tile = tx + ty * GXTilesetColumns
                tile = tx + tilesetPos.x + (ty + tilesetPos.y) * GXTilesetColumns
            END IF
            ' add the tile to the map at the next unpopulated layer
            GXMapTileAdd tile, x, y
            x = x + 1
        NEXT tx
        y = y + 1
    NEXT ty
END SUB

' Delete the tiles in the location indicated by the cursor.  This will only
' remove the tile from the topmost layer in each selected position.
SUB DeleteTile ()
    DIM x AS INTEGER, y AS INTEGER, sx AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    sx = FIX((_MOUSEX / scale - Control(Map).Left + GXSceneX) / GXTilesetWidth)
    y = FIX((_MOUSEY / scale - Control(Map).Top + GXSceneY) / GXTilesetHeight)

    FOR ty = tileSelStart.y TO tileSelEnd.y
        x = sx
        FOR tx = tileSelStart.x TO tileSelEnd.x
            GXMapTileRemove x, y
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
        GetTilePosAt id, _MOUSEX, _MOUSEY, scale, tpos
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

    ELSE 'id = Tileset
        ' Calculate the position of the tileset cursor
        GetTilePosAt id, _MOUSEX, _MOUSEY, tscale, tpos
        cx = tpos.x * GXTilesetWidth * tscale
        cy = tpos.y * GXTilesetHeight * tscale
        endx = cx + GXTilesetWidth * tscale - 1
        endy = cy + GXTilesetHeight * tscale - 1
    END IF

    ' Draw the cursor
    LINE (cx, cy)-(endx, endy), _RGB(255, 255, 255), B , &B1010101010101010
END SUB

' Get the tile position at the specified window coordinates
SUB GetTilePosAt (id AS LONG, x AS INTEGER, y AS INTEGER, scale AS INTEGER, tpos AS GXPosition)
    IF id = Map THEN
        x = x / scale - Control(id).Left
        y = y / scale - Control(id).Top
        tpos.x = FIX(x / GXTilesetWidth)
        tpos.y = FIX(y / GXTilesetHeight)
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

    EndDraw Tiles
END SUB

' Handle map click events
SUB OnMapClick
    IF NOT mapSelSizing THEN
        PutTile
    ELSE
        mapSelSizing = False
        _MOUSEMOVE tileSelStart.x * GXTilesetWidth, (tileSelStart.y + 2) * GXTilesetHeight
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
    Control(ViewMenuZoomOut).Disabled = False
    IF scale = 1 THEN Control(ViewMenuZoomOut).Disabled = True
    IF scale = 4 THEN Control(ViewMenuZoomIn).Disabled = True
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


' Resize the application controls
SUB ResizeControls
    ' Position tileset control
    DIM twidth AS INTEGER
    twidth = GXTilesetColumns * GXTilesetWidth * tscale
    DIM maxwidth AS INTEGER
    DIM minwidth AS INTEGER
    minwidth = 200
    maxwidth = Control(MainForm).Width / 3
    IF twidth < minwidth THEN
        twidth = minwidth
    ELSEIF twidth >= maxwidth THEN
        twidth = maxwidth
    END IF
    Control(Tiles).Top = 23
    Control(Tiles).Width = twidth
    Control(Tiles).Left = Control(MainForm).Width - twidth
    Control(Tiles).Height = Control(MainForm).Height - 50
    LoadImage Control(Tiles), ""

    ' Position map control
    Control(Map).Left = 0
    Control(Map).Top = 23
    Control(Map).Width = Control(MainForm).Width - twidth - 1
    Control(Map).Height = Control(MainForm).Height - 50
    GXSceneResize Control(Map).Width / scale, Control(Map).Height / scale
    LoadImage Control(Map), ""

    ' Position status bar
    Control(lblStatus).Left = -1
    Control(lblStatus).Top = Control(MainForm).Height - 26
    Control(lblStatus).Width = Control(MainForm).Width + 2

    ResizeDialog frmNewMap
    ResizeDialog frmReplaceTileset
    ResizeDialog frmFile
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
    Control(ViewMenu).Hidden = dialogMode
    Control(TilesetMenu).Hidden = dialogMode
    Control(Map).Hidden = dialogMode
    Control(Tiles).Hidden = dialogMode
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
    Control(dialogId).Hidden = True
    SetDialogMode False
END SUB

SUB ShowNewMapDialog
    SetDialogMode True
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
    IF __GXFS_IsDriveLetter(path) THEN
        path = path + __GXFS_PathSeparator
    ELSE
        AddItem lstFDPaths, ".."
    END IF
    FOR i = 1 TO __GXFS_DirList(path, True, fitems())
        AddItem lstFDPaths, fitems(i)
    NEXT i
    FOR i = 1 TO __GXFS_DriveList(fitems())
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

    IF __GXFS_IsDriveLetter(path) THEN path = path + __GXFS_PathSeparator

    ' Refresh the folder list
    ResetList lstFDFiles
    FOR i = 1 TO __GXFS_DirList(path, False, fitems())
        IF NOT Control(chkFDFilterExt).Value OR ExtFilterMatch(fitems(i)) THEN
            AddItem lstFDFiles, fitems(i)
        END IF
    NEXT i
END SUB

FUNCTION ExtFilterMatch (filename AS STRING)
    DIM match AS INTEGER
    DIM ext AS STRING
    ext = UCASE$(__GXFS_GetFileExtension(filename))

    IF fileDialogTargetForm = MainForm THEN
        IF ext = "MAP" THEN match = True
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
        fileDialogPath = __GXFS_GetParentPath(fileDialogPath)
    ELSEIF __GXFS_IsDriveLetter(dir) THEN
        fileDialogPath = dir
    ELSEIF fileDialogPath = __GXFS_PathSeparator THEN
        fileDialogPath = __GXFS_PathSeparator + dir
    ELSE
        fileDialogPath = fileDialogPath + __GXFS_PathSeparator + dir
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

    filename = fileDialogPath + __GXFS_PathSeparator + filename

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
