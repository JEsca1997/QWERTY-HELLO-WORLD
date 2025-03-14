'================================================================
' FUNCTN : PARSER 
' DESCRT : Function to parse content 
' PARAMS : ( dlim - delimiter , input - input, keep - keep delimiter in return )
' RETURN : Object containing the parsed content 
'================================================================
function parse(delimiters as Object, input as object, keep_delims as Object) as Object

    if isValid(input)
        if isString(input)
                ' Array to store the parsed content
            parsedContent = CreateObject("roArray", 0, true)

            ' Array to store all delimiter positions
            limits = CreateObject("roArray", 0, true)
            
            ' Find all instances of each delimiter in the input string using allInstances

            delimiterInstances = allInstances(true, delimiters, input, true)
                
            'print "TOKEN COUNT : " + toString(delimiterInstances.Count())

            if delimiterInstances.Count() <> 0 
                sort(delimiterInstances)
            end if 

            startIndex = 1
            
            for each limit in delimiterInstances


                index = limit.index
                dlim = limit.token
                if startIndex = index 
                    
                    if isInList(dlim, keep_delims)
                        parsedContent.push(dlim)
                    end if
                    startIndex = index + len(dlim) 

                else if startIndex < index
                    ' Extract the substring before the delimiter
                    segment = mid(input, startIndex, index - startIndex)
                    'print "START INDEX : " + toString(startIndex) + " DLI :  " + toString(index) + " Segment : " + toString(segment)
                    parsedContent.push(segment)
                    ' Check if the delimiter should be kept
                    if isInList(dlim, keep_delims)
                        parsedContent.push(dlim)
                    end if
                    startIndex = index + len(dlim)
                
                end if

            end for
            
            ' Add the remaining part of the input to the parsedContent
            if startIndex <= len(input)
                segment = getSubString(input, startIndex, len(input), true)
                parsedContent.push(segment)
            end if

            return parsedContent
        end if
    else 
        return invalid
    end if


   
end function

'================================================================