/**
 * Handoff Comercial SMB -> Customer Success/KAM | Bold
 * V4.1 FINAL OPTIMIZADA — solo campos solicitados por Kathe Cardona
 *
 * Principio UX:
 * - No se pregunta nada que pueda venir de Metabase, financiero, transaccional o BASE_COMERCIOS.
 * - El Team Lead solo registra contexto humano del handoff: contactos, historia, modelo de atención,
 *   reportería especial, negociaciones, dolores, nuevas sedes, potencial TPV y compromisos.
 *
 * Campos eliminados vs V4:
 * - Prioridad de transferencia
 * - Productos/servicios actuales: Botón de pago, Link de pago, Cuenta Bold, Bolsillo, POS
 * - Número de datáfonos
 * - Contrato de comodato
 * - Fechas de comodato
 * - Requiere reunión de handoff
 * - Comentarios adicionales
 *
 * Flujo recomendado:
 * 1. Extensiones > Apps Script > pegar este archivo completo.
 * 2. Ejecutar setupHandoffComercialSMB_V41().
 * 3. Pegar BASE_COMERCIOS con merchant_id, merchant_name, team_lead, manager, city.
 * 4. Ejecutar validarBaseComercios_V41().
 * 5. Ejecutar actualizarListaMerchants_V41().
 * 6. Ejecutar vincularYVerificarRespuestas_V41().
 * 7. Enviar una prueba desde form_public_url.
 * 8. Ejecutar vincularYVerificarRespuestas_V41() de nuevo.
 * 9. Ejecutar reconstruirConsolidado_V41().
 * 10. Revisar VISTA_KAM_CS.
 */

const HANDOFF_V41 = {
  formTitle: 'Handoff Comercial SMB | Customer Success/KAM | Bold',
  formDescription:
    'Formulario para que los Team Leads SMB entreguen contexto comercial de clientes a transferir. ' +
    'La información operativa y transaccional se cruza aparte por merchant_id contra Metabase. ' +
    'Aquí solo se registra información que no está en base: contactos, historia, modelo de atención, ' +
    'reportería especial, negociaciones, dolores, necesidades, potencial y compromisos.',
  baseSheet: 'BASE_COMERCIOS',
  catalogSheet: 'CATALOGOS',
  consolidatedSheet: 'CONSOLIDADO_HANDOFF',
  viewSheet: 'VISTA_KAM_CS',
  configSheet: 'CONFIG',
  instructionsSheet: 'INSTRUCCIONES',
  responseSheetFixedName: 'RESPUESTAS_FORM',
  requiredBaseHeaders: ['merchant_id', 'merchant_name'],
  recommendedBaseHeaders: [
    'merchant_id',
    'merchant_name',
    'document_type',
    'document_number',
    'category_id',
    'subcategory_id',
    'city_code',
    'address',
    'email',
    'cellphone_number',
    'sales_agent_email',
    'tpv_max',
    'clasificación',
    'team_lead',
    'manager'
  ]
};

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Handoff SMB')
    .addItem('1. Crear estructura V4.1 FINAL', 'setupHandoffComercialSMB_V41')
    .addItem('2. Validar BASE_COMERCIOS', 'validarBaseComercios_V41')
    .addItem('3. Actualizar comercios del Form', 'actualizarListaMerchants_V41')
    .addItem('4. Vincular y verificar respuestas', 'vincularYVerificarRespuestas_V41')
    .addItem('5. Reconstruir consolidado', 'reconstruirConsolidado_V41')
    .addItem('6. Reaplicar formato', 'reaplicarFormato_V41')
    .addItem('7. Actualizar tablero de avance', 'construirTableroImplementacion_V41')
    .addSeparator()
    .addItem('Diagnóstico (solo lectura)', 'diagnosticarFormulario_V41')
    .addToUi();
}

/**
 * Crea estructura y formulario si no existe.
 * Si CONFIG ya tiene form_edit_url, reutiliza ese Form. Para crear un Form limpio desde cero,
 * borra form_edit_url en CONFIG o usa un Sheet nuevo.
 */
function setupHandoffComercialSMB_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  if (!ss) throw new Error('Ejecuta esto desde Extensiones > Apps Script dentro de un Google Sheet.');

  buildBaseSheet_V41_(ss);
  buildCatalogSheet_V41_(ss);

  let form = null;
  const existingFormUrl = getValueFromConfig_V41_(ss, 'form_edit_url');
  if (existingFormUrl) {
    try {
      form = FormApp.openByUrl(existingFormUrl);
    } catch (e) {
      form = buildForm_V41_(ss);
    }
  } else {
    form = buildForm_V41_(ss);
  }

  buildConsolidatedSheet_V41_(ss);
  buildViewSheet_V41_(ss);
  buildConfigSheet_V41_(ss, form);
  buildInstructionsSheet_V41_(ss);
  reaplicarFormato_V41();
  vincularYVerificarRespuestas_V41();
}

