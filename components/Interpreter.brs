' Function to find a token within a token
function tokenInToken(input as String, index as Integer, list as Object, parent as String, m as Object) as String
    'print "TOKEN IN TOKEN : PARENT " + parent
    char = invalid

    if IsString(input) and isInteger(index)
        char = Mid(input, index, 1)  ' Get the character at the given index
    end if

    if isValid(char)
        if Type(list) = "roArray"
            'print "RO | ARRAY"
            tags = allInstances(false, [char], list, true)
            maxTokenSize = getMax(tags)
            if isString(maxTokenSize)
                maxTokenSize = Len(maxTokenSize)
            end if
            if isValid(maxTokenSize)
                'print "Max Token Size: " + Str(maxTokenSize)
                while maxTokenSize > 0
                    delta = Mid(input, index, maxTokenSize)  ' Get substring of max token size
                    predicates = filterSize(tags, maxTokenSize, "ext")
                    for each prediction in predicates
                        if prediction = delta
                            ' Check if the token is alphabetic
                        if isAlphabetic(prediction)
                            ' Check if the token is an operator/keyword
                                ' Check if the token is surrounded by whitespace or non-string operators
                                if (index = 0 or IsWhitespace(Mid(input, index - 1, 1)) or isOperator(Mid(input, index - 1, 1), m.jsKeywordsMatrix)) and (index + maxTokenSize = Len(input) or IsWhitespace(Mid(input, index + maxTokenSize, 1)) or isOperator(Mid(input, index + maxTokenSize, 1), m.jsKeywordsMatrix))
                                    return prediction
                                end if
                        else
                            return prediction
                        end if
                        end if
                    end for
                    maxTokenSize -= 1
                end while
            end if
        else if Type(list) = "roAssociativeArray"
            ' print "RO | Associative Array"
            newList = getTokens(list)
            return tokenInToken(input, index, newList, "TOKENINTOKEN", m)
        else if Type(list) = "roList"
            ' print "RO | List"
        else
            ' print "Invalid list type. Expected Array, AssociativeArray, or List | Type : " + Type(list)
            if isString(input) and isInteger(index)
                print "RETURN | " + Mid(input, index, 1)
                return Mid(input, index, 1)
            else
                return ""
            end if
        end if
        if isString(input) and isInteger(index)
            return Mid(input, index, 1)
        else
            return ""
        end if
    else
        return ""
    end if
end function

function interpret(parent as String , input as String, m as Object) as Object
    print " INTERPRET | PARENT : " + parent

    unwind(parent, input, m) 

end function

function unwind(parent as String, input as String, m as Object) as Object

    print "function unwinding(" + input + ")"

    if not isString(input) or not isValid(input)
      print " TYPE(input) : " + Type(input)
      return []
  end if 

  ' Get the final token list
  tokens = []
  openClose = OC_Matrix()
  operators = parseOperators(input, m.javaKeys, m)

  result = rewind(parent, input, tokens, m.jsKeywordsMatrix, openClose, operators)

  ' Output the stack and check if it matches the input
  
  'Out = ""
  'ROut = ""
 ' for each operator in operators
    '  Out = Out + operator["value"]
   '   ROut = ROut + operator["value"] + "|"
 ' end for

  Out = ""
  ROut = ""
  for each token in result.tokens
      Out = Out + token["value"]
      ROut = ROut + token["value"] + "|"
  end for

  if Out = input
      print "Parsing sucessful: " + Chr(10) + " Original input: " + input +  Chr(10) + " Parsed output: " + ROut
  else
      print "Parsing failed: " + Chr(10) + " Original input: " + input +  Chr(10) + " Parsed output: " + ROut
  end if

  return operators

  return []

    

end function

