# Mediciones

Una entrada por medición, añadida y nunca reescrita (reglas globales, «Measurements»). Se lee antes de medir: lo medido
no se repite. Cada entrada: fecha, pregunta, qué cambió desde la anterior, código y configuración, estado de la máquina,
resultado, validez (sesgos conocidos) y decisión. Datos por partida: `bench/series.csv` (antes del 2026-10-29,
`bench/partidas.csv`); cómo se mide: `bench/README.md`.

## Sesgos conocidos de las series antiguas
Las entradas hasta el 2026-10-31 se escribieron después, el 2026-10-31, desde los datos. Sufren sesgos que entonces no
se vieron, y por eso **ninguna sirve para elegir entre variantes**:
- **S1, sin courier:** nadie tenía courier hasta el 2026-10-29. Afecta a `oha-vs-valve-unfair` y `prueba-sonda`.
- **S2, el humano en Radiant:** el usuario podía quedar en Radiant con un héroe sin control. No se descartó antes del
  2026-10-29 (`partidas.csv`).
- **S3, la lógica Turbo de OHA apagada:** el custom game no es el modo 23, así que unos 12 interruptores Turbo de OHA
  no se activaban. Afecta a todas las series en Turbo hasta el 2026-10-31.
- **S4, Dire con héroes al azar:** Radiant jugaba los cinco sorteados y Dire, cinco al azar. Afecta a todas las series
  hasta `dire-ab` incluida y favorece a quien jugaba en Radiant.
- **S5, el espejo con fallos (`justa`):** Dire perdía los objetos iniciales, los guardianes y el humo; el héroe viejo
  seguía en el mapa; y Dota se cerró solo 3 veces en 12 partidas con espejo (antes del espejo, 1 vez en 126:
  `prueba-sonda`, 2026-10-29, causa desconocida).
- **S6, dota-bot jugando héroes del equipo de Valve:** el orquestador borraba el archivo de equipo al empezar la
  partida; un héroe que aparecía o se cambiaba después cargaba los scripts de dota-bot. Afecta a muchas partidas de
  todas las series: casi siempre el pid 1 de Radiant, que aparecía tarde, y desde el espejo también héroes de Dire
  (en `justa-3`, los cinco de Valve). Lo encontró el revisor adversarial del humo del 2026-10-31.
- **Filas contaminadas en `series.csv`:** muchas filas de series con estos sesgos dicen `valida=si`, porque la
  validez de entonces no los miraba. Esa columna solo vale desde el banco del 2026-10-31.
- **R, sin registro:** ninguna serie anterior anotó el commit; el estado de la máquina solo quedó por partida
  (`cpu_media`, `mem_libre`) desde el 2026-10-29.

## Entradas

### 2026-10-28 · `oha-vs-valve-unfair` (21 partidas, modo normal, Valve en Injusto)
- Pregunta: ¿juega OHA mejor que los bots de Valve?
- Resultado: dota-bot ganó 15 de 21.
- Validez: S1, S2, S4 y R. Contaminada.
- Decisión: adoptar OHA como base.

### 2026-10-29 · `empuje-ab` (24, normal; antes, `prueba-sonda`, 2)
- Pregunta: ¿gana más el cambio de empuje del PR #11?
- Cambió: el orquestador A/B intercalado y la validez por partida; los couriers llegaron en mitad del día.
- Resultado: base 11 de 12, empuje 9 de 12.
- Validez: S4 y R.
- Decisión: quitar el empuje del bot (DECISIONES 2026-10-29).

### 2026-10-30 · `mapa-prueba`, `mapa-turbo`, `mapa-modos`, `sonda-equipo`, `sonda-api` (9, Turbo imitado)
- Pregunta: reconocer cómo juegan los bots, para el mapa; no comparaban variantes.
- Resultado: docs/mapa.md.
- Validez: S3, S4 y R. Sirven como observación, no como comparación.

