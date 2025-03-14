sub scrape()
    print "CR | GETCONTENT (trimmed version)"
    
    ' Get server configuration and construct serverPath
    m.serverInfo = fetch_Server_Info()
    m.protocol = "http://"
    m.ip = toString(m.serverInfo.ip)
    m.portForward = Trim(toString(m.serverInfo.port))
    m.serverPath = m.protocol + m.ip + ":" + m.portForward
    print "CR | SERVER PATH: " + m.serverPath

    PRINT "CR | POSTING SCREEN INFO"
    ' Optionally, post screen info if required
    postScreenInfo("size", toString(m.bounds), m)
    PRINT "CR | POSTED SCREEN..."

    print "CR | FETCHING CLASSES..."
    ' Use fetch_Classes to get merged class content from a remote URL
    classes = fetch_Classes("http://www.soundcloud.com", m)
    print "CR | FETCHED CLASSES."

    ' If classes is an array of objects, append each as a child node
    'if classes <> invalid and isDataStructure(classes) then
     '    for each classItem in classes
     '        child = content.createChild("ContentNode")
      '       child.setFields(classItem)
      '   end for
   ' end if

    ' Assign the updated content node to m.top.content
   ' m.top.content = content
end sub

sub getcontent()

    content = createObject("roSGNode", "ContentNode")

    m.htmlMap = htmlMap()
    di = CreateObject("roDeviceInfo")
    m.height = di.getDisplaySize()["h"]
    m.width = di.getDisplaySize()["w"]
    m.bounds = { x : 0, y : 0, width : m.width, height  : m.height }

    if isValid(m.top.data)
        print "M.TOP.DATA | TRUE | TYPE : " ; type(m.top.data)
    else 
        print "M.TOP.DATA | FALSE "
    end if

    ' Get server configuration and construct serverPath
    m.serverInfo = fetch_Server_Info()
    m.protocol = "http://"
    m.ip = toString(m.serverInfo.ip)
    m.portForward = Trim(toString(m.serverInfo.port))
    m.serverPath = m.protocol + m.ip + ":" + m.portForward

    print "SCRAPER | SERVER INFO | IP : " + toString(m.ip)
    print "SCRAPER | SERVER INFO | PORT : " + toString(m.portForward)
    print "SCRAPER | SERVER INFO | INFO : " + toString(m.serverInfo)
    print "SCRAPER | M.SERVERPATH : " + m.serverPath

    ' Optionally, post screen info (if this is still required)
    postScreenInfo("size", toString(m.bounds), m)

    ' Use fetch_Classes to get merged class content from a remote URL
    url = "http://soundcloud.com"
    func_1 = "/fetch-merge?url="
    func_2 = "/fetch-count"

    path_1 = m.serverPath + func_1 + url
    path_2 = m.serverPath + func_2

    print "CB | Fetching Merged Classes " + path_1

    request_1 = CreateObject("roUrlTransfer")

    print "CB | REQUEST CREATED"

    request_1.SetUrl(path_1)

    print "CB | URL : " + path_1

    ' Fetch content as a string
    m.top.data = request_1.GetToString()
    classContent = request_1.GetToString()


    request_2 = CreateObject("roUrlTransfer")
    request_2.setUrl(path_2)
    classCount = request_2.getToString()

    m.classCount = classCount


    print "Class Count : "; classCount
    print "EXIT | getContent()"
    

    m.top.content = content
  end sub

