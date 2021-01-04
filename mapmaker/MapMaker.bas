$EXEICON:'./map.ico'
'OPTION _EXPLICIT
'$include: './FileDialog.bi'
'$include: '../gx/gx.bi'
DIM SHARED scale AS INTEGER
DIM SHARED gxloaded AS INTEGER
DIM SHARED mapFilename AS STRING
DIM SHARED tileSelStart AS GXPosition
DIM SHARED tileSelEnd AS GXPosition
DIM SHARED tileSelSizing AS INTEGER
DIM SHARED mapSelSizing AS INTEGER
DIM SHARED mapSelMode AS INTEGER
DIM SHARED saving AS INTEGER

': This program uses
': InForm - GUI library for QB64 - v1.2
': Fellippe Heitor, 2016-2020 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------

': Controls' IDs: ------------------------------------------------------------------
DIM SHARED Form1 AS LONG
DIM SHARED FileMenu AS LONG
DIM SHARED ViewMenu AS LONG
DIM SHARED frmNewMap AS LONG
DIM SHARED PictureBox1 AS LONG
DIM SHARED FileMenuNew AS LONG
DIM SHARED Tiles AS LONG
DIM SHARED ViewMenuZoomIn AS LONG
DIM SHARED ViewMenuZoomOut AS LONG
DIM SHARED FileMenuOpen AS LONG
DIM SHARED FileMenuSave AS LONG
DIM SHARED lblColumns AS LONG
DIM SHARED lblRows AS LONG
DIM SHARED txtColumns AS LONG
DIM SHARED txtRows AS LONG
DIM SHARED lblTilesetImage AS LONG
DIM SHARED txtTilesetImage AS LONG
DIM SHARED btnSelectTilesetImage AS LONG
DIM SHARED lblIsometric AS LONG
DIM SHARED toggleIsometric AS LONG
DIM SHARED btnCreateMap AS LONG
DIM SHARED btnCancel AS LONG
DIM SHARED FileMenuSaveAs AS LONG
DIM SHARED FileMenuExit AS LONG
DIM SHARED CreateNewMapLB AS LONG
DIM SHARED TileWidthLB AS LONG
DIM SHARED lblTileHeight AS LONG
DIM SHARED txtTileWidth AS LONG
DIM SHARED txtTileHeight AS LONG
DIM SHARED frmReplaceTileset AS LONG
DIM SHARED lblTilesetImage2 AS LONG
DIM SHARED txtRTTilesetImage AS LONG
DIM SHARED btnRTSelectTilesetImage AS LONG
DIM SHARED btnReplaceTileset AS LONG
DIM SHARED btnRTCancel AS LONG
DIM SHARED CreateNewMapLB2 AS LONG
DIM SHARED TileWidthLB2 AS LONG
DIM SHARED lblTileHeight2 AS LONG
DIM SHARED txtRTTileWidth AS LONG
DIM SHARED txtRTTileHeight AS LONG
DIM SHARED MenuTileset AS LONG
DIM SHARED TilesetMenuReplace AS LONG

': External modules: ---------------------------------------------------------------
'$INCLUDE:'./inform/InForm.ui'
'$INCLUDE:'./inform/xp.uitheme'
'$INCLUDE:'MapMaker.frm'

': Event procedures: ---------------------------------------------------------------

SUB __UI_BeforeInit
END SUB

SUB __UI_OnLoad
    DIM x: x = _EXIT ' prevent window from closing
    ' TODO: look at using __UI_BeforeUnload instead

    SetFrameRate 60
    Control(frmNewMap).Hidden = True
    Control(frmReplaceTileset).Hidden = True

    scale = 1
    Control(ViewMenuZoomOut).Disabled = True
    Control(FileMenuSave).Disabled = True
    Control(FileMenuSaveAs).Disabled = True

    GXSceneEmbedded True
    GXSceneCreate Control(PictureBox1).Width / 2, Control(PictureBox1).Height / 2
    'GXTilesetCreate "img/pal16a.png", 16, 16
    'GXMapCreate 100, 20

    ResizePanels
    gxloaded = 1

END SUB