### 2026-10-30 · `remate-ab` (18, Turbo; antes, `remate-humo`, 2)
- Pregunta: ¿cierran antes las partidas `grupo` y `grupo_farm`?
- Resultado:
  - victorias: base 5 de 6, grupo 5 de 6, grupo_farm 4 de 6;
  - `grupo`: 4-5 bots empujando juntos el 34 % del tiempo, frente al 9 % de base, pero dejó caer la base yendo +18.000.
- Validez: S3, S4 y R.
- Decisión: no activarlo; pasar a una mejora grande, el cerebro (DECISIONES 2026-10-30).

### 2026-10-30 · `cerebro-ab` (24, Turbo; antes, `cerebro-humo` y `cerebro-humo2`, 4)
- Pregunta: ¿mejora el cerebro de equipo v1?
- Resultado:
  - victorias: base 11 de 12, cerebro 8 de 12;
  - cierre desde +10.000: cerebro unos 10 min, base unos 19;
  - el cerebro muere más.
- Validez: S3, S4 y R.
- Decisión: v2 y builds juntas (DECISIONES 2026-10-30).

### 2026-10-30/31 · `v2-ab` (15, Turbo, parada en la 16.ª; antes, `v2-humo`, 2)
- Pregunta: ¿mejoran el cerebro v2 y las builds con datos?
- Resultado: base 7 de 7 y cerebro_builds 5 de 8 contadas aquí. En el momento se resumió como «cerebro 10 de 10 en
  Radiant y 3 de 10 en Dire» sumando dos series.
- Validez: S3, S4 y R. La diferencia entre lados era S4, no un fallo de posición.
- Decisión: parar y arreglar Dire (DECISIONES 2026-10-31). La causa que se buscó era errónea.

### 2026-10-31 · `v2-dire`, `dire-fix`, `dire-aislar`, `dire-ab`, `turbo-oha` (25, Turbo, todo en Dire)
- Pregunta: ¿qué hace perder a dota-bot en Dire?
- Resultado:
  - `v2-dire`: 2 de 6;
  - `dire-ab`: base 0 de 3, cerebro_def 0 de 3;
  - bloques de 2 partidas por variante, sin poder para distinguir nada.
- Validez: S3, S4 y R. Medían S4 sin saberlo.
- Decisión: tras la insistencia de Pedro se encontró S4 y se hizo el espejo (`base-espejo`, 2 partidas, lo comprobó).

### 2026-10-31 · `justa` (8 de 12, Turbo, parada)
- Pregunta: base contra base_estado contra cerebro_def, con héroes espejo.
- Resultado: no se usa.
- Validez: S5 y R. Contaminada.
- Decisión: parar la serie, arreglar el espejo y crear la puerta de medición y los tres niveles (DECISIONES 2026-10-31).

### 2026-10-31 · `humo` (partidas de humo del banco nuevo)
- Pregunta: ¿cumple el banco la tabla del protocolo?
- Resultado:
  - 1.ª: el control de inicio miraba demasiado pronto;
  - 3.ª, con el commit `8b602799af26`: mismos héroes, patrimonio inicial 2.950 frente a 3.001, y Dota se cerró en el
    minuto 15 (S5: el héroe viejo).
- Validez: puerta del nivel 0, no comparación.
- Decisión: borrar el héroe viejo (commit `5d8bfb5`); repetir el humo y comprobar que Dota ya no se cierra antes de la
  serie A contra A.

### 2026-10-31 · `humo` con el banco fusionado (1 partida, commit `448f626`)
- Pregunta: puerta del nivel 0 antes de la serie A contra A.
- Máquina: CPU 38 %, memoria libre 50 %.
- Resultado:
  - terminó (35 min), sin crash;
  - espejo, borrado del héroe viejo, patrimonio inicial (2.977 frente a 3.026) y couriers (5 y 5 a 1.100), correctos.