function holder()
   ' if isArray(class_)
        'for each occ in class_
            str_content = ""
            'if isValid(occ["superClass"])
                'if isValid(occ["superClass"]["elementInfo"])
                    'if isValid(occ["superClass"]["elementInfo"]["tagName"])
                        'tagName = LCase(occ["superClass"]["elementInfo"]["tagName"])
                    'end if

                    ' Only process if the tag is allowed
                    'if isInList(tagName, allowedTags)

                        'if isValid(occ["superClass"]["elementInfo"]["text"])
                            'text = occ["superClass"]["elementInfo"]["text"]
                            'print "KEY : "; key; " TEXT : "; text; " OCC : "; toStringIndent(occ, 0)
                        'end if

                       


                        'if isValid(occ["superClass"]["elementInfo"]["attributes"])

                            'if isValid(occ["superClass"]["elementInfo"]["attributes"]["content"])
                            '    str_content = occ["superClass"]["elementInfo"]["attributes"]["content"]
                               ' print "Key : "; key; " CONTENT VALID : "; content
                           ' end if

                           ' if isValid(occ["superClass"]["elementInfo"]["attributes"]["style"])
                               ' if isValid(occ["superClass"]["elementInfo"]["attributes"]["style"]["default"])
                                  '  defaultStyle = occ["superClass"]["elementInfo"]["attributes"]["style"]["default"]
                                    ' Optional: Make a deep copy if you need to modify it without affecting the original
                                  '  dJ = FormatJson(defaultStyle)
                                 '   styleCopy = ParseJson(dJ)
                                
                                    ' Assume "text" holds your text content and "content" holds any content attribute
                                 '   textContent = occ["superClass"]["elementInfo"]["text"]
                                 '   str_content = occ["superClass"]["elementInfo"]["attributes"]["content"]
                                    ' You might choose one or the other; here we combine them:

                                  '  if textContent <> "" then
                                  '      finalText = textContent
                                 '   else
                                 '       finalText = str_content
                                 '   end if
                                    
                                
                                    ' Create and append the label node
                                    'add_node = createLabelNode(key, finalText, styleCopy, m)
                                    'itemContent = content.createChild("ContentNode")



                                    'print "ItemContent Type : " + Type(itemContent)
                                    
                                    'm.body_port.appendChild(add_node)
                                    
                               ' else
                               '     print "No default style for tag: " + tagName
                              '  end if
                                
                          '  else
                         '       print "STYLE NOT VALID for tag: "; tagName
                         '   end if
                       ' else
                       '     print "Attributes not valid for tag: "; tagName
                       ' end if
                    'else
                    '    print "Skipping non-allowed tag: "; tagName
                    'end if
               ' else
                    'print "ElementInfo not valid for key: "; key
               ' end if
            'else
            '    print "superClass not valid for key: "; key
            'end if
        'end for
    'else
    '    print "Expected array for class_ but got: "; Type(class_)
    'end if
end function
  
function layoutBrowser(m)

    if NOT isValid(m.bounds)
        di = CreateObject("roDeviceInfo")
            screenSize = di.getDisplaySize()
            width = screenSize.w
            height = screenSize.h
        
        m.screenSize = screenSize 
        m.width = width
        m.height = height
        m.bounds = { x : 0, y : 0, width : m.width, height  : m.height }
    end if

    screen = m.bounds
    
    font = {
        size : 22,
        family : ""
    }

    classCount = val(m.classCount)
    classes = m.classes

    sc_width = m.bounds.width 
    sc_height = m.bounds.height 

    vp_width = sc_width 
    vp_height = sc_height 

    c_width = vp_width * (15/16) ' * some ratio optimized for resolution with content body and vertical scroller 
    c_height = classCount * font.size

    sl_width = vp_width * (1/16)
    sl_height = vp_height

    viewport = CreateObject("roSGNode", "Group")

    viewport.id = "viewport"
    viewport.clippingRect = [0, 0, vp_width, vp_height]

    print " Map | Width : " ; toString(m.bounds.width); " Height : " ; toString(classCount * font.size)

    content = CreateObject("roSGNode", "Group")

    bk_bounds = CreateObject("roSGNode", "Rectangle")
    bk_bounds.width = c_width 
    bk_bounds.height = c_height
    bk_bounds.color = "0xFF0000FF"

    content.appendChild(bk_bounds)

    print " Background | Width : " ; toString(bk_bounds.width); " Height : " ; toString(bk_bounds.height);" Color : " ; toString(bk_bounds.color)

    scrollgroup = CreateObject("roSGNode", "Group")
    
    scrollbox = CreateObject("roSGNode", "Rectangle")
        
        scrollbox.width =  sl_width
        scrollbox.height = sl_height
        scrollbox.translation = [c_width, 0]
        scrollbox.color = "0x00FF00FF"

    scroller = CreateObject("roSGNode", "Rectangle")
       
        scroller.width =  sl_width
        scroller.height =  sc_height / classCount ' figure out height based on ratio of thumb to total background
        scroller.translation = [c_width, 0]
        scroller.color = "0x0000FFFF"
    
    scrollgroup.appendChild(scrollbox)
    scrollgroup.appendChild(scroller)

    viewport.appendChild(content)
    viewport.appendChild(scrollgroup)

    m.viewport = viewport
    'm.contentContainer.appendChild(m.viewport)
    'm.contentContainer.appendChild(background)

    print "Class Count : "; toString(classCount)

