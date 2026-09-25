const rows = $input.all().map(item => item.json);
const groups = {};

// Para producción, reemplazar por CFG_Parametros.fecha_corte
const SNAPSHOT_DATE = new Date();

function getWeekStart(isoDate) {
  const date = new Date(isoDate);

  if (Number.isNaN(date.getTime())) {
    return null;
  }

  const day = date.getUTCDay() || 7;

  date.setUTCDate(date.getUTCDate() - day + 1);

  return date.toISOString().slice(0, 10);
}

function percentage(numerator, denominator) {
  if (!denominator) return 0;

  return Number(
    ((numerator / denominator) * 100).toFixed(2)
  );
}

function asBoolean(value) {
  return (
    value === true ||
    value === 'true' ||
    value === 1 ||
    value === '1'
  );
}

function normalizeStatus(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

function toNumber(value) {
  const number = Number(value || 0);

  return Number.isFinite(number) ? number : 0;
}

for (const row of rows) {
  if (!row.fecha_cita_iso) continue;

  const weekStart = getWeekStart(row.fecha_cita_iso);

  if (!weekStart) continue;

  const periodo = row.periodo_analisis || 'Sin periodo';
  const key = `${weekStart}|${periodo}`;

  if (!groups[key]) {
    groups[key] = {
      semana_inicio: weekStart,
      periodo_analisis: periodo,

      citas_agendadas: 0,
      citas_realizadas: 0,
      citas_futuras: 0,

      oportunidades: 0,
      cierres: 0,
      perdidas: 0,
      pendientes: 0,
      sin_gestion: 0,

      excepciones: 0,
      outliers_embudo: 0,
      inconsistencias_realizacion: 0,

      tpv_m0: 0,
      tpv_m1: 0
    };
  }

  const kpi = groups[key];

  kpi.citas_agendadas++;

  const fechaCita = new Date(row.fecha_cita_iso);
  const fechaCitaValida = !Number.isNaN(fechaCita.getTime());

  const citaFutura =
    asBoolean(row.cita_futura) ||
    (fechaCitaValida && fechaCita > SNAPSHOT_DATE);

  if (citaFutura) {
    kpi.citas_futuras++;
  } else if (asBoolean(row.cita_realizada)) {
    kpi.citas_realizadas++;
  }

  /*
   * El embudo utiliza flags independientes.
   * Un cierre también cuenta como oportunidad.
   */
  const estadoOP = normalizeStatus(row.estado_oportunidad);

  const esOportunidad =
    row.es_oportunidad !== undefined
      ? asBoolean(row.es_oportunidad)
      : toNumber(row.conteo_op) > 0 ||
        ['ganada', 'cerrada', 'perdida'].includes(estadoOP);

  const esCierre =
    row.es_cierre !== undefined
      ? asBoolean(row.es_cierre)
      : toNumber(row.conteo_cierre) > 0 ||
        row.estado_comercial === 'Cierre' ||
        row.estado_cita === 'Cierre Exitoso';

  if (esOportunidad) {
    kpi.oportunidades++;
  }

  if (esCierre) {
    kpi.cierres++;
  }

  if (row.estado_comercial === 'Perdida') {
    kpi.perdidas++;
  }

  if (row.estado_comercial === 'Pendiente') {
    kpi.pendientes++;
  }

  if (row.estado_comercial === 'Sin gestión') {
    kpi.sin_gestion++;
  }

  if (asBoolean(row.registro_excepcion)) {
    kpi.excepciones++;
  }

  if (asBoolean(row.outlier_embudo)) {
    kpi.outliers_embudo++;
  }

  if (asBoolean(row.inconsistencia_realizacion)) {
    kpi.inconsistencias_realizacion++;
  }

  kpi.tpv_m0 += toNumber(row.tpv_m0);
  kpi.tpv_m1 += toNumber(row.tpv_m1);
}

return Object.values(groups)
  .sort((a, b) =>
    a.semana_inicio.localeCompare(b.semana_inicio)
  )
  .map(kpi => ({
    json: {
      ...kpi,

      tasa_realizacion: percentage(
        kpi.citas_realizadas,
        kpi.citas_agendadas - kpi.citas_futuras
      ),

      tasa_cita_oportunidad: percentage(
        kpi.oportunidades,
        kpi.citas_agendadas
      ),

      tasa_oportunidad_cierre: percentage(
        kpi.cierres,
        kpi.oportunidades
      ),

      fecha_proceso: new Date().toISOString()
    }
  }));
