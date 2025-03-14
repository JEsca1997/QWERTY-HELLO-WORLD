
function isDataStructure(value as Dynamic) as Boolean 
    return isArray(value) or IsAssociativeArray(value) or isList(value)
end function

' Function to check if a string is alphabetic
function isAlphabetic(input as String) as Boolean
    if Len(input) = 0
        return false
    end if

    for i = 0 to Len(input) - 1
        char = Mid(input, i, 1)
        if Asc(char) < 65 or (Asc(char) > 90 and Asc(char) < 97) or Asc(char) > 122
            return false
        end if
    end for

    return true
end function



function runEssentialsTest(m as Object)
    test = "test!==test!==test!=test==test=test"
    list = parseOperators(test,m.javaKeys, m)
    output = "{ "

      for each operator in list 
          output = output + operator["value"] + ", "
      end for

      output = Trim(output)
      output = TrimRight(output, ",")
      output = output + " }"

      print output


    opTest = "!="

  if isTOKEN(opTest, m.javaKeys)
      print "The operator " + opTest + " is an operator."
  else 
      print "The operator " + opTest + " is not an operator."
  end if


  list = allInstances(false, opTest, m.javaKeys, false)

  output = "{ "

  for each operator in list 
      output = output + operator + ", "
  end for

  output = Trim(output)
  output = TrimRight(output, ",")
  output = output + " }"

  print output

  opTest = "for"

  if isKeyword(opTest, m.javaKeys)
      print "The operator " + opTest + " is a keyword."
  else 
      print "The operator " + opTest + " is an operator."
  end if
end function

function TrimRight(input as String, trimSubstring as String) as String
    ' Check if the input ends with the trimSubstring
    while Right(input, Len(trimSubstring)) = trimSubstring
        input = Mid(input, 1, Len(input) - Len(trimSubstring)) ' Remove the trimSubstring from the end
    end while
    return input
end function

' Function to get a subset of an array between start and end indices, with reindexing and retagging
function getSubset(delta as Integer, arr as Object, startIndex as Integer, endIndex as Integer, tip as Boolean) as Object
    subset = CreateObject("roArray", 0, true)  ' Initialize an empty array

    if startIndex < 0 or endIndex < 0 or startIndex >= arr.Count() or endIndex >= arr.Count()
        return subset  ' Return an empty array if indices are out of range
    end if

    ' Swap start and end indices if endIndex is before startIndex
    if endIndex < startIndex
        temp = startIndex
        startIndex = endIndex
        endIndex = temp
    end if

    ' Adjust the endIndex based on the value of tip
    if not tip
        endIndex = endIndex - 1
    end if

    ' Add elements to subset array
    baseIndex = arr[startIndex]["index"]
    for i = startIndex to endIndex
        element = arr[i]
        subset.Push(element)
    end for

    ' Retag the elements in the subset array with new tags and indices
    return retag(delta, subset)
end function

' Function to retag the elements in the list with new tags and indices
function retag(baseIndex as Integer, list as Object) as Object
    tag = 0
    for each item in list
        if isValid(item["tag"])
            item["tag"] = tag
            item["index"] = (item["index"] - baseIndex) + 1
            tag = tag + 1
        end if
    end for
    return list
end function

