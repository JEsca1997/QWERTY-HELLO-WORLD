' Check if the input is a JavaScript syntax
function isJS(input as String, m as Object) as Boolean
    parseJS(input, m)
end function

function js_Keywords_Matrix() as Object
    Quotes = """"""  ' String placeholders for double and single quotes
    doubleQuotes = Mid(Quotes, 0, 1)
    singleQuotes = "'"
    newLine = Chr(10)
    carriageReturn = Chr(13)
    
    reservedKeywords = [
        "await", "break", "case", "catch", "class", "const", "continue", 
        "debugger", "default", "delete", "do", "else", "enum", "export", 
        "extends", "false", "finally", "for", "function", "if", "import", 
        "in", "instanceof", "let", "new", "null", "return", "super", 
        "switch", "this", "throw", "true", "try", "typeof", "var", 
        "void", "while", "with", "yield", "yield*", "as", "from", "of"
    ]

    reservedEntry = CreateObject("roAssociativeArray")
    reservedEntry["keys"] = reservedKeywords
    reservedEntry["type"] = "reserved"
    
    
    specialKeywords = [
        "arguments", "async", "await", "eval", "constructor", "prototype", 
        "static", "get", "set", "declare", "module", "require"
    ]

    specialEntry = CreateObject("roAssociativeArray")
    specialEntry["keys"] = specialKeywords
    specialEntry["type"] = "special"
    
    futureKeywords = [
        "enum", "implements", "interface", "package", "private", 
        "protected", "public", "any", "boolean", "number", "string", 
        "symbol", "type", "namespace", "keyof", "readonly"
    ]

    futureEntry = CreateObject("roAssociativeArray")
    futureEntry["keys"] = futureKeywords
    futureEntry["type"] = "future"
    
    strictKeywords = [
        "implements", "interface", "package", "private", "protected", 
        "public"
    ]

    strictEntry = CreateObject("roAssociativeArray")
    strictEntry["keys"] = strictKeywords
    strictEntry["type"] = "strict"
    
    operators = [
        ".", ",", ":", ";", "?", "=>", "...", "#", "+", "-", "*", "/", "%", 
        "**", "&", "|", "^", "~", "!", "=", "==", "===", "!=", "!==", ">", 
        "<", ">=", "<=", "&&", "||", "??", "<<", ">>", ">>>", "+=", "-=", 
        "*=", "/=", "%=", "**=", "&=", "|=", "^=", "??=", "<<=", ">>=", 
        ">>>=", "{", "}", "[", "]", "(", ")", doubleQuotes, singleQuotes,
        newLine, carriageReturn, "/*", "*/", "//"]

    operatorsEntry = CreateObject("roAssociativeArray")
    operatorsEntry["keys"] = operators
    operatorsEntry["type"] = "operators"

    jsKeywordsMatrix = CreateObject("roAssociativeArray")
    'jsKeywordsMatrix["OC"] = openCloseEntry
    jsKeywordsMatrix["operators"] = operators
    jsKeywordsMatrix["reserved"] = reservedKeywords
    jsKeywordsMatrix["special"] = specialKeywords
    jsKeywordsMatrix["future"] = futureKeywords
    jsKeywordsMatrix["strict"] = strictKeywords

    return jsKeywordsMatrix
end function




' Function to get all operators (strings) under the entry item "keys" from the matrix
function getTokens(Matrix as Object) as Object
    allTokens = []  ' Initialize an empty list to store all tokens
    extractStrings(Matrix, allTokens, false)  ' Start the recursive search with the initial matrix
    return allTokens  ' Return the combined list of all tokens
end function

