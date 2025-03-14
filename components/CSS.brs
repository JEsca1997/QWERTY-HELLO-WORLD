'-------------------------------------------
' CSS.brs
'-------------------------------------------
function runCSS(url as string, m as Object)
    request = CreateObject("roUrlTransfer")
    request.SetUrl("http://192.168.1.150:3000/fetch-css?url=" + url)  ' Puppeteer server endpoint for CSS
  
    cssContent = request.GetToString()
  
    if cssContent = invalid or Len(cssContent) = 0
        print "Error: Failed to fetch CSS content from Puppeteer server"
        return "Invalid CSS content"
    else
        cssJSON = parseJSON(cssContent)
        if cssJSON = invalid
            print "Error parsing CSS JSON"
            return invalid
        end if
  
        ' Process the CSS JSON and apply the styles to HTML nodes
        processCSSJSON(cssJSON, m)
    end if
  end function
  
  function cssProperties() as Object 
      css_properties = [
      "animation-range-end",
      "animation-range-start",
      "animation-timeline",
      "appearance",
      "align-content",
      "align-items",
      "align-self",
      "all",
      "animation",
      "animation-delay",
      "animation-direction",
      "animation-duration",
      "animation-fill-mode",
      "animation-iteration-count",
      "animation-name",
      "animation-play-state",
      "animation-timing-function",
      "backface-visibility",
      "background",
      "background-attachment",
      "background-blend-mode",
      "background-clip",
      "background-color",
      "background-image",
      "background-origin",
      "background-position",
      "background-position-x",
      "background-position-y",
      "background-repeat",
      "background-size",
      "block-size",
      "border",
      "border-block",
      "border-block-color",
      "border-block-end",
      "border-block-end-color",
      "border-block-end-style",
      "border-block-end-width",
      "border-block-start",
      "border-block-start-color",
      "border-block-start-style",
      "border-block-start-width",
      "border-block-style",
      "border-block-width",
      "border-bottom",
      "border-bottom-color",
      "border-bottom-left-radius",
      "border-bottom-right-radius",
      "border-bottom-style",
      "border-bottom-width",
      "border-collapse",
      "border-color",
      "border-end-end-radius",
      "border-end-start-radius",
      "border-image",
      "border-image-outset",
      "border-image-repeat",
      "border-image-slice",
      "border-image-source",
      "border-image-width",
      "border-inline",
      "border-inline-color",
      "border-inline-end",
      "border-inline-end-color",
      "border-inline-end-style",
      "border-inline-end-width",
      "border-inline-start",
      "border-inline-start-color",
      "border-inline-start-style",
      "border-inline-start-width",
      "border-inline-style",
      "border-inline-width",
      "border-left",
      "border-left-color",
      "border-left-style",
      "border-left-width",
      "border-radius",
      "border-right",
      "border-right-color",
      "border-right-style",
      "border-right-width",
      "border-spacing",
      "border-start-end-radius",
      "border-start-start-radius",
      "border-style",
      "border-top",
      "border-top-color",
      "border-top-left-radius",
      "border-top-right-radius",
      "border-top-style",
      "border-top-width",
      "border-width",
      "bottom",
      "box-decoration-break",
      "box-shadow",
      "box-sizing",
      "break-after",
      "break-before",
      "break-inside",
      "caption-side",
      "caret-color",
      "clear",
      "clip",
      "clip-path",
      "color",
      "column-count",
      "column-fill",
      "column-gap",
      "column-rule",
      "column-rule-color",
      "column-rule-style",
      "column-rule-width",
      "column-span",
      "column-width",
      "columns",
      "--connected-color",
      "content",
      "counter-increment",
      "counter-reset",
      "cursor",
      "direction",
      "display",
      "--disconnected-color",
      "empty-cells",
      "font-variation-settings",
      "fill",
      "filter",
      "flex",
      "flex-basis",
      "flex-direction",
      "flex-flow",
      "flex-grow",
      "flex-shrink",
      "flex-wrap",
      "float",
      "font",
      "font-family",
      "font-feature-settings",
      "font-kerning",
      "font-language-override",
      "font-optical-sizing",
      "font-size",
      "font-size-adjust",
      "font-stretch",
      "font-style",
      "font-synthesis",
      "font-variant",
      "font-variant-alternates",
      "font-variant-caps",
      "font-variant-east-asian",
      "font-variant-ligatures",
      "font-variant-numeric",
      "font-variant-position",
      "font-variation-settings",
      "font-weight",
      "gap",
      "grid",
      "grid-area",
      "grid-auto-columns",
      "grid-auto-flow",
      "grid-auto-rows",
      "grid-column",
      "grid-column-end",
      "grid-column-gap",
      "grid-column-start",
      "grid-gap",
      "grid-row",
      "grid-row-end",
      "grid-row-gap",
      "grid-row-start",
      "grid-template",
      "grid-template-areas",
      "grid-template-columns",
      "grid-template-rows",
      "hanging-punctuation",
      "height",
      "hyphens",
      "image-orientation",
      "image-rendering",
      "image-resolution",
      "ime-mode",
      "inline-size",
      "inset",
      "inset-block",
      "inset-block-end",
      "inset-block-start",
      "inset-inline",
      "inset-inline-end",
      "inset-inline-start",
      "isolation",
      "justify-content",
      "justify-items",
      "justify-self",
      "left",
      "letter-spacing",
      "line-break",
      "line-height",
      "list-style",
      "list-style-image",
      "list-style-position",
      "list-style-type",
      "margin",
      "margin-block",
      "margin-block-end",
      "margin-block-start",
      "margin-bottom",
      "margin-inline",
      "margin-inline-end",
      "margin-inline-start",
      "margin-left",
      "margin-right",
      "margin-top",
      "mask",
      "mask-border",
      "mask-border-mode",
      "mask-border-outset",
      "mask-border-repeat",
      "mask-border-slice",
      "mask-border-source",
      "mask-border-width",
      "mask-clip",
      "mask-composite",
      "mask-image",
      "mask-mode",
      "mask-origin",
      "mask-position",
      "mask-repeat",
      "mask-size",
      "mask-type",
      "max-block-size",
      "max-height",
      "max-inline-size",
      "max-width",
      "min-block-size",
      "min-height",
      "min-inline-size",
      "min-width",
      "mix-blend-mode",
      "object-fit",
      "object-position",
      "offset",
      "offset-anchor",
      "offset-distance",
      "offset-path",
      "offset-position",
      "offset-rotate",
      "opacity",
      "order",
      "orphans",
      "outline",
      "outline-color",
      "outline-offset",
      "outline-style",
      "outline-width",
      "overflow",
      "overflow-anchor",
      "overflow-block",
      "overflow-clip-box",
      "overflow-inline",
      "overflow-wrap",
      "overflow-x",
      "overflow-y",
      "overscroll-behavior",
      "overscroll-behavior-block",
      "overscroll-behavior-inline",
      "overscroll-behavior-x",
      "overscroll-behavior-y",
      "padding",
      "padding-block",
      "padding-block-end",
      "padding-bottom",
      "padding-left",
      "padding-right",
      "padding-top",
      "position",
      "padding-bottom",
      "padding-left",
      "padding-right",
      "padding-top",
      "perspective-origin",
      "pointer-events",
      "pointer-events",
      "pointer-events",
      "right",
      "row-gap",
      "text-indent",
      "top",
      "transform",
      "transition-behavior",
      "transition-delay",
      "transition-duration",
      "transition-property",
      "transition-timing-function",
      "text-shadow",
      "text-align",
      "text-decoration-color",
      "text-decoration-line",
      "text-decoration-style",
      "text-decoration-thickness",
      "transform-origin",
      "text-overflow",
      "text-transform",
      "text-size-adjust",
      "text-wrap",
      "user-select"
      "vertical-align",
      "visibility",
      "-webkit-font-smoothing",
      "-webkit-border-horizontal-spacing",
      "-webkit-border-vertical-spacing",
      "white-space-collapse",
      "width",
      "word-break",
      "z-index"]
  
      return css_properties
  end function
  
  
  '-------------------------------------------
  ' Function to extract classes, IDs, and styles from the HTML content (including <style> tags)
  '-------------------------------------------
  function extractClassIDs(m as object) as object
    classIDMap = CreateObject("roAssociativeArray")
  
    if m.DoesExist("tags")
        tags = m["tags"]
  
        ' Iterate over each tag in m["tags"]
        for each tag in tags
            ' Check if the tag has "attributes"
            if tags[tag].DoesExist("attributes")
                attributes = tags[tag]["attributes"]
  
                ' Check if the tag has a class attribute
                if attributes.DoesExist("class")
                    classValue = attributes["class"]
                    classIDMap["class_" + classValue] = tag
                   ' print "Class : " + tag + " = " + classValue
                end if
  
                ' Check if the tag has an ID attribute
                if attributes.DoesExist("id")
                    idValue = attributes["id"]
                    classIDMap["id_" + idValue] = tag
                   ' print "ID: " + tag + " = " + idValue
                end if
            end if
  
            ' Check if the tag is a <style> tag and extract the CSS inside it
            if tags[tag].DoesExist("name") and tags[tag]["name"] = "style"
                embeddedCSS = tags[tag]["content"]
                ' Parse the embedded CSS
                if embeddedCSS <> invalid
                    parseEmbeddedCSS(embeddedCSS, classIDMap)  ' A helper function to parse and process the embedded CSS
                end if
            end if
        end for
    else
        print "No tags found in m."
    end if
  
    return classIDMap
  end function
  
  
  function prepCSS(m as Object, cssContent as Object)
      cssKeys = cssProperties()
      htmlkeys = m.htmlClasses
  
      for index = 0 to cssContent.Count() - 1
            Element = cssContent[index]
            properties = Element["properties"]
            selector = Element["selector"]
    
            if isString(selector)
                dlims = [" ", "#", ".", ","]
                selectors = parse(dlims, selector, [])
               ' for each select in selectors
                 'print " CSS | selector : " + select
               '  m.cssClasses.push(select)
                ' createAndAppendNode("css", {"selector": select, "properties":properties}, m)
               ' end for
  
              else 
  
            end if
    
        end for
  
  end function 
  
  function renderCSS(m as Object, cssContent as Object)
      
  
  end function 
  
  function parseEmbeddedCSS(cssContent as String, classIDMap as Object)
    ' Split the CSS content by rules (assume rules are separated by "}")
    cssRules = splitString(cssContent, "}")
  
    for each rule in cssRules
        if rule <> ""
            ' Further split each rule into the selector and properties
            ruleParts = splitString(rule, "{")
            if ruleParts.Count() = 2
                selector = trimString(ruleParts[0])
                properties = trimString(ruleParts[1])
                'print "Extracted embedded CSS | Selector: " + selector + " | Properties: " + properties
  
                ' Add the selector to the classIDMap for further processing
                classIDMap[selector] = properties
            end if
        end if
    end for
  end function
  
  
  '-------------------------------------------
  ' Function to check for missing selectors and attributes, and log them
  '-------------------------------------------
  function checkMissingSelectorsAndAttributes(selector as String, classIDMap as Object, cssSelectors as Object)
    ' Check for missing selector in classIDMap
    if Left(selector, 1) = "."  ' Class selector
        className = Mid(selector, 2)  ' Remove the leading "."
        if not classIDMap.DoesExist("class_" + className)
           ' print "Missing CSS Selector in HTML: " + selector
        end if
    else if Left(selector, 1) = "#"  ' ID selector
        idName = Mid(selector, 2)  ' Remove the leading "#"
        if not classIDMap.DoesExist("id_" + idName)
           ' print "Missing CSS Selector in HTML: " + selector
        end if
    end if
  
    ' Check for missing attributes from cssSelectors
    for each cssSelector in cssSelectors
        if not classIDMap.DoesExist(cssSelector)
           ' print "Missing CSS Selector in HTML: " + cssSelector
        end if
    end for
  end function
  
  
  '-------------------------------------------
  ' Process the parsed CSS JSON
  '-------------------------------------------
  function processCSSJSON(cssJSON as Object, m as Object)
    ' Extract class and ID mapping from the HTML content
    classIDMap = extractClassIDs(m)
  
    ' Create an array to store CSS selectors
    cssSelectors = CreateObject("roAssociativeArray")
  
    ' Iterate over CSS rules and apply them to corresponding HTML elements
    cssRules = cssJSON.cssRules
  
    for each rule in cssRules
        selector = rule.selector
        properties = rule.properties
  
        ' Check the type of properties before attempting to print
        if Type(properties) = "roAssociativeArray"
            for each key in properties
                value = properties[key]
            end for
        else if Type(properties) = "roArray" or Type(properties) = "roList"
            for i = 0 to properties.Count() - 1
                value = properties[i]
            end for
        else
          '  print "CSS | Selector: " + selector + " | Properties: " + convertToString(properties)
        end if
  
        ' Store the selector for later comparison
        cssSelectors[selector] = true
  
        ' Check if the selector matches a class or ID in the HTML
        if Left(selector, 1) = "."  ' Class selector
            className = Mid(selector, 2)  ' Remove the leading "."
            if classIDMap.DoesExist("class_" + className)
                tag = classIDMap["class_" + className]
                applyPropertiesToTag(tag, properties, m)
            else
                ' Call the function to log missing selectors
                checkMissingSelectorsAndAttributes(selector, classIDMap, cssSelectors)
            end if
        else if Left(selector, 1) = "#"  ' ID selector
            idName = Mid(selector, 2)  ' Remove the leading "#"
            if classIDMap.DoesExist("id_" + idName)
                tag = classIDMap["id_" + idName]
                applyPropertiesToTag(tag, properties, m)
            else
                ' Call the function to log missing selectors
                checkMissingSelectorsAndAttributes(selector, classIDMap, cssSelectors)
            end if
        end if
    end for
  
    ' Call checkMissingSelectorsAndAttributes one final time to catch any selectors that were missed
    checkMissingSelectorsAndAttributes("", classIDMap, cssSelectors)
  end function
  
  
  '-------------------------------------------
  ' Helper function to recursively convert different types to string for printing
  '-------------------------------------------
  function convertToString(value as Object) as String
    if Type(value) = "roAssociativeArray"
        result = "{"
        for each key in value.Keys()
            result += key + ": " + convertToString(value[key]) + ", "
        end for
        ' Remove the trailing comma and space
        result = Left(result, Len(result) - 2)
        result += "}"
        return result
    else if Type(value) = "roArray" or Type(value) = "roList"
        result = "["
        for i = 0 to value.Count() - 1
            result += convertToString(value[i]) + ", "
        end for
        ' Remove the trailing comma and space
        result = Left(result, Len(result) - 2)
        result += "]"
        return result
    else if isString(value)
        return value
    else if isInteger(value) or isDouble(value)
        return Str(value)
    else
        return "Unknown Type"
    end if
  end function
  
  '-------------------------------------------
  ' Function to apply CSS properties to an HTML tag
  '-------------------------------------------
  function applyPropertiesToTag(tag as String, properties as Object, m as Object)
    if m["tags"].DoesExist(tag)
        ' Ensure the tag has a "styles" object to store the applied CSS properties
        if not m["tags"][tag].DoesExist("styles")
            m["tags"][tag]["styles"] = CreateObject("roAssociativeArray")
        end if
  
        ' Apply each CSS property to the tag's "styles" object
        for each property in properties
            value = properties[property]
            m["tags"][tag]["styles"][property] = value
            ' print "Applied CSS: " + property + " = " + value + " to tag: " + tag
        end for
    else
        print "Tag " + tag + " not found in m."
    end if
  end function
  