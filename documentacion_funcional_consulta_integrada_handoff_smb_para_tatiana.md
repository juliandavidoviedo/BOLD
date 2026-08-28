# Documentacion funcional - consulta integrada Handoff SMB

Dirigido a: Tatiana, Process Automation Developer  
Uso esperado: B-maker / Next.js  
Proceso: Handoff Comercial SMB -> Customer Success / KAM

## 1. Objetivo

La consulta integrada tiene como objetivo enriquecer la base mensual de comercios
que seran transferidos desde SMB hacia Customer Success/KAM.

La consulta no define que comercios entran al handoff. Ese universo ya viene
curado por la Head de SMB y por el proceso comercial mensual.

El insumo minimo de entrada para la consulta es:

```text
merchant_id
```

El KAM asignado y el mes de transferencia se gestionan fuera de esta consulta:

- `kam_asignado_email`: viene en la base mensual entregada al proceso y es
  administrado por el manager de KAMs.
- `mes_transferencia`: debe calcularlo o asignarlo el proceso de carga mensual.

Estos campos pueden vivir en la tabla/sheet/control de carga mensual, pero no se
buscan ni se infieren desde Athena en esta consulta.

## 2. Alcance de la consulta

La consulta trae informacion no cualitativa disponible en fuentes internas para
alimentar el dashboard:

- datos base del comercio;
- contacto principal disponible;
- categoria economica;
- ubicacion/hub cuando exista;
- oportunidad CRM asociada;
- responsable comercial origen;
- Team Lead origen;
- manager origen;
- terminales asociadas;
- productos transaccionales;
- TPV M0 a M5;
- transacciones M0 a M5;
- clasificacion calculada por TPV maximo;
- estados de calidad de datos.

La consulta no trae ni debe intentar inferir informacion cualitativa como:

- historia del comercio;
- dolores del cliente;
- necesidades comerciales;
- negociaciones en curso;
- compromisos del cliente;
- compromisos de Bold;
- contexto relacional;
- reporterias especiales;
- sedes futuras;
- potencial cualitativo.

Esa informacion debe capturarse en el formulario de handoff y cruzarse por
`merchant_id`.

## 3. Fuente autoritativa mensual

La CTE `base_mensual` representa la lista de merchants recibida cada mes.

En la version de validacion se usa un bloque `VALUES`:

```sql
base_mensual (merchant_id) AS (
    VALUES
        ('0CZTLXEOXY'), ('7DVLTIUMHX'), ('RMCVFJO3D8')
)
```

En produccion, Tatiana puede reemplazar esta CTE por la fuente que use B-maker:

- una tabla de carga mensual;
- una vista de staging;
- una sheet conectada al proceso;
- una tabla materializada mantenida por Automation.

Regla clave: si un `merchant_id` viene en la base mensual, debe salir en el
dashboard aunque falte informacion en alguna dimension.

## 4. Fuentes internas usadas

La consulta integra las siguientes fuentes:

```text
awsdatacatalog.bold_gold_growth.dim_client
awsdatacatalog.bold_gold_growth.dim_merchant_onboarding
awsdatacatalog.bold_gold_growth.dim_client_georeference
awsdatacatalog.bold_gold_growth.mart_master_merchant_enrich
awsdatacatalog.bold_gold_finance.mart_tpv_daily_by_transaction
awsdatacatalog.bold_gold_core.dim_date
awsdatacatalog.bold_gold_terminals.mart_terminal_enrich
awsdatacatalog.bold_gold_sales.dim_crm_users
awsdatacatalog.bold_gold_sales.dim_user_bamboo_information
awsdatacatalog.bold_gold_sales.dim_crm_pos_locations
awsdatacatalog.bold_gold_sales.dim_crm_opportunities
```

No se usa `dim_crm_services` para buscar KAM porque el KAM asignado viene en el
archivo mensual y es administrado fuera de esta consulta.

No se usa `dim_apolo_opportunities` como fuente principal porque en la muestra
validada no encontro oportunidad para los 10 merchants.

## 5. Logica de responsable cualitativo

Para saber quien debe diligenciar o asegurar la informacion cualitativa, la
consulta usa la oportunidad registrada en CRM/EPIC:

```text
merchant_id
-> dim_crm_opportunities
-> responsable_origen_user_id
-> dim_crm_users.parent_id
-> team_lead_origen
-> manager_origen
```

El dashboard debe usar principalmente estos campos:

```text
responsable_origen_email
team_lead_origen_email
manager_origen_email
estado_responsable_cualitativo
```

Estados esperados:

- `RESPONSABLE_ORIGEN_RESUELTO`: se encontro oportunidad, responsable origen y
  Team Lead.
- `SIN_OPORTUNIDAD_CRM`: el merchant no tiene oportunidad asociada en CRM.
- `OPORTUNIDAD_SIN_USER_ID`: existe oportunidad, pero no tiene usuario
  responsable.
- `RESPONSABLE_NO_ENCONTRADO_EN_CRM_USERS`: el usuario de la oportunidad no
  cruza con `dim_crm_users`.
- `SIN_TEAM_LEAD_ORIGEN`: se encontro responsable, pero no TL por `parent_id`.

## 6. TPV M0 a M5

La consulta calcula TPV de maduracion desde Finance.

Definicion:

- `M0`: primer mes calendario en el que el comercio tiene TPV mayor a cero.
- `M1`: mes siguiente a M0.
- `M2`: segundo mes posterior a M0.
- `M3`: tercer mes posterior a M0.
- `M4`: cuarto mes posterior a M0.
- `M5`: quinto mes posterior a M0, equivalente al sexto mes de maduracion.

