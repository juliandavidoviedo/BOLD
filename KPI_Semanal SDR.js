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


[
  {
    "semana_inicio": "2026-06-01",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 204,
    "citas_realizadas": 94,
    "oportunidades": 36,
    "cierres": 114,
    "perdidas": 21,
    "pendientes": 3,
    "sin_gestion": 30,
    "tpv_m0": 1147255297,
    "tpv_m1": 1601956545,
    "tasa_realizacion": 46.08,
    "tasa_cita_oportunidad": 17.65,
    "tasa_oportunidad_cierre": 316.67,
    "fecha_proceso": "2026-09-25T17:33:47.781Z"
  },
  {
    "semana_inicio": "2026-07-20",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 196,
    "citas_realizadas": 75,
    "oportunidades": 36,
    "cierres": 112,
    "perdidas": 23,
    "pendientes": 5,
    "sin_gestion": 20,
    "tpv_m0": 321166681,
    "tpv_m1": 978351263.0799999,
    "tasa_realizacion": 38.27,
    "tasa_cita_oportunidad": 18.37,
    "tasa_oportunidad_cierre": 311.11,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-06-29",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 116,
    "citas_realizadas": 57,
    "oportunidades": 17,
    "cierres": 66,
    "perdidas": 15,
    "pendientes": 3,
    "sin_gestion": 15,
    "tpv_m0": 342423155,
    "tpv_m1": 430282337,
    "tasa_realizacion": 49.14,
    "tasa_cita_oportunidad": 14.66,
    "tasa_oportunidad_cierre": 388.24,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-09-28",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 2,
    "citas_realizadas": 2,
    "oportunidades": 0,
    "cierres": 0,
    "perdidas": 1,
    "pendientes": 1,
    "sin_gestion": 0,
    "tpv_m0": 0,
    "tpv_m1": 0,
    "tasa_realizacion": 100,
    "tasa_cita_oportunidad": 0,
    "tasa_oportunidad_cierre": 0,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-11-02",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 1,
    "citas_realizadas": 1,
    "oportunidades": 0,
    "cierres": 0,
    "perdidas": 1,
    "pendientes": 0,
    "sin_gestion": 0,
    "tpv_m0": 0,
    "tpv_m1": 0,
    "tasa_realizacion": 100,
    "tasa_cita_oportunidad": 0,
    "tasa_oportunidad_cierre": 0,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-06-08",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 184,
    "citas_realizadas": 86,
    "oportunidades": 32,
    "cierres": 88,
    "perdidas": 23,
    "pendientes": 11,
    "sin_gestion": 30,
    "tpv_m0": 314709142,
    "tpv_m1": 746548456,
    "tasa_realizacion": 46.74,
    "tasa_cita_oportunidad": 17.39,
    "tasa_oportunidad_cierre": 275,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-06-22",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 188,
    "citas_realizadas": 90,
    "oportunidades": 27,
    "cierres": 111,
    "perdidas": 24,
    "pendientes": 4,
    "sin_gestion": 22,
    "tpv_m0": 756547731,
    "tpv_m1": 1541728151.5,
    "tasa_realizacion": 47.87,
    "tasa_cita_oportunidad": 14.36,
    "tasa_oportunidad_cierre": 411.11,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-06-15",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 140,
    "citas_realizadas": 61,
    "oportunidades": 28,
    "cierres": 72,
    "perdidas": 16,
    "pendientes": 3,
    "sin_gestion": 21,
    "tpv_m0": 239560176,
    "tpv_m1": 700900954.2,
    "tasa_realizacion": 43.57,
    "tasa_cita_oportunidad": 20,
    "tasa_oportunidad_cierre": 257.14,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-07-06",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 173,
    "citas_realizadas": 82,
    "oportunidades": 21,
    "cierres": 110,
    "perdidas": 23,
    "pendientes": 3,
    "sin_gestion": 16,
    "tpv_m0": 878977235,
    "tpv_m1": 1089043321,
    "tasa_realizacion": 47.4,
    "tasa_cita_oportunidad": 12.14,
    "tasa_oportunidad_cierre": 523.81,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-07-27",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 191,
    "citas_realizadas": 88,
    "oportunidades": 58,
    "cierres": 78,
    "perdidas": 18,
    "pendientes": 10,
    "sin_gestion": 27,
    "tpv_m0": 514368173,
    "tpv_m1": 719603228,
    "tasa_realizacion": 46.07,
    "tasa_cita_oportunidad": 30.37,
    "tasa_oportunidad_cierre": 134.48,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  },
  {
    "semana_inicio": "2026-07-13",
    "periodo_analisis": "2026-06 a 2026-12",
    "citas_agendadas": 196,
    "citas_realizadas": 89,
    "oportunidades": 43,
    "cierres": 116,
    "perdidas": 14,
    "pendientes": 3,
    "sin_gestion": 20,
    "tpv_m0": 378897787,
    "tpv_m1": 879413352,
    "tasa_realizacion": 45.41,
    "tasa_cita_oportunidad": 21.94,
    "tasa_oportunidad_cierre": 269.77,
    "fecha_proceso": "2026-09-25T17:33:47.782Z"
  }
]