' Function to sort an associative array or an array of associative arrays by the "index" key
function sort(matrix as Object) as Object
    ' Check if the matrix is a valid associative array
    if Type(matrix) = "roAssociativeArray"
        ' Convert associative array to an array of key-value pairs
        keyValuePairs = CreateObject("roArray", 0, true)
        for each key in matrix
            keyValuePairs.push({key: key, value: matrix[key]})
        end for
        
        ' Implement bubble sort for the key-value pairs based on the "index" key
        for i = 0 to keyValuePairs.count() - 2
            for j = 0 to keyValuePairs.count() - 2 - i
                if keyValuePairs[j].value.index > keyValuePairs[j + 1].value.index
                    temp = keyValuePairs[j]
                    keyValuePairs[j] = keyValuePairs[j + 1]
                    keyValuePairs[j + 1] = temp
                end if
            end for
        end for
        
        ' Create a new sorted associative array
        sortedMatrix = CreateObject("roAssociativeArray")
        for each pair in keyValuePairs
            sortedMatrix[pair.key] = pair.value
        end for
        
        return sortedMatrix

    else if Type(matrix) = "roArray"
        ' Sort an array of associative arrays by the "index" key of each sub-associative array
        for i = 0 to matrix.count() - 2
            for j = 0 to matrix.count() - 2 - i
                if matrix[j]["index"] > matrix[j + 1]["index"]
                    temp = matrix[j]
                    matrix[j] = matrix[j + 1]
                    matrix[j + 1] = temp
                end if
            end for
        end for
        
        return matrix

    else
        print "Error: Input is neither an associative array nor an array of associative arrays"
        return matrix
    end if
end function

function getUnits(property as String, input as String, m as Object) as Object
    print "Starting getUnits function | property: " + property + " | Input: " + input

    unitproperty = "unknown"
    value = input

    if Right(input, 1) = "%" then
        unitproperty = "percent"
        value = Mid(input, 1, Len(input) - 1).ToFloat()
        value = value / 100 ' Convert percentage to decimal
        ' Multiply by the appropriate dimension based on property
        if property = "width" or property = "left" or property = "right"
            value = value * m.bounds.width
        elseif property = "height" or property = "top" or property = "bottom"
            value = value * m.bounds.height
        end if
    elseif input = "auto" then
        unitproperty = "auto"
        value = 0 ' Auto can be handled separately with specific logic
    elseif Instr(1, input, "calc(") = 1 then
        unitproperty = "calc"
        value = 0
        print " Calc : Property " + property + " Input : " + input
       ' value = input ' Can further process calc expressions if needed
    elseif Right(input, 2) = "px" then
        unitproperty = "px"
        value = Mid(input, 1, Len(input) - 2).ToFloat()
    else
        unitproperty = "unknown"
        value = input.ToFloat()
    end if

    print "Unit property: " + unitproperty + " | Value: " + value.ToStr()

    return {
        unitproperty: unitproperty,
        value: value
    }
end function

'------------------------------------------------------------
' Custom Split function
'------------------------------------------------------------
function Split(str_ as string, delimiter as string) as Object
    result = []
    start_ = 0
    while true
        index = Instr(start_, str_, delimiter)
        if index = -1
            result.Push(Mid(str_, start_))
            exit while
        else
            result.Push(Mid(str_, start_, index - start_))
            start_ = index + Len(delimiter)
        end if
    end while
    return result
end function

' Function to convert CSS colors to BrightScript format (0xRRGGBBAA)
function convertColors(colorValue as String) as String
    ' Check if the color value is in rgb format
    if Instr(1, colorValue, "rgb(") = 1 then
        ' Extract the RGB values
        colorValue = Mid(colorValue, 5, Len(colorValue) - 5) ' Remove "rgb(" and ")"

        ' Initialize variables
        red = 0
        green = 0
        blue = 0

        ' Find positions of commas
        comma1 = Instr(1, colorValue, ",")
        comma2 = Instr(comma1 + 1, colorValue, "," )

        ' Extract and convert RGB values
        red = Val(Trim(Mid(colorValue, 1, comma1 - 1)))
        green = Val(Trim(Mid(colorValue, comma1 + 1, comma2 - comma1 - 1)))
        blue = Val(Trim(Mid(colorValue, comma2 + 1)))

        ' Convert RGB values to hex format
        hexRed = Right("0" + intToHex(red, 16), 2)
        hexGreen = Right("0" + intToHex(green, 16), 2)
        hexBlue = Right("0" + intToHex(blue, 16), 2)

        ' Combine the hex values with alpha (FF for fully opaque)
        hexColor = "0x" + hexRed + hexGreen + hexBlue + "FF"

        return hexColor
    else
        ' Handle other color formats if needed
        return colorValue ' Default to white if format is not recognized
    end if
