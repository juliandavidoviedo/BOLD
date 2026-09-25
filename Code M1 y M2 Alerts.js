return items.map(item => {
  const row = item.json;

  return {
    json: {
      ...row,
      status_normalizado: String(row.status_code || '').trim().toUpperCase(),
      verificacion_normalizada: String(
        row.manual_verification_status_code || ''
      ).trim().toUpperCase(),
      ejecutivo_email: String(
        row.sales_agent_email || ''
      ).trim().toLowerCase(),
      dias_vida: Number(row['Dias de Vida']) || 0,
      tipo_churn: String(row['Tipo de Churn'] || '').trim()
    }
  };
});

Perfecto. Desde la salida del filtro `ACTIVE + VERIFIED`, continúa así:

```text
Google Sheets - Get Rows
        ↓
Filtro sales_source = SMB
        ↓
Filtro ACTIVE + VERIFIED
        ↓
Code - Clasificar M1/M2 y churn
        ↓
IF - ¿Tiene alerta?
        ↓
Gmail - Enviar correo de prueba
```

## 1. Agrega un nodo Code

Configúralo así:

- **Language:** JavaScript
- **Mode:** Run Once for All Items

Pega este código:

```javascript
function toNumber(value) {
  if (value === null || value === undefined || value === '') {
    return 0;
  }

  if (typeof value === 'number') {
    return value;
  }

  return Number(
    String(value)
      .trim()
      .replace(/\./g, '')
      .replace(',', '.')
      .replace(/[^\d.-]/g, '')
  ) || 0;
}

function normalizeText(value) {
  return String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim()
    .toUpperCase();
}

return items.map(item => {
  const row = item.json;

  const daysAlive = toNumber(row['Dias de Vida']);
  const tpvM1 = toNumber(row['TPV M1']);
  const tpvM2 = toNumber(row['TPV M2']);

  let lifecycle = null;

  if (daysAlive >= 1 && daysAlive <= 30) {
    lifecycle = 'M1';
  } else if (daysAlive >= 31 && daysAlive <= 60) {
    lifecycle = 'M2';
  }

  const existingChurn = normalizeText(row['Tipo de Churn']);

  let churnType = null;

  if (existingChurn.includes('7')) {
    churnType = 7;
  } else if (existingChurn.includes('5')) {
    churnType = 5;
  } else if (existingChurn.includes('3')) {
    churnType = 3;
  }

  let priority = null;

  if (churnType === 7) {
    priority = 'CRITICA';
  } else if (churnType === 5) {
    priority = 'ALTA';
  } else if (churnType === 3) {
    priority = 'MEDIA';
  }

  if (tpvM1 + tpvM2 >= 10000000 && priority !== null) {
    priority = 'CRITICA';
  } else if (
    tpvM1 + tpvM2 >= 3000000 &&
    priority === 'MEDIA'
  ) {
    priority = 'ALTA';
  }

  const email = String(row['sales_agent_email'] || '')
    .trim()
    .toLowerCase();

  return {
    json: {
      ...row,

      lifecycle,
      days_alive: daysAlive,
      tpv_m1_normalizado: tpvM1,
      tpv_m2_normalizado: tpvM2,
      churn_type: churnType,
      priority,
      ejecutivo_email: email,

      debe_alertar:
        lifecycle !== null &&
        churnType !== null &&
        email !== '',

      alert_key:
        churnType !== null && lifecycle !== null
          ? `${row.master_merchant_id}-${lifecycle}-churn-${churnType}`
          : null,

      recommended_action:
        churnType === 7
          ? 'Contactar hoy y diagnosticar la pérdida de actividad.'
          : churnType === 5
            ? 'Contactar en las próximas horas y activar recuperación.'
            : churnType === 3
              ? 'Realizar contacto preventivo y validar la causa.'
              : null
    }
  };
});
```

Este código usa el campo ya calculado `Tipo de Churn`. En esta primera prueba es mejor no recalcular todavía los días, hasta confirmar cómo están organizadas las columnas diarias.

## 2. Agrega un nodo IF

Conecta el nodo `Code` a un nodo `IF`.

Configura la condición:

```text
Campo: debe_alertar
Operación: is true
```

La salida `true` continuará hacia el correo.

La salida `false` se puede dejar temporalmente sin conectar.

## 3. Agrega el nodo Gmail

Como ya conectaste tu cuenta de Google, agrega:

```text
Gmail → Message → Send
```

Configúralo inicialmente con un correo fijo de prueba.

### To

Usa tu correo personal o de validación, no el correo real del ejecutivo:

