# MCP Local Files Server

Ein Model Context Protocol (MCP) Server für sicheren Zugriff auf lokale Dateien, Netzwerkfreigaben und Video-Aufzeichnungen.

## Funktionen

- ✅ **Lokaler Dateizugriff**: Lesen von Dateien aus dem lokalen Dateisystem (Windows, Linux, macOS)
- ✅ **Netzwerkfreigaben**: Zugriff auf gemappte Laufwerke und Netzwerkpfade
- ✅ **Video-Unterstützung**: Automatische Erkennung und Base64-Kodierung von Videodateien
- ✅ **Verzeichnis-Listing**: Auflisten von Dateien mit optionaler Filterung
- ✅ **Dateisuche**: Rekursive Suche nach Dateien mit Regex-Mustern
- ✅ **Metadaten**: Größe, Erstellungs- und Änderungsdatum
- ✅ **Sicherheit**: Pfad-Validierung und konfigurierbare Zugriffsbeschränkungen

## Quick Start

📺 **Für Wandera Video-Analyse**: Siehe [QUICKSTART-WANDERA.md](QUICKSTART-WANDERA.md) für eine schnelle, spezifische Anleitung.

## Installation

### Voraussetzungen

- Node.js >= 18.0.0
- npm oder yarn

### Schritt 1: Package installieren

```bash
cd packages/mcp-local-files
npm install
npm run build
```

### Schritt 2: Claude Desktop konfigurieren

Fügen Sie den MCP-Server zu Ihrer Claude Desktop Konfiguration hinzu:

