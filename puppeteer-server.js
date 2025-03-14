/**
 * server.js
 *
 * Demonstrates:
 * - Storing CSS in `attributes.style.inline`, `attributes.style.block`, `attributes.style.external`
 * - Preserving your "versioning and instancing" logic for classes/tokens
 * - Handling a naive approach to "descendant selectors" like `.sc-classic .userDialogBadge`.
 */

import express from 'express';
import puppeteer from 'puppeteer';
import fs from 'fs';
import path from 'path';
import axios from 'axios';
import { fileURLToPath } from 'url';
import { JSDOM } from 'jsdom';
import os from 'os';
import cors from 'cors';
import postcss from 'postcss';
import { createRequire } from 'module';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const require = createRequire(import.meta.url);
const normalizePath = require.resolve('normalize.css/normalize.css');
const normalizeCSS = fs.readFileSync(normalizePath, 'utf8');

class MidStack {
  constructor(content) {
    this.content = content;
    this.cType = '';
  }
  setContent(content) { this.content = content; }
  getContent() { return this.content; }
  setcType(cType) { this.cType = cType; }
  getcType() { return this.cType; }
}

class CINFO {
  constructor(x, y, width, height) {
    this.cInfo = { x, y, width, height };
  }
  setContent(cInfo) { this.cInfo = cInfo; }
  getContent() { return this.cInfo; }
  setPosition(x, y) { this.cInfo.x = x; this.cInfo.y = y; }
  setSize(width, height) { this.cInfo.width = width; this.cInfo.height = height; }
  getPosition() { return { x: this.cInfo.x, y: this.cInfo.y }; }
  getSize() { return { width: this.cInfo.width, height: this.cInfo.height }; }
}

class Server {
  constructor() {
    console.log('constructor()');
    this.app = express();
    this.stack = new MidStack('Initial Content');
    this.client = new CINFO(1280, 720, 1280, 720); // Ensure client has nonzero dimensions
    this.totalCount = 0

    this.setupMiddleware();
    this.setupRoutes();
  }

  setupMiddleware() {
    console.log('setupMiddleware()');
    this.app.use(cors());
    this.app.use(express.json());

    // Minimal logger
    this.app.use((req, res, next) => {
      next();
    });

    // Serve static from /images & /tmp
    this.app.use(
      '/images',
      express.static(path.join(__dirname, 'images'), {
        setHeaders: (res, filePath) => {
          if (filePath.endsWith('.jpg')) {
            res.set('Content-Type', 'image/jpeg');
          }
        }
      })
    );

    this.app.use('/tmp', express.static(path.join(__dirname, 'tmp')));
  }

  setupRoutes() {
    console.log('setupRoutes()');
    this.app.get('/', (req, res) => res.send('Hello World'));
    this.app.get('/fetch-merge', this.fetchAndMerge.bind(this));
    this.app.get('/fetch-count', this.fetchTotalCount.bind(this));
  }

  start(ip, port) {
    this.ip = ip || this.getIPAddress();
    this.port = port || 3000;
    
    // Write the JSON configuration to pkg/source/conf.txt
    const confPath = path.join(__dirname, 'source', 'conf.txt');
    const confData = { ip: this.ip, port: this.port };
    try {
      fs.writeFileSync(confPath, JSON.stringify(confData, null, 2), 'utf8');
      console.log(`IP and port saved as JSON to ${confPath}`);
    } catch (err) {
      console.error(`Error saving conf.txt: ${err.message}`);
    }
    
    this.app.listen(this.port, this.ip, () => {
      console.log(`✅ Server running on http://${this.ip}:${this.port}`);
    });
  }
  
  

  getIPAddress() {
    console.log('getIPAddress()');
    const interfaces = os.networkInterfaces();
    const wifiInterfaceNames = ['Wi-Fi', 'WLAN', 'Wireless Network Connection'];
    let wifiIPAddress = '127.0.0.1';
    let found = false;

    for (const iface in interfaces) {
      if (wifiInterfaceNames.includes(iface)) {
        for (const alias of interfaces[iface]) {
          if (alias.family === 'IPv4' && !alias.internal) {
            wifiIPAddress = alias.address;
            found = true;
            break;
          }
        }
      }
      if (found) break;
    }
    if (!found) {
      for (const iface in interfaces) {
        for (const alias of interfaces[iface]) {
          if (alias.family === 'IPv4' && !alias.internal) {
            wifiIPAddress = alias.address;
            break;
          }
        }
      }
    }
    return wifiIPAddress;
  }

  traceFamily(key, index, updated) {
    // Get the array of occurrences for the given key
    const arr = updated[key];
    if (!arr || !arr[index]) return [];

    // Start with the current occurrence
    const occ = arr[index];
    const branch = [];
    branch.push({ key: key, occ: occ });

    // Begin walking up the parent's chain
    let parent = occ.family;
    while (parent && parent.parents && parent.parents.length > 0) {
      const firstParent = parent.parents[0];
      const parentKey = firstParent.parentKey;
      const parentIndex = firstParent.parentIndex;
      const parentArr = updated[parentKey];
      if (!parentArr) break;
      const parentOcc = parentArr[parentIndex];
      if (!parentOcc) break;
      branch.push({ key: parentKey, occ: parentOcc });
      parent = parentOcc.family;
    }
    return branch;
  }

  traceDownFamily(key, index, updated) {
    const arr = updated[key];
    if (!arr || !arr[index]) return [];
    const occ = arr[index];
    const branch = [];
    branch.push({ key, occ });
    let children = occ.family.children;
    while (children && children.length > 0) {
      const firstChild = children[0];
      const childKey = firstChild.childKey;
      const childIndex = firstChild.childIndex;
      const childArr = updated[childKey];
      if (!childArr) break;
      const childOcc = childArr[childIndex];
      if (!childOcc) break;
      branch.push({ key: childKey, occ: childOcc });
      children = childOcc.family.children;
    }
    return branch;
  }

  async getRootNodes(updated) {
    const roots = [];
    for (const key in updated) {
      const occurrences = Array.isArray(updated[key]) ? updated[key] : [updated[key]];
      occurrences.forEach(occ => {
        if (!occ.family || !occ.family.parents || occ.family.parents.length === 0) {
          roots.push({ key, occ });
        }
      });
    }
    return roots;
  }

  async cascade(inputJSON) {
    const updated = JSON.parse(JSON.stringify(inputJSON));
    const roots = await this.getRootNodes(updated);
    const outputDir = path.join(__dirname, 'output');
    if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

    fs.writeFileSync(
      path.join(outputDir, 'rootNodes.json'),
      JSON.stringify(roots, null, 2),
      'utf8'
    );
   // console.log("✅ Root nodes saved to rootNodes.json!");
    const keys = Object.keys(updated);
   // console.log("Top-level keys:", keys);

    function mergeStyles(base, override) {
      return { ...base, ...override };
    }

    function compareSpecificity(spec1, spec2) {
      for (let i = 0; i < 4; i++) {
        if (spec1[i] !== spec2[i]) return spec1[i] - spec2[i];
      }
      return 0;
    }

    function cascadeStylesForElement(element, parentComputed = {}, parentSpec = {}) {
      let style = element.superClass.elementInfo.attributes.style;
      if (!style) {
        style = { inline: {}, block: {}, external: {}, default: {} };
        element.superClass.elementInfo.attributes.style = style;
      } else {
        if (!style.inline) style.inline = {};
        if (!style.block) style.block = {};
        if (!style.external) style.external = {};
        if (!style.default) style.default = {};
      }
      let computed = { ...parentComputed };
      let computedSpec = { ...parentSpec };

      const external = style.external || {};
      const externalSpec = [0, 0, 0, 1];
      for (let prop in external) {
        if (
          !computed.hasOwnProperty(prop) ||
          compareSpecificity(externalSpec, computedSpec[prop] || [0, 0, 0, 0]) > 0
        ) {
          computed[prop] = external[prop];
          computedSpec[prop] = externalSpec;
        }
      }

      const block = style.block || {};
      const blockSpec = [0, 0, 1, 0];
      for (let prop in block) {
        if (
          !computed.hasOwnProperty(prop) ||
          compareSpecificity(blockSpec, computedSpec[prop] || [0, 0, 0, 0]) > 0
        ) {
          computed[prop] = block[prop];
          computedSpec[prop] = blockSpec;
        }
      }

      const inline = style.inline || {};
      const inlineSpec = [1, 0, 0, 0];
      for (let prop in inline) {
        if (
          !computed.hasOwnProperty(prop) ||
          compareSpecificity(inlineSpec, computedSpec[prop] || [0, 0, 0, 0]) >= 0
        ) {
          computed[prop] = inline[prop];
          computedSpec[prop] = inlineSpec;
        }
      }
      style.default = computed;
      style.computedSpec = computedSpec;
      return computed;
    }

    function cascadeRecursive(node, parentComputed = {}, parentSpec = {}) {
      const computed = cascadeStylesForElement(node.occ, parentComputed, parentSpec);
      //console.log("Cascading node:", node.key, "computed style:", computed);
      const children = node.occ.family.children || [];
      children.forEach(childRef => {
        const childArr = updated[childRef.childKey];
        if (!childArr) return;
        const childOcc = childArr[childRef.childIndex];
        if (!childOcc) return;
        const childNode = { key: childRef.childKey, occ: childOcc };
        cascadeRecursive(childNode, computed, node.occ.superClass.elementInfo.attributes.style.computedSpec);
      });
    }

    roots.forEach(rootNode => {
      cascadeRecursive(rootNode, {}, {});
    });

    fs.writeFileSync(
      path.join(outputDir, 'cascade.json'),
      JSON.stringify(updated, null, 2),
      'utf8'
    );
    console.log("✅ Cascaded styles saved to cascade.json!");
    return updated;
  }