end function

' Function to convert integer to hexadecimal string
function intToHex(value as Integer, base as Integer) as String
    hexStr = ""
    while value > 0
        remainder = value Mod base
        hexDigit = ""
        if remainder < 10 then
            hexDigit = Chr(remainder + Asc("0"))
        else
            hexDigit = Chr(remainder - 10 + Asc("A"))
        end if
        hexStr = hexDigit + hexStr
        value = value \ base
    end while

    if hexStr = "" then
        hexStr = "0"
    end if

    return hexStr
end function

function newNode(m as Object, key as String, value as Object)
   
    new_node = CreateObject("roSGNode", "Label")
    new_node.width = value["width"]
    new_node.height = value["height"]
    new_node.translation = [value["left"], value["top"]]
    new_node.text = value["content"]


    print " NEW NODE => "; key; " : "; toStringIndent(value,0); Chr(10); "} "  

    return new_node

end function 


' Function to find all instances of tokens in the matrix
function allInstances(strict as Boolean, tokens as Object, matrix as Object, b as Boolean) as Object
    result = CreateObject("roArray", 0, true)  ' Array to store all found instances

    if isString(matrix)
        'print " IS STRING MATRIX : TOKENS : " + toString(tokens) + " | Matrix : " + toString(matrix) 
        for each token in tokens
            dIndex = InStr(0, matrix, token)
            'print "DTOKEN : " + TOKEN + " D-INDEX: " + toString(dIndex)
            while dIndex > 0
                'print "FOUND TOKEN AT INDEX: " + toString(dIndex)
                result.push({index: dIndex, token: token})
                dIndex = InStr(dIndex + 1, matrix, token)
            end while
        end for

    else if isDataStructure(matrix)
      '  print " IS DATA STRUCT : Matrix : " + toString(matrix) 
        for each cell in matrix
            if isString(cell)
                for each token in tokens
                    if strict
                        if b
                            if Left(cell, Len(token)) = token and InStr(1, cell, token) > 0
                                result.Push(cell)
                            end if
                        else
                            if cell = token
                                result.Push(cell)
                            end if
                        end if
                    else
                        if b
                            if Left(cell, Len(token)) = token and InStr(1, cell, token) > 0
                                result.Push(cell)
                            end if
                        else
                            if InStr(1, cell, token) > 0
                                result.Push(cell)
                            end if
                        end if
                    end if
                end for
            else if Type(cell) = "roArray" or Type(cell) = "roList"
                nestedResults = allInstances(strict, tokens, cell, b)
                for each item in nestedResults
                    result.Push(item)
                end for
            else if Type(cell) = "roAssociativeArray"
                allTokens = []
                allTokens = getTokens(cell)
                nestedResults = allInstances(strict, tokens, allTokens, b)
                for each item in nestedResults
                    result.Push(item)
                end for
            end if
        end for
    end if

    'print " RESULT : " + toString(result)

    if isString(matrix)
        result = sort(result)
    end if


    return result
end function


function lambda(touples as Object, operation as Object) as Integer
    return operation(touples) ' Call the passed function
end function

function toString(input as Object) as String
    inputType = type(input)

    if isString(input)
        return input
    else if isValid(input) and not isDataStructure(input)
        return Str(input)
    else if isDataStructure(input)
        ' Handle data structures (arrays or associative arrays)
        result = ""
        if type(input) = "roArray"
            result = "[" ' Start array representation
            for each element in input
                'print "2str : "; element
                result = result + toString(element) + ", "
            end for
         '   print "PRE-RESULT : " + result
            if input.count() > 0
                result = left(result, len(result) - 2) ' Remove trailing comma and space
            end if
            result = result + "]" ' End array representation
          '  print "PRE-RESULT : " + result
        else if type(input) = "roAssociativeArray"
            result = toStringIndent(input, 0)
            'result = "{" + chr(10) ' Start associative array representation with a new line
            'for each key in input
            '    value = input[key]
            '    result = result + key + " : " + toString(value) + chr(10) ' Add new line after each key-value pair
            'end for
            'result = result + "}" ' End associative array representation
        end if
        return result
    else
        return Type(input)
    end if