function rewind(parent as String, input as String, tokens as Object, jsKeywordsMatrix as Object, openClosePairs as Object, operators as Object) as Object

        print "rewind (" + input + ")"

        print " REWIND PARENT STYLE "
        operatorsAndSymbols = jsKeywordsMatrix["operators"]
    
        op_out = "{"
        for each op in operators
            op_out = op_out + op["value"] + ", "
        end for
        op_out = op_out + "}"
    
        print "OPERATOR UNWIND := " + op_out
    
        lOperator = invalid
        cOperator = invalid
        nOperator = invalid
    
        i = 1
        ctag = 0
    
        while i <= Len(input)
    
            if ctag < operators.Count()
                cOperator = operators[ctag]   
                endToken = cOperator["index"] + Len(cOperator["value"]) - 1
                print "i: " + Str(i) + ", ctag: " + Str(ctag) + ", cOperator[value]: " + cOperator["value"] + ", cOperator[index]: " + Str(cOperator["index"])
            else
                cOperator = invalid
               ' print "cOperator Invalid"
            end if
    
            if cOperator <> invalid and i < cOperator["index"]
                preOp = getSubString(input, i, cOperator["index"], false)
                print "preOp: " + preOp
    
                entry = CreateObject("roAssociativeArray")
                entry["value"] = preOp
                entry["index"] = i
                entry["tag"] = -1
    
                tokens.Push(entry)
    
    
                i = cOperator["index"]
    
            else if cOperator <> invalid
                tokens.push(cOperator)
                i = endToken
                print "Processing cOperator: " + cOperator["value"]
                cb = isCommentSymbol(cOperator["value"], openClosePairs)
                cs = isStringSymbol(cOperator["value"], jsKeywordsMatrix["operators"])
                if cb or cs 
                    
                    closeTAG = findMatchingCloseSymbol(operators, cOperator["tag"] + 1, openClosePairs, cOperator["value"])
    
                    print " Is Comment or String | cOperator: " + cOperator["value"] + " | OPEN : " + Str(cOperator["tag"]) + " | CLOSE : " + Str(closeTag)
    
                    if closeTAG <> -1
                        
                        print "closeTAG <> -1 : CLOSE "
                      
                        startIndex = cOperator["index"]
                        endIndex = operators[closeTAG]["index"] + Len(operators[closeTAG]["value"]) - 1
                        entireSection = getSubString(input, endToken + 1, operators[closeTAG]["index"], false)
                        
                        print "Skipping entire section: " + entireSection
    
                        entry = CreateObject("roAssociativeArray")
                        entry["value"] = entireSection
                        entry["index"] = startIndex
                        entry["tag"] = -1
    
                        tokens.Push(entry)
                        tokens.push(operators[closeTag])
    
                        i = endIndex + 1
                        ctag = closeTAG + 1
                    else
    
                        print "closeTAG = -1"
    
                        if cb
                            if cOperator["value"] = "//"
                                cTag = operators.Count() 
                                comment = getSubString(input, endToken + 1, len(input), true )
    
                                entry = CreateObject("roAssociativeArray")
                                entry["value"] = comment
                                entry["index"] = endToken + 1
                                entry["tag"] = -1
    
                                tokens.Push(entry)
                                i = len(input) + 1
                            end if
                        end if
    
    
    
                    end if
                else
    
                    if isOpenSymbol(cOperator["value"], jsKeywordsMatrix)
                        print "Found open symbol: " + cOperator["value"]
                        closeTAG = findMatchingCloseSymbol(operators, ctag + 1, openClosePairs, cOperator["value"])
    
                        if closeTAG <> -1
                            print "Found close symbol: " + operators[closeTAG]["value"]
    
                            startIndex = cOperator["index"] + Len(cOperator["value"])
                            endIndex = operators[closeTAG]["index"] 
    
                            if not startIndex = endIndex
                                body = getSubstring(input, startIndex, endIndex, false)
                                print "Body to parse: " + body
                                nestedTokens = []
    
                                newOperators = getSubset(startIndex, operators, cOperator["tag"] + 1, closeTag, false)
    
                                print "RECURSED: Pushed closing Operator: cOperator[value] :  " + cOperator["value"] + " Closing Operator : " + operators[closeTAG]["value"] + " cOperator[tag] : " + Str(cOperator["tag"]) + " Closing Operator Tag : " + Str(operators[closeTag]["tag"])
    
                              '  for each nestedToken in newOperators
                                  '  print " Nested TOKENS : " + nestedToken["value"]
                                   ' tokens.Push(nestedToken)
                              '  end for
    
                                result = rewind(parent, body, tokens, jsKeywordsMatrix, openClosePairs, newOperators)
    
                                
                            end if
    
                            cOperator = operators[closeTAG]
                            tokens.push(cOperator)
    
                            endIndex = cOperator["index"] + len(cOperator["value"]) 
    
                            i = endIndex
                            ctag = closeTAG 
    
                            print "RECURSED: Pushed closing Operator: " + cOperator["value"]
    
                        else 
                            i = i + 1
                        end if
                    else
    
                        i = endToken  + 1
    
                        ' Additional postOp section to handle the rest of the input using next operator index
                        if ctag + 1 < operators.Count()
                            nOperator = operators[ctag + 1]
                            
                            ' Check if the current and next operator are adjacent
                            if i < nOperator["index"] 
                                postOp = getSubString(input, i, nOperator["index"], false)
                                print "Additional postOp: " + postOp
                        
                                entry = CreateObject("roAssociativeArray")
                                entry["value"] = postOp
                                entry["index"] = i
                                entry["tag"] = -1
                        
                                tokens.Push(entry)
                        
                                i = nOperator["index"]
                            else
                                ' Move to the next operator if they are adjacent
                                i = nOperator["index"]
                            end if
                        
                        else if i < Len(input)
                            postOp = getSubString(input, i, Len(input), true)
                            print "Additional postOp (end of input): " + postOp
                        
                            entry = CreateObject("roAssociativeArray")
                            entry["value"] = postOp
                            entry["index"] = i
                            entry["tag"] = -1
                        
                            tokens.Push(entry)
                            i = Len(input) + 1 ' Update i to end the loop
                        end if
                        
    
                    end if
    
                    ctag = ctag + 1
                end if
            else
                if i <= Len(input)
                    postOp = getSubString(input, i, Len(input),true)
                    print "postOp: " + postOp
    
                    entry = CreateObject("roAssociativeArray")
                    entry["value"] = postOp
                    entry["index"] = i
                    entry["tag"] = -1
    
                    tokens.Push(entry)
                    i = Len(input) + 1 ' Update i to end the loop
                end if
            end if
        end while

  
    ' Print tokens
    'print "Tokens:"
   ' for each token in tokens
     '   print "Token: " + token["value"]
    'end for

    return {
        tokens: tokens
    }
