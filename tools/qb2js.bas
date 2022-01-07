Option _Explicit
$Console:Only
$ExeIcon:'./../gx/resource/gx.ico'

Const False = 0
Const True = Not False

Type Method
    line As Integer
    type As String
    returnType As String
    name As String
    uname As String
    argc As Integer
    args As String
    jsname As String
End Type

Type Argument
    name As String
    type As String
End Type

Type QBType
    line As Integer
    name As String
    argc As Integer
    args As String
End Type

Type Variable
    type As String
    name As String
    jsname As String
    isConst As Integer
    isArray As Integer
    arraySize As Integer
    typeId As Integer
End Type

ReDim Shared lines(0) As String
ReDim Shared methods(0) As Method
ReDim Shared types(0) As QBType
ReDim Shared typeVars(0) As Variable
ReDim Shared globalVars(0) As Variable
ReDim Shared localVars(0) As Variable
Dim Shared currentMethod As String
Dim Shared programMethods As Integer

ReadLines Command$
FindMethods
programMethods = UBound(methods)
InitGX
InitQB64Methods

Print "async function init() {"
Dim mtest As Method
If FindMethod("GXOnGameEvent", mtest, "SUB") Then
    Print "    await GX.registerGameEvents(sub_GXOnGameEvent);"
Else
    Print "    await GX.registerGameEvents(function(e){});"
    Print "    QB64.sub_Screen(0);"
    Print
End If
Print ""
ConvertLines 1, MainEnd, ""
ConvertMethods
Print "}"

System

Sub ConvertLines (firstLine As Integer, lastLine As Integer, functionName As String)
    Dim typeMode As Integer: typeMode = False
    Dim i As Integer
    Dim indent As Integer
    Dim tempIndent As Integer
    Dim m As Method
    Dim totalIndent As Integer
    totalIndent = 1
    Dim caseCount As Integer
    Dim loopMode(10) As Integer ' TODO: only supports 10 levels of do/loop nesting
    Dim loopLevel As Integer
    For i = firstLine To lastLine
        indent = 0
        tempIndent = 0
        Dim l As String
        l = _Trim$(lines(i))
        ReDim parts(0) As String
        Dim c As Integer
        c = SLSplit(l, parts())

        Dim currType As Integer

        Dim js As String
        js = ""
        Dim first As String
        first = UCase$(parts(1))

        If typeMode = True Then
            If first = "END" Then
                Dim second As String: second = UCase$(parts(2))
                If second = "TYPE" Then
                    typeMode = False
                End If
            Else
                Dim tvar As Variable
                tvar.typeId = currType
                tvar.name = parts(1)
                tvar.type = UCase$(parts(3))
                AddVariable tvar, typeVars()
            End If
        Else
            If first = "CONST" Then
                js = "const " + parts(2) + " = " + ConvertExpression(Join(parts(), 4, -1, " ")) + ";"
                AddConst parts(2)

            ElseIf first = "DIM" Or first = "REDIM" Or first = "STATIC" Then
                js = DeclareVar(parts())


            ElseIf first = "SELECT" Then
                js = "switch (" + ConvertExpression(Join(parts(), 3, -1, " ")) + ") {"
                indent = 1
                caseCount = 0

            ElseIf first = "CASE" Then
                If caseCount > 0 Then js = "break;" + GX_LF
                If UCase$(parts(2)) = "ELSE" Then
                    js = js + "default:"
                Else
                    js = js + "case " + ConvertExpression(parts(2)) + ":"
                End If
                caseCount = caseCount + 1

            ElseIf first = "FOR" Then
                Dim fstep As String: fstep = "1"
                Dim eqIdx As Integer
                Dim toIdx As Integer
                Dim stepIdx As Integer
                Dim fcond As String: fcond = " <= "
                stepIdx = 0
                Dim fi As Integer
                For fi = 2 To UBound(parts)
                    Dim fword As String
                    fword = UCase$(parts(fi))
                    If fword = "=" Then
                        eqIdx = fi
                    ElseIf fword = "TO" Then
                        toIdx = fi
                    ElseIf fword = "STEP" Then
                        stepIdx = fi
                        fstep = ConvertExpression(Join(parts(), fi + 1, -1, " "))
                    End If
                Next fi
                Dim fvar As String
                fvar = ConvertExpression(Join(parts(), 2, eqIdx - 1, " "))
                Dim sval As String
                sval = ConvertExpression(Join(parts(), eqIdx + 1, toIdx - 1, " "))
                Dim uval As String
                uval = ConvertExpression(Join(parts(), toIdx + 1, stepIdx - 1, " "))

                If Val(fstep) < 0 Then fcond = " >= "

                js = "for (" + fvar + "=" + sval + "; " + fvar + fcond + uval + "; " + fvar + "=" + fvar + " + " + fstep + ") {"


                'If UBound(parts) = 8 Then fstep = parts(8)
                'js = "for (" + parts(2) + "=" + parts(4) + "; " + parts(2) + " <= " + ConvertExpression(parts(6)) + "; " + parts(2) + "=" + parts(2) + "+" + fstep + ") {"
                indent = 1

            ElseIf first = "IF" Then
                Dim thenIndex As Integer
                For thenIndex = 2 To UBound(parts)
                    If UCase$(parts(thenIndex)) = "THEN" Then Exit For
                Next thenIndex

                js = "if (" + ConvertExpression(Join(parts(), 2, thenIndex - 1, " ")) + ") {"
                indent = 1

            ElseIf first = "ELSEIF" Then
                js = "} else if (" + ConvertExpression(Join(parts(), 2, UBound(parts) - 1, " ")) + ") {"
                tempIndent = -1

            ElseIf first = "ELSE" Then
                js = "} else {"
                tempIndent = -1

            ElseIf first = "NEXT" Then
                js = js + "}"
                indent = -1

            ElseIf first = "END" Then

                If UCase$(parts(2)) = "SELECT" Then js = "break;"
                js = js + "}"
                indent = -1

            ElseIf first = "DO" Then
                loopLevel = loopLevel + 1
                If UBound(parts) > 1 Then
                    If UCase$(parts(2)) = "WHILE" Then
                        js = "while (" + ConvertExpression(Join(parts(), 3, -1, " ")) + ") {"
                    Else
                        js = "while (!(" + ConvertExpression(Join(parts(), 3, -1, " ")) + ")) {"
                    End If
                    loopMode(loopLevel) = 1
                Else
                    js = "do {"
                    loopMode(loopLevel) = 2
                End If
                indent = 1

            ElseIf first = "LOOP" Then
                If loopMode(loopLevel) = 1 Then
                    js = "}"
                Else
                    js = "} while (("
                    If UBound(parts) < 2 Then
                        js = js + "1));"
                    Else
                        If UCase$(parts(2)) = "UNTIL" Then js = "} while (!("
                        js = js + ConvertExpression(Join(parts(), 3, UBound(parts), " ")) + "))"
                    End If
                End If
                loopLevel = loopLevel - 1
                indent = -1

            ElseIf first = "_CONTINUE" Then
                js = "continue;"

            ElseIf UCase$(l) = "EXIT FUNCTION" Then
                js = "return " + functionName + ";"

            ElseIf UCase$(l) = "EXIT SUB" Then
                js = "return;"

            ElseIf first = "EXIT" Then
                js = "break;"

            ElseIf first = "TYPE" Then
                typeMode = True
                Dim qbtype As QBType
                qbtype.line = i
                qbtype.name = UCase$(parts(2))
                AddType qbtype
                currType = UBound(types)


            ElseIf c > 2 Then
                Dim assignment As Integer
                assignment = 0
                Dim j As Integer
                For j = 1 To UBound(parts)
                    If parts(j) = "=" Then assignment = j
                Next j

                'If parts(2) = "=" Then
                If assignment > 0 Then
                    'This is a variable assignment
                    js = RemoveSuffix(ConvertExpression(Join(parts(), 1, assignment - 1, " "))) + " = " + ConvertExpression(Join(parts(), assignment + 1, -1, " ")) + ";"

                Else
                    If FindMethod(parts(1), m, "SUB") Then
                        js = ConvertSub(m, Join(parts(), 2, -1, " "))
                    Else
                        js = "// " + l
                    End If
                End If
            Else
                If FindMethod(parts(1), m, "SUB") Then
                    js = ConvertSub(m, Join(parts(), 2, -1, " "))
                Else
                    js = "// " + l
                End If
            End If

            If (indent < 0) Then totalIndent = totalIndent + indent
            Print GXSTR_LPad("", " ", (totalIndent + tempIndent) * 3) + js
            If (indent > 0) Then totalIndent = totalIndent + indent

        End If

    Next i

