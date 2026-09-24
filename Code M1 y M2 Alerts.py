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


{
  "errorMessage": "invalid syntax (<unknown>, line 1)",
  "errorDetails": {},
  "n8nDetails": {
    "n8nVersion": "2.39.6 (Cloud)",
    "binaryDataMode": "filesystem",
    "stackTrace": [
      "WrappedExecutionError: invalid syntax (<unknown>, line 1)",
      "    at throwExecutionError (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-nodes-base@file++++home+runner+_work+n8n+n8n+packages+nodes-base/node_modules/n8n-nodes-base/nodes/Code/throw-execution-error.ts:11:9)",
      "    at PythonTaskRunnerSandbox.runUsingIncomingItems (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-nodes-base@file++++home+runner+_work+n8n+n8n+packages+nodes-base/node_modules/n8n-nodes-base/nodes/Code/PythonTaskRunnerSandbox.ts:69:30)",
      "    at processTicksAndRejections (node:internal/process/task_queues:104:5)",
      "    at ExecuteContext.execute (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-nodes-base@file++++home+runner+_work+n8n+n8n+packages+nodes-base/node_modules/n8n-nodes-base/nodes/Code/Code.node.ts:234:12)",
      "    at WorkflowExecute.executeNode (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file++++home+runner+_work+n8n+n8n+packages+core/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1125:8)",
      "    at WorkflowExecute.runNode (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file++++home+runner+_work+n8n+n8n+packages+core/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:1427:11)",
      "    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file++++home+runner+_work+n8n+n8n+packages+core/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:2329:27",
      "    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/n8n-core@file++++home+runner+_work+n8n+n8n+packages+core/node_modules/n8n-core/src/execution-engine/workflow-execute.ts:2810:11"
    ]
  }
}
