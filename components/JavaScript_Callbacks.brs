' Callback functions for each keyword

' Reserved Keywords
function callback_await()
    print "callback_await"
end function

function callback_break()
    print "callback_break"
end function

function callback_case()
    print "callback_case"
end function

function callback_catch()
    print "callback_catch"
end function

function callback_class()
    print "callback_class"
end function

function callback_const()
    print "callback_const"
end function

function callback_continue()
    print "callback_continue"
end function

function callback_debugger()
    print "callback_debugger"
end function

function callback_default()
    print "callback_default"
end function

function callback_delete()
    print "callback_delete"
end function

function callback_do()
    print "callback_do"
end function

function callback_else()
    print "callback_else"
end function

function callback_enum()
    print "callback_enum"
end function

function callback_export()
    print "callback_export"
end function

function callback_extends()
    print "callback_extends"
end function

function callback_false()
    print "callback_false"
end function

function callback_finally()
    print "callback_finally"
end function

function callback_for()
    print "callback_for"
end function

function callback_function(input as String, i as Integer, IIFE as Boolean) as Dynamic
  '  print "Processing input: " + input  

    openInputs = findLastIndexOf("(", input)
    closeInputs = findLastIndexOf(")", input)
    delIIFE = findLastIndexOf(";", input)

    if IIFE = true
        ' Locate the IIFE body
        openIIFE = InStr(0, input, "(")
        bodyIIFE = getSubString(input, openIIFE + 1, openInputs - 1, true)  ' Exclude the parentheses

        keyword = Instr(openIIFE + 1,  input, "function")

        openParameters = Instr(keyword + 1, input, "(") - 1
        closeParameters = Instr(keyword + 1, input, ")") + 1
     
        parameters = Mid(input, keyword + len("function"), closeParameters - openParameters)

    '    print "Parameters: " + parameters

        ' Find positions of the opening and closing braces in the body
        openBrace = InStr(0, bodyIIFE, "{")
        closeBrace = findLastIndexOf("}", bodyIIFE)

        if openBrace = 0 or closeBrace = 0
            print "Error: Missing opening or closing braces."
            return invalid
        end if

        ' Extract the body between the braces
        body = getSubString(bodyIIFE, openBrace, closeBrace - 1, true)
    '    print "Callback_Function Body: " + body

        ' Capture the parameters passed after the IIFE
        Input_parameters = Mid(input, openInputs + 1, ( closeInputs - openInputs ) + 1 )
    '    print "Input Parameters: " + Input_parameters

        ' Parse the body of the IIFE
    '    print "Parsing IIFE body..."
      '  readLines(body, {})
    else
        ' Handle non-IIFE function logic (if necessary)
   '     print "Regular function detected, no IIFE."
    end if

    return invalid  ' Final return if function completes without errors
end function

' Handle assignments
function assignmentCallback(line as String, i as Integer, m as Object) as Integer
    lhs = ""
    rhs = ""
    assignmentStarted = false

    while i < Len(line)
        char = Mid(line, i, 1)

        if not assignmentStarted
            if char = "="
                assignmentStarted = true
            '    print "Assignment detected. LHS: " + lhs
            else
                lhs = lhs + char
            end if
        else
            rhs = rhs + char
            if char = ";"  ' End of assignment
               ' print "Finalizing Assignment -> LHS: " + lhs + ", RHS: " + rhs
                exit while
            end if
        end if

        i = i + 1
    end while

    return i
end function


function dotCallback(input as String, i as Integer)
print "Dot Callback"
end function 

function mapCallback(input as String, i as Integer)
print "Map Callback"
end function 

function arrayCallback(input as String, i as Integer)
    print "Array Callback"
end function 


function commentCallback(input as String, i as Integer, openCloseMatrix as Object) as Integer
    ' Ensure openCloseMatrix[5] exists and contains the required elements
    jsKeywordsMatrix = js_Keywords_Matrix()
    openCloseMatrix = jsKeywordsMatrix[0]

    if openCloseMatrix.Count() < 6 or Type(openCloseMatrix[5]) <> "roArray" then
        print "Error: openCloseMatrix[5] is not properly initialized."
        return i
    end if

    commentSymbols = openCloseMatrix[5]
    if commentSymbols.Count() < 3 then
        print "Error: openCloseMatrix[5] does not contain sufficient elements for comments."
        return i
    end if

    singleLineComment = commentSymbols[2]
    openMultiLineComment = commentSymbols[0]
    closeMultiLineComment = commentSymbols[1]

    ' Handle single-line comments
    if Mid(input, i, Len(singleLineComment)) = singleLineComment
        endIndex = Instr(i + Len(singleLineComment), input, Chr(10))  ' Find end of line
        if endIndex = 0 then endIndex = Len(input)  ' Handle last-line case
        comment = Mid(input, i, endIndex - i)
      '  print "Single-line comment: " + comment
        i = endIndex  ' Move `i` to the end of the comment
        return i

    ' Handle multi-line comments
    else if Mid(input, i, Len(openMultiLineComment)) = openMultiLineComment
        closeIndex = Instr(i + Len(openMultiLineComment), input, closeMultiLineComment)  ' Find closing tag
        if closeIndex > 0
            comment = Mid(input, i, closeIndex - i + Len(closeMultiLineComment))
          '  print "Multi-line comment: " + comment
            i = closeIndex + Len(closeMultiLineComment)  ' Move `i` to the end of the comment
        else
           ' print "Unclosed multi-line comment"
            i = Len(input)  ' Move `i` to the end of input if comment is unclosed
        end if
        return i
    end if

    ' If no comment is found, return `i` unchanged
    return i