end function

function toStringIndent(input as Object, indent as Integer) as String
    indentString = ""
    
    ' Create indentation string
    if indent > 0
        for i = 1 to indent
            indentString = indentString + " "
        end for
    end if

    ' Handle different types
    if input = invalid
        return "invalid"
    else if isString(input)
        return  input  
    else if type(input) = "roInt" or type(input) = "roFloat"
        return str(input)
    else if isBoolean(input)
        if input = true
            return "true"
        else 
            return "false"
        end if
    else if isArray(input)
        ' Handle arrays
        result = "["
        if input.count() > 0
            'print "Input Count : "; input.count()
            index = 1
            for each element in input
               ' print index;" | ELEMENT TYPE : "; type(element)
                result = result + toStringIndent(element, indent) + ", " 
                index = index + 1
            end for
            ' Remove trailing comma
            result = trim(result)
            'print "RESULT : "; result
            result = getSubString(result, 1, len(result), false) 
            if Right(result, 2) = "," + Chr(10)
                result = Left(result, Len(result) - 2) + Chr(10)
            end if
        end if
        result = result + "]"
        return result
    else if IsAssociativeArray(input) and not type(input) = "roSGNode"
        ' Handle associative arrays
        result = "{"
        if input.count() > 0
            result = result + Chr(10)
            keys = input.keys()
            for each key in keys
                value = input[key]
                result = result + indentString + "  " + Chr(34) + key + Chr(34) + ": " + toStringIndent(value, indent + 2) + "," + Chr(10)
            end for
            ' Remove trailing comma
            if Right(result, 2) = "," + Chr(10)
                result = Left(result, Len(result) - 2) + Chr(10)
            end if
        end if
        result = result + indentString + "}"
        return result
    else
        ' Handle numeric and other types
        if Type(input) = "roSGNode"
            'print " TYPE IS RO SG NODE "
            return type(input)
        else 
            'print " TYPE IS NOT RO SG NODE "
            return str(input)
        end if 

    end if
end function



function processMatrixRecursive(strict as Boolean, token as String, matrix as Object, path as Object, result as Object, seen as Object) as Boolean
    ' Initialize a tracker for seen references to detect circular references
    if seen = invalid
        seen = CreateObject("roAssociativeArray")
    end if

    ' Base case: Check if matrix is valid and non-empty
    if matrix = invalid or matrix.Count() = 0
        return false
    end if

    ' Generate a unique identifier for the current matrix by converting its address to a string
    matrixId = "MatrixRef-" + Str(matrix.ToStr())

    ' Check for self-referencing or previously visited matrices
    if seen.DoesExist(matrixId)
        print "Error: Self-referencing or previously visited matrix detected. Breaking recursion."
        return false
    end if

    ' Mark the current matrix as visited
    seen[matrixId] = true

    ' Check if matrix is an array or list
    if Type(matrix) = "roArray" or Type(matrix) = "roList"
        for i = 0 to matrix.Count() - 1
            nextPath = copyArray(path)  ' Copy the current path to avoid mutation
            nextPath.Push(i)  ' Add current index to the path

            item = matrix[i]
            if Type(item) = "roArray" or Type(item) = "roList" or Type(item) = "roAssociativeArray"
                ' Recurse into nested structure
                processMatrixRecursive(strict, token, item, nextPath, result, seen)
            else
                ' Check if the token matches the item
                checkAndStore(strict, token, item, nextPath, result)
            end if
        end for
    else if Type(matrix) = "roAssociativeArray"
        for each key in matrix
            nextPath = copyArray(path)  ' Copy the current path to avoid mutation
            nextPath.Push(key)  ' Add current key to the path

            item = matrix[key]
            if Type(item) = "roArray" or Type(item) = "roList" or Type(item) = "roAssociativeArray"
                ' Recurse into nested structure
                processMatrixRecursive(strict, token, item, nextPath, result, seen)
            else
                ' Check if the token matches the item
                checkAndStore(strict, token, item, nextPath, result)
            end if
        end for
    else
        print "Error: Invalid matrix type or structure."
        return false
    end if

    return true
