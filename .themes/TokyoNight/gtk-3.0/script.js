const fs = require('fs');

// Step 1: Read the CSS file content
const cssFilePath = 'gtk-dark.css';
const cssContent = fs.readFileSync(cssFilePath, 'utf8');

// Step 2: Find all border-radius properties
const regex = /\bborder(?:-(?:top|bottom))?(?:-(?:left|right))?-radius\s*:\s*([^;"']*)/g;
let updatedCssContent = cssContent.replace(regex, 'border-radius: 0px');

// Step 4: Write the updated CSS content back to the file
fs.writeFileSync(cssFilePath, updatedCssContent, 'utf8');
