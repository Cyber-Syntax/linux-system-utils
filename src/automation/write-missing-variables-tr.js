/**
 * This script was created for superproductivity but would be work for most of the typescript projects that use i18n JSON files.
 * 
 * This script updates the Turkish translation file (tr.json) by adding any missing keys from the English file (en.json),
 * preserving the same key order and structure. It is designed for junior developers who know Python but are new to JavaScript.
 *
 * Key JavaScript concepts explained:
 * - `const` declares a variable whose value cannot be reassigned (like Python's `final` or a constant).
 * - `require('module')` imports a Node.js module (like Python's `import` statement).
 * - Functions are defined with the `function` keyword.
 * - Objects in JS are like Python dicts; arrays are like Python lists.
 * - `typeof` checks the type of a variable (like Python's `type()`).
 * - `process.exit(1)` stops the script with an error code (like `sys.exit(1)` in Python).
 * - `console.log()` prints to the terminal (like `print()` in Python).
 *
 * This script assumes you have en.json and tr.json in src/assets/i18n/ relative to this script's directory.
 */

// Import the built-in 'fs' (filesystem) and 'path' modules from Node.js
const fs = require('fs'); // For reading and writing files
const path = require('path'); // For handling file paths

// Get the absolute path to the i18n directory (where translation files are stored)
// __dirname is a special variable in Node.js that gives the directory of the current script
const i18nDir = path.resolve(__dirname, 'src/assets/i18n');

// Build the full paths to the English and Turkish JSON files
const enPath = path.join(i18nDir, 'en.json');
const trPath = path.join(i18nDir, 'tr.json');

/**
 * Recursively merges two objects (dictionaries), preserving the order of keys from the first object (enObj).
 * If a key is missing in trObj, it will be filled in from enObj.
 *
 * @param {object} enObj - The English object (source of truth for keys)
 * @param {object} trObj - The Turkish object (may be missing keys)
 * @returns {object} - The merged object with all keys from enObj, values from trObj if present, else from enObj
 */
function mergeInOrder(enObj, trObj) {
  // If enObj is not an object (could be a string, number, etc.), just return trObj
  if (typeof enObj !== 'object' || enObj === null) return trObj;

  // If enObj is an array, result will be an array; otherwise, an object
  const result = Array.isArray(enObj) ? [] : {};

  // Loop through each key in enObj (Object.keys() gets all keys in the object)
  for (const key of Object.keys(enObj)) {
    // If the value is a nested object (not null, not an array), recurse
    if (
      typeof enObj[key] === 'object' &&
      enObj[key] !== null &&
      !Array.isArray(enObj[key])
    ) {
      // Recursively merge nested objects
      result[key] = mergeInOrder(enObj[key], trObj[key] || {});
    } else {
      // If trObj has this key, use its value; otherwise, use enObj's value
      result[key] = (trObj && key in trObj) ? trObj[key] : enObj[key];
    }
  }
  return result;
}

// Check if both en.json and tr.json exist; if not, print an error and exit
if (!fs.existsSync(enPath) || !fs.existsSync(trPath)) {
  console.error('en.json or tr.json not found in src/assets/i18n/');
  process.exit(1);
}

// Read and parse the English and Turkish JSON files into JavaScript objects
// fs.readFileSync reads the file as a string; JSON.parse converts it to an object
const en = JSON.parse(fs.readFileSync(enPath, 'utf8'));
const tr = JSON.parse(fs.readFileSync(trPath, 'utf8'));

// Merge the objects, filling in missing keys in tr with values from en
const merged = mergeInOrder(en, tr);

// Write the merged object back to tr.json, formatted with 2 spaces for readability
fs.writeFileSync(trPath, JSON.stringify(merged, null, 2), 'utf8');

// Print a success message
console.log('tr.json updated with missing keys in the same order as en.json.');
