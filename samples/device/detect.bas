OPTION _EXPLICIT
$EXEICON:'./../../gx/resource/gx.ico'
'$include: '../../gx/gx.bi'
_TITLE "Detect Device Input"

PRINT "Waiting for input..."
DO
    DIM di AS GXDeviceInput
    GXDeviceInputDetect di
    CLS
    PRINT "Device #:    "; di.deviceId
    PRINT "Device Name: "; GXDeviceName(di.deviceId)
    PRINT "Device Type: "; GXDeviceTypeName(di.deviceType)
    PRINT "Input Type:  "; GXInputTypeName(di.inputType)
    PRINT "Input Id:    "; di.inputId;
    IF di.deviceType = GXDEVICE_KEYBOARD THEN
        PRINT " [ "; GXKeyButtonName(di.inputId); " ]"
    ELSE
        PRINT
    END IF
    PRINT "Input Value: "; di.inputValue
    PRINT
LOOP

SUB GXOnGameEvent (e AS GXEvent): END SUB
'$include: '../../gx/gx.bm'
