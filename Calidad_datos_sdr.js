const items = $input.all();
const rows = items.map(item => item.json);

const total = rows.length;
const seenCitas = new Map();
const duplicateIds = [];

let missingEmpresa = 0;
let missingComercio = 0;
let missingEjecutivo = 0;
let missingTeamLead = 0;
let missingFechaCita = 0;
let missingFechaTRX = 0;
let invalidFechaCita = 0;
let invalidFechaCierre = 0;
let inconsistentCierre = 0;
let inconsistentTRX = 0;

const estadoComercial = {};
const estadoCita = {};
const canal = {};
const ejecutivo = {};

function countValue(dictionary, value) {
  const key = value || 'Sin dato';
  dictionary[key] = (dictionary[key] || 0) + 1;
}

for (const row of rows) {
  const idCita = row.id_cita || 'SIN_ID_CITA';

  if (seenCitas.has(idCita)) {
    duplicateIds.push(idCita);
  } else {
    seenCitas.set(idCita, true);
  }

  if (!row.empresa) missingEmpresa++;
  if (!row.id_comercio) missingComercio++;
  if (!row.ejecutivo_sdr && !row.ejecutivo_asignado) {
    missingEjecutivo++;
  }
  if (!row.team_lead) missingTeamLead++;
  if (!row.fecha_cita_iso) missingFechaCita++;
  if (!row.fecha_primera_trx_iso) missingFechaTRX++;

  if (row.calidad?.error_fecha_cita) {
    invalidFechaCita++;
  }

  if (row.calidad?.error_fecha_cierre) {
    invalidFechaCierre++;
  }

  // Cierre exitoso sin cita marcada como realizada
  if (
    row.estado_cita === 'Cierre Exitoso' &&
    row.cita_realizada === false
  ) {
    inconsistentCierre++;
  }

  // Existe fecha de primera transacción, pero no hay cierre
  if (
    row.fecha_primera_trx_iso &&
    row.conteo_cierre === 0 &&
    row.estado_comercial !== 'Cierre'
  ) {
    inconsistentTRX++;
  }

  countValue(estadoComercial, row.estado_comercial);
  countValue(estadoCita, row.estado_cita);
  countValue(canal, row.canal);
  countValue(
    ejecutivo,
    row.ejecutivo_asignado || row.ejecutivo_sdr
  );
}

const uniqueIds = seenCitas.size;
const duplicateCount = duplicateIds.length;

const percentage = value =>
  total === 0 ? 0 : Number(((value / total) * 100).toFixed(2));

const calidadGeneral =
  invalidFechaCita > 0 ||
  missingFechaCita > 0 ||
  missingComercio > 0 ||
  missingEmpresa > 0
    ? 'REVISAR'
    : 'OK';

return [
  {
    json: {
      fecha_proceso: new Date().toISOString(),
      periodo_analisis: '2026-06 a 2026-12',

      total_registros: total,
      ids_cita_unicos: uniqueIds,
      registros_duplicados: duplicateCount,
      ids_duplicados_muestra: duplicateIds.slice(0, 20),

      faltantes: {
        empresa: missingEmpresa,
        comercio: missingComercio,
        ejecutivo: missingEjecutivo,
        team_lead: missingTeamLead,
        fecha_cita: missingFechaCita,
        fecha_primera_trx: missingFechaTRX
      },

      errores_fecha: {
        fecha_cita: invalidFechaCita,
        fecha_cierre: invalidFechaCierre
      },

      inconsistencias_negocio: {
        cierre_exitoso_no_realizada: inconsistentCierre,
        trx_sin_cierre: inconsistentTRX
      },

      porcentajes: {
        empresa_completa: percentage(total - missingEmpresa),
        comercio_completo: percentage(total - missingComercio),
        ejecutivo_completo: percentage(total - missingEjecutivo),
        team_lead_completo: percentage(total - missingTeamLead),
        fecha_cita_completa: percentage(total - missingFechaCita),
        fecha_trx_completa: percentage(total - missingFechaTRX)
      },

      distribuciones: {
        estado_comercial: estadoComercial,
        estado_cita: estadoCita,
        canal: canal,
        ejecutivo: ejecutivo
      },

      calidad_general: calidadGeneral,
      recomendacion:
        calidadGeneral === 'OK'
          ? 'Continuar con cálculo de KPIs'
          : 'Revisar excepciones antes de certificar KPIs'
    }
  }
];
