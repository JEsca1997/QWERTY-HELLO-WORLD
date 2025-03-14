'-------------------------------------------
' Handle various categories of HTML tags
'-------------------------------------------

function handleContainerTag(tag as string, value as Object, indent as string , m as Object)
    ' print indent + "Processing Container Tag: " + tag

    if tag = "div" then
        handleDivTag(tag, value, indent)
    else if tag = "span" then
        handleSpanTag(tag, value, indent)
    else if tag = "section" then
        handleSectionTag(tag, value, indent)
    else if tag = "article" then
        handleArticleTag(tag, value, indent)
    else if tag = "header" then
        handleHeaderTag(tag, value, indent)
    else if tag = "footer" then
        handleFooterTag(tag, value, indent)
    else if tag = "nav" then
        handleNavTag(tag, value, indent)
    else if tag = "aside" then
        handleAsideTag(tag, value, indent)
    else if tag = "main" then
        handleMainTag(tag, value, indent)
    else if tag = "figure" then
        handleFigureTag(tag, value, indent)
    else if tag = "figcaption" then
        handleFigcaptionTag(tag, value, indent)
    else if tag = "address" then
        handleAddressTag(tag, value, indent)
    else if tag = "dialog" then
        handleDialogTag(tag, value, indent)
    else if tag = "fieldset" then
        handleFieldsetTag(tag, value, indent)
    end if
end function

function handleTextTag(tag as string, value as Object, indent as string, m as Object)
    ' print indent + "Processing Text Tag: " + tag

    if tag = "p" then
        handlePTag(tag, value, indent)
    else if tag = "strong" then
        handleStrongTag(tag, value, indent)
    else if tag = "em" then
        handleEmTag(tag, value, indent)
    else if tag = "b" then
        handleBTag(tag, value, indent)
    else if tag = "i" then
        handleITag(tag, value, indent)
    else if tag = "u" then
        handleUTag(tag, value, indent)
    else if tag = "mark" then
        handleMarkTag(tag, value, indent)
    else if tag = "small" then
        handleSmallTag(tag, value, indent)
    else if tag = "del" then
        handleDelTag(tag, value, indent)
    else if tag = "ins" then
        handleInsTag(tag, value, indent)
    else if tag = "sub" then
        handleSubTag(tag, value, indent)
    else if tag = "sup" then
        handleSupTag(tag, value, indent)
    else if tag = "blockquote" then
        handleBlockquoteTag(tag, value, indent)
    else if tag = "code" then
        handleCodeTag(tag, value, indent)
    else if tag = "samp" then
        handleSampTag(tag, value, indent)
    else if tag = "pre" then
        handlePreTag(tag, value, indent)
    end if
end function

function handleMediaTag(tag as string, value as Object, indent as string, m as Object)
    ' print indent + "Processing Media Tag: " + tag

    if tag = "img" then
        handleImgTag(tag, value, indent)
    else if tag = "picture" then
        handlePictureTag(tag, value, indent)
    else if tag = "video" then
        handleVideoTag(tag, value, indent)
    else if tag = "audio" then
        handleAudioTag(tag, value, indent)
    else if tag = "canvas" then
        handleCanvasTag(tag, value, indent)
    else if tag = "iframe" then
        handleIframeTag(tag, value, indent)
    else if tag = "embed" then
        handleEmbedTag(tag, value, indent)
    else if tag = "object" then
        handleObjectTag(tag, value, indent)
    end if
end function

function handleLinkTag(tag as string, value as Object, indent as string, m as Object)
    ' print indent + "Processing Link Tag: " + tag

    if tag = "a" then
        handleATag(tag, value, indent)
    end if
end function

function handleListTag(tag as string, value as Object, indent as string, m as Object)
    ' print indent + "Processing List Tag: " + tag

    if tag = "ul" then
        handleUlTag(tag, value, indent)
    else if tag = "ol" then
        handleOlTag(tag, value, indent)
    else if tag = "li" then
        handleLiTag(tag, value, indent)
    else if tag = "dl" then
        handleDlTag(tag, value, indent)
    else if tag = "dt" then
        handleDtTag(tag, value, indent)
    else if tag = "dd" then
        handleDdTag(tag, value, indent)
    end if