end function 

  function render(m as Object, content as Object)
    classCount = m.classCount
    classes = m.classes

    print "Class Count : "; toString(classCount)

    layoutBrowser(m)

    ' Define the list of allowed tags (content-bearing GUI elements)
    allowedTags = [
        "button", "h1", "h2", "h3", "h4", "h5", "h6", "label", "p", "div", "span", "a", "article", "section", "header", "footer", "nav", "aside", "ul", "ol", "li", "blockquote", "pre", "code", "figure", "figcaption"
    ]

    if IsAssociativeArray(classes)
        keys = classes.Keys()
        for each key in keys 
            class_ = classes[key]
            tagName = ""
            if isArray(class_)
                for each occ in class_
                    content = ""
                    if isValid(occ["superClass"])
                        if isValid(occ["superClass"]["elementInfo"])
                            if isValid(occ["superClass"]["elementInfo"]["tagName"])
                                tagName = LCase(occ["superClass"]["elementInfo"]["tagName"])
                            end if

                            ' Only process if the tag is allowed
                            if isInList(tagName, allowedTags)

                                if isValid(occ["superClass"]["elementInfo"]["text"])
                                    text = occ["superClass"]["elementInfo"]["text"]
                                    'print "KEY : "; key; " TEXT : "; text; " OCC : "; toStringIndent(occ, 0)
                                end if

                                if isValid(occ["superClass"]["elementInfo"]["attributes"])

                                    if isValid(occ["superClass"]["elementInfo"]["attributes"]["content"])
                                        content = occ["superClass"]["elementInfo"]["attributes"]["content"]
                                       ' print "Key : "; key; " CONTENT VALID : "; content
                                    end if

                                    if isValid(occ["superClass"]["elementInfo"]["attributes"]["style"])
                                        if isValid(occ["superClass"]["elementInfo"]["attributes"]["style"]["default"])
                                            defaultStyle = occ["superClass"]["elementInfo"]["attributes"]["style"]["default"]
                                            ' Optional: Make a deep copy if you need to modify it without affecting the original
                                            dJ = FormatJson(defaultStyle)
                                            styleCopy = ParseJson(dJ)
                                        
                                            ' Assume "text" holds your text content and "content" holds any content attribute
                                            textContent = occ["superClass"]["elementInfo"]["text"]
                                            content = occ["superClass"]["elementInfo"]["attributes"]["content"]
                                            ' You might choose one or the other; here we combine them:

                                            if textContent <> "" then
                                                finalText = textContent
                                            else
                                                finalText = content
                                            end if
                                            
                                        
                                            ' Create and append the label node
                                            add_node = createLabelNode(key, finalText, styleCopy, m)
                                            itemContent = content.createChild("ContentNode")

                                            print "ItemContent Type : " + Type(itemContent)
                                            
                                            'm.body_port.appendChild(add_node)
                                            
                                        else
                                            print "No default style for tag: " + tagName
                                        end if
                                        
                                    else
                                        print "STYLE NOT VALID for tag: "; tagName
                                    end if
                                else
                                    print "Attributes not valid for tag: "; tagName
                                end if
                            else
                                print "Skipping non-allowed tag: "; tagName
                            end if
                        else
                            print "ElementInfo not valid for key: "; key
                        end if
                    else
                        print "superClass not valid for key: "; key
                    end if
                end for
            else
                print "Expected array for class_ but got: "; Type(class_)
            end if
        end for
    else
        if isDataStructure(classes)
            print "STRUCT | TRUE | RENDER : "; Type(classes)
        else
            print "STRUCT | FALSE | RENDER : "; Type(classes)
        end if
    end if
end function


'------------------------------------------------------------
' Helper function to create and append a Label node
'------------------------------------------------------------
function createLabelNode(key as String, labelText as Object, style as Object, m as Object) as Object
    if IsValid(labelText)
        print "TRUE | IsValid(labelText)"
        labelNode = CreateObject("roSGNode", "Label")
        labelNode.id = key
    
        ' Set label properties from the style associative array
        if isValid(style["width"]) then labelNode.width = style["width"]
        if isValid(style["height"]) then labelNode.height = style["height"]
        if isValid(style["left"]) and isValid(style["top"]) then
            labelNode.translation = "["+toString(style["left"])+","+toSTring(style["top"])+"]"
            print " TRANSLATION | X : "; toString(style["left"]); " Y : "; toString(style["top"])
            print " TRANSLATION | TRANS : "; toString(labelNode.translation)
        end if
        if isValid(style["font-size"]) then labelNode.font.size = style["font-size"]
        if isValid(style["padding"]) then labelNode.padding = style["padding"]
        if isValid(style["margin"]) then labelNode.margin = style["margin"]
        
        labelNode.color = "0x000000FF"
        
        ' Set the label's content/text
        labelNode.text = labelText
    
        ' Append the new node to the content container
        ' m.contentContainer.appendChild(labelNode)
        print "Label node created | KEY : " + key + " Node : " + toStringIndent(style,0)
        return labelNode

    else
        print "FALSE | IsValid(labelText)"
        return {}
    end if

    
