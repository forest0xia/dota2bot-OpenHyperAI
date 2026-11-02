# Encargo para los revisores adversariales del cerebro v3

Pedro, 2026-11-01: «en la próxima sesión fresca sometemos tu planteamiento a agentes adversariales para tomar la firma
final e implementar. PERO no olvides darles el contexto entero para que los subagentes no sugieren tonterias
minúsculas nuevamente». Este archivo es ese contexto: se pasa **entero** a cada revisor, junto con
`trabajo/cerebro-v3.md` (la propuesta).

## Qué se les pide
Revisar la propuesta `trabajo/cerebro-v3.md` **como un todo** y decir si es la mejora grande y contundente que Pedro
pidió, qué le falta para serlo y qué sobra o es arriesgado. Los dos sentidos: dónde la propuesta se queda corta (es
poco ambiciosa, deja fuera algo de la investigación que pesa) y dónde un punto puede empeorar el bot o es inviable con
la API de bots de Valve.

## Lo que NO se les pide (y por qué)
- **Nada de proponer ajustes sueltos, medir una regla aislada ni series por cada detalle.** Regla de Pedro
  (DECISIONES 2026-10-30): «si por cada minusia vamos a hacer una corrida nos pasaremos la vida entera ennpruebas sin
  hacer mejoras […] quiero que postulemos una mejor cuantiosa basada en argumentos solidos y mejoremos». Y el
  2026-11-01: «si seguimos a este paso haremos 20 partidas por cada creep muerto de diferencia y esto ya lo habiamos
  dejhado claro y como regla». Tres series de reglas sueltas (filtro de ultis + defensa de T1/T2, umbral del empuje en
  grupo, retirada temprana) no mostraron mejora clara: el problema es de coordinación de equipo.
- Nada de dividir el cerebro en fases medidas por separado. Se construye entero, cada capa se comprueba en una partida
  observada (que el mecanismo actúa) y se mide **una vez al final** contra `base`.
- No basar nada en las series anteriores al 2026-10-31: estaban contaminadas (MEDICIONES.md, sesgos S1-S6).

## Contexto que deben leer
- `trabajo/cerebro-v3.md`: la propuesta.
- `docs/investigacion/2026-10-30-criterio-de-juego.md`: criterio de juego en profundidad (12 criterios, lista
  priorizada, hallazgos del código de OHA en §0). Pedro pidió criterio, no solo números: «no toda ma metrica debe ser
  en base a datos cuantitativos […] las mecanicas del juego en profundidad y de criterio».
- `docs/investigacion/2026-10-30-datos-pro.md`: métricas de partidas profesionales (OpenDota, modo normal, no Turbo).
- `MEDICIONES.md`: lo medido con el banco fiable (desde `aa`): ruido, `n2-nivel1`, `n2-pd`, humos de la retirada.
- `trabajo/cerebro-equipo.md` y `bots/FunLib/team_brain.lua`: el cerebro v2 existente sobre el que se construye.
- `docs/BOT_API_REFERENCE.md` y `bots/FunLib/aba_global_overrides.lua`: qué se puede hacer con la API y qué OHA ha
  sobreescrito. Dos cambios anteriores no hacían nada en silencio por usar funciones que no existen en la API de bots
  (`GetAbilityType`) o que OHA anula para no-héroes (`WasRecentlyDamagedByAnyHero` en torres): verificar cada función.
- `docs/mapa.md`: cómo juegan de verdad OHA y los bots de Valve en este banco.

## Hechos medidos que la propuesta debe atacar (banco fiable, 2026-10-31/11-01)
- dota-bot gana alrededor del 50-60 % contra los bots de Valve en Injusto, Turbo imitado.
- Pierde la mitad de las partidas en las que llega a ir +10.000 (10 de 15 en `n2-pd`); entre profesionales, el primero
  en llegar a +10.000 pierde el 4 %.
- Dos tercios de sus muertes ocurren en retirada, el 70 % en los 4 primeros segundos de huida; en `humo-ret` cada
  muerte tuvo una amenaza (daño enemigo estimado en 5 s / vida) ≥ 1 entre 1 y 10 s antes.
- `base` llegó al tope de 60 min con +94.000 y +52.000 sin cerrar.
- Las victorias son ruidosas: con 16 partidas por brazo solo se ve una diferencia de unos 35 puntos; métricas más
  sensibles: derrotas tras ir +10.000, muertes por partida, minuto de +10.000 (dispersión ~1,4 min).

## Condiciones del banco (no se discuten aquí)
Custom game local `dotabench`, dota-bot contra bots de Valve, mismo enfrentamiento desde los dos lados, Turbo imitado,
validez comprobada por partida (bench/README.md, «Protocolo de medición»). Cada partida tarda unos 15-20 min reales.

## Qué entregar
1. Veredicto: ¿es contundente? ¿qué capa o criterio pesa más y cuál menos?
2. Lo que falta para que se note de verdad en el comportamiento (de la investigación o del criterio de juego), con su
   porqué.
3. Riesgos reales (empeorar el bot, inviable con la API), cada uno con cómo mitigarlo dentro del diseño, sin quitarle
   ambición.
4. Orden de construcción recomendado y cómo comprobar cada capa en una partida observada.
5. La pregunta, las métricas y el tamaño de la serie final única.
