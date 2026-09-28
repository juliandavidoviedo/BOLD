Actúa como Senior Sales Operations Manager y BI Data Analyst de Bold. Analiza el XLSX adjunto para preparar un informe ejecutivo dirigido a la Manager del canal SDR.

Periodo oficial:
Junio a septiembre de 2026.

Población esperada:
3.971 citas filtradas por Fecha de la cita.

Pestañas esperadas:
- fuente original;
- datos_normalizados;
- KPI_Semanal;
- Gestion_Ejecutivos;
- Gestion_Canales;
- Calidad_Datos;
- Alertas_DEV;
- Log_Ejecuciones.

Reglas obligatorias:
1. No inventes datos, nombres, canales, TPV, rankings ni porcentajes.
2. No uses datos mock, ejemplos o aproximaciones.
3. Si una pestaña está vacía, decláralo.
4. Si los totales no coinciden, muestra la discrepancia y no la ocultes.
5. Usa Fecha de la cita para el periodo.
6. Las citas futuras no cuentan como realizadas.
7. Una oportunidad puede convertirse en cierre.
8. No uses Dia Ultima Act OP como fecha de transacción.
9. No declares que un comercio está sin transar si no existe una fecha confiable de última transacción.
10. No evalúes negativamente a ejecutivos con volumen bajo.
11. Distingue hechos, interpretación, hipótesis y recomendaciones.
12. Redacta sólo con evidencia del archivo.

Primero realiza una auditoría:

- filas por pestaña;
- periodo de cada pestaña;
- población fuente;
- población normalizada;
- duplicados;
- fechas inválidas;
- citas futuras;
- faltantes de Team Lead;
- inconsistencias de realización;
- diferencias entre KPIs semanales y gestión por ejecutivo;
- diferencias entre TPV semanal, ejecutivo y canal.

Después genera el informe con esta estructura:

1. Resumen ejecutivo para la Manager SDR
   - estado general del canal;
   - volumen de citas;
   - oportunidades;
   - cierres;
   - pendientes;
   - TPV M0 y M1;
   - tasas de conversión;
   - nivel de confiabilidad.

2. Qué dicen las cifras
   - evolución semana a semana;
   - semanas de mayor y menor actividad;
   - comportamiento del embudo;
   - principales variaciones;
   - diferencias entre volumen y eficiencia.

3. Calidad de las citas
   - registros completos;
   - duplicados;
   - inconsistencias;
   - citas futuras;
   - datos faltantes;
   - impacto en la gestión.

4. Gestión del canal
   - ejecutivos con mayor volumen;
   - ejecutivos con mayor conversión;
   - ejecutivos con más pendientes;
   - Team Leads con mayor concentración de excepciones;
   - canales con mayor aporte de TPV;
   - advertencia para muestras pequeñas.

5. Ejecutivos que requieren atención
   Crear una tabla con:
   - ejecutivo;
   - Team Lead;
   - manager;
   - citas;
   - realizadas;
   - oportunidades;
   - cierres;
   - pendientes;
   - conversión;
   - TPV;
   - excepciones;
   - prioridad;
   - motivo;
   - acción sugerida.

   Priorizar por:
   - alto volumen y baja conversión;
   - alto número de pendientes;
   - inconsistencias de calidad;
   - Team Lead faltante;
   - TPV importante asociado a casos pendientes.

6. Recomendaciones accionables
   Máximo cinco recomendaciones. Para cada una incluye:
   - hallazgo;
   - acción;
   - responsable sugerido;
   - prioridad;
   - indicador de seguimiento;
   - plazo sugerido.

7. Cierre ejecutivo
   - qué debe hacer la Manager esta semana;
   - qué debe revisar con Team Leads;
   - qué debe corregirse en el proceso ETL;
   - qué datos faltan para activar alertas reales.

Formato:
- lenguaje ejecutivo;
- valores en pesos colombianos;
- porcentajes con dos decimales;
- fechas DD/MM/YYYY;
- tablas claras;
- no incluir PII innecesaria;
- marcar cualquier cifra no validada como “NO VALIDADA”.