end function

sub scrape_()
    print "CR | GETCONTENT (trimmed version)"
    
    ' Create a ContentNode to hold the fetched content (if needed)
    content = createObject("roSGNode", "ContentNode")

    
    'print "FETCH_CLASSES : "; classContent

    ' Parse the JSON content
    'classJSON = parseJSON(classContent)


    'print "CR | Classes fetched: " + toStringIndent(classes, 0)

    ' Option 1: If classes is the final content, assign it directly
    'm.top.content = content

end sub


'------------------------------------------------------------
' Function to fetch and display merged class content from Puppeteer server
'------------------------------------------------------------
function fetch_Classes(url as string, m as Object) as Object
    func = "/fetch-merge?url="
    path = m.serverPath + func + url

    print "CB | Fetching Merged Classes " + path

    request = CreateObject("roUrlTransfer")

    print "CB | REQUEST CREATED"

    request.SetUrl(path)

    print "CB | URL : " + path

    ' Fetch content as a string
    classContent = request.GetToString()

    print "FETCH_CLASSES : "; classContent

    ' Parse the JSON content
    'classJSON = parseJSON(classContent)

    return classContent
end function


        
'------------------------------------------------------------
' Function to fetch server info from conf.txt
'------------------------------------------------------------
function fetch_Server_Info() as Object
    serverInfo = { ip: "127.0.0.1", port: 3000 }
    filePath = "pkg:/source/conf.txt"
    ba = CreateObject("roByteArray")

    if ba.ReadFile(filePath)
        print " Reading file: " + filePath
        fileContent = ba.toAsciiString()
        print " File Content : " + fileContent

        ' Parse the JSON content
        jsonData = parseJSON(fileContent)
        if jsonData <> invalid
            if jsonData.ip <> invalid
                serverInfo.ip = jsonData.ip
            end if
            if jsonData.port <> invalid
                serverInfo.port = jsonData.port
            end if
        else
            print "Failed to parse JSON content."
        end if
    else
        print "Failed to read conf.txt."
    end if

    return serverInfo
end function


' Function to fetch and display content from Puppeteer server
function postScreenInfo(cd as string, content as string, m as Object)

    func = "/postScreenInfo"
    url = m.serverPath + func 

    print "Posting : " + url
    
    request = CreateObject("roUrlTransfer")
    request.SetUrl(url)
    request.PostFromString(content)

end function


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

' Function to check if an input symbol is an operator
function isOperator(input as String, jsKeywordsMatrix as Object) as Boolean
operators = jsKeywordsMatrix["operators"]
return isInList(input,operators)
end function

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


' Function to create a node based on the conversions map and append a rectangle for visibility
function createNode(name as String, info as Object, m as Object) as Object

bounds = info.bounds
colors = info.colors
text = name

conversionsMap = htmlMap()
tagToNode = conversionsMap["tagToNode"]

' Convert units with type information
left_ = getUnits("left", toString(bounds.left_), m)
right_ = getUnits("right", toString(bounds.right_), m)
top = getUnits("top", toString(bounds.top), m)
bottom = getUnits("bottom", toString(bounds.bottom), m)
width = getUnits("width", toString(bounds.width), m)
height = getUnits("height", toString(bounds.height), m)

print "Bounds | Left : " + toString(left_.value) + " Right : " + toString(right_.value) + " Top : " + toString(top.value) + " Bottom : " + toString(bottom.value) + " Width : " + toString(width.value) + " Height : " + toString(height.value)

' Create the main node
mainNode = CreateObject("roSGNode", "Group")

' Create nodes for left, top, right, and bottom
leftNode = CreateObject("roSGNode", "Group")
rightNode = CreateObject("roSGNode", "Group")
topNode = CreateObject("roSGNode", "Group")
bottomNode = CreateObject("roSGNode", "Group")

