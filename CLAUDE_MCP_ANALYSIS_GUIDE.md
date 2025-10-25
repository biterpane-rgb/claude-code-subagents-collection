# 🔍 Claude Desktop & MCP Server Analyse - Anleitung

## ⚠️ Wichtiger Hinweis

Ich befinde mich in einer **Linux-Container-Umgebung** und habe **keinen Zugriff** auf Ihre Windows-Verzeichnisse:
- `C:\Users\neco.roknic\`
- `C:\Users\neco.roknic\AppData\Roaming\Claude`
- `C:\Users\neco.roknic.yourit\AppData\Roaming\Claude`
- `C:\Projekte`
- `C:\Python313`
- `C:\Python314`

## 📋 Lösung: Ausführbare Analyse-Scripts

Ich habe **zwei Scripts** erstellt, die Sie auf Ihrem Windows-System ausführen können:

### 1️⃣ PowerShell Script (Empfohlen)
**Datei**: `analyze-claude-mcp-windows.ps1`

**Features**:
- ✅ Umfassende Analyse aller Verzeichnisse
- ✅ Sucht nach Claude Desktop Konfigurationen
- ✅ Findet MCP Server (Node.js & Python)
- ✅ Prüft npm global packages
- ✅ Findet .env Dateien mit API-Keys (ohne Werte anzuzeigen)
- ✅ Analysiert package.json für MCP Dependencies

**Ausführung**:
```powershell
# 1. Öffnen Sie PowerShell als Administrator
# 2. Navigieren Sie zum Script:
cd C:\Pfad\zum\Script

# 3. Falls Execution Policy blockiert:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 4. Script ausführen:
.\analyze-claude-mcp-windows.ps1
```

### 2️⃣ Batch Script (Einfacher)
**Datei**: `analyze-claude-mcp-windows.bat`

**Features**:
- ✅ Einfache Analyse
- ✅ Keine Admin-Rechte nötig
- ✅ Funktioniert auf jedem Windows

**Ausführung**:
```batch
# Doppelklick auf die .bat Datei
# ODER in CMD:
analyze-claude-mcp-windows.bat
```

---

## 📂 Was wird gesucht?

### 1. **Claude Desktop Konfiguration**

**Typische Speicherorte**:
```
%APPDATA%\Claude\claude_desktop_config.json
C:\Users\<username>\AppData\Roaming\Claude\claude_desktop_config.json
```

**Beispiel-Konfiguration**:
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "C:\\Users\\Documents"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxx"
      }
    }
  }
}
```

### 2. **MCP Server Installationen**

#### A) **Node.js MCP Server**
**Suchen nach**:
```
node_modules/@modelcontextprotocol/
```

**Bekannte MCP Server Packages**:
- `@modelcontextprotocol/server-filesystem`
- `@modelcontextprotocol/server-github`
- `@modelcontextprotocol/server-postgres`
- `@modelcontextprotocol/server-brave-search`
- `@modelcontextprotocol/server-sqlite`
- `@modelcontextprotocol/server-gdrive`
- `@modelcontextprotocol/server-slack`
- `@modelcontextprotocol/server-puppeteer`
- `@modelcontextprotocol/server-git`

#### B) **Python MCP Server**
**Suchen nach**:
- Python Packages mit `mcp` im Namen
- MCP Server Python Scripts in `C:\Python313` oder `C:\Python314`

**Prüfen mit pip**:
```bash
python -m pip list | findstr mcp
```

#### C) **Custom MCP Server**
**Dateien suchen**:
- `*mcp*.json`
- `*mcp*.js`
- `*mcp*.ts`
- `*mcp*.py`
- `server.json`
- `mcp-config.json`

### 3. **Umgebungsvariablen & API Keys**

**Dateien**:
- `.env`
- `.env.local`
- `.env.development`

**Typische Variablen**:
```bash
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxx
ANTHROPIC_API_KEY=sk-ant-xxxxx
POSTGRES_CONNECTION_STRING=postgresql://...
BRAVE_API_KEY=BSA...
OPENAI_API_KEY=sk-...
```

---

## 🔧 Manuelle Suche (Falls Scripts nicht funktionieren)

### Schritt 1: Claude Desktop Config finden

1. **Öffnen Sie Windows Explorer**
2. **Geben Sie in die Adressleiste ein**:
   ```
   %APPDATA%\Claude
   ```
3. **Suchen Sie nach**: `claude_desktop_config.json`
4. **Öffnen mit**: Notepad oder VS Code

