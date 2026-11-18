# Revisión de la consigna del Proyecto Final

Este checklist está orientado a no presentar **requisitos obligatorios** como “mejoras futuras”. No sustituye una rúbrica docente que pueda tener criterios adicionales.

| Requisito | Evidencia preparada | Estado antes de subir a GitHub |
|---|---|---|
| README: caso de negocio y ahorro / costo / ROI | Secciones 1 y 2, con supuestos explícitos de costo | **Preparado**, revisar supuestos elegidos |
| Entradas múltiples / fuente adecuada | Formulario de ingesta + Webhook de consulta en workflows separados | **Implementado en dos flujos**; interpretación exacta de “múltiples” potencialmente ambigua |
| Vector Store + Embeddings RAG | Ingesta y recuperación con Simple Vector Store + Gemini | **Implementado**, requiere ejecutar ingesta |
| AI Agent con System Prompt | AI Agent V7 + texto exacto incluido en README | **Implementado y probado** |
| Modelo Ollama / justificación | README, sección 3 | **Implementado** |
| Salida funcional | Webhook devuelve JSON | **Probado** |
| Gestión de dos posibles fallos | Sin datos, autorización, falla de Ollama | **Probado en tres escenarios** |
| Control de timeout del Vector Store y respuesta nula | No se ensayó de forma aislada | **No atribuirlo como implementado**. Confirmar si la consigna exige explícitamente ambos o solo alternativas |
| Workflow(s) exportados en .json | V7 y copia limpia de ingesta incluidas en `workflows/` | **Incluidos ambos; la copia limpia de ingesta se importó y probó** |
| System Prompt completo en README | Copia literal de V7 | **Preparado** |
| Capturas canvas y ejecución exitosa | `/capturas` | **Preparado** |
| Repositorio GitHub/GitLab | Crear y publicar repo | **PENDIENTE — OBLIGATORIO** |

## Antes de enviar

1. **Completado:** V7 con `qwen2.5:3b` incorporada como `workflows/workflow-agente-rag.json` (copiado del export validado, sin enlaces a credenciales ni identificadores internos).
2. **Completado a nivel de archivo:** se incorporó la exportación de ingesta que terminó en verde y se retiraron nodos heredados no utilizados. **Completado:** se importó la copia limpia en n8n y ejecutó la carga con 495 registros; evidencia `capturas/11-ingesta-limpia-validada.png`.
3. Revisar que los JSON no expongan contraseñas, claves, tokens, usuarios privados ni identificadores innecesarios; no subir datos bancarios reales.
4. Opcional pero recomendable: adjuntar una muestra exclusivamente ficticia del XLSX para que la demo sea reproducible. Los 495 registros originales no están incluidos en este ZIP.
5. Subir todos los archivos al repositorio y abrir el README en GitHub para confirmar que las imágenes y rutas funcionan.
6. No declarar probados: timeout del Vector Store, respuesta nula del LLM como escenario aislado, rendimiento multiusuario a escala, permisos empresariales, consultas productivas de 16 bancas o envío de correos. Sí se probó concurrencia **n=2** en V7.

## Qué NO es necesario implementar para cumplir literalmente la consigna

- Supabase (se propone como ejemplo de almacén vectorial, no como requisito exclusivo).
- WhatsApp real, Gmail productivo, nube empresarial o monitoreo a gran escala (son alternativas/etapas futuras).
- Uso de memoria conversacional si la solución no la requiere.

### Riesgo académico interpretativo

El apartado «Entradas Múltiples / Disparadores» ofrece varias fuentes posibles y puede interpretarse como requisito de múltiples activadores. La solución posee dos puntos de entrada **en workflows coordinados**, que se explican con transparencia en el README. Si el criterio de corrección exige más de un trigger dentro del mismo workflow, eso no está implementado.


## Estado tras incorporación del JSON de ingesta (18/11/2026)

Los dos workflows están incluidos. La ingesta fue limpiada de nodos heredados (sin cambiar su ruta de inserción), reimportada y probada con 495 registros. La prueba de concurrencia n=2 con V7 se completó con dos respuestas correctas y latencias de 28,24 y 41,88 segundos. Aún conviene añadir una captura del canvas V7 en una sola ejecución correlacionada de extremo a extremo. Ver [AUDITORIA_PREENTREGA_4.md](AUDITORIA_PREENTREGA_4.md).

## Actualización V7 y conclusiones de auditoría (18/11/2026)

- El workflow de consulta exportado y publicado es **V7**, con prompt y modelo `qwen2.5:3b`; incluye deduplicación y estado `sin_datos` cuando corresponda.
- La ingesta limpia fue reimportada y se visualizó completada en n8n (495 registros; 64 grupos; 4 grupos de Banca 01; carga al Vector Store).
- La observación docente de una **pequeña prueba de carga** está cubierta a nivel exploratorio con 2 consultas simultáneas y medición de tiempos, resultados y errores. No equivale a escalabilidad productiva. Ver [PRUEBA_CARGA_V7.md](PRUEBA_CARGA_V7.md).
- Si el docente exige literalmente un control específico de **timeout del Vector Store**, sigue sin probarse: los controles de dos puntos de fallo que implementamos son autorización, falta de filas y falla de Ollama. Mantener esta salvedad visible.
