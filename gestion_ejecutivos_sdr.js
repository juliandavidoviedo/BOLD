// n8n Code: Gestion ejecutivos SDR
// Mode: Run Once for All Items

const rows = $input.all().map(item => item.json);
const groups = {};
const snapshotDate = new Date();

function bool(value) {
  return value === true || value === 'true' || value === 1 || value === '1';
}

function num(value) {
  const result = Number(value || 0);
  return Number.isFinite(result) ? result : 0;
}

function pct(a, b) {
  return b ? Number(((a / b) * 100).toFixed(2)) : 0;
}

function status(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

for (const row of rows) {
  const ejecutivo =
    row.ejecutivo_asignado ||
    row.ejecutivo_sdr ||
    'Sin ejecutivo';

  const teamLead = row.team_lead || 'Sin Team Lead';
  const manager = row.manager || 'Sin manager';

  const key = `${ejecutivo}|${teamLead}|${manager}`;

  if (!groups[key]) {
    groups[key] = {
      ejecutivo,
      team_lead: teamLead,
      manager,
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

  const appointmentDate = row.fecha_cita_iso
    ? new Date(row.fecha_cita_iso)
    : null;

  const futureAppointment =
    bool(row.cita_futura) ||
    (appointmentDate && appointmentDate > snapshotDate);

  if (futureAppointment) {
    kpi.citas_futuras++;
  } else if (bool(row.cita_realizada)) {
    kpi.citas_realizadas++;
  }

  const opportunity = row.es_oportunidad !== undefined
    ? bool(row.es_oportunidad)
    : num(row.conteo_op) > 0 ||
      ['ganada', 'cerrada', 'perdida'].includes(
        status(row.estado_oportunidad)
      );

  const closure = row.es_cierre !== undefined
    ? bool(row.es_cierre)
    : num(row.conteo_cierre) > 0 ||
      row.estado_comercial === 'Cierre' ||
      row.estado_cita === 'Cierre Exitoso';

  if (opportunity) kpi.oportunidades++;
  if (closure) kpi.cierres++;
  if (row.estado_comercial === 'Perdida') kpi.perdidas++;
  if (row.estado_comercial === 'Pendiente') kpi.pendientes++;
  if (row.estado_comercial === 'Sin gestión') kpi.sin_gestion++;

  if (bool(row.registro_excepcion)) kpi.excepciones++;
  if (bool(row.outlier_embudo)) kpi.outliers_embudo++;
  if (bool(row.inconsistencia_realizacion)) {
    kpi.inconsistencias_realizacion++;
  }

  kpi.tpv_m0 += Math.round(num(row.tpv_m0));
  kpi.tpv_m1 += Math.round(num(row.tpv_m1));
}

return Object.values(groups)
  .sort((a, b) =>
    `${a.manager}|${a.team_lead}|${a.ejecutivo}`
      .localeCompare(`${b.manager}|${b.team_lead}|${b.ejecutivo}`)
  )
  .map(kpi => ({
    json: {
      ...kpi,
      tasa_realizacion: pct(
        kpi.citas_realizadas,
        kpi.citas_agendadas - kpi.citas_futuras
      ),
      tasa_cita_oportunidad: pct(
        kpi.oportunidades,
        kpi.citas_agendadas
      ),
      tasa_oportunidad_cierre: pct(
        kpi.cierres,
        kpi.oportunidades
      ),
      fecha_proceso: new Date().toISOString()
    }
  }));
