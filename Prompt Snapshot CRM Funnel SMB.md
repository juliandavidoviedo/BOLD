Actúa como Product Designer, Analytics Engineer y desarrollador de Sites para crear una PoC visual del dashboard comercial SMB de Bold.

Contexto:
La conexión directa con Google Sheets mediante fetch está bloqueada por CORS. Para esta primera demo de 30 minutos construiremos un mockup funcional con un snapshot estático de datos representativos. La conexión autenticada a Sheets quedará desacoplada y se reemplazará posteriormente mediante un conector autorizado o una API corporativa.

Objetivo:
Crear una PoC navegable para managers y líderes comerciales que permita revisar el desempeño de leads y oportunidades SMB.

Importante:
- No presentes el mockup como conexión en tiempo real.
- No uses la URL pública CSV.
- No intentes ocultar el error CORS.
- No inventes una conexión autenticada.
- Incluye una alerta visible:
  “PoC con snapshot estático. La conexión automática a Google Sheets está pendiente de resolver autenticación y CORS.”
- Incluye la fecha de corte del snapshot.
- No incluyas teléfonos, documentos, direcciones, correos personales, archivos ni fotografías.
- Puedes conservar empresa, owner_id y manager corporativo como dimensiones de gestión.

## Datos

Reemplaza los arreglos mock actuales por datos estructurados en el código:

```javascript
const DATA_SOURCE = {
  type: "static_snapshot",
  source: "Google Sheet corporativo",
  updatedAt: "2026-09-18",
  status: "demo_only"
};

const rawLeads = [];
const rawOpportunities = [];
