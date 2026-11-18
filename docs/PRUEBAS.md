# Registro de pruebas — V7 AI Agent RAG Ollama y antecedentes de V6

Pruebas realizadas el 18 de noviembre de 2026 en entorno local con datos ficticios. La primera tabla recoge pruebas individuales **históricas de V6**; la segunda documenta **V7**, incluida una prueba pequeña de dos consultas concurrentes. La verificación determinística del nodo final es independiente de la calidad del texto original de Ollama.

| Caso | Entrada | Resultado observado | Latencia | Evidencia |
|---|---|---|---:|---|
| Consulta individual | `cliente_prueba_01`, Sueldos básicos Banca 01 YTD | HTTP 200; `estado=ok`; `verificacion=cuenta_validada`; −39.080 (sobregasto) | 42.604 ms | `capturas/03-consulta-individual-powershell.png` |
| Comparación parcial | 3 cuentas PERSONAL Banca 01 YTD | HTTP 200; `lista_comparada_validada`; 255 caracteres; mayor sobregasto Plus vacacional −55.610 | 36.302 ms | `capturas/04-comparacion-powershell.png` |
| Uso de herramienta | Misma comparación | Logs del Agent muestran Ollama → Calculator → Ollama (el detalle de la operación no fue capturado) | Incluido en comparación | `capturas/05-ai-agent-calculator-logs.png` |
| Cuenta inexistente | Cuenta 999999999 Banca 01 | HTTP 200; `sin_datos`; `SIN_FILAS_RELEVANTES` | 855 ms | `capturas/06-cuenta-inexistente.png` |
| Autorización | `cliente_prueba_01` consulta Banca 02 | HTTP 200; respuesta de rechazo; `If` con `autorizado=false` pasa por False | 214 ms | `capturas/07-rechazo-banca-02.png` y `08-if-autorizacion-false.png` |
| Falla de Ollama | Modelo inexistente solo en copia experimental | HTTP 200; `estado=error`, `SERVICIO_NO_DISPONIBLE`; mensaje controlado | No se registró latencia | `capturas/09-contingencia-ollama-powershell.png` |

## V7: corrección de duplicados y prueba concurrente

| Caso | Resultado observado | Latencia | Evidencia |
|---|---|---:|---|
| V7 consulta individual Plus vacacional | HTTP 200; −55.610 (sobregasto); `estado=ok`, `cuenta_validada` | No se registró en esta captura | `capturas/12-v7-consulta-individual.png` |
| V7 concurrencia: Sueldos básicos | HTTP 200; −39.080 (sobregasto); `estado=ok`, `cuenta_validada` | **28,24 s** | `capturas/13-v7-prueba-concurrencia.png` |
| V7 concurrencia: Plus vacacional | HTTP 200; −55.610 (sobregasto); `estado=ok`, `cuenta_validada` | **41,88 s** | `capturas/13-v7-prueba-concurrencia.png` |
| Ingesta limpia reimportada | 495 filas XLSX, 64 textos, 4 grupos filtrados, inserción completada | No medida | `capturas/11-ingesta-limpia-validada.png` |

**Resumen de V7 (concurrencia n=2):** 2/2 respuestas correctas; cero fallos HTTP; latencia media **35,06 segundos**. No extrapolar a carga alta. La captura de CPU 35 %, RAM 74 %, disco 13 % pertenece a una prueba anterior con V6 y no describe los recursos de esta corrida V7.

**Aclaraciones de verificación:**

- La comparación del mayor sobregasto se valida en el Code final a partir de filas autorizadas. El modelo generativo puede equivocarse y su salida no sustituye la comprobación numérica.
- El agente utiliza un modelo local, pero los embeddings Gemini requieren servicio externo.
- Un `HTTP 200` no significa necesariamente éxito funcional. Registrar siempre `estado`, `codigo`, `verificacion` y la rama ejecutada.
- Las respuestas de cuentas inexistentes y la autorización de demo no prueban cómo se comportaría el sistema con información corporativa real.
- Los tiempos son end-to-end y no permiten medir cuánto consumió cada nodo o inferir desempeño con muchos usuarios.
- Un error HTTP 404 previo fue consecuencia de llamar a un endpoint no registrado en modo prueba; la prueba correcta se hizo con `/webhook/` de producción activo.
- Ver [prueba de carga V7](PRUEBA_CARGA_V7.md) y [cambios V7](CAMBIOS_V7.md).