end function

function handleTableTag(tag as string, value as Object, indent as string, m as Object)
    ' print indent + "Processing Table Tag: " + tag

    if tag = "table" then
        handleTableTag(tag, value, indent,m)
    else if tag = "thead" then
        handleTheadTag(tag, value, indent)
    else if tag = "tbody" then
        handleTbodyTag(tag, value, indent)
    else if tag = "tfoot" then
        handleTfootTag(tag, value, indent)
    else if tag = "tr" then
        handleTrTag(tag, value, indent)
    else if tag = "th" then
        handleThTag(tag, value, indent)
    else if tag = "td" then
        handleTdTag(tag, value, indent)
    end if
end function

function handleFormTag(tag as string, value as Object, indent as string, m as Object)
    ' print indent + "Processing Form Tag: " + tag

    if tag = "input" then
        handleInputTag(tag, value, indent)
    else if tag = "button" then
        handleButtonTag(tag, value, indent)
    else if tag = "select" then
        handleSelectTag(tag, value, indent)
    else if tag = "textarea" then
        handleTextareaTag(tag, value, indent)
    end if
end function

function handleHeadingTag(tag as string, value as Object, indent as string, m as Object)
    ' print indent + "Processing Heading Tag: " + tag

    if tag = "h1" then
        handleH1Tag(tag, value, indent)
    else if tag = "h2" then
        handleH2Tag(tag, value, indent)
    else if tag = "h3" then
        handleH3Tag(tag, value, indent)
    else if tag = "h4" then
        handleH4Tag(tag, value, indent)
    else if tag = "h5" then
        handleH5Tag(tag, value, indent)
    else if tag = "h6" then
        handleH6Tag(tag, value, indent)
    end if
end function

function handleHeadTag(tag as string, value as Object, indent as string, m as Object)
   ' print indent + "Processing Head Tag: " + tag

    if tag = "meta" then
        handleMetaTag(tag, value, indent)
    else if tag = "link" then
        handleLinkTag(tag, value, indent,m)
    else if tag = "script" then
      '  handleScriptData(tag, value, indent)
    else if tag = "style" then
        handleStyleData(tag, value, indent)
    else if tag = "title" then
        handleTitleTag(tag, value, indent)
    end if
end function

function handleGlobalAttributes(node as Object, value as Object, indent as string)

    ' Check if value has an attribs field before trying to access it
    if Type(value) = "roAssociativeArray" and value.DoesExist("attribs") then
        attribs = value.attribs

        ' Handle the class attribute
        if attribs.Lookup("class", invalid) <> invalid then
            node.className = attribs["class"]
            print indent + "Class: " + attribs["class"]
        else if attribs.Lookup("id", invalid) <> invalid then
            node.id = attribs["id"]
            print indent + "ID: " + attribs["id"]
        else
            'print indent + "Class attribute not found"
        end if

    else 
       ' print indent + "No attribs field or invalid attribs"
    end if
end function

'-------------------------------------------
' Callbacks for various HTML tags with class and id attributes
'-------------------------------------------

' Container Tags Callbacks
function handleDivTag(tag as string, value as Object, indent as string)
    print "function  handleDivTag(tag as string, value as Object, indent as string)"
  
    node = createObject("roSGNode", "Group")
    node.width = 1920
    node.height = 1080
    handleGlobalAttributes(node, value, indent) ' Handle class and id
    m.contentContainer.appendChild(node)
end function