/**
 * Úsala si ya tienes un Form V4 con preguntas de productos y quieres crear
 * un nuevo Form limpio V4.1 sin borrar el Sheet, BASE_COMERCIOS ni respuestas antiguas.
 */
function crearNuevoFormularioFinal_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  if (!ss) throw new Error('Ejecuta esto desde Extensiones > Apps Script dentro de un Google Sheet.');

  buildCatalogSheet_V41_(ss);
  const form = buildForm_V41_(ss);
  buildConfigSheet_V41_(ss, form);
  vincularYVerificarRespuestas_V41();

  SpreadsheetApp.getUi().alert(
    'Nuevo Form V4.1 FINAL creado y vinculado. Revisa CONFIG > form_public_url.\n\n' +
    'Ahora ejecuta actualizarListaMerchants_V41() para cargar los comercios.'
  );
}

function buildForm_V41_(ss) {
  const form = FormApp.create(HANDOFF_V41.formTitle);
  form.setDescription(HANDOFF_V41.formDescription);
  form.setCollectEmail(false);
  form.setAllowResponseEdits(true);
  form.setLimitOneResponsePerUser(false);
  form.setAcceptingResponses(true);
  form.setConfirmationMessage('Gracias. Información registrada para el handoff comercial SMB → Customer Success/KAM.');
  form.setDestination(FormApp.DestinationType.SPREADSHEET, ss.getId());

  const cat = getCatalogValues_V41_(ss);

  form.addPageBreakItem().setTitle('1. IDENTIFICACIÓN DEL COMERCIO');

  form.addListItem()
    .setTitle('Comercio a transferir')
    .setHelpText('Selecciona el comercio identificado en la base mensual. El resto de datos operativos se cruza por merchant_id.')
    .setChoiceValues(['PENDIENTE_ACTUALIZAR_BASE_COMERCIOS'])
    .setRequired(true);

  form.addTextItem()
    .setTitle('Página web')
    .setHelpText('Si no tiene o no la conoces, escribe NO.')
    .setRequired(false);

  form.addPageBreakItem().setTitle('2. CONTACTO PRINCIPAL');
  addContactBlock_V41_(form, 'Contacto 1', true, cat);

  form.addPageBreakItem().setTitle('3. CONTACTO ADICIONAL (opcional)');
  addContactBlock_V41_(form, 'Contacto 2', false, cat);

  form.addPageBreakItem().setTitle('4. INFORMACIÓN DEL COMERCIO');

  form.addListItem()
    .setTitle('Pertenece a Grupo Empresarial')
    .setChoiceValues(cat.siNo)
    .setRequired(true);

  form.addTextItem()
    .setTitle('¿Cuál grupo empresarial? (si aplica)')
    .setRequired(false);

  form.addListItem()
    .setTitle('Tiene múltiples sedes')
    .setChoiceValues(cat.siNo)
    .setRequired(true);

  form.addListItem()
    .setTitle('Está a nivel nacional')
    .setChoiceValues(cat.siNo)
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Comentarios: cuéntanos la historia de este comercio')
    .setHelpText('Resume el contexto comercial del cliente, su relación con Bold y cualquier antecedente útil para Customer Success/KAM.')
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('¿Cómo es tu modelo de atención con este cliente? ¿Haces reuniones? ¿Cada cuánto tiempo?')
    .setHelpText('Ejemplo: atención por WhatsApp, llamadas semanales, reunión mensual, seguimiento por correo, atención reactiva, etc.')
    .setRequired(true);

  form.addListItem()
    .setTitle('¿Le envías reportería especial?')
    .setChoiceValues(cat.siNo)
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Detalle de reportería especial')
    .setHelpText('Si aplica, describe qué recibe, frecuencia, formato y responsable. Si no aplica, escribe NO.')
    .setRequired(false);

  form.addPageBreakItem().setTitle('5. NEGOCIACIONES, DOLORES Y POTENCIAL');

  form.addParagraphTextItem()
    .setTitle('Negociaciones y términos especiales')
    .setHelpText('Incluye acuerdos, tarifas, condiciones especiales, excepciones, promesas comerciales o temas sensibles.')
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Dolores y necesidades del cliente')
    .setHelpText('Describe problemas actuales, expectativas, riesgos, fricciones o necesidades relevantes.')
    .setRequired(true);

  form.addPageBreakItem().setTitle('EL CLIENTE VA A ABRIR NUEVAS SEDES?');
  form.addParagraphTextItem()
    .setTitle('Corto Plazo (3-6 meses)')
    .setHelpText('Si no aplica, escribe NO.')
    .setRequired(false);
  form.addParagraphTextItem()
    .setTitle('Mediano Plazo (6-12 meses)')
    .setHelpText('Si no aplica, escribe NO.')
    .setRequired(false);
  form.addParagraphTextItem()
    .setTitle('Largo Plazo (1+ años)')
    .setHelpText('Si no aplica, escribe NO.')
    .setRequired(false);

  form.addParagraphTextItem()
    .setTitle('TPV potencial del cliente / ¿podemos profundizarlo y traer más TPV?')
    .setHelpText('Describe oportunidad de crecimiento, nuevos productos, sedes, canales o mayor adopción de Bold.')
    .setRequired(true);

  form.addPageBreakItem().setTitle('6. TEMAS PENDIENTES / COMPROMISOS');

  form.addParagraphTextItem()
    .setTitle('Temas pendientes / compromisos - Cliente')
    .setHelpText('Acciones, documentos, validaciones o decisiones pendientes del lado del cliente.')
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Temas pendientes / compromisos - Bold')
    .setHelpText('Acciones pendientes del lado de Bold: producto, soporte, tarifas, reportes, llamadas, activaciones, etc.')
    .setRequired(true);

  return form;
}

