OPTION _EXPLICIT
$EXEICON:'./map.ico'
'$include:'../gx/gx.bi'

CONST FD_OPEN = 1
CONST FD_SAVE = 2

DIM SHARED scale AS INTEGER
DIM SHARED gxloaded AS INTEGER
DIM SHARED mapLoaded AS INTEGER
DIM SHARED mapFilename AS STRING
DIM SHARED tileSelStart AS GXPosition
DIM SHARED tileSelEnd AS GXPosition
DIM SHARED tileSelSizing AS INTEGER
DIM SHARED mapSelSizing AS INTEGER
DIM SHARED mapSelMode AS INTEGER
DIM SHARED saving AS INTEGER
DIM SHARED deleting AS INTEGER
DIM SHARED dialogMode AS INTEGER
DIM SHARED fileDialogMode AS INTEGER
DIM SHARED fileDialogPath AS STRING
DIM SHARED fileDialogTargetForm AS LONG
DIM SHARED fileDialogTargetField AS LONG
DIM SHARED lastControlClicked AS LONG
DIM SHARED lastClick AS DOUBLE

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
DIM SHARED MenuTileset AS LONG
DIM SHARED TilesetMenuReplace AS LONG

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

    ' Disable menu items which are not valid yet
    Control(ViewMenuZoomIn).Disabled = True
    Control(ViewMenuZoomOut).Disabled = True
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = True
    Control(TilesetMenuReplace).Disabled = True

    ' Create the GX Scene for rendering the map
    GXSceneEmbedded True
    GXSceneCreate Control(Map).Width / 2, Control(Map).Height / 2

    ' Initialize the file dialog
    fileDialogPath = _CWD$
    Control(chkFDFilterExt).Value = True

    ' Size the window components for the current window size
    dialogMode = False
    ResizePanels

    ' Ok, we're ready to display screen updates now
    gxloaded = True

    ' Set a higher frame rate for smoother cursor movement
    SetFrameRate 60
END SUB

SUB __UI_BeforeUpdateDisplay
    IF gxloaded = False THEN EXIT SUB ' We're not ready yet, abort!
    IF dialogMode = True THEN EXIT SUB ' Nothing to do here

    ' Use WASD or arrow keys to navigate around the map
    IF GXKeyDown(GXKEY_S) OR GXKeyDown(GXKEY_DOWN) THEN ' move down
        GXSceneMove 0, GXTilesetHeight
        IF mapSelMode THEN tileSelStart.y = tileSelStart.y - 1: tileSelEnd.y = tileSelEnd.y - 1

    ELSEIF GXKeyDown(GXKEY_W) OR GXKeyDown(GXKEY_UP) THEN ' move up
        GXSceneMove 0, -GXTilesetHeight
        IF mapSelMode THEN tileSelStart.y = tileSelStart.y + 1: tileSelEnd.y = tileSelEnd.y + 1

    ELSEIF GXKeyDown(GXKEY_D) OR GXKeyDown(GXKEY_RIGHT) THEN ' move right
        GXSceneMove GXTilesetWidth, 0
        IF mapSelMode THEN tileSelStart.x = tileSelStart.x - 1: tileSelEnd.x = tileSelEnd.x - 1

    ELSEIF GXKeyDown(GXKEY_A) OR GXKeyDown(GXKEY_LEFT) THEN ' move left
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

        CASE Map
            IF NOT mapSelSizing THEN
                PutTile
            ELSE
                mapSelSizing = False
            END IF

        CASE FileMenuNew
            SetDialogMode True
            Control(frmNewMap).Hidden = False
            _MOUSESHOW

        CASE FileMenuOpen
            ShowFileDialog FD_OPEN, MainForm

        CASE FileMenuSave
            SaveMap mapFilename

        CASE FileMenuSaveAs
            ShowFileDialog FD_SAVE, MainForm

        CASE FileMenuExit
            SYSTEM 0

        CASE ViewMenuZoomIn
            Zoom 1

        CASE ViewMenuZoomOut
            Zoom -1

        CASE TilesetMenuReplace
            dialogMode = True
            Control(frmReplaceTileset).Hidden = False
            Control(txtRTTileWidth).Value = GXTilesetWidth
            Control(txtRTTileHeight).Value = GXTilesetHeight
            SetDialogMode True
            _MOUSESHOW

        CASE btnRTCancel
            Control(frmReplaceTileset).Hidden = True
            SetDialogMode False

        CASE btnCancel
            Control(frmNewMap).Hidden = True
            SetDialogMode False

        CASE btnFDCancel
            Control(frmFile).Hidden = True
            SetDialogMode False

        CASE btnCreateMap
            CreateMap

        CASE btnReplaceTileset
            ReplaceTileset
            SetDialogMode False

        CASE btnSelectTilesetImage
            ShowFileDialog FD_OPEN, frmNewMap

        CASE btnRTSelectTilesetImage
            ShowFileDialog FD_OPEN, frmReplaceTileset

        CASE lstFDFiles
            Text(txtFDFilename) = GetItem(lstFDFiles, Control(lstFDFiles).Value)
            IF lastControlClicked = id AND TIMER - lastClick < .3 THEN ' Double-click
                OnSelectFile
            END IF

        CASE btnFDOK
            OnSelectFile

        CASE lstFDPaths
            IF lastControlClicked = id AND TIMER - lastClick < .3 THEN ' Double-click
                OnChangeDirectory
            END IF

    END SELECT
    lastControlClicked = id
    lastClick = TIMER
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id

        CASE Map
            IF NOT dialogMode AND mapLoaded THEN _MOUSEHIDE

        CASE Tiles
            IF NOT dialogMode AND mapLoaded THEN _MOUSEHIDE

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id

        CASE Map
            _MOUSESHOW

        CASE Tiles
            _MOUSESHOW

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
        CASE chkFDFilterExt
            RefreshFileList
    END SELECT