' Recursive function to search through the matrix
function extractStrings(matrix as Object, allTokens as Object, ordered as Boolean) as Void
    
   ' print "Entering searchMatrix with matrix of type: " + Type(matrix)
    testKeys = [] ' Initialize an empty list to store
    if ordered 
    
    else 

        if isArray(matrix)
            for c = 0 to matrix.Count() -1
                if not isValid(matrix[c])
                   ' print "KEY | INVALID: "
                else if isValid(matrix[c]) and isString(matrix[c])
                    'print "KEY | STRING: " + matrix[c]
                    allTokens.Push(matrix[c])
                else if isValid(matrix[c]) and (isArray(matrix[c]) or IsAssociativeArray(matrix[c]) or islist(matrix[c]))
                    extractStrings(matrix[c], allTokens, ordered)
                end if
            end for
        end if

        if Type(matrix) = "roAssociativeArray"
            items = matrix.items()
            
            testKeys = matrix.Keys()

            if testKeys.Count() <> 0
                for each tKey in testKeys
    
                    if Type(tKey) = "roInvalid"
    
                        'print "KEY | INVALID: " 
    
                    else if Type(tkey) = "roString"
    
                        if isValid(matrix[tkey]) and not isNumeric(tkey)
    
                           ' print "MATRIX | KEY | valid: "
                            'print "KEY | STRING: " +  TKEY
    
                            if isArray(matrix[tkey]) or IsAssociativeArray(matrix[tkey]) or isList(matrix[tkey])
                                extractStrings(matrix[tkey], allTokens, false)
                            else if isString(matrix[tkey])
                                allTokens.Push(tkey)
                            end if
    
                        else
    
                          '  print "MATRIX | KEY | Invalid: "
                            
                        end if
    
                    else if Type(tkey) = "roAssociativeArray"
                      '  print "KEY | Associative Array: "
                    else 
                     '   print "KEY | ELSE: " + Type(tkey)
                    end if
        
                end for
            end if
    
            
    
        end if
    
    end if

    
   
    'print "Exiting searchMatrix"

end function



function getKeywords(input as String, jsKeywordsMatrix as Object, m as Object) as Object
    result = CreateObject("roArray", 0, true)  ' Array to store found keywords
    allKeywords = CreateObject("roArray", 0, true)  ' Combine all keyword lists
    allKeywords.Append(jsKeywordsMatrix[1])  ' Reserved keywords
    allKeywords.Append(jsKeywordsMatrix[2])  ' Special keywords
    allKeywords.Append(jsKeywordsMatrix[3])  ' Future reserved keywords
    allKeywords.Append(jsKeywordsMatrix[4])  ' Strict mode reserved keywords

    tokens = []
    tokens = extractStrings(jsKeywordsMatrix, tokens, false)

    i = 0
    while i < Len(input)
        token = tokenInToken(input, i, tokens, "getKEywords" , m )  ' Use tokenInToken to get the next matching keyword

        if token <> ""
            ' Check if the token is a valid keyword
            for each keyword in allKeywords
                if token = keyword
                    entry = CreateObject("roAssociativeArray")
                    entry["index"] = i  ' Store the index of the token
                    entry["value"] = token  ' Store the value of the token
                    result.Push(entry)  ' Add to result array
                    exit for
                end if
            end for
        end if

        i = i + Len(token)  ' Move the pointer forward
        if Len(token) = 0
            i = i + 1  ' Avoid infinite loop if no token is found
        end if
    end while

    return result  ' Return the array of found keywords
end function
' Function to check if an input symbol is an operator
function isOperator(input as String, jsKeywordsMatrix as Object) as Boolean
    operators = jsKeywordsMatrix["operators"]
    return isInList(input,operators)
end function


function isTOKEN(input as String, jsKeywordsMatrix as Object) as Boolean

    size = Len(input)
    reduced = filterSize(jsKeywordsMatrix, size, "ext")
    
    for each operator in reduced
        if input = operator
            return true
        end if
    end for
    
    return false
end function