  /**
 * Recursively adjusts the height of each target child element within a container.
 *
 * @param {Object} node - The current node in your JSON structure.
 * @param {Object} jsonStructure - The full JSON structure (mapping keys to occurrence arrays).
 * @param {Object} clientInfo - The client dimensions, e.g. { width: 1280, height: 720 }.
 * @param {Array<string>} targetTags - An array of tag names (lowercase) that need proportional height.
 */
  applyHeightProportions(node, jsonStructure, clientInfo, targetTags, tagCounts)
  {
  
  
      const total = tagCounts.body + tagCounts.header + tagCounts.main + tagCounts.footer;
      
      if(node.height)
      {
          console.log("AHP | CI: ", clientInfo.height);
          node.height = clientInfo.height/total;
          console.log(clientInfo.height,"/",total," = ", node.height);
          console.log("AHP | NODE: ", node.height);
      }
  
      
  }

/**
 * Recursively counts descendant nodes that match the provided targetTags.
 * (Assumes each node has a family.children array and that each occurrence’s
 *  tag name is stored in occ.superClass.elementInfo.tagName.)
 *
 * @param {Object} node - A node occurrence.
 * @param {Object} jsonStructure - The full JSON structure.
 * @param {Array<string>} targetTags - Array of lowercase tag names to count.
 * @returns {number} Count of descendant nodes matching targetTags.
 */
countTags(node, jsonStructure, targetTags) {
  let count = 0;
  if (node.family && node.family.children) {
    node.family.children.forEach(childRef => {
      const childArr = jsonStructure[childRef.childKey];
      if (childArr) {
        // In case the value is an array
        const childNode = Array.isArray(childArr)
          ? childArr[childRef.childIndex]
          : childArr;
        if (childNode) {
          const childTag = childNode.superClass.elementInfo.tagName.toLowerCase();
          if (targetTags.includes(childTag)) {
            count++;
          }
          count += countTags(childNode, jsonStructure, targetTags);
        }
      }
    });
  }
  return count;
}

/**
 * Recursively counts all occurrences at the top level.
 * Here we simply iterate over all keys and sum the number of occurrences.
 *
 * @param {Object} jsonStructure - The JSON representation.
 * @param {Array<string>} [targetTags] - Optional array of tags to filter.
 * @returns {Object} An object with { total, class } counts.
 */
countAllTags(jsonStructure, targetTags) {
  let totalCount = 0;
  let classCount = 0;
  const keys = Object.keys(jsonStructure);
  keys.forEach(key => {
    const versions = Array.isArray(jsonStructure[key])
      ? jsonStructure[key]
      : [jsonStructure[key]];
    totalCount += versions.length;
    // If targetTags are provided, count only those versions whose tag is in targetTags.
    if (targetTags && targetTags.length > 0) {
      const tag = versions[0].superClass.elementInfo.tagName.toLowerCase();
      if (targetTags.includes(tag)) {
        classCount += versions.length;
      }
    } else {
      // Otherwise count every occurrence as part of the "class" count.
      classCount += versions.length;
    }
  });
  return { total: totalCount, class: classCount };
}

/**
 * Extracts the total counts of nodes.
 * If allEntries is true, then every occurrence in the top-level JSON is counted
 * (using countAllTags); otherwise, we traverse only container nodes (body, header, main, footer)
 * and for each we count descendants that match targetTags (using countTags).
 *
 * @param {Object} jsonStructure - The JSON representation.
 * @param {Array<string>} targetTags - Array of tag names (lowercase) to count.
 * @param {Boolean} allEntries - If true, count every occurrence.
 * @returns {Object} An object like { total: number, class: number }.
 */
extractTagCounts(jsonStructure, targetTags, renderables) {
  const tags = this.countAllTags(jsonStructure, targetTags);
  
  const total = tags.total 
  const renderable = tags.class 

  if (renderables) {
    return { total: total, class: renderable }; 
  } 
  else return total
  
}


  computeDefaultFontSize(clientInfo) {
    // For example, 3% of the client height
    const size = Math.round(clientInfo.height * 0.03);
    return size;
  }
  
