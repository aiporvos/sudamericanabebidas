#!/usr/bin/env bash
# PreToolUse (matcher: Bash) — evita exponer secretos por shell.
# Bloquea comandos Bash que referencien .mcp.json, .env o una API key de n8n.
# Exit 2 = bloquear (el mensaje de stderr se le muestra a Claude).
set -euo pipefail

payload="$(cat)"

# Patrones sensibles:
#  - archivos con secretos: .mcp.json / .env
#  - variable de credencial: N8N_API_KEY
#  - cabecera estándar de JWT de n8n (base64 de {"alg":"HS256","typ":"JWT"})
if printf '%s' "$payload" | grep -Eiq '\.mcp\.json|\.env([^a-z0-9]|$)|N8N_API_KEY|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'; then
  echo "guard-secrets: comando bloqueado por referenciar un archivo/valor sensible (.mcp.json, .env o API key de n8n). Editá la config con la herramienta Edit y usá el MCP para operar sobre n8n; no imprimas secretos por shell." >&2
  exit 2
fi

exit 0
