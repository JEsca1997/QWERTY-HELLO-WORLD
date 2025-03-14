
function updateNode(nodeObj as Object, prop as String, newValue as Object) as Void
    ' Check that the node object is valid.
    if not isValid(nodeObj) then
     'print "updateNode: nodeObj is invalid."
        return
    end if

    ' Check that nodeObj.params exists.
    if not IsAssociativeArray(nodeObj.params) then
     'print "updateNode: nodeObj.params is not valid."
        return
    end if

    ' Check that the actual node is valid.
    if not isValid(nodeObj.node) then
     'print "updateNode: nodeObj.node is invalid."
        return
    end if

    ' Check if the property exists in the parameters.
    if nodeObj.params.DoesExist(prop) then
        nodeObj.params[prop] = newValue
        ' Check if the underlying node has this field.
        ' roSGNodes typically allow you to use getFieldNames() or hasField.
        if nodeObj.node.hasField(prop) then
            nodeObj.node[prop] = newValue
        else
         'print "updateNode: The underlying node does not have the field '" + prop + "'. Only updating params."
        end if
    else
     'print "updateNode: property '" + prop + "' does not exist in nodeObj.params; not updating."
    end if
end function


function calculateFontSize(screenInfo as Object) as Integer
    if not IsValid(screenInfo) or not (screenInfo.h <> invalid) then
        'print "Error: Invalid screenInfo object"
        return 24  ' default font size if screenInfo is invalid
    end if

    ' Calculate font size as 3% of screenm.height.
    fontSize = Int(screenInfo.h * 0.03)
    return fontSize
end function

'------------------------------------------------------------
' Helper function to create a Rectangle node
'------------------------------------------------------------
function createRectangleNode(x as Integer, y as Integer, width as Integer, height as Integer, color as String) as Object 
    ' Validate color parameter; if not provided, default to opaque black.
    if not isValid(color) or color = ""
        color = "0x000000FF"
    end if

    ' Create a Rectangle node
    rectangleNode = CreateObject("roSGNode", "Rectangle")
    
    ' Set the translation using a string format "[x,y]"
    rectangleNode.translation = "[" + Str(x) + "," + Str(y) + "]"
    
    ' Set dimensions and color
    rectangleNode.width = width
    rectangleNode.height = height
    rectangleNode.color = color

    return rectangleNode
end function

'------------------------------------------------------------
' Helper function to create a Poster node
'------------------------------------------------------------
function createPosterNode(uri as String, x as Integer, y as Integer, width as Integer, height as Integer) as Object 
    ' Validate the URI; if not valid, default to an empty string.
    if not isValid(uri)
        uri = ""
    end if

    ' Create a Poster node
    posterNode = CreateObject("roSGNode", "Poster")
    
    ' Set the image URI
    posterNode.uri = uri
    
    ' Set the translation using a string format "[x,y]"
    posterNode.translation = "[" + Str(x) + "," + Str(y) + "]"
    
    ' Set dimensions
    posterNode.width = width
    posterNode.height = height

    return posterNode
end function

'------------------------------------------------------------
' Helper function to create and append a Label node
'------------------------------------------------------------
function createLabelNode(text as String, x as Integer, y as Integer, width as Integer, height as Integer) as Object 
        if NOT isValid(text)
            text = ""
        end if

        'print "CREATE LABEL : "; x;y;width;height

      ' Create a Label node
        labelNode = CreateObject("roSGNode", "Label")
        
        ' Set the text field
        
        labelNode.text = text
        
        ' Set the translation using a string format "[x,y]"
        labelNode.translation = "[" + Str(x) + "," + Str(y) + "]"

        'print "CREATE LABEL : "; labelNode.translation
        
        ' Set width and height
        labelNode.width = width
        labelNode.height = height

        labelNode.color = "0x000000FF"
        
        return labelNode
end function

function createNode(nodeType as String, params as Object) as Object
    translation = ""

    if isValid(params.translation)
        if isString(params.translation)
            translation = parse(["[",",","]"], params.translation, [])
            translation[0] = val(translation[0])
            translation[1] = val(translation[1])
        else 
            translation = params.translation 
        end if 
    end if

    if nodeType = "Rectangle" then
        if isValid(params.translation)
            node = createRectangleNode(translation[0], translation[1], params.width, params.height, params.color)
        else 
            node = createRectangleNode(params.x, params.y, params.width, params.height, params.color)
        end if
    else if nodeType = "Poster" then
        if isValid(params.translation)
            node = createPosterNode(params.uri, translation[0], translation[1], params.width, params.height)
        else 
            node = createPosterNode(params.uri, params.x, params.y, params.width, params.height)
        end if
    else if nodeType = "Label" then
        if isValid(params.translation)
          '  print " Label Text : "; params.text
            node = createLabelNode(params.text, translation[0], translation[1], params.width, params.height)
        else 
            node = createLabelNode(params.text, params.x, params.y, params.width, params.height)
        end if
    else if nodeType = "Group" then
        node = createObject("roSGNode", "Group")
    else 
        'print "Unsupported node type: " + nodeType
        return invalid
    end if

    ' Fallback ID mechanism: generate a unique ID if none provided.
    if not isValid(params.id) or params.id = "" then
        if not isValid(m.nodeCounters) then m.nodeCounters = {}
        if not m.nodeCounters.DoesExist(nodeType) then
            m.nodeCounters[nodeType] = 0
        end if
        m.nodeCounters[nodeType] = m.nodeCounters[nodeType] + 1
        node.id = nodeType + "_" + Str(m.nodeCounters[nodeType])
    else
        node.id = params.id
    end if

    return node
end function

function isRenderNode(node as Object)
    return type(node) = "roSGNode"
end function

function isRenderType(typeStr as String) as Boolean
    typeStr = LCase(typeStr)
    if typeStr = "rectangle" or typeStr = "poster" or typeStr = "label" then
        return true
    else
        return false
    end if
end function

function isRenderable(item as Object) as Boolean
    if isString(item) then
        return isRenderType(item)
    else if IsAssociativeArray(item) then
        return isRenderNode(item)
    end if
end function

function makeNode(key as String, values as Object, nodeType as String, node as Object) as Object
    ' Get the HTML conversion maps directly within makeNode
    conversionMaps = htmlMap()
    tagToNode = conversionMaps.tagToNode
    
    ' Convert HTML tag to Roku node type if needed
    originalTag = ""
    actualNodeType = nodeType
    
    ' Check if nodeType is an HTML tag that needs conversion
    if tagToNode.doesExist(LCase(nodeType))
        originalTag = nodeType
        actualNodeType = tagToNode[LCase(nodeType)]
        'print "Converting HTML tag '" + originalTag + "' to node type '" + actualNodeType + "'"
    end if
    
    ' Check that m.default exists and has an entry for the given node type
    if not IsAssociativeArray(m.default) then
        'print "m.default is not defined or not an associative array."
        return {}
    end if

    if not m.default.DoesExist(actualNodeType) then
        'print "m.default does not contain node type: " + actualNodeType
        return {}
    end if

    ' Merge default parameters
    paramsJSON = formatJSON(m.default[actualNodeType])
    defaultParams = parseJSON(paramsJSON)
    mergedParams = {}

    ' Copy default parameters, skipping any "group" key
    for each dKey in defaultParams.Keys()
        if dKey <> "group" then
            mergedParams[dKey] = defaultParams[dKey]
        end if
    end for

    ' Merge provided values, skipping the "group" key
    for each vKey in values.Keys()
        if vKey <> "group" then
            mergedParams[vKey] = values[vKey]
        end if
    end for
    
    ' Apply HTML-specific styling if this was converted from an HTML tag
    if originalTag <> ""
        ' Store the original tag for reference
       ' mergedParams.htmlTag = originalTag
        
        ' Apply default tag styles if available
        tagStyles = conversionMaps.tagStyles
        if tagStyles.doesExist(LCase(originalTag))
            defaultTagStyle = tagStyles[LCase(originalTag)]
            for each styleKey in defaultTagStyle
                ' Only apply if not already set by user
                if not mergedParams.doesExist(styleKey)
                    mergedParams[styleKey] = defaultTagStyle[styleKey]
                end if
            end for
        end if
    end if

    ' Check if this node type is renderable
    if isRenderType(actualNodeType) then
        if isValid(mergedParams.x) and isValid(mergedParams.y) then
            ' If translation is not valid, create one
            if (not isValid(mergedParams.translation)) or (not isString(mergedParams.translation)) then
                mergedParams.translation = "[" + Str(mergedParams.x) + "," + Str(mergedParams.y) + "]"
            else
                ' Translation exists; parse it
                parsedTranslation = parse(["[",",","]"], mergedParams.translation, [])
                if parsedTranslation.count() = 2 then
                    tx = val(parsedTranslation[0])
                    ty = val(parsedTranslation[1])
                    if tx <> mergedParams.x or ty <> mergedParams.y then
                        mergedParams.translation = "[" + Str(mergedParams.x) + "," + Str(mergedParams.y) + "]"
                    end if
                else
                    ' If parsing did not return two values, rebuild the translation
                    mergedParams.translation = "[" + Str(mergedParams.x) + "," + Str(mergedParams.y) + "]"
                end if
            end if
        end if
    end if

    ' Create the roSGNode if not provided
    actualNode = invalid 
    if isValid(node) then
        actualNode = node
    else 
        actualNode = createNode(actualNodeType, mergedParams)
    end if

    ' Fallback ID mechanism: generate a unique ID if none is provided
    if (not isValid(mergedParams.id)) or (mergedParams.id = "") then
        if not isValid(m.nodeCounters) then m.nodeCounters = {}
        if not m.nodeCounters.DoesExist(actualNodeType) then m.nodeCounters[actualNodeType] = 0
        m.nodeCounters[actualNodeType] = m.nodeCounters[actualNodeType] + 1
        
        ' Include HTML tag in ID if available
        if originalTag <> ""
            actualNode.id = LCase(originalTag) + "_" + Str(m.nodeCounters[actualNodeType])
        else
            actualNode.id = actualNodeType + "_" + Str(m.nodeCounters[actualNodeType])
        end if
    else
        actualNode.id = mergedParams.id
    end if

    if key = invalid 
        key = "null"
    end if

    ' Assemble the return object
    if actualNodeType = "Group" then
        if IsAssociativeArray(values) and values.DoesExist("group") then
            groupContent = values.group
        else
            groupContent = {}  ' Default to empty associative array
        end if

        temp = {
            nodeType: actualNodeType,
            params: mergedParams,
            node: actualNode,
            group: groupContent,
            key : key
           ' htmlTag: originalTag ' Store original HTML tag
        }
    else 
        temp = {
            nodeType: actualNodeType,
            params: mergedParams,
            node: actualNode,
            key : key
           ' htmlTag: originalTag ' Store original HTML tag
        }
    end if

    result = {}
    result[key] = temp
    return result
