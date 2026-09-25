function clean(value) {
  if (value === null || value === undefined) return null;

  const text = String(value).trim();

  if (text === '' || text === '-' || text.toLowerCase() === 'n/a') {
    return null;
  }

  return text;
}

function numberValue(value) {
  if (value === null || value === undefined || value === '') return 0;

  const normalized = String(value)
    .replace(/\$/g, '')
    .replace(/\./g, '')
    .replace(/,/g, '.')
    .trim();

  const number = Number(normalized);

  return Number.isFinite(number) ? number : 0;
}

function yes(value) {
  return ['si', 'sí', 'yes', 'true', '1'].includes(
    String(value ?? '').trim().toLowerCase()
  );
}

function normalizeStatus(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

return $input.all().map((item, index) => {
  const r = item.json;

  const fechaCita = clean(r['Fecha de la cita']);
  const estadoCita = normalizeStatus(r['Estado Cita']);
  const estadoOP = normalizeStatus(r['Ultimo estado OP']);

  const conteoOP = numberValue(r['Conteo OP']);
  const conteoCierre = numberValue(r['Conteo Cierre']);
  const tpvM0 = numberValue(r['TPV M0']);
  const tpvM1 = numberValue(r['TPV M1']);
  const calificacion = numberValue(r['Calificación Cita']);

  const realizada = yes(r['Realizaste la cita']);

  let estadoComercial = 'Pendiente de clasificar';

  if (conteoCierre > 0 || clean(r['Fecha de cierre venta'])) {
    estadoComercial = 'Cierre';
  } else if (conteoOP > 0 || estadoOP === 'ganada') {
    estadoComercial = 'Oportunidad';
  } else if (estadoOP === 'perdida') {
    estadoComercial = 'Perdida';
  } else if (realizada) {
    estadoComercial = 'Pendiente';
  }

  return {
    json: {
      id_registro: clean(r['ID']) || `fila_${index + 1}`,
      id_evento: clean(r['ID del evento']),
      id_comercio: clean(r['Documento NIT / CC']),
      empresa: clean(r['Empresa']),

      fecha_cita: fechaCita,
      fecha_agendo: clean(r['Fecha agendo']),
      fecha_cierre: clean(r['Fecha de cierre venta']),
      fecha_ultima_actividad_op: clean(r['Dia Ultima Act OP']),
      fecha_primera_trx: clean(r['Fecha 1 TRX general']),

      ejecutivo_sdr: clean(r['Executive SDR / LTQ']),
      ejecutivo_asignado: clean(r['Ejecutivo asignado']),
      team_lead: clean(r['Team Lead']),
      manager: clean(r['Manager']),

      correo_manager: clean(r['Correo Manager']),
      correo_team_lead: clean(r['Correo TL']),
      correo_tl_sdr: clean(r['Correo TL SDR']),

      canal: clean(r['Canal actual de la venta']),
      origen_lead: clean(r['ORIGEN LEAD']),
      equipo: clean(r['Equipo']),

      estado_cita: clean(r['Estado Cita']),
      estado_oportunidad: clean(r['Ultimo estado OP']),
      estado_comercial: estadoComercial,

      cita_realizada: realizada,
      calificacion_cita: calificacion || null,

      conteo_op: conteoOP,
      conteo_cierre: conteoCierre,
      tpv_m0: tpvM0,
      tpv_m1: tpvM1,

      periodo_analisis: '2026-06 a 2026-12',
      fecha_proceso: new Date().toISOString(),

      _calidad: {
        falta_empresa: !clean(r['Empresa']),
        falta_identificador: !clean(r['Documento NIT / CC']),
        falta_ejecutivo: !clean(r['Ejecutivo asignado']) &&
                         !clean(r['Executive SDR / LTQ']),
        falta_fecha_cita: !fechaCita,
        falta_team_lead: !clean(r['Team Lead'])
      }
    }
  };
});