End Sub

Function ConvertSub$ (m As Method, args As String)
    ' This actually converts the parameters passed to the sub
    Dim js As String

    ' Let's handle the weirdo Line Input command which has a space
    If m.name = "Line" Then
        Dim parts(0) As String
        Dim plen As Integer
        plen = SLSplit(args, parts())
        If plen > 0 Then
            If UCase$(parts(1)) = "INPUT" Then
                m.name = "Line Input"
                m.jsname = "sub_LineInput"
                args = Join(parts(), 2, -1, " ")
            End If
        End If
    End If

    ' Handle special cases for methods which take ranges and optional parameters
    If m.name = "Line" Or m.name = "LineInput" Then
        js = m.jsname + "(" + ConvertLine(args) + ");"

    ElseIf m.name = "_PrintString" Then
        js = m.jsname + "(" + ConvertPrintString(args) + ");"

    ElseIf m.name = "Input" Then
        js = ConvertInput(m, args)

    Else
        js = m.jsname + "(" + ConvertExpression(args) + ");"
    End If

    ConvertSub = js
End Function

Function ConvertLine$ (args As String)
    ' TODO: This does not yet handle dash patterns
    Dim firstParam As String
    Dim theRest As String
    Dim idx As Integer
    Dim sstep As String
    Dim estep As String
    sstep = "false"
    estep = "false"

    idx = FindParamChar(args, ",")
    If idx = -1 Then
        firstParam = args
        theRest = ""
    Else
        firstParam = Left$(args, idx - 1)
        theRest = Right$(args, Len(args) - idx)
    End If

    idx = FindParamChar(firstParam, "-")
    Dim startCord As String
    Dim endCord As String
    If idx = -1 Then
        endCord = firstParam
    Else
        startCord = Left$(firstParam, idx - 1)
        endCord = Right$(firstParam, Len(firstParam) - idx)
    End If

    If UCase$(_Trim$(Left$(startCord, 4))) = "STEP" Then
        sstep = "true"
    End If
    If UCase$(_Trim$(Left$(endCord, 4))) = "STEP" Then
        estep = "true"
    End If

    idx = InStr(startCord, "(")
    startCord = Right$(startCord, Len(startCord) - idx)
    idx = _InStrRev(startCord, ")")
    startCord = Left$(startCord, idx - 1)
    startCord = ConvertExpression(startCord)
    If (_Trim$(startCord) = "") Then startCord = "undefined, undefined"

    idx = InStr(endCord, "(")
    endCord = Right$(endCord, Len(endCord) - idx)
    idx = _InStrRev(endCord, ")")
    endCord = Left$(endCord, idx - 1)
    endCord = ConvertExpression(endCord)

    theRest = ConvertExpression(theRest)
    theRest = GXSTR_Replace(theRest, " BF", " " + Chr$(34) + "BF" + Chr$(34))
    theRest = GXSTR_Replace(theRest, " B", " " + Chr$(34) + "B" + Chr$(34))

    ConvertLine = sstep + ", " + startCord + ", " + estep + ", " + endCord + "," + theRest
End Function

Function ConvertPrintString$ (args As String)
    Dim firstParam As String
    Dim theRest As String
    Dim idx As Integer

    idx = FindParamChar(args, ",")
    If idx = -1 Then
        firstParam = args
        theRest = ""
    Else
        firstParam = Left$(args, idx - 1)
        theRest = Right$(args, Len(args) - idx)
    End If

    idx = InStr(firstParam, "(")
    firstParam = Right$(firstParam, Len(firstParam) - idx)
    idx = _InStrRev(firstParam, ")")
    firstParam = Left$(firstParam, idx - 1)

    ConvertPrintString = ConvertExpression(firstParam) + ", " + ConvertExpression(theRest)
End Function

Function ConvertInput$ (m As Method, args As String)
    Dim js As String
    Dim vname As String
    vname = "___i" + _Trim$(Str$(_Round(Rnd * 10000000)))
    js = "var " + vname + " = new Array(1);" + GX_CRLF
    js = js + m.jsname + "(" + vname + ");" + GX_CRLF
    js = js + ConvertExpression(args) + " = " + vname + "[0];"
    ConvertInput = js
End Function

Function FindParamChar (s As String, char As String)
    Dim idx As Integer
    idx = -1

    Dim c As String
    Dim quote As Integer
    Dim paren As Integer
    Dim i As Integer
    For i = 1 To Len(s)
        c = Mid$(s, i, 1)
        If c = Chr$(34) Then
            quote = Not quote
        ElseIf Not quote And c = "(" Then
            paren = paren + 1
        ElseIf Not quote And c = ")" Then
            paren = paren - 1
        ElseIf Not quote And paren = 0 And c = char Then
            idx = i
            Exit For
        End If
    Next i

    FindParamChar = idx
End Function

