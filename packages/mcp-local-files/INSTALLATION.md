# Installation des MCP Local Files Servers

Diese Anleitung führt Sie durch die Installation und Konfiguration des MCP Local Files Servers für Claude Desktop.

## Schritt-für-Schritt Anleitung

### 1. Repository klonen (falls noch nicht geschehen)

```bash
git clone https://github.com/davepoon/claude-code-subagents-collection.git
cd claude-code-subagents-collection
```

### 2. MCP Server Package installieren und bauen

```bash
cd packages/mcp-local-files
npm install
npm run build
```

**Wichtig**: Notieren Sie sich den **absoluten Pfad** zum `dist/index.js`:
- Windows Beispiel: `C:\Users\IhrName\Projekte\claude-code-subagents-collection\packages\mcp-local-files\dist\index.js`
- Linux Beispiel: `/home/IhrName/Projekte/claude-code-subagents-collection/packages/mcp-local-files/dist/index.js`
- macOS Beispiel: `/Users/IhrName/Projekte/claude-code-subagents-collection/packages/mcp-local-files/dist/index.js`

### 3. Claude Desktop Konfiguration finden

Öffnen Sie die Claude Desktop Konfigurationsdatei:

**Windows**:
```
%APPDATA%\Claude\claude_desktop_config.json
```
Vollständiger Pfad: `C:\Users\IhrBenutzername\AppData\Roaming\Claude\claude_desktop_config.json`

**macOS**:
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

**Linux**:
```
~/.config/Claude/claude_desktop_config.json
```

### 4. Konfiguration hinzufügen

Öffnen Sie die `claude_desktop_config.json` in einem Texteditor und fügen Sie den MCP-Server hinzu:

#### Windows Beispiel:

```json
{
  "mcpServers": {
    "local-files": {
      "command": "node",
      "args": [
        "C:\\Users\\IhrName\\Projekte\\claude-code-subagents-collection\\packages\\mcp-local-files\\dist\\index.js"
      ],
      "env": {
        "MCP_ALLOWED_PATHS": "C:\\Users;D:\\;E:\\Videos"
      }
    }
  }
}
```

**Wichtig für Windows**:
- Verwenden Sie **doppelte Backslashes** (`\\`) in JSON-Pfaden
- Trennen Sie mehrere Pfade mit **Semikolon** (`;`)

#### macOS/Linux Beispiel:

```json
{
  "mcpServers": {
    "local-files": {
      "command": "node",
      "args": [
        "/Users/IhrName/Projekte/claude-code-subagents-collection/packages/mcp-local-files/dist/index.js"
      ],
      "env": {
        "MCP_ALLOWED_PATHS": "/Users:/home:/mnt/videos"
      }
    }
  }
}
```

**Wichtig für macOS/Linux**:
- Verwenden Sie normale Slashes (`/`)
- Trennen Sie mehrere Pfade mit **Doppelpunkt** (`:`)

### 5. Erlaubte Pfade konfigurieren

Die `MCP_ALLOWED_PATHS` Umgebungsvariable definiert, welche Verzeichnisse Claude zugreifen kann.

#### Empfohlene Windows-Pfade:

```json
"MCP_ALLOWED_PATHS": "C:\\Users;D:\\Videos;E:\\Recordings;F:\\Netzwerk"
```

Für Netzwerkfreigaben:
```json
"MCP_ALLOWED_PATHS": "C:\\Users;\\\\server\\freigabe;D:\\Videos"
```

#### Empfohlene macOS/Linux-Pfade:

```json
"MCP_ALLOWED_PATHS": "/Users:/home:/mnt/videos:/media"
```

### 6. Node.js Installation prüfen

Stellen Sie sicher, dass Node.js installiert ist:

```bash
node --version
```

Sollte mindestens v18.0.0 sein. Falls nicht installiert:

- **Windows**: https://nodejs.org/
- **macOS**: `brew install node`
- **Linux**: `sudo apt install nodejs npm` oder `sudo yum install nodejs npm`

### 7. Claude Desktop neu starten

**Wichtig**: Claude Desktop vollständig beenden und neu starten, damit die Konfiguration geladen wird.

- **Windows**: Task-Manager → Claude beenden → Neu starten
- **macOS**: Cmd+Q → Neu starten
- **Linux**: Prozess beenden → Neu starten

### 8. Installation testen

Öffnen Sie Claude Desktop und testen Sie:

```
Liste alle MP4-Dateien im Verzeichnis C:\Users\IhrName\Videos auf
```

Oder für macOS/Linux:
```
Liste alle MP4-Dateien im Verzeichnis /Users/IhrName/Videos auf
```

Claude sollte nun die MCP-Tools verwenden können.

## Fehlerbehebung

### Problem: "MCP server not found"

**Lösung**:
1. Prüfen Sie, ob der Pfad zur `index.js` korrekt ist
2. Stellen Sie sicher, dass `npm run build` erfolgreich war
3. Verwenden Sie absolute Pfade, keine relativen

### Problem: "Access denied"

**Lösung**:
1. Prüfen Sie die `MCP_ALLOWED_PATHS` Konfiguration
2. Stellen Sie sicher, dass der Pfad in den erlaubten Pfaden enthalten ist
3. Beachten Sie Groß-/Kleinschreibung bei Linux/macOS

### Problem: "node: command not found"

**Lösung**:
1. Node.js installieren (siehe Schritt 6)
2. Nach Installation Terminal/CMD neu starten
3. Node.js-Pfad zur PATH-Umgebungsvariable hinzufügen

### Problem: Videos können nicht gelesen werden

**Lösung**:
1. Prüfen Sie Dateiberechtigungen
2. Stellen Sie sicher, dass die Datei existiert
3. Verwenden Sie absolute Pfade
4. Bei Netzwerkfreigaben: Sind Sie angemeldet?

## Claude Desktop Logs prüfen

Bei Problemen können Sie die Logs prüfen:

**Windows**:
```
%APPDATA%\Claude\logs\
```

**macOS**:
```
~/Library/Logs/Claude/
```

**Linux**:
```
~/.config/Claude/logs/
```

## Weitere Hilfe

- Siehe [README.md](README.md) für ausführliche Dokumentation
- GitHub Issues: https://github.com/davepoon/claude-code-subagents-collection/issues
- MCP Dokumentation: https://modelcontextprotocol.io/

## Nächste Schritte

Nach erfolgreicher Installation:

1. **Meeting-Video-Analyzer Subagent installieren**:
   ```bash
   cp ../../subagents/meeting-video-analyzer.md ~/.claude/agents/
   ```

2. **Claude Desktop neu starten**

3. **Video analysieren**:
   ```
   Analysiere das Video "C:\Users\IhrName\Videos\meeting.mp4"
   und erstelle einen Beraterbericht
   ```

Viel Erfolg! 🚀