function addContactBlock_V41_(form, label, required, cat) {
  form.addTextItem()
    .setTitle(label + ' - Tipo de contacto')
    .setHelpText('Ejemplo: dueño, representante legal, administrador, financiero, operaciones, backoffice, otro.')
    .setRequired(required);

  form.addTextItem()
    .setTitle(label + ' - Nombre')
    .setRequired(required);

  form.addTextItem()
    .setTitle(label + ' - Cargo')
    .setRequired(required);

  form.addTextItem()
    .setTitle(label + ' - Teléfono')
    .setRequired(required);

  form.addTextItem()
    .setTitle(label + ' - Email')
    .setRequired(false);

  form.addListItem()
    .setTitle(label + ' - Mejor hora de contacto')
    .setChoiceValues(cat.horasContacto)
    .setRequired(required);

  form.addListItem()
    .setTitle(label + ' - Mejor vía de contacto')
    .setChoiceValues(cat.viasContacto)
    .setRequired(required);
}

function vincularYVerificarRespuestas_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const formUrl = getValueFromConfig_V41_(ss, 'form_edit_url');
  if (!formUrl) {
    SpreadsheetApp.getUi().alert('No hay form_edit_url en CONFIG. Ejecuta primero "1. Crear estructura V4.1 FINAL".');
    return;
  }

  const form = FormApp.openByUrl(formUrl);
  form.setAcceptingResponses(true);

  if (form.getDestinationId() !== ss.getId()) {
    form.setDestination(FormApp.DestinationType.SPREADSHEET, ss.getId());
  }

  SpreadsheetApp.flush();
  Utilities.sleep(1500);

  let respSheet = findBestResponseSheetOrNull_V41_(ss);
  if (respSheet && respSheet.getName() !== HANDOFF_V41.responseSheetFixedName) {
    const dup = ss.getSheetByName(HANDOFF_V41.responseSheetFixedName);
    if (dup && dup.getSheetId() !== respSheet.getSheetId()) {
      dup.setName(HANDOFF_V41.responseSheetFixedName + '_ANTIGUA_' + new Date().getTime());
    }
    respSheet.setName(HANDOFF_V41.responseSheetFixedName);
  }

  if (respSheet) {
    setConfigValue_V41_(ss, 'response_sheet_name', HANDOFF_V41.responseSheetFixedName);
  }
  setConfigValue_V41_(ss, 'destino_verificado_en', new Date());

  SpreadsheetApp.getUi().alert(
    'Verificación de respuestas\n\n' +
    'Formulario: ' + form.getTitle() + '\n' +
    'Aceptando respuestas: ' + form.isAcceptingResponses() + '\n' +
    'Destino = este Sheet: ' + (form.getDestinationId() === ss.getId() ? 'SÍ' : 'NO — revisar manualmente') + '\n' +
    'Hoja de respuestas: ' + (respSheet ? respSheet.getName() + ' (' + Math.max(respSheet.getLastRow() - 1, 0) + ' respuestas)' : 'NO ENCONTRADA — envía una respuesta de prueba desde form_public_url y vuelve a ejecutar este paso')
  );
}