  computeBoxModel(clientInfo) {
    // Get the default font size as a number.
    const fontSize = this.computeDefaultFontSize(clientInfo);
    // Define your margins, padding, etc. (in pixels)
    const margin = 0;
    const padding = 0;
    const top = 0;
    // The computed height can be defined as the sum of these values.
    const computedHeight = margin + fontSize + padding + top;
    
    return {
      margin: "0",
      padding: "0",
      top: "0",
      left: "0",
      width: String(clientInfo.width),
      height: String(computedHeight),
      "font-size": fontSize 
    };
  }

  
  cssMap() {
    return {
      BoxModel: [
        "margin", "margin-top", "margin-right", "margin-bottom", "margin-left",
        "margin-block", "margin-block-end", "margin-block-start",
        "margin-inline", "margin-inline-end", "margin-inline-start",
        "padding", "padding-top", "padding-right", "padding-bottom", "padding-left",
        "padding-block", "padding-block-end", "padding-block-start",
        "padding-inline", "padding-inline-end", "padding-inline-start",
        "border", "border-width", "border-style", "border-color",
        "border-top", "border-top-color", "border-top-style", "border-top-width",
        "border-right", "border-right-color", "border-right-style", "border-right-width",
        "border-bottom", "border-bottom-color", "border-bottom-style", "border-bottom-width",
        "border-left", "border-left-color", "border-left-style", "border-left-width",
        "border-radius", "border-top-left-radius", "border-top-right-radius",
        "border-bottom-left-radius", "border-bottom-right-radius",
        "box-sizing"
      ],
      Layout: [
        "display", "position", "top", "right", "bottom", "left",
        "float", "clear", "z-index",
        "inset", "inset-block", "inset-block-end", "inset-block-start",
        "inset-inline", "inset-inline-end", "inset-inline-start",
        "flex", "flex-basis", "flex-direction", "flex-flow", "flex-grow", "flex-shrink", "flex-wrap",
        "align-items", "align-content", "align-self",
        "grid", "grid-area", "grid-auto-columns", "grid-auto-flow", "grid-auto-rows",
        "grid-column", "grid-column-end", "grid-column-start",
        "grid-row", "grid-row-end", "grid-row-start",
        "grid-template", "grid-template-areas", "grid-template-columns", "grid-template-rows",
        "gap", "row-gap", "column-gap"
      ],
      Typography: [
        "font", "font-family", "font-feature-settings", "font-kerning",
        "font-language-override", "font-size", "font-size-adjust", "font-stretch",
        "font-style", "font-synthesis", "font-variant", "font-variant-alternates",
        "font-variant-caps", "font-variant-east-asian", "font-variant-ligatures",
        "font-variant-numeric", "font-variant-position", "font-weight",
        "line-height", "letter-spacing", "text-align", "text-align-last",
        "text-decoration", "text-decoration-color", "text-decoration-line",
        "text-decoration-style", "text-decoration-thickness", "text-emphasis",
        "text-emphasis-color", "text-emphasis-position", "text-emphasis-style",
        "text-indent", "text-justify", "text-overflow", "text-shadow",
        "text-transform", "text-underline-offset", "text-underline-position",
        "white-space", "word-break", "word-spacing", "word-wrap"
      ],
      Visual: [
        "background", "background-attachment", "background-blend-mode",
        "background-clip", "background-color", "background-image", "background-origin",
        "background-position", "background-position-x", "background-position-y",
        "background-repeat", "background-size",
        "box-shadow", "filter", "opacity",
        "transform", "transform-origin", "transform-style",
        "perspective", "perspective-origin",
        "mix-blend-mode",
        "clip", "clip-path"
      ],
      Animations: [
        "animation", "animation-delay", "animation-direction", "animation-duration",
        "animation-fill-mode", "animation-iteration-count", "animation-name",
        "animation-play-state", "animation-timing-function",
        "transition", "transition-delay", "transition-duration",
        "transition-property", "transition-timing-function",
        "@keyframes"
      ],
      Miscellaneous: [
        "accent-color", "all", "backdrop-filter", "backface-visibility",
        "clip-path", "cursor", "direction", "empty-cells", "image-rendering",
        "@charset", "@import", "initial-letter", "@font-face", "@font-palette-values",
        "@counter-style", "@namespace", "@property", "@supports", "@layer", "@container",
        "counter-increment", "counter-reset", "counter-set", "quotes", "resize",
        "user-select", "visibility", "overflow", "overflow-anchor", "overflow-wrap",
        "overflow-x", "overflow-y", "overscroll-behavior", "overscroll-behavior-block",
        "overscroll-behavior-inline", "overscroll-behavior-x", "overscroll-behavior-y",
        "scroll-behavior", "scroll-margin", "scroll-margin-block", "scroll-margin-block-end",
        "scroll-margin-block-start", "scroll-margin-bottom", "scroll-margin-inline",
        "scroll-margin-inline-end", "scroll-margin-inline-start", "scroll-margin-left",
        "scroll-margin-right", "scroll-margin-top", "scroll-padding", "scroll-padding-block",
        "scroll-padding-block-end", "scroll-padding-block-start", "scroll-padding-bottom",
        "scroll-padding-inline", "scroll-padding-inline-end", "scroll-padding-inline-start",
        "scroll-padding-left", "scroll-padding-right", "scroll-padding-top", "scroll-snap-align",
        "scroll-snap-stop", "scroll-snap-type", "scrollbar-color", "shape-outside",
        "tab-size", "table-layout", "text-combine-upright", "text-orientation",
        "rotate", "scale", "translate", "unicode-bidi", "vertical-align", "widows",
        "writing-mode", "z-index", "zoom"
      ]
    };
  }

  
  getUserAgents(clientInfo) {
    // Compute a default font size for html/body.
    const defaultFontSize = this.computeDefaultFontSize(clientInfo);
    // Compute a box model template for non-html/body tags.
    const boxModel = this.computeBoxModel(clientInfo);
  
    return {
      "*": {
        "box-sizing": "border-box",
        margin: "0",
        padding: "0"
      },
      html: {
        "line-height": "1.15",
        "-webkit-text-size-adjust": "100",
        top: "0",
        left: "0",
        width: String(clientInfo.width),
        height: String(clientInfo.height),
        "font-size": defaultFontSize + "px"
      },
      body: {
        margin: "0",
        padding: "0",
        top: "0",
        left: "0",
        width: String(clientInfo.width),
        height: String(clientInfo.height),
        "font-size": defaultFontSize + "px"
      },
      // Common elements using the box model defaults:
      div: { ...boxModel },
      section: { ...boxModel },
      article: { ...boxModel },
      header: { ...boxModel },
      footer: { ...boxModel },
      nav: { ...boxModel },
      aside: { ...boxModel },
      main: { ...boxModel },
      span: { ...boxModel },
      p: { ...boxModel },
      ul: { ...boxModel },
      ol: { ...boxModel },
      li: { ...boxModel },
      // Additional elements:
      h1: { ...boxModel, "font-size": (defaultFontSize * 2) + "px" },
      h2: { ...boxModel, "font-size": (defaultFontSize * 1.75) + "px" },
      h3: { ...boxModel, "font-size": (defaultFontSize * 1.5) + "px" },
      h4: { ...boxModel, "font-size": (defaultFontSize * 1.25) + "px" },
      h5: { ...boxModel, "font-size": (defaultFontSize * 1) + "px" },
      h6: { ...boxModel, "font-size": (defaultFontSize * 0.875) + "px" },
      form: { ...boxModel },
      input: { ...boxModel },
      button: { ...boxModel },
      select: { ...boxModel },
      textarea: { ...boxModel },
      label: { ...boxModel },
      a: { ...boxModel },
      table: { ...boxModel },
      thead: { ...boxModel },
      tbody: { ...boxModel },
      tfoot: { ...boxModel },
      tr: { ...boxModel },
      th: { ...boxModel },
      td: { ...boxModel },
      img: { ...boxModel },
      video: { ...boxModel },
      audio: { ...boxModel },
      canvas: { ...boxModel },
      figure: { ...boxModel },
      figcaption: { ...boxModel },
      blockquote: { ...boxModel },
      pre: { ...boxModel },
      code: { ...boxModel }
      // Add any other elements as needed.
    };
  }

  
  // ================= End New: Boundaries Computation =================

  /**
   * Applies our custom user-agent defaults (including box model defaults and explicit
   * layout bounds for Roku) to every element, based on the element’s tag name.
   * If a tag does not have a specific default defined, it uses the universal defaults ("*").
   * 
   * All dimensions are provided as numeric strings (without "px") for Roku TV.
   * 
   * This function also ensures that every tag that must have explicit bounds (x, y, width, height)
   * gets them, using fallback values if not provided.
   * 
   * The computed defaults are stored in:
   *    occ.superClass.elementInfo.attributes.style.default
   * while leaving occ.superClass.elementInfo.attributes.style.inline,
   * occ.superClass.elementInfo.attributes.style.external, and
   * occ.superClass.elementInfo.attributes.style.block intact.
   *
   * @param {Object} htmlJSON - The JSON representation of the HTML.
   * @param {Object} clientInfo - The client info from CINFO (e.g. { width: 1280, height: 720 }).
   * @returns {Object} The updated htmlJSON with defaults merged into each element's style.default.
   */