Ejemplo:

```text
Si M0 = enero, entonces M5 = junio.
```

La maduracion transaccional no debe filtrar comercios. Debe mostrarse como
contexto mediante:

```text
meses_con_tpv_m0_m5
estado_maduracion_tpv
```

## 7. Campos recomendados para el dashboard

Campos de identificacion:

```text
merchant_id
client_id
merchant_name
document_type
document_number
```

Campos para gestion del cualitativo:

```text
responsable_origen_email
responsable_origen_status
responsable_origen_job_title
team_lead_origen_email
team_lead_origen_status
team_lead_origen_job_title
manager_origen_email
manager_origen_status
manager_origen_job_title
estado_responsable_cualitativo
```

Campos operativos:

```text
category_id
city_code
department_code
address
email
cellphone_number
selected_products
client_status
onboarding_status
```

Campos de TPV y salud:

```text
tpv_m0
tpv_m1
tpv_m2
tpv_m3
tpv_m4
tpv_m5
tx_m0
tx_m1
tx_m2
tx_m3
tx_m4
tx_m5
tpv_max
clasificacion_calculada
crecimiento_m1_vs_m0
crecimiento_m5_vs_m0
crecimiento_m3_m5_vs_m0_m2
estado_maduracion_tpv
```

Campos de terminales:

```text
numero_terminales
terminales_asociadas
modelos_terminales
estados_terminales
tiene_pos
tiene_link_pago
tiene_boton_pago
tiene_qr
```

## 8. Validaciones esperadas

Antes de conectar la consulta al dashboard, validar:

1. La consulta debe devolver una fila por `merchant_id`.
2. El numero de filas debe coincidir con la base mensual de entrada.
3. Ningun merchant de la base mensual debe perderse por falta de joins.
4. Los merchants sin oportunidad CRM deben quedar marcados como
   `SIN_OPORTUNIDAD_CRM`.
5. Los campos de TPV M0-M5 deben interpretarse como maduracion, no como meses
   calendario recientes.
6. `clasificacion_calculada` debe depender de `tpv_max`.
7. KAM asignado y mes de transferencia deben venir del proceso mensual, no de la
   consulta.

## 9. Flujo recomendado para B-maker / Next.js

1. Cargar mensualmente la base curada de merchants.
2. Guardar esa base con al menos:
   - `merchant_id`;
   - `kam_asignado_email`, fuera de esta consulta;
   - `mes_transferencia`, calculado por el proceso.
3. Ejecutar la consulta integrada usando esa base como entrada.
4. Cruzar el resultado de la consulta con:
   - KAM asignado;
   - formulario cualitativo;
   - estado de diligenciamiento.
5. Mostrar en el dashboard:
   - comercios a transferir;
   - KAM destino;
   - responsable origen/TL/manager;
   - estado de informacion cualitativa;
   - datos operativos y salud transaccional.

## 10. Decision final

Si Tatiana necesita una sola consulta integrada para Metabase/Athena, usar:

```text
28_consulta_integrada_handoff_smb_para_tatiana_sin_kam_ni_canal.sql
```

Esta consulta es la version recomendada porque:

- respeta que SMB entrega la base mensual curada;
- no filtra ni recalcula canal;
- no busca ni infiere KAM;
- conserva los merchants aunque falte informacion;
- identifica el responsable origen para el diligenciamiento cualitativo;
- entrega la informacion operativa necesaria para el dashboard.

## 11. Validacion con muestra de 10 merchants

La consulta `28_consulta_integrada_handoff_smb_para_tatiana_sin_kam_ni_canal.sql`
fue validada con una muestra de 10 merchants.

Resultado de calidad observado:

- La consulta devuelve 10 filas para 10 merchants de entrada.
- No se observan duplicados en la muestra.
- `merchant_id`, `client_id`, `merchant_name`, documento, contacto base y
  categoria se poblaron para los 10 merchants.
- La consulta ya no devuelve `kam_asignado_email` ni `mes_transferencia`, porque
  esos campos pertenecen al proceso mensual de carga.
- La consulta ya no calcula ni valida canal de aplicacion, porque la base mensual
  se considera curada por SMB.
- La oportunidad CRM resolvio responsable origen, Team Lead origen y manager
  origen para 7 de 10 merchants.
- Los 3 merchants restantes quedaron marcados como `SIN_OPORTUNIDAD_CRM`.
- TPV M0-M5 se calculo para los 10 merchants, con estado de maduracion visible.
- Terminales asociadas se poblaron cuando existe informacion en la fuente de
  terminales; cuando no existe, el comercio permanece visible.

Interpretacion:

La consulta es apta como consulta integrada base para el dashboard. Los casos
`SIN_OPORTUNIDAD_CRM` no son un error de ejecucion; son excepciones operativas
que deben quedar visibles para seguimiento manual o validacion del equipo
comercial.

Campos principales recomendados para controlar el diligenciamiento cualitativo:

```text
estado_responsable_cualitativo
responsable_origen_email
responsable_origen_status
team_lead_origen_email
team_lead_origen_status
manager_origen_email
manager_origen_status
```

Campos principales recomendados para salud transaccional:

```text
tpv_m0
tpv_m1
tpv_m2
tpv_m3
tpv_m4
tpv_m5
tpv_max
clasificacion_calculada
estado_maduracion_tpv
```