function diagnosticarFormulario_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const formUrl = getValueFromConfig_V41_(ss, 'form_edit_url');
  if (!formUrl) {
    SpreadsheetApp.getUi().alert('No hay form_edit_url todavía.');
    return;
  }

  const form = FormApp.openByUrl(formUrl);
  const respSheet = findBestResponseSheetOrNull_V41_(ss);

  SpreadsheetApp.getUi().alert(
    'Diagnóstico\n\n' +
    'Título: ' + form.getTitle() + '\n' +
    'Aceptando respuestas: ' + form.isAcceptingResponses() + '\n' +
    'Destino actual (ID): ' + (form.getDestinationId() || 'NINGUNO') + '\n' +
    'ID de este Sheet: ' + ss.getId() + '\n' +
    'Coinciden: ' + (form.getDestinationId() === ss.getId() ? 'SÍ' : 'NO') + '\n' +
    'Hoja de respuestas detectada: ' + (respSheet ? respSheet.getName() : 'NINGUNA') + '\n' +
    'Respuestas registradas: ' + (respSheet ? Math.max(respSheet.getLastRow() - 1, 0) : 0)
  );
}

function validarBaseComercios_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const base = ss.getSheetByName(HANDOFF_V41.baseSheet);
  if (!base) throw new Error('No existe la hoja BASE_COMERCIOS.');

  const data = base.getDataRange().getValues();
  if (data.length < 2) {
    SpreadsheetApp.getUi().alert('BASE_COMERCIOS no tiene datos. Pega merchant_id y merchant_name como mínimo.');
    return false;
  }

  const headers = data[0].map(h => String(h).trim());
  const missingRequired = HANDOFF_V41.requiredBaseHeaders.filter(h => !headers.includes(h));
  if (missingRequired.length > 0) {
    SpreadsheetApp.getUi().alert('Faltan columnas obligatorias:\n' + missingRequired.join('\n'));
    return false;
  }

  const idIdx = headers.indexOf('merchant_id');
  const duplicated = findDuplicates_V41_(data.slice(1).map(r => String(r[idIdx]).trim()).filter(Boolean));
  const emptyIds = data.slice(1).filter(r => !String(r[idIdx]).trim()).length;

  let message = 'BASE_COMERCIOS validada.\n\n';
  message += 'Comercios: ' + (data.length - 1) + '\n';
  message += 'merchant_id vacíos: ' + emptyIds + '\n';
  message += 'merchant_id duplicados: ' + duplicated.length;
  if (duplicated.length) message += '\n(' + duplicated.slice(0, 10).join(', ') + ')';

  SpreadsheetApp.getUi().alert(message);
  return true;
}

function actualizarListaMerchants_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const validation = validarBaseSilenciosa_V41_(ss);
  if (!validation.ok) {
    SpreadsheetApp.getUi().alert(validation.message);
    return;
  }

  const formUrl = getValueFromConfig_V41_(ss, 'form_edit_url');
  if (!formUrl) throw new Error('No se encontró form_edit_url en CONFIG. Ejecuta "1. Crear estructura V4.1 FINAL".');

  const form = FormApp.openByUrl(formUrl);
  const base = ss.getSheetByName(HANDOFF_V41.baseSheet);
  const values = base.getDataRange().getValues();
  const headers = values[0].map(h => String(h).trim());

  const idIdx = headers.indexOf('merchant_id');
  const nameIdx = headers.indexOf('merchant_name');
  const cityIdx = headers.indexOf('city_code');
  const tlIdx = headers.indexOf('team_lead');
  const segmentIdx = headers.indexOf('clasificación') >= 0 ? headers.indexOf('clasificación') : headers.indexOf('clasificacion');

  const choices = values.slice(1)
    .filter(r => r[idIdx])
    .map(r => {
      const name = nameIdx >= 0 && r[nameIdx] ? String(r[nameIdx]).trim() : 'Comercio sin nombre';
      const id = String(r[idIdx]).trim();
      const city = cityIdx >= 0 && r[cityIdx] ? ' | ' + String(r[cityIdx]).trim() : '';
      const tl = tlIdx >= 0 && r[tlIdx] ? ' | TL: ' + String(r[tlIdx]).trim() : '';
      const segment = segmentIdx >= 0 && r[segmentIdx] ? ' | ' + String(r[segmentIdx]).trim() : '';
      return `${name} — Merchant ${id}${city}${tl}${segment}`;
    })
    .slice(0, 1000);

  const item = form.getItems(FormApp.ItemType.LIST)
    .map(i => i.asListItem())
    .find(i => i.getTitle() === 'Comercio a transferir');

  if (!item) throw new Error('No se encontró la pregunta "Comercio a transferir".');

  item.setChoiceValues(choices.length ? choices : ['SIN_COMERCIOS_EN_BASE']);
  setConfigValue_V41_(ss, 'ultima_actualizacion_merchants', new Date());
  SpreadsheetApp.getUi().alert('Lista actualizada. Total comercios: ' + choices.length);
}