end function







' Helper function to check and store matching items
function checkAndStore(strict as Boolean, token as String, item as Object, path as Object, result as Object)
    if strict
        if item = token
            ' If the item matches the token, store it with coordinates
            occurrence = CreateObject("roAssociativeArray")
            occurrence["value"] = item
            occurrence["coordinates"] = path
            result.Push(occurrence)
        end if
    else
        ' Ensure item is a string before using Instr
        if Type(item) = "roString"
            if Instr(0, item, token) > 0
                ' If the item contains the token, store it with coordinates
                occurrence = CreateObject("roAssociativeArray")
                occurrence["value"] = item
                occurrence["coordinates"] = path
                result.Push(occurrence)
            end if
        else
            ' Optionally handle other types if needed
            print "Skipping non-string item in checkAndStore: " + Str(item)
        end if
    end if
end function



' Helper function to copy an array (preserve paths in recursion)
function copyArray(original as Object) as Object
    copy_ = CreateObject("roArray", 0, true)
    for each item in original
        copy_.Push(item)
    end for
    return copy
end function


' Function to extract a substring from the input string
' Arguments:
'   input - The input string
'   startIndex - The starting index 
'   endIndex - The ending index 
'   tip - include endIndex in the output
' Returns:
'   A substring of the input string from startIndex to endIndex
function getSubString(input as String, startIndex as Integer, endIndex as Integer, tip as Boolean) as String
    
  '  print " INPUT : " + input + " LEN(INPUT) : " + Str(Len(input)) + " START : " + Str(startIndex) + " END : " + Str(endIndex)

    if startIndex < 0 or endIndex < 0 or startIndex > Len(input) or endIndex > Len(input)
        print "Error: Invalid indices provided."
        return ""  ' Return an empty string for invalid indices
    else if startIndex = endIndex
        return Mid(input, startIndex, 1)
    else if startIndex > endIndex
        ' Handle reverse substring
        reversedString = ""
        if tip
            for i = startIndex to endIndex step -1
                reversedString = reversedString + Mid(input, i, 1)
            end for
        else
            for i = startIndex to endIndex + 1 step -1
                reversedString = reversedString + Mid(input, i, 1)
            end for
        end if
        return reversedString
    else
        ' Handle regular substring
        if tip
            length = endIndex - startIndex + 1  ' Include ending character
        else
            length = endIndex - startIndex      ' Exclude ending character
        end if
        return Mid(input, startIndex, length)
    end if
end function




function Trim(input as String) as String
    ' Remove leading and trailing whitespace, newlines, carriage returns, and tabs
    while Left(input, 1) = " " or Left(input, 1) = Chr(10) or Left(input, 1) = Chr(13) or Left(input, 1) = Chr(9)
        input = Mid(input, 2, Len(input) - 1)
    end while

    while Right(input, 1) = " " or Right(input, 1) = Chr(10) or Right(input, 1) = Chr(13) or Right(input, 1) = Chr(9)
        input = Mid(input, 1, Len(input) - 1)
    end while

    return input
end function

function sortKeywordIndices(array as Object) as Object
    if Type(array) <> "roArray"
        print "Error: Input is not an array."
        return invalid
    end if

    ' Bubble sort implementation to sort by the "index" key
    for i = 0 to array.Count() - 2
        for j = 0 to array.Count() - i - 2
            if array[j]["index"] > array[j + 1]["index"]
                ' Swap elements
                temp = array[j]
                array[j] = array[j + 1]
                array[j + 1] = temp
            end if
        end for
    end for

    return array
end function