function inString(code as Object, sequence as String, jsKeywordsMatrix as Object) as Boolean
    singleQuote = jsKeywordsMatrix[0][Len(jsKeywordsMatrix[0]) - 1]  ' Extract single quote character
    doubleQuote = jsKeywordsMatrix[0][Len(jsKeywordsMatrix[0]) - 2]  ' Extract double quote character

    insideSingleQuote = false  ' Track if currently inside single quotes
    insideDoubleQuote = false  ' Track if currently inside double quotes

    for each token in code
        tokenValue = token["value"]  ' Get the token value

        ' Process the token value character by character
        for i = 1 to Len(tokenValue)
            char = Mid(tokenValue, i, 1)

            ' Check for single and double quotes and toggle state
            if char = singleQuote and not insideDoubleQuote then
                insideSingleQuote = not insideSingleQuote
            else if char = doubleQuote and not insideSingleQuote then
                insideDoubleQuote = not insideDoubleQuote
            end if
        end for

        ' Check if the sequence exists within the current token and is inside a string literal
        if InStr(1, tokenValue, sequence) > 0 and (insideSingleQuote or insideDoubleQuote)
            return true  ' The sequence is found inside a string literal
        end if
    end for

    return false  ' The sequence is not inside any string literal
end function



function isKeyword(input as String, jsKeywordsMatrix as Object) as Boolean
    reservedKeywords = jsKeywordsMatrix["reserved"]["keys"]  ' Reserved keywords
    specialKeywords = jsKeywordsMatrix["special"]["keys"]  ' Special keywords
    futureReservedKeywords = jsKeywordsMatrix["future"]["keys"]  ' Future reserved keywords
    strictModeReservedKeywords = jsKeywordsMatrix["strict"]["keys"] ' Strict mode reserved keywords

    ' Combine all keyword categories into one check
    for each keyword in reservedKeywords
        if input = keyword
            return true
        end if
    end for

    for each keyword in specialKeywords
        if input = keyword
            return true
        end if
    end for

    for each keyword in futureReservedKeywords
        if input = keyword
            return true
        end if
    end for

    for each keyword in strictModeReservedKeywords
        if input = keyword
            return true
        end if
    end for

    return false  ' Return false if no match is found
end function

' Main function for processing JavaScript content line-by-line
function parseJS(input as String, m as Object) as Integer
    '   print "Processing input: " + input
   
       i = 0
       jsKeywordsMatrix = js_Keywords_Matrix()
       openCloseMatrix = jsKeywordsMatrix["0"]
       allKeywords = combineKeywords(jsKeywordsMatrix)
       stack = []  ' Track open symbols and buffers
       currentWord = ""  ' Accumulate potential keywords or identifiers
       jsKeywordsMatrix = js_Keywords_Matrix()
       interpret("parse", input , m)
   
       return Len(input)  ' Return length of processed line
   end function
   
   


function formatArray(arr as Object) as String
    result = "["
    if arr <> invalid and Type(arr) = "roArray"
        for each item in arr
            result = result + item + ", "
        end for
        result = TrimRight(result, ", ")
    end if
    result = result + "]"
    return result
end function







   


function processLine(code as Object, m as Object) 
   ' print "Routing symbol: " + symbol

    jsKeywordsMatrix = m.javaKeys
    operatorsAndSymbols = jsKeywordsMatrix[5]

    for each token in code
       if isTOKEN(token["value"], jsKeywordsMatrix) or isKeyword(token["value"], jsKeywordsMatrix)
        print "true   | OPERATOR OR TOKEN : " + token["value"]
            
       else
        print "false  | OPERATOR OR TOKEN : " + token["value"]

       end if
    end for

end function
function inComment(code as Object, jsKeywordsMatrix as Object) as Object
    results = CreateObject("roAssociativeArray") ' Store whether each token is in a comment
    singleLineComment = "//"  ' Single-line comment start
    multiLineCommentOpen = "/*"  ' Multi-line comment start
    multiLineCommentClose = "*/"  ' Multi-line comment end

    insideSingleLineComment = false  ' Track if currently inside a single-line comment
    insideMultiLineComment = false  ' Track if currently inside a multi-line comment

    for each token in code
        tokenValue = token["value"]  ' Get the token value
        inCommentFlag = false  ' Flag to indicate if the token is inside a comment

        for i = 1 to Len(tokenValue)
            ' Extract the current character and the next one for comment checking
            char = Mid(tokenValue, i, 1)
            nextChar = ""
            if i < Len(tokenValue)
                nextChar = Mid(tokenValue, i + 1, 1)
            end if
            twoChars = char + nextChar  ' Combine current and next character

            ' Check for single-line comment start
            if twoChars = singleLineComment
                insideSingleLineComment = true
            end if

            ' Check for multi-line comment start
            if twoChars = multiLineCommentOpen
                insideMultiLineComment = true
            end if

            ' Check for multi-line comment end
            if twoChars = multiLineCommentClose
                insideMultiLineComment = false
            end if

            ' If inside either comment type, mark the flag
            if insideSingleLineComment or insideMultiLineComment
                inCommentFlag = true
            else
                inCommentFlag = false
            end if
        end for

        ' Reset single-line comment flag after processing the token (single-line comments don't span tokens)
        insideSingleLineComment = false

        ' Store the result for this token
        results[tokenValue] = inCommentFlag
    end for

    return results