END SUB

SUB __UI_FormResized
    ' The window has been resized so resize the child components accordingly
    ResizePanels
END SUB


' GX Events
' ----------------------------------------------------------------------------
SUB GXOnGameEvent (e AS GXEvent)
    IF e.event = GXEVENT_PAINTBEFORE THEN BeginDraw Map
    IF e.event = GXEVENT_PAINTAFTER THEN EndDraw Map
    IF e.event = GXEVENT_DRAWSCREEN THEN
        IF mapSelMode THEN DrawSelected
        DrawCursor Map, scale
        ' draw a bounding rectangle around the border of the map
        LINE (-GXSceneX - 1, -GXSceneY - 1)-(GXMapColumns * GXTilesetWidth - GXSceneX, GXMapRows * GXTilesetHeight - GXSceneY), _RGB(100, 100, 100), B
    END IF
END SUB


' Create a new map from the parameters specified by the user
' on the new map dialog.
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
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = False
    Control(ViewMenuZoomIn).Disabled = False
    Control(ViewMenuZoomOut).Disabled = True
    Control(TilesetMenuReplace).Disabled = False
    Control(frmNewMap).Hidden = True

    SetDialogMode False
    mapLoaded = True

    ResizePanels
    SetStatus "Map created."
END SUB

SUB LoadMap (filename AS STRING)
    SetStatus "Loading map..."
    DIM msgRes AS INTEGER

    EnableFileDialog False
    GXMapLoad filename
    mapFilename = filename
    GXScenePos 0, 0

    Control(FileMenuSave).Disabled = False
    Control(FileMenuSaveAs).Disabled = False
    Control(ViewMenuZoomIn).Disabled = False
    Control(ViewMenuZoomOut).Disabled = True
    Control(TilesetMenuReplace).Disabled = False
    mapLoaded = True
    scale = 1

    Control(frmFile).Hidden = True
    SetDialogMode False
    EnableFileDialog True

    ResizePanels
    SetStatus "Map loaded."
END SUB

SUB SaveMap (filename AS STRING)
    SetStatus "Saving map..."
    EnableFileDialog False
    DIM msgResult AS INTEGER
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
    dialogMode = False
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

SUB SetStatus (msg AS STRING)
    SetCaption lblStatus, msg
END SUB

SUB Zoom (amount AS INTEGER)
    scale = scale + amount
    Control(ViewMenuZoomOut).Disabled = False
    IF scale = 1 THEN Control(ViewMenuZoomOut).Disabled = True
    IF scale = 4 THEN Control(ViewMenuZoomIn).Disabled = True
    ResizePanels
END SUB

SUB ResizePanels
    ' Position tileset control
    DIM twidth AS INTEGER
    twidth = GXTilesetColumns * GXTilesetWidth
    IF twidth = 0 THEN twidth = 200
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

' General Dialog Methods
' ----------------------------------------------------------------------------
SUB SetDialogMode (newDialogMode AS INTEGER)
    dialogMode = newDialogMode
    Control(FileMenu).Hidden = dialogMode
    Control(ViewMenu).Hidden = dialogMode
    Control(MenuTileset).Hidden = dialogMode
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
        msgRes = MessageBox("Please select a file.", "Invalid Option", MsgBox_OkOnly + MsgBox_Exclamation)
        EXIT SUB
    END IF

    filename = fileDialogPath + __GXFS_PathSeparator + filename

    IF fileDialogMode = FD_OPEN THEN
        IF NOT _FILEEXISTS(filename) THEN
            msgRes = MessageBox("File exists, overwrite existing file?", "Invalid Option", MsgBox_YesNo + MsgBox_Question)
            IF msgRes = MsgBox_Cancel THEN EXIT SUB
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
                    msgRes = MessageBox("File not found.", "Invalid Option", MsgBox_OkCancel + MsgBox_Exclamation)
                    EXIT SUB
                END IF

                SaveMap filename
        END SELECT
    END IF

END SUB


'$include:'../gx/gx.bm'