function getListsContaining(input as Object, element as String) as Object
    result = []  ' Initialize an empty array for the results

    ' Ensure the input is an array
    if Type(input) <> "roArray" and Type(input) <> "roList"
        print "Error: Input must be an array or list | TYPE(input) : " + Type(input)
    else if Type(input) = "roArray" or Type(input) = "roList"
            for each item in input
                ' Handle strings
                if Type(item) = "roString"
                    if InStr(0, item, element) > 0  ' Check if the element exists in the string
                        print " ITEM : " + item + " Element : " + element
                        result.Push(item)
                    end if        
                ' Handle arrays
                else 
                    print "Error : Input must be String "
                end if
            end for
        end if

    return result
end function

function rangeInsideString(text as String, startIndex as Integer, endIndex as Integer) as Boolean
    insideQuotes = false
    currentQuoteChar = ""  ' Tracks the type of quote used (" or ')
    quoteStartIndex = -1   ' Start index of the current string literal

    ' Fetch quote characters from the matrix
    js_Keys = js_Keywords_Matrix()
    openCloseMatrix = js_Keys[0]

    doubleQuotes = openCloseMatrix[3][0]
    singleQuotes = openCloseMatrix[4][0]

    for i = 0 to len(text) - 1
        char = mid(text, i, 1)  ' Access the current character

        ' Check for quote characters
        if char = doubleQuotes or char = singleQuotes then
            if insideQuotes then
                if char = currentQuoteChar then
                    ' Closing the string literal
                    if quoteStartIndex <> -1 then
                        ' Check if the provided range lies within the string literal
                        if startIndex >= quoteStartIndex and endIndex <= i then
                            return true
                        end if
                    end if
                    insideQuotes = false  ' Exit the string literal
                    currentQuoteChar = ""
                    quoteStartIndex = -1
                end if
            else
                ' Entering a new string literal
                insideQuotes = true
                currentQuoteChar = char
                quoteStartIndex = i + 1
            end if
        end if
    end for

    ' Return false if the range was not found inside any string literal
    return false
end function


function isInsideString(text as String, substring as String) as Boolean
    insideQuotes = false
    currentQuoteChar = ""  ' Tracks the type of quote used (" or ')
    startIndex = -1        ' Start index of the current string literal

    for i = 0 to len(text) - 1
        char = text[i]

        ' Check for quote characters
        if char = "\"" or char = "'" then
            if insideQuotes then
                if char = currentQuoteChar then
                    ' Closing the string literal
                    if startIndex <> -1 then
                        stringLiteral = mid(text, startIndex, i - startIndex)
                        ' Use InStr with starting position as 1
                        if Instr(1, stringLiteral, substring) > 0 then
                            return true
                        end if
                    end if
                    insideQuotes = false  ' Exit the string literal
                    currentQuoteChar = ""
                end if
            else
                ' Entering a new string literal
                insideQuotes = true
                currentQuoteChar = char
                startIndex = i + 1
            end if
        end if
    end for

    ' Return false if no matching substring was found inside quotes
    return false
end function

function filterSize(input as Object, size as Integer, mode as String) as Object
    result = CreateObject("roArray", 0, true)  ' Initialize an empty array for the results

    ' Ensure the input is an array or list
    if Type(input) <> "roArray" and Type(input) <> "roList"
        print "Error: Input must be an array or list."
        return result
    end if

    for each element in input
        ' Handle strings
        if isString(element)
            elementSize = Len(element)
            ' Apply mode logic
            if mode = "ext" and elementSize = size
                result.Push(element)  ' Wrap in a list to maintain sublist consistency
            else if mode = "min" and elementSize <= size
                result.Push(element)
            else if mode = "max" and elementSize >= size
                result.Push(element)
            end if

        ' Handle arrays or lists
        else if Type(element) = "roArray" or Type(element) = "roList"
            elementSize = element.Count()
            ' Apply mode logic
            if mode = "ext" and elementSize = size
                result.Push(element)  ' Add sublist as is
            else if mode = "min" and elementSize <= size
                result.Push(element)
            else if mode = "max" and elementSize >= size
                result.Push(element)
            end if

        else
            ' Ignore other types
            print "Warning: Ignoring unsupported type. : " + Type(element)
        end if
    end for

    return result
end function