end function

function dataStructureCallback(input as String, i as Integer, openCloseMatrix as Object, stack as Object) as Integer
    char = Mid(input, i, 1)
   ' print "Data structure : " + char

    ' Check which structure we are dealing with and delegate
    if isBraces(input, i, openCloseMatrix, stack) then
        i = bracesCallback(input, i, openCloseMatrix, stack)
    else if isBrackets(input, i, openCloseMatrix, stack) then
        i = bracketsCallback(input, i, openCloseMatrix, stack)
    else if isParenthesis(input, i, openCloseMatrix, stack) then
        i = parenthesisCallback(input, i, openCloseMatrix, stack)
    end if

    return i + 1  ' Move to the next character after processing structure
end function




function parseOperators(input as String, jsKeywordsMatrix as Object, m as Object) as Object

    'print "INPUT : " + input 
    
    i = 1
    tag = 0

    oIndex = []

    while i <= len(input)

        token = tokenInToken(input, i, jsKeywordsMatrix, "parse Operators", m)
        
        if isTOKEN(token, jsKeyWordsMatrix) 
           ' print " PARSE(OPERATORS) |  OPERATOR : " + token + " TAG : " + Str(tag)
            entry = CreateObject("roAssociativeArray")
            entry["index"] = i 
            entry["value"] = token
            entry["tag"] = tag 
            oIndex.push(entry)
            tag = tag + 1
        end if

        i = i + Len(token)

    end while 

    return oIndex  ' Return the array of found operators
end function


' Function to get instances of a token in a string using a token list
function getInstances(input as String, tokenList as Object, m as Object) as Object
    instancesArray = CreateObject("roArray", 0, true)  ' Array to store associative arrays of found tokens
    visitedIndices = CreateObject("roAssociativeArray")  ' Tracks visited indices to avoid duplicates
    position = 1  ' Start position for token scanning


    while position <= Len(input)
        token = tokenInToken(input, position, tokenList, false, m)  ' Get the token at the current position

        ' If the token is valid and not already counted
        if not token = "" 
            ' Create an associative array for the found token
            entry = CreateObject("roAssociativeArray")
            entry["index"] = position
            entry["value"] = token
            instancesArray.Push(entry)  ' Add the entry to the instances array
        end if

        ' Move the position forward
        position = position + Len(token)
        if Len(token) = 0
            position = position + 1  ' Handle case where tokenInToken fails
        end if
    end while

    return instancesArray
end function



' Helper function to check if a character is part of open-close symbols
function isInOpenClose(char as String, openCloseMatrix as Object) as Boolean
    for each pair in openCloseMatrix
        if char = pair[0] or char = pair[1]
            return true
        end if
    end for
    return false
end function


function isComment(input as String, openCloseMatrix as Object)

    commentLength = getCommentLength(input,0)
    if not commentLength = 0 and Type(commentLength) <> "roInvalid"
       ' print " Comment Length : " + Str(commentLength)
        comment = getSubString(input, 0, commentLength, true)
        if isSingleComment(input, openCloseMatrix) or isMultiComment(input, openCloseMatrix) 
            if isInsideString(input,comment)
                return false 
            else return true
            end if
        else return false
        end if
    else return false    
    end if

end function