' Set the translations for the individual nodes
leftNode.translation = [left_.value, 0]
rightNode.translation = [m.bounds.width - right_.value, 0]
topNode.translation = [0, top.value]
bottomNode.translation = [0, m.bounds.height - bottom.value]

' Append the individual nodes to the main node
mainNode.appendChild(leftNode)
mainNode.appendChild(rightNode)
mainNode.appendChild(topNode)
mainNode.appendChild(bottomNode)

' Set dimensions of the main node based on the combined bounds
if left_.unitType <> "unknown" and right_.unitType <> "unknown" then
mainNode.width = m.width - left_.value - right_.value
else
mainNode.width = width.value
end if

if top.unitType <> "unknown" and bottom.unitType <> "unknown" then
mainNode.height = m.height - top.value - bottom.value
else
mainNode.height = height.value
end if

' Retrieve and set colors from the associative array using convertColors function
backgroundColor = "0xFFFFFFFF"
borderColor = "0x00000000"
textColor = "0x000000FF"

if isValid(colors["background-color"]) then
backgroundColor = convertColors(colors["background-color"])
end if
if isValid(colors["border-color"]) then
borderColor = convertColors(colors["border-color"])
end if
if isValid(colors["color"]) then
textColor = convertColors(colors["color"])
end if

' Create and append a rectangle node for the background
backgroundNode = CreateObject("roSGNode", "Rectangle")
backgroundNode.width = mainNode.width
backgroundNode.height = mainNode.height
print "Background Color : " + toString(backgroundColor)
backgroundNode.color = backgroundColor
backgroundNode.visible = true


borderNode = CreateObject("roSGNode", "Rectangle")
borderNode.width = mainNode.width
borderNode.height = mainNode.height
borderNode.color = borderColor
borderNode.visible = true

mainNode.appendChild(borderNode)


' Create and append a label node for the text
labelNode = CreateObject("roSGNode", "Label")
labelNode.width = mainNode.width
labelNode.height = mainNode.height
labelNode.text = text
print "Label Color : " + toString(textColor)
labelNode.color = textColor
labelNode.visible = true

' Append the background and label nodes to the main node
mainNode.appendChild(backgroundNode)
mainNode.appendChild(labelNode)

' Print information about the created node
print "Created new node with width: " + toString(mainNode.width) + " and height: " + toString(mainNode.height) + " for Class : " + name

return mainNode
end function


' Function to append a node to contentContainer
function appendNode(node as Object, m as Object) as Void
' Append the node to contentContainer
m.contentContainer.appendChild(node)

'   print "Appended node to contentContainer."
end function

' Function to create and append a node based on the conversions map
function createAndAppendNode(caller as String, info as Object, m as Object) as Object
' Create the new node
newNode_ = createNode(caller, info, m)

' Append the new node to contentContainer if it was created successfully
if newNode_ <> invalid
appendNode(newNode_, m)
end if

return newNode_
end function

' Function to find all instances of tokens in the matrix
function allInstances(strict as Boolean, tokens as Object, matrix as Object, b as Boolean) as Object
result = CreateObject("roArray", 0, true)  ' Array to store all found instances

if isString(matrix)
print " IS STRING MATRIX : TOKENS : " + toString(tokens) + " | Matrix : " + toString(matrix) 
for each token in tokens
    dIndex = InStr(0, matrix, token)
    print "DTOKEN : " + TOKEN + " D-INDEX: " + toString(dIndex)
    while dIndex > 0
        print "FOUND TOKEN AT INDEX: " + toString(dIndex)
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

print " RESULT : " + toString(result)

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
        print "2str : "; element
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
inputType = type(input)
indentString = ""

if indent <> 0
for i = 0 to indent
    indentString = indentString + " "
end for
end if

' Initialize the indentation string



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
        result = result + toStringIndent(element, indent) + ", "
    end for
 '   print "PRE-RESULT : " + result
    if input.count() > 0
        result = left(result, len(result) - 2) ' Remove trailing comma and space
    end if
    result = result + "]" ' End array representation
  '  print "PRE-RESULT : " + result