end function

function createBox(params as Object) as Object
    '-----------------------------
    ' Overall box defaults.
    '-----------------------------
    x = 0
    y = 0 
    width = 200
    height = 200
    translation = [0, 0]
    
    ' Store the content color if provided
    contentColor = invalid
    if isValid(params.color)
        contentColor = params.color
    end if 
    
    if isValid(params.translation) then
        translation = params.translation
    else if isValid(params.x) and isValid(params.y) then
        x = params.x 
        y = params.y
        translation = [x, y]
    end if 

    if isValid(params.width) then width = params.width
    if isValid(params.height) then height = params.height

    ' Fallback unique ID for the box.
    if not isValid(params.id) or params.id = "" then
        if not isValid(m.nodeCounters) then m.nodeCounters = {}
        if not m.nodeCounters.DoesExist("box") then m.nodeCounters["box"] = 0
        m.nodeCounters["box"] = m.nodeCounters["box"] + 1
        params.id = "box_" + Str(m.nodeCounters["box"])
    end if
    boxUID = params.id

    ' Create the outer box group.
    boxGroup = makeNode(boxUID, { id: boxUID, translation: translation, width: width, height: height }, "Group", invalid)

    ' Add family tracking
    boxGroup[boxUID].family = {
        parent: invalid,  ' Reference to parent box
        children: [],     ' List of child boxes
        siblings: []      ' List of sibling boxes
    }

    ' Optional: Allow setting parent and children during box creation
    if isValid(params.parent)
        boxGroup[boxUID].family.parent = params.parent
        ' Add this box to parent's children
        if isValid(params.parent.family)
            params.parent.family.children.push(boxGroup[boxUID])
        end if
    end if

    ' Optional: Allow pre-adding children during box creation
    if isValid(params.children)
        for each child in params.children
            boxGroup[boxUID].family.children.push(child)
            ' Set parent for each child
            if isValid(child.family)
                child.family.parent = boxGroup[boxUID]
            end if
        end for
    end if

    '-----------------------------
    ' Frame sizes (thickness) for each layer.
    '-----------------------------
    marginFrame = 0
    borderFrame = 5
    paddingFrame = 5
    if isValid(params.marginFrame) then marginFrame = params.marginFrame
    if isValid(params.borderFrame) then borderFrame = params.borderFrame
    if isValid(params.paddingFrame) then paddingFrame = params.paddingFrame

    '-----------------------------
    ' Margin layer: occupies the entire box.
    '-----------------------------
    marginTranslation = translation
    marginWidth = width
    marginHeight = height
    marginUID = boxUID + "_margin"
    marginRect = makeNode(marginUID, { id: marginUID, translation: marginTranslation, width: marginWidth, height: marginHeight, color: "0xFF0000FF" }, "Rectangle", invalid)

    '-----------------------------
    ' Inner area after margin.
    '-----------------------------
    innerX = translation[0] + marginFrame
    innerY = translation[1] + marginFrame
    innerWidth = width - (marginFrame * 2)
    innerHeight = height - (marginFrame * 2)

    '-----------------------------
    ' Border layer: drawn on the inner area.
    '-----------------------------
    borderTranslation = [ innerX, innerY ]
    borderWidth = innerWidth
    borderHeight = innerHeight
    borderUID = boxUID + "_border"
    borderRect = makeNode(borderUID, { id: borderUID, translation: borderTranslation, width: borderWidth, height: borderHeight, color: "0x00FF00FF" }, "Rectangle", invalid)

    '-----------------------------
    ' Inner area after border.
    '-----------------------------
    innerBorderX = innerX + borderFrame
    innerBorderY = innerY + borderFrame
    innerBorderWidth = innerWidth - (borderFrame * 2)
    innerBorderHeight = innerHeight - (borderFrame * 2)

    '-----------------------------
    ' Padding layer: drawn on the inner border area.
    '-----------------------------
    paddingTranslation = [ innerBorderX, innerBorderY ]
    paddingWidth = innerBorderWidth
    paddingHeight = innerBorderHeight
    paddingUID = boxUID + "_padding"
    paddingRect = makeNode(paddingUID, { id: paddingUID, translation: paddingTranslation, width: paddingWidth, height: paddingHeight, color: "0x0000FFFF" }, "Rectangle", invalid)

    '-----------------------------
    ' Inner content area after padding.
    '-----------------------------
    contentX = innerBorderX + paddingFrame
    contentY = innerBorderY + paddingFrame
    contentWidth = innerBorderWidth - (paddingFrame * 2)
    contentHeight = innerBorderHeight - (paddingFrame * 2)
    contentUID = boxUID + "_content"
    contentParams = {
        id: contentUID,
        translation: [ contentX, contentY ],
        width: contentWidth,
        height: contentHeight
    }

    ' If a text parameter is provided, pass it along.
    if isValid(params.text) then contentParams.text = params.text
    
    ' Pass the content color to createContent if provided
    if isValid(contentColor) then contentParams.color = contentColor
    
    content = createContent(contentUID, contentParams)

    '-----------------------------
    ' Assemble children.
    '-----------------------------
    addNodesWithCaller("BOX", boxGroup, marginRect)
    addNodesWithCaller("BOX", boxGroup, borderRect)
    addNodesWithCaller("BOX", boxGroup, paddingRect)
    addNodesWithCaller("BOX", boxGroup, content)
    
    return boxGroup
end function

' Helper function to add a child to a box
function addChildToBox(parentBox as Object, childBox as Object) as Void
    if not isValid(parentBox) or not isValid(childBox)
        return
    end if

    ' Get the parent box's family object
    parentKey = parentBox.keys()[0]
    
    ' Add child to parent's children
    if isValid(parentBox[parentKey].family)
        parentBox[parentKey].family.children.push(childBox[childBox.keys()[0]])
        
        ' Set parent for child
        childKey = childBox.keys()[0]
        if isValid(childBox[childKey].family)
            childBox[childKey].family.parent = parentBox[parentKey]
        end if
    end if
end function

' Helper function to get a box's family information
function getBoxFamily(box_ as Object) as Object
    if not isValid(box_) 
        return invalid
    end if

    boxKey = box_.keys()[0]
    return box_[boxKey].family
end function

'------------------------------------------------------------
' Function: createContent
'
' Description:
'   Creates a content group containing a background, a poster, and a label.
'   The UID used for the group is passed in as a separate parameter.
'
' Parameters:
'   uid    - String: a unique identifier for the content group.
'   bounds - Object: an associative array with keys:
'            translation (array), width (integer), height (integer),
'            and optionally text and color.
'
' Returns:
'   An associative array where the key is the uid of the content group.
'------------------------------------------------------------
function createContent(uid as String, bounds as Object) as Object
    ' If uid is not provided, generate a unique one.
    if not isValid(uid) or uid = "" then
        if not isValid(m.nodeCounters) then m.nodeCounters = {}
        if not m.nodeCounters.DoesExist("content") then m.nodeCounters["content"] = 0
        m.nodeCounters["content"] = m.nodeCounters["content"] + 1
        uid = "content_" + Str(m.nodeCounters["content"])
    end if

    ' Create a group node with the provided UID.
    contentGroupObj = makeNode(uid, { }, "Group", invalid)
    
    ' (Optional) Set a clippingRect on the group's node.
    contentGroupObj[uid].node.clippingRect.x = {
        x: bounds.translation[0],
        y: bounds.translation[1],
        width: bounds.width,
        height: bounds.height
    }
    
    ' Create a background rectangle sized to the content area.
    backgroundParams = copy(bounds)
    
    ' Use the provided color for background if available, otherwise use white
    if isValid(bounds.color)
        backgroundParams.color = bounds.color
    else
        backgroundParams.color = "0xFFFFFFFF"  ' Default white background
    end if
    
    backgroundObj = makeNode("background", backgroundParams, "Rectangle", invalid)
    
    ' Create a poster node.
    posterParams = copy(bounds)
    posterParams.uri = "pkg:/images/example.png"
    posterObj = makeNode("poster", posterParams, "Poster", invalid)
    
    ' Create a label node.
    labelParams = copy(bounds)
    if isValid(bounds.text) and bounds.text <> "" then
        labelParams.text = bounds.text
    else
        labelParams.text = ""
    end if
    labelObj = makeNode("label", labelParams, "Label", invalid)
    
    ' Assemble children: add background, poster, and label.
    addNodesWithCaller("Content", contentGroupObj, backgroundObj)
    addNodesWithCaller("Content", contentGroupObj, posterObj)
    addNodesWithCaller("Content", contentGroupObj, labelObj)
    
    return contentGroupObj
end function

