const START = new Date('2026-06-01T00:00:00');
const END = new Date('2026-10-01T00:00:00');

const months = {
  ene: 0, enero: 0,
  feb: 1, febrero: 1,
  mar: 2, marzo: 2,
  abr: 3, abril: 3,
  may: 4, mayo: 4,
  jun: 5, junio: 5,
  jul: 6, julio: 6,
  ago: 7, agosto: 7,
  sep: 8, sept: 8, septiembre: 8,
  oct: 9, octubre: 9,
  nov: 10, noviembre: 10,
  dic: 11, diciembre: 11
};

function parseDate(value) {
  if (!value) return null;

  const text = String(value).trim();

  let match = text.match(
    /^(\d{1,2})\s+([a-záéíóú]+)\s+(\d{4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$/
  );

  if (match) {
    const [
      ,
      day,
      monthText,
      year,
      hour = '0',
      minute = '0',
      second = '0'
    ] = match;

    if (months[monthText] !== undefined) {
      return new Date(
        Number(year),
        months[monthText],
        Number(day),
        Number(hour),
        Number(minute),
        Number(second)
      );
    }
  }

  match = text.match(
    /^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})/
  );

  if (match) {
    return new Date(
      Number(match[3]),
      Number(match[2]) - 1,
      Number(match[1])
    );
  }

  if (/^\d{4}-\d{2}-\d{2}/.test(text)) {
    const date = new Date(text);
    return Number.isNaN(date.getTime()) ? null : date;
  }

  return null;
}

const output = [];

for (const item of $input.all()) {
  const row = item.json;
  const date = parseDate(row['Fecha de la cita']);

  if (date && date >= START && date < END) {
    output.push({
      json: {
        ...row,
        fecha_cita_filtro_iso: date.toISOString(),
        periodo_filtro: '2026-06 a 2026-09'
      }
    });
  }
}

return output;