end function

function bracketsCallback(input as String, i as Integer, openCloseMatrix as Object, stack as Object) as Integer
    dx = 1
    keywordDetected = false  ' Track if a keyword is detected in the current structure

    while i <= Len(input)
        substring = Mid(input, i, dx)

        'print " Brackets : " + substring
        if substring = "[" then
            stack.Push({symbol: "[", content: ""})
            i = i + 1
            dx = 1
            keywordDetected = false  ' Reset detection flag for new scope

        else if substring = "]" then
            entry = stack.Pop()
         '   print "Brackets : " + entry.content
            i = i + 1
            exit while

    '    else if isDataStructure(input, i, openCloseMatrix, stack) then
            i = dataStructureCallback(input, i, openCloseMatrix, stack)
         
        else
            dx = dx + 1
        end if
    end while
    return i
end function

function parenthesisCallback(input as String, i as Integer, openCloseMatrix as Object, stack as Object) as Integer
    dx = 1
    substring = ""
    keywordDetected = false  ' Track if a keyword is detected in the current structure

    while i <= Len(input)
        char = Mid(input, i, 1)

        ' Handle opening parenthesis
        if char = "(" then
            stack.Push({symbol: "(", content: ""})
          '  print " Parenthesis : ("
            i = i + 1
            dx = 1  ' Reset substring length
            keywordDetected = false  ' Reset detection flag for new scope

        ' Handle closing parenthesis
        else if char = ")" then
            if stack.Count() > 0 then
                entry = stack.Pop()
              '  print " Entry Parenthesis : " + entry.content
            else
              '  print "Warning: Unmatched closing parenthesis found."
            end if
          '  print " Parenthesis : )"
            i = i + 1
            exit while  ' Exit loop once closing parenthesis is handled

        ' Detect nested structure and call recursively
       ' else if isDataStructure(input, i, openCloseMatrix, stack) then
            i = dataStructureCallback(input, i, openCloseMatrix, stack)

        ' Accumulate characters and detect keywords
        else
            substring = substring + char
        end if

        ' Move to the next character
        i = i + 1
    end while

    return i
end function

function bracesCallback(input as String, i as Integer, openCloseMatrix as Object, stack as Object) as Integer
    dx = 1
    keywordDetected = false

    while i <= Len(input)
        substring = Mid(input, i, dx)
      '  print "Current Index I: " + i.ToStr() + ", Length: " + Len(input).ToStr()
       ' print "Braces Callback : " + substring

        if substring = "{" then
            stack.Push({symbol: "{", content: ""})
            i = i + 1
            dx = 1
            keywordDetected = false

        else if substring = "}" then
            if stack.Count() > 0 then
                entry = stack.Pop()
            '    print "Close Braces : " + entry.content
            else
            '    print "Warning: Unmatched closing brace."
            end if
            i = i + 1
            exit while

        'else if isDataStructure(input, i, openCloseMatrix, stack) then
            i = dataStructureCallback(input, i, openCloseMatrix, stack)
         
        else
            dx = dx + 1
        end if
        ' Ensure index advances after each loop iteration
        i = i + 1
    end while
    return i
end function

function stringCallback(input as String, i as Integer, openCloseMatrix as Object) as Integer
    quoteChar = Mid(input, i, 1)
    i = i + 1
    while i < Len(input)
        char = Mid(input, i, 1)
        if char = quoteChar and Mid(input, i - 1, 1) <> "\" ' Closing quote found
            i = i + 1
            exit while
        else
            i = i + 1
        end if
    end while
    return i
end function

' Handle statement endings
function statementEndCallback(line as String, i as Integer, m as Object) as Integer
    print "End of statement detected: " + line
    return i + 1
end function

function callback_if()
    print "callback_if"
end function

function callback_import()
    print "callback_import"
end function

function callback_in()
    print "callback_in"
end function

function callback_instanceof()
    print "callback_instanceof"
end function

function callback_let()
    print "callback_let"
end function

function callback_new()
    print "callback_new"
end function

function callback_null()
    print "callback_null"
end function

function callback_return()
    print "callback_return"
end function

function callback_super()
    print "callback_super"
end function

function callback_switch()
    print "callback_switch"
end function

function callback_this()
    print "callback_this"
end function

function callback_throw()
    print "callback_throw"
end function

function callback_true()
    print "callback_true"
end function

function callback_try()
    print "callback_try"
end function

function callback_typeof()
    print "callback_typeof"
end function

function callback_var()
    print "callback_var"
end function

function callback_void()
    print "callback_void"
end function

function callback_while()
    print "callback_while"
end function

function callback_with()
    print "callback_with"
end function

function callback_yield()
    print "callback_yield"
end function

function callback_yield_star()
    print "callback_yield*"
end function

' Special Keywords
function callback_arguments()
    print "callback_arguments"
end function

function callback_async()
    print "callback_async"
end function

function callback_eval()
    print "callback_eval"
end function

function callback_constructor()
    print "callback_constructor"
end function

function callback_prototype()
    print "callback_prototype"
end function

function callback_static()
    print "callback_static"
end function

function callback_get()
    print "callback_get"
end function

function callback_set()
    print "callback_set"
end function

function callback_public()
    print "callback_public"
end function

' Strict Mode Reserved Keywords
function callback_implements()
    print "callback_implements"
end function

function callback_interface()
    print "callback_interface"
end function

function callback_package()
    print "callback_package"
end function

function callback_private()
    print "callback_private"
end function

function callback_protected()
    print "callback_protected"
end function


