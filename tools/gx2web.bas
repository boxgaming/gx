Option _Explicit
$Console:Only
$ExeIcon:'./../gx/resource/gx.ico'
'$Include: '../gx/gx.bi'

Dim Shared gameFullpath As String
Dim Shared gameFilename As String
Dim Shared gameDir As String
Dim Shared gameFolder As String
Dim Shared distDir As String
Dim Shared outputDir As String


gameFullpath = Command$
If Not _FileExists(gameFullpath) Then
    Print "File not found: [" + gameFullpath + "]"
    System
End If

gameFilename = GXFS_GetFilename(gameFullpath)
gameDir = GXFS_GetParentPath(gameFullpath)
gameFolder = GXFS_GetFilename(gameDir)
distDir = _CWD$ + GXFS_PathSeparator + "dist"
outputDir = distDir + GXFS_PathSeparator + gameFolder

Print "Converting game [" + gameFolder + "] from source [" + gameFilename + "] in directory [" + gameDir + "]..."

MakeOutputDir
ConvertSource
' TODO: create a more generic asset conversion method that
'       does not depend on the project folder structure
CopyFolder "img", "images"
CopyFolder "snd", "sounds"
'CopyFolder "qb64", "qb64"
ConvertMaps
CopyWebFramework

System

Sub MakeOutputDir
    Print "Preparing output directory [" + outputDir + "]"
    If Not _DirExists(distDir) Then MkDir distDir
    If _DirExists(outputDir) Then
        $If WIN Then
            Shell "rmdir /Q /S " + Chr$(32) + outputDir + Chr$(32)
        $Else
            Shell "rm -r " + Chr$(32) + outputDir + Chr$(32)
        $End If
    End If
    MkDir outputDir
End Sub

Sub ConvertSource
    Print "Converting QB64 to Javascript..."
    Shell "." + GXFS_PathSeparator + "qb2js " + Chr$(32) + gameFullpath + Chr$(32) + " > " + Chr$(32) + outputDir + GXFS_PathSeparator + "game.js" + Chr$(32)
End Sub

Sub CopyFolder (fname As String, description As String)
    Print "Copying " + description + "..."
    Dim srcDir As String
    srcDir = gameDir + GXFS_PathSeparator + fname
    If _DirExists(srcDir) Then
        Dim destDir As String
        destDir = outputDir + GXFS_PathSeparator + fname
        MkDir destDir

        $If WIN Then
            Shell "copy " + Chr$(32) + srcDir + GXFS_PathSeparator + "*" + Chr$(32) + " " + Chr$(32) + destDir + Chr$(32)
        $Else
            Shell "cp " + Chr$(32) + srcDir + GXFS_PathSeparator + "*" + Chr$(32) + " " + Chr$(32) + destDir + Chr$(32)
        $End If
    End If
End Sub

Sub ConvertMaps
    Print "Converting maps..."
    Dim mapDir As String
    mapDir = gameDir + GXFS_PathSeparator + "map"
    If _DirExists(mapDir) Then
        Dim mapDestDir As String
        mapDestDir = outputDir + GXFS_PathSeparator + "map"
        MkDir mapDestDir

        Dim fcount As Integer
        Dim mapFiles(0) As String
        fcount = GXFS_DirList(mapDir, 0, mapFiles())
        Dim i As Integer
        For i = 1 To fcount
            Print " -> " + mapFiles(i)
            Dim mapFullPath As String
            Dim mapDestPath As String
            mapFullPath = mapDir + GXFS_PathSeparator + mapFiles(i)
            mapDestPath = mapDestDir + GXFS_PathSeparator + mapFiles(i)
            Shell "." + GXFS_PathSeparator + "map2web " + Chr$(32) + mapFullPath + Chr$(32) + " " + Chr$(32) + mapDestPath + Chr$(32)
        Next i
    End If
End Sub

Sub CopyWebFramework
    Print "Copying web framework..."
    Dim webDir As String
    webDir = _CWD$ + GXFS_PathSeparator + "web"
    $If WIN Then
        Shell "xcopy /E " + Chr$(32) + webDir + Chr$(32) + " " + Chr$(32) + outputDir + Chr$(32)
    $Else
        Shell "cp -R " + Chr$(32) + webDir + Chr$(32) + " " + Chr$(32) + outputDir + Chr$(32)
    $End If

    ' Copy the default font images
    __gx_font_default
    __gx_font_default_black
    Print outputDir + GXFS_PathSeparator + "gx"
    MkDir outputDir + GXFS_PathSeparator + "gx"
    $If WIN Then
        Shell "copy tmp\__gx_font_default*.png " + Chr$(32) + outputDir + "\gx" + Chr$(32)
    $Else
        Shell "cp tmp/__gx_font_default*.png " + Chr$(32) + outputDir + "/gx" + Chr$(32)
    $End If

    ' Cleanup temp files
    Kill "tmp" + GXFS_PathSeparator + "__gx_font_default.png"
    Kill "tmp" + GXFS_PathSeparator + "__gx_font_default_black.png"
End Sub

Sub GXOnGameEvent (e As GXEvent): End Sub
'$Include: '../gx/gx.bm'