function handleSpanTag(tag as string, value as Object, indent as string)
    print "function handleSpanTag(tag as string, value as Object, indent as string)"
  
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleSectionTag(tag as string, value as Object, indent as string)
    print "function handleSectionTag(tag as string, value as Object, indent as string)"
  
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleArticleTag(tag as string, value as Object, indent as string)
    print "function  handleArticleTag(tag as string, value as Object, indent as string)"
  
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleHeaderTag(tag as string, value as Object, indent as string)
    print "function handleHeaderTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "HeaderFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleFooterTag(tag as string, value as Object, indent as string)
    print "function handleFooterTag(tag as string, value as Object, indent as string)"
  
    node = createObject("roSGNode", "Label")
    node.text = value
    node.color = "gray"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleNavTag(tag as string, value as Object, indent as string)
    print "functionhandleNavTag(tag as string, value as Object, indent as string)"
  
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleAsideTag(tag as string, value as Object, indent as string)
    print "functionhandleAsideTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleMainTag(tag as string, value as Object, indent as string)
    print "function handleMainTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleFigureTag(tag as string, value as Object, indent as string)
    print "function handleFigureTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Poster")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleFigcaptionTag(tag as string, value as Object, indent as string)
    print "function handleFigcaptionTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleAddressTag(tag as string, value as Object, indent as string)
    print "function handleAddressTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleDialogTag(tag as string, value as Object, indent as string)
    print "function handleDialogTag(tag as string, value as Object, indent as string)"
    dialogNode = createObject("roSGNode", "Group")
    dialogNode.translation = [0, 0]

    backgroundRect = createObject("roSGNode", "Rectangle")
    backgroundRect.size = [500, 300]
    backgroundRect.color = "0x000000FF"

    label = createObject("roSGNode", "Label")
    label.text = value.text
    label.translation = [20, 20]

    handleGlobalAttributes(dialogNode, value, indent)
    dialogNode.appendChild(backgroundRect)
    dialogNode.appendChild(label)

    m.contentContainer.appendChild(dialogNode)
end function

function handleFieldsetTag(tag as string, value as Object, indent as string)
    print "function handleFieldsetTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

' Text Tags Callbacks
function handlePTag(tag as string, value as Object, indent as string)
    print "function handlePTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleStrongTag(tag as string, value as Object, indent as string)
    print "function handleStrongTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "BoldFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleEmTag(tag as string, value as Object, indent as string)
    print "function handleEmTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.fontStyle = "italic"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleBTag(tag as string, value as Object, indent as string)
    print "function handleBTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "BoldFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleITag(tag as string, value as Object, indent as string)
    print "function handleITag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.fontStyle = "italic"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleUTag(tag as string, value as Object, indent as string)
    print "function handleUTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.underline = true
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleMarkTag(tag as string, value as Object, indent as string)
    print "function handleMarkTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.backgroundColor = "yellow"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleSmallTag(tag as string, value as Object, indent as string)
    print "function handleSmallTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleDelTag(tag as string, value as Object, indent as string)
    print "function handleDelTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.strikethrough = true
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleInsTag(tag as string, value as Object, indent as string)
    print "function handleInsTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.underline = true
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleSubTag(tag as string, value as Object, indent as string)
    print "function handleSubTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.fontStyle = "subscript"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleSupTag(tag as string, value as Object, indent as string)
    print "function handleSupTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.fontStyle = "superscript"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleBlockquoteTag(tag as string, value as Object, indent as string)
    print "function handleBlockquoteTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "ItalicFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleCodeTag(tag as string, value as Object, indent as string)
    print "function handleCodeTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "MonospaceFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleSampTag(tag as string, value as Object, indent as string)
    print "function handleSampTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handlePreTag(tag as string, value as Object, indent as string)
    print "function handlePreTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

' Media Tags Callbacks
function handleImgTag(tag as string, value as Object, indent as string)
    print "function handleImgTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Poster")
    node.uri = value.uri
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handlePictureTag(tag as string, value as Object, indent as string)
    print "function handlePictureTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Poster")
    node.uri = value.uri
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleVideoTag(tag as string, value as Object, indent as string)
    print "function handleVideoTag(tag as string, value as Object, indent as string)"
    videoNode = createObject("roVideoPlayer")
    videoNode.setContent({ uri: value.uri })
    handleGlobalAttributes(videoNode, value, indent)
    m.contentContainer.appendChild(videoNode)
end function

function handleAudioTag(tag as string, value as Object, indent as string)
    print "function handleAudioTag(tag as string, value as Object, indent as string)"
    audioNode = createObject("roAudioPlayer")
    audioNode.setContent({ uri: value.uri })
    handleGlobalAttributes(audioNode, value, indent)
    m.contentContainer.appendChild(audioNode)
end function

function handleCanvasTag(tag as string, value as Object, indent as string)
  
    print "function handleCanvasTag(tag as string, value as Object, indent as string)"
    ' SceneGraph doesn't support canvas directly; could use an image-based approach
    ' Append logic can be added if implemented as a workaround