SUB __UI_BeforeUpdateDisplay
    'This event occurs at approximately 30 frames per second.
    'You can change the update frequency by calling SetFrameRate DesiredRate%
    IF gxloaded THEN
        IF _KEYDOWN(115) THEN
            GXSceneMove 0, GXTilesetHeight
            IF mapSelMode THEN tileSelStart.y = tileSelStart.y - 1: tileSelEnd.y = tileSelEnd.y - 1
        ELSEIF _KEYDOWN(119) THEN
            GXSceneMove 0, -GXTilesetHeight
            IF mapSelMode THEN tileSelStart.y = tileSelStart.y + 1: tileSelEnd.y = tileSelEnd.y + 1
        ELSEIF _KEYDOWN(100) THEN
            GXSceneMove GXTilesetWidth, 0
            IF mapSelMode THEN tileSelStart.x = tileSelStart.x - 1: tileSelEnd.x = tileSelEnd.x - 1
        ELSEIF _KEYDOWN(97) THEN
            GXSceneMove -GXTilesetWidth, 0
            IF mapSelMode THEN tileSelStart.x = tileSelStart.x + 1: tileSelEnd.x = tileSelEnd.x + 1
        END IF

        IF tileSelSizing THEN
            GetTilePosAt Tiles, _MOUSEX, _MOUSEY, 1, tileSelEnd
        ELSEIF mapSelSizing THEN
            GetTilePosAt PictureBox1, _MOUSEX, _MOUSEY, scale, tileSelEnd
        END IF

        GXSceneDraw
        DrawTileset
        BeginDraw Tiles
        IF NOT mapSelMode THEN DrawSelected
        DrawCursor Tiles, 1
        EndDraw Tiles
    END IF

    IF _EXIT AND NOT saving THEN SYSTEM
END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.

END SUB

SUB __UI_Click (id AS LONG)
    DIM filename AS STRING, msgResult

    SELECT CASE id
        CASE Form1

        CASE FileMenu

        CASE PictureBox1
            IF NOT mapSelSizing THEN
                IF _KEYDOWN(GXKEY_DEL) OR _KEYDOWN(120) THEN
                    DeleteTile
                ELSE
                    PutTile
                END IF
            ELSE
                mapSelSizing = False
            END IF

        CASE Tiles
            'SelectTile

        CASE FileMenuNew
            Control(frmNewMap).Hidden = False

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
            msgResult = MessageBox("Map saved.", "", MsgBox_OkOnly)
            'filename = GetSaveFileName("Save Game Map", ".\", "Map Files (*.map)|*.map", 1, OFN_OVERWRITEPROMPT + OFN_NOCHANGEDIR)
            'IF filename <> "" THEN
            '    GXMapSave filename
            'END IF

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
            Control(frmReplaceTileset).Hidden = False
            Control(txtRTTileWidth).Value = GXTilesetWidth
            Control(txtRTTileHeight).Value = GXTilesetHeight

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
        CASE Form1

        CASE FileMenu

        CASE PictureBox1
            _MOUSEHIDE

        CASE Tiles
            _MOUSEHIDE

        CASE FileMenuNew

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE Form1

        CASE FileMenu

        CASE PictureBox1
            _MOUSESHOW

        CASE Tiles
            _MOUSESHOW

        CASE FileMenuNew

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        'CASE ListBox1

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        'CASE ListBox1

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE Form1

        CASE FileMenu

        CASE PictureBox1
            IF _KEYDOWN(100304) THEN
                mapSelMode = True
                mapSelSizing = True
                GetTilePosAt PictureBox1, _MOUSEX, _MOUSEY, scale, tileSelStart
                tileSelEnd = tileSelStart
            END IF

        CASE FileMenuNew

        CASE Tiles
            mapSelMode = False
            tileSelSizing = True
            GetTilePosAt Tiles, _MOUSEX, _MOUSEY, 1, tileSelStart
            tileSelEnd = tileSelStart

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE Form1

        CASE FileMenu

        CASE PictureBox1

        CASE FileMenuNew

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
    ResizePanels
END SUB

SUB CreateMap
    DIM columns AS INTEGER, rows AS INTEGER
    DIM tilesetImage AS STRING
    DIM tileWidth AS INTEGER, tileHeight AS INTEGER
    DIM isometric AS INTEGER

    columns = Control(txtColumns).Value
    rows = Control(txtRows).Value
    tilesetImage = Text(txtTilesetImage)
    tileWidth = Control(txtTileWidth).Value
    tileHeight = Control(txtTileHeight).Value
    isometric = Control(toggleIsometric).Value

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
END SUB

SUB ReplaceTileset
    DIM tilesetImage AS STRING
    DIM tileWidth AS INTEGER, tileHeight AS INTEGER

    tilesetImage = Text(txtRTTilesetImage)
    tileWidth = Control(txtRTTileWidth).Value
    tileHeight = Control(txtRTTileHeight).Value

    GXTilesetCreate tilesetImage, tileWidth, tileHeight
    Control(frmReplaceTileset).Hidden = True
