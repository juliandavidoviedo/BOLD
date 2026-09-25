// n8n Code
// Nombre: Aplanar Calidad SDR
// Mode: Run Once for All Items

const output = [];

for (const item of $input.all()) {
  const row = item.json;
  const quality = row.calidad || {};

  const {
    calidad,
    ...base
  } = row;

  output.push({
    json: {
      ...base,

      falta_empresa:
        quality.falta_empresa ?? false,

      falta_identificador:
        quality.falta_identificador ?? false,

      falta_ejecutivo:
        quality.falta_ejecutivo ?? false,

      falta_team_lead:
        quality.falta_team_lead ?? false,

      falta_fecha_cita:
        quality.falta_fecha_cita ?? false,

      falta_fecha_primera_trx:
        quality.falta_fecha_primera_trx ?? false,

      error_fecha_cita:
        quality.error_fecha_cita ?? false,

      error_fecha_cierre:
        quality.error_fecha_cierre ?? false,

      advertencia_sin_fecha_trx:
        quality.advertencia_sin_fecha_trx ?? false
    }
  });
}

return output;