  async applyUserAgentDefaults(htmlJSON, clientInfo) {

    const targetTags = ["head","div", "section", "article", "header", "footer", "nav", "aside", "main", "span", "p"];
    //const tagCounts = this.extractTagCounts(htmlJSON, targetTags);
   // console.log("Counts of target tags in containers:", tagCounts);

   // const headerCount = tagCounts.header;
    
  //  const bodyCount = tagCounts.body;
  //  const mainCount = tagCounts.main;
  //  const footerCount = tagCounts.footer;

  //  const totalCount =  bodyCount + mainCount + footerCount;

    const defaults = this.getUserAgents(clientInfo);
    const agentKeys = Object.keys(defaults);

    console.log("Defaults: ", defaults);
    

    const tagsRequiringBounds = [
      "html", "body", "div", "section", "article", "header", "footer", "nav", "aside", "main",
      "span", "p", "h1", "h2", "h3", "h4", "h5", "h6",
      "form", "input", "button", "select", "textarea", "label", "a",
      "table", "thead", "tbody", "tfoot", "tr", "th", "td",
      "img", "video", "audio", "canvas",
      "figure", "figcaption", "blockquote", "pre", "code",
      "iframe", "fieldset"
    ];

    var y_offset = 0;
    
    for(const key in htmlJSON) {

      const occArray = Array.isArray(htmlJSON[key]) ? htmlJSON[key] : [htmlJSON[key]];
      let index = 0
      for (const occ of occArray) 
        {
            const tag = occ.superClass.elementInfo.tagName.toLowerCase();
            const keyname = occ.keyName;

            console.log("ENTER | AUAD | KEY : ", key);
            
            if(occ.superClass)
            {
                const superClass = occ.superClass;
                //   console.log("occ.superClass === valid");
                    if(occ.superClass.elementInfo)
                    {
                      const elementInfo = superClass.elementInfo
                //     console.log("occ.superClass.elementInfo === valid");
                            if(occ.superClass.elementInfo.tagName)
                            {
                              const tagName = elementInfo.tagName
                            // console.log("occ.superClass.elementInfo.tagName === valid"); 

                                if (tagsRequiringBounds.includes(tagName))
                                {
                                    console.log("AUAD | TRUE | TAG: ", tagName);
                                    let boundaries; 

                                    if(occ.boundaries)
                                    {
                                        boundaries = occ.boundaries    
                                        console.log("AUAD | TRUE | BOUNDARIES: ", tag);
                                    }
                                    else
                                    {
                                        console.log("AUAD | FALSE | BOUNDARIES: ", tag);    
                                    }
        
                                    if(occ.superClass.elementInfo.attributes)
                                    {       
                                            const attributes = elementInfo.attributes;

                                            console.log("occ.superClass.elementInfo.attributes === valid");

                                            if(occ.superClass.elementInfo.attributes.style)
                                            {   
                                                const style = attributes.style;

                                              //  if(style["background-image"])
                                               // {
                                                //  console.log("FOUND BACKGROUND IMAGE", style["background-image"]);
                                                 // await this.download_Image(style["background-image"]);
                                               // }
                                                

                                                console.log("occ.superClass.elementInfo.attributes.style === valid");
                                                if(occ.superClass.elementInfo.attributes.style.default)
                                                {
                                                    console.log("occ.superClass.elementInfo.attributes.style.default === valid");
                                                }
                                                else
                                                {
                                                    occ.superClass.elementInfo.attributes.style.default = {};
                                                    console.log("occ.superClass.elementInfo.attributes.style.default !== valid");   

                                                    if(agentKeys.includes(occ.superClass.elementInfo.tagName))
                                                    {
                                                        console.log("1 | AGENT KEYS INCLUDES: ", occ.superClass.elementInfo.tagName);   
                                                        console.log("1 | AGENT KEYS Default: ", defaults[occ.superClass.elementInfo.tagName]);

                                                        console.log("2 | AGENT KEYS Default: ", defaults[occ.superClass.elementInfo.tagName]);
                                                        occ.superClass.elementInfo.attributes.style.default = { ...defaults[occ.superClass.elementInfo.tagName] };
                                                       // occ.superClass.elementInfo.attributes.style.default.top = y_offset.toString();
        
        
                                                        if(occ.superClass.elementInfo.tagName !== "body" && occ.superClass.elementInfo.tagName !== "html")
                                                        {
                                                           
                                                            console.log("occ.superClass.elementInfo.tagName !== body && occ.superClass.elementInfo.tagName !== html");
            
                                                            if(agentKeys.includes(occ.superClass.elementInfo.tagName))
                                                            {
                                                                console.log("agentKeys.includes(occ.superClass.elementInfo.tagName)");
                                                                console.log("2 | AGENT KEYS INCLUDES: Tag : ", occ.superClass.elementInfo.tagName," | KeyName : ", keyname); 
                                                              
                                                                console.log("1 | Y_OFFSET: ", y_offset , " + ", 
                                                                    defaults[occ.superClass.elementInfo.tagName].height   , " = ", parseInt(y_offset) + parseInt(defaults[occ.superClass.elementInfo.tagName].height));
        
                                                                 y_offset = parseInt(y_offset) + parseInt(defaults[occ.superClass.elementInfo.tagName].height, 10)
        
                                                                 const y = y_offset.toString();
                                                                 
                                                                 occ.superClass.elementInfo.attributes.style.default.top = y;
                                                                
                                                                console.log("2 | Y_OFFSET: ", y_offset , " + ", 
                                                                    occ.superClass.elementInfo.attributes.style.default.top   , " = ", parseInt(y_offset) + parseInt(occ.superClass.elementInfo.attributes.style.default.height));
                                                                
                                                                console.log("AGENT KEYS ATTRIBUTES: ", occ.superClass.elementInfo.attributes);
                                                                if(key === "app") {console.log("HTMLJSON | DEFAULT : " , JSON.stringify(htmlJSON[key], null, 2));}
                                                                
                                                            }
                                                            else 
                                                            {
                                                                console.log("AGENT KEYS DOES NOT INCLUDE: ", occ.superClass.elementInfo.tagName);
                                                            }
                    
                                                        }
                                                       
                                                    }
                                                    else 
                                                    {
                                                        console.log("AGENT KEYS DOES NOT INCLUDE: ", occ.superClass.elementInfo.tagName);
                                                    }

                                                }
                                            }
                                            else
                                            {
                                                occ.superClass.elementInfo.attributes.style = 
                                                {
                                                    inline: {},
                                                    block: {},
                                                    external: {},
                                                    default: {}
                                                };

                                                
  
                                                console.log("2 | AGENT KEYS Default: ", defaults[occ.superClass.elementInfo.tagName]);
                                                occ.superClass.elementInfo.attributes.style.default = { ...defaults[occ.superClass.elementInfo.tagName] };
                                               // occ.superClass.elementInfo.attributes.style.default.top = y_offset.toString();

                                                if(occ.superClass.elementInfo.tagName !== "body" && occ.superClass.elementInfo.tagName !== "html")
                                                {
                                                   
                                                    console.log("occ.superClass.elementInfo.tagName !== body && occ.superClass.elementInfo.tagName !== html");
    
                                                    if(agentKeys.includes(occ.superClass.elementInfo.tagName))
                                                    {
                                                        console.log("agentKeys.includes(occ.superClass.elementInfo.tagName)");
                                                        console.log("2 | AGENT KEYS INCLUDES: Tag : ", occ.superClass.elementInfo.tagName," | KeyName : ", keyname); 
                                                      
                                                        console.log("1 | Y_OFFSET: ", y_offset , " + ", 
                                                            defaults[occ.superClass.elementInfo.tagName].height   , " = ", parseInt(y_offset) + parseInt(defaults[occ.superClass.elementInfo.tagName].height));

                                                         y_offset = parseInt(y_offset) + parseInt(defaults[occ.superClass.elementInfo.tagName].height, 10)

                                                         const y = y_offset.toString();
                                                         
                                                         occ.superClass.elementInfo.attributes.style.default.top = y;
                                                        
                                                        console.log("2 | Y_OFFSET: ", y_offset , " + ", 
                                                            occ.superClass.elementInfo.attributes.style.default.top   , " = ", parseInt(y_offset) + parseInt(occ.superClass.elementInfo.attributes.style.default.height));
                                                        
                                                        console.log("AGENT KEYS ATTRIBUTES: ", occ.superClass.elementInfo.attributes);
                                                        if(key === "app") {console.log("HTMLJSON | DEFAULT : " , JSON.stringify(htmlJSON[key], null, 2));}
                                                        
                                                    }
                                                    else 
                                                    {
                                                        console.log("AGENT KEYS DOES NOT INCLUDE: ", occ.superClass.elementInfo.tagName);
                                                    }
            
                                                }
                                               
                                               
                                            }
                                        }
                                        else
                                        {
                                          console.log("occ.superClass.elementInfo.attributes !== valid");
                                        }

                                } 
                                else
                                {
                                    console.log("AUAD | FALSE | TAG: ", occ.superClass.elementInfo.tagName);
                                }
                                
                            }
                            else
                            {
                            //   console.log("occ.superClass.elementInfo.tagName === valid");
                            }
                            
                        

                    }   
                    else 
                    {
                //   console.log("occ.superClass.elementInfo !== valid");
                    }
            
            }
            else
            {
                // console.log("occ.superClass !== valid");
            }

           // const node = htmlJSON[key];
           // if(node[index].superClass.elementInfo.attributes.style && node[index].superClass.elementInfo.attributes.style.default)
           // {
           //     const node_style = node[0].superClass.elementInfo.attributes.style.default
           //     console.log("1 | NODE-STYLE: ", JSON.stringify(node_style, null, 2));    
           // }
            index++;
       };

    }

    return htmlJSON;
  }

  
  
