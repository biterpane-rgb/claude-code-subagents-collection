# Quick Start: Wandera Video-Analyse

Diese Anleitung zeigt Ihnen, wie Sie den MCP Local Files Server speziell für die Analyse Ihrer Wandera-Präsentationsvideos konfigurieren.

## Ihre Konfiguration

Basierend auf Ihren Pfaden:
- **Videos**: `C:\Users\neco.roknic.yourit\Videos\`
- **GitHub**: `C:\Users\neco.roknic.yourit\Documents\GitHub\`

## Schritt 1: MCP Server installieren

```bash
# Im Repository-Verzeichnis
cd C:\Users\neco.roknic.yourit\Documents\GitHub\claude-code-subagents-collection
cd packages\mcp-local-files
npm install
npm run build
```

## Schritt 2: Claude Desktop konfigurieren

Öffnen Sie diese Datei:
```
%APPDATA%\Claude\claude_desktop_config.json
```

Oder navigieren Sie zu:
```
C:\Users\neco.roknic.yourit\AppData\Roaming\Claude\claude_desktop_config.json
```

Fügen Sie folgende Konfiguration ein:

```json
{
  "mcpServers": {
    "local-files": {
      "command": "node",
      "args": [
        "C:\\Users\\neco.roknic.yourit\\Documents\\GitHub\\claude-code-subagents-collection\\packages\\mcp-local-files\\dist\\index.js"
      ],
      "env": {
        "MCP_ALLOWED_PATHS": "C:\\Users\\neco.roknic.yourit\\Videos;C:\\Users\\neco.roknic.yourit\\Documents\\GitHub"
      }
    }
  }
}
```

### Was bedeutet das?

- **command**: Startet Node.js
- **args**: Pfad zum MCP-Server (Ihr GitHub-Repository)
- **MCP_ALLOWED_PATHS**: Erlaubt Zugriff auf:
  - Ihr Videos-Verzeichnis (für Meeting-Aufzeichnungen)
  - Ihr GitHub-Verzeichnis (für Projekte und Dokumentation)

## Schritt 3: Meeting-Video-Analyzer installieren

```bash
# Im Repository-Verzeichnis
cd C:\Users\neco.roknic.yourit\Documents\GitHub\claude-code-subagents-collection
copy subagents\meeting-video-analyzer.md %USERPROFILE%\.claude\agents\
```

Oder manuell kopieren:
- Von: `C:\Users\neco.roknic.yourit\Documents\GitHub\claude-code-subagents-collection\subagents\meeting-video-analyzer.md`
- Nach: `C:\Users\neco.roknic.yourit\.claude\agents\meeting-video-analyzer.md`

## Schritt 4: Claude Desktop neu starten

1. Claude Desktop vollständig schließen (Task-Manager prüfen)
2. Claude Desktop neu starten
3. Warten bis vollständig geladen

## Schritt 5: Video analysieren

Öffnen Sie Claude Desktop und geben Sie ein:

```
Analysiere das Video "C:\Users\neco.roknic.yourit\Videos\2025-10-24 14-09-06.mp4"
und erstelle einen detaillierten Beraterbericht über die Warenwirtschaftssystem-Präsentation
der Wandera GmbH (https://www.wandera-schnitzereien.com/) und deren Auftragsabwicklung.

Der Bericht soll enthalten:
- Executive Summary für Management
- Detaillierte Prozessanalyse der Auftragsabwicklung
- Workflow-Dokumentation des Warenwirtschaftssystems
- Screenshot- und Diagramm-Beschreibungen
- Identifizierte Optimierungspotenziale
- Handlungsempfehlungen
- Technische Spezifikationen des Systems
```

## Was passiert dann?

Claude wird automatisch:

1. ✅ Den MCP-Server verwenden, um das Video zu laden
2. ✅ Das Video mit dem `meeting-video-analyzer` Subagent analysieren
3. ✅ Einen professionellen Beraterbericht erstellen

## Weitere Videos analysieren

Sie können nun beliebige Videos aus Ihrem Videos-Ordner analysieren:

```
Analysiere das Video "C:\Users\neco.roknic.yourit\Videos\DATEINAME.mp4"
```

## Zusätzliche Pfade hinzufügen

Falls Sie weitere Verzeichnisse benötigen, erweitern Sie `MCP_ALLOWED_PATHS`:

```json
"MCP_ALLOWED_PATHS": "C:\\Users\\neco.roknic.yourit\\Videos;C:\\Users\\neco.roknic.yourit\\Documents\\GitHub;C:\\Users\\neco.roknic.yourit\\Documents\\Projekte;D:\\Recordings"
```

**Wichtig**: Trennen Sie Pfade mit Semikolon (`;`) und verwenden Sie doppelte Backslashes (`\\`)

## Troubleshooting

### "Access denied" Fehler

Das Video ist nicht in den erlaubten Pfaden. Prüfen Sie:
```json
"MCP_ALLOWED_PATHS": "C:\\Users\\neco.roknic.yourit\\Videos;..."
```

### "MCP server not found"

1. Prüfen Sie, ob `npm run build` erfolgreich war
2. Prüfen Sie den Pfad in `args`:
   ```
   C:\Users\neco.roknic.yourit\Documents\GitHub\claude-code-subagents-collection\packages\mcp-local-files\dist\index.js
   ```
3. Stellen Sie sicher, dass die Datei existiert

### Video wird nicht geladen

1. Prüfen Sie, ob die Datei existiert:
   ```
   C:\Users\neco.roknic.yourit\Videos\2025-10-24 14-09-06.mp4
   ```
2. Prüfen Sie Dateiberechtigungen
3. Stellen Sie sicher, dass Claude Desktop neu gestartet wurde

## Unterstützte Video-Formate

- ✅ MP4 (.mp4)
- ✅ AVI (.avi)
- ✅ MOV (.mov)
- ✅ MKV (.mkv)
- ✅ WebM (.webm)
- ✅ FLV (.flv)

## Logs prüfen

Bei Problemen prüfen Sie die Claude Desktop Logs:
```
%APPDATA%\Claude\logs\
```

Oder:
```
C:\Users\neco.roknic.yourit\AppData\Roaming\Claude\logs\
```

## Weitere Hilfe

- Siehe [INSTALLATION.md](INSTALLATION.md) für ausführliche Anleitung
- Siehe [README.md](README.md) für vollständige API-Dokumentation
- GitHub Issues: https://github.com/davepoon/claude-code-subagents-collection/issues

---

**Viel Erfolg mit der Wandera-Präsentationsanalyse!** 🚀
