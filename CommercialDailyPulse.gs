/** Commercial Daily Pulse — bootstrap para Google Sheets + Google Forms
 *  Uso: pega este archivo en script.google.com, ejecuta setupCommercialDailyPulse() una vez.
 *  El formulario no pregunta fecha: la fecha/hora se toma del timestamp de envío.
 */
const CDP = { title: 'Commercial Daily Pulse — MVP', formTitle: 'Cierre diario SMB — POS, Crédito y Payments' };

function setupCommercialDailyPulse() {
  const ss = SpreadsheetApp.create(CDP.title);
  const config = ss.getSheets()[0].setName('CONFIG_LIDERES');
  config.getRange(1, 1, 1, 5).setValues([['lider_id','lider_nombre','zona','equipo','activo']]);
  config.getRange(2, 1, 6, 5).setValues([
    ['L001','Crhistian Osorio','Cali','SMB','Sí'], ['L002','Luis Costa','Costa','SMB','Sí'],
    ['L003','Carolina Santos','SMB','SMB','Sí'], ['L004','Carolina Daza','Costa','SMB','Sí'],
    ['L005','Juan Pablo','Cali','SMB','Sí'], ['L006','Santanderes','Santanderes','SMB','Sí']
  ]);
  const log = ss.insertSheet('LOG_CIERRE_DIARIO');
  const headers = ['timestamp','fecha_log','lider','zona','producto','radicados','aprobados','desembolsados','monto_desembolsado','demos_pos','cotizaciones_pos','ventas_pos','leads_payments','oportunidades_payments','tipo_envio','novedad','estado_validacion','observacion_validacion'];
  log.getRange(1,1,1,headers.length).setValues([headers]);
  const valid = ss.insertSheet('VALIDACION_CRM');
  valid.getRange(1,1,1,10).setValues([['fecha_log','lider','producto','metrica','reportado','crm_metabase','crm_epic','diferencia','estado','ultima_consulta']]);
  const summary = ss.insertSheet('RESUMEN_DIARIO');
  summary.getRange('A1').setValue('Commercial Daily Pulse — resumen operativo');
  summary.getRange('A3:E3').setValues([['Líder','Zona','Reportó','Radicados','Estado']]);
  summary.getRange('A4').setFormula('=FILTER(CONFIG_LIDERES!B2:B,CONFIG_LIDERES!E2:E="Sí")');
  summary.getRange('B4').setFormula('=FILTER(CONFIG_LIDERES!C2:C,CONFIG_LIDERES!E2:E="Sí")');
  summary.getRange('C4').setFormula('=ARRAYFORMULA(IF(A4:A="","",COUNTIFS(LOG_CIERRE_DIARIO!C:C,A4:A,LOG_CIERRE_DIARIO!B:B,TODAY())))');
  summary.getRange('D4').setFormula('=ARRAYFORMULA(IF(A4:A="","",SUMIFS(LOG_CIERRE_DIARIO!F:F,LOG_CIERRE_DIARIO!C:C,A4:A,LOG_CIERRE_DIARIO!B:B,TODAY())))');
  summary.getRange('E4').setFormula('=ARRAYFORMULA(IF(A4:A="","",IF(C4:C=0,"Pendiente",IF(D4:D<10,"Bajo meta","En meta"))))');
  [config,log,valid,summary].forEach(s => { s.setFrozenRows(1); s.autoResizeColumns(1, Math.min(s.getMaxColumns(), 18)); });
  const form = FormApp.create(CDP.formTitle).setDescription('Un envío por líder y día. La fecha se registra automáticamente al enviar. Si corriges, selecciona Corrección.');
  const leaderItem = form.addListItem().setTitle('Líder comercial').setRequired(true);
  form.addListItem().setTitle('Zona').setChoiceValues(['Cali','Costa','SMB','Santanderes','Eje y Tolima']).setRequired(true);
  form.addListItem().setTitle('Producto').setChoiceValues(['Crédito','POS','Payments']).setRequired(true);
  form.addTextItem().setTitle('Radicados de Crédito').setHelpText('Cantidad del día; si no aplica, escribe 0').setRequired(true);
  form.addTextItem().setTitle('Aprobados de Crédito').setRequired(true);
  form.addTextItem().setTitle('Desembolsados de Crédito').setRequired(true);
  form.addTextItem().setTitle('Monto desembolsado').setRequired(true);
  form.addTextItem().setTitle('Demos POS').setRequired(true);
  form.addTextItem().setTitle('Cotizaciones POS').setRequired(true);
  form.addTextItem().setTitle('Ventas POS').setRequired(true);
  form.addTextItem().setTitle('Leads Payments').setRequired(true);
  form.addTextItem().setTitle('Oportunidades Payments').setRequired(true);
  form.addMultipleChoiceItem().setTitle('Tipo de envío').setChoiceValues(['Inicial','Corrección']).setRequired(true);
  form.addParagraphTextItem().setTitle('Novedad del día');
  leaderItem.setChoiceValues(getActiveLeaders_(config));
  PropertiesService.getScriptProperties().setProperties({CDP_SS_ID:ss.getId(),CDP_FORM_ID:form.getId()});
  ScriptApp.newTrigger('onCdpFormSubmit').forForm(form).onFormSubmit().create();
  ScriptApp.newTrigger('refreshLeaderChoices').timeBased().everyHours(1).create();
  Logger.log('SHEET: '+ss.getUrl()); Logger.log('FORM: '+form.getPublishedUrl());
}

function getActiveLeaders_(config) { return config.getRange(2,2,Math.max(config.getLastRow()-1,1),4).getValues().filter(r => r[0] && r[3] === 'Sí').map(r => r[0]); }

function refreshLeaderChoices() {
  const p = PropertiesService.getScriptProperties(); const ss = SpreadsheetApp.openById(p.getProperty('CDP_SS_ID')); const form = FormApp.openById(p.getProperty('CDP_FORM_ID')); const config = ss.getSheetByName('CONFIG_LIDERES');
  form.getItems(FormApp.ItemType.LIST).find(i => i.getTitle() === 'Líder comercial').asListItem().setChoiceValues(getActiveLeaders_(config));
}

function onCdpFormSubmit(e) {
  const p = PropertiesService.getScriptProperties(); const ss = SpreadsheetApp.openById(p.getProperty('CDP_SS_ID')); const log = ss.getSheetByName('LOG_CIERRE_DIARIO');
  const v = e.namedValues; const ts = new Date(e.values[0]); const date = Utilities.formatDate(ts, Session.getScriptTimeZone() || 'America/Bogota', 'yyyy-MM-dd');
  const n = k => Number((v[k] || ['0'])[0].replace(/[^0-9.-]/g,'')) || 0; const text = k => (v[k] || [''])[0];
  log.appendRow([ts,date,text('Líder comercial'),text('Zona'),text('Producto'),n('Radicados de Crédito'),n('Aprobados de Crédito'),n('Desembolsados de Crédito'),n('Monto desembolsado'),n('Demos POS'),n('Cotizaciones POS'),n('Ventas POS'),n('Leads Payments'),n('Oportunidades Payments'),text('Tipo de envío'),text('Novedad del día'),'Pendiente de validación','']);
}
