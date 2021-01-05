OPTION _EXPLICIT
$EXEICON:'./map.ico'
'$include:'../gx/gx.bi'
'$include:'FileDialog.bi'
'TODO: replace windows file dialog with custom control for cross-platform support

DIM SHARED scale AS INTEGER
DIM SHARED gxloaded AS INTEGER
DIM SHARED mapFilename AS STRING
DIM SHARED tileSelStart AS GXPosition
DIM SHARED tileSelEnd AS GXPosition
DIM SHARED tileSelSizing AS INTEGER
DIM SHARED mapSelSizing AS INTEGER
DIM SHARED mapSelMode AS INTEGER
DIM SHARED saving AS INTEGER
DIM SHARED deleting AS INTEGER
DIM SHARED dialogMode AS INTEGER

': This program uses
': InForm - GUI library for QB64 - v1.2
': Fellippe Heitor, 2016-2020 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------

': Controls' IDs: ------------------------------------------------------------------
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
DIM SHARED MenuTileset AS LONG
DIM SHARED TilesetMenuReplace AS LONG

DIM SHARED Map AS LONG
DIM SHARED Tiles AS LONG

DIM SHARED frmNewMap AS LONG
DIM SHARED lblNewMap AS LONG
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
DIM SHARED btnCreateMap AS LONG
DIM SHARED btnCancel AS LONG

DIM SHARED frmReplaceTileset AS LONG
DIM SHARED lblReplaceTileset AS LONG
DIM SHARED lblTileWidth2 AS LONG
DIM SHARED txtRTTileWidth AS LONG
DIM SHARED lblTileHeight2 AS LONG
DIM SHARED txtRTTileHeight AS LONG
DIM SHARED lblTilesetImage2 AS LONG
DIM SHARED txtRTTilesetImage AS LONG
DIM SHARED btnRTSelectTilesetImage AS LONG
DIM SHARED btnReplaceTileset AS LONG
DIM SHARED btnRTCancel AS LONG

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

    ' Set the initial zoom level (1=100%, actual size)
    scale = 1

    ' Disable menu items which are not valid yet
    Control(ViewMenuZoomOut).Disabled = True
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = True

    ' Create the GX Scene for rendering the map
    GXSceneEmbedded True
    GXSceneCreate Control(Map).Width / 2, Control(Map).Height / 2

    ' Size the window components for the current window size
    ResizePanels

    ' Ok, we're ready to display screen updates now
    gxloaded = True
END SUB

SUB __UI_BeforeUpdateDisplay
    IF gxloaded = False THEN EXIT SUB ' We're not ready yet, abort!

    ' Use WASD to navigate around the map
    IF GXKeyDown(GXKEY_S) THEN ' move down
        GXSceneMove 0, GXTilesetHeight
        IF mapSelMode THEN tileSelStart.y = tileSelStart.y - 1: tileSelEnd.y = tileSelEnd.y - 1

    ELSEIF GXKeyDown(GXKEY_W) THEN ' move up
        GXSceneMove 0, -GXTilesetHeight
        IF mapSelMode THEN tileSelStart.y = tileSelStart.y + 1: tileSelEnd.y = tileSelEnd.y + 1

    ELSEIF GXKeyDown(GXKEY_D) THEN ' move right
        GXSceneMove GXTilesetWidth, 0
        IF mapSelMode THEN tileSelStart.x = tileSelStart.x - 1: tileSelEnd.x = tileSelEnd.x - 1

    ELSEIF GXKeyDown(GXKEY_A) THEN ' move left
        GXSceneMove -GXTilesetWidth, 0
        IF mapSelMode THEN tileSelStart.x = tileSelStart.x + 1: tileSelEnd.x = tileSelEnd.x + 1
    END IF

    ' Adjust the current selection if selection sizing is in progress
    IF tileSelSizing THEN
        GetTilePosAt Tiles, _MOUSEX, _MOUSEY, 1, tileSelEnd
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
    IF NOT mapSelMode THEN DrawSelected
    DrawCursor Tiles, 1
    EndDraw Tiles
END SUB

SUB __UI_BeforeUnload
    ' If the user is in the process of saving the map
    ' prevent the application from closing
    IF saving THEN __UI_UnloadSignal = False
END SUB