**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Linux**: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "local-files": {
      "command": "node",
      "args": [
        "C:\\Users\\IhrBenutzername\\Documents\\GitHub\\claude-code-subagents-collection\\packages\\mcp-local-files\\dist\\index.js"
      ],
      "env": {
        "MCP_ALLOWED_PATHS": "C:\\Users\\IhrBenutzername\\Videos;C:\\Users\\IhrBenutzername\\Documents\\GitHub;D:\\Videos"
      }
    }
  }
}
```

**Wichtig**: Ersetzen Sie `/absoluter/pfad/zu/` mit dem tatsächlichen Pfad zum Repository!

### Schritt 3: Erlaubte Pfade konfigurieren

Die Umgebungsvariable `MCP_ALLOWED_PATHS` definiert, welche Verzeichnisse zugänglich sind. Mehrere Pfade werden durch das System-Pfad-Trennzeichen getrennt:

- **Windows**: Semikolon (`;`)
- **Linux/macOS**: Doppelpunkt (`:`)

**Beispiel für Windows** (spezifische Pfade empfohlen):
```json
"MCP_ALLOWED_PATHS": "C:\\Users\\IhrBenutzername\\Videos;C:\\Users\\IhrBenutzername\\Documents\\GitHub;D:\\Videos"
```

**Beispiel für Linux/macOS**:
```json
"MCP_ALLOWED_PATHS": "/home/username/videos:/Users/username/Documents:/mnt/videos"
```

**Sicherheitshinweis**: Verwenden Sie spezifische Pfade statt breiter Verzeichnisse:
- ✅ Empfohlen: `C:\\Users\\username\\Videos`
- ❌ Zu breit: `C:\\Users` (Zugriff auf alle Benutzer)

### Schritt 4: Claude Desktop neu starten

Starten Sie Claude Desktop neu, damit die Konfiguration geladen wird.

## Verwendung

### Verfügbare Tools

Der MCP-Server stellt folgende Tools bereit:

#### 1. `read_local_file`

Liest den Inhalt einer lokalen Datei oder Video-Datei.

**Parameter**:
- `path` (string, required): Absoluter Pfad zur Datei
- `encoding` (string, optional): Text-Encoding (utf-8, ascii, latin1) - wird bei Videos ignoriert

**Beispiel**:
```typescript
{
  "path": "C:\\Users\\username\\Videos\\meeting-2025-10-24.mp4"
}
```

**Rückgabe**:
- Textdateien: Content als String
- Videodateien: Base64-kodierter Content + Metadaten

#### 2. `list_directory`

Listet Dateien in einem Verzeichnis auf.

**Parameter**:
- `path` (string, required): Absoluter Pfad zum Verzeichnis
- `pattern` (string, optional): Regex-Muster zum Filtern

**Beispiel**:
```typescript
{
  "path": "C:\\Users\\username\\Videos",
  "pattern": ".*\\.mp4$"
}
```

#### 3. `get_file_metadata`

Ruft Metadaten einer Datei ab.

**Parameter**:
- `path` (string, required): Absoluter Pfad zur Datei

**Beispiel**:
```typescript
{
  "path": "C:\\Users\\username\\Videos\\meeting.mp4"
}
```

#### 4. `search_files`

Sucht nach Dateien in einem Verzeichnisbaum.

**Parameter**:
- `basePath` (string, required): Startverzeichnis
- `pattern` (string, required): Regex-Muster für Dateinamen
- `recursive` (boolean, optional): Rekursive Suche (default: false)
- `maxResults` (number, optional): Maximale Anzahl Ergebnisse (default: 100)

**Beispiel**:
```typescript
{
  "basePath": "C:\\Users\\username",
  "pattern": ".*meeting.*\\.mp4$",
  "recursive": true,
  "maxResults": 50
}
```

## Verwendung mit dem Meeting-Video-Analyzer Subagent

Der MCP-Server wurde speziell entwickelt, um mit dem `meeting-video-analyzer` Subagent zu arbeiten:

```
Analysiere das Video "C:\Users\neco.roknic.yourit\Videos\2025-10-24 14-09-06.mp4"
und erstelle einen Beraterbericht über die Wandera Warenwirtschafts-Präsentation.
```

Claude wird automatisch:
1. Den MCP-Server verwenden, um auf die lokale Datei zuzugreifen
2. Den meeting-video-analyzer Subagent aufrufen
3. Einen professionellen Beraterbericht erstellen

## Sicherheit

### Pfad-Validierung

Der Server validiert alle Pfade gegen die konfigurierten `MCP_ALLOWED_PATHS`. Zugriffe außerhalb dieser Pfade werden abgelehnt.

### Größenlimit

Dateien größer als 100MB werden abgelehnt, um Speicherprobleme zu vermeiden.

### Best Practices

1. **Minimale Berechtigungen**: Konfigurieren Sie nur die wirklich benötigten Pfade
2. **Keine sensiblen Verzeichnisse**: Vermeiden Sie System- oder Config-Verzeichnisse
3. **Regelmäßige Updates**: Halten Sie die Dependencies aktuell

## Fehlerbehandlung

Der Server gibt aussagekräftige Fehlermeldungen zurück:

- **Access denied**: Pfad nicht in erlaubten Verzeichnissen
- **File not found**: Datei existiert nicht
- **File too large**: Datei überschreitet Größenlimit
- **Permission denied**: Keine Leseberechtigung

## Entwicklung

### Build

```bash
npm run build
```

### Development Mode

```bash
npm run dev
```

### Testing

```bash
# Manueller Test
node dist/index.js
```

## Unterstützte Dateiformate

### Video-Formate (Base64-Kodierung)
- MP4 (.mp4)
- AVI (.avi)
- MOV (.mov)
- MKV (.mkv)
- WebM (.webm)
- FLV (.flv)

### Text-Formate (UTF-8/ASCII)
- Alle anderen Dateien werden als Text gelesen

## Lizenz

MIT License - siehe [LICENSE](../../LICENSE) für Details.

## Support

Bei Problemen oder Fragen:
1. Prüfen Sie die Claude Desktop Logs
2. Validieren Sie die `claude_desktop_config.json`
3. Stellen Sie sicher, dass die Pfade absolut und korrekt sind
4. Erstellen Sie ein Issue im Repository

## Weitere Ressourcen

- [Model Context Protocol Dokumentation](https://modelcontextprotocol.io/)
- [Claude Desktop Setup](https://docs.anthropic.com/claude/docs)
- [MCP SDK TypeScript](https://github.com/modelcontextprotocol/typescript-sdk)
