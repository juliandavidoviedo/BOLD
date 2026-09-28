const rows = $input.all().map(item => item.json);

const months = {
  ene: 1, enero: 1,
  feb: 2, febrero: 2,
  mar: 3, marzo: 3,
  abr: 4, abril: 4,
  may: 5, mayo: 5,
  jun: 6, junio: 6,
  jul: 7, julio: 7,
  ago: 8, agosto: 8,
  sep: 9, sept: 9, septiembre: 9,
  oct: 10, octubre: 10,
  nov: 11, noviembre: 11,
  dic: 12, diciembre: 12
};

function parseMonthYear(value) {
  if (!value) return null;

  const text = String(value).trim();

  // ISO: 2026-06-02
  let match = text.match(/^(\d{4})-(\d{2})-(\d{2})/);

  if (match) {
    return {
      year: Number(match[1]),
      month: Number(match[2]),
      source: 'ISO'
    };
  }

  // Español: 2 jun 2026 11:30:00
  match = text.toLowerCase().match(
    /^(\d{1,2})\s+([a-záéíóú]+)\s+(\d{4})/
  );

  if (match && months[match[2]]) {
    return {
      year: Number(match[3]),
      month: months[match[2]],
      source: 'ES'
    };
  }

  // Colombia: 15/06/2026
  match = text.match(
    /^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})/
  );

  if (match) {
    return {
      year: Number(match[3]),
      month: Number(match[2]),
      source: 'DD/MM/YYYY'
    };
  }

  return null;
}

const byMonth = {};
const byYearField = {};
const invalidDates = [];
const samples = {};

for (const row of rows) {
  const rawDate = row['Fecha de la cita'];
  const parsed = parseMonthYear(rawDate);

  const yearField =
    row['Año Cita'] ??
    row['Año de la cita'] ??
    row['Año de cita'] ??
    'SIN_CAMPO';

  const yearKey = String(yearField).trim() || 'VACIO';
  byYearField[yearKey] = (byYearField[yearKey] || 0) + 1;

  if (!parsed) {
    invalidDates.push({
      fecha_cita: rawDate ?? null,
      empresa: row['Empresa'] ?? null,
      id_evento: row['ID del evento'] ?? null
    });
    continue;
  }

  const monthKey =
    `${parsed.year}-${String(parsed.month).padStart(2, '0')}`;

  byMonth[monthKey] = (byMonth[monthKey] || 0) + 1;

  if (!samples[monthKey]) {
    samples[monthKey] = {
      fecha_cita: rawDate,
      anio_campo: yearField,
      empresa: row['Empresa'] ?? null
    };
  }
}

return [
  {
    json: {
      etapa: 'diagnostico',
      fecha_ejecucion: new Date().toISOString(),
      total_registros: rows.length,
      distribucion_por_mes: byMonth,
      distribucion_campo_anio: byYearField,
      fechas_invalidas: invalidDates.length,
      muestras_fechas_invalidas: invalidDates.slice(0, 20),
      muestras_por_mes: samples,
      total_jun_sep_2026:
        Object.entries(byMonth)
          .filter(([key]) =>
            key >= '2026-06' && key <= '2026-09'
          )
          .reduce((sum, [, value]) => sum + value, 0),
      total_jun_dic_2026:
        Object.entries(byMonth)
          .filter(([key]) =>
            key >= '2026-06' && key <= '2026-12'
          )
          .reduce((sum, [, value]) => sum + value, 0)
    }
  }
];
