# Cerebro v3: el equipo juega como equipo

Propuesta del 2026-11-01 para que Pedro la apruebe antes de construir. Pedro: «necesito toda la conclusión de
profesionales y entornos ranked que sacaste aplicadas al bot que sea algo contundente y que se note en comportamiento
de manera real». Regla vigente (DECISIONES 2026-10-30): una mejora grande con argumentos sólidos, medida **una sola vez
al final**, no una serie por cada detalle.

## Por qué, con lo medido en el banco fiable (MEDICIONES, 2026-10-31 y 2026-11-01)

1. **dota-bot regala sus ventajas.** Pierde la mitad de las partidas en las que llega a ir +10.000 (10 de 15 en
   `n2-pd`). En partidas profesionales, el primero en llegar a +10.000 pierde el 4 % (datos-pro, a). Es el defecto más
   caro y el que más se nota jugando.
2. **Muere huyendo demasiado tarde.** Dos tercios de sus muertes ocurren en retirada; el 70 % en los 4 primeros
   segundos de huida. En `humo-ret`, cada muerte tuvo, entre 1 y 10 s antes, una amenaza (daño enemigo estimado en
   5 s) mayor que su vida, y 6 de cada 14 seguían atacando.
3. **No cierra.** `base` llegó dos veces al tope de 60 min con +94.000 y +52.000. Los profesionales cierran en una
   mediana de 7,5 min desde +10.000.
4. **Las reglas sueltas no mueven nada.** El filtro de ultis, la defensa de T1/T2 y el empuje en grupo, cada uno por
   su lado, no mostraron mejora (`n2-nivel1`, `n2-pd`): el problema es de coordinación de equipo, no de un
   comportamiento aislado.
5. **Hoy cada bot decide solo** (criterio-de-juego, §0): «somos más fuertes» ignora cooldowns, ultis y niebla; las
   ultis de iniciación se lanzan cuando la pelea ya empezó; los aturdimientos no se encadenan; nadie espera a nadie.

## Qué hace el cerebro v3

Un plan de equipo, recalculado cada 0,2 s, que los cinco obedecen (base: el cerebro v2, que ya tiene estados, punto de
reunión, evaluación de pelea simple y encadenado de aturdimientos). v3 lo convierte en un sistema completo en cinco
capas. Cada línea dice de qué conclusión sale.

### Capa 1 · Saber si la pelea se gana (base de todo lo demás)
- **Evaluación de pelea v3** en un lugar, para los próximos 10-20 s (criterio §1):
  - aliados que llegan en 8 s o menos (distancia, velocidad, TP listo o en curso), con sus ultis y su maná;
  - enemigos visibles con su poder bruto, rebajado si los vimos gastar la ulti hace menos de su cooldown;
  - enemigos que dejamos de ver hace menos de 10 s cerca de allí, y los que faltan del mapa;
  - bonos: iniciación disponible (blink + control listo), BKB del carry, Aegis, torre propia cerca; penalización:
    pelea bajo torre enemiga o en su jungla sin visión.
- **La amenaza individual** (lo validado en `humo-ret`): daño que los enemigos cercanos pueden hacer en 5 s / vida.
- **Sustituye a «somos más fuertes» de OHA en todos sus usos:** retirada, ayudar a un aliado, defensa y empuje. Con
  histéresis: se entra a pelear por encima de 1,1 y se sale por debajo de 0,8, para no oscilar.

### Capa 2 · No regalar muertes (defecto 2)
- **Retirada a tiempo:** cuando la amenaza supera la vida y la pelea no se gana, huir ya, sostenido mientras siga la
  amenaza (la variante `retirada_temprana` v2, que adelantó la huida de 4 s a 2 s en `humo-rt2`).
- **Enemigos que faltan del mapa** (decisión del 2026-10-31): con 3 o más enemigos sin ver, nadie farmea solo en la
  mitad enemiga ni en líneas lejanas; se farmea en la mitad propia o en grupo.
- **Caza de un aliado:** salvar, ceder o contraatacar (criterio §2). Se va solo si los que llegan antes de que muera
  ganan la pelea resultante; si no, se cede y nadie acude de uno en uno, y los demás aprovechan para tomar algo en otra
  parte del mapa.
- **Tras perder una pelea** (criterio §3): REAGRUPAR en la torre propia más adelantada, farm de jungla propia
  desbloqueado aunque haya ventaja, y no se vuelve a pelear hasta que reaparecen los muertos.

### Capa 3 · Jugar la ventaja (defectos 1 y 3)
- **Con ventaja, no arriesgar** (criterio §10): con +5.000 o más, nadie pelea si la evaluación no lo da a favor; se
  presiona con la ventaja (líneas, jungla enemiga cercana en grupo, visión) en vez de con riesgo.
- **Convertir cada pelea ganada en un objetivo**, dentro de la ventana de reaparición enemiga (criterio §9; los
  profesionales tiran el 38 % de las T3 en los 90 s tras una pelea ganada, frente al 12 % de tiempo base): con 2 o
  más enemigos muertos, tomar lo más valioso que quepa en la ventana (torre, cuarteles si están los 4-5, Roshan) y
  retirarse ordenadamente cuando la ventana acaba.