function reconstruirConsolidado_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const responseSheet = findResponseSheet_V41_(ss);
  const base = ss.getSheetByName(HANDOFF_V41.baseSheet);
  const out = getOrCreateSheet_V41_(ss, HANDOFF_V41.consolidatedSheet);
  const view = getOrCreateSheet_V41_(ss, HANDOFF_V41.viewSheet);

  const resp = responseSheet.getDataRange().getValues();
  const baseData = base.getDataRange().getValues();

  if (resp.length < 2) {
    SpreadsheetApp.getUi().alert('Todavía no hay respuestas del formulario.');
    return;
  }
  if (baseData.length < 2) {
    SpreadsheetApp.getUi().alert('BASE_COMERCIOS no tiene datos para cruzar.');
    return;
  }

  const respHeaders = resp[0].map(h => String(h).trim());
  const baseHeaders = baseData[0].map(h => String(h).trim());
  const baseIdIdx = baseHeaders.indexOf('merchant_id');

  const baseMap = {};
  baseData.slice(1).forEach(r => {
    const id = String(r[baseIdIdx]).trim();
    if (id) baseMap[id] = r;
  });

  const merchantRespIdx = respHeaders.indexOf('Comercio a transferir');
  const timestampIdx = respHeaders.indexOf('Timestamp') >= 0 ? respHeaders.indexOf('Timestamp') : respHeaders.indexOf('Marca temporal');
  const emailRespIdx = respHeaders.indexOf('Email Address') >= 0 ? respHeaders.indexOf('Email Address') : respHeaders.indexOf('Dirección de correo electrónico');

  const excluded = ['Timestamp', 'Marca temporal', 'Comercio a transferir', 'Email Address', 'Dirección de correo electrónico'];

  const outputHeaders = [
    'merchant_id',
    'fecha_respuesta',
    'respondent_email',
    'estado_asignacion_cs',
    'kam_asignado',
    'fecha_asignacion_kam',
    'observacion_customer_success',
    ...baseHeaders.filter(h => h !== 'merchant_id'),
    ...respHeaders.filter(h => !excluded.includes(h))
  ];

  const rows = [outputHeaders];

  resp.slice(1).forEach(r => {
    const merchantRaw = merchantRespIdx >= 0 ? String(r[merchantRespIdx] || '').trim() : '';
    const merchantId = extractMerchantId_V41_(merchantRaw);
    const baseRow = baseMap[merchantId] || [];

    const baseValues = baseHeaders.filter(h => h !== 'merchant_id').map(h => {
      const idx = baseHeaders.indexOf(h);
      return baseRow[idx] || '';
    });

    const responseOnly = respHeaders
      .map((h, idx) => ({ h, v: r[idx] }))
      .filter(x => !excluded.includes(x.h))
      .map(x => x.v);

    rows.push([
      merchantId,
      timestampIdx >= 0 ? r[timestampIdx] : '',
      emailRespIdx >= 0 ? r[emailRespIdx] : '',
      'Pendiente asignación CS',
      '',
      '',
      '',
      ...baseValues,
      ...responseOnly
    ]);
  });

  out.clear();
  out.getRange(1, 1, rows.length, rows[0].length).setValues(rows);
  applyBasicFormat_V41_(out);
  createFilterIfMissing_V41_(out);

  buildViewFromConsolidated_V41_(view, rows);
  setConfigValue_V41_(ss, 'ultima_reconstruccion_consolidado', new Date());
  SpreadsheetApp.getUi().alert('Consolidado y VISTA_KAM_CS reconstruidos.');
}