else if type(input) = "roAssociativeArray"
    ' print "INDENT : " + Str(indent) 
    result = "{" + chr(10) ' Start associative array representation with a new line
    keys = input.keys()

 '   print "PRE-RESULT : " + result
    if keys.count() > 0

        for each key in keys
            value = input[key]
            result = result + indentString + "  " + key + " : " + toStringIndent(value, indent + 2) + "," + chr(10) ' Indent key-value pairs
        end for

        result = trim(result) ' Remove trailing comma and space
        result = getSubString(result, 1, Len(result), false)
    end if

    result = result + Chr(10) + indentString  + "}" ' End associative array representation
    'print "POST-RESULT : " + result
end if
return result
else
return Type(input)
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
copy = CreateObject("roArray", 0, true)
for each item in original
copy.Push(item)
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
function isInList(item as string, list as Object) as Boolean
for each t in list
if LCase(t) = LCase(item) then
    return true
end if
end for
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
function isNumeric(char as String) as Boolean
if Len(char) = 1 and Asc(char) >= Asc("0") and Asc(char) <= Asc("9")
return true
else
return false
end if
end function

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
        
    print "TOKEN COUNT : " + toString(delimiterInstances.Count())

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
            print "START INDEX : " + toString(startIndex) + " DLI :  " + toString(index) + " Segment : " + toString(segment)
            parsedContent.push(segment)
            ' Check if the delimiter should be kept
            if isInList(dlim, keep_delims)
                parsedContent.push(dlim)
            end if
            startIndex = index + len(dlim)
        
        end if
        print "HTML CLASS TOKEN : INDEX " + toString(index)
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


' Function to create the reversible conversions map for HTML tags to BrightScript nodes
function htmlMap() as Object
conversionsMap = CreateObject("roAssociativeArray")

' Example mappings for HTML tags to SceneGraph nodes
tagToNode = {
"div": "Group",
"span": "Label",
"section": "Group",
"article": "Group",
"header": "Group",
"footer": "Group",
"nav": "Group",
"aside": "Group",
"main": "Group",
"figure": "Group",
"figcaption": "Label",
"address": "Label",
"dialog": "Group",
"fieldset": "Group",
"p": "Label",
"strong": "Label",
"em": "Label",
"b": "Label",
"i": "Label",
"u": "Label",
"mark": "Label",
"small": "Label",
"del": "Label",
"ins": "Label",
"sub": "Label",
"sup": "Label",
"blockquote": "Label",
"code": "Label",
"samp": "Label",
"pre": "Label",
"img": "Poster",  ' Assuming Poster node for images
"picture": "Group",
"video": "Video",
"audio": "Audio",
"canvas": "Canvas",  ' Assuming Canvas node
"iframe": "Group",   ' Custom handling might be required
"embed": "Group",    ' Custom handling might be required
"object": "Group",   ' Custom handling might be required
"a": "Label",
"ul": "Group",
"ol": "Group",
"li": "Label",
"dl": "Group",
"dt": "Label",
"dd": "Label",
"table": "Group",
"thead": "Group",
"tbody": "Group",
"tfoot": "Group",
"tr": "Group",
"th": "Label",
"td": "Label",
"input": "TextField",
"button": "Button",
"select": "List",
"textarea": "TextField",
"form": "Group",
"h1": "Label",
"h2": "Label",
"h3": "Label",
"h4": "Label",
"h5": "Label",
"h6": "Label",
"meta": "Group",  ' Meta tags are usually not rendered visibly
"link": "Group",  ' Link tags are usually not rendered visibly
"script": "Group",  ' Script tags are usually not rendered visibly
"style": "Group",  ' Style tags are usually not rendered visibly
"title": "Group"   ' Title tags are usually not rendered visibly
}

' Create reverse mapping from SceneGraph nodes to HTML tags
nodeToTag = CreateObject("roAssociativeArray")
for each key in tagToNode
nodeType = tagToNode[key]
if not nodeToTag.doesExist(nodeType)
    nodeToTag[nodeType] = []
end if
nodeToTag[nodeType].push(key)
end for

' Combine both mappings into the conversionsMap
conversionsMap["tagToNode"] = tagToNode
conversionsMap["nodeToTag"] = nodeToTag

return conversionsMap
end function