- **Roshan como licencia** (datos-pro, c y b): quien mata a Roshan tira 2 torres de mediana en 5 min y gana el 79 %; la
  mitad de las primeras T3 cae con Aegis. Roshan se hace con ventaja y en superioridad, y el Aegis abre el asalto.
- **Cerrar la partida por asaltos** (criterio §12): con +10.000 o cuarteles caídos, alternar ASALTO (los cinco a una
  línea, con Aegis o en una ventana de reaparición) y PREPARAR (farm de jungla enemiga cercana y empuje lateral con
  creeps, sin bajar de 3 juntos). Nunca high ground en inferioridad.
- **Recompra para la base y la pelea decisiva**, no para repetir la pelea perdida; el carry guarda oro de recompra a
  partir de cierta ventaja.

### Capa 4 · Ganar las peleas (contra humanos es lo que más se nota)
- **Iniciación por fases** (criterio §6): FORMAR (los asignados se juntan a ~1.200 del grupo enemigo, nadie entra) →
  INICIAR (con suficientes aliados cerca, el iniciador entra: blink + control) → SEGUIR (todos al foco, en el orden del
  combo) → LIMPIAR. Contrainiciación: si un enemigo salta sobre nosotros, control y foco sobre él. Corrige que hoy las
  ultis de iniciación esperen a que la pelea ya esté empezada.
- **Combos de ultis** (criterio §5, tabla de pares): el control va primero y el daño de área dentro de su ventana; dos
  controles de área no se pisan; Chrono no se lanza sobre aliados cuerpo a cuerpo; las ultis de daño se retienen hasta
  1,5 s esperando el control. Los profesionales que usan 4+ ultis en una pelea la ganan el 62 %, frente al 36-40 % con
  0-1 (datos-pro, h).
- **Foco de equipo** (criterio §7): el enemigo que muere antes y más cambia la pelea; no perseguir a quien tiene BKB o
  salvada activa; cambiar de foco solo si el nuevo es claramente mejor.
- **Aturdimientos encadenados por tiempo restante** (criterio §4, ya en v2) con un aturdimiento reservado para
  interrumpir canalizaciones (Black Hole, Death Ward, TP).
- **Salvadas y BKB** (criterio §8): cada objeto de salvar tiene un protegido y no caen dos sobre el mismo aliado; BKB
  antes del control clave, no cuando la amenaza ya pasó.

### Capa 5 · La base, intocable (criterio §11)
- La defensa de high ground se evalúa **antes** del bloqueo de OHA que la apaga cuando el equipo empuja, y graduada por
  amenaza (1-2 defensores para una oleada, todos con héroes enemigos en la base); recompra por Ancient con la vida en
  fracción (el arreglo ya existe en v2); glifo para ganar tiempo.
- **Builds con datos** de jugadores de alto nivel (ya en v2, variante `builds`): BKB y Blink a su tiempo, que son los
  picos de poder que usa la evaluación de pelea.

## Qué no cambia
- Las habilidades de cada héroe siguen en sus 127 archivos de OHA; el cerebro les dice cuándo y a quién, no cómo.
- Todo detrás de la variante `cerebro_v3`, apagado por defecto hasta que la medición lo justifique.

## Cómo se construye
- Sobre el cerebro v2 (`bots/FunLib/team_brain.lua`), en este orden, cada capa con una comprobación interna en una
  partida observada (que el mecanismo actúa, no una serie): 1 → 2 → 3 → 5 → 4. La capa 4 es la más delicada y va
  la última.
- Antes, las comprobaciones de API que pedía la investigación, en una sola partida observada: que se leen los
  modificadores y su tiempo restante en enemigos, los TP enemigos entrantes y la reaparición de enemigos muertos.
- Una revisión de Opus por capa, con la consigna de verificar cada función contra la referencia de la API (el filtro
  de ultis no hacía nada por una función inexistente y nadie lo vio hasta la revisión).

## Cómo se mide: una vez, al final
- Una serie `cerebro_v3` frente a `base`, de 32 partidas (16 por brazo), con la pregunta y el análisis fijados antes
  en MEDICIONES.
- Métricas principales: derrotas tras ir +10.000 (hoy ~50 %), muertes por partida, victorias; con 16 por brazo se
  distingue una diferencia de unos 35 puntos en victorias, que es el tamaño de mejora que se busca. Secundarias: cierre
  desde +10.000, topes, ventaja máxima.
- Si mejora con claridad, se propone a Pedro activarlo por defecto y probarlo con sus amigos.

## Coste y riesgos
- Construirlo es trabajo de varias sesiones del agente, no de horas. La serie final, unas 14-16 horas de máquina.
- Riesgo principal: con un plan común, un error hace que fallen los cinco a la vez (antes fallaba uno). Mitigación:
  histéresis en cada decisión, tiempos límite en cada fase y comprobación de cada capa en partida antes de la siguiente.
- Riesgo de pasividad (esperar demasiado): cada estado de espera tiene duración máxima y no se activa con ventaja de
  vivos.
