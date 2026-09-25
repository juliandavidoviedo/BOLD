// n8n Code: Normalización SDR/LQL
// Mode: Run Once for All Items
function clean(v) {
    if (v === null || v === undefined) return null;
    const s = String(v).trim();
    return ['', '-', 'n/a', '#n/a'].includes(s.toLowerCase()) ? null : s;
}

function norm(v) {
    return String(v ?? '').trim().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

function num(v) {
    if (v === null || v === undefined || v === '') return 0;
    let s = String(v).replace(/\$/g, '').replace(/\s/g, '').trim();
    if (s.includes('.') && s.includes(',')) s = s.replace(/\./g, '').replace(',', '.');
    else if (s.includes(',')) s = s.replace(',', '.');
    else if (/^\d{1,3}(\.\d{3})+$/.test(s)) s = s.replace(/\./g, '');
    const n = Number(s);
    return Number.isFinite(n) ? n : 0;
}

function yes(v) {
    return ['si', 'sí', 'yes', 'true', '1'].includes(norm(v));
}

function date(v) {
    const original = clean(v);
    if (!original) return {
        original: null,
        iso: null,
        valid: false,
        error: false
    };
    const s = original.trim();
    let m = s.match(/^(\d{1,2})[\/-](\d{1,2})[\/-](\d{4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$/);
    if (m) {
        const [, d, mo, y, h = '0', mi = '0', se = '0'] = m;
        const x = new Date(+y, +mo - 1, +d, +h, +mi, +se);
        const ok = x.getFullYear() == +y && x.getMonth() == +mo - 1 && x.getDate() == +d;
        return ok ? {
            original,
            iso: x.toISOString(),
            valid: true,
            error: false
        } : {
            original,
            iso: null,
            valid: false,
            error: true
        };
    }
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
    m = s.toLowerCase().match(/^(\d{1,2})\s+([a-záéíóú]+)\s+(\d{4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$/);
    if (m) {
        const [, d, mt, y, h = '0', mi = '0', se = '0'] = m;
        const x = new Date(+y, months[mt], +d, +h, +mi, +se);
        if (months[mt] !== undefined && !Number.isNaN(x.getTime())) return {
            original,
            iso: x.toISOString(),
            valid: true,
            error: false
        };
    }
    if (/^\d{4}-\d{2}-\d{2}/.test(s)) {
        const x = new Date(s);
        if (!Number.isNaN(x.getTime())) return {
            original,
            iso: x.toISOString(),
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

function pick(r, names) {
    for (const n of names)
        if (Object.prototype.hasOwnProperty.call(r, n)) return r[n];
    return null;
}
const out = [];
const now = new Date();
for (let i = 0; i < $input.all().length; i++) {
    const r = $input.all()[i].json;
    const idFuente = clean(r['ID']),
        idEvento = clean(r['ID del evento']),
        idComercio = clean(r['Documento NIT / CC']);
    const empresa = clean(r['Empresa']);
    const ejecutivoSDR = clean(r['Executive SDR / LTQ']),
        ejecutivoAsignado = clean(r['Ejecutivo asignado']),
        teamLead = clean(r['Team Lead']),
        manager = clean(r['Manager']);
    const fc = date(r['Fecha de la cita']),
        fa = date(r['Fecha agendo']),
        fci = date(r['Fecha de cierre venta']),
        fop = date(r['Dia Ultima Act OP']),
        ftrx = date(r['Fecha 1 TRX general']);
    const estadoCita = clean(r['Estado Cita']),
        estadoOPOriginal = clean(r['Ultimo estado OP']),
        estadoOP = norm(estadoOPOriginal),
        realizada = yes(r['Realizaste la cita']);
    const op = num(r['Conteo OP']),
        cierre = num(r['Conteo Cierre']),
        tpvM0 = num(r['TPV M0']),
        tpvM1 = num(r['TPV M1']);
    const calRaw = r['Calificación Cita'];
    const cal = calRaw === null || calRaw === undefined || calRaw === '' ? null : num(calRaw);
    let estadoComercial;
    if (cierre > 0 || fci.valid) estadoComercial = 'Cierre';
    else if (estadoOP === 'perdida') estadoComercial = 'Perdida';
    else if (op > 0 || ['ganada', 'cerrada'].includes(estadoOP)) estadoComercial = 'Oportunidad';
    else if (realizada) estadoComercial = 'Pendiente';
    else estadoComercial = 'Sin gestión';
    const fechaCita = fc.iso ? new Date(fc.iso) : null;
    const futura = !!fechaCita && !Number.isNaN(fechaCita.getTime()) && fechaCita > now;
    const esOportunidad = op > 0 || ['ganada', 'cerrada', 'perdida'].includes(estadoOP);
    const esCierre = cierre > 0 || estadoComercial === 'Cierre' || estadoCita === 'Cierre Exitoso';
    const outlier = esCierre && !esOportunidad;
    const inconsistencia = esCierre && !realizada;
    const excepcion = futura || outlier || inconsistencia || !fc.valid;
    const calidad = (!empresa || !idComercio || (!ejecutivoSDR && !ejecutivoAsignado) || !fc.valid) ? 'Revisar' : 'OK';
    out.push({
        json: {
            id_cita: idEvento || [idComercio, fc.original, ejecutivoAsignado || ejecutivoSDR].filter(Boolean).join('|') || `fila_${i+1}`,
            id_evento: idEvento,
            id_fuente: idFuente,
            id_comercio: idComercio,
            empresa,
            ciudad: clean(r['Ciudad']),
            direccion: clean(r['Dirección']),
            fecha_cita_original: fc.original,
            fecha_cita_iso: fc.iso,
            fecha_agendo_original: fa.original,
            fecha_agendo_iso: fa.iso,
            fecha_cierre_original: fci.original,
            fecha_cierre_iso: fci.iso,
            fecha_ultima_actividad_op_original: fop.original,
            fecha_ultima_actividad_op_iso: fop.iso,
            fecha_primera_trx_original: ftrx.original,
            fecha_primera_trx_iso: ftrx.iso,
            ejecutivo_sdr: ejecutivoSDR,
            ejecutivo_asignado: ejecutivoAsignado,
            team_lead: teamLead,
            manager,
            correo_manager: clean(r['Correo Manager']),
            correo_team_lead: clean(r['Correo TL']),
            correo_tl_sdr: clean(r['Correo TL SDR']),
            equipo: clean(r['Equipo']),
            modelo_cita: clean(r['Modelo de la cita']),
            canal: clean(pick(r, ['Canal actual de la venta', 'Canal', 'Canal de venta'])),
            origen_lead: clean(pick(r, ['ORIGEN LEAD', 'Origen Lead', 'Origen del lead'])),
            producto_interes: clean(r['Productos de interés:']),
            estado_cita: estadoCita,
            cita_realizada: realizada,
            califica_cita: clean(r['Califica esta cita']),
            calificacion_cita: cal,
            estado_oportunidad: estadoOPOriginal,
            estado_comercial: estadoComercial,
            conteo_op: op,
            conteo_cierre: cierre,
            tpv_esperado: num(r['TPV Esperado']),
            tpv_m0: tpvM0,
            tpv_m1: tpvM1,
            es_oportunidad: esOportunidad,
            es_cierre: esCierre,
            cita_futura: futura,
            outlier_embudo: outlier,
            inconsistencia_realizacion: inconsistencia,
            registro_excepcion: excepcion,
            periodo_analisis: '2026-06 a 2026-12',
            fecha_proceso: new Date().toISOString(),
            calidad_registro: calidad,
            nivel_calidad: calidad === 'Revisar' ? 'Crítico' : (!ftrx.valid ? 'Advertencia' : 'OK'),
            calidad: {
                falta_empresa: !empresa,
                falta_identificador: !idComercio,
                falta_ejecutivo: !ejecutivoSDR && !ejecutivoAsignado,
                falta_team_lead: !teamLead,
                falta_fecha_cita: !fc.valid,
                falta_fecha_primera_trx: !ftrx.valid,
                error_fecha_cita: fc.error,
                error_fecha_cierre: fci.error,
                advertencia_sin_fecha_trx: !ftrx.valid
            }
        }
    });
}
return out;
