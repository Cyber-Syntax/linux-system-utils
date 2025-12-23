//
// This script was created for superproductivity but would be work for most of the typescript projects that use i18n JSON files.
// 
// This script updates all language translation files (i18n JSON files) in the project.
// It ensures that every language file has all the keys present in the English file (en.json),
// and keeps the same order of keys as in en.json. Existing translations are preserved.
//
// This script is written in JavaScript (Node.js). If you know Python, think of this as a script
// that reads and writes JSON files, similar to using the 'json' and 'os' modules in Python.
// 
// Folder structure: tools/add_missing_i18n_variables.js
// Usage: node tools/add_missing_i18n_variables.js
//
// Example: If en.json has {"A": 1, "B": 2} and tr.json has {"A": 10},
// after running this script, tr.json will become {"A": 10, "B": 2}.

// Import the built-in 'fs' (filesystem) and 'path' modules from Node.js.
// 'fs' is like Python's 'open', 'read', 'write', etc.
// 'path' is like Python's 'os.path' for handling file paths.
const fs = require('fs');
const path = require('path');


// __dirname is a special variable in Node.js that gives the directory of the current script file.
// path.resolve joins paths and makes an absolute path.
// This finds the i18n directory relative to this script.
const i18nDir = path.resolve(__dirname, '../src/assets/i18n');

// This is the path to the English translation file, which is our reference.
const enPath = path.join(i18nDir, 'en.json');


// This function merges two objects (dictionaries), keeping the order and structure of the first (enObj).
// It fills in missing keys in langObj with values from enObj, but keeps any existing translations in langObj.
// This is recursive, so it works for nested objects (like nested dictionaries in Python).
//
// Example:
// enObj = {"A": 1, "B": {"C": 2}}
// langObj = {"A": 10}
// Result: {"A": 10, "B": {"C": 2}}
function mergeInOrder(enObj, langObj) {
  // If enObj is not an object (could be a string, number, etc.), just return langObj.
  if (typeof enObj !== 'object' || enObj === null) return langObj;

  // If enObj is an array, make result an array; otherwise, make it an object.
  // (Most translation files use objects, not arrays.)
  const result = Array.isArray(enObj) ? [] : {};

  // Loop through each key in enObj (like for key in enObj in Python)
  for (const key of Object.keys(enObj)) {
    // If the value is a nested object (not null, not an array), recurse.
    if (
      typeof enObj[key] === 'object' &&
      enObj[key] !== null &&
      !Array.isArray(enObj[key])
    ) {
      // If langObj has this key, use it; otherwise, use an empty object.
      result[key] = mergeInOrder(enObj[key], langObj && langObj[key] ? langObj[key] : {});
    } else {
      // If langObj has this key, use its value (the translation), otherwise use the English value.
      result[key] = langObj && key in langObj ? langObj[key] : enObj[key];
    }
  }
  return result;
}


// Check if the English file exists. If not, print an error and exit.
if (!fs.existsSync(enPath)) {
  console.error('en.json not found in src/assets/i18n/');
  process.exit(1);
}

// Check if the i18n directory exists. If not, print an error and exit.
if (!fs.existsSync(i18nDir)) {
  console.error('i18n directory not found at src/assets/i18n/');
  process.exit(1);
}


// Read the English reference file (en.json) and parse it as a JavaScript object.
// This is like: with open('en.json') as f: en = json.load(f) in Python.
const en = JSON.parse(fs.readFileSync(enPath, 'utf8'));

// Get all files in the i18n directory that end with .json, except for en.json.
// This is like: [f for f in os.listdir(i18nDir) if f.endswith('.json') and f != 'en.json'] in Python.
const i18nFiles = fs
  .readdirSync(i18nDir)
  .filter((file) => file.endsWith('.json') && file !== 'en.json')
  .sort(); // Sort alphabetically for consistency

// Print out which files will be updated.
console.log(`Found ${i18nFiles.length} language files to update:`);
console.log(i18nFiles.map((file) => `  - ${file}`).join('\n'));
console.log('');


// These counters keep track of how many files were updated and how many had errors.
let updatedFiles = 0;
let errors = 0;


// Loop through each language file (other than English)
for (const file of i18nFiles) {
  // Get the full path to the language file
  const langPath = path.join(i18nDir, file);
  // Get the language code (e.g., 'tr' from 'tr.json')
  const langCode = file.replace('.json', '');

  try {
    // Read the language file if it exists, otherwise use an empty object.
    // This is like: langObj = json.load(open(langPath)) if exists else {}
    let langObj = {};
    if (fs.existsSync(langPath)) {
      const content = fs.readFileSync(langPath, 'utf8');
      if (content.trim()) {
        langObj = JSON.parse(content);
      }
    }

    // Merge the English structure with the language file, preserving existing translations.
    // This fills in any missing keys with English values.
    const merged = mergeInOrder(en, langObj);

    // Write the updated object back to the language file, formatted with 2 spaces for readability.
    // This is like: json.dump(merged, open(langPath, 'w'), indent=2) in Python.
    fs.writeFileSync(langPath, JSON.stringify(merged, null, 2), 'utf8');

    // Print a success message for this file.
    console.log(`✓ Updated ${file}`);
    updatedFiles++;
  } catch (error) {
    // If there was an error (e.g., invalid JSON), print an error message.
    console.error(`✗ Error processing ${file}:`, error.message);
    errors++;
  }
}


// Print a summary of what happened.
console.log('');
console.log(`Summary:`);
console.log(`  - Updated files: ${updatedFiles}`);
console.log(`  - Errors: ${errors}`);
console.log(`  - Total files processed: ${i18nFiles.length}`);

if (errors === 0) {
  console.log('');
  console.log(
    'All language files updated successfully with missing keys in the same order as en.json.'
  );
} else {
  console.log('');
  console.log('Some files had errors. Please check the output above.');
  process.exit(1);
}
