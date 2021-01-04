' Dialog flag constants (use + or OR to use more than 1 flag value)
CONST OFN_ALLOWMULTISELECT = &H200& '  Allows the user to select more than one file, not recommended!
CONST OFN_CREATEPROMPT = &H2000& '     Prompts if a file not found should be created(GetOpenFileName only).
CONST OFN_EXTENSIONDIFFERENT = &H400& 'Allows user to specify file extension other than default extension.
CONST OFN_FILEMUSTEXIST = &H1000& '    Chechs File name exists(GetOpenFileName only).
CONST OFN_HIDEREADONLY = &H4& '        Hides read-only checkbox(GetOpenFileName only)
CONST OFN_NOCHANGEDIR = &H8& '         Restores the current directory to original value if user changed
CONST OFN_NODEREFERENCELINKS = &H100000& 'Returns path and file name of selected shortcut(.LNK) file instead of file referenced.
CONST OFN_NONETWORKBUTTON = &H20000& ' Hides and disables the Network button.
CONST OFN_NOREADONLYRETURN = &H8000& ' Prevents selection of read-only files, or files in read-only subdirectory.
CONST OFN_NOVALIDATE = &H100& '        Allows invalid file name characters.
CONST OFN_OVERWRITEPROMPT = &H2& '     Prompts if file already exists(GetSaveFileName only)
CONST OFN_PATHMUSTEXIST = &H800& '     Checks Path name exists (set with OFN_FILEMUSTEXIST).
CONST OFN_READONLY = &H1& '            Checks read-only checkbox. Returns if checkbox is checked
CONST OFN_SHAREAWARE = &H4000& '       Ignores sharing violations in networking
CONST OFN_SHOWHELP = &H10& '           Shows the help button (useless!)
'--------------------------------------------------------------------------------------------

DEFINT A-Z 'not recommended to use this statement in a final application!

TYPE FILEDIALOGTYPE
    $IF 32BIT THEN
    lStructSize AS LONG '        For the DLL call
    hwndOwner AS LONG '          Dialog will hide behind window when not set correctly
    hInstance AS LONG '          Handle to a module that contains a dialog box template.
    lpstrFilter AS _OFFSET '     Pointer of the string of file filters
    lpstrCustFilter AS _OFFSET
    nMaxCustFilter AS LONG
    nFilterIndex AS LONG '       One based starting filter index to use when dialog is called
    lpstrFile AS _OFFSET '       String full of 0's for the selected file name
    nMaxFile AS LONG '           Maximum length of the string stuffed with 0's minus 1
    lpstrFileTitle AS _OFFSET '  Same as lpstrFile
    nMaxFileTitle AS LONG '      Same as nMaxFile
    lpstrInitialDir AS _OFFSET ' Starting directory
    lpstrTitle AS _OFFSET '      Dialog title
    flags AS LONG '              Dialog flags
    nFileOffset AS INTEGER '     Zero-based offset from path beginning to file name string pointed to by lpstrFile
    nFileExtension AS INTEGER '  Zero-based offset from path beginning to file extension string pointed to by lpstrFile.
    lpstrDefExt AS _OFFSET '     Default/selected file extension
    lCustData AS LONG
    lpfnHook AS LONG
    lpTemplateName AS _OFFSET
    $ELSE
        lStructSize AS _OFFSET '      For the DLL call
        hwndOwner AS _OFFSET '        Dialog will hide behind window when not set correctly
        hInstance AS _OFFSET '        Handle to a module that contains a dialog box template.
        lpstrFilter AS _OFFSET '      Pointer of the string of file filters
        lpstrCustFilter AS LONG
        nMaxCustFilter AS LONG
        nFilterIndex AS _INTEGER64 '  One based starting filter index to use when dialog is called
        lpstrFile AS _OFFSET '        String full of 0's for the selected file name
        nMaxFile AS _OFFSET '         Maximum length of the string stuffed with 0's minus 1
        lpstrFileTitle AS _OFFSET '   Same as lpstrFile
        nMaxFileTitle AS _OFFSET '    Same as nMaxFile
        lpstrInitialDir AS _OFFSET '  Starting directory
        lpstrTitle AS _OFFSET '       Dialog title
        flags AS _INTEGER64 '         Dialog flags
        nFileOffset AS _INTEGER64 '   Zero-based offset from path beginning to file name string pointed to by lpstrFile
        nFileExtension AS _INTEGER64 'Zero-based offset from path beginning to file extension string pointed to by lpstrFile.
        lpstrDefExt AS _OFFSET '      Default/selected file extension
        lCustData AS _INTEGER64
        lpfnHook AS _INTEGER64
        lpTemplateName AS _OFFSET
    $END IF
END TYPE

DECLARE DYNAMIC LIBRARY "comdlg32" ' Library declarations using _OFFSET types
    FUNCTION GetOpenFileNameA& (DIALOGPARAMS AS FILEDIALOGTYPE) ' The Open file dialog
    FUNCTION GetSaveFileNameA& (DIALOGPARAMS AS FILEDIALOGTYPE) ' The Save file dialog
END DECLARE