function addNodesWithCaller(caller as String, parent as Object, nodes as Object) as Void
    ' Ensure the parent has a children associative array in its params.
    print "addNodes | Caller : "; caller; " Parent : "; parent.keys()[0]; " Node : "; nodes.keys()[0]

    if parent.keys()[0] = "app_1"
     '   print "APP_1 CHILDREN => "; toStringIndent(parent[parent.keys()[0]],0)
    end if
    
    pKeys = parent.keys()
    pkey = pKeys[0]

    pvalues = parent[pkey]
    pvkeys = pvalues.keys() 

    nkeys = nodes.Keys()
    nkey = nkeys[0]

    nvalues = nodes[nkey]
    nvKeys = nvalues.keys()

    if not IsAssociativeArray(pvalues.group) then
       ' print "if not IsAssociativeArray(parent.group) "
        pvalues.group = {} 'MIGHT BE THIS CALL
    end if

        ' Create a group node to hold our content.
    if not isValid(m.contentCounter) then m.contentCounter = 0
   
    if pvalues.group.DoesExist(nkey) 
       ' print "ADD NODE | NODE ALREADY EXISTS : "; nkey
        m.contentCounter = m.contentCounter + 1
        nkey = nkey + "_" + Str(m.contentCounter)    
    end if

    ' Iterate over each key in the nodes associative array.
    pvalues.group[nkey] = {} 

    for each vKey in nvKeys

        _value = nvalues[vKey] 
        if isRenderNode(_value)
            if isValid(parent.node)
              'print "APPENDED TO PARENT NODE"
                parent.node.appendChild(_value)        
            else if isValid(pvalues.node)
              'print "APPENDED TO PVALUES NODE"
                pvalues.node.appendChild(_value)        
            end if
        end if    
        pvalues.group[nkey][vkey] = _value

    end for

  'print " Final Parent : "; toStringIndent(parent,0)

end function


function applyDefaultLayout() as Void
    ' Get screen information (sets m.width, m.height, m.fontSize, etc.)
    getInfo()
    font_size = m.fontSize

    ' Calculate dimensions.
    headerHeight = font_size * 3        ' Example header height.
    bodyHeight = m.height - headerHeight  ' Remaining screen height for the body.

    default = {
        Rectangle: {
            width: m.width,             ' full screen width by default
            height: font_size,        ' one line of text
            translation: "[0,0]",
            color: "0xFFFFFFFF",      ' Black with full opacity
            opacity: 1.0,
            rotation: 0,
           ' clippingRect: "[0,0,0,0]",
            visible: true
        },
        Poster: {
            width: font_size * font_size,     ' Example: square poster, twice the line height
            height: font_size * font_size,
            translation: "[0,0]",
            uri: "",
            scale: 1,
            visible: true
        },
        Label: {
            width: m.width,             ' Could be full screen width
            height: font_size,        ' One line of text height
            translation: "[0,0]",
            text: "",
            font: { size: font_size, family: "Medium" },  ' Use the computed font size
            color: "0x000000FF",      ' Black with full opacity
            visible: true,
            opacity: 1.0
        },
        Group: {
            translation: "[0,0]",
            visible: true,
            group : {}
        }
    }

    m.default = default

    ' Retrieve the main container defined in XML (Bright_Browser)
    mainContainer = m.top.findNode("Bright_Browser")
    if mainContainer = invalid then
        return
    end if

    m.Bright_Browser = {
        screen: {
            x: 0,
            y: 0,
            width: m.width,
            height: m.height,
            default: { font: { size: m.fontSize, family: "" }, nodes: m.default },
            renderer: mainContainer
        },
        header: {},
        body: {}
    }


    ' -----------------------------------------------
    ' Create Header using createBox.
    ' -----------------------------------------------
    headerBox = createBox({ 
        id : "header_box", 
        x: 0, 
        y: 0, 
        width: m.width, 
        height: headerHeight,
        marginFrame : 5,
        borderFrame : 5,
        paddingFrame : 5, 
        text:"https://soundcloud.com"
    })

    m.Bright_Browser.header = headerBox
    m.Bright_Browser.screen.renderer.appendChild(headerBox["header_box"].node)

    ' -----------------------------------------------
    ' Create Body using createBox.
    ' -----------------------------------------------
    bodyBox = createBox({ 
        id : "body_box", 
        x: 0, 
        y: headerHeight, 
        width: m.width, 
        height: bodyHeight,
        marginFrame : 5,
        borderFrame : 5,
        paddingFrame : 5, 
    })

    m.Bright_Browser.body = bodyBox
 'print "BODY_BOX : "; toStringIndent(bodyBox,0)
   ' m.Bright_Browser.body.clippingRect(bodyBox.)
    m.Bright_Browser.body.body_box.params.group = makeNode("body_params_group", {}, "Group", bodyBox["body_box"].node)
    m.Bright_Browser.body.body_box.params.group.body_params_group.node.clippingRect = { x: 0, y: headerHeight, width: m.width, height: bodyHeight }

 'print "Bright_Browser : "; toStringIndent(m.Bright_Browser.body,0)

    m.Bright_Browser.screen.renderer.appendChild(bodyBox["body_box"].node)

    m.top.setFocus(true)
  'print "Layout Initialized Successfully."
end function


function getInfo()
    di = CreateObject("roDeviceInfo")
    screenSize = di.getDisplaySize()
    m.width = screenSize.w
    m.height = screenSize.h

    font_size = calculateFontSize(screenSize)
    m.fontSize = font_size
    m.screenSize = screenSize
end function

function copy(struct as Object)
    'params_string = toStringIndent(m.default[nodeType],0)
    str_uct = formatJSON(struct)
    ret_str = parseJSON(str_uct)
    return ret_str

end function 

function addNodes(parent as Object, nodes as Object) as Void
    ' Ensure the parent has a children associative array in its params.

    pKeys = parent.keys()
    pkey = pKeys[0]

    pvalues = parent[pkey]
    pvkeys = pvalues.keys() 

    nkeys = nodes.Keys()
    nkey = nkeys[0]

    nvalues = nodes[nkey]
    nvKeys = nvalues.keys()

    'print " nvKeys : "; toStringIndent(nvKeys,0)

    if not IsAssociativeArray(pvalues.group) then
       ' print "if not IsAssociativeArray(parent.group) "
        pvalues.group = {} 'MIGHT BE THIS CALL
    end if

        ' Create a group node to hold our content.
    if not isValid(m.contentCounter) then m.contentCounter = 0
   
    if pvalues.group.DoesExist(nkey) 
       ' print "ADD NODE | NODE ALREADY EXISTS : "; nkey
        m.contentCounter = m.contentCounter + 1
        nkey = nkey + "_" + Str(m.contentCounter)    
    end if

    ' Iterate over each key in the nodes associative array.
    pvalues.group[nkey] = {} 

    for each vKey in nvKeys

        _value = nvalues[vKey] 
        if isRenderNode(_value)
            if isValid(parent.node)
                parent.node.appendChild(_value)        
            
            else if isValid(pvalues.node)
                pvalues.node.appendChild(_value)        
            
            end if

        end if    
        pvalues.group[nkey][vkey] = _value

    end for

end function

'------------------------------------------------------------
' Function: calculateBoxSize
'
' Description:
'   Given a font size, this function calculates default frame sizes
'   (margin, border, and padding) as a fraction of the font size.
'   It then computes the overall box height based on these frame sizes
'   and the content height (equal to the font size).
'
' Parameters:
'   fontSize - Integer: the base font size (also the content height)
'
' Returns:
'   An associative array with the following keys:
'     overallHeight - Total height of the box.
'     contentHeight - Height of the content (equal to fontSize).
'     marginFrame   - Calculated margin frame thickness.
'     borderFrame   - Calculated border frame thickness.
'     paddingFrame  - Calculated padding frame thickness.
'------------------------------------------------------------
function calculateBoxSize(fontSize as Integer) as Object
    ' Calculate frame sizes as 20% of the fontSize (minimum 1 pixel)
    marginFrame = Max(1, Int(fontSize * 0.2))
    borderFrame = Max(1, Int(fontSize * 0.2))
    paddingFrame = Max(1, Int(fontSize * 0.2))
    
    contentHeight = fontSize
    overallHeight = contentHeight + 2 * (marginFrame + borderFrame + paddingFrame)
    
    return {
        overallHeight: overallHeight,
        contentHeight: contentHeight,
        marginFrame: marginFrame,
        borderFrame: borderFrame,
        paddingFrame: paddingFrame
    }
end function


function updateContent(contentObj as Object, newWidth as Integer, newHeight as Integer) as Void
    'print "===== | Enter : UPDATE CONTENT | ==================== | Enter : UPDATE CONTENT | ==================== | Enter : UPDATE CONTENT | ====="
    ' Get the UID key from the content object.
    contentKeys = contentObj.keys()
    if contentKeys.count() = 0 then
      'print "updateContent: no keys in contentObj."
        return
    end if
    contentKey = contentKeys[0]
    actualContent = contentObj[contentKey]

   ' print " Actual Content => "; toStringIndent(actualContent,0)
    
    ' For each child in the content group (e.g., background, poster, label), update its dimensions.
    'print "Actual Content Group Type => "; type(actualContent.group)
    if IsAssociativeArray(actualContent) then
        'print " UPDATE CONTENT IsAssociativeArray "
        childKeys = actualContent.keys()
        for each ck in childKeys
            childObj = actualContent[ck]
            'print "UPDATE KEY => "; ck
            updateNode(childObj, "width", newWidth)
            updateNode(childObj, "height", newHeight)
            ' Optionally, if the content group itself has a translation (in its params),
            ' update each child to use that same translation.
            if IsAssociativeArray(actualContent.params) and isValid(actualContent.params.translation) then
                transStr = "[" + Str(actualContent.params.translation[0]) + "," + Str(actualContent.params.translation[1]) + "]"
                updateNode(childObj, "translation", transStr)
            end if
        end for
    else
      'print "updateContent: No children found in content group."
    end if
end function

