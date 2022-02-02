Option _Explicit
$ExeIcon:'./../../gx/resource/gx.ico'
'$Include:'../../gx/gx.bi'
_Title "Detect Device Input"

Print "Waiting for input..."
Do
    Dim di As GXDeviceInput
    GXDeviceInputDetect di
    Cls
    Print "Device #:    " + Str$(di.deviceId)
    Print "Device Name: " + GXDeviceName(di.deviceId)
    Print "Device Type: " + GXDeviceTypeName(di.deviceType)
    Print "Input Type:  " + GXInputTypeName(di.inputType)
    Print "Input Id:    " + Str$(di.inputId)
    If di.deviceType = GXDEVICE_KEYBOARD Then
        Print "Key Name: " + GXKeyButtonName(di.inputId)
    End If
    Print "Input Value: " + Str$(di.inputValue)
    Print
Loop

Sub GXOnGameEvent (e As GXEvent): End Sub
'$Include:'../../gx/gx.bm'