end function

function handleIframeTag(tag as string, value as Object, indent as string)
    print "function handleIframeTag(tag as string, value as Object, indent as string)"
  
    ' No direct support in SceneGraph for iframe; might handle via custom webview
end function

function handleEmbedTag(tag as string, value as Object, indent as string)
    print "function handleEmbedTag(tag as string, value as Object, indent as string)"
  
    node = createObject("roSGNode", "Poster")
    node.uri = value.uri
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleObjectTag(tag as string, value as Object, indent as string)
    print "function handleObjectTag(tag as string, value as Object, indent as string)"
  
    ' SceneGraph doesn't directly support object tag; might handle as media node
end function

' Link Tags Callback
function handleATag(tag as string, value as Object, indent as string)
    print "function handleATag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value.text
    node.uri = value.href
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

' List Tags Callbacks
function handleUlTag(tag as string, value as Object, indent as string)
    print "function handleUlTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleOlTag(tag as string, value as Object, indent as string)
    print "function andleOlTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleLiTag(tag as string, value as Object, indent as string)
    print "function handleLiTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleDlTag(tag as string, value as Object, indent as string)
    print "function handleDlTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleDtTag(tag as string, value as Object, indent as string)
    print "function handleDtTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleDdTag(tag as string, value as Object, indent as string)
    print "function handleDdTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleTheadTag(tag as string, value as Object, indent as string)
    print "function handleTheadTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleTbodyTag(tag as string, value as Object, indent as string)
    print "function handleTbodyTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleTfootTag(tag as string, value as Object, indent as string)
    print "function handleTfootTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleTrTag(tag as string, value as Object, indent as string)
    print "function handleTrTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Group")
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleThTag(tag as string, value as Object, indent as string)
    print "function handleThTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "BoldFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleTdTag(tag as string, value as Object, indent as string)
    print "function handleTdTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

' Form Tags Callbacks
function handleInputTag(tag as string, value as Object, indent as string)
    print "function handleInputTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleButtonTag(tag as string, value as Object, indent as string)
   ' print "function handleButtonTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleSelectTag(tag as string, value as Object, indent as string)
    print "function handleSelectTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleTextareaTag(tag as string, value as Object, indent as string)
    print "function handleTextareaTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

' Heading Tags Callbacks
function handleH1Tag(tag as string, value as Object, indent as string)
    print "function handleH1Tag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "HeaderFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleH2Tag(tag as string, value as Object, indent as string)
    print "function handleH2Tag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    node.font = "SubHeaderFont"
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleH3Tag(tag as string, value as Object, indent as string)
    print "function handleH3Tag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleH4Tag(tag as string, value as Object, indent as string)
    print "function handleH4Tag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleH5Tag(tag as string, value as Object, indent as string)
    print "function handleH5Tag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

function handleH6Tag(tag as string, value as Object, indent as string)
    print "function handleH6Tag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function

' Head Tags Callbacks
function handleMetaTag(tag as string, value as Object, indent as string)
    print "function handleMetaTag(tag as string, value as Object, indent as string)"
    ' No direct SceneGraph equivalent for meta tags, could be used for metadata processing
end function

' Function to handle script tags
function handleScriptData(Data as Object, m as Object, verbose as Boolean, parent as String)
    print "function handleScriptTag(tag as Object, m as Object, verbose as Boolean)"    
    script = getContent(m, Data, Data, "script")
    readScript(script, parent)
end function

' Function to handle style tags
function handleStyleData(Data as Object, m as Object, verbose as Boolean) as Object
    print "function handleStyleData(Data as Object, m as Object, verbose as Boolean)"
    content = getContent(m, Data, Data, "style")
    contJSON = convertJSON(m, "css", content)

    if isString(contJSON)
        print "isString(contJSON) : " ; contJSON
    else if isDataStructure(contJSON)
        print "isDataStructure(contJSON)"
    end if

    return contJSON
end function


function handleTitleTag(tag as string, value as Object, indent as string)
   ' print "function handleTitleTag(tag as string, value as Object, indent as string)"
    node = createObject("roSGNode", "Label")
    node.text = value
    handleGlobalAttributes(node, value, indent)
    m.contentContainer.appendChild(node)
end function