'----------------------------------------------------------------
' Function: updateBox
'
' Description:
'   Given a box object (created by createBox) and new overall width
'   and height values, this function recalculates the sizes and
'   translations for each layer (margin, border, padding, and content)
'   based on the provided frame-thickness values and updates them.
'
'   It also calls updateContent to update the child nodes inside the
'   content area.
'
' Parameters:
'   boxObj    - the associative array representing the box.
'   newWidth  - Integer: new overall width.
'   newHeight - Integer: new overall height.
'
' Returns:
'   Void (updates the box object in-place)
'----------------------------------------------------------------
function updateBox(boxObj as Object, newWidth as Integer, newHeight as Integer) as Void
    ' Check that the box object is valid.
    if not isValid(boxObj) then
      'print "updateBox: boxObj is invalid."
        return
    end if

    ' Get the UID key from the box object. (Assumes boxObj is an associative array
    ' with one key that is the box’s UID.)
    boxKeys = boxObj.keys()
    if boxKeys.count() = 0 then
      'print "updateBox: no keys in boxObj."
        return
    end if
    boxKey = boxKeys[0]
    actualBox = boxObj[boxKey]

    ' Retrieve frame-thickness values from the box parameters (defaults to 5 if not provided).
    marginFrame = 5
    borderFrame = 5
    paddingFrame = 5
    if actualBox.params.DoesExist("marginFrame") then marginFrame = actualBox.params.marginFrame
    if actualBox.params.DoesExist("borderFrame") then borderFrame = actualBox.params.borderFrame
    if actualBox.params.DoesExist("paddingFrame") then paddingFrame = actualBox.params.paddingFrame

    ' Update overall box dimensions.
    updateNode(actualBox, "width", newWidth)
    updateNode(actualBox, "height", newHeight)
    ' (Assume translation remains unchanged.)

    ' The margin layer occupies the entire box.
    marginKey = boxKey + "_margin"
    if actualBox.group.DoesExist(marginKey) then
        marginObj = actualBox.group[marginKey]
        updateNode(marginObj, "width", newWidth)
        updateNode(marginObj, "height", newHeight)
        updateNode(marginObj, "translation", "[" + Str(actualBox.params.translation[0]) + "," + Str(actualBox.params.translation[1]) + "]")
    end if

    ' The border layer is inset by the marginFrame.
    borderKey = boxKey + "_border"
    if actualBox.group.DoesExist(borderKey) then
        borderObj = actualBox.group[borderKey]
        newBorderTranslation = "[" + Str(actualBox.params.translation[0] + marginFrame) + "," + Str(actualBox.params.translation[1] + marginFrame) + "]"
        updateNode(borderObj, "translation", newBorderTranslation)
        updateNode(borderObj, "width", newWidth - (2 * marginFrame))
        updateNode(borderObj, "height", newHeight - (2 * marginFrame))
    end if

    ' The padding layer is inset further by borderFrame.
    paddingKey = boxKey + "_padding"
    if actualBox.group.DoesExist(paddingKey) then
        paddingObj = actualBox.group[paddingKey]
        newPaddingTranslation = "[" + Str(actualBox.params.translation[0] + marginFrame + borderFrame) + "," + Str(actualBox.params.translation[1] + marginFrame + borderFrame) + "]"
        updateNode(paddingObj, "translation", newPaddingTranslation)
        updateNode(paddingObj, "width", newWidth - 2 * (marginFrame + borderFrame))
        updateNode(paddingObj, "height", newHeight - 2 * (marginFrame + borderFrame))
    end if

    ' The content area is inset further by paddingFrame.
    contentKey = boxKey + "_content"
    if actualBox.group.DoesExist(contentKey) then
        contentObj = actualBox.group[contentKey]
        newContentWidth = newWidth - 2 * (marginFrame + borderFrame + paddingFrame)
        newContentHeight = newHeight - 2 * (marginFrame + borderFrame + paddingFrame)
        updateContent(contentObj, newContentWidth, newContentHeight)
    end if
end function

function Max(a as Integer, b as Integer)
    if a < b
        return b 
    else return a 
    end if
end function 

' Helper function to replace all occurrences of searchStr with replaceStr in inputStr.
' (Since BrightScript doesn’t provide a built-in Replace function.)
function Replace(inputStr as String, searchStr as String, replaceStr as String) as String
    pos_ = Instr(1, inputStr, searchStr)
    while pos_ > 0
        inputStr = Left(inputStr, pos_ - 1) + replaceStr + Mid(inputStr, pos_ + Len(searchStr))
        pos_ = Instr(1, inputStr, searchStr)
    end while
    return inputStr
end function