function buildViewFromConsolidated_V41_(view, consolidatedRows) {
  const consHeaders = consolidatedRows[0].map(String);

  const desired = [
    'estado_asignacion_cs',
    'kam_asignado',
    'merchant_id',
    'merchant_name',
    'team_lead',
    'manager',
    'document_type',
    'document_number',
    'category_id',
    'subcategory_id',
    'city_code',
    'sales_agent_email',
    'clasificación',
    'tpv_max',
    'Página web',
    'Contacto 1 - Tipo de contacto',
    'Contacto 1 - Nombre',
    'Contacto 1 - Cargo',
    'Contacto 1 - Teléfono',
    'Contacto 1 - Email',
    'Contacto 1 - Mejor hora de contacto',
    'Contacto 1 - Mejor vía de contacto',
    'Contacto 2 - Tipo de contacto',
    'Contacto 2 - Nombre',
    'Contacto 2 - Cargo',
    'Contacto 2 - Teléfono',
    'Contacto 2 - Email',
    'Contacto 2 - Mejor hora de contacto',
    'Contacto 2 - Mejor vía de contacto',
    'Pertenece a Grupo Empresarial',
    '¿Cuál grupo empresarial? (si aplica)',
    'Tiene múltiples sedes',
    'Está a nivel nacional',
    'Comentarios: cuéntanos la historia de este comercio',
    '¿Cómo es tu modelo de atención con este cliente? ¿Haces reuniones? ¿Cada cuánto tiempo?',
    '¿Le envías reportería especial?',
    'Detalle de reportería especial',
    'Negociaciones y términos especiales',
    'Dolores y necesidades del cliente',
    'Corto Plazo (3-6 meses)',
    'Mediano Plazo (6-12 meses)',
    'Largo Plazo (1+ años)',
    'TPV potencial del cliente / ¿podemos profundizarlo y traer más TPV?',
    'Temas pendientes / compromisos - Cliente',
    'Temas pendientes / compromisos - Bold'
  ];

  const viewRows = [desired];

  consolidatedRows.slice(1).forEach(r => {
    viewRows.push(desired.map(h => {
      let idx = consHeaders.indexOf(h);

      // Compatibilidad por si la base viene sin tilde.
      if (idx < 0 && h === 'clasificación') idx = consHeaders.indexOf('clasificacion');

      return idx >= 0 ? r[idx] : '';
    }));
  });

  view.clear();
  view.getRange(1, 1, viewRows.length, viewRows[0].length).setValues(viewRows);
  applyBasicFormat_V41_(view);
  createFilterIfMissing_V41_(view);
}

/**
 * Tablero simple de implementación en Sheets.
 * Lo puedes usar como seguimiento interno sin necesidad de Looker todavía.
 */
function construirTableroImplementacion_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const base = ss.getSheetByName(HANDOFF_V41.baseSheet);
  const responseSheet = findBestResponseSheetOrNull_V41_(ss);
  const dashboard = getOrCreateSheet_V41_(ss, 'TABLERO_IMPLEMENTACION');

  const baseData = base ? base.getDataRange().getValues() : [];
  const totalBase = Math.max(baseData.length - 1, 0);

  let totalRespuestas = 0;
  let merchantsRespondidos = new Set();

  if (responseSheet && responseSheet.getLastRow() > 1) {
    const resp = responseSheet.getDataRange().getValues();
    const headers = resp[0].map(h => String(h).trim());
    const merchantIdx = headers.indexOf('Comercio a transferir');
    totalRespuestas = resp.length - 1;
    resp.slice(1).forEach(r => {
      if (merchantIdx >= 0 && r[merchantIdx]) {
        merchantsRespondidos.add(extractMerchantId_V41_(String(r[merchantIdx])));
      }
    });
  }

  const avance = totalBase ? merchantsRespondidos.size / totalBase : 0;
  const pendientes = Math.max(totalBase - merchantsRespondidos.size, 0);

  const rows = [
    ['Indicador', 'Valor'],
    ['Comercios en base', totalBase],
    ['Comercios con respuesta', merchantsRespondidos.size],
    ['Respuestas totales', totalRespuestas],
    ['Comercios pendientes', pendientes],
    ['Avance %', avance],
    ['Última actualización', new Date()]
  ];

  dashboard.clear();
  dashboard.getRange(1, 1, rows.length, 2).setValues(rows);
  dashboard.getRange(6, 2).setNumberFormat('0.0%');
  applyBasicFormat_V41_(dashboard);

  SpreadsheetApp.getUi().alert('TABLERO_IMPLEMENTACION actualizado.');
}

function buildBaseSheet_V41_(ss) {
  const sh = getOrCreateSheet_V41_(ss, HANDOFF_V41.baseSheet);
  if (sh.getLastRow() === 0 || sh.getLastColumn() === 0) {
    sh.getRange(1, 1, 1, HANDOFF_V41.recommendedBaseHeaders.length).setValues([HANDOFF_V41.recommendedBaseHeaders]);
  }
  applyBasicFormat_V41_(sh);
}

function buildCatalogSheet_V41_(ss) {
  const sh = getOrCreateSheet_V41_(ss, HANDOFF_V41.catalogSheet);
  const rows = [
    ['catalogo', 'valor'],
    ['siNo', 'SI'],
    ['siNo', 'NO'],
    ['horasContacto', 'Mañana'],
    ['horasContacto', 'Tarde'],
    ['horasContacto', 'Noche'],
    ['viasContacto', 'Mail'],
    ['viasContacto', 'WhatsApp'],
    ['viasContacto', 'Llamada']
  ];
  sh.clear();
  sh.getRange(1, 1, rows.length, 2).setValues(rows);
  applyBasicFormat_V41_(sh);
}