end function


' Function to find the matching close symbol for a given open symbol
function findMatchingCloseSymbol(operators as Object, startIndex as Integer, openClosePairs as Object, openSymbol as String) as Integer
    ' print "Entering findMatchingCloseSymbol with openSymbol: " + openSymbol

   ' for each operator in operators
     '   print "Match | operator : " + operator["value"]
   ' end for

    openCount = 1
    closeSymbol = invalid
    isSelfClosing = false

    ' Determine the corresponding close symbol and check if it's self-closing
    for each entry in openClosePairs["keys"]
        for each symbol in entry["symbols"]

            
           ' if entry["selfClosing"]
              '  print "Self Closing | Symbol : OPEN : " + symbol["open"] + " CLOSE : " + symbol["close"]  
           ' else 
             '   print "Not Self Closing | Symbol : OPEN : " + symbol["open"] + " CLOSE : " + symbol["close"]  
           ' end if

            if openSymbol = symbol["open"]
                closeSymbol = symbol["close"]
                isSelfClosing = entry["selfClosing"]
                exit for
            end if
        end for
        if closeSymbol <> invalid
            exit for
        end if
    end for

   ' if isValid(closeSymbol)
    '     print "Determined closeSymbol: " + closeSymbol
   ' end if

    ' Find the matching close symbol
    for i = startIndex to operators.Count() - 1

       '  print "Check operator | Open Symbol : " + openSymbol + ", value: " + operators[i]["value"]

        if operators[i]["value"] = openSymbol and not isSelfClosing
            openCount = openCount + 1
            ' print "Found another openSymbol at index " + Str(i) + ", openCount: " + Str(openCount)
        else if operators[i]["value"] = closeSymbol and not isSelfClosing
            openCount = openCount - 1
            ' print "Found closeSymbol at index " + Str(i) + ", openCount: " + Str(openCount)
            if openCount = 0
                ' print "Matching close symbol found at index " + Str(i)
                return i
            end if
        else if isSelfClosing
            ' Self-closing tags are handled differently than regular tags
            if operators[i]["value"] = closeSymbol
              '   print "Found close symbol at index " + Str(i) + ", openCount: " + Str(openCount)
                return i
            end if
        end if
    end for

    ' print "No matching close symbol found"
    return -1  ' Return -1 if no matching close symbol is found
end function