'-------------------------------------------
' Function to retrieve HTML tag categories
'-------------------------------------------
function getTagCategories() as Object
' Define categories of tags
containerTags = ["div", "span", "section", "article", "header", "footer", "nav", "aside", "main", "figure", "figcaption", "address", "dialog", "fieldset"]
textTags = ["p", "strong", "em", "b", "i", "u", "mark", "small", "del", "ins", "sub", "sup", "blockquote", "code", "samp", "pre"]
mediaTags = ["img", "picture", "video", "audio", "canvas", "iframe", "embed", "object"]
linkTags = ["a"]
listTags = ["ul", "ol", "li", "dl", "dt", "dd"]
tableTags = ["table", "thead", "tbody", "tfoot", "tr", "th", "td"]
formTags = ["input", "button", "select", "textarea", "form"]
headingTags = ["h1", "h2", "h3", "h4", "h5", "h6"]
headTags = ["meta", "link", "script", "style", "title"]

tagCategories = {
"containerTags": containerTags,
"textTags": textTags,
"mediaTags": mediaTags,
"linkTags": linkTags,
"listTags": listTags,
"tableTags": tableTags,
"formTags": formTags,
"headingTags": headingTags,
"headTags": headTags
}

return tagCategories
end function
'-------------------------------------------
' Create the attribute tree for handling global and tag-specific attributes
'-------------------------------------------
function createAttributeTree() as Object
globalAttributes = CreateObject("roAssociativeArray")

' Adding global attributes
globalAttributes["name"] = ""
globalAttributes["accesskey"] = ""
globalAttributes["autocapitalize"] = ""
globalAttributes["autofocus"] = ""
globalAttributes["class"] = ""
globalAttributes["contenteditable"] = ""
globalAttributes["data-*"] = ""
globalAttributes["dir"] = ""
globalAttributes["draggable"] = ""
globalAttributes["enterkeyhint"] = ""
globalAttributes["exportparts"] = ""
globalAttributes["hidden"] = ""
globalAttributes["id"] = ""
globalAttributes["inert"] = ""
globalAttributes["inputmode"] = ""
globalAttributes["is"] = ""
globalAttributes["itemid"] = ""
globalAttributes["itemprop"] = ""
globalAttributes["itemref"] = ""
globalAttributes["itemscope"] = ""
globalAttributes["itemtype"] = ""
globalAttributes["lang"] = ""
globalAttributes["nonce"] = ""
globalAttributes["part"] = ""
globalAttributes["popover"] = ""
globalAttributes["role"] = ""
globalAttributes["slot"] = ""
globalAttributes["spellcheck"] = ""
globalAttributes["style"] = ""
globalAttributes["tabindex"] = ""
globalAttributes["title"] = ""
globalAttributes["translate"] = ""
globalAttributes["virtualkeyboardpolicy"] = ""
globalAttributes["writingsuggestions"] = ""
globalAttributes["crossorigin"] = "" ' Added crossorigin for media and script elements
globalAttributes["autocomplete"] = "" ' Added autocomplete for form inputs

' Adding ARIA widget attributes
globalAttributes["aria-autocomplete"] = ""
globalAttributes["aria-checked"] = ""
globalAttributes["aria-disabled"] = ""
globalAttributes["aria-errormessage"] = ""
globalAttributes["aria-expanded"] = ""
globalAttributes["aria-haspopup"] = ""
globalAttributes["aria-hidden"] = ""
globalAttributes["aria-invalid"] = ""
globalAttributes["aria-label"] = ""
globalAttributes["aria-level"] = ""
globalAttributes["aria-modal"] = ""
globalAttributes["aria-multiline"] = ""
globalAttributes["aria-multiselectable"] = ""
globalAttributes["aria-orientation"] = ""
globalAttributes["aria-placeholder"] = ""
globalAttributes["aria-pressed"] = ""
globalAttributes["aria-readonly"] = ""
globalAttributes["aria-required"] = ""
globalAttributes["aria-selected"] = ""
globalAttributes["aria-sort"] = ""
globalAttributes["aria-valuemax"] = ""
globalAttributes["aria-valuemin"] = ""
globalAttributes["aria-valuenow"] = ""
globalAttributes["aria-valuetext"] = ""

' Adding ARIA live region attributes
globalAttributes["aria-busy"] = ""
globalAttributes["aria-live"] = ""
globalAttributes["aria-relevant"] = ""
globalAttributes["aria-atomic"] = ""

' Adding ARIA drag-and-drop attributes
globalAttributes["aria-dropeffect"] = ""
globalAttributes["aria-grabbed"] = ""