' Function to find the maximum value in an array 
function getMax(arr as Object) as Dynamic 
    if arr.Count() = 0 
        return invalid 
    end if 
    maxVal = arr[0] 
    for i = 1 to arr.Count() - 1 
        currentVal = arr[i] 
        maxLength = getComparableValue(maxVal) 
        currentLength = getComparableValue(currentVal) 
        if currentLength > maxLength 
            maxVal = currentVal 
        end if 
    end for 
    return maxVal 
end function 

' Function to find the minimum value in an array 
function getMin(arr as Object) as Dynamic 
    if arr.Count() = 0 
        return invalid 
    end if 
    minVal = arr[0] 
    for i = 1 to arr.Count() - 1 
        currentVal = arr[i] 
        minLength = getComparableValue(minVal) 
        currentLength = getComparableValue(currentVal) 
        if currentLength < minLength 
            minVal = currentVal 
        end if 
    end for 
    return minVal 
end function 

' Helper function to get a comparable value for different types 
function getComparableValue(var as Dynamic) as Integer 
    
    if isNumeric(var) 
        return var 
    else if isString(var) 
        return Len(var) 
    else if Type(var) = "roAssociativeArray" or Type(var) = "roList" 
        return var.Count() 
    else 
        return var 
        ' Default value for unsupported types 
    end if 
end function 

' Function to get the bounds based on the specified type 
function getBounds(bound as String, arr as Object) as Dynamic 
    if bound = "min" 
        return getMin(bound) 
    else if bound = "max" 
        return getMax(arr) 
    else if bound = "range" 
        minVal = getMin(arr) 
        maxVal = getMax(arr) 
        return [minVal, maxVal] 
    else 
        return invalid 
        ' Return invalid for unsupported types 
    end if 
end function



' Function to find the last index of a character in a string
' Arguments:
'   char - The character to find
'   input - The input string to search
' Returns:
'   The last index of the character in the input string (0-based), or -1 if not found
function findLastIndexOf(char as String, input as String) as Integer
    if Len(char) <> 1
        print "Error: The search character must be a single character."
        return -1
    end if

    ' Iterate backwards through the string
    for i = Len(input) to 1 step -1
        if Mid(input, i, 1) = char
            return i - 1  ' Convert to 0-based index
        end if
    end for

    return -1  ' Return -1 if the character is not found
end function


' Custom Min function to get the minimum of two numbers
function Min(a as Integer, b as Integer) as Integer
    if a < b then
        return a
    else
        return b
    end if
end function

' Function to check if a character is alphabetical
function IsAlpha(char as String) as Boolean
    asciiValue = Asc(char)
    if (asciiValue >= 65 and asciiValue <= 90) or (asciiValue >= 97 and asciiValue <= 122)
        return true
    else
        return false
    end if
end function

' Custom Ceil function
function Ceil(value as Float) as Integer
    if value = Int(value) then
        return Int(value)
    else
        return Int(value) + 1
    end if
end function

function elementToStr(element as Object) as String
    if Type(element) = "roString"
        return element
    else if Type(element) = "roBoolean"
        if element = true
            return "true"
        else
            return "false"
        end if
    else if Type(element) = "roDouble" or Type(element) = "roFloat" or Type(element) = "roInt"
        return Str(element)
    else if IsAssociativeArray(element)
        return "Associative Array"
    else if Type(element) = "roArray" or Type(element) = "roList"
        return "Array/List with " + Str(element.Count()) + " elements"
    else if Type(element) = "roInvalid"
        return "Invalid"
    else
        return "Unknown Type"
    end if
end function



' Function to extract the file name from a URL
function GetFileName(url as string) as string
    parts = parse(["/"], url, [])
    print " PARTS : " + toString(parts)
    return parts[parts.Count() - 1]
end function

