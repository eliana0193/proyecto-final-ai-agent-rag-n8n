# Auditoría frente a la devolución de Preentrega 4

**Fecha:** 18/11/2026. **Fuentes:** `Proyecto Final - AI Agent RAG Ollama - V7 SIN DUPLICADOS - PRUEBA.json`, `Preentrega 4 - Ingesta RAG 2 - Bucle corregido (5).json`, capturas y mediciones de ejecución suministradas. La revisión del código no sustituye la ejecución posterior a la importación.

| Punto de mejora | Estado | Evidencia y observación |
|---|---|---|
| 1. Retriever/Vector Store en el mismo flujo del agente | **Resuelto** | En V7, `Webhook → If → Simple Vector Store (Get Many) → Filtrar documentos RAG → Hay documentos autorizados → AI Agent RAG Ollama → Formatear respuesta`. La **ingesta** permanece separada, lo cual es normal para actualizar un índice; **la consulta RAG y el agente están integrados**. |
| 2. Una ejecución end-to-end desde mensaje a respuesta, con Session ID | **Resuelto técnicamente; documentar evidencia correlacionada** | `Webhook` recibe `body.from`; `Edit Fields` crea `sessionId`; en PowerShell se probó `cliente_prueba_01`; la ejecución V7 muestra Webhook, recuperación, AI Agent y respuesta. Para una figura única, conviene guardar el detalle de `sessionId` y la vista completa de **la misma ejecución**. No se usa memoria persistente. |
| 3. Reemplazar o justificar Simple Vector Store y Simple Memory | **Justificado para prototipo; mejora de producción pendiente** | Se usa Simple Vector Store en RAM, `rag_banca_01`, con reingesta tras reinicios. V7 **no usa Simple Memory**; el agente antiguo de la ingesta exportada tenía memoria, pero fue eliminado del JSON limpio de publicación. En producción se propone Supabase/PGVector persistente, permisos autenticados y filtrado por banca en el servidor antes del vector search. |
| 4. Límites concretos de mensajes tipo WhatsApp | **Resuelto para formato; canal real no implementado** | Prompt y Code final limitan a **600 caracteres** y máximo **3 elementos de lista**. Sin datos se devuelve un texto predefinido. La salida real es Webhook JSON, no API oficial de WhatsApp. |
| 5. Consulta con datos recuperados del XLSX, no Code Tool | **Resuelto** | Archivo ficticio `Datos_n8n`, 495 registros, 64 grupos banca/rubro; indexación de 4 grupos de Banca 01. Pruebas de `Sueldos básicos` (cuenta 990000001, YTD −39080), comparación de 3 cuentas y logs de Calculator. La Code Tool **con importes ficticios fijos** pertenecía al antiguo agente desconectado de ingesta y fue eliminada en copia pública. |
| 6. Metadatos de banca/rubro/período y autorización previa | **Resuelto en prototipo, con limitación de seguridad declarada** | `Default Data Loader` inserta metadatos `banca`, `rubro`, `periodo`. En V7 `Code in JavaScript` comprueba usuario y banca y `If` rechaza antes de `Simple Vector Store`. Después del vector search se valida `metadata.banca`, no se garantiza un filtro por banca dentro del motor antes de buscar. El usuario se identifica mediante `from` simulado, no está autenticado. |
| 7. Latencia, errores, consumo y pequeña prueba de carga | **Resuelto para prototipo mediante prueba exploratoria n=2** | V7 con dos solicitudes simultáneas al endpoint de producción: **28,24 s y 41,88 s; 2/2 respuestas correctas; 0 errores**; media 35,06 s. Captura de CPU 35 %, RAM 74 % y disco 13 % corresponde **a otra ejecución previa V6**, no al ensayo V7. No hay p95 ni picos; no se afirma escalabilidad. También se probó contingencia `SERVICIO_NO_DISPONIBLE`. |

## Riesgos que no se deben ocultar

- La ingesta original contenía **un antiguo agente Gemini con Simple Memory y Code Tool de demostración**, en un camino ajeno a la carga y consulta V6. La copia del repositorio lo elimina; **ya fue importada y comprobada con 495 registros**.
- `Simple Vector Store` se puede vaciar al reiniciar la instancia. **No es un índice persistente**; reejecutar la ingesta para restaurar la demostración.
- El control por `from` y filtro por banca es válido como demostración académica; no constituye autorización de producción.
- La validación final del Code puede corregir una comparación que Ollama formuló mal. Los resultados correctos de salida **no prueban infalibilidad del modelo**.
- Los mensajes de error funcional pueden enviarse con HTTP 200 y `estado=error`; es un compromiso de la API del prototipo, no un código HTTP ideal para producción.
- La carga medida incluye pruebas individuales históricas y una **prueba V7 con dos solicitudes simultáneas**, con ambos resultados correctos. No extrapolar a escalabilidad empresarial.

## Antes de entregar

1. **Realizado:** se importó y ejecutó `workflow-ingesta-rag.json` limpio, con 495 registros. Conservar original.
2. Revisar y, cuando corresponda, reconectar las credenciales de Ollama y Google Gemini después de importar los JSON públicos.
3. **Realizado:** dos solicitudes simultáneas V7 con latencias 28,24/41,88 s y 0 errores. **No** se tomó instantánea de recursos durante exactamente esta ejecución V7; la foto disponible corresponde a ejecución previa.
4. Incorporar la captura de una ejecución correlacionada del flujo V7 (identificador de sesión, RAG, AI Agent, respuesta) si la ya existente no muestra todas las etapas legiblemente.
5. Verificar rutas relativas del README y publicar en GitHub con datos sintéticos únicamente.

## Adenda V7 — cierre de seguimiento (18/11/2026)

- Se exportó la **V7 realmente probada**. La deduplicación de filas y el ajuste de `estado` eliminan la ambigüedad por copias exactas de registros.
- La copia limpia de ingesta se importó y ejecutó correctamente. Se quitaron nodos heredados sin participación en la indexación.
- Se obtuvo evidencia de dos solicitudes simultáneas correctas. El punto 7 queda atendido **para una prueba exploratoria mínima**, no para operación sostenida. Ver [PRUEBA_CARGA_V7.md](PRUEBA_CARGA_V7.md).
- Persiste la diferencia entre **autorización simulada anterior a la búsqueda** y filtro de metadatos **dentro de la búsqueda vectorial** (no implementado). También faltan controles dedicados de timeout del Vector Store, persistencia y autenticación real. No presentarlos como implementados.
