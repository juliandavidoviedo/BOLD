// n8n Code: KPI semanal SDR
// Mode: Run Once for All Items
const rows = $input.all().map(i => i.json),
    groups = {},
    snapshot = new Date();

function week(iso) {
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return null;
    const day = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() - day + 1);
    return d.toISOString().slice(0, 10);
}

function pct(a, b) {
    return b ? Number(((a / b) * 100).toFixed(2)) : 0;
}

function bool(v) {
    return v === true || v === 'true' || v === 1 || v === '1';
}

function num(v) {
    const n = Number(v || 0);
    return Number.isFinite(n) ? n : 0;
}

function status(v) {
    return String(v ?? '').trim().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}
for (const r of rows) {
    if (!r.fecha_cita_iso) continue;
    const w = week(r.fecha_cita_iso);
    if (!w) continue;
    const key = `${w}|${r.periodo_analisis||'Sin periodo'}`;
    if (!groups[key]) groups[key] = {
        semana_inicio: w,
        periodo_analisis: r.periodo_analisis || 'Sin periodo',
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
    const k = groups[key];
    k.citas_agendadas++;
    const futura = bool(r.cita_futura) || (new Date(r.fecha_cita_iso) > snapshot);
    if (futura) k.citas_futuras++;
    else if (bool(r.cita_realizada)) k.citas_realizadas++;
    const op = r.es_oportunidad !== undefined ? bool(r.es_oportunidad) : num(r.conteo_op) > 0 || ['ganada', 'cerrada', 'perdida'].includes(status(r.estado_oportunidad));
    const cierre = r.es_cierre !== undefined ? bool(r.es_cierre) : num(r.conteo_cierre) > 0 || r.estado_comercial === 'Cierre' || r.estado_cita === 'Cierre Exitoso';
    if (op) k.oportunidades++;
    if (cierre) k.cierres++;
    if (r.estado_comercial === 'Perdida') k.perdidas++;
    if (r.estado_comercial === 'Pendiente') k.pendientes++;
    if (r.estado_comercial === 'Sin gestión') k.sin_gestion++;
    if (bool(r.registro_excepcion)) k.excepciones++;
    if (bool(r.outlier_embudo)) k.outliers_embudo++;
    if (bool(r.inconsistencia_realizacion)) k.inconsistencias_realizacion++;
    k.tpv_m0 += Math.round(num(r.tpv_m0));
    k.tpv_m1 += Math.round(num(r.tpv_m1));
}
return Object.values(groups).sort((a, b) => a.semana_inicio.localeCompare(b.semana_inicio)).map(k => ({
    json: {
        ...k,
        tasa_realizacion: pct(k.citas_realizadas, k.citas_agendadas - k.citas_futuras),
        tasa_cita_oportunidad: pct(k.oportunidades, k.citas_agendadas),
        tasa_oportunidad_cierre: pct(k.cierres, k.oportunidades),
        fecha_proceso: new Date().toISOString()
    }
}));
