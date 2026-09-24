return items.map(item => {
  const row = item.json;

  return {
    json: {
      ...row,
      status_normalizado: String(row.status_code || '').trim().toUpperCase(),
      verificacion_normalizada: String(
        row.manual_verification_status_code || ''
      ).trim().toUpperCase(),
      ejecutivo_email: String(
        row.sales_agent_email || ''
      ).trim().toLowerCase(),
      dias_vida: Number(row['Dias de Vida']) || 0,
      tipo_churn: String(row['Tipo de Churn'] || '').trim()
    }
  };
});


