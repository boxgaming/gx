OPTION _EXPLICIT
$EXEICON:'./../../gx/resource/gx.ico'
'$include: '../../gx/gx.bi'
_TITLE "Test Device Input"

GXSceneCreate 500, 300
GXFrameRate 10

DIM SHARED dleft AS GXDeviceInput
PRINT "Press Left... ";
GXDeviceInputDetect dleft
PrintDeviceInput dleft

DIM SHARED dright AS GXDeviceInput
PRINT "Press Right...";
GXDeviceInputDetect dright
PrintDeviceInput dright

DIM SHARED djump AS GXDeviceInput
PRINT "Press Jump...";
GXDeviceInputDetect djump
PrintDeviceInput djump

GXSleep 1

'DIM test AS INTEGER
'test = _deviceinput(di.deviceId)

GXSceneStart

SUB GXOnGameEvent (e AS GXEvent)
    DIM ldown AS INTEGER
    SELECT CASE e.event
        CASE GXEVENT_DRAWSCREEN
            IF GXDeviceInputTest(dleft) THEN
                GXDrawText GXFONT_DEFAULT, 100, 100, "Left"
            END IF
            IF GXDeviceInputTest(dright) THEN
                GXDrawText GXFONT_DEFAULT, 150, 100, "Right"
            END IF
            IF GXDeviceInputTest(djump) THEN
                GXDrawText GXFONT_DEFAULT, 125, 125, "Jump"
            END IF
    END SELECT
END SUB


SUB PrintDeviceInput (di AS GXDeviceInput)
    PRINT GXDeviceName(di.deviceId) + " : ";
    PRINT GXInputTypeName(di.inputType) + " : ";
    PRINT STR$(di.inputId) + " : ";
    IF di.deviceType = GXDEVICE_KEYBOARD THEN
        PRINT " [ "; GXKeyButtonName(di.inputId); " ]";
    ELSE
        PRINT ;
    END IF
    PRINT " : "; di.inputValue
    PRINT
END SUB

'$include: '../../gx/gx.bm'
