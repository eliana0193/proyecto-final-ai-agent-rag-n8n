# Workflows incluidos

- `workflow-ingesta-rag.json`: ingesta del XLSX mediante formulario, extracción de `Datos_n8n`, agrupación, filtro de Banca 01, embeddings Gemini y almacenamiento Simple Vector Store. Conserva una rama manual de consulta para comprobar que se cargaron documentos. Es **una copia de presentación limpiada**: se quitaron seis nodos de un prototipo conversacional antiguo (Gemini Agent + Simple Memory + Code Tool + Webhook). Se conservaron los parámetros de los doce nodos restantes y las conexiones entre ellos, pero **esta copia limpia se importó y se ejecutó correctamente con 495 registros; la captura está en `capturas/11-ingesta-limpia-validada.png`**.
- `workflow-agente-rag.json`: flujo V7 probado con dos solicitudes concurrentes correctas, autorización antes de la recuperación, RAG obligatorio, AI Agent con Ollama `qwen2.5:3b` y Calculator, validaciones numéricas y contingencia del modelo.

Ambos utilizan la misma clave de almacenamiento `rag_banca_01` y el mismo modelo de embeddings Google Gemini. El almacenamiento en RAM es volátil. La ingesta de demostración selecciona solo Banca 01, aunque el Excel sintético tiene 16 bancas.

**Seguridad en GitHub:** se quitaron los vínculos a credenciales y los identificadores de instancia de las copias publicadas. Tras importar, volver a asignar las credenciales de Ollama y Gemini. Nunca subir claves API ni datos reales del banco.

**Sobre V7:** incluye deduplicación en `Filtrar documentos RAG` y `Formatear respuesta para Webhook`, sin cambio de modelo. Se omitieron identificadores de instancia, IDs superiores de despliegue y referencias a credenciales en el JSON de publicación; volver a asociar credenciales al importarlo.