Function DeclareVar$ (parts() As String)

    Dim vname As String
    Dim vtype As String: vtype = ""
    Dim vtypeIndex As Integer: vtypeIndex = 4
    Dim isGlobal As Integer: isGlobal = False
    Dim isArray As Integer: isArray = False
    'Dim arraySize As Integer: arraySize = -1
    Dim arraySize As String
    Dim pstart As Integer
    Dim asIdx As Integer
    asIdx = -1
    Dim i As Integer
    For i = 1 To UBound(parts)
        If UCase$(parts(i)) = "AS" Then asIdx = i
    Next i


    If UCase$(parts(2)) = "SHARED" Then
        isGlobal = True
        vname = Join(parts(), 3, asIdx - 1, " ")
        vtype = ""
        vtypeIndex = 5
    Else
        vname = Join(parts(), 2, asIdx - 1, " ")
        vtype = ""
    End If

    ' TODO: this logic cannot handle multi-dimensional arrays
    '       I think it can now, this comment can probably go away
    pstart = InStr(vname, "(")
    If pstart > 0 Then
        isArray = True
        arraySize = ConvertExpression(Mid$(vname, pstart + 1, Len(vname) - pstart - 2))
        vname = Left$(vname, pstart - 1)
    End If

    If UBound(parts) = vtypeIndex Then
        vtype = UCase$(parts(vtypeIndex))
    Else
        vtype = DataTypeFromName(vname)
    End If

    ' TODO: need to move this to later in the function so we can check to see whether
    '       the variable has already been defined, this is particulary important
    '       for handling REDIM _PRESERVE scenarios
    Dim var As Variable
    var.name = vname
    var.type = vtype
    var.isArray = isArray
    'var.arraySize = arraySize
    If isGlobal Then
        AddVariable var, globalVars()
    Else
        AddVariable var, localVars()
    End If


    Dim js As String
    If Not var.isArray Then
        js = "var " + var.name + " = " + InitTypeValue(var.type) + ";"

    Else
        ' TODO: if this is a REDIM, make sure we are not declaring the variable twice
        '       if this is an array with _PRESERVE specified, then enlarge or shrink the existing array
        js = "var " + var.name + " = [];" 'new Array(" + Str$(var.arraySize + 1) + ");"
        If arraySize <> "" Then
            js = js + " QB64.initArray(" + var.name + ", [" + arraySize + "], " + InitTypeValue(var.type) + ");"

            '    js = js + ".fill(" + InitTypeValue(var.type) + ")"
        End If
    End If

    js = js + " // " + var.type

    DeclareVar = js
End Function

Function InitTypeValue$ (vtype As String)
    Dim value As String
    If vtype = "STRING" Then
        value = "''"
    ElseIf vtype = "_BIT" Or vtype = "_UNSIGNED _BIT" Or vtype = "_BYTE" Or vtype = "_UNSIGNED _BYTE" Or _
           vtype = "INTEGER" Or vtype = "_UNSIGNED INTEGER" Or vtype = "LONG" Or vtype = "_UNSIGNED LONG" Or _
           vtype = "_INTEGER64" Or vtype = "_UNSIGNED INTEGER64" Or _
           vtype = "SINGLE" Or vtype = "DOUBLE" Or vtype = "_FLOAT" Or _
           vtype = "_OFFSET" Or vtype = "_UNSIGNED _OFFSET" Then
        value = "0"
    Else ' Custom Type
        value = "{"
        Dim typeId As Integer
        typeId = FindTypeId(vtype)
        Dim i As Integer
        For i = 1 To UBound(typeVars)
            If typeId = typeVars(i).typeId Then
                value = value + typeVars(i).name + ":" + InitTypeValue(typeVars(i).type) + ","
            End If
        Next i
        value = Left$(value, Len(value) - 1) + "}"
    End If

    InitTypeValue = value
End Function

Function FindTypeId (typeName As String)
    Dim id As Integer
    id = -1
    Dim i As Integer
    For i = 1 To UBound(types)
        If types(i).name = typeName Then
            id = i
            Exit For
        End If
    Next i
    FindTypeId = id
End Function

Function ConvertExpression$ (ex As String)
    Dim c As String
    Dim js As String: js = ""
    Dim word As String: word = ""
    Dim var As Variable
    Dim m As Method

    Dim stringLiteral As Integer
    Dim i As Integer: i = 1
    While i <= Len(ex)
        c = Mid$(ex, i, 1)

        If c = Chr$(34) Then
            js = js + c
            stringLiteral = Not stringLiteral

        ElseIf stringLiteral Then
            js = js + c

        Else
            If c = " " Or c = "," Or i = Len(ex) Then
                If i = Len(ex) Then word = word + c
                Dim uword As String: uword = UCase$(word)
                If uword = "NOT" Then
                    js = js + "!"
                ElseIf uword = "AND" Then
                    js = js + " && "
                ElseIf uword = "OR" Then
                    js = js + " || "
                ElseIf uword = "MOD" Then
                    js = js + " % "
                ElseIf word = "=" Then
                    js = js + " == "
                ElseIf word = "<>" Then
                    js = js + " != "
                ElseIf word = "^" Then
                    js = js + " ** "
                ElseIf word = ">" Or word = ">=" Or word = "<" Or word = "<=" Then
                    js = js + " " + word + " "
                Else
                    'Print "/* " + word + " */"
                    If FindVariable(word, var, False) Then
                        js = js + " " + var.jsname
                    Else
                        ' TODO: Need a more sophisticated way to determine whether
                        '       the return value is being assigned in the method.
                        '       Currently, this does not support recursive calls.
                        'Print " /* " + word + " */ "
                        If FindMethod(word, m, "FUNCTION") Then
                            If m.name <> currentMethod Then
                                js = js + " " + m.jsname + "()"
                            Else
                                js = js + " " + word
                            End If
                        Else
                            js = js + " " + word
                        End If

                    End If
                End If
                If c = "," And Not i = Len(ex) Then js = js + ","
                word = ""

            ElseIf c = "(" Then
                ' Find the end of the group
                Dim done As Integer: done = False
                Dim pcount As Integer: pcount = 0
                Dim c2 As String
                Dim ex2 As String: ex2 = ""
                Dim stringLiteral2 As Integer
                stringLiteral2 = False
                i = i + 1
                While Not done And i <= Len(ex)
                    c2 = Mid$(ex, i, 1)
                    If c2 = Chr$(34) Then
                        stringLiteral2 = Not stringLiteral2
                    ElseIf Not stringLiteral2 And c2 = "(" Then
                        pcount = pcount + 1
                    ElseIf Not stringLiteral2 And c2 = ")" Then
                        If pcount = 0 Then
                            done = True
                        Else
                            pcount = pcount - 1
                        End If
                    End If

                    If Not done Then
                        ex2 = ex2 + c2
                        i = i + 1
                    End If
                Wend

                ' Determine whether the current word is a function or array variable
                If FindVariable(word, var, True) Then
                    js = js + var.jsname + "[" + GXSTR_Replace(ConvertExpression(ex2), ",", "][") + "]"

                ElseIf FindMethod(word, m, "FUNCTION") Then
                    js = js + m.jsname + "(" + ConvertExpression(ex2) + ")"
                Else
                    ' nested condition
                    js = js + "(" + ConvertExpression(ex2) + ")"
                End If
                word = ""

            Else
                word = word + c
            End If
        End If
        i = i + 1
    Wend
    ConvertExpression = js
End Function

Function FindVariable (varname As String, var As Variable, isArray As Integer)
    Dim found As Integer: found = False
    Dim i As Integer
    Dim fvarname As String
    fvarname = _Trim$(UCase$(RemoveSuffix(varname)))
    For i = 1 To UBound(localVars)
        If localVars(i).isArray = isArray And UCase$(localVars(i).name) = fvarname Then
            found = True
            var = localVars(i)
            Exit For
        End If
    Next i
    If Not found Then
        For i = 1 To UBound(globalVars)
            If globalVars(i).isArray = isArray And UCase$(globalVars(i).name) = fvarname Then
                found = True
                var = globalVars(i)
                Exit For
            End If
        Next i
    End If

    FindVariable = found
End Function

Function FindMethod (mname As String, m As Method, t As String)
    Dim found As Integer: found = False
    Dim i As Integer
    For i = 1 To UBound(methods)
        If methods(i).uname = _Trim$(UCase$(RemoveSuffix(mname))) And methods(i).type = t Then
            found = True
            m = methods(i)
            Exit For
        End If
    Next i
    FindMethod = found