- Validez, según el revisor adversarial:
  - **S6:** el Necrophos de Dire, que debía jugar Valve, lo jugó dota-bot;
  - el héroe del puesto 1 de Radiant apareció en t=+3;
  - la velocidad real fue ×2,28, no ×4, y varía con la carga de Lua.
- Decisión: no lanzar la serie A contra A.
  - Arreglos: el archivo de equipo se queda hasta el final, y la validez exige el observador, ningún héroe de Valve
    jugado por dota-bot y ningún héroe aparecido tras el inicio.
  - Prueba: añadir los bots un segundo después de sacar al humano.
  - Siguiente paso: repetir el humo con dota-bot en cada lado.

### 2026-10-31 · `humo` del reparto de héroes (13 partidas, commits `2b3de55` a `b3138c2` y siguiente)
- Pregunta: ¿cómo consiguen los dos equipos los héroes pedidos, sin que se cierre Dota?
- Resultado, medido:
  - si los dos equipos entran a la vez, el primero recibe sus héroes y el segundo, unos al azar que nunca coinciden
    con los del primero (0 de 112 partidas): el motor no repite héroe entre equipos;
  - con 30 s de selección pasa lo mismo, y un equipo que entra 1 s después no recibe ninguno;
  - el primer bot añadido aparece de 15 a 50 s después que los demás; con 90 s de fase previa llegan todos antes del
    inicio;
  - cambiar los héroes de Dire (`ReplaceHeroWith`) cerró Dota en 5 de 16 partidas, y crearlos (`CreateHeroForPlayer`)
    también lo cerró, además de que el motor no los cuenta como héroes de sus jugadores;
  - con dos sorteos sin héroes en común, cada equipo recibió el suyo y no hubo cierres (2 de 2).
- Validez: puerta del nivel 0, no comparación.
- Decisión: mismo enfrentamiento en los dos lados en lugar de mismos héroes (DECISIONES 2026-10-31); se quitan el
  espejo y la creación de héroes.

### 2026-10-31 · `humo` del banco final (2 partidas, rama `claude/banco-s6`, PR #24)
- Pregunta: puerta del nivel 0; ¿pasan todos los controles con dota-bot en cada lado?
- Resultado: 2 de 2 válidas (43 y 29 min, sin cierres); cada equipo con su grupo, todos los héroes antes del inicio,
  ningún héroe de Valve jugado por dota-bot, couriers Turbo y patrimonio inicial parejo. Antes, dos partidas
  invalidadas por el propio control de código al tocar el orquestador y hacer un commit durante la serie (corregido:
  se comparan los árboles de `bots/` y `tools/bench/`).
- Decisión: pasar a la serie A contra A.

### 2026-10-31 · `aa` (serie A contra A, nivel 0) — pregunta escrita antes de lanzarla
- Pregunta: con dos versiones idénticas, ¿cuánto se separan por azar (el ruido) y cuánto gana el lado del mapa por sí
  solo? Sin eso, ninguna diferencia entre variantes se puede leer.