function buildConsolidatedSheet_V41_(ss) {
  const sh = getOrCreateSheet_V41_(ss, HANDOFF_V41.consolidatedSheet);
  if (sh.getLastRow() === 0) {
    sh.getRange(1, 1).setValue('Ejecuta "5. Reconstruir consolidado" cuando existan respuestas.');
  }
}

function buildViewSheet_V41_(ss) {
  const sh = getOrCreateSheet_V41_(ss, HANDOFF_V41.viewSheet);
  if (sh.getLastRow() === 0) {
    sh.getRange(1, 1).setValue('Vista operativa CS/KAM. Ejecuta "5. Reconstruir consolidado".');
  }
}

function buildConfigSheet_V41_(ss, form) {
  const sh = getOrCreateSheet_V41_(ss, HANDOFF_V41.configSheet);

  const existing = {};
  if (sh.getLastRow() > 1) {
    sh.getDataRange().getValues().slice(1).forEach(r => {
      if (r[0]) existing[String(r[0])] = r[1];
    });
  }

  const rows = [
    ['clave', 'valor'],
    ['form_public_url', form.getPublishedUrl()],
    ['form_edit_url', form.getEditUrl()],
    ['sheet_url', ss.getUrl()],
    ['response_sheet_name', existing['response_sheet_name'] || ''],
    ['ultima_creacion_mvp', existing['ultima_creacion_mvp'] || new Date()],
    ['ultima_actualizacion_merchants', existing['ultima_actualizacion_merchants'] || ''],
    ['ultima_reconstruccion_consolidado', existing['ultima_reconstruccion_consolidado'] || ''],
    ['destino_verificado_en', existing['destino_verificado_en'] || '']
  ];

  sh.clear();
  sh.getRange(1, 1, rows.length, 2).setValues(rows);
  applyBasicFormat_V41_(sh);
}

function buildInstructionsSheet_V41_(ss) {
  const sh = getOrCreateSheet_V41_(ss, HANDOFF_V41.instructionsSheet);
  const rows = [
    ['Paso', 'Qué hacer', 'Resultado esperado'],
    ['1', 'Ejecutar "1. Crear estructura V4.1 FINAL".', 'Se crean/actualizan Form, pestañas, catálogos y CONFIG.'],
    ['2', 'Pegar BASE_COMERCIOS con merchant_id y merchant_name como mínimo.', 'Base mensual lista para poblar el desplegable.'],
    ['3', 'Ejecutar "2. Validar BASE_COMERCIOS".', 'Confirma filas, duplicados y columnas obligatorias.'],
    ['4', 'Ejecutar "3. Actualizar comercios del Form".', 'El desplegable queda con los comercios de la base.'],
    ['5', 'Ejecutar "4. Vincular y verificar respuestas".', 'Confirma que el destino del Form es este Sheet.'],
    ['6', 'Enviar 1-2 respuestas de prueba desde form_public_url.', 'Deben verse filas en RESPUESTAS_FORM.'],
    ['7', 'Ejecutar "5. Reconstruir consolidado".', 'Cruza respuestas + base y arma VISTA_KAM_CS.'],
    ['8', 'Ejecutar construirTableroImplementacion_V41().', 'Crea un tablero simple de avance del handoff.']
  ];

  sh.clear();
  sh.getRange(1, 1, rows.length, 3).setValues(rows);
  applyBasicFormat_V41_(sh);
}

function getCatalogValues_V41_(ss) {
  const sh = ss.getSheetByName(HANDOFF_V41.catalogSheet);
  const values = sh.getDataRange().getValues().slice(1);
  const out = {};

  values.forEach(([cat, val]) => {
    if (!out[cat]) out[cat] = [];
    if (val !== '') out[cat].push(String(val));
  });

  return out;
}

function reaplicarFormato_V41() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  [
    HANDOFF_V41.baseSheet,
    HANDOFF_V41.catalogSheet,
    HANDOFF_V41.consolidatedSheet,
    HANDOFF_V41.viewSheet,
    HANDOFF_V41.configSheet,
    HANDOFF_V41.instructionsSheet,
    'TABLERO_IMPLEMENTACION'
  ].forEach(name => {
    const sh = ss.getSheetByName(name);
    if (sh) applyBasicFormat_V41_(sh);
  });
}