function getItems(startIndex as Integer, endIndex as Integer, list as Object) as Object
    ' Validate input
    if Type(list) <> "roArray"
        print "Error: 'list' must be an array."
        return invalid  ' Return invalid for an error
    end if
    
    if startIndex < 1 or endIndex > list.Count() or startIndex > endIndex
        print "Error: Invalid range. Ensure 1 <= startIndex <= endIndex <= list.Count()."
        return invalid  ' Return invalid for an error
    end if

    ' Create a new array to store the items in the range
    items = CreateObject("roArray", 0, true)
    
    ' Loop through the list from startIndex to endIndex
    for i = startIndex to endIndex
        items.Push(list[i - 1])  ' Push items into the new array (BrightScript is 1-indexed)
    end for

    return items  ' Return the new array with items in the range
end function

function getIndexOf(list as Object, token as String, index as Integer) as Integer
    ' Validate input
    print " List Type : " + Type(list) + " Token : " + Type(token)
    if not isArray(list) or not isString(token)
        print "Error: Invalid input. 'list' must be an array and 'token' must be a string."
        return -1  ' Return -1 to indicate an error
    end if

    if token <> Chr(10)
     trimmed = trim(token)
    end if

    ' Loop through the list starting from the given index
    for i = index to list.Count() - 1

        if isAssociativeArray(list[i])
           
            print "type(list[i]) = AssociativeArray | TOKEN : " + token + " Current : " + list[i]["value"] 
           
            if token = Chr(10)
                if 0 < Instr(0, list[i]["value"], token)
                    return i
                end if
            else  if list[i]["value"] = trimmed  ' BrightScript arrays are 1-indexed
                return i  ' Return the current index if the token matches
            end if

        else 
            print "type(list[i]) != AssociativeArray" 

            if token = Chr(10)
                if 0 < Instr(0, list[i], token)
                    return i
                end if
            else  if list[i] = trimmed  ' BrightScript arrays are 1-indexed
                return i  ' Return the current index if the token matches
            end if

        end if

    end for
    
    return -1  ' Return -1 if the token is not found
end function


function isStringSymbol(token as String, openClosePairs as Object) as Boolean
    ' Check if the token is a single or double quote
    singleQuote = openClosePairs[54]
    doubleQuote = openClosePairs[53]
    
    ' Verify if the token matches single or double quote
    if token = singleQuote or token = doubleQuote
        return true
    end if

    return false  ' Return false if not a string symbol
end function

function indexInString(input as String, sequence as String, index as Integer, checkToken as Boolean, jsKeywordsMatrix as Object) as Boolean
    tokenList = []
    tokenList = getTokens(jsKeywordsMatrix)

    Quote = """"""  ' String placeholders for double and single quotes
    doubleQuote = Mid(Quote, 0, 1)
    singleQuote = "'"

    insideSingleQuote = false
    insideDoubleQuote = false

    ' Determine the token to check
    if checkToken
        token = tokenInToken(input, index, tokenList, "INDEX IN STRINGS", m)
    else
        token = sequence
    end if

    tokenLength = Len(token)

   ' print "Input : " + input + " Sequence : " + sequence + " Token : " + token + " Index : " + Str(index)

    for i = 1 to Len(input)
        char = Mid(input, i, 1)

        ' Toggle quote flags if a quote character is found
        if char = singleQuote and not insideDoubleQuote
            insideSingleQuote = not insideSingleQuote
        else if char = doubleQuote and not insideSingleQuote
            insideDoubleQuote = not insideDoubleQuote
        end if

        ' Check if the current index falls within the bounds of the sequence
        if i = index
            endIndex = index + tokenLength - 1

            ' Ensure the entire token lies within the quoted string
            if (insideSingleQuote or insideDoubleQuote)
               ' print "TRUE  : Token is inside a quoted string."
                return true
            else
               ' print "FALSE : Token is not inside a quoted string."
                return false
            end if
        end if
    end for

    return false
end function


'================================================================



