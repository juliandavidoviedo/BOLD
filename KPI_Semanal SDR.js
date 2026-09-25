const rows = $input.all().map(item => item.json);
const groups = {};

function getWeekStart(isoDate) {
  const date = new Date(isoDate);
  const day = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() - day + 1);
  return date.toISOString().slice(0, 10);
}

function percentage(a, b) {
  return b === 0 ? 0 : Number(((a / b) * 100).toFixed(2));
}

for (const row of rows) {
  if (!row.fecha_cita_iso) continue;

  const weekStart = getWeekStart(row.fecha_cita_iso);
  const key = `${weekStart}|${row.periodo_analisis}`;

  if (!groups[key]) {
    groups[key] = {
      semana_inicio: weekStart,
      periodo_analisis: row.periodo_analisis,
      citas_agendadas: 0,
      citas_realizadas: 0,
      oportunidades: 0,
      cierres: 0,
      perdidas: 0,
      pendientes: 0,
      sin_gestion: 0,
      tpv_m0: 0,
      tpv_m1: 0
    };
  }

  const kpi = groups[key];

  kpi.citas_agendadas++;

  if (row.cita_realizada === true) {
    kpi.citas_realizadas++;
  }

  if (row.estado_comercial === 'Oportunidad') {
    kpi.oportunidades++;
  }

  if (row.estado_comercial === 'Cierre') {
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

  kpi.tpv_m0 += Number(row.tpv_m0 || 0);
  kpi.tpv_m1 += Number(row.tpv_m1 || 0);
}

return Object.values(groups).map(kpi => ({
  json: {
    ...kpi,
    tasa_realizacion: percentage(
      kpi.citas_realizadas,
      kpi.citas_agendadas
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