END SUB


SUB PutTile ()
    DIM x AS INTEGER, y AS INTEGER, sx AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    DIM mtx AS INTEGER, mty AS INTEGER
    DIM tile AS INTEGER

    sx = FIX((_MOUSEX / scale - Control(PictureBox1).Left + GXSceneX) / GXTilesetWidth)
    y = FIX((_MOUSEY / scale - Control(PictureBox1).Top + GXSceneY) / GXTilesetHeight)
    'DIM tpos AS GXPosition
    'GetTilePosAt PictureBox1, _MOUSEX, _MOUSEY, scale, tpos
    'sx = tpos.x
    'y = tpos.y


    FOR ty = tileSelStart.y TO tileSelEnd.y
        x = sx
        FOR tx = tileSelStart.x TO tileSelEnd.x
            IF mapSelMode THEN
                mtx = tx + GXSceneX / GXTilesetWidth
                mty = ty + GXSceneY / GXTilesetHeight
                tile = GXMapTile(mtx, mty, GXMapTileDepth(mtx, mty))
            ELSE
                tile = tx + ty * GXTilesetColumns
            END IF
            GXMapTileAdd tile, x, y
            x = x + 1
        NEXT tx
        y = y + 1
    NEXT ty
END SUB

SUB DeleteTile ()
    DIM x AS INTEGER, y AS INTEGER, sx AS INTEGER, sy AS INTEGER
    DIM tx AS INTEGER, ty AS INTEGER
    sx = FIX((_MOUSEX / scale - Control(PictureBox1).Left + GXSceneX) / GXTilesetWidth)
    y = FIX((_MOUSEY / scale - Control(PictureBox1).Top + GXSceneY) / GXTilesetHeight)

    'IF mapSelMode = True THEN
    FOR ty = tileSelStart.y TO tileSelEnd.y
        x = sx
        FOR tx = tileSelStart.x TO tileSelEnd.x
            GXMapTileRemove x, y
            x = x + 1
        NEXT tx
        y = y + 1
    NEXT ty
    'ELSE
    '    GXMapTileRemove sx, y
    'END IF

END SUB

SUB SelectTile ()
    DIM x AS INTEGER, y AS INTEGER
    DIM cx AS INTEGER, cy AS INTEGER
    x = _MOUSEX - Control(Tiles).Left
    y = _MOUSEY - Control(Tiles).Top
    cx = FIX(x / GXTilesetWidth)
    cy = FIX(y / GXTilesetHeight)
    'selectedTile = cx + cy * GXTilesetColumns
END SUB

SUB DrawCursor (id AS LONG, scale AS INTEGER)
    'DIM x AS INTEGER, y AS INTEGER
    DIM cx AS INTEGER, cy AS INTEGER
    DIM endx AS INTEGER, endy AS INTEGER
    DIM tpos AS GXPosition
    GetTilePosAt id, _MOUSEX, _MOUSEY, scale, tpos
    'x = _MOUSEX / scale - Control(id).Left
    'y = _MOUSEY / scale - Control(id).Top
    '_PRINTSTRING (1, 1), STR$(x)
    'cx = FIX(x / GXTilesetWidth) * GXTilesetWidth
    'cy = FIX(y / GXTilesetHeight) * GXTilesetHeight
    cx = tpos.x * GXTilesetWidth
    cy = tpos.y * GXTilesetHeight

    IF (id = PictureBox1 AND NOT mapSelSizing) THEN
        endx = (tpos.x + tileSelEnd.x - tileSelStart.x + 1) * GXTilesetWidth
        endy = (tpos.y + tileSelEnd.y - tileSelStart.y + 1) * GXTilesetHeight
    ELSE
        endx = cx + GXTilesetWidth
        endy = cy + GXTilesetHeight
    END IF

    'LINE (cx, cy)-(cx + GXTilesetWidth, cy + GXTilesetHeight), _RGB(255, 255, 255), B
    LINE (cx, cy)-(endx, endy), _RGB(255, 255, 255), B
END SUB

SUB GetTilePosAt (id AS LONG, x AS INTEGER, y AS INTEGER, scale AS INTEGER, tpos AS GXPosition)
    x = _MOUSEX / scale - Control(id).Left
    y = _MOUSEY / scale - Control(id).Top
    tpos.x = FIX(x / GXTilesetWidth)
    tpos.y = FIX(y / GXTilesetHeight)
END SUB