- Qué cambió desde la anterior: nada en el bot; primera serie con el banco completo (PR #24).
- Configuración: `--variantes base,base_b --partidas 12 --modo turbo`, sin observador, Valve en Injusto, ×4. Bloques de
  4 (cada variante en los dos lados, mismo enfrentamiento), 3 bloques.
- Métricas, fijadas antes: victorias por brazo; victorias de dota-bot en Radiant frente a Dire; minutos de partida y
  minuto de +10.000 hasta el final, con su dispersión por brazo; partidas inválidas y topes.
- Qué se espera: brazos parecidos. Una diferencia grande entre brazos idénticos mide el ruido que tendrá cualquier
  comparación de 12 partidas.
- Sin comprobar que puede pesar: la velocidad real variable (×1,6 a ×3,4); la lista de héroes del sorteo, recordada.

### 2026-11-01 · `aa` — resultado (11 de 12 jugadas, parada sola por >20 % inválidas)
- Máquina: libre en las partidas 1-3 (CPU media 32-46 %); saturada en las 4-11 (76-98 %, Unreal, python y sumo;
  Pedro decidió seguir, DECISIONES 2026-10-31). Código `349e8da` (árboles iguales en toda la serie).
- Inválidas: 3 (partidas 7, 10 y 11), todas por patrimonio inicial con ~850 de diferencia, y las tres con una baja
  antes del inicio (minuto 0 con kills); las 8 válidas, ninguna. Es juego, no sesgo: el control se corrige (rama
  `claude/banco-nw`).
- Resultado de las 8 válidas:

  | Métrica | base (5) | base_b (3) | Juntas (8) |
  |---|---|---|---|
  | dota-bot ganó | 3 | 2 | 5 de 8 |
  | Minutos de partida | 38, 40, 31, 31, 31 | 29, 35, 22 | media 32 |
  | Minuto en que llegó a +10.000 | 10, 12, 8, 12, 11 | 9, 11, 10 | media 10,4 (dispersión ~1,4) |

  - Lado: dota-bot ganó 3 de 4 en Radiant y 2 de 4 en Dire; Radiant ganó 5 de 8 partidas.
  - Carga: con la máquina libre, 2 de 3; con la máquina saturada, 3 de 5. Duración media 35,7 frente a 30 min.
    Con estos números ninguna diferencia se distingue del azar.
- Lectura:
  - los dos brazos idénticos quedan en 3 de 5 y 2 de 3: compatibles con ninguna diferencia, como debe ser;
  - **el porcentaje de victorias es demasiado ruidoso para el nivel 2**: con victorias en torno al 60 %, distinguir
    20 puntos entre dos variantes pide del orden de 90 partidas por brazo (unas 50 horas);
  - el minuto en que se llega a +10.000 varía poco (~1,4 min): es una métrica mucho más sensible, igual que el tiempo
    de cierre desde +10.000;
  - ni el lado ni la carga muestran efecto con 8 partidas; no se descarta uno pequeño.
- Decisión: corregir el control de patrimonio inicial; para el nivel 2, métricas principales sensibles (minuto de
  +10.000, cierre desde +10.000, ventaja máxima, muertes) con victorias como métrica secundaria. Tamaño y pregunta, en
  su entrada antes de lanzar.

### 2026-11-01 · `humo-n1` (nivel 1, variante `nivel1`, 2 partidas con observador, commit `39f4b1d`)
- Pregunta: ¿se mueven las métricas de los dos arreglos (filtro de ultis y defensa de T1/T2) sin romper nada?
- Máquina: CPU 15-23 %, memoria libre 54 %.
- Resultado:
  - variante aplicada en las dos (`filtro_ultis=true defensa_t12=true` en el log), ningún `ult_gate error`;
  - ultis de dota-bot: 40, ninguna sin un enemigo a 1.200 (antes, el 10 %); el filtro no tuvo que rechazar ninguna
    con estos héroes (Chaos Knight, Necrophos, Kunkka, Lion, Witch Doctor), así que el rechazo y que el héroe no se
    quede quieto **siguen sin comprobarse en partida**;
  - defensa: 45 y 51 decisiones; con 1-2 atacantes y aliados a tiempo, «defiende», y los elegidos pasan a
    `DEFEND_TOWER_*` con deseo 0,95; cuando los defensores mueren y no llegan bastantes, «concede». Las torres que
    cayeron sin defensores cayeron tras peleas perdidas, no por abandono;
  - las dos partidas las ganó Valve (2 partidas no dicen nada).
- Validez: puerta del nivel 1, no comparación.
- Decisión: el nivel 1 pasa; el rechazo de ultis se comprobará cuando salgan héroes con ultis de riesgo (Skywrath,
  DK). Fusionar y pasar al nivel 2.