function applyBasicFormat_V41_(sh) {
  const lastRow = Math.max(sh.getLastRow(), 1);
  const lastCol = Math.max(sh.getLastColumn(), 1);
  sh.setFrozenRows(1);
  sh.getRange(1, 1, 1, lastCol)
    .setFontWeight('bold')
    .setBackground('#f1f3f4');
  sh.getRange(1, 1, lastRow, lastCol)
    .setWrap(true)
    .setVerticalAlignment('middle');
  sh.autoResizeColumns(1, Math.min(lastCol, 30));
}

function createFilterIfMissing_V41_(sh) {
  if (sh.getFilter()) return;
  const lastRow = sh.getLastRow();
  const lastCol = sh.getLastColumn();
  if (lastRow > 1 && lastCol > 1) {
    sh.getRange(1, 1, lastRow, lastCol).createFilter();
  }
}

function getOrCreateSheet_V41_(ss, name) {
  return ss.getSheetByName(name) || ss.insertSheet(name);
}

function getValueFromConfig_V41_(ss, key) {
  const sh = ss.getSheetByName(HANDOFF_V41.configSheet);
  if (!sh) return null;
  const values = sh.getDataRange().getValues();
  for (let i = 1; i < values.length; i++) {
    if (values[i][0] === key) return values[i][1];
  }
  return null;
}

function setConfigValue_V41_(ss, key, value) {
  const sh = ss.getSheetByName(HANDOFF_V41.configSheet);
  const values = sh.getDataRange().getValues();

  for (let i = 1; i < values.length; i++) {
    if (values[i][0] === key) {
      sh.getRange(i + 1, 2).setValue(value);
      return;
    }
  }

  sh.appendRow([key, value]);
}

function findResponseSheet_V41_(ss) {
  const configuredName = getValueFromConfig_V41_(ss, 'response_sheet_name');
  if (configuredName) {
    const configured = ss.getSheetByName(String(configuredName));
    if (configured && configured.getLastRow() >= 2) return configured;
  }

  const best = findBestResponseSheetOrNull_V41_(ss);
  if (!best) {
    throw new Error('No se encontró una hoja de respuestas con datos. Envía una respuesta de prueba y ejecuta "4. Vincular y verificar respuestas".');
  }

  setConfigValue_V41_(ss, 'response_sheet_name', best.getName());
  return best;
}

function findBestResponseSheetOrNull_V41_(ss) {
  const fixed = ss.getSheetByName(HANDOFF_V41.responseSheetFixedName);
  if (fixed && fixed.getLastRow() >= 1) return fixed;

  const candidates = ss.getSheets().filter(s => {
    const name = s.getName().toLowerCase();
    const lastRow = s.getLastRow();
    const lastCol = s.getLastColumn();

    if (lastRow < 1 || lastCol < 1) return false;

    const headers = s.getRange(1, 1, 1, lastCol).getValues()[0].map(h => String(h).trim());
    const hasTimestamp = headers.includes('Timestamp') || headers.includes('Marca temporal');
    const hasMerchant = headers.includes('Comercio a transferir');
    const nameLooksLikeResponse = name.includes('respuesta') || name.includes('response') || name.includes('formulario');

    return nameLooksLikeResponse && hasTimestamp && hasMerchant;
  });

  if (!candidates.length) return null;

  candidates.sort((a, b) => (b.getLastRow() - a.getLastRow()) || (b.getIndex() - a.getIndex()));
  return candidates[0];
}

function extractMerchantId_V41_(text) {
  const value = String(text || '').trim();
  const match = value.match(/Merchant\s+([^|]+)/i);
  if (match && match[1]) return match[1].trim();
  if (value.includes('|')) return value.split('|')[0].trim();
  return value;
}

function validarBaseSilenciosa_V41_(ss) {
  const base = ss.getSheetByName(HANDOFF_V41.baseSheet);
  if (!base) return { ok: false, message: 'No existe BASE_COMERCIOS.' };

  const data = base.getDataRange().getValues();
  if (data.length < 2) return { ok: false, message: 'BASE_COMERCIOS no tiene datos.' };

  const headers = data[0].map(h => String(h).trim());
  const missing = HANDOFF_V41.requiredBaseHeaders.filter(h => !headers.includes(h));

  if (missing.length) {
    return { ok: false, message: 'Faltan columnas obligatorias: ' + missing.join(', ') };
  }

  return { ok: true, message: 'OK' };
}

function findDuplicates_V41_(arr) {
  const seen = {};
  const duplicates = [];

  arr.forEach(x => {
    if (seen[x] && duplicates.indexOf(x) === -1) duplicates.push(x);
    seen[x] = true;
  });

  return duplicates;
}
