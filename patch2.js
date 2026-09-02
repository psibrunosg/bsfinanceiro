const fs = require('fs');
let c = fs.readFileSync('src/app/AccountsPage.tsx', 'utf8');
c = c.replace(/    \} catch \(err: any\) \{\n      setMessage\("Erro ao adicionar conta: " \+ err\.message\);\n    \}\n  \}\n\n  return \(/, '    } catch (err: any) {\n      setMessage("Erro ao adicionar conta: " + err.message);\n    }\n  }\n\n  return (');
c = c.replace(/  \}  await reload\(\);\n  \}/, '  }');
fs.writeFileSync('src/app/AccountsPage.tsx', c, 'utf8');

let s = fs.readFileSync('src/app/SettingsPage.tsx', 'utf8');
s = s.replace(/value=\{\\\\/g, 'value={${window.location.origin}');
s = s.replace(/token=\\\\\\}/g, 'token=}');
s = s.replace(/writeText\(\\\\/g, 'writeText(${window.location.origin}');
s = s.replace(/token=\\\\\)/g, 'token=)');
fs.writeFileSync('src/app/SettingsPage.tsx', s, 'utf8');