End Function

Sub ConvertMethods ()
    Print ""
    Dim i As Integer
    For i = 1 To UBound(methods)
        If (methods(i).line <> 0) Then
            Dim lastLine As Integer
            lastLine = methods(i + 1).line - 1
            If lastLine < 0 Then lastLine = UBound(lines)

            ' TODO: figure out how to make needed functions have the async modifier
            '       at the moment just applying it to all subs
            Dim asyncModifier As String
            'asyncModifier = "async "
            If methods(i).type = "SUB" Then asyncModifier = "async " Else asyncModifier = ""
            Print asyncModifier + "function " + methods(i).jsname + "(";
            If methods(i).argc > 0 Then
                ReDim args(0) As String
                Dim c As Integer
                c = GXSTR_Split(methods(i).args, ",", args())
                Dim a As Integer
                For a = 1 To c
                    Dim v As Integer
                    ReDim parts(0) As String
                    v = GXSTR_Split(args(a), ":", parts())
                    Print parts(1);
                    Print "/* " + parts(2) + "*/";
                    If a < c Then Print ",";
                Next a
            End If
            Print ") {"
            If methods(i).type = "FUNCTION" Then
                Print "var " + RemoveSuffix(methods(i).name) + " = null;"
            End If
            currentMethod = methods(i).name

            ConvertLines methods(i).line + 1, lastLine - 1, methods(i).name
            If methods(i).type = "FUNCTION" Then
                Print "return " + RemoveSuffix(methods(i).name) + ";"
            End If
            Print "}"
        End If
    Next i
End Sub


Sub ReadLines (filename As String)
    Dim fline As String
    Open filename For Input As #1
    Do Until EOF(1)
        Line Input #1, fline
        If Not _Trim$(fline) = "" Then ' remove all blank lines

            While EndsWith(fline, " _")
                Dim nextLine As String
                Line Input #1, nextLine
                fline = Left$(fline, Len(fline) - 1) + nextLine
            Wend

            Dim quoteDepth As Integer
            quoteDepth = 0
            Dim i As Integer
            For i = 1 To Len(fline)
                Dim c As String
                c = Mid$(fline, i, 1)
                If c = Chr$(34) Then
                    If quoteDepth = 0 Then
                        quoteDepth = 1
                    Else
                        quoteDepth = 0
                    End If
                End If
                If quoteDepth = 0 And c = "'" Then
                    fline = Left$(fline, i - 1)
                    Exit For
                End If
                If quoteDepth = 0 And c = ":" Then
                    AddLine Left$(fline, i - 1)
                    fline = Right$(fline, Len(fline) - i)
                End If
            Next i

            ' If once we have removed the comments the line is empty do not add it
            If Not _Trim$(fline) = "" Then
                AddLine fline
            End If
        End If
    Loop
    Close #1
End Sub

Sub FindMethods
    Dim i As Integer
    Dim pcount As Integer
    ReDim parts(0) As String
    For i = 1 To UBound(lines)
        pcount = GXSTR_Split(lines(i), " ", parts())
        Dim word As String: word = UCase$(parts(1))

        If word = "FUNCTION" Or word = "SUB" Then

            Dim m As Method
            m.line = i
            m.type = UCase$(parts(1))
            m.name = parts(2)
            m.argc = 0
            m.args = ""
            ReDim args(0) As Argument

            If UBound(parts) > 2 Then
                Dim a As Integer
                Dim args As String
                args = ""
                For a = 3 To UBound(parts)
                    args = args + parts(a) + " "
                Next a
                args = _Trim$(GXSTR_Replace(GXSTR_Replace(args, "(", ""), ")", ""))
                'm.args = args
                ReDim arga(0) As String
                m.argc = GXSTR_Split(args, ",", arga())
                args = ""
                For a = 1 To m.argc
                    'Dim arg As String
                    ReDim aparts(0) As String
                    Dim apcount As Integer
                    apcount = GXSTR_Split(arga(a), " ", aparts())
                    If apcount = 3 Then
                        args = args + aparts(1) + ":" + UCase$(aparts(3))
                    Else
                        args = args + aparts(1) + ":" + DataTypeFromName(aparts(1))
                        ' TODO determine type from name
                    End If
                    If Not a = m.argc Then
                        args = args + ","
                    End If
                Next a
                m.args = args
            End If

            AddMethod m, ""
        End If
    Next i
End Sub

