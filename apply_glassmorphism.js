const fs = require('fs');

let globals = fs.readFileSync('src/app/globals.css', 'utf8');
let app = fs.readFileSync('src/app/app.css', 'utf8');

// 1. Force globals.css to use Dark Premium Base
const rootRegex = /:root\{[\s\S]*?\}/;
const darkRootRegex = /:root\[data-theme="dark"\]\{[\s\S]*?\}/;
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

globals = globals.replace(rootRegex, newRoot);
globals = globals.replace(darkRootRegex, '');

// Update nav brand
globals = globals.replace('.nav-brand span{display:grid;place-items:center;width:38px;height:38px;border-radius:11px;background:var(--primary);color:var(--bg);font-size:.8rem}', '.nav-brand span { display: grid; place-items: center; width: 38px; height: 38px; border-radius: 11px; background: linear-gradient(135deg, #10B981, #059669); color: #ffffff; font-size: .8rem; }');

// Update menu items
globals = globals.replace('.app-nav nav a,.nav-bottom button{min-height:46px;border:0;border-radius:10px;padding:0 12px;display:flex;align-items:center;gap:12px;background:transparent;color:var(--muted);font-weight:600;text-decoration:none;text-align:left}', '.app-nav nav a, .nav-bottom button { min-height: 46px; border: 0; border-radius: 12px; padding: 12px 16px; display: flex; align-items: center; gap: 12px; background: transparent; color: #94A3B8; font-weight: 600; text-decoration: none; text-align: left; transition: all 0.2s; cursor: pointer; }');
globals = globals.replace('.app-nav nav a:hover,.app-nav nav a.active,.nav-bottom button:hover{background:var(--surface-2);color:var(--primary)}', '.app-nav nav a:hover, .nav-bottom button:hover { background-color: rgba(255, 255, 255, 0.05); color: #FFFFFF; } .app-nav nav a.active { background-color: rgba(16, 185, 129, 0.1); color: #10B981; }');

fs.writeFileSync('src/app/globals.css', globals);

// 2. Update metric-card to look like dynamicCard
app = app.replace('.metric-card {\n  background: var(--surface);', '.metric-card {\n  background: linear-gradient(135deg, #3B82F6 0%, #2563EB 100%);\n  border-radius: 24px;\n  padding: 24px;\n  color: #FFFFFF;\n  position: relative;\n  overflow: hidden;\n  box-shadow: 0 10px 30px rgba(0,0,0,0.2);\n  display: flex;\n  flex-direction: column;');
app = app.replace('.metric-card--positive {\n  color: var(--positive);\n}', '.metric-card--positive {\n  background: linear-gradient(135deg, #059669 0%, #10B981 100%);\n  color: #fff;\n  border: none;\n}\n.metric-card--positive .muted {\n  color: rgba(255,255,255,0.9);\n}');
app = app.replace('.metric-card strong {\n  font-size: 1.5rem;\n  line-height: 1;\n}', '.metric-card strong {\n  font-family: Lexend, sans-serif;\n  font-size: 2.5rem;\n  font-weight: 700;\n  margin: 0;\n  order: 3;\n  line-height: 1;\n}');
app = app.replace('.metric-card .muted {\n  font-size: 0.85rem;\n}', '.metric-card .muted {\n  font-size: 0.9rem;\n  opacity: 0.9;\n  text-transform: uppercase;\n  letter-spacing: 0.05em;\n  font-weight: 600;\n  margin-bottom: 8px;\n  order: 2;\n  color: inherit;\n}');
app = app.replace('.metric-card svg {\n  width: 24px;\n  height: 24px;\n  margin-bottom: 8px;\n}', '.metric-card svg {\n  position: absolute;\n  top: 24px;\n  right: 24px;\n  opacity: 0.2;\n  width: 80px;\n  height: 80px;\n  margin: 0;\n}');

// 3. Update dashboard-card to look like glassCard
app = app.replace('.dashboard-card {\n  background: var(--surface);', '.dashboard-card {\n  background: rgba(255, 255, 255, 0.03);\n  backdrop-filter: blur(12px);\n  -webkit-backdrop-filter: blur(12px);\n  border: 1px solid rgba(255, 255, 255, 0.08);\n  border-radius: 24px;\n  padding: 24px;\n  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);');

// 4. Update row hovers for list/account-row
app = app.replace('.account-row {\n  background: var(--surface);', '.account-row {\n  background: rgba(255, 255, 255, 0.03);\n  backdrop-filter: blur(12px);\n  -webkit-backdrop-filter: blur(12px);\n  border-radius: 24px;\n  border: 1px solid rgba(255, 255, 255, 0.08);');

fs.writeFileSync('src/app/app.css', app);

let nav = fs.readFileSync('src/app/components/Nav.tsx', 'utf8');
nav = nav.replace('Moon, ', '').replace('Sun, ', '');
nav = nav.replace('const { preference, updateThemePreference } = useThemePreference();\n  const nextTheme = preference === "dark" ? "light" : "dark";', '');
nav = nav.replace('<button aria-label="Alternar tema" onClick={() => void updateThemePreference(nextTheme)}>\n          {preference === "dark" ? <Sun aria-hidden="true" /> : <Moon aria-hidden="true" />}\n          <span>Tema</span>\n        </button>', '');
fs.writeFileSync('src/app/components/Nav.tsx', nav);
console.log('Done!');
