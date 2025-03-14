function primaryCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
    if verbose
        print "function primaryCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean)"
    end if

    if isString(value)
        if value = "style"
            if verbose
                print "VALUE IS STYLE : " + value
            end if
            context = "style"
            'handleStyleTag(key, value, indent, m, verbose)
        else if value = "script"
            if verbose
                print "VALUE IS SCRIPT : " + value
            end if
            context = "script"
        else if value = "link"
            if verbose
                print "VALUE IS LINK : " + value
            end if
        else
            processPrimaryKey(key, value, indent, m, verbose, context)
        end if
    else
        processPrimaryKey(key, value, indent, m, verbose, context)
    end if
end function

function processPrimaryKey(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
    if key = "type"
        if verbose
            print "TYPE CALLBACK"
        end if
       ' typeCallback(key, value, indent, m, verbose, context)
    else if key = "name"
        if verbose
            print "NAME CALLBACK"
        end if
       ' nameCallback(key, value, indent, m, verbose, context)
    else if key = "attribs"
        if verbose
            print "ATTRIBS CALLBACK"
        end if
        attribsCallback(key, value, indent, m, verbose, context)
    else if key = "children"
        if verbose
            print "CHILDREN CALLBACK"
        end if
        childrenCallback(key, value, indent, m, verbose, context)
    else if key = "content"
        if verbose
            print "CONTENT CALLBACK"
        end if
        contentCallback(key, value, indent, m, verbose, context)
    else if key = "class"
        if verbose
            print "CLASS CALLBACK"
        end if
      '  classCallback(key, value, indent, m, verbose, context)
    else if key = "id"
        if verbose
            print "ID CALLBACK"
        end if
      '  idCallback(key, value, indent, m, verbose, context)
   ' else if isHTML(key, m)
     '   if verbose
      '      print "HTML CALLBACK"
      '  end if
      '  handleHTML(key, value, indent, m, verbose, context)
    else
        customCallback(key, value, indent, m, verbose, context)
    end if
end function

function jsonKeys() as Object
    ' Define Primary Keys
    htmlKeys = [
        "type",
        "name",
        "attribs",
        "children",
        "content",
        "class",
        "id"
    ]

    cssKeys = [       
    "cssRules",        
    "selector",        
    "properties"      
    ]


    ' Define Common Additional Keys
    commonAdditionalKeys = [
        "data",
        "namespace",
        "voidElement",
        "selfClosing",
        "position"
    ]

    ' Define Advanced/Metadata Keys
    advancedMetadataKeys = [
        "parent",
        "index",
        "key",
        "raw",
        "outerHTML",
        "innerHTML",
        "textContent",
        "tail",
        "nodeValue",
        "comments",
        "processingInstructions",
        "directives",
        "events",
        "datasets",
        "aria",
        "styles",
        "classes",
        "scripts",
        "links",
        "media",
        "dimensions",
        "stylesComputed",
        "computedLayout",
        "accessibility",
        "animations",
        "transitions",
        "customData",
        "errors",
        "warnings",
        "metadata"
    ]

    ' Define Specialized Keys (Less Common)
    specializedKeys = [
        "foreignObject",
        "renderingHints",
        "eventHandlers",
        "securityAttributes",
        "linkRelations",
        "mediaQueries",
        "seoAttributes",
        "i18n",
        "templating",
        "validation"
    ]

    ' Create associative array with categorized keys
    keyCategories = {
        "HTML Keys": htmlKeys,
        "CSS Keys": cssKeys,
        "Common Additional Keys": commonAdditionalKeys,
        "Advanced/Metadata Keys": advancedMetadataKeys,
        "Specialized Keys (Less Common)": specializedKeys
    }

    return keyCategories
end function

' Function to check if a key is in any of the lists in jsonKeys
function isInJsonKeys(key as String, json_Keys as Object) as Boolean
    ' Loop through all categories in the jsonKeys associative array
    for each category in json_Keys
        keyList = json_Keys[category]
        if isInList(key, keyList)
            return true
        end if
    end for
    return false
end function

function convertJSON( m as Object, id as String, content as String)
    postJSON(id, content, m)
    return parseJSON(getJSON())
end function

function getJSON() as String
    print "Fetching HTML:JSON:http://192.168.1.150:3000/post-json"
    request = CreateObject("roUrlTransfer")
    request.SetUrl("http://192.168.1.150:3000/convert-json")

    ' Fetch content as a string
    json = request.GetToString()

    if json = invalid or Len(json) = 0 then
        print "Error: Failed to fetch content from Puppeteer server"
        return "invalid"
    else
        print "Content fetched from Puppeteer server."
    end if

    print "HTML content length: "; Len(json)
    return json
end function

' Function to fetch and display content from Puppeteer server
function postJSON(cd as string, content as string, m as Object)
    print "Fetching HTML:JSON:http://192.168.1.150:3000/post-json"
    request = CreateObject("roUrlTransfer")
    request.SetUrl("http://192.168.1.150:3000/post-json")
    post_ = cd + " | " + content 
    request.PostFromString(post_)
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

function routeJSON(caller as string, parent as Object, node as Object, key as Object, level as Integer, m as Object, verbose as Boolean) as Boolean
    value = node[key]
    if caller = "html"

        if verbose
            print "STRING K-V Pair | KEY : " + key + " | VALUE : " + value
        end if

        if value = "script" or value = "style"
            inline = true
            if value = "script"
                print " SEND | handleScriptTag"
                handleScriptData(node, m, verbose, "EXECUTE")
            else if value = "style"
                print " SEND | handleStyleTag"
              styleData =  handleStyleData(node, m, verbose)
              rules = styleData["cssRules"]

              prepCSS(m, rules)

             
              ' renderJSON("css", node, styleData, level, m, verbose)

            else

            end if   
            return true
        else 
            print "ELSE NOT SCRIPT OR STYLE | KEY : " + key + " | VALUE : " + value

'            containerTags = ["div", "span", "section", "article", "header", "footer", "nav", "aside", "main", "figure", "figcaption", "address", "dialog", "fieldset"]
'            textTags = ["p", "strong", "em", "b", "i", "u", "mark", "small", "del", "ins", "sub", "sup", "blockquote", "code", "samp", "pre"]
'            mediaTags = ["img", "picture", "video", "audio", "canvas", "iframe", "embed", "object"]
'            linkTags = ["a"]
'            listTags = ["ul", "ol", "li", "dl", "dt", "dd"]
'            tableTags = ["table", "thead", "tbody", "tfoot", "tr", "th", "td"]
'            formTags = ["input", "button", "select", "textarea", "form"]
'            headingTags = ["h1", "h2", "h3", "h4", "h5", "h6"]
'            headTags = ["meta", "link", "script", "style", "title"]
            
          
            
            if key = "class"
                print "1 : IF CONDITIONAL CLASS IS TRUE "

              



            end if
        

            if isInList(value, m.tagCategories["containerTags"]) 
                print "ROUTE : Container Tags | KEY : " + key + " | Value : " + value 
                containerNode = CreateObject("roSGNode", "Rectangle") ' ONLY CHANGES COLOR FOR RECTANGLES  
                'containerNode.id = key 
                'containerNode.text =  value 
                containerNode.width = 1920
                containerNode.height = 1080
                containerNode.translation="[0, 0]"
               ' containerNode.color = "0xFF0000FF" ' 0xRRGGBBAA
                containerNode.visible = "true"

             '   m.contentContainer.appendChild(containerNode)
                'm.containerNode.appendChild(containerNode)

'                print " NODE | ID : " + containerNode.id + " TEXT :  " + containerNode.text 

            else if isInList(value, m.tagCategories["textTags"])
                print "ROUTE : Container Tags | KEY : " + key + " | Value : " + value 
                if value = "p"
                    containerNode = CreateObject("roSGNode", "Rectangle") ' ONLY CHANGES COLOR FOR RECTANGLES  
                    'containerNode.id = key 
                    'containerNode.text =  value 
                    containerNode.width = 1920
                    containerNode.height = 1080
                    containerNode.translation="[0, 0]"
                   ' containerNode.color = "0xFF0000FF" ' 0xRRGGBBAA
                    containerNode.visible = "true"
    
              '      m.contentContainer.appendChild(containerNode)
                else 
                end if
            
            else if isInList(value, m.tagCategories["mediaTags"])
                print "ROUTE : Container Tags | KEY : " + key + " | Value : " + value 
            
            else if isInList(value, m.tagCategories["linkTags"])
                print "ROUTE : Link Tags | KEY : " + key + " | Value : " + value 
            
            else if isInList(value, m.tagCategories["listTags"])
                print "ROUTE : List Tags | KEY : " + key + " | Value : " + value 
            
            else if isInList(value, m.tagCategories["tableTags"])
                print "ROUTE : Table Tags | KEY : " + key + " | Value : " + value 
            
            else if isInList(value, m.tagCategories["formTags"])
                print "ROUTE : Form Tags | KEY : " + key + " | Value : " + value 
            
            else if isInList(value, m.tagCategories["headingTags"])
                print "ROUTE : Heading Tags | KEY : " + key + " | Value : " + value 
            
            else if isInList(value, m.tagCategories["headTags"])
                print "ROUTE : Head Tags | KEY : " + key + " | Value : " + value 

            else

            end if

        end if 

       else if caller = "css"

            ' Extract the selector
            selector = node["selector"]
            properties = []
            keys = node.Keys()
        
            ' Iterate over the keys and construct the properties array
            for each tag in keys

                print " Route | Tag : "  + tag

                if tag <> "selector"
                 '   property = CreateObject("roAssociativeArray")
                 '   property["property"] = tag
                 '   property["value"] = node[tag]
                 '   properties.push(property)
        '
                 '   print "ROUTE | Selector: " + toString(selector) + " TAG: " + toString(tag) + " VALUE: " + toString(node[tag])
                end if
            end for
        
            ' Construct the final CSS content
         '   cssContent = { "selector": selector, "properties": properties }
        
            ' Render the CSS content
          '  renderCSS(m, cssContent)
        

        
        
        return true

       else if caller = "javascript"

       else 

       end if

end function 


' Main function to map JSON
function renderJSON(caller as string, parent as Object, node as Object, level as Integer, m as Object, verbose as Boolean) as Object
   
    
   
    if isDataStructure(node)
        print "isDataStructure"
        if isAssociativeArray(node)
            print "isAssociativeArray(node)"
            keys = node.keys()
            inline = false

            if verbose
                print "==================LEVEL " + Str(level) + "=================="
            end if


            for each key in keys
                value = node[key]

                if key = "class"
                    print "2 | IF CONDITIONAL CLASS IS TRUE "
    
                    tokens = parse([" "], value, [])

                    if isValid(tokens)
                        
                        for each token in tokens 
    
                            print " TOKEN CHECK : " + token
        
                            print "ROUTEJSON | CLASS |  : " + m.cssStrings
        
                            if not isInList(token, m.cssClasses) and not isInList(token, m.htmlClasses)
                                print " ROUTEJSON NOT IN LIST "
                                'createAndAppendNode("html",token, m) 
                              '  m.htmlClasses.push(tokens)   
                            end if
                            '    print "CSS CLASS FOUND | CLASS : " + token  
                           ' else 
                            '    print "CSS CLASS NOT FOUND | CLASS : " + token + " CSS CLASSES : " + m.cssStrings
                           ' end if
        
        
                            print "ROUTEJSON | CLASS | PARSED TOKENS : " + token 
                        end for
                    
                    else 

                        print "ROUTEJSON | CLASS | TOKENS INVALID " 

                    end if

                end if

                if isString(key) and key <> "children"
                    if isString(value)
 
'============================================================================================================================
m.cssStrings = toString(m.cssClasses)
if routeJSON(caller, parent, node, key, level, m, verbose)    
exit for
end if           

'============================================================================================================================
                        
                    else if isDataStructure(value)
                        if verbose
                            print "STRUCT K-V Pair | KEY : " + key + " | TYPE(VALUE) : " + Type(value)
                        end if
                        ' Continue recursive processing for nested structures
                        renderJSON(caller, node, value, level + 1, m, verbose)
                    else
                        if verbose
                            print "NON-STRING K-V Pair | KEY : " + key + " | TYPE(VALUE) : " + Type(value)
                        end if
                    end if
                end if
            end for

            if isValid(node["children"]) and not inline
                if verbose
                    print "isValid(node[children]) "
                end if
                renderJSON(caller, node, node["children"], level, m , verbose)
            end if

        else 

            if isArray(node) or isList(node)
                print "isArray(node) or isList(node) | Count : " + Str(node.Count())

                for i = 0 to node.Count() - 1
                    print " NODE TYPE : " + Type(node[i])
                    if isDataStructure(node[i])
                        print " IS DATA STRUCTURE "
                        renderJSON(caller, node, node[i], level + 1, m, verbose)
                    end if
                end for

            end if

            if verbose
                print "NOT ASSOCIATIVE : TAG TYPE : " + Type(node)
            end if
        end if
    else 
        if verbose
            print "ELSE : TAG TYPE : " + Type(node)
        end if
    end if

    return node
end function




' Function to check if an associative array only contains primary keys
function isPreamble(data as Object) as Boolean
    keyCategories = jsonKeys()
    primaryKeys = keyCategories["Primary Keys"]

    for each key in data.keys()
        if not isInList(key, primaryKeys)
            return false
        end if
    end for

    return true
end function

function getContent(m as Object, parent as Object, node as Object, forward as String) as String
   ' print "Entering function getContent(parent as Object, node as Object) as String"
    'print "Node Type: " + Type(node)

    result = ""

    if isDataStructure(node)
        if IsAssociativeArray(node)
            if isValid(node["content"]) and Type(node["content"]) = "roString"
                return node["content"]
            else 
                keys = node.keys()
                for each key in keys
                    test = getContent(m, node, node[key], "CONTENT")
                    if test <> ""
                        result = test
                    end if
                end for
            end if
        else if isArray(node) or isList(node)
            for i = 0 to node.Count() - 1
             '   print "Node TYPE: " + Type(node[i])
                test = getContent(m, node, node[i], "CONTENT")
                if test <> ""
                    result = test
                end if
            end for 
        end if
    else if isString(node) and IsAssociativeArray(parent) and parent["content"] = node
        result = node
    end if

    return result
end function


function router( m as Object, code as string) as Boolean
    javaKeys = m.javaKeys ' 1-D List of all JavaScript keys 
    html_Keys = m.htmlKeys ' 1-D List of all HTML keys 
    cssKeys = m.cssKeys   ' 1-D List of all CSS keys 

    ' Convert the code to lowercase to make the search case-insensitive
    lowerCaseCode = LCase(code)
    
    ' Check for CSS properties
    for each cssKey in cssKeys
        if InStr(1, lowerCaseCode, LCase(cssKey)) > 0
            print "Detected CSS code"
            return true
        end if
    end for

    ' Check for JavaScript keywords and operators
    for each javaKey in javaKeys
        if InStr(1, lowerCaseCode, LCase(javaKey)) > 0
            print "Detected JavaScript code"
            return true
        end if
    end for

    ' Check for HTML tags and attributes
    for each htmlKey in html_Keys
        if InStr(1, lowerCaseCode, LCase(htmlKey)) > 0
            print "Detected HTML code"
            return true
        end if
    end for

    print "Unknown code type"
    return false
end function

function jsonCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
    ' Check which category the key belongs to
    json_keys = m.jsonKeys

    if isString(key)
        if isString(value)
            if verbose
                print "JSON CALLBACK | key : " + key + " | value : " + value
            end if
        else
            if verbose
                print "JSON CALLBACK | key : " + key
            end if
        end if
    end if 

    if isInList(key, json_keys["Primary Keys"])
        primaryCallback(key, value, indent, m, verbose, context)
    else if isInList(key, json_keys["CSS Keys"])
        'cssCallback(key, value, indent, m, verbose, context)
    else if isInList(key, json_keys["Common Additional Keys"])
        commonCallback(key, value, indent, m, verbose, context)
    else if isInList(key, json_keys["Advanced/Metadata Keys"])
        advancedCallback(key, value, indent, m, verbose, context)
    else if isInList(key, json_keys["Specialized Keys (Less Common)"])
        specializedCallback(key, value, indent, m, verbose, context)
    else
        if verbose
            print "Unknown key"
        end if
    end if
end function

' General recursive handler to process any object (associative array, array, list, or primitive)
function recursiveHandler(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
    if verbose
        print "RECURSIVE HANDLER : function recursiveHandler(key as String, value as Object, indent as String, m as Object, verbose as Boolean)"
    end if

    if IsAssociativeArray(value)
        if verbose
            print indent + "Key: " + key + " contains an Associative Array"
        end if
        for each subKey in value
            subValue = value[subKey]
            if verbose
                print indent + "  Sub Key: " + subKey + " Value: " + elementToStr(subValue)
            end if
            recursiveHandler(subKey, subValue, indent + "  ", m, verbose, context) ' Recurse into nested associative array
        end for
    else if Type(value) = "roArray" or Type(value) = "roList"
        if verbose
            print indent + "Key: " + key + " contains array/list with " + Str(value.Count()) + " elements"
        end if
        for i = 0 to value.Count() - 1
            element = value[i]
            if verbose
                print indent + "  Element " + Str(i) + ": " + elementToStr(element)
            end if
            recursiveHandler("ArrayItem " + Str(i), element, indent + "  ", m, verbose, context) ' Recurse into nested arrays/lists
        end for
    else
        if verbose 
            if Type(value) = "roInvalid"
                print indent + "Key: " + key + " Value: Invalid"
            else if Type(value) = "roString"
                print indent + "Key: " + key + " Value: " + value
            else if Type(value) = "roBoolean"
                if value = true
                    print indent + "Key: " + key + " Value: true"
                else
                    print indent + "Key: " + key + " Value: false"
                end if
            else
                print indent + "Key: " + key + " Value: " + Str(value)
            end if
        end if
        primaryCallback(key, value, indent, m, verbose, context)
    end if
end function





function attribsCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
    if verbose
        print "Attribs Callback"
    end if

    ' Recursively handle associative array or list
    'recursiveHandler(key, value, indent, m, verbose)

    ' Check if key or value is an HTML tag and send to handleHTML
    'if isHTML(key, m) or (Type(value) = "roString" and isHTML(value, m))
     '   handleHTML(key, value, indent, m, verbose)
    'end if
end function

function childrenCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
    if verbose
        print "Children Callback"
    end if

    ' Recursively handle associative array or list
    'recursiveHandler(key, value, indent, m, verbose)

    ' Check if key or value is an HTML tag and send to handleHTML
    'if isHTML(key, m) or (Type(value) = "roString" and isHTML(value, m))
     '   handleHTML(key, value, indent, m, verbose)
    'end if
end function

function contentCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as object)
   
    'if verbose
      '  print "Content Callback"
        if Type(value) <> "roInvalid" and Type(value) <> "roString"
        '    print " Key : " + key + " Value : " + Str(value) 
        else if Type(value) = "roString"
        '    print " Key : " + key + " Value : " + value
        else if Type(value) = "roInvalid"
        '    print " Key : " + key + " Value : Invalid "
        end if
    'end if

    if isJS(value,m)
        print "Handling JavaScript content"
    end if

    ' Check if the content belongs to a script tag
    if m.previousTag = "script"
        print "Rerouting : "
      '  handleScriptDATA(m.previousTag, value, indent)
    end if

    ' Check for nested content
    if IsAssociativeArray(value)
        for each subKey in value
            subValue = value[subKey]
            print "Rerouting subKey: " + subKey
           ' jsonCallback(subKey, subValue, indent + "  ", m, verbose)
        end for
    else if Type(value) = "roArray" or Type(value) = "roList"
        for i = 0 to value.Count() - 1
            element = value[i]
            print "Rerouting ArrayItem " + Str(i)
           ' jsonCallback("ArrayItem " + Str(i), element, indent + "  ", m, verbose)
        end for
    end if
end function




function customCallback(key as String, value as Object, indent as String, m as Object, verbose as boolean, context as Object)
    if verbose 
        print "Custom Callback"
        if Type(value) <> "roInvalid" and Type(value) <> "roString"
            print " Key : " + key + " Value : " + Str(value) 
        else if Type(value) = "roString"
            print " Key : " + key + " Value : " + value
        else if Type(value) = "roInvalid"
            print " Key : " + key + " Value : Invalid "
        end if
    end if
end function


function commonCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
     if verbose 
        print "Common Callback"
        if Type(value) <> "roInvalid" and Type(value) <> "roString"
            print " Key : " + key + " Value : " + Str(value) 
        else if Type(value) = "roString"
            print " Key : " + key + " Value : " + value
        else if Type(value) = "roInvalid"
            print " Key : " + key + " Value : Invalid "
        end if
    end if
end function

function advancedCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as Object)
    print "ADVANCED CALLBACK | key: " + key + " value: " + value
end function

function specializedCallback(key as String, value as Object, indent as String, m as Object, verbose as Boolean, context as object)
    print "SPECIALIZED CALLBACK"
end function

