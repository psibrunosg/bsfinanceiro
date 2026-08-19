const fs = require('fs');
let css = fs.readFileSync('src/app/globals.css', 'utf8');

const importStatement = "@import url('https://fonts.googleapis.com/css2?family=Lexend:wght@400;600;700&family=Source+Sans+3:wght@400;600;700&display=swap');\n\n";

if (!css.includes('@import')) {
  css = importStatement + css;
}

const rootRegex = /:root(\[data-theme="dark"\])?\s*\{[\s\S]*?\}/g;
const newRoot = `:root, :root[data-theme="dark"] {
  color-scheme: dark;
  --bg: #0B0E14;
  --surface: #11151F;
  --surface-2: rgba(255, 255, 255, 0.03);
  --text: #F8FAFC;
  --muted: #94A3B8;
  --border: rgba(255, 255, 255, 0.08);
  --primary: #10B981;
  --primary-2: #059669;
  --accent: #10B981;
  --accent-contrast: #FFFFFF;
  --positive: #10B981;
  --warning: #F59E0B;
  --danger: #EF4444;
  --gold: #F59E0B;
  --focus: #3B82F6;
  --shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  --radius: 24px;
  --sidebar: 260px;
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 24px;
  --space-6: 32px;
  --radius-sm: 12px;
  --radius-md: 16px;
  --tint: rgba(16, 185, 129, 0.1);
  --row-hover: rgba(255, 255, 255, 0.05);
}`;

css = css.replace(rootRegex, ''); // remove all roots
css = css.replace(importStatement, importStatement + newRoot + '\n\n'); // re-insert

fs.writeFileSync('src/app/globals.css', css);
console.log('globals.css updated');