function isCommentSymbol(input as String, openCloseMatrix as Object) as Boolean
    ' Trim the input to remove any leading or trailing whitespace
    trimmedInput = Trim(input)

    ' Extract the single and multi-line comment symbols from the matrix
    singleCommentSymbol = "//"
    singleCommentCloset = Chr(10)
    multiCommentOpenSymbol = "/*"
    multiCommentCloseSymbol = "*/"
    

   ' print "Trimmed Input : " + trimmedInput

    ' Check if the trimmed input matches any comment operator
    if trimmedInput = singleCommentSymbol or trimmedInput = multiCommentOpenSymbol or trimmedInput = multiCommentCloseSymbol
        return true
    else
        return false
    end if
end function

function getCommentLength(input as String, startIndex as Integer) as Integer
    commentLength = 0
    i = startIndex  ' Start from the specified index

    ' Get operators and symbols from the JS Keywords Matrix
    jsKeywords = js_Keywords_Matrix()
    operatorsAndSymbols = jsKeywords[0]
    
    ' Extract single-line and multi-line comment markers
    singleLineComment = "//"
    multiLineCommentOpen = "/*"
    multiLineCommentClose = "*/"

    while i < Len(input)
        ' Extract current character and look ahead where necessary
        char = Mid(input, i, 1)
        nextChar = ""
        if i + 1 <= Len(input)
            nextChar = Mid(input, i + 1, 1)
        end if

        token = char + nextChar  ' Combine current and next character

        ' Check for single-line comment
        if token = singleLineComment
            j = i + 2  ' Start after //
            while j <= Len(input) and Mid(input, j, 1) <> Chr(10) and Mid(input, j, 1) <> Chr(13)  ' Look for end of the line
                j += 1
            end while
            commentLength += j - i  ' Add length of the single-line comment
            i = j  ' Move pointer past the comment

        ' Check for multi-line comment
        elseif token = multiLineCommentOpen
            j = i + 2  ' Start after /*
            while j < Len(input) - 1 and Mid(input, j, 1) + Mid(input, j + 1, 1) <> multiLineCommentClose  ' Look for */
                j += 1
            end while
            if j < Len(input) - 1
                j += 2  ' Move pointer past */
            end if
            commentLength += j - i  ' Add length of the multi-line comment
            i = j  ' Move pointer past the comment

        else
            i += 1  ' Move to the next character
        end if
    end while

    return commentLength-1
end function


' Consolidates all keywords into a single list
function combineKeywords(jsKeywordsMatrix as Object) as Object
    allKeywords = []
    numLists = jsKeywordsMatrix.Count()

    ' Iterate over each entry in the matrix and check if it contains "keys"
    for i = 1 to numLists - 1
        entry = jsKeywordsMatrix[Str(i)]
        
        if entry <> invalid and entry.Lookup("keys", invalid) <> invalid then
            keywordList = entry["keys"]  ' Get the keyword list from the entry
            for each keyword in keywordList
                allKeywords.Push(keyword)
            end for
        end if
    end for

    return allKeywords
end function



' Function to get the open/close matrix
function OC_Matrix() as Object
    doubleQuotes = Chr(34)
    singleQuotes = "'"
    newLine = Chr(10)
    carriageReturn = Chr(13)

   ' print "Double Quotes : " + doubleQuotes + " Single Quotes : " + singleQuotes 

    openClose = [
        {
            "type": "string",
            "selfClosing": true,
            "symbols": [
                {"open": singleQuotes, "close": singleQuotes},
                {"open": doubleQuotes, "close": doubleQuotes}
            ]
        },
        {
            "type": "comment",
            "selfClosing": false,
            "symbols": [
                {"open": "//", "close": newLine},
                {"open": "/*", "close": "*/"}
            ]
        },
        {
            "type": "struct",
            "selfClosing": false,
            "symbols": [
                {"open": "{", "close": "}"},
                {"open": "[", "close": "]"},
                {"open": "(", "close": ")"}
            ]
        }
    ]

    openCloseEntry = CreateObject("roAssociativeArray")
    openCloseEntry["keys"] = openClose
    openCloseEntry["type"] = "OC"

    return openCloseEntry
