// n8n Code node
// Mode: Run Once for All Items

function clean(value) {
  if (value === null || value === undefined) return null;

  const text = String(value).trim();

  if (
    text === '' ||
    text === '-' ||
    text.toLowerCase() === 'n/a' ||
    text.toLowerCase() === '#n/a'
  ) {
    return null;
  }

  return text;
}

function normalizeText(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');
}

function parseNumber(value) {
  if (value === null || value === undefined || value === '') return 0;

  let text = String(value)
    .replace(/\$/g, '')
    .replace(/\s/g, '')
    .trim();

  if (!text || text === '-') return 0;

  if (text.includes('.') && text.includes(',')) {
    text = text.replace(/\./g, '').replace(',', '.');
  } else if (text.includes(',')) {
    text = text.replace(',', '.');
  } else if (/^\d{1,3}(\.\d{3})+$/.test(text)) {
    text = text.replace(/\./g, '');
  }

  const number = Number(text);
  return Number.isFinite(number) ? number : 0;
}

function isYes(value) {
  return ['si', 'sí', 'yes', 'true', '1'].includes(
    normalizeText(value)
  );
}

function parseDate(value) {
  const original = clean(value);

  if (!original) {
    return {
      original: null,
      iso: null,
      valid: false,
      error: false
    };
  }

  const text = original.trim();

  /*
   * 1. Fechas numéricas colombianas.
   * Se procesa primero para evitar que JavaScript interprete
   * 4/12/2025 como 12 de abril en lugar de 4 de diciembre.
   */
  const numericDate = text.match(
    /^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$/
  );

  if (numericDate) {
    const [
      ,
      day,
      month,
      year,
      hour = '0',
      minute = '0',
      second = '0'
    ] = numericDate;

    const date = new Date(
      Number(year),
      Number(month) - 1,
      Number(day),
      Number(hour),
      Number(minute),
      Number(second)
    );

    const validDate =
      date.getFullYear() === Number(year) &&
      date.getMonth() === Number(month) - 1 &&
      date.getDate() === Number(day);

    if (validDate) {
      return {
        original,
        iso: date.toISOString(),
        valid: true,
        error: false
      };
    }

    return {
      original,
      iso: null,
      valid: false,
      error: true
    };
  }

  /*
   * 2. Fechas en español.
   * Ejemplo: 2 jun 2026 11:30:00
   */
  const months = {
    ene: 0,
    enero: 0,
    feb: 1,
    febrero: 1,
    mar: 2,
    marzo: 2,
    abr: 3,
    abril: 3,
    may: 4,
    mayo: 4,
    jun: 5,
    junio: 5,
    jul: 6,
    julio: 6,
    ago: 7,
    agosto: 7,
    sep: 8,
    sept: 8,
    septiembre: 8,
    oct: 9,
    octubre: 9,
    nov: 10,
    noviembre: 10,
    dic: 11,
    diciembre: 11
  };

  const spanishDate = text.toLowerCase().match(
    /^(\d{1,2})\s+([a-záéíóú]+)\s+(\d{4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$/
  );

  if (spanishDate) {
    const [
      ,
      day,
      monthText,
      year,
      hour = '0',
      minute = '0',
      second = '0'
    ] = spanishDate;

    const month = months[monthText];

    if (month !== undefined) {
      const date = new Date(
        Number(year),
        month,
        Number(day),
        Number(hour),
        Number(minute),
        Number(second)
      );

      const validDate =
        date.getFullYear() === Number(year) &&
        date.getMonth() === month &&
        date.getDate() === Number(day);

      if (validDate) {
        return {
          original,
          iso: date.toISOString(),
          valid: true,
          error: false
        };
      }
    }

    return {
      original,
      iso: null,
      valid: false,
      error: true
    };
  }

  /*
   * 3. ISO.
   * Sólo se permite parseo automático si comienza con YYYY-MM-DD.
   */
  if (/^\d{4}-\d{2}-\d{2}/.test(text)) {
    const date = new Date(text);

    if (!Number.isNaN(date.getTime())) {
      return {
        original,
        iso: date.toISOString(),
        valid: true,
        error: false
      };
    }
  }

  return {
    original,
    iso: null,
    valid: false,
    error: true
  };
}

function getValue(row, names) {
  for (const name of names) {
    if (Object.prototype.hasOwnProperty.call(row, name)) {
      return row[name];
    }
  }

  return null;
}

const output = [];

for (let index = 0; index < $input.all().length; index++) {
  const row = $input.all()[index].json;

  const idFuente = clean(row['ID']);
  const idEvento = clean(row['ID del evento']);
  const idComercio = clean(row['Documento NIT / CC']);

  const empresa = clean(row['Empresa']);
  const ejecutivoSDR = clean(row['Executive SDR / LTQ']);
  const ejecutivoAsignado = clean(row['Ejecutivo asignado']);
  const teamLead = clean(row['Team Lead']);
  const manager = clean(row['Manager']);

  const fechaCita = parseDate(row['Fecha de la cita']);
  const fechaAgendo = parseDate(row['Fecha agendo']);
  const fechaCierre = parseDate(row['Fecha de cierre venta']);
  const fechaUltimaActividadOP = parseDate(row['Dia Ultima Act OP']);
  const fechaPrimeraTRX = parseDate(row['Fecha 1 TRX general']);

  const estadoCita = clean(row['Estado Cita']);
  const estadoOPOriginal = clean(row['Ultimo estado OP']);
  const estadoOP = normalizeText(estadoOPOriginal);

  const realizada = isYes(row['Realizaste la cita']);

  const conteoOP = parseNumber(row['Conteo OP']);
  const conteoCierre = parseNumber(row['Conteo Cierre']);

  const tpvEsperado = parseNumber(row['TPV Esperado']);
  const tpvM0 = parseNumber(row['TPV M0']);
  const tpvM1 = parseNumber(row['TPV M1']);

  const calificacionRaw = row['Calificación Cita'];
  const calificacion =
    calificacionRaw === null ||
    calificacionRaw === undefined ||
    calificacionRaw === ''
      ? null
      : parseNumber(calificacionRaw);

  const idCita =
    idEvento ||
    [
      idComercio,
      fechaCita.original,
      ejecutivoAsignado || ejecutivoSDR
    ]
      .filter(Boolean)
      .join('|');

  /*
   * La prioridad es intencional:
   * Cierre > Perdida > Oportunidad > Pendiente > Sin gestión
   */
  let estadoComercial;

  if (conteoCierre > 0 || fechaCierre.valid) {
    estadoComercial = 'Cierre';
  } else if (estadoOP === 'perdida') {
    estadoComercial = 'Perdida';
  } else if (
    conteoOP > 0 ||
    estadoOP === 'ganada' ||
    estadoOP === 'cerrada'
  ) {
    estadoComercial = 'Oportunidad';
  } else if (realizada) {
    estadoComercial = 'Pendiente';
  } else {
    estadoComercial = 'Sin gestión';
  }

  const faltaEmpresa = !empresa;
  const faltaIdentificador = !idComercio;
  const faltaEjecutivo = !ejecutivoSDR && !ejecutivoAsignado;
  const faltaFechaCita = !fechaCita.valid;
  const faltaTeamLead = !teamLead;
  const faltaFechaTRX = !fechaPrimeraTRX.valid;

  const errorFechaCita = fechaCita.error;
  const errorFechaAgendo = fechaAgendo.error;
  const errorFechaCierre = fechaCierre.error;
  const errorFechaActividadOP = fechaUltimaActividadOP.error;
  const errorFechaTRX = fechaPrimeraTRX.error;

  const registroRequiereRevision =
    faltaEmpresa ||
    faltaIdentificador ||
    faltaEjecutivo ||
    faltaFechaCita ||
    errorFechaCita;

  const calidadRegistro = registroRequiereRevision
    ? 'Revisar'
    : 'OK';

  const nivelCalidad = registroRequiereRevision
    ? 'Crítico'
    : faltaFechaTRX
      ? 'Advertencia'
      : 'OK';

  output.push({
    json: {
      // Identificación
      id_cita: idCita || `fila_${index + 1}`,
      id_evento: idEvento,
      id_fuente: idFuente,
      id_comercio: idComercio,

      // Comercio
      empresa,
      ciudad: clean(row['Ciudad']),
      direccion: clean(row['Dirección']),

      // Fechas originales
      fecha_cita_original: fechaCita.original,
      fecha_agendo_original: fechaAgendo.original,
      fecha_cierre_original: fechaCierre.original,
      fecha_ultima_actividad_op_original:
        fechaUltimaActividadOP.original,
      fecha_primera_trx_original: fechaPrimeraTRX.original,

      // Fechas normalizadas ISO
      fecha_cita_iso: fechaCita.iso,
      fecha_agendo_iso: fechaAgendo.iso,
      fecha_cierre_iso: fechaCierre.iso,
      fecha_ultima_actividad_op_iso:
        fechaUltimaActividadOP.iso,
      fecha_primera_trx_iso: fechaPrimeraTRX.iso,

      // Responsables
      ejecutivo_sdr: ejecutivoSDR,
      ejecutivo_asignado: ejecutivoAsignado,
      team_lead: teamLead,
      manager,

      correo_manager: clean(row['Correo Manager']),
      correo_team_lead: clean(row['Correo TL']),
      correo_tl_sdr: clean(row['Correo TL SDR']),

      // Segmentación
      equipo: clean(row['Equipo']),
      modelo_cita: clean(row['Modelo de la cita']),
      canal: clean(
        getValue(row, [
          'Canal actual de la venta',
          'Canal',
          'Canal de venta'
        ])
      ),
      origen_lead: clean(
        getValue(row, [
          'ORIGEN LEAD',
          'Origen Lead',
          'Origen del lead'
        ])
      ),
      producto_interes: clean(row['Productos de interés:']),

      // Cita
      estado_cita: estadoCita,
      cita_realizada: realizada,
      califica_cita: clean(row['Califica esta cita']),
      calificacion_cita: calificacion,

      // Embudo
      estado_oportunidad: estadoOPOriginal,
      estado_comercial: estadoComercial,
      conteo_op: conteoOP,
      conteo_cierre: conteoCierre,

      // TPV
      tpv_esperado: tpvEsperado,
      tpv_m0: tpvM0,
      tpv_m1: tpvM1,

      // Control de ejecución
      periodo_analisis: '2026-06 a 2026-12',
      fecha_proceso: new Date().toISOString(),

      // Calidad
      calidad_registro: calidadRegistro,
      nivel_calidad: nivelCalidad,

      calidad: {
        falta_empresa: faltaEmpresa,
        falta_identificador: faltaIdentificador,
        falta_ejecutivo: faltaEjecutivo,
        falta_fecha_cita: faltaFechaCita,
        falta_team_lead: faltaTeamLead,
        falta_fecha_primera_trx: faltaFechaTRX,

        fecha_cita_valida: fechaCita.valid,
        fecha_agendo_valida: fechaAgendo.valid,
        fecha_cierre_valida: fechaCierre.valid,
        fecha_ultima_actividad_op_valida:
          fechaUltimaActividadOP.valid,
        fecha_primera_trx_valida: fechaPrimeraTRX.valid,

        error_fecha_cita: errorFechaCita,
        error_fecha_agendo: errorFechaAgendo,
        error_fecha_cierre: errorFechaCierre,
        error_fecha_ultima_actividad_op:
          errorFechaActividadOP,
        error_fecha_primera_trx: errorFechaTRX,

        advertencia_sin_fecha_trx: faltaFechaTRX,
        advertencia_cierre_sin_fecha:
          estadoComercial === 'Cierre' && !fechaCierre.valid
      }
    }
  });
}

return output;