```text
tu-correo@dominio.com
```

### Subject

```text
[PRUEBA] Alerta {{ $json.priority }} - {{ $json.merchant_name }}
```

### Email Type

```text
HTML
```

### Body

```html
<h2>Alerta de churn - Prueba</h2>

<p>Este correo corresponde a una prueba controlada del flujo n8n.</p>

<table border="1" cellpadding="6" cellspacing="0">
  <tr>
    <td><strong>Comercio</strong></td>
    <td>{{ $json.merchant_name }}</td>
  </tr>
  <tr>
    <td><strong>ID comercio</strong></td>
    <td>{{ $json.master_merchant_id }}</td>
  </tr>
  <tr>
    <td><strong>Ejecutivo asignado</strong></td>
    <td>{{ $json.sales_agent_email }}</td>
  </tr>
  <tr>
    <td><strong>Segmento</strong></td>
    <td>{{ $json.lifecycle }}</td>
  </tr>
  <tr>
    <td><strong>Días de vida</strong></td>
    <td>{{ $json.days_alive }}</td>
  </tr>
  <tr>
    <td><strong>Tipo de churn</strong></td>
    <td>{{ $json.churn_type }} días</td>
  </tr>
  <tr>
    <td><strong>Prioridad</strong></td>
    <td>{{ $json.priority }}</td>
  </tr>
  <tr>
    <td><strong>TPV M1</strong></td>
    <td>{{ $json.tpv_m1_normalizado }}</td>
  </tr>
  <tr>
    <td><strong>TPV M2</strong></td>
    <td>{{ $json.tpv_m2_normalizado }}</td>
  </tr>
</table>

<p>
  <strong>Acción recomendada:</strong>
  {{ $json.recommended_action }}
</p>

<p>
  El ejecutivo asignado en la reportería es:
  {{ $json.sales_agent_email }}
</p>
```

## 4. Cómo probarlo

Ejecuta los nodos en este orden:

1. `Get Rows`
2. Filtro `SMB`
3. Filtro `ACTIVE + VERIFIED`
4. `Code`
5. `IF`
6. `Gmail`

Antes de ejecutar Gmail, revisa en la salida del nodo `Code` que existan:

```text
lifecycle: M1 o M2
churn_type: 3, 5 o 7
priority: MEDIA, ALTA o CRITICA
debe_alertar: true
ejecutivo_email: correo válido
```

Si el nodo `IF` devuelve cero elementos, revisa especialmente:

- `Dias de Vida`
- `Tipo de Churn`
- `sales_agent_email`
- El nombre exacto de las columnas.

## 5. Importante para esta primera prueba

Mantén fijo el destinatario:

```text
tu-correo@dominio.com
```

No uses todavía:

```text
{{ $json.sales_agent_email }}
```

Cuando confirmemos que el contenido y la clasificación son correctos, reemplazamos el destinatario por:

```text
{{ $json.ejecutivo_email }}
```

El siguiente paso, después de validar el correo, será agregar una hoja `ALERTAS_ENVIADAS` para evitar que el mismo comercio reciba alertas repetidas diariamente.



  <h2>Alerta de churn - Prueba</h2>

<p>Se generó una alerta para un comercio asignado a un ejecutivo.</p>

<table border="1" cellpadding="6" cellspacing="0">
  <tr>
    <td><strong>Tipo de alerta</strong></td>
    <td>{{ $json.alert_type }}</td>
  </tr>
  <tr>
    <td><strong>Prioridad</strong></td>
    <td>{{ $json.priority }}</td>
  </tr>
  <tr>
    <td><strong>Comercio</strong></td>
    <td>{{ $json.merchant_name }}</td>
  </tr>
  <tr>
    <td><strong>ID comercio</strong></td>
    <td>{{ $json.master_merchant_id }}</td>
  </tr>
  <tr>
    <td><strong>Ejecutivo asignado</strong></td>
    <td>{{ $json.sales_agent_email }}</td>
  </tr>
  <tr>
    <td><strong>Canal</strong></td>
    <td>{{ $json.sales_source }}</td>
  </tr>
  <tr>
    <td><strong>Días de vida</strong></td>
    <td>{{ $json.dias_de_vida }}</td>
  </tr>
  <tr>
    <td><strong>TPV M1</strong></td>
    <td>{{ $json.tpv_m1 }}</td>
  </tr>
  <tr>
    <td><strong>TPV M2</strong></td>
    <td>{{ $json.tpv_m2 }}</td>
  </tr>
</table>

<p>
  <strong>Acción recomendada:</strong>
  {{ $json.recommended_action }}
</p>