SUB DrawSelected
    'DIM tpos AS GXPosition, tx AS INTEGER, ty AS INTEGER
    'GXTilesetGetPos selectedTile, tpos
    'tx = (tpos.x - 1) * GXTilesetWidth
    'ty = (tpos.y - 1) * GXTilesetHeight
    'LINE (tx, ty)-(tx + GXTilesetWidth, ty + GXTilesetWidth), _RGB(255, 255, 0), B
    DIM startx AS INTEGER, starty AS INTEGER, endx AS INTEGER, endy AS INTEGER
    startx = tileSelStart.x * GXTilesetWidth
    starty = tileSelStart.y * GXTilesetHeight
    endx = tileSelEnd.x * GXTilesetWidth + GXTilesetWidth
    endy = tileSelEnd.y * GXTilesetHeight + GXTilesetHeight
    LINE (startx, starty)-(endx, endy), _RGB(255, 255, 0), B
END SUB

SUB DrawTileset
    DIM tcols AS INTEGER, trow AS INTEGER, tx AS INTEGER, ty AS INTEGER, tcol AS INTEGER
    DIM tilesPerRow AS INTEGER, totalTiles AS INTEGER
    DIM tpos AS GXPosition
    DIM i AS INTEGER
    tilesPerRow = FIX(Control(Tiles).Width / GXTilesetWidth)
    totalTiles = GXTilesetColumns * GXTilesetRows
    DIM img AS LONG
    img = GXTilesetImage
    BeginDraw Tiles
    'LINE (0, 0)-(Control(Tiles).Width, Control(Tiles).Height), _RGB(0, 0, 0), BF
    'tcol = 0
    'FOR i = 1 TO totalTiles
    '    tx = tcol * GXTilesetWidth
    '    GXTilesetGetPos i, tpos
    '    GXSpriteDraw img, tx, ty, tpos.y, tpos.x, GXTilesetWidth, GXTilesetHeight, 0

    '    tcol = tcol + 1
    '    IF tcol = tilesPerRow - 1 THEN
    '        tcol = 0
    '        ty = ty + GXTilesetHeight
    '    END IF

    'NEXT i
    '_PRINTSTRING (0, 0), STR$(tilesPerRow)
    CLS
    FOR trow = 1 TO GXTilesetRows
        tx = 0
        FOR tcol = 1 TO GXTilesetColumns
            GXSpriteDraw img, tx, ty, trow, tcol, GXTilesetWidth, GXTilesetHeight, 0
            tx = tx + GXTilesetWidth
        NEXT tcol
        ty = ty + GXTilesetHeight
    NEXT trow
    '_PRINTSTRING (0, 0), STR$(ty)
    EndDraw Tiles
END SUB

SUB ResizePanels
    DIM twidth AS INTEGER
    twidth = GXTilesetColumns * GXTilesetWidth
    IF twidth = 0 THEN twidth = 200
    Control(Tiles).Top = 23
    Control(Tiles).Width = twidth
    Control(Tiles).Left = Control(Form1).Width - twidth
    Control(Tiles).Height = Control(Form1).Height - 23
    LoadImage Control(Tiles), ""

    Control(PictureBox1).Left = 0
    Control(PictureBox1).Top = 23
    Control(PictureBox1).Width = Control(Form1).Width - twidth - 1
    Control(PictureBox1).Height = Control(Form1).Height - 23
    GXSceneResize Control(PictureBox1).Width / scale, Control(PictureBox1).Height / scale
    LoadImage Control(PictureBox1), ""

    ResizeDialog frmNewMap
    ResizeDialog frmReplaceTileset
END SUB

SUB ResizeDialog (dialogId AS LONG)
    Control(dialogId).Left = 0
    Control(dialogId).Top = 0
    Control(dialogId).Width = Control(Form1).Width
    Control(dialogId).Height = Control(Form1).Height
END SUB


SUB GXOnGameEvent (e AS GXEvent)
    IF e.event = GXEVENT_PAINTBEFORE THEN BeginDraw PictureBox1
    IF e.event = GXEVENT_PAINTAFTER THEN EndDraw PictureBox1
    IF e.event = GXEVENT_DRAWSCREEN THEN
        IF mapSelMode THEN DrawSelected
        DrawCursor PictureBox1, scale
        LINE (-GXSceneX, -GXSceneY)-(GXMapColumns * GXTilesetWidth - GXSceneX + 1, GXMapRows * GXTilesetHeight - GXSceneY + 1), _RGB(100, 100, 100), B
    END IF
END SUB

'$include: './FileDialog.bm'
'$INCLUDE:'../gx/gx.bm'