' Function to split a string by a delimiter
function splitString(text as String, delimiter as String) as Object
    result = CreateObject("roArray", 10, true)  ' Create an array to store the split results
    startIndex = 0
  
    ' Find delimiter positions and extract substrings
    while true
        pos_ = Instr(text, delimiter, startIndex)
        if pos_ = 0  ' No more delimiters found
            result.Push(Mid(text, startIndex))  ' Add the remaining text
            exit while
        else
            result.Push(Mid(text, startIndex, pos_ - startIndex))
            startIndex = pos_ + Len(delimiter)  ' Move past the delimiter
        end if
    end while
  
    return result
  end function
  
  ' Function to trim leading and trailing whitespace from a string
  function trimString(text as String) as String
    ' Trim leading spaces
    while Left(text, 1) = " "
        text = Mid(text, 2)
    end while
  
    ' Trim trailing spaces
    while Right(text, 1) = " "
        text = Left(text, Len(text) - 1)
    end while
  
    return text
  end function

' Function to trim whitespace from a string
function trimWhitespace(s as string) as string
    ' Remove leading whitespace
    while Len(s) > 0 and isWhitespace(Left(s, 1))
        s = Mid(s, 2)
    end while
    ' Remove trailing whitespace
    while Len(s) > 0 and isWhitespace(Right(s, 1))
        s = Left(s, Len(s) - 1)
    end while
    return s
end function

' Function to check if a character is whitespace
function isWhitespace(c as string) as Boolean
    code = Asc(c)
    return code = 32 or code = 9 or code = 10 or code = 13
end function

'-------------------------------------------
' Function to check if a key or tag exists within a categorized list
'-------------------------------------------
function isInList(item as object, list as Object) as Boolean
   
    if isString(item)
        for each t in list
            if LCase(t) = LCase(item) then
                return true
            end if
        end for
    else if isInteger(item)
        for each n in list 
            if n = item 
               return true 
            end if 
        end for
    end if   

    return false
end function

function inArray(item as String, list as Object) as Boolean

    if not isDataStructure(list) 
        return false 
    end if

    for c = 0 to list.Count() - 1
        cItem = list[c]
        if cItem = item then
            return true
        end if
    end for
    return false
end function


Function IsXmlElement(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifXMLElement") <> invalid
End Function

Function IsFunction(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifFunction") <> invalid
End Function

Function IsBoolean(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifBoolean") <> invalid
End Function

Function IsInteger(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifInt") <> invalid And (Type(value) = "roInt" Or Type(value) = "roInteger" Or Type(value) = "Integer")
End Function

Function IsFloat(value As Dynamic) As Boolean
    Return IsValid(value) And (GetInterface(value, "ifFloat") <> invalid Or (Type(value) = "roFloat" Or Type(value) = "Float"))
End Function

Function IsDouble(value As Dynamic) As Boolean
    Return IsValid(value) And (GetInterface(value, "ifDouble") <> invalid Or (Type(value) = "roDouble" Or Type(value) = "roIntrinsicDouble" Or Type(value) = "Double"))
End Function

Function IsList(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifList") <> invalid
End Function

Function IsArray(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifArray") <> invalid
End Function

Function IsAssociativeArray(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifAssociativeArray") <> invalid
End Function

Function IsString(value As Dynamic) As Boolean
    Return IsValid(value) And GetInterface(value, "ifString") <> invalid
End Function

Function IsDateTime(value As Dynamic) As Boolean
    Return IsValid(value) And (GetInterface(value, "ifDateTime") <> invalid Or Type(value) = "roDateTime")
End Function

Function IsValid(value As Dynamic) As Boolean
    Return Type(value) <> "<uninitialized>" And value <> invalid
End Function

' Function to check if a character is numeric
function isNumeric(char as Object) as Boolean
    if isDataStructure(char) or NOT isValid(char)
        return false
    end if
    if Len(char) = 1 and Asc(char) >= Asc("0") and Asc(char) <= Asc("9")
        return true
    else
        return false
    end if
end function

function createTreeNode(value as Dynamic, children as Object) as Object
    node = { 
       value: value, 
       children: children, 
       addChild: function(child as Object) 
           m.children.Push(child) 
       end function } 
       return node 
end function