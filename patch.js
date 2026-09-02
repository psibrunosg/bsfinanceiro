const fs = require('fs');
let c = fs.readFileSync('src/app/AccountsPage.tsx', 'utf8');
c = c.replace(/    \} catch \(err: any\) \{\n      setMessage\("Erro ao adicionar conta: " \+ err\.message\);\n    \}\n  \}  await reload\(\);\n  \}/, '    } catch (err: any) {\n      setMessage("Erro ao adicionar conta: " + err.message);\n    }\n  }');
fs.writeFileSync('src/app/AccountsPage.tsx', c, 'utf8');
