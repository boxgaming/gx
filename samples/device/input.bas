Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
_Title "Test Device Input"

GXSceneCreate 500, 300
GXFrameRate 10

Dim Shared dleft As GXDeviceInput
Print "Press Left... ";
GXDeviceInputDetect dleft
PrintDeviceInput dleft

Dim Shared dright As GXDeviceInput
Print "Press Right...";
GXDeviceInputDetect dright
PrintDeviceInput dright

Dim Shared djump As GXDeviceInput
Print "Press Jump...";
GXDeviceInputDetect djump
PrintDeviceInput djump

GXSleep 1

'DIM test AS INTEGER
'test = _deviceinput(di.deviceId)

GXSceneStart

Sub GXOnGameEvent (e As GXEvent)
    Dim ldown As Integer
    Select Case e.event
        Case GXEVENT_DRAWSCREEN
            If GXDeviceInputTest(dleft) Then
                GXDrawText GXFONT_DEFAULT, 100, 100, "Left"
            End If
            If GXDeviceInputTest(dright) Then
                GXDrawText GXFONT_DEFAULT, 150, 100, "Right"
            End If
            If GXDeviceInputTest(djump) Then
                GXDrawText GXFONT_DEFAULT, 125, 125, "Jump"
            End If
    End Select
End Sub


Sub PrintDeviceInput (di As GXDeviceInput)
    Print GXDeviceName(di.deviceId) + " : ";
    Print GXInputTypeName(di.inputType) + " : ";
    Print Str$(di.inputId) + " : ";
    If di.deviceType = GXDEVICE_KEYBOARD Then
        Print " [ "; GXKeyButtonName(di.inputId); " ]";
    Else
        Print ;
    End If
    Print " : "; di.inputValue
    Print
End Sub

'$Include:'../../gx/gx.bm'
