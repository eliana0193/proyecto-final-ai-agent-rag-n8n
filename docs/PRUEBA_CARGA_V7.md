# Prueba de carga exploratoria V7 — 18/11/2026

## Objetivo

Validar que la consulta RAG con AI Agent Ollama responde correctamente a dos preguntas enviadas en paralelo desde PowerShell, usando el endpoint de producción del Webhook del **workflow V7**.

## Entorno

n8n local (Docker), Simple Vector Store `rag_banca_01`, embeddings de Google Gemini y agente Ollama `qwen2.5:3b`. Base académica: Excel sintético de 495 filas / 16 bancas; la demostración indexa Banca 01. Datos de entrada de PowerShell con `from=cliente_prueba_01`. La autorización es simulada.

## Resultados observados

| N.º | Consulta | HTTP | `estado` | `verificacion` | Respuesta | Latencia |
|---|---|---|---|---|---|---:|
| 1 | Sueldos básicos, Banca 01, YTD | 200 | `ok` | `cuenta_validada` | −39.080, sobregasto | 28,24 s |
| 2 | Plus vacacional, Banca 01, YTD | 200 | `ok` | `cuenta_validada` | −55.610, sobregasto | 41,88 s |

- **Respuestas correctas:** 2/2; errores HTTP de la repetición exitosa: 0; **latencia media:** 35,06 s.
- Dos solicitudes solamente: la tasa 100 % es un **resultado de la muestra**, no una tasa de disponibilidad futura.
- No hay percentiles p95/p99 ni medición de throughput. Los tiempos incluyen toda la cadena desde la solicitud hasta la respuesta.
- Una fotografía anterior del Administrador de tareas durante el test de V6 mostró **35 % CPU, 74 % RAM y 13 % disco**. Son cifras globales de esa instantánea, **no mediciones propias del test V7**.

## Lecciones del diagnóstico

1. La prueba V6 recuperó al menos dos copias de una misma línea de `Plus vacacional`. La validación final la interpretó como ambigua y devolvió «información insuficiente», a pesar de tener los datos.
2. V7 deduplica filas idénticas al construir el contexto y nuevamente en la validación, sin reemplazar filas con importes distintos.
3. En un intento anterior de enviar solicitudes simultáneas se observó 404 para una consulta. Fue necesario utilizar `/webhook/` publicado, no `/webhook-test/` bajo escucha.
4. La prueba exitosa utiliza `http://localhost:5678/webhook/consulta-presupuesto-rag-ai-agent-v7` en el equipo de pruebas. Es una URL local de ejemplo; verificar al importar.

## Capturas

- [Resultados de PowerShell V7](../capturas/13-v7-prueba-concurrencia.png)
- [Respuesta individual V7](../capturas/12-v7-consulta-individual.png)
- [Duplicados observados en V6](../capturas/14-v6-duplicados-diagnostico.png)
- [Recursos en instantánea de prueba previa V6](../capturas/15-recursos-referencia.png)

## Reproducibilidad

Ejecutar [`scripts/prueba-carga-2-consultas.ps1`](../scripts/prueba-carga-2-consultas.ps1) con `-Url` apuntando a la ruta de producción de una V7 activada y con la colección indexada. Revisar `estado`, respuesta y códigos HTTP de **ambos** resultados, no solamente HTTP 200.