  async extractScArtwork(htmlJSON) {
    console.log('extractScArtwork(htmlJSON)');
    const instances = htmlJSON.instances || htmlJSON;
    const scArtworkElements = {};
    for (const key of Object.keys(instances)) {
      if (key.includes('sc-artwork')) {
        scArtworkElements[key] = instances[key];
      }
    }
    const scArtworkCSS = {};
    for (const key of Object.keys(instances)) {
      const occurrences = Array.isArray(instances[key]) ? instances[key] : [];
      for (const occ of occurrences) {
        if (occ.superClass && occ.superClass.cssContent) {
          for (const [className, rules] of Object.entries(occ.superClass.cssContent)) {
            if (className.includes('sc-artwork')) {
              scArtworkCSS[className] = rules;
            }
          }
        }
      }
    }
    const result = {
      elements: scArtworkElements,
      cssRules: scArtworkCSS,
      metadata: {
        extractedAt: new Date().toISOString(),
        totalScArtworkElements: Object.keys(scArtworkElements).length,
        totalScArtworkCSSRules: Object.keys(scArtworkCSS).length
      }
    };
    try {
      const outputDir = path.join(__dirname, 'output');
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir);
      }
      const outputPath = path.join(outputDir, 'sc-artwork.json');
      fs.writeFileSync(outputPath, JSON.stringify(result, null, 2), 'utf8');
      console.log(`✅ Successfully extracted ${result.metadata.totalScArtworkElements} sc-artwork elements to ${outputPath}`);
      return result;
    } catch (error) {
      console.error(`❌ Error writing sc-artwork.json: ${error.message}`);
      throw error;
    }
  }

      
  async getBase64Images(url) {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto(url);

    const base64Images = await page.evaluate(() => {
        const images = [];
        document.querySelectorAll('[style*="url(data:image"]').forEach(element => {
            const style = element.getAttribute('style');
            const match = style.match(/url\((data:image\/[a-zA-Z]+;base64,[^\)]+)\)/);
            if (match) {
                images.push(match[1]);
            }
        });
        return images;
    });

    await browser.close();
    return base64Images;
}



async saveBase64Image(base64Data) {
    const imageBuffer = Buffer.from(base64Data, 'base64');
    const imagesDir = path.join(__dirname, 'images');

    // Ensure the images directory exists
    if (!fs.existsSync(imagesDir)) {
        fs.mkdirSync(imagesDir);
    }

    // Increment the file count and use it as the filename
    this.fileCount++;
    const uniqueKey = `file_${this.fileCount}`;
    const imagePath = path.join(imagesDir, `${uniqueKey}.jpg`);

    // Log the image path for debugging
    console.log('Saving image to path:', imagePath);

    try {
        // Check if image is SVG
        if (base64Data.includes("svg")) {
            console.log("ENTER | IF | base64Data.includes(svg)");

            const svgContent = Buffer.from(base64Data.replace(/^data:image\/svg\+xml;base64,/, ''), 'base64').toString('utf-8');
            const svgWithDimensions = svgContent.includes('width') && svgContent.includes('height')
                ? svgContent
                : svgContent.replace('<svg', '<svg width="1000" height="1000"');
            const svgBuffer = Buffer.from(svgWithDimensions);

            // Log the SVG buffer for debugging
            console.log('SVG Buffer:', svgBuffer.toString());

            const pngBuffer = await svg2png(svgBuffer);

            // Log the PNG buffer size for debugging
            console.log('PNG Buffer Size:', pngBuffer.length);

            await sharp(pngBuffer).jpeg().toFile(imagePath);
            console.log('Image saved as JPEG:', imagePath);
            return 'SVG image saved as JPEG';
        } else {
            console.log("ENTER | ELSE | base64Data.includes(svg)");

            await sharp(imageBuffer).jpeg().toFile(imagePath);
            console.log('Image saved as JPEG:', imagePath);
            return 'Base64 image saved as JPEG';
        }
    } catch (err) {
        console.error('Error converting image to JPEG:', err);
        throw new Error('Error converting image to JPEG');
    }
}

async download_Image(imageUrl) {
  if (!imageUrl) {
      throw new Error('No URL provided');
  }

  function stripURL(Url) {
    // Check if the string contains "url(".
    let urlStart = Url.indexOf("url(");
    if (urlStart !== -1) {
      // Skip past "url(".
      urlStart += 4;
      // Find the closing parenthesis.
      let urlEnd = Url.indexOf(")", urlStart);
      if (urlEnd === -1) {
        urlEnd = Url.length;
      }
      // Extract the URL and trim whitespace.
      let extracted = Url.substring(urlStart, urlEnd);
      // Remove surrounding quotes if they exist.
      if (
        (extracted.startsWith('"') && extracted.endsWith('"')) ||
        (extracted.startsWith("'") && extracted.endsWith("'"))
      ) {
        extracted = extracted.substring(1, extracted.length - 1);
      }
      return extracted;
    } else {
      // If no "url(" is found, simply decode the whole string.
      return Url;
    }
  }

  // Decode URL and replace spaces with '+' signs.
  imageUrl = stripURL(imageUrl);

  console.log("Stripped URL : ", imageUrl);

  // Define the absolute path to the Images directory.
  const imagesDirectory = path.join(__dirname, 'Images');
  // Create the Images directory if it doesn't exist.
  if (!fs.existsSync(imagesDirectory)) {
      fs.mkdirSync(imagesDirectory);
  }

  // Case 1: The URL is base64 image data.
  if (imageUrl.startsWith('data:image')) {
      console.log('Processing base64 image data...');
      const base64Data = imageUrl.replace(/^data:image\/[a-zA-Z]+;base64,/, '');
      // Use a timestamp for a unique filename.
      const imagePath = path.join(imagesDirectory, 'image_' + Date.now() + '.jpg');
      fs.writeFileSync(imagePath, base64Data, 'base64');
      console.log('Image saved to:', imagePath);
      return imagePath;

  // Case 2: The URL is an HTTP/HTTPS link to an image.
  } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      console.log('Downloading image from URL...');
      // Use the basename of the URL (forcing a .jpg extension) for the filename.
      const imageName = path.basename(imageUrl).split('.')[0] + '.jpg';
      const imagePath = path.join(imagesDirectory, imageName);
      const writer = fs.createWriteStream(imagePath);

      try {
          const response = await axios({
              url: imageUrl,
              method: 'GET',
              responseType: 'stream'
          });
          response.data.pipe(writer);

          // Return a promise that resolves when the writing is finished.
          await new Promise((resolve, reject) => {
              writer.on('finish', resolve);
              writer.on('error', reject);
          });
          console.log('Image downloaded and saved as JPEG to:', imagePath);
          return imagePath;
      } catch (error) {
          console.error('Error downloading the image:', error.message);
          throw error;
      }

  // Case 3: The URL is assumed to be a webpage from which base64 images are extracted.
  } else {
      console.log('Assuming webpage URL, extracting base64 images...');
      const images = await getBase64Images(imageUrl);
      let savedImages = [];

      for (const base64Image of images) {
          const base64Data = base64Image.replace(/^data:image\/[a-zA-Z]+;base64,/, '');
          const imagePath = path.join(imagesDirectory, 'image_' + Date.now() + '.jpg');
          fs.writeFileSync(imagePath, base64Data, 'base64');
          console.log('Saved image:', imagePath);
          savedImages.push(imagePath);
      }
      return savedImages;
  }
}