' String literal aware split
Function SLSplit (sourceString As String, results() As String)
    Dim cstr As String, p As Long, curpos As Long, arrpos As Long, dpos As Long

    cstr = _Trim$(sourceString)

    ReDim results(0) As String

    ' remove all excess space not inside a string literal
    Dim lastChar As String
    Dim quoteMode As Integer
    Dim result As String
    Dim count As Integer
    Dim i As Integer
    For i = 1 To Len(cstr)
        Dim c As String
        c = Mid$(cstr, i, 1)

        If c = Chr$(34) Then
            quoteMode = Not quoteMode
            result = result + c

            ' This is not the most intuitive place for this...
            ' If we find a string then escape any backslashes
            If Not quoteMode Then
                result = GXSTR_Replace(result, "\", "\\")
            End If

        ElseIf c = " " Then
            If quoteMode Then
                result = result + c

            ElseIf lastChar = " " Then
                ' extra space, move along

            Else
                count = UBound(results) + 1
                ReDim _Preserve results(count) As String
                results(count) = result
                result = ""
            End If
        Else
            result = result + c
        End If

        lastChar = c
    Next i

    ' add the leftover last segment
    If result <> "" Then
        count = UBound(results) + 1
        ReDim _Preserve results(count) As String
        results(count) = result
    End If

    SLSplit = UBound(results)
End Function


Sub PrintMethods
    Print ""
    Print "Methods"
    Print "------------------------------------------------------------"
    Dim i As Integer
    For i = 1 To UBound(methods)
        Dim m As Method
        m = methods(i)
        Print Str$(m.line) + ": " + m.type + " - " + m.name + " [" + m.jsname + "] - " + m.returnType + " - " + m.args
    Next i
End Sub

Sub PrintTypes
    Print ""
    Print "Types"
    Print "------------------------------------------------------------"
    Dim i As Integer
    For i = 1 To UBound(types)
        Dim t As QBType
        t = types(i)
        Print Str$(t.line) + ": " + t.name ' + " - " + m.args
        Dim v As Integer
        For v = 1 To UBound(typeVars)
            If typeVars(i).typeId = i Then
                Print "  -> " + typeVars(v).name + ": " + typeVars(v).type
            End If
        Next v
    Next i
End Sub


Sub AddMethod (m As Method, prefix As String)
    Dim mcount: mcount = UBound(methods) + 1
    ReDim _Preserve methods(mcount) As Method
    If m.type = "FUNCTION" Then
        m.returnType = DataTypeFromName(m.name)
    End If
    m.uname = UCase$(RemoveSuffix(m.name))
    m.jsname = MethodJS(m, prefix)
    methods(mcount) = m
End Sub

Sub AddGXMethod (mtype As String, mname As String)
    Dim mcount: mcount = UBound(methods) + 1
    ReDim _Preserve methods(mcount) As Method
    Dim m As Method
    m.type = mtype
    m.name = mname
    m.uname = UCase$(m.name)
    m.jsname = GXMethodJS(RemoveSuffix(mname))
    If mtype = "FUNCTION" Then
        m.returnType = DataTypeFromName(mname)
    End If
    methods(mcount) = m
End Sub

Sub AddQB64Method (mtype As String, mname As String)
    Dim m As Method
    m.type = mtype
    m.name = mname
    AddMethod m, "QB64."
End Sub


Sub AddLine (fline As String)
    ' check for single line if statements
    Dim parts(0) As String
    Dim c As Integer
    c = GXSTR_Split(fline, " ", parts())

    If UCase$(parts(1)) = "IF" Then
        'Print "'''' IT'S AN IF!"
        Dim thenIndex As Integer
        thenIndex = 0
        Dim i As Integer
        For i = 1 To c
            If UCase$(parts(i)) = "THEN" Then
                thenIndex = i
                Exit For
            End If
        Next i

        If thenIndex <> c Then
            __AddLine Join(parts(), 1, thenIndex, " ")
            __AddLine Join(parts(), thenIndex + 1, c, " ")
            __AddLine "End If"
        Else
            __AddLine fline
        End If
    Else
        __AddLine fline
    End If
End Sub

Sub __AddLine (fline As String)
    'Print fline
    Dim lcount: lcount = UBound(lines) + 1
    ReDim _Preserve lines(lcount) As String
    lines(lcount) = fline
End Sub


Sub AddConst (vname As String)
    Dim v As Variable
    v.type = "CONST"
    v.name = vname
    v.isConst = True
    AddVariable v, globalVars()
End Sub

Sub AddGXConst (vname As String)
    Dim v As Variable
    v.type = "CONST"
    v.name = vname
    If vname = "GX_TRUE" Then
        v.jsname = "true"
    ElseIf vname = "GX_FALSE" Then
        v.jsname = "false"
    Else
        Dim jsname As String
        jsname = Mid$(vname, 3, Len(vname) - 2)
        If Left$(jsname, 1) = "_" Then jsname = Right$(jsname, Len(jsname) - 1)
        v.jsname = "GX." + jsname
    End If
    v.isConst = True
    AddVariable v, globalVars()
End Sub

Sub AddGlobal (vname As String, vtype As String, arraySize As Integer)
    Dim v As Variable
    v.type = vtype
    v.name = vname
    v.isArray = arraySize > -1
    v.arraySize = arraySize
    AddVariable v, globalVars()
End Sub

Sub AddLocal (vname As String, vtype As String, arraySize As Integer)
    Dim v As Variable
    v.type = vtype
    v.name = vname
    v.isArray = arraySize > -1
    v.arraySize = arraySize
    AddVariable v, localVars()
End Sub

Sub AddVariable (var As Variable, vlist() As Variable)
    Dim vcount: vcount = UBound(vlist) + 1
    ReDim _Preserve vlist(vcount) As Variable
    If var.jsname = "" Then var.jsname = RemoveSuffix(var.name)
    vlist(vcount) = var
End Sub

Sub AddType (t As QBType)
    Dim tcount: tcount = UBound(types) + 1
    ReDim _Preserve types(tcount) As QBType
    types(tcount) = t
End Sub

Sub AddGXType (tname As String, args As String)
    Dim t As QBType
    t.name = tname
    't.argc = argc
    't.args = args
    AddType t
    Dim typeId As Integer
    typeId = UBound(types)
    Dim count As Integer
    ReDim pairs(0) As String
    count = GXSTR_Split(args, ",", pairs())
    Dim i As Integer
    For i = 1 To UBound(pairs)
        ReDim nv(0) As String
        count = GXSTR_Split(pairs(i), ":", nv())
        Dim tvar As Variable
        tvar.typeId = typeId
        tvar.name = nv(1)
        tvar.type = UCase$(nv(2))
        AddVariable tvar, typeVars()
    Next i
End Sub

Function MainEnd
    If programMethods = 0 Then
        MainEnd = UBound(lines)
    Else
        MainEnd = methods(1).line - 1
    End If
End Function

Function RemoveSuffix$ (vname As String)
    Dim i As Integer
    Dim done As Integer
    Dim c As String
    vname = _Trim$(vname)
    i = Len(vname)
    While Not done
        c = Mid$(vname, i, 1)
        If c = "`" Or c = "%" Or c = "&" Or c = "$" Or c = "~" Or c = "!" Then
            i = i - 1
        Else
            done = True
        End If
    Wend
    RemoveSuffix = Left$(vname, i)
End Function

Function DataTypeFromName$ (vname As String)
    Dim dt As String
    If EndsWith(vname, "`") Then
        dt = "_BIT"
    ElseIf EndsWith(vname, "%%") Then
        dt = "_BYTE"
    ElseIf EndsWith(vname, "~%") Then
        dt = "_UNSIGNED INTEGER"
    ElseIf EndsWith(vname, "%") Then
        dt = "INTEGER"
    ElseIf EndsWith(vname, "~&&") Then
        dt = "_UNSIGNED INTEGER64"
    ElseIf EndsWith(vname, "&&") Then
        dt = "_INTEGER64"
    ElseIf EndsWith(vname, "~&") Then
        dt = "_UNSIGNED LONG"
    ElseIf EndsWith(vname, "##") Then
        dt = "_FLOAT"
    ElseIf EndsWith(vname, "#") Then
        dt = "DOUBLE"
    ElseIf EndsWith(vname, "~%&") Then
        dt = "_UNSIGNED _OFFSET"
    ElseIf EndsWith(vname, "%&") Then
        dt = "_OFFSET"
    ElseIf EndsWith(vname, "&") Then
        dt = "LONG"
    ElseIf EndsWith(vname, "!") Then
        dt = "SINGLE"
    Else
        dt = "SINGLE"
    End If

    DataTypeFromName = dt
End Function

Function EndsWith (s As String, finds As String)
    If _InStrRev(s, finds) = Len(s) - 1 Then
        EndsWith = True
    Else
        EndsWith = False
    End If
End Function

Function StartsWith (s As String, finds As String)
    If InStr(s, finds) = 1 Then
        StartsWith = True
    Else
        StartsWith = False
    End If
End Function

Function Join$ (parts() As String, startIndex As Integer, endIndex As Integer, delimiter As String)

    If endIndex = -1 Then endIndex = UBound(parts)
    Dim s As String
    Dim i As Integer
    For i = startIndex To endIndex
        s = s + parts(i)
        If i <> UBound(parts) Then
            s = s + delimiter
        End If
    Next i
    Join = s
End Function

Function MethodJS$ (m As Method, prefix As String)
    Dim jsname As String
    jsname = prefix
    If m.type = "FUNCTION" Then
        jsname = jsname + "func_"
    Else
        jsname = jsname + "sub_"
    End If

    Dim i As Integer
    Dim c As String
    Dim a As Integer
    For i = 1 To Len(m.name)
        c = Mid$(m.name, i, 1)
        a = Asc(c)
        ' uppercase, lowercase, numbers, - and .
        If (a >= 65 And a <= 90) Or (a >= 97 And a <= 122) Or _
           (a >= 48 And a <= 57) Or _
           a = 95 Or a = 46 Then
            jsname = jsname + c
        End If
    Next i

    If m.name = "_Limit" Or m.name = "_Delay" Or m.name = "Sleep" Or m.name = "Input" Or m.name = "Print" Then
        jsname = "await " + jsname
    End If

    MethodJS = jsname
End Function

Function GXMethodJS$ (mname As String)
    Dim jsname As String
    Dim startIdx As Integer
    If InStr(mname, "GXSTR") = 1 Then
        jsname = "GXSTR."
        startIdx = 7
    Else
        jsname = "GX."
        startIdx = 3
    End If
    jsname = jsname + LCase$(Mid$(mname, startIdx, 1))

    Dim i As Integer
    Dim c As String
    Dim a As Integer
    For i = startIdx + 1 To Len(mname)
        c = Mid$(mname, i, 1)
        a = Asc(c)
        ' uppercase, lowercase, numbers, - and .
        If (a >= 65 And a <= 90) Or (a >= 97 And a <= 122) Or _
           (a >= 48 And a <= 57) Or _
           a = 95 Or a = 46 Then
            jsname = jsname + c
        End If
    Next i

    If mname = "GXMapLoad" Then
        jsname = "await " + jsname
    End If

    GXMethodJS = jsname
End Function

Sub InitGX
    AddGXType "GXPOSITION", "x:LONG,y:LONG"
    AddGXType "GXDEVICEINPUT", "deviceId:INTEGER,deviceType:INTEGER,inputType:INTEGER,inputId:INTEGER,inputValue:INTEGER"


    AddGXConst "GX_FALSE"
    AddGXConst "GX_TRUE"
    AddGXConst "GXEVENT_INIT"
    AddGXConst "GXEVENT_UPDATE"
    AddGXConst "GXEVENT_DRAWBG"
    AddGXConst "GXEVENT_DRAWMAP"
    AddGXConst "GXEVENT_DRAWSCREEN"
    AddGXConst "GXEVENT_MOUSEINPUT"
    AddGXConst "GXEVENT_PAINTBEFORE"
    AddGXConst "GXEVENT_PAINTAFTER"
    AddGXConst "GXEVENT_COLLISION_TILE"
    AddGXConst "GXEVENT_COLLISION_ENTITY"
    AddGXConst "GXEVENT_PLAYER_ACTION"
    AddGXConst "GXEVENT_ANIMATE_COMPLETE"
    AddGXConst "GXANIMATE_LOOP"
    AddGXConst "GXANIMATE_SINGLE"
    AddGXConst "GXBG_STRETCH"
    AddGXConst "GXBG_SCROLL"
    AddGXConst "GXBG_WRAP"
    AddGXConst "GXKEY_ESC"
    AddGXConst "GXKEY_1"
    AddGXConst "GXKEY_2"
    AddGXConst "GXKEY_3"
    AddGXConst "GXKEY_4"
    AddGXConst "GXKEY_5"
    AddGXConst "GXKEY_6"
    AddGXConst "GXKEY_7"
    AddGXConst "GXKEY_8"
    AddGXConst "GXKEY_9"
    AddGXConst "GXKEY_0"
    AddGXConst "GXKEY_DASH"
    AddGXConst "GXKEY_EQUALS"
    AddGXConst "GXKEY_BACKSPACE"
    AddGXConst "GXKEY_TAB"
    AddGXConst "GXKEY_Q"
    AddGXConst "GXKEY_W"
    AddGXConst "GXKEY_E"
    AddGXConst "GXKEY_R"
    AddGXConst "GXKEY_T"
    AddGXConst "GXKEY_Y"
    AddGXConst "GXKEY_U"
    AddGXConst "GXKEY_I"
    AddGXConst "GXKEY_O"
    AddGXConst "GXKEY_P"
    AddGXConst "GXKEY_LBRACKET"
    AddGXConst "GXKEY_RBRACKET"
    AddGXConst "GXKEY_ENTER"
    AddGXConst "GXKEY_LCTRL"
    AddGXConst "GXKEY_A"
    AddGXConst "GXKEY_S"
    AddGXConst "GXKEY_D"
    AddGXConst "GXKEY_F"
    AddGXConst "GXKEY_G"
    AddGXConst "GXKEY_H"
    AddGXConst "GXKEY_J"
    AddGXConst "GXKEY_K"
    AddGXConst "GXKEY_L"
    AddGXConst "GXKEY_SEMICOLON"
    AddGXConst "GXKEY_QUOTE"
    AddGXConst "GXKEY_BACKQUOTE"
    AddGXConst "GXKEY_LSHIFT"
    AddGXConst "GXKEY_BACKSLASH"
    AddGXConst "GXKEY_Z"
    AddGXConst "GXKEY_X"
    AddGXConst "GXKEY_C"
    AddGXConst "GXKEY_V"
    AddGXConst "GXKEY_B"
    AddGXConst "GXKEY_N"
    AddGXConst "GXKEY_M"
    AddGXConst "GXKEY_COMMA"
    AddGXConst "GXKEY_PERIOD"
    AddGXConst "GXKEY_SLASH"
    AddGXConst "GXKEY_RSHIFT"
    AddGXConst "GXKEY_NUMPAD_MULTIPLY"
    AddGXConst "GXKEY_SPACEBAR"
    AddGXConst "GXKEY_CAPSLOCK"
    AddGXConst "GXKEY_F1"
    AddGXConst "GXKEY_F2"
    AddGXConst "GXKEY_F3"
    AddGXConst "GXKEY_F4"
    AddGXConst "GXKEY_F5"
    AddGXConst "GXKEY_F6"
    AddGXConst "GXKEY_F7"
    AddGXConst "GXKEY_F8"
    AddGXConst "GXKEY_F9"
    AddGXConst "GXKEY_PAUSE"
    AddGXConst "GXKEY_SCRLK"
    AddGXConst "GXKEY_NUMPAD_7"
    AddGXConst "GXKEY_NUMPAD_8"
    AddGXConst "GXKEY_NUMPAD_9"
    AddGXConst "GXKEY_NUMPAD_MINUS"
    AddGXConst "GXKEY_NUMPAD_4"
    AddGXConst "GXKEY_NUMPAD_5"
    AddGXConst "GXKEY_NUMPAD_6"
    AddGXConst "GXKEY_NUMPAD_PLUS"
    AddGXConst "GXKEY_NUMPAD_1"
    AddGXConst "GXKEY_NUMPAD_2"
    AddGXConst "GXKEY_NUMPAD_3"
    AddGXConst "GXKEY_NUMPAD_0"
    AddGXConst "GXKEY_NUMPAD_PERIOD"
    AddGXConst "GXKEY_F11"
    AddGXConst "GXKEY_F12"
    AddGXConst "GXKEY_NUMPAD_ENTER"
    AddGXConst "GXKEY_RCTRL"
    AddGXConst "GXKEY_NUMPAD_DIVIDE"
    AddGXConst "GXKEY_NUMLOCK"
    AddGXConst "GXKEY_HOME"
    AddGXConst "GXKEY_UP"
    AddGXConst "GXKEY_PAGEUP"
    AddGXConst "GXKEY_LEFT"
    AddGXConst "GXKEY_RIGHT"
    AddGXConst "GXKEY_END"
    AddGXConst "GXKEY_DOWN"
    AddGXConst "GXKEY_PAGEDOWN"
    AddGXConst "GXKEY_INSERT"
    AddGXConst "GXKEY_DELETE"
    AddGXConst "GXKEY_LWIN"
    AddGXConst "GXKEY_RWIN"
    AddGXConst "GXKEY_MENU"
    AddGXConst "GXACTION_MOVE_LEFT"
    AddGXConst "GXACTION_MOVE_RIGHT"
    AddGXConst "GXACTION_MOVE_UP"
    AddGXConst "GXACTION_MOVE_DOWN"
    AddGXConst "GXACTION_JUMP"
    AddGXConst "GXACTION_JUMP_RIGHT"
    AddGXConst "GXACTION_JUMP_LEFT"
    AddGXConst "GXSCENE_FOLLOW_NONE"
    AddGXConst "GXSCENE_FOLLOW_ENTITY_CENTER"
    AddGXConst "GXSCENE_FOLLOW_ENTITY_CENTER_X"
    AddGXConst "GXSCENE_FOLLOW_ENTITY_CENTER_Y"
    AddGXConst "GXSCENE_FOLLOW_ENTITY_CENTER_X_POS"
    AddGXConst "GXSCENE_FOLLOW_ENTITY_CENTER_X_NEG"
    AddGXConst "GXSCENE_CONSTRAIN_NONE"
    AddGXConst "GXSCENE_CONSTRAIN_TO_MAP"
    AddGXConst "GXFONT_DEFAULT"
    AddGXConst "GXFONT_DEFAULT_BLACK"
    AddGXConst "GXDEVICE_KEYBOARD"
    AddGXConst "GXDEVICE_MOUSE"
    AddGXConst "GXDEVICE_CONTROLLER"
    AddGXConst "GXDEVICE_BUTTON"
    AddGXConst "GXDEVICE_AXIS"
    AddGXConst "GXDEVICE_WHEEL"
    AddGXConst "GXTYPE_ENTITY"
    AddGXConst "GXTYPE_FONT"

    AddGXMethod "SUB", "GXSleep"
    AddGXMethod "FUNCTION", "GXMouseX"
    AddGXMethod "FUNCTION", "GXMouseY"
    AddGXMethod "FUNCTION", "GXSoundLoad"
    AddGXMethod "SUB", "GXSoundPlay"
    AddGXMethod "SUB", "GXSoundRepeat"
    AddGXMethod "SUB", "GXSoundVolume"
    AddGXMethod "SUB", "GXSoundPause"
    AddGXMethod "SUB", "GXSoundStop"
    AddGXMethod "SUB", "GXSoundMuted"
    AddGXMethod "FUNCTION", "GXSoundMuted"
    AddGXMethod "SUB", "GXEntityAnimate"
    AddGXMethod "SUB", "GXEntityAnimateStop"
    AddGXMethod "SUB", "GXEntityAnimateMode"
    AddGXMethod "FUNCTION", "GXEntityAnimateMode"
    AddGXMethod "FUNCTION", "GXScreenEntityCreate"
    AddGXMethod "FUNCTION", "GXEntityCreate"
    AddGXMethod "SUB", "GXEntityCreate"
    AddGXMethod "SUB", "GXEntityVisible"
    AddGXMethod "SUB", "GXEntityMove"
    AddGXMethod "SUB", "GXEntityPos"
    AddGXMethod "SUB", "GXEntityVX"
    AddGXMethod "FUNCTION", "GXEntityVX"
    AddGXMethod "SUB", "GXEntityVY"
    AddGXMethod "FUNCTION", "GXEntityVY"
    AddGXMethod "FUNCTION", "GXEntityX"
    AddGXMethod "FUNCTION", "GXEntityY"
    AddGXMethod "FUNCTION", "GXEntityWidth"
    AddGXMethod "FUNCTION", "GXEntityHeight"
    AddGXMethod "SUB", "GXEntityFrameNext"
    AddGXMethod "SUB", "GXEntityFrameSet"
    AddGXMethod "SUB", "GXEntityType"
    AddGXMethod "FUNCTION", "GXEntityType"
    AddGXMethod "FUNCTION", "GXEntityUID$"
    AddGXMethod "FUNCTION", "GXFontUID$"
    AddGXMethod "FUNCTION", "GX"
    AddGXMethod "SUB", "GXEntityApplyGravity"
    AddGXMethod "FUNCTION", "GXEntityApplyGravity"
    AddGXMethod "SUB", "GXEntityCollisionOffset"
    AddGXMethod "FUNCTION", "GXEntityCollisionOffsetLeft"
    AddGXMethod "FUNCTION", "GXEntityCollisionOffsetTop"
    AddGXMethod "FUNCTION", "GXEntityCollisionOffsetRight"
    AddGXMethod "FUNCTION", "GXEntityCollisionOffsetBottom"
    AddGXMethod "SUB", "GXFullScreen"
    AddGXMethod "FUNCTION", "GXFullScreen"
    AddGXMethod "FUNCTION", "GXBackgroundAdd"
    AddGXMethod "SUB", "GXBackgroundY"
    AddGXMethod "SUB", "GXBackgroundHeight"
    AddGXMethod "SUB", "GXBackgroundClear"
    AddGXMethod "SUB", "GXSceneEmbedded"
    AddGXMethod "FUNCTION", "GXSceneEmbedded"
    AddGXMethod "SUB", "GXSceneCreate"
    AddGXMethod "SUB", "GXSceneWindowSize"
    AddGXMethod "SUB", "GXSceneScale"
    AddGXMethod "SUB", "GXSceneResize"
    AddGXMethod "SUB", "GXSceneDestroy"
    AddGXMethod "SUB", "GXCustomDraw"
    AddGXMethod "FUNCTION", "GXCustomDraw"
    AddGXMethod "SUB", "GXFrameRate"
    AddGXMethod "FUNCTION", "GXFrameRate"
    AddGXMethod "FUNCTION", "GXFrame"
    AddGXMethod "SUB", "GXSceneDraw"
    AddGXMethod "SUB", "GXSceneMove"
    AddGXMethod "SUB", "GXScenePos"
    AddGXMethod "FUNCTION", "GXSceneX"
    AddGXMethod "FUNCTION", "GXSceneY"
    AddGXMethod "FUNCTION", "GXSceneWidth"
    AddGXMethod "FUNCTION", "GXSceneHeight"
    AddGXMethod "FUNCTION", "GXSceneColumns"
    AddGXMethod "FUNCTION", "GXSceneRows"
    AddGXMethod "SUB", "GXSceneStart"
    AddGXMethod "SUB", "GXSceneUpdate"
    AddGXMethod "SUB", "GXSceneFollowEntity"
    AddGXMethod "SUB", "GXSceneConstrain"
    AddGXMethod "SUB", "GXSceneStop"
    AddGXMethod "SUB", "GXMapCreate"
    AddGXMethod "FUNCTION", "GXMapColumns"
    AddGXMethod "FUNCTION", "GXMapRows"
    AddGXMethod "FUNCTION", "GXMapLayers"
    AddGXMethod "SUB", "GXMapLayerVisible"
    AddGXMethod "FUNCTION", "GXMapLayerVisible"
    AddGXMethod "SUB", "GXMapLayerAdd"
    AddGXMethod "SUB", "GXMapLayerInsert"
    AddGXMethod "SUB", "GXMapLayerRemove"
    AddGXMethod "SUB", "GXMapResize"
    AddGXMethod "SUB", "GXMapDraw"
    AddGXMethod "SUB", "GXMapTilePosAt"
    AddGXMethod "SUB", "GXMapTile"
    AddGXMethod "FUNCTION", "GXMapTile"
    AddGXMethod "FUNCTION", "GXMapTileDepth"
    AddGXMethod "SUB", "GXMapTileAdd"
    AddGXMethod "SUB", "GXMapTileRemove"
    AddGXMethod "FUNCTION", "GXMapVersion"
    AddGXMethod "SUB", "GXMapSave"
    AddGXMethod "SUB", "GXMapLoad"
    AddGXMethod "FUNCTION", "GXMapIsometric"
    AddGXMethod "SUB", "GXMapIsometric"
    AddGXMethod "SUB", "GXSpriteDraw"
    AddGXMethod "SUB", "GXSpriteDrawScaled"
    AddGXMethod "SUB", "GXTilesetCreate"
    AddGXMethod "SUB", "GXTilesetReplaceImage"
    AddGXMethod "SUB", "GXTilesetLoad"
    AddGXMethod "SUB", "GXTilesetSave"
    AddGXMethod "SUB", "GXTilesetPos"
    AddGXMethod "FUNCTION", "GXTilesetWidth"
    AddGXMethod "FUNCTION", "GXTilesetHeight"
    AddGXMethod "FUNCTION", "GXTilesetColumns"
    AddGXMethod "FUNCTION", "GXTilesetRows"
    AddGXMethod "FUNCTION", "GXTilesetFilename"
    AddGXMethod "FUNCTION", "GXTilesetImage"
    AddGXMethod "SUB", "GXTilesetAnimationCreate"
    AddGXMethod "SUB", "GXTilesetAnimationAdd"
    AddGXMethod "SUB", "GXTilesetAnimationRemove"
    AddGXMethod "FUNCTION", "GXTilesetAnimationFrames"
    AddGXMethod "FUNCTION", "GXTilesetAnimationSpeed"
    AddGXMethod "SUB", "GXTilesetAnimationSpeed"
    AddGXMethod "FUNCTION", "GXFontCreate"
    AddGXMethod "SUB", "GXFontCreate"
    AddGXMethod "FUNCTION", "GXFontWidth"
    AddGXMethod "FUNCTION", "GXFontHeight"
    AddGXMethod "FUNCTION", "GXFontCharSpacing"
    AddGXMethod "SUB", "GXFontCharSpacing"
    AddGXMethod "FUNCTION", "GXFontLineSpacing"
    AddGXMethod "SUB", "GXFontLineSpacing"
    AddGXMethod "SUB", "GXDrawText"
    AddGXMethod "FUNCTION", "GXDebug"
    AddGXMethod "SUB", "GXDebug"
    AddGXMethod "FUNCTION", "GXDebugScreenEntities"
    AddGXMethod "SUB", "GXDebugScreenEntities"
    AddGXMethod "FUNCTION", "GXDebugFont"
    AddGXMethod "SUB", "GXDebugFont"
    AddGXMethod "FUNCTION", "GXDebugTileBorderColor"
    AddGXMethod "SUB", "GXDebugTileBorderColor"
    AddGXMethod "FUNCTION", "GXDebugEntityBorderColor"
    AddGXMethod "SUB", "GXDebugEntityBorderColor"
    AddGXMethod "FUNCTION", "GXDebugEntityCollisionColor"
    AddGXMethod "SUB", "GXDebugEntityCollisionColor"
    AddGXMethod "SUB", "GXKeyInput"
    AddGXMethod "FUNCTION", "GXKeyDown"
    AddGXMethod "SUB", "GXDeviceInputDetect"
    AddGXMethod "FUNCTION", "GXDeviceInputTest"
    AddGXMethod "FUNCTION", "GXDeviceName"
    AddGXMethod "FUNCTION", "GXDeviceTypeName"
    AddGXMethod "FUNCTION", "GXInputTypeName"
    AddGXMethod "FUNCTION", "GXKeyButtonName"

    ' Supporting Libraries
    AddGXConst "GX_CR"
    AddGXConst "GX_LF"
    AddGXConst "GX_CRLF"

    AddGXMethod "FUNCTION", "GXSTR_LPad"
    AddGXMethod "FUNCTION", "GXSTR_RPad"
    AddGXMethod "FUNCTION", "GXSTR_Replace"
    AddGXMethod "FUNCTION", "GXSTR_Split"
End Sub

Sub InitQB64Methods
    AddQB64Method "SUB", "_Delay"
    AddQB64Method "FUNCTION", "_FontWidth"
    AddQB64Method "FUNCTION", "_Height"
    AddQB64Method "SUB", "_Limit"
    AddQB64Method "FUNCTION", "_KeyHit"
    AddQB64Method "FUNCTION", "_NewImage"
    AddQB64Method "FUNCTION", "_Pi"
    AddQB64Method "SUB", "_PrintString"
    AddQB64Method "FUNCTION", "_PrintWidth"
    AddQB64Method "FUNCTION", "_RGB"
    AddQB64Method "FUNCTION", "_RGB32"
    AddQB64Method "FUNCTION", "_Round"
    AddQB64Method "SUB", "_Title"
    AddQB64Method "FUNCTION", "_Trim"
    AddQB64Method "FUNCTION", "_Width"

    AddQB64Method "FUNCTION", "Abs"
    AddQB64Method "FUNCTION", "Asc"
    AddQB64Method "FUNCTION", "Atn"
    AddQB64Method "FUNCTION", "Chr$"
    AddQB64Method "SUB", "Cls"
    AddQB64Method "SUB", "Color"
    AddQB64Method "FUNCTION", "Cos"
    AddQB64Method "FUNCTION", "Fix"
    AddQB64Method "SUB", "Input"
    AddQB64Method "FUNCTION", "InStr"
    AddQB64Method "FUNCTION", "Int"
    AddQB64Method "FUNCTION", "Left$"
    AddQB64Method "FUNCTION", "LCase$"
    AddQB64Method "FUNCTION", "Len"
    AddQB64Method "SUB", "Line"
    AddQB64Method "SUB", "Locate"
    AddQB64Method "FUNCTION", "LTrim$"
    AddQB64Method "FUNCTION", "Mid$"
    AddQB64Method "SUB", "Print"
    AddQB64Method "FUNCTION", "Right$"
    AddQB64Method "FUNCTION", "RTrim$"
    AddQB64Method "FUNCTION", "Rnd"
    AddQB64Method "SUB", "Screen"
    AddQB64Method "FUNCTION", "Sgn"
    AddQB64Method "FUNCTION", "Sin"
    AddQB64Method "SUB", "Sleep"
    AddQB64Method "FUNCTION", "Sqr"
    AddQB64Method "FUNCTION", "Str$"
    AddQB64Method "FUNCTION", "Tan"
    AddQB64Method "FUNCTION", "UBound"
    AddQB64Method "FUNCTION", "UCase$"
    AddQB64Method "FUNCTION", "Val"
End Sub

'$include: '../gx/gx_str.bm'
