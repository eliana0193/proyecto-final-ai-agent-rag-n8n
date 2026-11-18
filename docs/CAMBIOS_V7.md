# Cambios de V6 a V7 — deduplicación del contexto RAG

**Motivo:** varias cargas en Simple Vector Store devolvieron copias idénticas de cuentas presupuestarias. La validación V6 requería una sola fila para consultas individuales y devolvió `sin_datos` por ambigüedad.

**Nodos modificados en V7:**

1. `Filtrar documentos RAG`: almacena claves por banca, rubro, cuenta y contenido normalizado. Descarta únicamente filas idénticas antes de armar `contextoRAG` e informa `filasDuplicadasDescartadas`.
2. `Formatear respuesta para Webhook`: elimina líneas idénticas del contexto como segunda barrera; para un resultado insuficiente retorna `estado=sin_datos`, no `ok`.

**Sin cambios funcionales de arquitectura:** Webhook, validación de banca, Simple Vector Store con `rag_banca_01`, Gemini Embeddings, AI Agent Ollama `qwen2.5:3b`, Calculator, rutas de salida y error.

**Verificación observada:** consulta individual V7 de Plus vacacional con −55.610 (sobregasto) y concurrencia de dos consultas con 2/2 respuestas correctas. El modelo original con nombre ficticio solo existió en una copia de prueba de contingencia; el export V7 usa `qwen2.5:3b`.

**Limitación:** La deduplicación en lectura no previene inserciones redundantes en la memoria del índice. Para uso sostenido, reemplazar por un almacén persistente con identificadores estables/actualización controlada y filtrado por permisos en origen.