SUB __UI_Click (id AS LONG)
    DIM filename AS STRING, msgResult

    SELECT CASE id
        CASE MainForm

        CASE FileMenu

        CASE Map
            IF NOT mapSelSizing THEN
                PutTile
            ELSE
                mapSelSizing = False
            END IF

        CASE FileMenuNew
            Control(frmNewMap).Hidden = False
            dialogMode = True
            _MOUSESHOW

        CASE FileMenuOpen
            filename = GetOpenFileName("Open Game Map", ".\", "Map Files (*.map)|*.map", 1, OFN_FILEMUSTEXIST + OFN_NOCHANGEDIR + OFN_READONLY)
            IF filename <> "" THEN
                GXMapLoad filename
                mapFilename = filename
                ResizePanels
                Control(FileMenuSave).Disabled = False
            END IF

        CASE FileMenuSave
            saving = 1
            GXMapSave mapFilename
            saving = 0
            msgResult = MessageBox("Map saved.", "Save Complete", MsgBox_OkOnly)

        CASE FileMenuSaveAs
            filename = GetSaveFileName("Save Game Map", ".\", "Map Files (*.map)|*.map", 1, OFN_OVERWRITEPROMPT + OFN_NOCHANGEDIR)
            IF filename <> "" THEN
                IF NOT RIGHT$(filename, 3) = ".map" THEN
                    filename = filename + ".map"
                END IF
                ' move tileset
                GXMapSave filename
                mapFilename = filename
                Control(FileMenuSave).Disabled = False
                msgResult = MessageBox("Map saved.", "Save Complete", MsgBox_OkOnly)
            END IF

        CASE FileMenuExit
            SYSTEM 0

        CASE ViewMenuZoomIn
            scale = scale + 1
            Control(ViewMenuZoomOut).Disabled = False
            IF scale = 4 THEN Control(ViewMenuZoomIn).Disabled = True
            ResizePanels

        CASE ViewMenuZoomOut
            scale = scale - 1
            Control(ViewMenuZoomIn).Disabled = False
            IF scale = 1 THEN Control(ViewMenuZoomOut).Disabled = True
            ResizePanels


        CASE TilesetMenuReplace
            dialogMode = True
            Control(frmReplaceTileset).Hidden = False
            Control(txtRTTileWidth).Value = GXTilesetWidth
            Control(txtRTTileHeight).Value = GXTilesetHeight
            _MOUSESHOW

        CASE btnRTCancel
            Control(frmReplaceTileset).Hidden = True

        CASE btnCancel
            Control(frmNewMap).Hidden = True

        CASE btnCreateMap
            CreateMap

        CASE btnReplaceTileset
            ReplaceTileset

        CASE btnSelectTilesetImage
            filename = GetOpenFileName("Select Tileset Image", ".\", "PNG Files (*.png)|*.png", 1, OFN_FILEMUSTEXIST + OFN_NOCHANGEDIR + OFN_READONLY)
            IF filename <> "" THEN
                Text(txtTilesetImage) = filename
            END IF

        CASE btnRTSelectTilesetImage
            filename = GetOpenFileName("Select Tileset Image", ".\", "PNG Files (*.png)|*.png", 1, OFN_FILEMUSTEXIST + OFN_NOCHANGEDIR + OFN_READONLY)
            IF filename <> "" THEN
                Text(txtRTTilesetImage) = filename
            END IF

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE MainForm

        CASE FileMenu

        CASE Map
            IF dialogMode = False THEN _MOUSEHIDE

        CASE Tiles
            IF dialogMode = False THEN _MOUSEHIDE

        CASE FileMenuNew

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE MainForm

        CASE FileMenu

        CASE Map
            _MOUSESHOW

        CASE Tiles
            _MOUSESHOW

        CASE FileMenuNew

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
            GetTilePosAt Tiles, _MOUSEX, _MOUSEY, 1, tileSelStart
            tileSelEnd = tileSelStart

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id

        CASE Tiles
            tileSelSizing = False

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0

END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_FormResized
    ' The window has been resized so resize the child components accordingly
    ResizePanels
END SUB



' Create a new map from the parameters specified by the user on the new map
' dialog.
SUB CreateMap
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
    ResizePanels

    mapFilename = ""
    Control(FileMenuSave).Disabled = True
    Control(frmNewMap).Hidden = True
    dialogMode = 0
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
    dialogMode = 0
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
                tile = tx + ty * GXTilesetColumns
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

' Draw the main map selection cursor
SUB DrawCursor (id AS LONG, scale AS INTEGER)
    DIM cx AS INTEGER, cy AS INTEGER
    DIM endx AS INTEGER, endy AS INTEGER
    DIM tpos AS GXPosition
    GetTilePosAt id, _MOUSEX, _MOUSEY, scale, tpos
    cx = tpos.x * GXTilesetWidth
    cy = tpos.y * GXTilesetHeight

    IF (id = Map AND NOT mapSelSizing) THEN
        endx = (tpos.x + tileSelEnd.x - tileSelStart.x + 1) * GXTilesetWidth - 1
        endy = (tpos.y + tileSelEnd.y - tileSelStart.y + 1) * GXTilesetHeight - 1
    ELSE
        endx = cx + GXTilesetWidth - 1
        endy = cy + GXTilesetHeight - 1
    END IF

    LINE (cx, cy)-(endx, endy), _RGB(255, 255, 255), B , &B1010101010101010
END SUB

' Get the tile position at the specified window coordinates
SUB GetTilePosAt (id AS LONG, x AS INTEGER, y AS INTEGER, scale AS INTEGER, tpos AS GXPosition)
    x = x / scale - Control(id).Left
    y = y / scale - Control(id).Top
    tpos.x = FIX(x / GXTilesetWidth)
    tpos.y = FIX(y / GXTilesetHeight)
END SUB

SUB DrawSelected
    DIM startx AS INTEGER, starty AS INTEGER, endx AS INTEGER, endy AS INTEGER
    startx = tileSelStart.x * GXTilesetWidth
    starty = tileSelStart.y * GXTilesetHeight
    endx = tileSelEnd.x * GXTilesetWidth + GXTilesetWidth - 1
    endy = tileSelEnd.y * GXTilesetHeight + GXTilesetHeight - 1
    LINE (startx, starty)-(endx, endy), _RGB(255, 255, 0), B
END SUB

SUB DrawTileset
    DIM tcol AS INTEGER, trow AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    DIM tilesPerRow AS INTEGER
    DIM totalTiles AS INTEGER
    DIM tpos AS GXPosition

    tilesPerRow = FIX(Control(Tiles).Width / GXTilesetWidth)
    totalTiles = GXTilesetColumns * GXTilesetRows
    DIM img AS LONG
    img = GXTilesetImage

    BeginDraw Tiles
    CLS
    FOR trow = 1 TO GXTilesetRows
        tx = 0
        FOR tcol = 1 TO GXTilesetColumns
            GXSpriteDraw img, tx, ty, trow, tcol, GXTilesetWidth, GXTilesetHeight, 0
            tx = tx + GXTilesetWidth
        NEXT tcol
        ty = ty + GXTilesetHeight
    NEXT trow
    EndDraw Tiles
END SUB

SUB ResizePanels
    DIM twidth AS INTEGER
    twidth = GXTilesetColumns * GXTilesetWidth
    IF twidth = 0 THEN twidth = 200
    Control(Tiles).Top = 23
    Control(Tiles).Width = twidth
    Control(Tiles).Left = Control(MainForm).Width - twidth
    Control(Tiles).Height = Control(MainForm).Height - 23
    LoadImage Control(Tiles), ""

    Control(Map).Left = 0
    Control(Map).Top = 23
    Control(Map).Width = Control(MainForm).Width - twidth - 1
    Control(Map).Height = Control(MainForm).Height - 23
    GXSceneResize Control(Map).Width / scale, Control(Map).Height / scale
    LoadImage Control(Map), ""

    ResizeDialog frmNewMap
    ResizeDialog frmReplaceTileset
END SUB

SUB ResizeDialog (dialogId AS LONG)
    Control(dialogId).Left = 0
    Control(dialogId).Top = 0
    Control(dialogId).Width = Control(MainForm).Width
    Control(dialogId).Height = Control(MainForm).Height
END SUB


SUB GXOnGameEvent (e AS GXEvent)
    IF e.event = GXEVENT_PAINTBEFORE THEN BeginDraw Map
    IF e.event = GXEVENT_PAINTAFTER THEN EndDraw Map
    IF e.event = GXEVENT_DRAWSCREEN THEN
        IF mapSelMode THEN DrawSelected
        DrawCursor Map, scale
        LINE (-GXSceneX - 1, -GXSceneY - 1)-(GXMapColumns * GXTilesetWidth - GXSceneX, GXMapRows * GXTilesetHeight - GXSceneY), _RGB(100, 100, 100), B
    END IF
END SUB

'$include: 'FileDialog.bm'
'$include:'../gx/gx.bm'