async downloadImage(req, res) {
   

  const encodedImageUrl = req.query.url;
    if (!encodedImageUrl) {
        return res.status(400).send('No URL provided');
    }

    let imageUrl = decodeURI(encodedImageUrl);
    console.log("IMAGE URL : ", imageUrl);
    imageUrl = imageUrl.replace(/ /g, "+"); // Replace spaces with + signs

    if (imageUrl.startsWith('data:image')) {
        // Handle base64 image data directly
        console.log('DOWNLOAD | Image URL : ', imageUrl);

        // Extract the base64 key after "base64"
        const base64Key = imageUrl.split('base64,')[1]; // Using first 20 characters for uniqueness
        const base64Data = imageUrl.replace(/^data:image\/[a-zA-Z]+;base64,/, '');

        // Save the base64 image
        const message = await this.saveBase64Image(base64Data);
        res.status(200).send(message);
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        const imagePath = path.join(__dirname, 'images', path.basename(imageUrl).split('.')[0] + '.jpg'); // Save as .jpg
        const writer = fs.createWriteStream(imagePath);

        try {
            const response = await axios({
                url: imageUrl,
                method: 'GET',
                responseType: 'stream'
            });

            response.data.pipe(writer);

            writer.on('finish', () => {
                res.status(200).send('Image downloaded and saved as JPEG');
            });

            writer.on('error', () => {
                res.status(500).send('Error downloading the image');
            });
        } catch (error) {
            console.error('Error downloading the image:', error.message);
            res.status(500).send('Error downloading the image');
        }
    } else {
        // If neither base64 nor direct URL, assume it's a webpage URL and call getBase64Images
        const images = await this.getBase64Images(imageUrl);

        // Save each extracted base64 image
        for (const imageUrl of images) {
            const base64Key = imageUrl.split('base64,')[1].slice(0, 20); // Using first 20 characters for uniqueness
            const base64Data = imageUrl.replace(/^data:image\/[a-zA-Z]+;base64,/, '');
            const message = await this.saveBase64Image(base64Data);
            console.log(message); // Log the result of saving each image
        }

        res.status(200).send('All images saved as JPEG');
    }
}

  async fetchAndApplyCSS(htmlJSON) {
    const normalizeStyles = await this.loadNormalizeCSS();
   // console.log("✅ Normalize.css :: ", normalizeStyles);
    const updated = JSON.parse(JSON.stringify(htmlJSON));
    const cssPromises = [];
    const allOccurrences = [];
    for (const key of Object.keys(updated)) {
      const arr = Array.isArray(updated[key]) ? updated[key] : [updated[key]];
      for (const occ of arr) {
        allOccurrences.push({ key, occ });
      }
    }
    for (const { occ } of allOccurrences) {
      const attrs = occ.superClass?.elementInfo?.attributes || {};
      if (!attrs.style || typeof attrs.style !== 'object') {
        const inlineExisting =
          attrs.style && Object.keys(attrs.style).length > 0 ? attrs.style : {};
        attrs.style = {
          inline: inlineExisting,
          block: {},
          external: {}
        };
      } else {
        if (!('inline' in attrs.style)) {
          attrs.style = {
            inline: attrs.style,
            block: {},
            external: {}
          };
        } else {
          attrs.style.inline = attrs.style.inline || {};
          attrs.style.block = attrs.style.block || {};
          attrs.style.external = attrs.style.external || {};
        }
      }
      occ.superClass.elementInfo.attributes = attrs;
    }
    for (const { key, occ } of allOccurrences) {
      const tagName = occ.superClass?.elementInfo?.tagName;
      const attrs = occ.superClass?.elementInfo?.attributes || {};
      if (tagName === 'style' && typeof attrs.cssContent === 'string') {
        const parsedObj = await this.parseCSSWithPostCSS(attrs.cssContent);
        attrs.style.block = parsedObj;
        delete attrs.cssContent;
      //  console.log(`✅ <style> => style.block for key="${key}"`);
      } else if (typeof occ.superClass?.cssContent === 'string') {
        const parsedObj = await this.parseCSSWithPostCSS(occ.superClass.cssContent);
        attrs.style.block = parsedObj;
      //  delete occ.superClass.cssContent;
        console.log(`✅ superClass.cssContent => style.block for key="${key}"`);
      } else if (
        tagName === 'link' &&
        attrs.rel?.toLowerCase() === 'stylesheet' &&
        attrs.href
      ) {
        const href = attrs.href;
        cssPromises.push(
          axios
            .get(href)
            .then(async (response) => {
              const cssText = response.data || '';
              const parsedObj = await this.parseCSSWithPostCSS(cssText);
              this.distributeExternalRules(parsedObj, allOccurrences, updated);
            //  console.log(`✅ External CSS => distributed for href="${href}"`);
            })
            .catch(err => {
              console.error(`❌ Error fetching external CSS from ${href}:`, err);
            })
        );
      }
    }
    await Promise.all(cssPromises);
    return updated;
  }

  distributeExternalRules(parsedObj, allOccurrences, updated) {
    for (const selector of Object.keys(parsedObj)) {
      if (selector.startsWith('@media')) {
        continue;
      }
      const cssRules = parsedObj[selector];
      const segments = selector.split(/\s+/);
      for (const { occ } of allOccurrences) {
        if (this.matchDescendantSelector(segments, occ, updated)) {
          const attrs = occ.superClass.elementInfo.attributes;
          const styleObj = attrs.style;
          for (const prop in cssRules) {
            styleObj.external[prop] = cssRules[prop];
          }
        }
      }
    }
  }

  getAncestorOccurrences(occ, updated) {
    const results = [];
    const queue = [...(occ.family.parents || [])];
    while (queue.length > 0) {
      const parentLink = queue.shift();
      const parentArr = updated[parentLink.parentKey];
      if (!parentArr) continue;
      const parentOcc = parentArr[parentLink.parentIndex];
      if (parentOcc) {
        results.push(parentOcc);
        if (parentOcc.family && parentOcc.family.parents) {
          for (const grand of parentOcc.family.parents) {
            queue.push(grand);
          }
        }
      }
    }
    return results;
  }

  checkMultiClassSegment(segment, occ) {
    const neededTokens = segment
      .split('.')
      .map(s => s.trim())
      .filter(x => x.length > 0);
    if (neededTokens.length === 0) return false;
    const classesMap = occ.subclasses || {};
    for (let token of neededTokens) {
      if (!classesMap[token]) {
        return false;
      }
    }
    return true;
  }

  matchDescendantSelector(segments, occ, updated) {
    if (segments.length === 1) {
      return this.checkMultiClassSegment(segments[0], occ);
    }
    const lastSegment = segments[segments.length - 1];
    const earlierSegments = segments.slice(0, segments.length - 1);
    if (!this.checkMultiClassSegment(lastSegment, occ)) {
      return false;
    }
    const ancestors = this.getAncestorOccurrences(occ, updated);
    for (const seg of earlierSegments) {
      let foundOne = false;
      for (const anc of ancestors) {
        if (this.checkMultiClassSegment(seg, anc)) {
          foundOne = true;
          break;
        }
      }
      if (!foundOne) {
        return false;
      }
    }
    return true;
  }

  async htmlToJSON(htmlContent) {
    const result = {};
    const visitedElements = new Set();
    const superClassTracker = new Map();
    const globalSubClassTracker = new Map();
    const globalTokenMaxInstance = new Map();
    let globalOrder = 0;
    const dom = new JSDOM(htmlContent);
    const doc = dom.window.document;
  
    function getKeyAndType(element) {
      if (element.hasAttribute('class') && element.getAttribute('class').trim()) {
        return { key: element.getAttribute('class').trim(), type: 'class' };
      } else if (element.hasAttribute('id') && element.getAttribute('id').trim()) {
        return { key: element.getAttribute('id').trim(), type: 'id' };
      } else {
        // Instead of creating a unique key for each null element,
        // just use 'null' as the key
        return { key: 'null', type: 'null' };
      }
    }
  
    function getElementAttributes(element) {
      const attributes = {};
      const inlineStyles = {};
      for (let attr of element.attributes) {
        if (attr.name === 'style') {
          const styleObj = element.style;
          for (let i = 0; i < styleObj.length; i++) {
            const prop = styleObj[i];
            inlineStyles[prop] = styleObj.getPropertyValue(prop);
          }
        } else if (attr.name !== 'class' && attr.name !== 'id') {
          attributes[attr.name] = attr.value;
        }
      }
      if (Object.keys(inlineStyles).length > 0) {
        attributes.style = { ...inlineStyles };
      }
      if (element.tagName.toLowerCase() === 'style') {
       // attributes.cssContent = element.textContent.trim();
      }
      return attributes;
    }
  
    function getImmediateText(element) {
      let immediateText = "";
      element.childNodes.forEach(child => {
        if (child.nodeType === 3) { // Node.TEXT_NODE
          immediateText += child.textContent;
        }
      });
      return immediateText.trim();
    }
  
    function getTokenInstanceVersion(token, superClassKey, prevOccurrence) {
      let tokenMap = globalSubClassTracker.get(token);
      if (!tokenMap) {
        tokenMap = new Map();
        globalSubClassTracker.set(token, tokenMap);
      }
      let instance = tokenMap.get(superClassKey);
      if (!instance) {
        const oldMax = globalTokenMaxInstance.get(token) || 0;
        const newMax = oldMax + 1;
        globalTokenMaxInstance.set(token, newMax);
        instance = newMax;
        tokenMap.set(superClassKey, instance);
      }
      let prevVersion = 0;
      if (prevOccurrence && prevOccurrence.subclasses[token]) {
        prevVersion = prevOccurrence.subclasses[token].version;
      }
      const newVersion = prevVersion + 1;
      return [instance, newVersion];
    }
  
    function processElement(element, parentKey = null, parentIndex = -1, level = 0) {
      if (visitedElements.has(element)) return;
      visitedElements.add(element);
      const { key, type } = getKeyAndType(element);
      const attrs = getElementAttributes(element);
      const tagName = element.tagName.toLowerCase();
      const elementOrder = globalOrder++;
      const textContent = getImmediateText(element);
      
      if (!result[key]) {
        result[key] = [];
        superClassTracker.set(key, 0);
      }
      let currentVersion = superClassTracker.get(key) || 0;
      currentVersion++;
      superClassTracker.set(key, currentVersion);
      let prevOccurrence = null;
      if (result[key].length > 0) {
        prevOccurrence = result[key][result[key].length - 1];
      }
      let subClassesObj = {};
      if (type === 'class') {
        const tokens = key.split(/\s+/);
        tokens.forEach(token => {
          const [inst, ver] = getTokenInstanceVersion(token, key, prevOccurrence);
          subClassesObj[token] = { instance: inst, version: ver };
        });
      } else {
        const [inst, ver] = getTokenInstanceVersion(key, key, prevOccurrence);
        subClassesObj[key] = { instance: inst, version: ver };
      }
      
      const newOccurrence = {
        keyName: key,
        type,
        superClass: {
          version: currentVersion,
          superName: type === 'class' ? key : null,
          elementInfo: {
            tagName,
            attributes: attrs,
            level,
            order: elementOrder,
            text: textContent.length > 0 ? textContent : null
          }
        },
        family: {
          parents: [],
          children: []
        },
        subclasses: subClassesObj
      };
  
      const newIndex = result[key].push(newOccurrence) - 1;
      if (parentKey !== null && parentIndex >= 0) {
        const parentOcc = result[parentKey][parentIndex];
        if (parentOcc) {
          newOccurrence.family.parents.push({
            parentKey,
            parentIndex
          });
          parentOcc.family.children.push({
            childKey: key,
            childIndex: newIndex,
            childSubs: subClassesObj
          });
        }
      }
      Array.from(element.children).forEach(child => {
        processElement(child, key, newIndex, level + 1);
      });
    }
  
    const allElements = doc.querySelectorAll('*');
    allElements.forEach(elem => {
      const p = elem.parentElement;
      if (!p || (!p.hasAttribute('class') && !p.hasAttribute('id'))) {
        processElement(elem, null, -1, 0);
      }
    });
    return result;
  }