end function


' Function to check if an input is an open symbol
function isOpenSymbol(input as String, jsKeywordsMatrix as Object) as Boolean
    openClose = OC_Matrix()

    ' Iterate through each type in the openClose matrix
    for each entry in openClose["keys"]
        ' Iterate through each symbol in the current type
        for each symbol in entry["symbols"]
            if input = symbol["open"]
                return true
            end if
        end for
    end for

    return false
end function



' Function to check if an input is a close symbol
function isCloseSymbol(input as String, jsKeywordsMatrix as Object) as Boolean
    jsKeywordsMatrix = js_keywords_matrix()
    openClose = jsKeywordsMatrix["OC"]["keys"]
    
    ' Check close symbols
    if input = openClose["string"]["single"]["close"] or input = openClose["string"]["double"]["close"] then
        return true
    end if
    
    if input = openClose["comment"]["single"]["close"] or input = openClose["comment"]["multi"]["close"] then
        return true
    end if
    
    if input = openClose["struct"]["brace"]["close"] or input = openClose["struct"]["bracket"]["close"] or input = openClose["struct"]["parenthesis"]["close"] then
        return true
    end if

    return false
end function

' Function to check if an input is either an open or a close symbol
function isOpenCloseSymbol(input as String, jsKeywordsMatrix as Object) as Boolean
    if isOpenSymbol(input, jsKeywordsMatrix) or isCloseSymbol(input, jsKeywordsMatrix) then
        return true
    end if
    
    return false
end function

function readScript(code as String, parent as String)
    interpret("script", code,m)
    if isString(code)
        print "READ SCRIPT | CODE : " + code
    end if
end function

function isJStructure(input as String, i as Integer, openCloseMatrix as Object, stack as Object) as Boolean
  '  print " IS DATA STRUCTURE "
    return isBraces(input, i, openCloseMatrix, stack) or isBrackets(input, i, openCloseMatrix, stack) or isParenthesis(input, i, openCloseMatrix, stack)
end function

function isParenthesis(input as string, i as integer, openCloseMatrix as object, stack as object)
    if openCloseMatrix[0] = invalid then openCloseMatrix = js_Keywords_Matrix()[0]
    parenthesis = openCloseMatrix[2]
    char = Mid(input, i, 1)
    if char = parenthesis[0] or char = parenthesis[1]
        return true
    end if
    return false
end function

function isBraces(input as string, i as integer, openCloseMatrix as object, stack as object) as Boolean
    if openCloseMatrix[0] = invalid then openCloseMatrix = js_Keywords_Matrix()[0]
    curly_braces = openCloseMatrix[0]
    char = Mid(input, i, 1)
    if char = curly_braces[0] or char = curly_braces[1]
        return true
    end if
    return false
end function

function isBrackets(input as string, i as integer, openCloseMatrix as object, stack as object) as Boolean
    if openCloseMatrix[0] = invalid then openCloseMatrix = js_Keywords_Matrix()[0]
    square_brackets = openCloseMatrix[1]
    char = Mid(input, i, 1)
    if char = square_brackets[0] or char = square_brackets[1]
        return true
    end if
    return false
end function