### Schritt 2: MCP Server in Projekten finden

**In CMD oder PowerShell**:
```batch
# Alle MCP-bezogenen JSON-Dateien finden:
dir C:\Projekte\*mcp*.json /s

# Node.js MCP Packages finden:
dir C:\Projekte\node_modules\@modelcontextprotocol /s /ad

# Python MCP Packages:
cd C:\Python313
python -m pip list | findstr mcp

cd C:\Python314
python -m pip list | findstr mcp
```

### Schritt 3: Global installierte MCP Server (npm)

**In CMD oder PowerShell**:
```bash
npm list -g --depth=0 | findstr modelcontextprotocol
```

### Schritt 4: Spezifische Verzeichnisse durchsuchen

**PowerShell (erweiterte Suche)**:
```powershell
# Alle MCP-bezogenen Dateien in allen User-Verzeichnissen:
Get-ChildItem -Path "C:\Users" -Filter "*mcp*" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName

# Alle claude_desktop_config.json Dateien:
Get-ChildItem -Path "C:\Users" -Filter "claude_desktop_config.json" -Recurse -ErrorAction SilentlyContinue | Select-Object FullName

# Alle package.json mit MCP Dependencies:
Get-ChildItem -Path "C:\Projekte" -Filter "package.json" -Recurse | Where-Object {
    (Get-Content $_.FullName -Raw) -match "modelcontextprotocol"
} | Select-Object FullName
```

---

## 📊 Erwartete Ergebnisse

### Beispiel Output (analyze-claude-mcp-windows.ps1):

```
=== Claude Desktop & MCP Server Analysis ===

Analyzing directories...

Checking: C:\Users\neco.roknic\AppData\Roaming\Claude
  [FOUND] claude_desktop_config.json
  [FOUND] MCP Server: server-github
  [FOUND] MCP Server: server-filesystem

Checking: C:\Projekte
  [FOUND] Node.js project with MCP at: C:\Projekte\my-mcp-project
  [FOUND] .env

Checking: C:\Python313
  [FOUND] Python: C:\Python313\python.exe
  [FOUND] MCP pip packages

=== Analysis Complete ===
Results saved to: C:\Users\neco.roknic\Desktop\claude-mcp-analysis.txt
```

---

## 🎯 Was tun mit den Ergebnissen?

### Nach der Analyse:

1. **Senden Sie mir die Ergebnisse**:
   - Öffnen Sie `claude-mcp-analysis.txt` vom Desktop
   - Kopieren Sie den relevanten Inhalt
   - Fügen Sie ihn in unseren Chat ein

2. **Ich kann dann analysieren**:
   - ✅ Welche MCP Server installiert sind
   - ✅ Wie Ihre Claude Desktop Konfiguration aussieht
   - ✅ Welche API-Keys konfiguriert sind (Namen, nicht Werte)
   - ✅ Ob es Probleme oder Optimierungsmöglichkeiten gibt

3. **Ich kann Ihnen helfen**:
   - 🔧 Konfiguration zu optimieren
   - 🆕 Neue MCP Server zu installieren
   - 🐛 Probleme zu beheben
   - 📚 Best Practices zu empfehlen

---

## 🔒 Sicherheitshinweis

**Die Scripts zeigen KEINE API-Keys oder Secrets an!**

Bei `.env` Dateien werden nur die **Variablennamen** angezeigt, z.B.:
```
GITHUB_PERSONAL_ACCESS_TOKEN=***
ANTHROPIC_API_KEY=***
```

**Trotzdem**: Prüfen Sie die Ausgabe vor dem Teilen!

---

## 📞 Support

Falls die Scripts nicht funktionieren oder Sie Fragen haben:

1. **Führen Sie die manuelle Suche durch** (siehe oben)
2. **Senden Sie mir**:
   - Welche Verzeichnisse existieren
   - Ob `claude_desktop_config.json` existiert und dessen Inhalt
   - Liste der gefundenen MCP-bezogenen Dateien
3. **Ich helfe weiter!**

---

## 📝 Nächste Schritte

1. ✅ Script herunterladen (analyze-claude-mcp-windows.ps1 oder .bat)
2. ✅ Script ausführen
3. ✅ Ergebnisse von Desktop öffnen
4. ✅ Relevante Teile hier posten
5. ✅ Ich analysiere und gebe Empfehlungen

---

**Viel Erfolg bei der Analyse!** 🚀

Bei Fragen stehe ich zur Verfügung!