' Helper function to extract the actual URL from a CSS background-image string.
' For example, it converts: url("http://example.com/image.png")
' to: http://example.com/image.png
function stripURL(cssString as String) as String
    urlPart = Replace(cssString, "url(", "")
    urlPart = Replace(urlPart, ")", "")
    urlPart = Replace(urlPart, """", "")
    urlPart = Replace(urlPart, "'", "")
    return Trim(urlPart)
end function


function RemoveKey(original as Object, keyToRemove as object) as Object
    newArray = {}
    keys = original.keys()
    for each key in keys
        if key <> keyToRemove then
            newArray[key] = original[key]
        end if
    end for
    return newArray
end function

'===========================================================================================================
function buildHitList(targets as Object) as Object
    print "----------------------Building Hit List--------------------------"
    
    ' Initialize the hit list
    hitList = {}
    
    ' Build the class version map - just count versions for each class
    for each className in targets.keys()
        classInstances = targets[className]
        hitList[className] = classInstances.count()
    end for
    
    return hitList
end function


function processData(meta as Object, data as Object, seenObject as Object, targets as Object) as Object
    rootKey = "null"
    processedElements = {}

    ' Validate root element existence
    if not isValid(data[rootKey]) or data[rootKey].count() = 0 
        print "No root element found in data"
        return processedElements
    end if

    rootElements = data[rootKey] ' This is an array of versions

    ' Validate root elements
    if not isValid(rootElements) then 
        print "Invalid root element"
        return processedElements
    end if

    print "Starting document traversal from root element"

    traverseElementChildren(data, invalid, rootElements)

    return processedElements
end function


sub traverseElementChildren(data as Object, parent as Object, children as Object)

    defaultBox_params = {
        translation : [0,90],
        width : 200,
        height : 22,
    }



    ' Ensure children is valid and of correct type
    if not isValid(children) or (type(children) <> "roArray" and type(children) <> "roAssociativeArray") or children.count() = 0
        print " TRUE | Invalid or empty children array/associative array | Type: "; type(children)
        return
    else 
        print " FALSE | Valid children array/associative array"
    end if

    defaultBox_params.height *= children.Count()
    parentBox = createBox(defaultBox_params.height)


    for each childEntry in children
        ' Ensure childEntry is a valid object
        if not isValid(childEntry) or type(childEntry) <> "roAssociativeArray" then 
            print "Skipping invalid child entry: "; childEntry
            continue for
        end if

        ' Ensure childKey and childIndex exist
        if not childEntry.doesExist("childKey") and not childEntry.doesExist("keyName") then 
            print "Skipping child with missing key/index: "; childEntry
            continue for
        end if

        childKey = childEntry.childKey
        childIndex = childEntry.childIndex

        ' Handle missing childKey
        if not isValid(childKey) 
            if childEntry.doesExist("keyName")
                childKey = childEntry.keyName
            else
                print "Child entry is missing keyName, defaulting childKey to empty string"
                childKey = "" 
            end if
        end if

        ' Handle missing childIndex
        if not isValid(childIndex) 
            if childEntry.doesExist("superClass")
                childIndex = childEntry.superClass.version - 1 
            else
                print "Child entry is missing childIndex, defaulting to 0"
                childIndex = 0 
            end if
        end if

        ' Retrieve the correct version of the child
        if not isValid(data[childKey]) or type(data[childKey]) <> "roArray" or childIndex >= data[childKey].count() then 
            print "Skipping missing or invalid child data for key: "; childKey
            continue for
        end if

        childObj = data[childKey][childIndex] ' Select the correct version

        ' Print parent-child relationship
        if isValid(parent)
            print "Parent: "; parent.keyName; " -> Child: "; childObj.keyName; " (Version: "; childObj.superClass.version; ")"
        else
            print "Root Child: "; childObj.keyName; " (Key: "; childKey; ", Index: "; childIndex; ")"
        end if

        ' Recursively process children
        if isValid(childObj.family) and childObj.family.doesExist("children") and type(childObj.family.children) = "roArray"
            print "ChildObj.family.children => "'; toStringIndent(childObj.family.children, 0)
            traverseElementChildren(data, childObj, childObj.family.children)
        end if
    end for
end sub




function processData__(meta as Object, data as Object, seenObject as Object, targets as Object) as Object
    ' Set the root key to "null"
    rootKey = "null"
    
    ' Initialize processed elements storage
    processedElements = {}
    
    ' Initialize a stack for traversal
    traversalStack = []
    
    ' Check if root element exists
    if not isValid(data[rootKey]) or data[rootKey].count() = 0
        print "No root element found in data"
        return processedElements
    end if
    
    ' Get the root element
    rootElement = data[rootKey][0]
    

    
    return processedElements
end function

function processData_(meta as Object, data as Object, seenObject as Object, targets as Object) as Object
    print "----------------------Enter Process Data--------------------------"
    
    ' Initialize tracking structures
    m.seenTypes = {} ' Change to associative array to track versions for each class
    m.processedElements = {}
    
    ' Get the browser body container
    browserContainer = m.Bright_Browser.body.body_box.params.group.body_params_group
    
    ' Create a group to contain our HTML content
    htmlGroup = makeNode("html_container", {
        id: "html_container",
        translation: "[0,200]",
        width: m.width,
        height: m.height - (m.fontSize * 3)
    }, "Group", invalid)
    
    ' Add the HTML container to the browser body
    addNodesWithCaller("HTML_ROOT", browserContainer, htmlGroup)
    
    ' Find the root element (looking in "null" class)
    rootKey = "null"
    
    ' Find the root element
    rootInstances = targets[rootKey]
    if rootInstances = invalid or rootInstances.count() = 0
        print "No root element found in 'null' class"
        return m.processedElements
    end if
    
    ' Process each root instance
    for each rootInstance in rootInstances
        ' Ensure it's an HTML tag
        if isValid(rootInstance.superClass) and isValid(rootInstance.superClass.elementInfo) and rootInstance.superClass.elementInfo.tagName = "html"
            ' Render the root element and its children
            renderHtmlElement(rootInstance, htmlGroup.html_container, targets, 0)
        end if
    end for
    
    return m.processedElements
end function

function renderHtmlElement(element as Object, parentContainer as Object, targets as Object, yPosition as Integer) as Object
    ' Check if element is valid and visible
    if not isValid(element) or not isElementVisible(element)
        return invalid
    end if
    
    ' Determine tag and element details
    tagName = "div"
    if isValid(element.superClass) and isValid(element.superClass.elementInfo) and isValid(element.superClass.elementInfo.tagName)
        tagName = LCase(element.superClass.elementInfo.tagName)
    end if
    
    ' Generate unique identifier
    elementId = generateElementId(element)
    
    ' Prepare box parameters
    boxParams = prepareBoxParameters(element, tagName, yPosition)
    
    ' Create the box for this element
    elementBox = createBox(boxParams)
    
    ' Get the actual box node from the returned group
    boxKey = elementBox.keys()[0]
    actualBoxNode = elementBox[boxKey]
    
    ' Add to parent container
    addNodesWithCaller("HTML_ELEMENT", parentContainer, elementBox)
    
    ' Store in processed elements
    m.processedElements[elementId] = {
        box: actualBoxNode,
        children: []
    }
    
    ' Process children if they exist
    if isValid(element.family) and isValid(element.family.children)
        ' Vertical offset for children
        childYOffset = boxParams.height + 10
        
        for each childRef in element.family.children
            ' Find the actual child instance
            childInstance = findChildInstance(childRef, targets)
            
            if isValid(childInstance)
                ' Recursively render child, using the current element's box as the container
                renderHtmlElement(childInstance, elementBox, targets, childYOffset)
                
                ' Update Y offset for next child
                childYOffset += boxParams.height + 10
            end if
        end for
    end if
    
    return actualBoxNode
end function

function findChildInstance(childRef as Object, targets as Object) as Object
    ' Skip if child reference is invalid
    if not isValid(childRef) or not isValid(childRef.childKey) or not isValid(childRef.childIndex)
        return invalid
    end if
    
    ' Find child class instances
    childKey = childRef.childKey
    childIndex = childRef.childIndex
    
    ' Check if child key exists in targets
    if not targets.doesExist(childKey)
        return invalid
    end if
    
    ' Find matching child instance
    for each childInstance in targets[childKey]
        if isValid(childInstance.superClass) and childInstance.superClass.version = childIndex
            return childInstance
        end if
    end for
    
    return invalid
end function

function isElementVisible(element as Object) as Boolean
    ' Check basic element validity
    if not isValid(element) or not isValid(element.superClass)
        return false
    end if
    
    ' Get element info
    if isValid(element.superClass.elementInfo) and isValid(element.superClass.elementInfo.attributes)
        attributes = element.superClass.elementInfo.attributes
        
        ' Check style attributes for visibility
        if isValid(attributes.style)
            styleAttrs = attributes.style
            
            ' Check inline or default styles
            styleSource = invalid
            if isValid(styleAttrs.inline)
                styleSource = styleAttrs.inline
            else if isValid(styleAttrs.default)
                styleSource = styleAttrs.default
            end if
            
            ' Check display property
            if isValid(styleSource) and isValid(styleSource.display)
                display = LCase(styleSource.display)
                if display = "none"
                    return false
                end if
            end if
            
            ' Check opacity
            if isValid(styleSource) and isValid(styleSource.opacity)
                opacity = Val(styleSource.opacity)
                if opacity <= 0
                    return false
                end if
            end if
        end if
    end if
    
    return true
end function


function generateElementId(element as Object) as String
    ' Generate a unique identifier for an element
    className = "unknown"
    version = "0"
    
    if isValid(element.superClass)
        if isValid(element.superClass.elementInfo) and isValid(element.superClass.elementInfo.tagName)
            className = element.superClass.elementInfo.tagName
        end if
        
        if isValid(element.superClass.version)
            version = element.superClass.version.toStr()
        end if
    end if
    
    return className + "_" + version
end function

function prepareBoxParameters(element as Object, tagName as String, yPosition as Integer) as Object
    ' Default box parameters
    boxParams = {
        x: 10,
        y: yPosition,
        width: 200,
        height: 100,
        color: "0xFFFFFFFF",
        text: ""
    }
    
    ' Get element info
    if isValid(element.superClass) and isValid(element.superClass.elementInfo)
        elementInfo = element.superClass.elementInfo
        
        ' Set text content if available
        if isValid(elementInfo.text)
            boxParams.text = elementInfo.text
        end if
        
        ' Process style attributes
        if isValid(elementInfo.attributes) and isValid(elementInfo.attributes.style)
            styleAttrs = elementInfo.attributes.style
            
            ' Try different style sources
            styleSource = invalid
            if isValid(styleAttrs.inline)
                styleSource = styleAttrs.inline
            else if isValid(styleAttrs.default)
                styleSource = styleAttrs.default
            end if
            
            ' Apply style attributes
            if isValid(styleSource)
                ' Width
                if isValid(styleSource.width)
                    width = Val(styleSource.width)
                    if width > 0
                        boxParams.width = width
                    end if
                end if
                
                ' Height
                if isValid(styleSource.height)
                    height = Val(styleSource.height)
                    if height > 0
                        boxParams.height = height
                    end if
                end if
                
                ' Background color
                if isValid(styleSource.backgroundColor)
                    boxParams.color = convertCssColorToHex(styleSource.backgroundColor)
                end if
            end if
        end if
    end if
    
    ' Use tag-specific styling from htmlMap if available
    conversionMaps = htmlMap()
    tagStyles = conversionMaps.tagStyles
    
    if tagStyles.doesExist(tagName)
        tagStyle = tagStyles[tagName]
        
        ' Use tag-specific default dimensions if not overridden
        if tagStyle.doesExist("width") and boxParams.width = 200
            boxParams.width = tagStyle.width
        end if
        
        if tagStyle.doesExist("height") and boxParams.height = 100
            boxParams.height = tagStyle.height
        end if
        
        ' Use default text if no text is provided
        if boxParams.text = "" and tagStyle.doesExist("defaultText")
            boxParams.text = tagStyle.defaultText
        end if
    end if
    
    return boxParams
end function

function processChildren(children as Object, targets as Object, parentObj as Object, startY as Integer) as Void
    ' Get parent container dimensions
    parentWidth = 0
    parentHeight = 0
    parentX = 0
    initialParentHeight = 0
    
    if isValid(parentObj)
        if isValid(parentObj.params)
            parentWidth = parentObj.params.width
            parentHeight = parentObj.params.height
            initialParentHeight = parentHeight
            parentX = 0 ' Default offset from left edge
            
            ' If there's a translation, extract X position
            if isValid(parentObj.params.translation)
                translation = parentObj.params.translation
                if isString(translation)
                    parsed = parse(["[",",","]"], translation, [])
                    if parsed.count() >= 1
                        parentX = Val(parsed[0])
                    end if
                end if
            end if
        end if
    end if
    
    ' If parent width isn't valid, use a default
    if parentWidth <= 0
        parentWidth = m.width - 40 ' Safe default
    end if
    
    ' Calculate available width for children (account for padding)
    childMaxWidth = parentWidth - 20 ' 10px padding on each side
    childX = 10 ' Start with 10px indent from parent left edge
    yPos = startY
    
    ' Keep track of total height needed for children
    totalChildrenHeight = 0
    
    for each child in children
        if isValid(child) and isValid(child.childKey) and isValid(child.childIndex)
            childKey = child.childKey
            childIndex = child.childIndex
            childId = childKey + "_" + childIndex.toStr()
            
            ' Initialize seenTypes entry for this class if not exists
            if not m.seenTypes.doesExist(childKey)
                m.seenTypes[childKey] = []
            end if
            
            ' Skip if this version is already processed
            if isInList(childIndex, m.seenTypes[childKey])
                continue for
            end if
            
            ' Find the child instance
            childInstance = invalid
            if targets.doesExist(childKey)
                for each ci in targets[childKey]
                    if isValid(ci.superClass) and ci.superClass.version = childIndex
                        childInstance = ci
                        exit for
                    end if
                end for
            end if
            
            ' Skip if child not found
            if not isValid(childInstance)
                continue for
            end if
            
            ' Process this child
            tagName = "unknown"
            if isValid(childInstance.superClass.elementInfo) and isValid(childInstance.superClass.elementInfo.tagName)
                tagName = childInstance.superClass.elementInfo.tagName
            end if
            
            ' Get element parameters - constrained to parent width
            boxParams = getElementParams(childKey, childInstance, childX, yPos)
            
            ' Ensure width doesn't exceed parent bounds
            if boxParams.width > childMaxWidth
                boxParams.width = childMaxWidth
            end if
            
            boxParams.color = "0x00FF00FF" ' Green for children
            boxParams.text = childKey + " (v" + childIndex.toStr() + ") - " + tagName
            
            ' Create the box
            elementBox = createBox(boxParams)
            
            ' Add to container
            addNodesWithCaller("CHILD_ELEMENT", parentObj, elementBox)
            
            ' Store in processed elements
            boxKey = elementBox.keys()[0]
            m.processedElements[childId] = {
                box: elementBox[boxKey],
                parent: parentObj.id, ' Track parent ID
                children: []
            }
            
            ' Mark this version as seen
            m.seenTypes[childKey].push(childIndex)
            
            ' Check if we've seen all versions of this class
            if m.hitList.doesExist(childKey) and m.seenTypes[childKey].count() >= m.hitList[childKey]
                ' All versions seen, remove from hit list
                m.hitList.delete(childKey)
            end if
            
            ' Process this child's children - pass the child box as parent
            if isValid(childInstance.family) and isValid(childInstance.family.children) and childInstance.family.children.count() > 0
                ' Create a new container for grandchildren inside the child element
                grandchildContainer = elementBox[boxKey]
                
                ' Process this child's children
                processChildren(childInstance.family.children, targets, grandchildContainer, 10) ' Start at 10px y offset
            end if
            
            ' Update position for next child
            yPos += boxParams.height + 15
            
            ' Update total height needed
            totalChildrenHeight = yPos + 10 ' Add extra padding at the bottom
        end if
    end for
    
    ' Check if parent needs to be resized to fit all children
    if totalChildrenHeight > initialParentHeight - startY
        ' Calculate new required height
        newHeight = totalChildrenHeight + startY + 10 ' Extra padding at bottom
        
        ' Update parent box size
        if isValid(parentObj) and isValid(parentObj.params) and isValid(parentObj.node)
            ' Use updateBox to resize the parent
            if isValid(parentObj)
                updateBox(parentObj, parentObj.params.width, newHeight)
            end if 

        end if
    end if
end function

' Process children of an element
function processElementChildren(parentId as String, parentInstance as Object, targets as Object, containingGroup as Object) as Void
   ' print "<Enter = function processElementChildren(parentId as String, parentInstance as Object, targets as Object, containingGroup as Object) as Void> : "; toStringIndent(parentInstance,0)

    ' Check if this element has children
    if not isValid(parentInstance.family) or not isValid(parentInstance.family.children) or parentInstance.family.children.count() = 0
        return
    end if

  '  print "<Exit | Boolean = if not isValid(parentInstance.family) or not isValid(parentInstance.family.children) or parentInstance.family.children.count() = 0>"
    
    ' Get parent box
    parentBox = m.processedElements[parentId].box
    
    ' Create child container if needed
    childContainer = invalid
    
    ' If parent box has node, use it to create a container for children
    if isValid(parentBox) and isValid(parentBox.node)
        ' Get parent box dimensions
        pWidth = parentBox.params.width
        pHeight = parentBox.params.height
        
        ' Create container for children inside parent
        childContainer = makeNode("children_" + parentId, {
            translation: "[10,10]",  ' Offset children within parent
            width: pWidth - 20,      ' Slightly smaller than parent
            height: pHeight - 20
        }, "Group", invalid)
        
        ' Add to parent
        addNodesWithCaller("CHILDREN_CONTAINER", parentBox, childContainer)
    else
        ' If no parent box, use containing group
        childContainer = containingGroup
    end if
    
    ' Process each child
    yOffset = 0
    
    for each child in parentInstance.family.children

        if not isValid(child.key)
            child.key = "null"
        end if 

        print "<Enter | Class = ";child.key;" | Loop => for each child in parentInstance.family.children>"

        if isValid(child) and isValid(child.childKey) and isValid(child.childIndex)
            print " TRUE | if isValid(child) and isValid(child.childKey) and isValid(child.childIndex) "
          
            childKey = child.childKey
            childIndex = child.childIndex
            childId = childKey + "_" + childIndex.toStr()
            
            ' Skip if already processed
            if m.processedElements.doesExist(childId)
                 print " CONTINUE | if m.processedElements.doesExist(childId) "
                continue for
            end if
            
            ' Find the child instance
            childInstance = invalid
            if targets.doesExist(childKey)
                for each ci in targets[childKey]
                    if isValid(ci.superClass) and ci.superClass.version = childIndex
                        childInstance = ci
                        exit for
                    end if
                end for
            end if
            
            ' Skip if child not found
            if not isValid(childInstance)
                continue for
            end if
            
            ' Get child parameters
            boxParams = getElementParams(childKey, childInstance, 10, yOffset)
           ' boxParams.color = "0x000000FF"
            'print " BOX PARAMETERS => "; toStringIndent(boxParams,0)


            
            ' Create the box
            elementBox = createBox(boxParams)
            
            ' Add to container
            addNodesWithCaller("CHILD_ELEMENT", childContainer, elementBox)
            
            ' Store for reference
            boxKey = elementBox.keys()[0]
            m.processedElements[childId] = {
                box: elementBox[boxKey],
                parent: parentId,
                children: []
            }
            
            ' Add to parent's children list
            m.processedElements[parentId].children.push(childId)
            
            'print "<func =  processElementChildren(childId, childInstance, targets, childContainer)> : ";childInstance 

            ' Process this child's children
            processElementChildren(childId, childInstance, targets, childContainer)
            
            ' Update offset for next child
            yOffset = yOffset + boxParams.height + 5
        else 
            print " ELSE | if isValid(child) and isValid(child.childKey) and isValid(child.childIndex) "
        end if
    end for
end function

' Extract parameters for an element from its class info
function getElementParams(className as String, classInstance as Object, x as Integer, y as Integer) as Object
    ' Default values
    width = 200
    height = 100
    text = ""
    tagName = "div"
    
    ' Get element info
    if isValid(classInstance.superClass) and isValid(classInstance.superClass.elementInfo)
        elementInfo = classInstance.superClass.elementInfo
        
        ' Get tag name
        if isValid(elementInfo.tagName)
            tagName = LCase(elementInfo.tagName)
            
            ' We'll handle tag tracking in the main process function,
            ' not here in getElementParams
        end if
        
        ' Get text
        if isValid(elementInfo.text)
            text = elementInfo.text
        end if
        
        ' Get style attributes
        if isValid(elementInfo.attributes) and isValid(elementInfo.attributes.style)
            styleAttrs = elementInfo.attributes.style
            
            ' Try different style sources
            styleSource = invalid
            
            if isValid(styleAttrs.default)
                styleSource = styleAttrs.default
            else if isValid(styleAttrs.inline)
                styleSource = styleAttrs.inline
            end if
            
            ' Extract size and position
            if isValid(styleSource)
                if isValid(styleSource.width)
       '             width = Val(styleSource.width)
                end if
                
                if isValid(styleSource.height)
        '            height = Val(styleSource.height)
                end if
                
                ' Position can be set directly if needed
                if isValid(styleSource.left)
         '           x = Val(styleSource.left)
                end if
                
                if isValid(styleSource.top)
          '          y = Val(styleSource.top)
                end if
            end if
        end if
    end if
    
    ' Create element ID
    elementId = className + "_" + classInstance.superClass.version.toStr()
    
    ' Determine styling based on tag type
    marginFrame = 5
    borderFrame = 5
    paddingFrame = 5
    
    ' Get tag styling from htmlMap if available
    conversionMaps = htmlMap()
    tagStyles = conversionMaps.tagStyles
    
    if tagStyles.doesExist(tagName)
        tagStyle = tagStyles[tagName]
        
        if tagStyle.doesExist("marginFrame")
            marginFrame = tagStyle.marginFrame
        end if
        
        if tagStyle.doesExist("borderFrame")
            borderFrame = tagStyle.borderFrame
        end if
        
        if tagStyle.doesExist("paddingFrame")
            paddingFrame = tagStyle.paddingFrame
        end if

        ' Check for default text if no text is provided
        if text = "" and tagStyle.doesExist("defaultText")
            text = tagStyle.defaultText
        end if
    end if
    
    ' Return the box parameters
    return {
        key : className,
        id: elementId,  ' Changed from key to id to be consistent
        x: x,
        y: y,
        width: width,
        height: height,
        marginFrame: marginFrame,
        borderFrame: borderFrame,
        paddingFrame: paddingFrame,
        text: text,
        className: className,  ' Added className
        version: classInstance.superClass.version  ' Added version
    }
end function

'===========================================================================================================

function renderElement(classObj as Object, key as String, version as Integer, parentObj as Object) as Object
    if not isValid(classObj) or not isValid(classObj.superClass)
        'print "Invalid class object for key: " + key + ", version: " + version.toStr()
        return invalid
    end if
    
    ' Get element info
    superClass = classObj.superClass
    elementInfo = superClass.elementInfo
    
    ' Default values
    tagName = "div"
    elementId = key + "_" + version.toStr()
    text = ""
    
    ' Extract tag and attributes
    if isValid(elementInfo)
        if isValid(elementInfo.tagName)
            tagName = LCase(elementInfo.tagName)
        end if
        
        if isValid(elementInfo.text)
            text = elementInfo.text
        end if
    end if
    
    ' Get HTML mapping and styles
    conversionMaps = htmlMap()
    tagStyles = conversionMaps.tagStyles
    tagDisplay = conversionMaps.tagDisplay
    
    ' Initialize position based on current render position
    position = [m.renderPosition.x, m.renderPosition.y]
    
    ' Initialize with appropriate default size based on element type
    ' Block elements default to parent width, inline elements size to content
    'isBlockElement = (tagDisplay.DoesExist(tagName) and tagDisplay[tagName] = "block")
    
    ' Set default size values based on element type
    ' Default width: block elements get parent width, inline elements get minimum width
    defaultWidth = 0
   ' if isBlockElement
   '     defaultWidth = parentObj.params.width - 10 ' Width for block elements
   ' else
      '  defaultWidth = m.fontSize * 8 ' Width for inline elements
   '' end if
    
    ' Default height: typically sized by content or a minimum height
    defaultHeight = m.fontSize * 1.5 ' Default height based on font size
    
    ' Adjust height for text elements based on content
    if tagName.StartsWith("h") and Len(tagName) = 2
        ' Heading tags have larger heights
        headingLevel = Val(Right(tagName, 1))
        defaultHeight = m.fontSize * (3 - (headingLevel * 0.3))
    else if text <> ""
        ' Approximate height based on text length and width
        approximateLines = Ceil(Len(text) * (m.fontSize / 2) / defaultWidth)
        defaultHeight = m.fontSize * (approximateLines + 0.5)
    end if
    
    size = [defaultWidth, defaultHeight]
    
    ' Get default tag styling
    marginFrame = 0
   ' if isBlockElement
    '    marginFrame = 5
    'else
    '    marginFrame = 2
    'end if
    
    borderFrame = 0
    
    paddingFrame = 0
   ' if isBlockElement
   '     paddingFrame = 5
   ' else
   '     paddingFrame = 2
   ' end if
    
    if tagStyles.DoesExist(tagName)
        tagStyle = tagStyles[tagName]
        if tagStyle.DoesExist("marginFrame")
            marginFrame = tagStyle.marginFrame
        end if
        if tagStyle.DoesExist("borderFrame")
            borderFrame = tagStyle.borderFrame
        end if
        if tagStyle.DoesExist("paddingFrame")
            paddingFrame = tagStyle.paddingFrame
        end if
    end if
    
    ' Create the box parameters with appropriate sizing
    boxParams = {
        id: elementId,
        x: position[0],
        y: position[1],
        width: size[0],
        height: size[1],
        marginFrame: marginFrame,
        borderFrame: borderFrame,
        paddingFrame: paddingFrame
    }
    
    ' Add text content if available
    if text <> ""
        boxParams.text = text
    end if
    
    ' Set appropriate colors based on element type
   ' boxParams.color = "0x00FF00FF" ' Default white background
   ' boxParams.text = tagName
    
    ' Create the box
    elementObj = createBox(boxParams)
    
    ' Add to parent
    if isValid(elementObj) and isValid(parentObj)
        ' Add the node to the parent
        if isValid(parentObj.node)
            parentObj.node.appendChild(elementObj[elementId].node)
        end if
    end if
    
    ' Update render position for next element
    m.renderPosition.y = m.renderPosition.y + size[1] + (marginFrame * 2) ' Account for margins
    
    return elementObj[elementId]
end function

' Helper function to get element depth in hierarchy
function getElementDepth(elementId as String, hierarchy as Object) as Integer
    if not hierarchy.DoesExist(elementId) or hierarchy[elementId].parent = ""
        return 0 ' Root element
    end if
    
    parentId = hierarchy[elementId].parent
    return 1 + getElementDepth(parentId, hierarchy)
end function

' Helper function to parse inline style string
function parseInlineStyle(styleStr as String) as Object
    result = {}
    if not isValid(styleStr) or styleStr = ""
        return result
    end if
    
    ' Split style string into individual property:value pairs
    stylePairs = styleStr.split(";")
    for each pair in stylePairs
        if pair.trim() = ""
            continue for
        end if
        
        ' Split each pair into property and value
        parts = pair.split(":")
        if parts.count() >= 2
            propName = parts[0].trim()
            propValue = parts[1].trim()
            result[propName] = propValue
        end if
    end for
    
    return result
end function

' Helper function to merge styles with later objects having priority
function mergeStyles(baseStyles as Object, overrideStyles as Object) as Object
    result = {}
    
    ' Copy base styles
    for each key in baseStyles
        result[key] = baseStyles[key]
    end for
    
    ' Apply override styles
    for each key in overrideStyles
        result[key] = overrideStyles[key]
    end for
    
    return result
end function

' Helper function to convert CSS color to Roku hex format
function convertCssColorToHex(cssColor as String) as String
    ' Default to black
    if not isValid(cssColor) or cssColor = ""
        return "0x000000FF"
    end if
    
    ' Handle named colors
    if cssColor = "black"
        return "0x000000FF"
    else if cssColor = "white"
        return "0xFFFFFFFF"
    else if cssColor = "red"
        return "0xFF0000FF"
    else if cssColor = "green"
        return "0x00FF00FF"
    else if cssColor = "blue"
        return "0x0000FFFF"
    else if cssColor = "transparent"
        return "0x00000000"
    end if
    
    ' Handle hex colors
    if Left(cssColor, 1) = "#"
        hexColor = Right(cssColor, Len(cssColor) - 1)
        if Len(hexColor) = 3
            ' Expand shorthand hex (#RGB to #RRGGBB)
            r = Mid(hexColor, 1, 1) + Mid(hexColor, 1, 1)
            g = Mid(hexColor, 2, 1) + Mid(hexColor, 2, 1)
            b = Mid(hexColor, 3, 1) + Mid(hexColor, 3, 1)
            hexColor = r + g + b
        end if
        
        ' Return Roku format with alpha
        return "0x" + hexColor + "FF"
    end if
    
    ' Handle rgb/rgba colors
    rgbaMatch = CreateObject("roRegex", "rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*([0-9\.]+))?\s*\)", "i")
    matches = rgbaMatch.Match(cssColor)
    if matches <> invalid and matches.count() >= 4
        r = Val(matches[1])
        g = Val(matches[2])
        b = Val(matches[3])
        a = 255 ' Default alpha
        if matches.count() >= 5 and matches[4] <> invalid
            a = Int(Val(matches[4]) * 255)
        end if
        
        ' Convert to hex and pad with zeros if needed
       ' rHex = Right("0" + UCase(Str(r, 16)), 2)
        'gHex = Right("0" + UCase(Str(g, 16)), 2)
       ' bHex = Right("0" + UCase(Str(b, 16)), 2)
       ' aHex = Right("0" + UCase(Str(a, 16)), 2)
        
        return "0x"' + rHex + gHex + bHex + aHex
    end if
    
    ' Default for unhandled formats
    return "0x000000FF"
end function

sub setData()
    'print "Set Data"
    
    allowedTags = [
        "button", "h1", "h2", "h3", "h4", "h5", "h6", "label", "p", "div", "span", "a", "article", "section", "header", "footer", "nav", "aside", "ul", "ol", "li", "blockquote", "pre", "code", "figure", "figcaption"
    ]

    data = m.readXMLContentTask.data
    m.labelNodes = []

    counter = 90

    ' Make sure the body is prepared for rendering
    bodyBox = m.Bright_Browser.body.body_box

    'print "SET DATA : BODY BOX => "; toStringIndent(bodyBox,0)
    
    ' Clear any existing content before rendering new content
   ' if isValid(m.Bright_Browser.body.body_box.params.group.body_params_group.node)
     '   childCount = m.Bright_Browser.body.body_box.params.group.body_params_group.node.getChildCount()
     '   for i = childCount - 1 to 0 step -1
     '       m.Bright_Browser.body.body_box.params.group.body_params_group.node.removeChildIndex(i)
     '   end for
   ' end if

    container = bodyBox.params
    bounds = { translation: container.translation, width: container.width, height: container.height }
    translation = bounds.translation 

    x = container.translation[0]
    y = container.translation[1]

    boxMetrics = calculateBoxSize(m.fontSize)

    meta = { counter: counter, tags: allowedTags, container: container, bounds: bounds, boxMetrics: boxMetrics }

    json = m.readXMLContentTask.data 

    if isString(json)
        'print "Processing JSON data..."

        ' Parse the JSON data
        data = parseJSON(json)

        ' Initialize counters
        m.totalCount = 0
        m.classCount = 0 

        ' Process data and render in one step
        result = processData(meta, data, {}, data)
        
        ' Store counts for reference
        m.counts = { total: m.totalCount, class: m.classCount }
        'print "Element counts => Total: " + m.totalCount.toStr() + ", Class: " + m.classCount.toStr()
    else
        'print "Error: Invalid JSON data received"
    end if
end sub

sub setcontent()
    m.content = m.readXMLContentTask.content
    m.contentitems = m.content.getChildCount()
    m.currentitem = 0
end sub


function htmlMap() as Object
    conversionsMap = CreateObject("roAssociativeArray")
    
    ' Get the base font size from calculateFontSize or use a default
    fontSize = 24 ' Default fallback size
    if isValid(m.fontSize)
        fontSize = m.fontSize
    else if isValid(m.screenSize)
        fontSize = calculateFontSize(m.screenSize)
    end if
    
    ' Get screen dimensions if available
    screenWidth = 1280 ' Default fallback width
    screenHeight = 720 ' Default fallback height
    if isValid(m.width)
        screenWidth = m.width
    end if
    if isValid(m.height)
        screenHeight = m.height
    end if
    
    ' HTML tags mapped to box-based rendering approach
    tagToNode = {
        ' Block elements - rendered as boxes with full width
        "div": "Box",
        "section": "Box",
        "article": "Box",
        "header": "Box",
        "footer": "Box", 
        "nav": "Box",
        "aside": "Box",
        "main": "Box",
        "figure": "Box",
        "p": "Box",
        "blockquote": "Box",
        "pre": "Box",
        "ul": "Box",
        "ol": "Box",
        "li": "Box",
        "dl": "Box",
        "form": "Box",
        "fieldset": "Box",
        "table": "Box",
        "thead": "Box",
        "tbody": "Box",
        "tfoot": "Box",
        "tr": "Box",
        "th": "Box",
        "td": "Box",

        ' Inline elements - rendered as boxes with inline characteristics
        "span": "Box",
        "a": "Box",
        "strong": "Box",
        "em": "Box",
        "b": "Box",
        "i": "Box",
        "u": "Box",
        "mark": "Box",
        "small": "Box",
        "del": "Box",
        "ins": "Box",
        "sub": "Box",
        "sup": "Box",
        "code": "Box",
        "samp": "Box",
        "figcaption": "Box",
        "address": "Box",
        "dt": "Box",
        "dd": "Box",
        
        ' Heading elements
        "h1": "Box",
        "h2": "Box",
        "h3": "Box",
        "h4": "Box", 
        "h5": "Box",
        "h6": "Box",
        
        ' Media and interactive elements
        "img": "Box",
        "picture": "Box",
        "video": "Box",
        "audio": "Box",
        "canvas": "Box",
        "iframe": "Box",
        "embed": "Box",
        "object": "Box",
        "input": "Box",
        "button": "Box",
        "select": "Box",
        "textarea": "Box",
        
        ' Non-visible elements
        "meta": "Box",
        "link": "Box",
        "script": "Box",
        "style": "Box",
        "title": "Box",
        "dialog": "Box"
    }

    ' Display characteristics for HTML tags
    tagDisplay = {
        ' Block elements
        "div": "block",
        "section": "block",
        "article": "block",
        "header": "block",
        "footer": "block",
        "nav": "block",
        "aside": "block",
        "main": "block",
        "p": "block",
        "h1": "block",
        "h2": "block",
        "h3": "block",
        "h4": "block",
        "h5": "block",
        "h6": "block",
        "blockquote": "block",
        "pre": "block",
        "ul": "block",
        "ol": "block",
        "li": "block",
        "table": "block",
        
        ' Inline elements
        "span": "inline",
        "a": "inline",
        "strong": "inline",
        "em": "inline",
        "img": "inline-block"
    }
    
    ' Calculate default sizes
    defaultBlockWidth = screenWidth - Int(fontSize * 2) ' Full width minus some margin
    narrowBlockWidth = Int(screenWidth * 0.7) ' 70% of screen width
    inlineWidth = Int(fontSize * 10) ' Width for inline elements
    
    ' Standard heights based on fontSize
    lineHeight = Int(fontSize * 1.5)
    doubleLineHeight = Int(fontSize * 3)
    smallLineHeight = Int(fontSize * 1.2)
    largeLineHeight = Int(fontSize * 2)

    ' Default styling for HTML tags - now with responsive width and height
    tagStyles = {
        ' Heading styles - scaled proportionally from the base font size
        "h1": { 
            marginFrame: Int(fontSize * 0.4), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.2), 
            fontSize: Int(fontSize * 2),
            width: defaultBlockWidth,
            height: largeLineHeight,
            defaultText: "<h1> Heading 1"
        },
        "h2": { 
            marginFrame: Int(fontSize * 0.35), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.2), 
            fontSize: Int(fontSize * 1.75),
            width: defaultBlockWidth,
            height: largeLineHeight,
            defaultText: "<h2> Heading 2"
        },
        "h3": { 
            marginFrame: Int(fontSize * 0.3), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.15), 
            fontSize: Int(fontSize * 1.5),
            width: defaultBlockWidth,
            height: lineHeight,
            defaultText: "<h3> Heading 3"
        },
        "h4": { 
            marginFrame: Int(fontSize * 0.25), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.15), 
            fontSize: Int(fontSize * 1.25),
            width: defaultBlockWidth,
            height: lineHeight,
            defaultText: "<h4> Heading 4"
        },
        "h5": { 
            marginFrame: Int(fontSize * 0.2), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.1), 
            fontSize: Int(fontSize * 1.1),
            width: defaultBlockWidth,
            height: lineHeight,
            defaultText: "<h5> Heading 5"
        },
        "h6": { 
            marginFrame: Int(fontSize * 0.15), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.1), 
            fontSize: fontSize,
            width: defaultBlockWidth,
            height: lineHeight,
            defaultText: "<h6> Heading 6"
        },
        
        ' Block element styles - using font size to determine spacing
        "p": { 
            marginFrame: Int(fontSize * 0.3), 
            borderFrame: 0, 
            paddingFrame: 0, 
            fontSize: fontSize,
            width: defaultBlockWidth,
            height: doubleLineHeight,
            defaultText: "<p> Paragraph"
        },
        "div": { 
            marginFrame: Int(fontSize * 0.1), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.1), 
            fontSize: fontSize,
            width: defaultBlockWidth,
            height: lineHeight,
            defaultText: "<div> Division"
        },
        "blockquote": { 
            marginFrame: Int(fontSize * 0.4), 
            borderFrame: Int(fontSize * 0.1), 
            paddingFrame: Int(fontSize * 0.4), 
            fontSize: fontSize,
            width: narrowBlockWidth,
            height: doubleLineHeight,
            defaultText: "<blockquote> Quote"
        },
        
        ' List styles
        "ul": { 
            marginFrame: Int(fontSize * 0.4), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.4), 
            fontSize: fontSize,
            width: defaultBlockWidth,
            height: doubleLineHeight,
            defaultText: "<ul> Unordered List"
        },
        "ol": { 
            marginFrame: Int(fontSize * 0.4), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.4), 
            fontSize: fontSize,
            width: defaultBlockWidth,
            height: doubleLineHeight,
            defaultText: "<ol> Ordered List"
        },
        "li": { 
            marginFrame: Int(fontSize * 0.2), 
            borderFrame: 0, 
            paddingFrame: Int(fontSize * 0.1), 
            fontSize: fontSize,
            width: defaultBlockWidth - Int(fontSize * 2),
            height: lineHeight,
            defaultText: "<li> List Item"
        },
        
        ' Table styles
        "table": { 
            marginFrame: Int(fontSize * 0.2), 
            borderFrame: Int(fontSize * 0.05), 
            paddingFrame: 0, 
            fontSize: fontSize,
            width: defaultBlockWidth,
            height: doubleLineHeight,
            defaultText: "<table> Table"
        },
        "th": { 
            marginFrame: 0, 
            borderFrame: Int(fontSize * 0.05), 
            paddingFrame: Int(fontSize * 0.2), 
            fontSize: fontSize,
            width: Int(defaultBlockWidth / 3),
            height: lineHeight,
            defaultText: "<th> Table Header"
        },
        "td": { 
            marginFrame: 0, 
            borderFrame: Int(fontSize * 0.05), 
            paddingFrame: Int(fontSize * 0.2), 
            fontSize: fontSize,
            width: Int(defaultBlockWidth / 3),
            height: lineHeight,
            defaultText: "<td> Table Cell"
        },
        
        ' Inline styles
        "a": { 
            marginFrame: 0, 
            borderFrame: 0, 
            paddingFrame: 0, 
            color: "0x0000FFFF", 
            fontSize: fontSize,
            width: inlineWidth,
            height: lineHeight,
            defaultText: "<a> Link"
        },
        "strong": { 
            marginFrame: 0, 
            borderFrame: 0, 
            paddingFrame: 0, 
            fontWeight: "bold", 
            fontSize: fontSize,
            width: inlineWidth,
            height: lineHeight,
            defaultText: "<strong> Bold Text"
        },
        "em": { 
            marginFrame: 0, 
            borderFrame: 0, 
            paddingFrame: 0, 
            fontStyle: "italic", 
            fontSize: fontSize,
            width: inlineWidth,
            height: lineHeight,
            defaultText: "<em> Italic Text"
        },
        
        ' Media styles
        "img": { 
            marginFrame: Int(fontSize * 0.1), 
            borderFrame: 0, 
            paddingFrame: 0, 
            fontSize: fontSize,
            width: Int(fontSize * 10),
            height: Int(fontSize * 10),
            defaultText: "<img> Image"
        }
    }

    ' Add default text for any tags without specific styles
    defaultTagText = {}
    
    ' Create default text for all block elements
    for each tag in tagDisplay.keys()
        if tagDisplay[tag] = "block" and not tagStyles.doesExist(tag)
            defaultTagText[tag] = "<" + tag + "> Block Element"
        end if
    end for
    
    ' Create default text for all inline elements
    for each tag in tagDisplay.keys()
        if tagDisplay[tag] = "inline" and not tagStyles.doesExist(tag)
            defaultTagText[tag] = "<" + tag + "> Inline Element"
        end if
    end for
    
    ' Create default text for remaining tags
    for each tag in tagToNode.keys()
        if not defaultTagText.doesExist(tag) and not tagStyles.doesExist(tag)
            defaultTagText[tag] = "<" + tag + "> Element"
        end if
    end for

    ' Create reverse mapping from SceneGraph nodes to HTML tags
    nodeToTag = CreateObject("roAssociativeArray")
    for each key in tagToNode
        nodeType = tagToNode[key]
        if not nodeToTag.DoesExist(nodeType)
            nodeToTag[nodeType] = []
        end if
        nodeToTag[nodeType].Push(key)
    end for

    ' Combine all mappings into the conversionsMap
    conversionsMap["tagToNode"] = tagToNode
    conversionsMap["nodeToTag"] = nodeToTag
    conversionsMap["tagDisplay"] = tagDisplay
    conversionsMap["tagStyles"] = tagStyles
    conversionsMap["defaultTagText"] = defaultTagText
    conversionsMap["baseFontSize"] = fontSize
    conversionsMap["screenWidth"] = screenWidth
    conversionsMap["screenHeight"] = screenHeight

    return conversionsMap
end function


function isVertical(key as String) as Boolean
    if key = "up" or key = "down" then
        return true
    else
        return false
    end if
end function

function isHorizontal(key as String) as Boolean
    if key = "left" or key = "right" then
        return true
    else
        return false
    end if
end function

function isTranslation(key as String) as Boolean
    return isVertical(key) or isHorizontal(key)
end function



function onKeyEvent(key as String, press as Boolean) as Boolean
    ' Retrieve children from the content group (modify the path as needed)
    children = m.Bright_Browser.body.body_box.params.group.body_params_group.group.group
    keys = children.keys()

    if press then
        if key = "back" then
            return true
        else if isTranslation(key) then
            ' For translation keys (vertical or horizontal), adjust each child's translation.
            sample = children[keys[0]]
         'print "Sample => " + toStringIndent(sample, 0)
            for each childKey in keys
                if isValid(children[childKey].params) then
                    translation = children[childKey].node.translation
                    if isString(translation) then
                        parsed = parse(["[",",","]"], translation, [])
                        translation = [val(parsed[0]), val(parsed[1])]
                    end if
                    if isVertical(key) then
                        if key = "up" then
                            translation[1] = translation[1] + m.fontsize
                        else if key = "down" then
                            translation[1] = translation[1] - m.fontsize
                        end if
                    else if isHorizontal(key) then
                        if key = "left" then
                            translation[0] = translation[0] - m.fontsize
                        else if key = "right" then
                            translation[0] = translation[0] + m.fontsize
                        end if
                    end if
                    ' Rebuild translation string.
                    newTranslation = "[" + Str(translation[0]) + "," + Str(translation[1]) + "]"
                    updateNode(children[childKey], "translation", newTranslation)
                else
                 'print "Params not valid for child: " + childKey
                end if
            end for
            return true
        else if key = "OK" then
            return true
        else if key = "replay" then
            return true
        else if key = "play" then
            return true
        else if key = "playonly" then
            return true
        else if key = "rewind" then
            return true
        else if key = "fastforward" then
            return true
        else if key = "options" then
            return true
        else if key = "pause" then
            return true
        else if key = "channelup" then
            return true
        else if key = "channeldown" then
            return true
        end if
    end if

    return false
end function

function scrollContent(amount as Integer)

    if isValid(m.body_margin)

        m.body_port.translation = [0, ]
        m.body_scrollbar_thumb.translation = [m.body_scrollbar_thumb.translation[0], -newY * 0.2] ' Move scrollbar proportionally

    end if

end function