function handleKeyWord(input as String, i as Integer, stack as Object, openCloseMatrix as Object) as Integer
    keywordsMatrix = js_Keywords_Matrix()
    reservedKeywords = keywordsMatrix[1]
    specialKeywords = keywordsMatrix[2]
    futureReservedKeywords = keywordsMatrix[3]
    strictModeReservedKeywords = keywordsMatrix[4]


    
    ' Combine all keywords into a single array
    allKeywords = []
    for each keyword in reservedKeywords
        allKeywords.Push(keyword)
    end for
    for each keyword in specialKeywords
        allKeywords.Push(keyword)
    end for
    for each keyword in futureReservedKeywords
        allKeywords.Push(keyword)
    end for
    for each keyword in strictModeReservedKeywords
        allKeywords.Push(keyword)
    end for

    for each keyword in allKeywords
        output = Mid(input, i, Len(keyword))
    end for

    ' Loop through all keywords and route to the appropriate callback
    for each keyword in allKeywords
        if Mid(input, i, Len(keyword)) = keyword then
            print "Keywords | Found keyword: " + keyword
            i = i + Len(keyword) - 1

            ' Call the corresponding callback function
            if keyword = "await" then
                callback_await()
            else if keyword = "break" then
                callback_break()
            else if keyword = "case" then
                callback_case()
            else if keyword = "catch" then
                callback_catch()
            else if keyword = "class" then
                callback_class()
            else if keyword = "const" then
                callback_const()
            else if keyword = "continue" then
                callback_continue()
            else if keyword = "debugger" then
                callback_debugger()
            else if keyword = "default" then
                callback_default()
            else if keyword = "delete" then
                callback_delete()
            else if keyword = "do" then
                callback_do()
            else if keyword = "else" then
                callback_else()
            else if keyword = "enum" then
                callback_enum()
            else if keyword = "export" then
                callback_export()
            else if keyword = "extends" then
                callback_extends()
            else if keyword = "false" then
                callback_false()
            else if keyword = "finally" then
                callback_finally()
            else if keyword = "for" then
                callback_for()
            else if keyword = "function" then

                callback_function(input, i, true)

            else if keyword = "if" then
                callback_if()
            else if keyword = "import" then
                callback_import()
            else if keyword = "in" then
                callback_in()
            else if keyword = "instanceof" then
                callback_instanceof()
            else if keyword = "let" then
                callback_let()
            else if keyword = "new" then
                callback_new()
            else if keyword = "null" then
                callback_null()
            else if keyword = "return" then
                callback_return()
            else if keyword = "super" then
                callback_super()
            else if keyword = "switch" then
                callback_switch()
            else if keyword = "this" then
                callback_this()
            else if keyword = "throw" then
                callback_throw()
            else if keyword = "true" then
                callback_true()
            else if keyword = "try" then
                callback_try()
            else if keyword = "typeof" then
                callback_typeof()
            else if keyword = "var" then
                callback_var()
            else if keyword = "void" then
                callback_void()
            else if keyword = "while" then
                callback_while()
            else if keyword = "with" then
                callback_with()
            else if keyword = "yield" then
                callback_yield()
            else if keyword = "yield*" then
                callback_yield_star()
            else if keyword = "arguments" then
                callback_arguments()
            else if keyword = "async" then
                callback_async()
            else if keyword = "eval" then
                callback_eval()
            else if keyword = "constructor" then
                callback_constructor()
            else if keyword = "prototype" then
                callback_prototype()
            else if keyword = "static" then
                callback_static()
            else if keyword = "get" then
                callback_get()
            else if keyword = "set" then
                callback_set()
            else if keyword = "implements" then
                callback_implements()
            else if keyword = "interface" then
                callback_interface()
            else if keyword = "package" then
                callback_package()
            else if keyword = "private" then
                callback_private()
            else if keyword = "protected" then
                callback_protected()
            else if keyword = "public" then
                callback_public()
            end if

            return i
        end if
    end for

    return i
end function

' Function to check if current position is at a string
function isJString(input as String, i as Integer, openCloseMatrix as Object) as Boolean
    char = Mid(input, i, 1)
    return char = Chr(34) or char = "'"
end function






function isSingleComment(input as String, openCloseMatrix as Object) as Boolean
    openSingleComment = openCloseMatrix["//"]  ' Access using the correct key
    if Left(input, Len(openSingleComment)) = openSingleComment
        return true
    end if
    return false
end function


function isMultiComment(input as String, openCloseMatrix as Object) as Boolean
    openMultiLineComment = openCloseMatrix["/*"]  ' Access the multi-line comment start
    closeMultiLineComment = openCloseMatrix["*/"]  ' Access the multi-line comment end

    if Left(input, Len(openMultiLineComment)) = openMultiLineComment and Right(input, Len(closeMultiLineComment)) = closeMultiLineComment
        return true
    end if

    return false
end function