' Function to check if an index is within a comment in the input sequence
function indexInComment(input as String, sequence as String, index as Integer, checkToken as Boolean, openCloseMatrix as Object) as Boolean
    jsKeywordsMatrix = js_Keywords_Matrix()
    tokens = []
    tokens = extractStrings(jsKeywordsMatrix, tokens, false)

    insideSingleComment = false
    insideMultiComment = false

    i = 1
    while i <= Len(input)
        singleCommentOpen = openCloseMatrix["keys"][1]["single"]["open"]
        singleCommentClose = openCloseMatrix["keys"][1]["single"]["close"]
        multiCommentOpen = openCloseMatrix["keys"][1]["multi"]["open"]
        multiCommentClose = openCloseMatrix["keys"][1]["multi"]["close"]

        tokenHere = Mid(input, i, Len(singleCommentOpen))  ' Check for single-line comment
        if tokenHere = singleCommentOpen
            insideSingleComment = true
        else if insideSingleComment and Mid(input, i, 1) = singleCommentClose  ' End of single-line comment
            insideSingleComment = false
        end if

        tokenHere = Mid(input, i, Len(multiCommentOpen))  ' Check for multi-line comment
        if tokenHere = multiCommentOpen
            insideMultiComment = true
        else if insideMultiComment and Mid(input, i, Len(multiCommentClose)) = multiCommentClose
            insideMultiComment = false
        end if

        ' If the current index matches and we're inside a comment, return true
        if i = index
            return insideSingleComment or insideMultiComment
        end if

        i += 1
    end while

    return false
end function



'================================================================

function parseLine(input as String, i as Integer, m as Object, jsKeywordsMatrix as Object) as Object
    ' Trim leading and trailing whitespace from the input string
    input = Trim(input) 
    
    ' Extract the list of operators and symbols from the jsKeywordsMatrix
    operatorsAndSymbols = jsKeywordsMatrix[1]
    
    ' Initialize an empty array to store parsed substrings and operators
    parsedArray = CreateObject("roArray", 0, true)  

    ' Extract all operators and symbols from the input string
    operators = parseOperators(input, m.javaKeys, m)
    
    ' Sort the list of operators and symbols by their indices
    sortedList = sortKeywordIndices(operators)

    ' Variable to keep track of the current position in the input string
    c = 1  

    ' Iterate through the sorted list of operators
    for each item in sortedList
        oIndex = item["index"]  ' Get the index of the current operator

        ' Check if there is a substring before the current operator
        if c < oIndex
            preOP = Mid(input, c, oIndex - c)  ' Extract the substring before the operator
            stringEntry = CreateObject("roAssociativeArray")  ' Create an associative array for the substring
            stringEntry["index"] = c  ' Store the index of the substring
            stringEntry["value"] = preOP  ' Store the value of the substring
            parsedArray.Push(stringEntry)  ' Add the substring entry to the parsed array
        end if

        ' Create an associative array for the operator
        operatorEntry = CreateObject("roAssociativeArray")
        operatorEntry["index"] = oIndex  ' Store the index of the operator
        operatorEntry["value"] = item["value"]  ' Store the operator itself
        parsedArray.Push(operatorEntry)  ' Add the operator entry to the parsed array

        ' Update the current position to exclude the processed operator
        c = oIndex + Len(item["value"])
    end for

    ' Check if there is any remaining part of the input string after the last operator
    if c <= Len(input)
        remaining = Mid(input, c, Len(input) - c + 1)  ' Extract the remaining substring
        if Len(remaining) > 0
            stringEntry = CreateObject("roAssociativeArray")  ' Create an associative array for the remaining substring
            stringEntry["index"] = c  ' Store the index of the remaining substring
            stringEntry["value"] = remaining  ' Store the value of the remaining substring
            parsedArray.Push(stringEntry)  ' Add the remaining substring entry to the parsed array
        end if
    end if

    processLine(parsedArray,m)

    ' Reconstruction Loop
    deconstructedLine = ""  ' Variable to store the deconstructed line with delimiters
    reconstructedLine = ""  ' Variable to store the reconstructed line
    for each entry in parsedArray
       ' print " Entry : " + entry["value"]  ' Print the value of each parsed entry
        deconstructedLine = deconstructedLine + entry["value"] + "|"  ' Append the value with a delimiter to the deconstructed line
        reconstructedLine = reconstructedLine + entry["value"]  ' Append the value to the reconstructed line
    end for

    ' Print the original input line, the deconstructed line, and the reconstructed line
    print "Input Line: " + input
    print "Deconstructed Line: " + deconstructedLine
    print "Reconstructed Line: " + reconstructedLine

    return parsedArray  ' Return the parsed array for further use
end function