/*
  async htmlToJSON(htmlContent) {
    const result = {};
    const visitedElements = new Set();
    const superClassTracker = new Map();
    const globalSubClassTracker = new Map();
    const globalTokenMaxInstance = new Map();
    let nullCounter = 1;
    let globalOrder = 0;
    const dom = new JSDOM(htmlContent);
    const doc = dom.window.document;
    function getKeyAndType(element) {
      if (element.hasAttribute('class') && element.getAttribute('class').trim()) {
        return { key: element.getAttribute('class').trim(), type: 'class' };
      } else if (element.hasAttribute('id') && element.getAttribute('id').trim()) {
        return { key: element.getAttribute('id').trim(), type: 'id' };
      } else {
        const key = `null_${nullCounter++}`;
        return { key, type: 'null' };
      }
    }
    function getElementAttributes(element) {
      const attributes = {};
      const inlineStyles = {};
      for (let attr of element.attributes) {
        if (attr.name === 'style') {
          const styleObj = element.style;
          for (let i = 0; i < styleObj.length; i++) {
            const prop = styleObj[i];
            inlineStyles[prop] = styleObj.getPropertyValue(prop);
          }
        } else if (attr.name !== 'class' && attr.name !== 'id') {
          attributes[attr.name] = attr.value;
        }
      }
      if (Object.keys(inlineStyles).length > 0) {
        attributes.style = { ...inlineStyles };
      }
      if (element.tagName.toLowerCase() === 'style') {
        attributes.cssContent = element.textContent.trim();
      }
      return attributes;
    }
    function getTokenInstanceVersion(token, superClassKey, prevOccurrence) {
      let tokenMap = globalSubClassTracker.get(token);
      if (!tokenMap) {
        tokenMap = new Map();
        globalSubClassTracker.set(token, tokenMap);
      }
      let instance = tokenMap.get(superClassKey);
      if (!instance) {
        const oldMax = globalTokenMaxInstance.get(token) || 0;
        const newMax = oldMax + 1;
        globalTokenMaxInstance.set(token, newMax);
        instance = newMax;
        tokenMap.set(superClassKey, instance);
      }
      let prevVersion = 0;
      if (prevOccurrence && prevOccurrence.subclasses[token]) {
        prevVersion = prevOccurrence.subclasses[token].version;
      }
      const newVersion = prevVersion + 1;
      return [instance, newVersion];
    }
    function processElement(element, parentKey = null, parentIndex = -1, level = 0) {
      if (visitedElements.has(element)) return;
      visitedElements.add(element);
      const { key, type } = getKeyAndType(element);
      const attrs = getElementAttributes(element);
      const tagName = element.tagName.toLowerCase();
      const elementOrder = globalOrder++;
      if (!result[key]) {
        result[key] = [];
        superClassTracker.set(key, 0);
      }
      let currentVersion = superClassTracker.get(key) || 0;
      currentVersion++;
      superClassTracker.set(key, currentVersion);
      let prevOccurrence = null;
      if (result[key].length > 0) {
        prevOccurrence = result[key][result[key].length - 1];
      }
      let subClassesObj = {};
      if (type === 'class') {
        const tokens = key.split(/\s+/);
        tokens.forEach(token => {
          const [inst, ver] = getTokenInstanceVersion(token, key, prevOccurrence);
          subClassesObj[token] = { instance: inst, version: ver };
        });
      } else {
        const [inst, ver] = getTokenInstanceVersion(key, key, prevOccurrence);
        subClassesObj[key] = { instance: inst, version: ver };
      }
      const newOccurrence = {
        type,
        superClass: {
          version: currentVersion,
          superName: type === 'class' ? key : null,
          elementInfo: {
            tagName,
            attributes: attrs,
            level,
            order: elementOrder
          }
        },
        family: {
          parents: [],
          children: []
        },
        subclasses: subClassesObj
      };
      const newIndex = result[key].push(newOccurrence) - 1;
      if (parentKey !== null && parentIndex >= 0) {
        const parentOcc = result[parentKey][parentIndex];
        if (parentOcc) {
          newOccurrence.family.parents.push({
            parentKey,
            parentIndex
          });
          parentOcc.family.children.push({
            childKey: key,
            childIndex: newIndex,
            childSubs: subClassesObj
          });
        }
      }
      Array.from(element.children).forEach(child => {
        processElement(child, key, newIndex, level + 1);
      });
    }
    const allElements = doc.querySelectorAll('*');
    allElements.forEach(elem => {
      const p = elem.parentElement;
      if (!p || (!p.hasAttribute('class') && !p.hasAttribute('id'))) {
        processElement(elem, null, -1, 0);
      }
    });
    return result;
  }
*/
    // ================= New: Boundaries Computation =================
    computeBoundariesRecursive(node, parentContainer, clientInfo) {

        if(node.superClass)
        {
           // console.log("node.superClass === valid");
            
            if(node.superClass.elementInfo)
            {
              //  console.log("node.superClass.elementInfo === valid");
                if(node.superClass.elementInfo.attributes)
                {
                   // console.log("node.superClass.elementInfo.attributes === valid");
                    if(node.superClass.elementInfo.attributes.style)
                    {
                       // console.log("node.superClass.elementInfo.attributes.style === valid");
                        if(node.superClass.elementInfo.attributes.style.default)
                        {
                            node.superClass.elementInfo.attributes.style.default = {};
                          //  console.log("node.superClass.elementInfo.attributes.style.default === valid");
                        }
                        else
                        {
                          //  console.log("node.superClass.elementInfo.attributes.style.default !== valid");
                            
                        }
                    }
                    else
                    {
                     //   console.log("node.superClass.elementInfo.attributes.style !== valid");
                        node.superClass.elementInfo.attributes.style = {};
                    }
                }
                else
                {
                  //  console.log("node.superClass.elementInfo.attributes !== valid");
                }
            }   
            else 
            {
              //  console.log("node.superClass.elementInfo !== valid");
            }
    
        }
        else
        {
          //  console.log("node.superClass !== valid");
        }

        if(node.keyName)
        {
          //  console.log("CBR | TAG : ", node.keyName);

        }
        else
        {
          //  console.log("CBR | FALSE ");
        }
    
        const computed = node.superClass.elementInfo.attributes.style.default || {};
        const left = parseFloat(computed.left) || 0;
        const top = parseFloat(computed.top) || 0;
        const width = parseFloat(computed.width) || 0;
        const height = parseFloat(computed.height) || 0;
        const nodeBounds = {
          x: parentContainer.x + left,
          y: parentContainer.y + top,
          width: width,
          height: height
        };
        node.boundaries = { // parentContainer should not be container for this node
          container: { ...parentContainer }, // container: { parent.bounds }
          bounds: nodeBounds
        };
        const children = node.family && node.family.children ? node.family.children : [];
        children.forEach(childRef => {
          const childArr = this.jsonStructure[childRef.childKey];
          if (!childArr) return;
          const childNode = childArr[childRef.childIndex];
          if (!childNode) return;
          this.computeBoundariesRecursive(childNode, nodeBounds, clientInfo);
        });
      }
    
      applyBoundaries(json, clientInfo) {
        this.jsonStructure = json;
        for (const key in json) {
          const occArray = Array.isArray(json[key]) ? json[key] : [json[key]];
          occArray.forEach(node => {
            // For root nodes (including <html> and <body>), use client dimensions as the container.
            const clientBounds = { x: 0, y: 0, width: clientInfo.width, height: clientInfo.height };
            this.computeBoundariesRecursive(node, clientBounds, clientInfo);
          });
        }
        return json;
      }

      async fetchTotalCount(req, res) {
        try {
          // Send the totalCount as a string back to the client (BrightScript app)
          console.log("FETCH COUNT | THIS.TOTALCOUNT : ", this.totalCount);
          res.send(this.totalCount.toString());
          console.log("✅ Responded with totalCount: " + this.totalCount.toString());
        } catch (err) {
          console.error('❌ Error in fetchTotalCount:', err);
          res.status(500).send(`Error: ${err.message}`);
        }
      }
      

  async fetchAndMerge(req, res) {
    const url = req.query.url;
    if (!url) {
      return res.status(400).send('Missing ?url= parameter');
    }
    try {
      const outputDir = path.join(__dirname, 'output');
      if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

      const rawHTML = await this.fetchHTML(url);
      const htmlJSON = await this.htmlToJSON(rawHTML);
      const copyJSON = JSON.parse(JSON.stringify(htmlJSON));

      const targetTags = ["div", "section", "article", "header", "footer", "nav", "aside", "main", "span", "p"];
      const tagCounts = this.extractTagCounts(htmlJSON, targetTags, true);
      
      console.log("FETCHMERGED | Counts of target tags in containers:", tagCounts);

      const totalCount =  tagCounts;



      
      const userJSON = await this.applyUserAgentDefaults(copyJSON, this.client.getContent());

      

      // const finalJSON = this.applyBoundaries(userJSON, this.client.getContent());

      fs.writeFileSync(
        path.join(outputDir, 'agentContent.json'),
        JSON.stringify(userJSON, null, 2),
        'utf8'
      );

      
      const cssJSON = await this.fetchAndApplyCSS(userJSON);
      const nextJSON = JSON.parse(JSON.stringify(cssJSON));
      
      const cascadeJSON = await this.cascade(nextJSON);
      const scArtworkData = await this.extractScArtwork(cascadeJSON);
      // Apply boundaries so that each node has proper container and bounds.

      const testJSON = JSON.parse(JSON.stringify(userJSON));
      const seed = "sc-artwork  sc-artwork-placeholder-0  image__full g-opacity-transition";
      const famJSON = await this.traceFamily(seed, 0, cssJSON);

      fs.writeFileSync(
        path.join(outputDir, 'traceFamily.json'),
        JSON.stringify(famJSON, null, 2),
        'utf8'
      );
      fs.writeFileSync(
        path.join(outputDir, 'cascade.json'),
        JSON.stringify(userJSON, null, 2),
        'utf8'
      );
      fs.writeFileSync(
        path.join(outputDir, 'htmlContent.json'),
        JSON.stringify(htmlJSON, null, 2),
        'utf8'
      );
      fs.writeFileSync(
        path.join(outputDir, 'cssContent.json'),
        JSON.stringify(cssJSON, null, 2),
        'utf8'
      );
      fs.writeFileSync(
        path.join(outputDir, 'sc-artwork.json'),
        JSON.stringify(scArtworkData, null, 2),
        'utf8'
      );
      
      /*const outCOPY = JSON.stringify(userJSON, null, 2);
      const copyOUT = JSON.parse(outCOPY);

      console.log("Type copyOUT : ", typeof copyOUT);

      const copyKeys = Object.keys(copyOUT);

      console.log("copyKEYS : ", copyKeys)
      */
      
      this.totalCount = totalCount
      
      console.log("THIS.TOTALCOUNT : ", this.totalCount);

      console.log('✅ fetchAndMerge complete. Files saved.');
       res.send(JSON.stringify(userJSON, null, 2));
      // res.send(JSON.stringify({ count : totalCount, json : userJSON}), null, 2);
      console.log("✅ Responded to Client.");
      
    } catch (err) {
      console.error('❌ Error in fetchAndMerge:', err);
      res.status(500).send(`Error: ${err.message}`);
    }
  }

  async fetchHTML(url) {
    console.log('fetchHTML(url)', url);
    let browser;
    try {
      browser = await puppeteer.launch({ args: ['--no-sandbox', '--disable-setuid-sandbox'] });
      const page = await browser.newPage();
      await page.goto(url, { waitUntil: 'networkidle0' });
      return await page.content();
    } catch (error) {
      throw error;
    } finally {
      if (browser) await browser.close();
    }
  }

  async loadNormalizeCSS() {
    const require = createRequire(import.meta.url);
    const normalizePath = require.resolve('normalize.css/normalize.css');
    try {
      const cssText = fs.readFileSync(normalizePath, 'utf8');
      const normalizeStyles = await this.parseCSSWithPostCSS(cssText);
    //  console.log("✅ Normalize.css loaded and parsed successfully.");
      return normalizeStyles;
    } catch (error) {
      console.error("❌ Error loading Normalize.css:", error);
      return {};
    }
  }

  async parseCSSWithPostCSS(cssString) {
    const root = postcss.parse(cssString);
    const result = {};
    root.walkRules(rule => {
      if (rule.parent.type === 'atrule') return;
      this.addRuleToObject(result, rule);
    });
    root.walkAtRules(atRule => {
      if (atRule.name === 'media') {
        const mediaKey = `@media ${atRule.params}`;
        const mediaObj = {};
        atRule.walkRules(nestedRule => {
          this.addRuleToObject(mediaObj, nestedRule);
        });
        result[mediaKey] = mediaObj;
      }
    });
    return result;
  }

  addRuleToObject(targetObj, rule) {
    const { selectors } = rule;
    if (!selectors) return;
    const declObject = {};
    rule.walkDecls(decl => {
      declObject[decl.prop] = decl.value;
    });
    selectors.forEach(sel => {
      const norm = sel.trim();
      targetObj[norm] = { ...declObject };
    });
  }



}

function main() {
  console.log('function main()');
  const server = new Server();
  const ip = '';
  const port = 3000;
  server.start(ip, port);
}

main();