' Adding ARIA relationship attributes
globalAttributes["aria-activedescendant"] = ""
globalAttributes["aria-colcount"] = ""
globalAttributes["aria-colindex"] = ""
globalAttributes["aria-colspan"] = ""
globalAttributes["aria-controls"] = ""
globalAttributes["aria-describedby"] = ""
globalAttributes["aria-description"] = ""
globalAttributes["aria-details"] = ""
globalAttributes["aria-errormessage"] = ""
globalAttributes["aria-flowto"] = ""
globalAttributes["aria-labelledby"] = ""
globalAttributes["aria-owns"] = ""
globalAttributes["aria-posinset"] = ""
globalAttributes["aria-rowcount"] = ""
globalAttributes["aria-rowindex"] = ""
globalAttributes["aria-rowspan"] = ""
globalAttributes["aria-setsize"] = ""

' Adding global ARIA attributes
globalAttributes["aria-atomic"] = ""   ' Global attribute
globalAttributes["aria-busy"] = ""     ' Global attribute
globalAttributes["aria-controls"] = "" ' Global attribute
globalAttributes["aria-current"] = ""  ' Global attribute
globalAttributes["aria-describedby"] = "" ' Global attribute
globalAttributes["aria-description"] = "" ' Global attribute
globalAttributes["aria-details"] = ""     ' Global attribute
globalAttributes["aria-disabled"] = ""    ' Global attribute
globalAttributes["aria-dropeffect"] = ""  ' Global attribute
globalAttributes["aria-errormessage"] = "" ' Global attribute
globalAttributes["aria-flowto"] = ""      ' Global attribute
globalAttributes["aria-grabbed"] = ""     ' Global attribute
globalAttributes["aria-haspopup"] = ""    ' Global attribute
globalAttributes["aria-hidden"] = ""      ' Global attribute
globalAttributes["aria-invalid"] = ""     ' Global attribute
globalAttributes["aria-keyshortcuts"] = "" ' Global attribute
globalAttributes["aria-label"] = ""       ' Global attribute
globalAttributes["aria-labelledby"] = ""  ' Global attribute
globalAttributes["aria-live"] = ""        ' Global attribute
globalAttributes["aria-owns"] = ""        ' Global attribute
globalAttributes["aria-relevant"] = ""    ' Global attribute
globalAttributes["aria-role"] = ""        ' Global attribute
globalAttributes["aria-roledescription"] = "" ' Global attribute

' Adding deprecated or obsolete attributes (marked for potential exclusion in HTML5)
globalAttributes["frameborder"] = ""   ' Deprecated for iframe/frame
globalAttributes["marginheight"] = ""  ' Deprecated for iframe/frame
globalAttributes["marginwidth"] = ""   ' Deprecated for iframe/frame
globalAttributes["scrolling"] = ""     ' Deprecated for iframe/frame

' Adding tag-specific attributes
tagAttributes = CreateObject("roAssociativeArray")
tagAttributes["a"] = ["href", "target", "download", "rel", "hreflang", "type"]
tagAttributes["abbr"] = ["title"]
tagAttributes["audio"] = ["src", "controls", "autoplay", "loop", "muted", "preload"]
tagAttributes["iframe"] = ["sandbox", "src", "height", "width", "allow", "frameborder"]
tagAttributes["meta"] = ["name", "charset", "http-equiv"] ' Added http-equiv for <meta> tags
tagAttributes["img"] = ["src", "width", "height", "alt"]
tagAttributes["link"] = ["href", "rel", "type", "crossorigin"] ' Added crossorigin for <link> tags
tagAttributes["input"] = ["type", "value", "placeholder", "name", "required", "autocomplete", "checked"] ' Added autocomplete for <input>
tagAttributes["button"] = ["type", "name", "value", "disabled"]
tagAttributes["script"] = ["type", "src", "async", "defer", "crossorigin"] ' Added crossorigin for <script> tags
tagAttributes["form"] = ["method", "action", "enctype", "target"]
tagAttributes["svg"] = ["viewBox", "xmlns", "x", "y", "d", "fill", "fill-rule", "cursor", "xlink"]
tagAttributes["path"] = ["d"] ' For SVG <path> element
tagAttributes["rect"] = ["x", "y"] ' For SVG <rect> element
tagAttributes["label"] = ["for", "class", "id"] ' You can add any other valid attributes

' Adding additional valid attributes
tagAttributes["*"] = ["height", "width", "allow", "data-load-time", "data-tagging-id", "src"]

' Adding the tagAttributes tree to globalAttributes
globalAttributes["tagAttributes"] = tagAttributes

return globalAttributes
end function
