Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
_Title "Detect Device Input"

Print "Waiting for input..."
Do
    Dim di As GXDeviceInput
    GXDeviceInputDetect di
    Cls
    Print "Device #:    "; di.deviceId
    Print "Device Name: "; GXDeviceName(di.deviceId)
    Print "Device Type: "; GXDeviceTypeName(di.deviceType)
    Print "Input Type:  "; GXInputTypeName(di.inputType)
    Print "Input Id:    "; di.inputId;
    If di.deviceType = GXDEVICE_KEYBOARD Then
        Print " [ "; GXKeyButtonName(di.inputId); " ]"
    Else
        Print
    End If
    Print "Input Value: "; di.inputValue
    Print
Loop

Sub GXOnGameEvent (e As GXEvent): End Sub
'$Include:'../../gx/gx.bm'
