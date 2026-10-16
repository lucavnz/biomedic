#import "@preview/mitex:0.2.6": *

#set document(
  title: "Spiking Neural Networks per Sistemi Biomedicali Impiantabili: Applicazioni e Architetture Circuitali CMOS",
  author: "Relazione Tecnica di Elettronica Biomedica"
)

#set page(
  paper: "a4",
  margin: (top: 2.2cm, bottom: 2.2cm, left: 2cm, right: 2cm),
  numbering: "1"
)

#set text(
  font: "Times New Roman",
  size: 10.5pt,
  lang: "it"
)

#set par(
  justify: true,
  leading: 0.65em
)

#show heading: set block(above: 1.4em, below: 0.8em)

#align(center)[
  #text(size: 17pt, weight: "bold")[
    Spiking Neural Networks per Sistemi Biomedicali Impiantabili:\
    Applicazioni e Architetture Circuitali CMOS
  ]
  #v(0.6em)
  #text(size: 11.5pt, style: "italic")[
    Relazione Tecnica Approfondita — Corso di Elettronica Biomedica
  ]
]

#v(1.2em)
#outline(title: "Indice Generale", indent: 1.2em, depth: 3)
#pagebreak()


#strong[Relazione Tecnica di Ricerca Bibliografica e Analisi Circuitale]
#strong[Corso di Elettronica Biomedica]

#line(length: 100%, stroke: 0.5pt + luma(200))

= Capitolo 1 — Principi di Funzionamento delle Spiking Neural Networks (SNN) e Modelli di Neurone Artificiale

== 1.1 Evoluzione delle Reti Neurali Artificiali: dalla Prima alla Terza Generazione

Secondo la classificazione classica introdotta da Maass (1997), l'evoluzione dei modelli computazionali ispirati al cervello biologico si articola in tre generazioni successive, distinte dalla natura del segnale scambiato tra le unità di calcolo e dal ruolo della variabile temporale:

+ #strong[Prima Generazione (Reti a Soglia Binaria — McCulloch & Pitts, 1943; Percettrone di Rosenblatt, 1958):]
Le unità computazionali calcolano una somma pesata di ingressi ed emettono un'uscita puramente binaria (#mi("y \\in \\{0, 1\\}") o #mi("\\{-1, +1\\}")) mediante una funzione a gradino di Heaviside. Non esiste alcuna dinamica temporale intrinseca né rappresentazione continua del grado di attivazione.
+ #strong[Seconda Generazione (Reti Neurali Artificiali Continue / \*Rate-Based\* — MLP, CNN, RNN, LSTM):]
I neuroni applicano funzioni di attivazione continue e differenziabili (sigmoide, #mi("\\tanh"), ReLU) alla somma pesata degli ingressi:
#mitex("y_i = \\varphi\\left(\\sum_{j} w_{\\text{ij}} x_j + b_i\\right)")
In questo paradigma, il valore scalare reale #mi("y_i \\in \\mathbb{R}") astrae la #strong[frequenza media di scarica (\*firing rate\*)] di un neurone biologico valutata su una finestra temporale prestabilita. Sebbene il calcolo continuo consenta l'addestramento diretto tramite #emph[backpropagation] del gradiente, la sua esecuzione su hardware digitale sincrono impone che ad ogni colpo di clock tutte le unità eseguano moltiplicazioni e accumulazioni in virgola mobile o intera (#emph[Multiply-and-Accumulate], MAC) e accedano continuamente alla memoria, indipendentemente dalla variazione o dalla sparsità del segnale d'ingresso.
+ #strong[Terza Generazione (\*Spiking Neural Networks\* — SNN):]
Le SNN reintroducono la #strong[dinamica biofisica spazio-temporale] dei neuroni reali. I neuroni non scambiano valori numerici continui ad ogni ciclo di clock, bensì comunicano attraverso #strong[eventi impulsivi discreti, asincroni e stereotipati nel tempo], detti #strong[spike] (potenziali d'azione). L'informazione non risiede nell'ampiezza o nella forma del singolo impulso (che è essenzialmente un evento binario puntiforme nel tempo), bensì negli #strong[istanti esatti di occorrenza degli spike] #mi("\\{t_j^{(f)}\\}"):
#mitex("s_j(t) = \\sum_{f} \\delta\\left(t - t_j^{(f)}\\right)")
dove #mi("\\delta(\\cdot)") è la distribuzione delta di Dirac e #mi("t_j^{(f)}") rappresenta l'istante del #mi("f")-esimo spike emesso dal neurone pre-sinaptico #mi("j").

In una SNN (specialmente nelle implementazioni neuromorfiche analogiche e #emph[mixed-signal]), #strong["il tempo rappresenta se stesso"] (#emph[time represents itself], Mead, 1989; Indiveri et al., 2011): ciascun neurone e ciascuna sinapsi è un sistema dinamico governato da equazioni differenziali nel tempo continuo che integra passivamente gli eventi in ingresso e consuma energia dinamica #strong[esclusivamente quando si verifica un evento (elaborazione \*event-driven\*)].

#line(length: 100%, stroke: 0.5pt + luma(200))

== 1.2 Schemi di Codifica dell'Informazione negli Spike (#emph[Neural Coding]) e Conversione Analogico-Evento

Poiché i segnali biologici acquisiti da elettrodi (potenziali d'azione intracorticali, #emph[Local Field Potentials] — LFP, elettrocorticografia — ECoG/iEEG, o elettroencefalografia da scalpo — EEG) sono grandezze analogiche continue nel tempo #mi("V_{\\text{bio}}(t)"), il loro trattamento mediante una SNN richiede la comprensione di come l'informazione venga codificata nei treni di spike:

- #strong[Codifica in Frequenza (\*Rate Coding\*):] L'intensità dello stimolo è codificata dal numero medio di spike #mi("N_{\\text{spike}}") emessi in una finestra di osservazione #mi("T"), ossia dal #emph[firing rate] #mi("\\nu = N_{\\text{spike}} / T"). È robusta al rumore e al jitter sui singoli spike, ma richiede finestre temporali più lunghe e un maggior numero di impulsi.
- #strong[Codifica Temporale (\*Temporal Coding\*):] Sfrutta la struttura fine degli istanti di sparo:
- #strong[Inter-Spike Interval (ISI):] L'informazione è racchiusa nella distanza temporale tra impulsi specifici (ad esempio, come dimostrato in #strong[NET-TEN], Ronchini et al., 2023, l'intervallo tra il primo e il secondo spike #mi("\\text{ISI}_{\\text{I}-\\text{II}}") o tra il primo e il terzo spike #mi("\\text{ISI}_{\\text{I}-\\text{III}}") permette di separare linearmente in pochi millisecondi una crisi epilettica ictale da una scarica interictale o da un artefatto).
- #strong[Time-to-First-Spike (TTFS):] Neuroni più fortemente stimolati raggiungono la soglia per primi; una singola ondata di spike basta per classificare lo stimolo.
- #strong[Codifica per Sincronia e Correlazione di Popolazione (\*Synchrony / Correlation Coding\*):] L'informazione patologica (come l'insorgenza di una crisi epilettica su più canali iEEG) non dipende solo dal #emph[firing rate] del singolo canale, ma dalla #strong[coincidenza temporale (sincronizzazione parziale / stati Chimera)] degli spike tra popolazioni diverse, come sfruttato nel layer #emph[Non-Local Non-Global] (NLNG) di #strong[Bartels et al. (2025)].

=== Tecniche Circuitali di Conversione Analogico-Spike (#emph[Spike Encoding])
Nei sistemi biomedicali neuromorfici analizzati in questa relazione, la conversione diretta del segnale biologico #mi("S(t)") in due flussi di eventi asincroni (#strong[UP] per pendenze positive e #strong[DOWN / DN] per pendenze negative) avviene tramite convertitori #emph[level-crossing] a modulazione delta asincrona:

+ #strong[Asynchronous Delta Modulator (ADM) / Step-Forward Encoding (SFE)] #emph[(usato in Paper 3 — NET-TEN e Paper 6 — DYNAP-SE2)]:
Definito un livello di riferimento dinamico #mi("V_{\\text{base}}(t)") e una finestra di soglia simmetrica #mi("\\pm \\Delta") (es. #mi("\\Delta = 2.7\\,\\mu\\text{V}") riferita all'ingresso in NET-TEN), il modulatore confronta continuamente il segnale #mi("S(t)") con i due limiti:
#mitex("\\begin{cases}
   \\text{Se } S(t) > V_{\\text{base}}(t) + \\Delta \\implies \\text{emetti evento } \\mathbf{UP} = 1, \\quad V_{\\text{base}}(t^+) \\leftarrow V_{\\text{base}}(t) + \\Delta \\\\
   \\text{Se } S(t) < V_{\\text{base}}(t) - \\Delta \\implies \\text{emetti evento } \\mathbf{DN} = 1, \\quad V_{\\text{base}}(t^+) \\leftarrow V_{\\text{base}}(t) - \\Delta
   \\end{cases}")
+ #strong[Codificatore Sigma-Delta (#mi("\\Sigma\\Delta"))] #emph[(usato in Paper 4 — SynSense Xylo)]:
Suddivide l'escursione dinamica del segnale EEG in intervalli di ampiezza equidistanti ed emette impulsi UP o DOWN ad ogni attraversamento di livello.
+ #strong[Analog-to-Spike Converter (ASC) con \*Signal Folding\* Capacitivo e Periodo Refrattario Bio-Ispirato] #emph[(usato in Paper 7 — NeuroSEED)]:
Utilizza un DAC a capacità commutate a 1 bit (#mi("C_1, C_2")) e due comparatori asincroni con soglie #mi("V_H") e #mi("V_L") intorno alla tensione di centro-scala #mi("V_M"): ogni volta che il segnale supera #mi("V_H") o scende sotto #mi("V_L"), il circuito emette uno spike #raw("UP") o #raw("DN"), attiva un circuito refrattario che spegne in #emph[power-gating] i comparatori per un tempo morto #mi("T_{\\text{refr}}") e #strong[riporta ("ripiega", \*folds\*) la tensione di ingresso a #mi("V_M")] mediante ridistribuzione di carica. La frequenza istantanea di campionamento si adatta automaticamente alla derivata temporale #mi("\\left|\\frac{dV}{dt}\\right|") del segnale biologico, rispettando il vincolo di ritardo di loop:
#mitex("T_{\\min} = \\frac{V_{\\text{LSB}}}{\\left.\\frac{dV(t)}{dt}\\right|_{\\max}} = \\frac{1}{2^M \\pi f_{\\text{IN}}}")

#line(length: 100%, stroke: 0.5pt + luma(200))

== 1.3 Tassonomia Matematica dei Modelli di Neurone Spiking

La progettazione di un neurone artificiale in tecnologia CMOS richiede un compromesso fondamentale tra #strong[fedeltà biofisica] (capacità di riprodurre le dinamiche non lineari dei neuroni corticali: #emph[regular spiking], #emph[fast spiking], #emph[bursting], #emph[chattering], adattamento di frequenza, risonanza) e #strong[compattezza circuitale] (numero di transistor, numero di condensatori di stato e potenza dissipata).

\`\`\`mermaid
flowchart TD
A\["Modelli di Neurone Spiking"\] --\> B\["Modelli Biofisici basati su Conduttanza"\]
A --\> C\["Modelli Fenomenologici Integrate-and-Fire (I&F)"\]
B --\> B1\["Hodgkin-Huxley (H-H, 1952)\<br/\>4 variabili di stato (V, m, h, n)\<br/\>Altissimo realismo biofisico, elevata area CMOS"\]
B --\> B2\["Modelli Multi-Compartimentali / Talamici\<br/\>Equazioni di cavo dendritico + correnti Ca2+ (I\_T)"\]
C --\> C1\["Leaky Integrate-and-Fire (LIF)\<br/\>1 variabile di stato (V\_mem), lineare sottosoglia\<br/\>Ultra-compatto, basso consumo, niente bursting intrinseco"\]
C --\> C2\["Quadratic I&F / Izhikevich (2003)\<br/\>2 variabili di stato (V\_mem, U), non-linearità quadratica V^2\<br/\>12-14 transistor CMOS, tutti i pattern corticali"\]
C --\> C3\["Adaptive Exponential I&F (AdEx, Brette & Gerstner 2005)\<br/\>2 variabili di stato (V\_mem / I\_mem, w / I\_g), feedback esponenziale\<br/\>Ideale per MOSFET in sottosoglia (Neurone DPI in ROLLS e DYNAP-SE)"\]
C --\> C4\["Mihalas-Niebur (2009)\<br/\>Equazioni lineari accoppiate con Soglia Adattativa Theta(t)\<br/\>Ideale per circuiti Switched-Capacitor"\]
\`\`\`

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 1.3.1 Il Modello Biofisico di Hodgkin–Huxley (H–H)

Formulato da Hodgkin e Huxley (1952) sulla base delle misure sull'assone gigante di calamaro, modella la membrana cellulare come una capacità #mi("C_m") in parallelo a tre canali ionici principali: un canale passivo di perdita (#emph[leak]) con conduttanza costante #mi("g_L") e potenziale di inversione #mi("E_L"), un canale del Sodio (#mi("\\text{Na}^+")) voltaggio-dipendente e un canale del Potassio (#mi("\\text{K}^+")) voltaggio-dipendente. Il sistema è retto da #strong[quattro equazioni differenziali non lineari accoppiate]:

#mitex("C_m \\frac{dV_m}{dt} = I_{\\text{ext}}(t) - \\underbrace{\\bar{g}_{\\text{Na}} m^3 h (V_m - E_{\\text{Na}})}_{I_{\\text{Na}}} - \\underbrace{\\bar{g}_{\\text{K}} n^4 (V_m - E_{\\text{K}})}_{I_{\\text{K}}} - \\underbrace{g_L (V_m - E_L)}_{I_L}")

dove #mi("m, h, n \\in [0, 1]") sono le variabili di #emph[gating] (probabilità di attivazione del #mi("\\text{Na}^+"), inattivazione del #mi("\\text{Na}^+") e attivazione del #mi("\\text{K}^+")), ciascuna governata da una cinetica del primo ordine dipendente dalla tensione:

#mitex("\\frac{dx}{dt} = \\alpha_x(V_m)(1 - x) - \\beta_x(V_m)x = \\frac{x_\\infty(V_m) - x}{\\tau_x(V_m)}, \\qquad x \\in \\{m, h, n\\}")

con valore di stato stazionario sigmoidale #mi("x_\\infty(V_m) = \\frac{\\alpha_x(V_m)}{\\alpha_x(V_m) + \\beta_x(V_m)}") e costante di tempo a campana #mi("\\tau_x(V_m) = \\frac{1}{\\alpha_x(V_m) + \\beta_x(V_m)}").
Sebbene il modello H–H riproduca esattamente la forma d'onda fisica del potenziale d'azione, la sua implementazione in silicio (es. Yu & Cauwenberghs, 2010a; Saighi et al., 2011) richiede circuiti dedicati per ciascuna variabile di gating, calcolatori di funzioni sigmoidali e moltiplicatori translineari per i termini #mi("m^3 h") e #mi("n^4"), occupando un'area molto elevata e risultando adatta solo a piccole reti bio-ibride (pochi neuroni) e non a grandi matrici impiantabili.

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 1.3.2 Il Modello #emph[Leaky Integrate-and-Fire] (LIF): Derivazione Fisica, Soluzione Analitica e Curva #mi("f\\text{-}I")

Il modello #strong[Leaky Integrate-and-Fire (LIF)] (introdotto originariamente da Lapicque nel 1907) rappresenta il riferimento cardine dell'ingegneria neuromorfica poiché cattura i tre processi essenziali dell'eccitabilità neuronale — #strong[integrazione sinaptica, perdita passiva di carica (\*leakage\*) e generazione di eventi a soglia con reset] — utilizzando #strong[una sola variabile di stato] (#mi("V_{\\text{mem}}")).

==== A. Circuito Elettrico Equivalente ed Equazione Differenziale di Membrana
Dal punto di vista biofisico ed circuitale (si veda la #strong[Figura 17], pannelli Fig. 1 e Fig. 2 estratti da #emph[Li et al., 2024]), la membrana cellulare in regime sottosoglia è modellata da un circuito #strong[RC parallelo] composto da:
- #strong[Capacità di membrana #mi("C_m") (o #mi("C_{\\text{mem}}")):] rappresenta il doppio strato fosfolipidico impermeabile agli ioni, che accumula carica elettrica #mi("Q = C_m V_{\\text{mem}}").
- #strong[Resistenza di membrana #mi("R_m = 1/g_L") in serie alla batteria #mi("E_L"):] rappresenta i canali ionici passivi (#emph[leak channels]) sempre aperti, che tendono a riportare esponenzialmente il potenziale di membrana verso il potenziale di riposo #mi("E_L") (spesso posto convenzionalmente a #mi("0\\,\\text{V}") o massa nei modelli semplificati).
- #strong[Generatore di corrente d'ingresso #mi("I(t) = I_{\\text{syn}}(t) + I_{\\text{inj}}(t)"):] rappresenta la somma delle correnti post-sinaptiche eccitatorie (EPSC) e inibitorie (IPSC) che attraversano i recettori di membrana.

Applicando la #strong[Legge di Kirchhoff delle Correnti (KCL)] al nodo del potenziale di membrana #mi("V_{\\text{mem}}(t)"), la corrente totale iniettata si ripartisce tra la corrente capacitiva #mi("I_C = C_m \\frac{dV_{\\text{mem}}}{dt}") e la corrente resistiva di perdita #mi("I_{\\text{leak}} = \\frac{V_{\\text{mem}}(t) - E_L}{R_m}"):

#mitex("C_m \\frac{dV_{\\text{mem}}(t)}{dt} = -g_L \\left(V_{\\text{mem}}(t) - E_L\\right) + I(t)")

Moltiplicando ambo i membri per #mi("R_m = 1/g_L") e definendo la #strong[costante di tempo di membrana] #mi("\\tau_m \\triangleq R_m C_m = \\frac{C_m}{g_L}"), si ottiene la forma canonica del modello LIF:

#mitex("\\tau_m \\frac{dV_{\\text{mem}}(t)}{dt} = -\\left(V_{\\text{mem}}(t) - E_L\\right) + R_m I(t)")

#emph[(Ponendo il riferimento di riposo #mi("E_L = 0"), l'equazione assume la forma compatta #mi("R C \\frac{dV_{\\text{mem}}(t)}{dt} = -V_{\\text{mem}}(t) + R I(t)") riportata in Li et al., 2024).]

==== B. Meccanismo di Soglia, Reset e Periodo Refrattario Assoluto
Poiché l'equazione RC è puramente lineare e passiva, non possiede i termini non lineari di attivazione del #mi("\\text{Na}^+") e del #mi("\\text{K}^+") necessari per generare autonomamente il picco dello spike. Nel modello LIF, la forma d'onda stereotipata del potenziale d'azione non viene risolta analiticamente ma è sostituita da una #strong[condizione al contorno algoritmica/circuitale (comparatore di soglia + switch di reset)]:

+ #strong[Condizione di Firing (Emissione dello Spike):] Quando #mi("V_{\\text{mem}}(t)") raggiunge dall'inferiore la tensione di soglia #mi("V_{\\text{th}}") all'istante #mi("t = t^{(f)}"):
#mitex("V_{\\text{mem}}\\left(t^{(f)-}\\right) = V_{\\text{th}} \\implies \\text{emissione di uno spike } \\delta\\left(t - t^{(f)}\\right)")
+ #strong[Reset Post-Spike:] Istantaneamente dopo l'emissione dello spike, il potenziale di membrana viene forzato al potenziale di reset #mi("V_{\\text{reset}} < V_{\\text{th}}"):
#mitex("V_{\\text{mem}}\\left(t^{(f)+}\\right) = V_{\\text{reset}}")
+ #strong[Periodo Refrattario Assoluto (#mi("\\tau_{\\text{ref}}")):] Per un intervallo temporale #mi("t \\in \\left(t^{(f)},\\, t^{(f)} + \\tau_{\\text{ref}}\\right]"), il potenziale è mantenuto bloccato (#emph[clamped]) a #mi("V_{\\text{reset}}") (l'interruttore di reset in parallelo a #mi("C_m") rimane chiuso) e l'integrazione riprende solo per #mi("t > t^{(f)} + \\tau_{\\text{ref}}").

==== C. Soluzione Analitica, Corrente Reobase e Curva di Trasferimento #mi("f\\text{-}I")
Consideriamo un neurone LIF stimolato da una corrente costante #mi("I(t) = I_0") a partire da #mi("V_{\\text{mem}}(0) = V_{\\text{reset}}"). La soluzione dell'equazione differenziale lineare del primo ordine per #mi("t > 0") è:

#mitex("V_{\\text{mem}}(t) = E_L + R_m I_0 + \\left(V_{\\text{reset}} - E_L - R_m I_0\\right) e^{-t/\\tau_m}")

Per #mi("t \\to \\infty"), in assenza di soglia il potenziale tenderebbe asintoticamente al valore di regime #mi("V_\\infty = E_L + R_m I_0"). Di conseguenza, il neurone può raggiungere la soglia #mi("V_{\\text{th}}") in un tempo finito #strong[se e solo se] #mi("V_\\infty > V_{\\text{th}}"), il che definisce la #strong[corrente di soglia minima (corrente reobase, \*rheobase current\*)]:

#mitex("I_{\\text{rh}} = \\frac{V_{\\text{th}} - E_L}{R_m} = g_L (V_{\\text{th}} - E_L)")

- Se #mi("I_0 \\le I_{\\text{rh}}"): il neurone non emette alcuno spike (#mi("f = 0")); la corrente di perdita #mi("I_{\\text{leak}}") bilancia completamente la corrente iniettata prima che venga toccata la soglia.
- Se #mi("I_0 > I_{\\text{rh}}"): imponendo #mi("V_{\\text{mem}}(T_{\\text{int}}) = V_{\\text{th}}"), si ricava il tempo di carica (integrazione) #mi("T_{\\text{int}}"):
#mitex("V_{\\text{th}} = E_L + R_m I_0 - \\left(E_L + R_m I_0 - V_{\\text{reset}}\\right) e^{-T_{\\text{int}}/\\tau_m} \\implies T_{\\text{int}} = \\tau_m \\ln\\left(\\frac{R_m I_0 + E_L - V_{\\text{reset}}}{R_m I_0 + E_L - V_{\\text{th}}}\\right)")
Sommando il periodo refrattario assoluto #mi("\\tau_{\\text{ref}}"), l'intervallo inter-spike totale vale #mi("\\text{ISI} = \\tau_{\\text{ref}} + T_{\\text{int}}"), da cui si ottiene la celebre #strong[curva di trasferimento frequenza-corrente (#mi("f\\text{-}I")) del neurone LIF]:

#mitex("f(I_0) = \\frac{1}{\\text{ISI}} = \\begin{cases} 0 & \\text{se } I_0 \\le I_{\\text{rh}} \\\\ \\left[ \\tau_{\\text{ref}} + \\tau_m \\ln\\left( \\dfrac{R_m I_0 - (V_{\\text{reset}} - E_L)}{R_m I_0 - (V_{\\text{th}} - E_L)} \\right) \\right]^{\\text{-1}} & \\text{se } I_0 > I_{\\text{rh}} \\end{cases}")

Per correnti molto grandi (#mi("I_0 \\gg I_{\\text{rh}}")), sviluppando il logaritmo al primo ordine (#mi("\\ln(1+x) \\approx x")), il tempo di integrazione scala come #mi("T_{\\text{int}} \\approx \\frac{C_m(V_{\\text{th}} - V_{\\text{reset}})}{I_0}") (comportamento da integratore puro), e la frequenza di scarica satura asintoticamente alla #strong[frequenza massima di firing] #mi("f_{\\max} = \\frac{1}{\\tau_{\\text{ref}}}").

==== D. Filtraggio Sinaptico Esponenziale e Discretizzazione Digitale
Nel modello LIF completo (ad es. implementato nel processore #strong[SynSense Xylo] in #emph[Li et al., 2024]), gli spike pre-sinaptici non iniettano impulsi di Dirac direttamente nella membrana, ma vengono prima filtrati da #strong[sinapsi esponenziali] con costante di tempo sinaptica #mi("\\tau_{\\text{syn},j}") e peso #mi("w_{\\text{ij}}"):

#mitex("\\tau_{\\text{syn},j} \\frac{dI_{\\text{syn},j}(t)}{dt} = -I_{\\text{syn},j}(t) + \\sum_{f} w_{\\text{ij}} \\delta\\left(t - t_j^{(f)}\\right), \\qquad I_{\\text{app},i}(t) = \\sum_{j} I_{\\text{syn},j}(t)")

Nelle implementazioni CMOS #strong[completamente digitali] a tempo discreto con passo #mi("\\Delta t") (come Xylo), l'integrazione di Eulero delle equazioni sinaptica e di membrana diventa:

#mitex("I_{\\text{syn}}[n+1] = \\alpha_{\\text{syn}} I_{\\text{syn}}[n] + \\sum_{j} w_j s_j[n], \\qquad V_{\\text{mem}}[n+1] = \\beta_{\\text{mem}} V_{\\text{mem}}[n] + I_{\\text{syn}}[n]")

dove i fattori di decadimento esponenziale #mi("\\alpha_{\\text{syn}} = e^{-\\Delta t / \\tau_{\\text{syn}}}") e #mi("\\beta_{\\text{mem}} = e^{-\\Delta t / \\tau_m}") possono essere realizzati senza moltiplicatori hardware tramite semplici operazioni di #strong[bit-shift e sottrazione] (#emph[bit-shift decay]: #mi("x \\leftarrow x - (x \\gg k)"), cui corrisponde #mi("\\beta = 1 - 2^{\\text{-k}}")).

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 1.3.3 Il Modello #emph[Quadratic Integrate-and-Fire] (QIF) e il Modello Bidimensionale di Izhikevich

Il modello LIF standard presenta due limitazioni biofisiche: (1) l'avvicinamento alla soglia è concavo verso il basso (mentre nei neuroni reali l'attivazione dei canali #mi("\\text{Na}^+") produce un'accelerazione rigenerativa convessa prima dello spike); (2) avendo una sola variabile di stato che viene resettata ad ogni spike, non conserva memoria degli spike precedenti e quindi non può esibire #emph[spike-frequency adaptation] né #emph[bursting] intrinseco.

Il modello di #strong[Izhikevich (2003)] risolve entrambi i problemi mediante la riduzione per teoria delle biforcazioni dei modelli di tipo Hodgkin–Huxley a un sistema bidimensionale con non-linearità quadratica (implementato direttamente in silicio in #emph[Wijekoon & Dudek, 2008] — #raw("paperSNN1") Fig. 16, e nel chip #strong[NET-TEN] di #emph[Ronchini et al., 2023] — #raw("paperSNN3") Fig. 3b):

#mitex("\\begin{cases}
\\dfrac{dV_{\\text{mem}}}{dt} = 0.04 V_{\\text{mem}}^2 + 5 V_{\\text{mem}} + 140 - U + I_{\\text{syn}} \\\\
\\dfrac{dU}{dt} = a\\left(b V_{\\text{mem}} - U\\right)
\\end{cases}")

con condizione ausiliaria di reset post-spike:
#mitex("\\text{se } V_{\\text{mem}} \\ge 30\\,\\text{mV}: \\quad \\begin{cases} V_{\\text{mem}} \\leftarrow c \\\\ U \\leftarrow U + d \\end{cases}")

- #strong[#mi("V_{\\text{mem}}")] rappresenta il potenziale transmembrana e il termine #mi("+0.04 V_{\\text{mem}}^2") genera il feedback positivo rigenerativo che porta #mi("V_{\\text{mem}}") all'apice dello spike senza bisogno di una soglia artificiale fissa di innesco.
- #strong[#mi("U")] è la variabile lenta di recupero della membrana (#emph[membrane recovery variable]), che rende conto dell'attivazione delle correnti ioniche #mi("\\text{K}^+") e dell'inattivazione delle correnti #mi("\\text{Na}^+"), fornendo un feedback negativo su #mi("V_{\\text{mem}}").
- I quattro parametri adimensionali #mi("(a, b, c, d)") controllano rispettivamente: la scala temporale del recupero #mi("U") (#mi("a")), la sensibilità sottosoglia di #mi("U") alle fluttuazioni di #mi("V_{\\text{mem}}") (#mi("b")), il valore di reset post-spike della tensione (#mi("c")) e il salto incrementale post-spike della variabile di recupero (#mi("d")). Variando le tensioni di polarizzazione corrispondenti a #mi("c") e #mi("d") su silicio, lo stesso circuito di 12–14 transistor riproduce #emph[Regular Spiking (RS)], #emph[Intrinsically Bursting (IB)], #emph[Chattering (CH)] e #emph[Fast Spiking (FS)].

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 1.3.4 Il Modello #emph[Adaptive Exponential Integrate-and-Fire] (AdEx)

Proposto da #strong[Brette & Gerstner (2005)], sostituisce il termine quadratico di Izhikevich con un termine #strong[esponenziale] (derivato direttamente dalla fisica dell'attivazione dei canali del Sodio di Hodgkin–Huxley vicino alla soglia di innesco):

#mitex("\\begin{cases}
C \\dfrac{dV}{dt} = -g_L (V - E_L) + g_L \\Delta_T \\exp\\left(\\dfrac{V - V_T}{\\Delta_T}\\right) - w + I \\\\
\\tau_w \\dfrac{dw}{dt} = a(V - E_L) - w
\\end{cases}")

con regola di reset per #mi("V \\ge V_{\\text{peak}}"):
#mitex("V \\leftarrow V_r, \\qquad w \\leftarrow w + b")
dove #mi("V_T") è la tensione di soglia effettiva di innesco del run-away esponenziale, #mi("\\Delta_T") è il fattore di pendenza dello spike (#emph[slope factor]) e #mi("w") è la corrente di adattamento (#emph[adaptation current]).

#block(fill: rgb("#f0f4f8"), inset: 10pt, radius: 4pt, stroke: (left: 3pt + rgb("#2b6cb0")), width: 100%)[
  #strong[IMPORTANT:] #strong[Perché il modello AdEx è il "Gold Standard" per i circuiti CMOS analogici in sottosoglia?]
  Poiché un transistor MOSFET polarizzato in inversione debole (#emph[sub-threshold]) possiede una caratteristica fisica corrente-tensione #strong[intrinsecamente esponenziale] (#mi("I_D = I_0 e^{\\kappa V_G / U_T}")), il termine esponenziale #mi("\\exp\\left(\\frac{V - V_T}{\\Delta_T}\\right)") del modello AdEx non deve essere approssimato: #strong[è generato gratis dalla fisica del singolo transistor CMOS!] Come dimostrato da Livi & Indiveri (2009) e Indiveri et al. (2011) (Equazione 2, p. 13), traducendo il modello AdEx nel dominio delle correnti sottosoglia tramite due filtri #strong[DPI (Differential Pair Integrator)] si ottiene il #strong[Neurone DPI], che costituisce il cuore computazionale dei processori #strong[ROLLS] (#raw("paperSNN2")), #strong[DYNAP-SE] (#raw("paperSNN5")) e #strong[DYNAP-SE2] (#raw("paperSNN6")):
  #mitex("\\begin{cases}
> \\tau \\dfrac{d}{dt} I_{\\text{mem}} = -I_{\\text{mem}} \\left(1 + \\dfrac{I_g}{I_\\tau}\\right) + I_{\\text{mem}\\infty} + f(I_{\\text{mem}}) \\\\
> \\tau_g \\dfrac{d}{dt} I_g = -I_g + I_{g\\max} r(t)
> \\end{cases}")
]

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 1.3.5 Il Modello a Soglia Adattativa di Mihalas–Niebur

Introdotto da #strong[Mihalas & Niebur (2009)] e implementato in tecnologia #emph[Switched-Capacitor] da Folowosele et al. (2009a,b) (#raw("paperSNN1"), Fig. 18–19), evita qualsiasi non-linearità nell'equazione di membrana accoppiando linearmente il potenziale #mi("V_m(t)") a una #strong[tensione di soglia dinamica adattativa #mi("\\Theta(t)")]:

#mitex("\\begin{cases}
\\dfrac{dV_m(t)}{dt} = -\\dfrac{1}{\\tau_m}\\left(V_m(t) - E_L\\right) + \\dfrac{I_{\\text{in}}(t)}{C_m} + \\sum_j I_j(t) \\\\
\\dfrac{d\\Theta(t)}{dt} = a\\left(V_m(t) - E_L\\right) - b\\left(\\Theta(t) - \\Theta_\\infty\\right)
\\end{cases}")

Quando #mi("V_m(t) = \\Theta(t)"), viene emesso uno spike e le variabili vengono aggiornate secondo #mi("V_m \\leftarrow E_L") e #mi("\\Theta \\leftarrow \\max(\\Theta_r, \\Theta)"). Essendo tutte le equazioni differenziali strettamente lineari, l'intero modello può essere realizzato mediante condensatori e interruttori MOSFET pilotati da fasi di clock non sovrapposte (#mi("\\phi_1, \\phi_2")), garantendo un'altissima immunità alle variazioni di processo.

#line(length: 100%, stroke: 0.5pt + luma(200))

== 1.4 Dinamiche Sinaptiche e Paradigmi di Plasticità e Apprendimento

Nelle SNN analizzate nei 7 articoli, la configurazione dei pesi sinaptici e la dinamica delle sinapsi seguono cinque paradigmi complementari:

+ #strong[Plasticità Dipendente dal Tempo di Spike (STDP — \*Spike-Timing-Dependent Plasticity\*):]
Utilizzata in hardware in #strong[NET-TEN] (#raw("paperSNN3")), aggiorna il peso sinaptico in base alla differenza temporale #mi("\\Delta t = t_{\\text{post}} - t_{\\text{pre}}") tra lo spike post-sinaptico e quello pre-sinaptico:
#mitex("\\Delta W(\\Delta t) = \\begin{cases} +A_+ \\exp(-\\Delta t / \\tau_+) & \\text{se } \\Delta t \\ge 0 \\quad (\\text{LTP: causalità pre}\\to\\text{post}) \\\\ -A_- \\exp(+\\Delta t / \\tau_-) & \\text{se } \\Delta t < 0 \\quad (\\text{LTD: anti-causalità post}\\to\\text{pre}) \\end{cases}")
+ #strong[Plasticità Bistabile Guidata dagli Spike e dal Calcio Post-Sinaptico (SDSP — Brader, Senn & Fusi, 2007):]
Implementata nelle #mi("64\\text{K}") sinapsi di apprendimento on-line del chip #strong[ROLLS] (#raw("paperSNN2")). Risolve il problema del decadimento rapido della carica sui piccoli condensatori CMOS combinando salti analogici istantanei (#mi("\\pm \\Delta w")) all'arrivo dello spike pre-sinaptico (condizionati dal potenziale di membrana #mi("V_{\\text{mem}}(t_{\\text{pre}})") e dalla concentrazione post-sinaptica di ioni Calcio #mi("Ca(t_{\\text{pre}})") che agisce da meccanismo di #emph[stop-learning]) con un #strong[drift bistabile lento] che attira il peso verso due stati asintotici stabili (#mi("w_{\\min}") o #mi("w_{\\max}")), garantendo la ritenzione a lungo termine della memoria senza memoria digitale esterna.
+ #strong[Plasticità a Breve Termine (STP / STD — \*Short-Term Depression\*):]
Implementata nelle #mi("64\\text{K}") sinapsi programmabili di #strong[ROLLS] (#raw("paperSNN2")), riduce transitoriamente l'ampiezza dell'EPSC durante treni di spike ad alta frequenza, fungendo da controllo automatico di guadagno dinamico.
+ #strong[Addestramento Supervisionato Off-Chip tramite \*Backpropagation Through Time\* (BPTT) con \*Surrogate Gradient\* e Regolarizzazione di Sparsità:]
Utilizzato in #strong[Li et al. (2024)] (#raw("paperSNN4"), processore Xylo). Poiché la funzione di generazione dello spike #mi("\\Theta(V_{\\text{mem}} - V_{\\text{th}})") ha derivata nulla ovunque tranne una delta di Dirac in #mi("V_{\\text{th}}"), durante il backward pass la derivata discontinua viene sostituita da una derivata surrogata liscia (#emph[surrogate gradient]), aggiungendo alla #emph[Cross-Entropy Loss] una penalità quadratica sul numero di spike in eccesso per minimizzare il consumo energetico su silicio.
+ #strong[Ricerca Architetturale Evolutiva Hardware-Aware (ENAS — \*Evolutionary Neural Architecture Search\*):]
Utilizzata in #strong[Bartels et al. (2025)] (#raw("paperSNN6"), processore DYNAP-SE2) per trovare la matrice di connettività spaziale ottima (#raw("1-2-1-0-1-2-1")) capace di estrarre la sincronizzazione parziale dei segnali iEEG nonostante il #emph[device mismatch] del #mi("20\\text{-}30\\%") dei circuiti analogici in sottosoglia.

#line(length: 100%, stroke: 0.5pt + luma(200))

= Capitolo 2 — Perché Utilizzare una SNN in un Dispositivo Biomedicale Impiantabile?

== 2.1 Vincoli Fisici, Termici ed Energetici dei Sistemi Impiantabili Intracranici e Indossabili

Un dispositivo biomedicale impiantabile (come un'interfaccia neurale intracorticale iBMI o un neurostimolatore #emph[closed-loop] per l'epilessia farmacoresistente) opera in uno degli ambienti più severi dell'ingegneria elettronica ed è soggetto a quattro vincoli stringenti:

+ #strong[Vincolo Termico e Bio-Compatibilità Tissutale:]
Il tessuto cerebrale non tollera un innalzamento cronico della temperatura locale superiore a #strong[#mi("\\Delta T_{\\max} \\approx 1\\,^\\circ\\text{C}")] (standard IEEE/ISO per dispositivi medici impiantabili attivi), cui corrisponde una densità massima di potenza dissipata di circa #strong[#mi("10\\text{-}40\\,\\text{mW/cm}^2")]. Come evidenziato in #strong[Ronchini et al. (2023)] (#raw("paperSNN3")), un singolo neurone biologico consuma tra #strong[#mi("0.5\\,\\text{nW}") e #mi("4.0\\,\\text{nW}")] a riposo/in attività: progettare una rete neuromorfica al silicio come #strong[NET-TEN] che dissipa in media #strong[#mi("3.50\\,\\text{nW}")] sull'intero task di rilevazione significa operare esattamente alla scala metabolica del tessuto ospite, azzerando il rischio di necrosi termica.
+ #strong[Budget Energetico Ultra-Ridotto (Batteria o \*Wireless Power Transfer\*):]
Per evitare frequenti interventi chirurgici di sostituzione della batteria o per consentire l'alimentazione wireless induttiva/ultrasonica con antenne millimetriche, l'intero System-on-Chip (acquisizione + elaborazione + telemetria) deve consumare da #strong[pochi nanowatt a poche decine/centinaia di microwatt] (#emph[sub-milliwatt regime]).
+ #strong[Bassa Latenza ed Elaborazione in Tempo Reale (\*Closed-Loop Stimulation\*):]
Nel trattamento dell'epilessia farmacoresistente (\~30% dei pazienti epilettici), la stimolazione cerebrale profonda (#emph[Deep Brain Stimulation], #strong[DBS]) ad anello chiuso (#emph[closed-loop]) eroga l'impulso elettrico terapeutico solo al rilevamento di biomarker elettrografici precoci (crisi ictali in LFP o iEEG). Affinché la stimolazione riesca a desincronizzare la rete biologica e abortire la crisi prima della sua generalizzazione clinica, il ritardo di rilevazione deve essere nell'ordine delle #strong[decine o centinaia di millisecondi] (#mi("56.7\\,\\text{ms}") mediana in NET-TEN; #mi("0.5\\,\\text{s}") in Xylo).
+ #strong[Area di Silicio Millimetrica:]
L'ingombro fisico dell'impianto intracranico deve essere ridotto al minimo per limitare il danno meccanico e la risposta infiammatoria gliale (es. #strong[#mi("0.70\\,\\text{mm}^2")] totali per 32 canali in #strong[NeuroSEED], #strong[#mi("1.08\\,\\text{mm}^2")] per #strong[NET-TEN]).

#line(length: 100%, stroke: 0.5pt + luma(200))

== 2.2 Limiti dell'Elaborazione Digitale Convenzionale (Campionamento di Nyquist + Architettura von Neumann)

Nei sistemi biomedicali convenzionali (Figura 21a da #emph[Bartels et al., 2025] e Figura 25 da #emph[Wu et al., 2026]), la catena di acquisizione ed elaborazione soffre di tre inefficienze strutturali:

+ #strong[Campionamento Continuo a Frequenza Fissa (Criterio di Nyquist-Shannon):]
Un ADC tradizionale campiona ininterrottamente tutti gli #mi("N") canali alla frequenza #mi("f_s \\ge 2 f_{\\max}") (es. #mi("10.4\\text{-}30\\,\\text{kHz/canale}") per gli spike intracorticali, producendo #strong[#mi("3.3\\,\\text{Mbps}")] per 32 canali a 10 bit). Tuttavia, i segnali biologici sono #strong[intrinsecamente sparsi nel tempo]: un neurone corticale spara a pochi Hz (spike della durata di #mi("\\sim 1\\,\\text{ms}") seguiti da centinaia di millisecondi di silenzio o rumore di fondo), e le crisi epilettiche occupano meno dell'#mi("1\\%") della vita del paziente. Campionare, quantizzare e processare a pieno regime il #mi("99\\%") di periodi silenti spreca la quasi totalità dell'energia.
+ #strong[Collo di Bottiglia di von Neumann e Buffer di Memoria:]
Gli algoritmi classici di estrazione di feature (Trasformata Rapida di Fourier FFT, Trasformata Wavelet Discreta DWT, calcolo di matrici di covarianza, filtri digitali FIR/IIR, CNN/LSTM) richiedono di accumulare finestre temporali di segnale in #strong[memorie SRAM/DRAM] e di spostare continuamente dati tra memoria e unità aritmetica (ALU/MAC) ad ogni ciclo di clock (ad es. le implementazioni FPGA/ASIC basate su DWT+SVM o CNN+LSTM in Tabella 1 di #raw("paperSNN4") consumano fino a #strong[#mi("159\\text{-}284\\,\\text{mW}")], ovvero tre ordini di grandezza in più rispetto a una SNN!).
+ #strong[Saturazione Energetica della Telemetria Wireless Raw:]
Trasmettere all'esterno della scatola cranica il flusso grezzo digitalizzato di decine o centinaia di canali neurali (diversi Mbps) richiede trasmettitori RF sempre attivi che dissipano decine di milliwatt, violando i limiti di #emph[Specific Absorption Rate] (SAR) e di potenza dell'impianto.

#line(length: 100%, stroke: 0.5pt + luma(200))

== 2.3 I Vantaggi Fondamentali del Paradigma Neuromorfico Spiking (#emph[Event-Driven])

L'impiego di una SNN (accoppiata a un front-end #emph[event-driven]) risponde direttamente alla prima domanda della consegna offrendo quattro vantaggi decisivi:

\`\`\`mermaid
flowchart LR
subgraph Conv\["Paradigma Convenzionale (Time-Driven / Nyquist)"\]
direction LR
E1\["Elettrodi\<br/\>(LFP / iEEG / AP)"\] --\> A1\["AFE + ADC Nyquist\<br/\>Campionamento continuo fisso\<br/\>(es. 3.3 Mbps per 32 ch)"\]
A1 --\> M1\["Buffer SRAM & DSP/CNN\<br/\>Clock globale sempre attivo\<br/\>Operazioni MAC continue"\]
M1 --\> T1\["TX Wireless Continuo\<br/\>Alto data-rate (Mbps)\<br/\>Potenza: mW - centinaia di mW"\]
end
subgraph Neuro\["Paradigma Neuromorfico SNN (Event-Driven / In-Situ)"\]
direction LR
E2\["Elettrodi\<br/\>(LFP / iEEG / AP)"\] --\> A2\["AFE + Codifica ADM / ASC\<br/\>Eventi solo su variazione Delta\<br/\>Compressione \> 100x"\]
A2 --\> M2\["Rete SNN (LIF / AdEx / Izhikevich)\<br/\>Co-localizzazione Memoria-Calcolo\<br/\>Costanti di tempo fisiche RC/DPI"\]
M2 --\> T2\["Rilevazione Locale / TX IR-UWB\<br/\>Send-on-Event (\> 500x compr.)\<br/\>Potenza: 3.5 nW - 375 uW"\]
end
\`\`\`

+ #strong[Consumo Energetico Proporzionale all'Attività Biologica (\*Activity-Driven Power\*):]
Poiché i circuiti analogici in sottosoglia e la logica digitale asincrona #emph[clockless] si attivano solo in presenza di spike, durante i lunghi periodi fisiologici di baseline (interictali) il consumo crolla a livelli trascurabili (es. #strong[#mi("1.77\\,\\mu\\text{W}")] su 56 canali in fase pre-ictale su DYNAP-SE2, o #strong[#mi("0.68\\,\\text{pW}") statici / #mi("3.50\\,\\text{nW}") medi] su NET-TEN).
+ #strong[Corrispondenza delle Costanti di Tempo (\*Real-Time Matching\* senza Clock né Buffer):]
I neuroni CMOS in sottosoglia (come il neurone DPI) hanno costanti di tempo fisiche #mi("\\tau = \\frac{C U_T}{\\kappa I_\\tau}") dell'ordine di #strong[#mi("1\\text{-}500\\,\\text{ms}")], che coincidono esattamente con le scale temporali dei segnali biologici (EEG, LFP, potenziali d'azione). La rete elabora quindi la storia temporale del segnale direttamente attraverso la carica fisica sui propri condensatori di membrana e sinaptici, #strong[senza bisogno di buffer di memoria per memorizzare finestre passate né di clock di campionamento].
+ #strong[Elaborazione Locale (\*Edge / In-Situ Computing\*) e Compressione #mi(">500\\times") per la Telemetria:]
Eseguendo lo #emph[spike detection] o la classificazione della crisi direttamente sul chip impiantato, non è più necessario trasmettere il segnale grezzo: si trasmette solo il flag dell'evento rilevato o l'indirizzo dello spike (#emph[send-on-event]), riducendo il traffico dati di #strong[oltre #mi("500") volte] e abbattendo la potenza del trasmettitore wireless UWB a soli #strong[#mi("4.6\\,\\mu\\text{W}")] (#strong[NeuroSEED], 2026).
+ #strong[Robustezza Intrinseca al Rumore e alla Deriva di Baseline:]
L'integrazione #emph[leaky] di membrana e gli schemi differenziali/valle-picco sugli eventi UP/DOWN filtrano naturalmente il rumore ad alta frequenza non correlato e gli artefatti lenti di movimento o polarizzazione d'elettrodo.


#line(length: 100%, stroke: 0.5pt + luma(200))

= Capitolo 3 — Applicazioni Biomedicali delle SNN nell'Elaborazione di Segnali Biologici

In questo capitolo vengono esaminate in dettaglio le quattro applicazioni biomedicali principali presentate nella letteratura di riferimento (#raw("paperSNN3"), #raw("paperSNN4"), #raw("paperSNN6"), #raw("paperSNN7")), che coprono l'intero spettro dei segnali elettrofisiologici neurali:
+ #strong[Potenziali di Campo Locale (\*Local Field Potentials\*, LFP)] intracranici da corteccia paraippocampale per la rilevazione a bassissima latenza di crisi epilettiche ed esclusione di scariche interictali e artefatti (#strong[NET-TEN], #emph[Ronchini et al., 2023]).
+ #strong[Elettroencefalografia da Scalpo (\*Scalp EEG\*)] non invasiva su dataset clinici pediatrici e adulti (CHB-MIT e Siena) per il monitoraggio #emph[streaming real-time] sub-milliwatt su processore neuromorfico digitale edge (#strong[WaveSense su SynSense Xylo], #emph[Li et al., 2024]).
+ #strong[Elettroencefalografia Intracranica (\*iEEG\*)] multicanale (42–62 elettrodi subdurali e di profondità, dataset SWEC-ETHZ) elaborata su processore neuromorfico #emph[mixed-signal] (#strong[DYNAP-SE2], #emph[Bartels et al., 2025]) per l'estrazione hardware dei cluster di sincronizzazione parziale ictale.
+ #strong[Potenziali d'Azione Extracellulari (\*Neural Action Potentials / Spikes\*, fino a #mi("5.2\\,\\text{kHz}"))] acquisiti su 32 canali con multiplexing diretto nel tempo (TDM), conversione adattiva in spike, rilevamento #emph[clockless] valle-picco e telemetria wireless impulsiva IR-UWB (#strong[NeuroSEED], #emph[Wu et al., 2026]).

#line(length: 100%, stroke: 0.5pt + luma(200))

== 3.1 Rilevamento a Bassissima Latenza di Crisi Epilettiche in Segnali LFP Intracranici: Il Sistema NET-TEN #emph[(Ronchini et al., 2023 — Paper 3)]

=== A. Obiettivo Clinico, Modello Sperimentale #emph[In Vitro] e Dataset
Circa un terzo dei pazienti affetti da epilessia è refrattario ai trattamenti farmacologici. Per questi soggetti, la neurostimolazione cerebrale profonda (#emph[Deep Brain Stimulation], #strong[DBS]) ad anello chiuso (#emph[closed-loop]) eroga impulsi elettrici terapeutici solo quando viene rilevata un'attività epilettiforme incipiente, riducendo gli effetti collaterali e massimizzando l'efficacia rispetto alla stimolazione continua (#emph[open-loop]). Un rivelatore impiantabile ideale per DBS deve discriminare in tempo reale tra:
- #strong[Attività di baseline sana (#raw("Label = 0"))];
- #strong[Scariche interictali brevi (#raw("Label = 1"))], che precedono o accompagnano la patologia ma non costituiscono una crisi clinica prolungata;
- #strong[Eventi ictali (#raw("Label = 2"))], ossia vere e proprie crisi epilettiche tonico-cloniche che richiedono l'intervento immediato dello stimolatore;
- #strong[Artefatti elettrici (#raw("Artifact"))], che non devono mai innescare falsi positivi.

Per validare sperimentalmente il chip #strong[NET-TEN] (fabbricato in tecnologia #strong[TSMC 180 nm CMOS], incapsulato in package QFN48 e montato sulla PCB di test #emph[HERMES], #strong[Figura 15]), gli autori hanno utilizzato registrazioni di #strong[Local Field Potentials (LFP)] ottenute da fette orizzontali di ippocampo-corteccia (#strong[CTX], spessore #mi("400\\,\\mu\\text{m}")) prelevate da #mi("n = 10") topi maschi CD1 (4–8 settimane), perfuse con liquido cerebrospinale artificiale (aCSF a #mi("32\\,^\\circ\\text{C}")) addizionato con il bloccante dei canali del potassio #strong[4-aminopiridina (4AP, #mi("250\\,\\mu\\text{M}"))] per indurre ittogenesi acuta. I segnali sono stati acquisiti tramite una matrice planare di microelettrodi (#strong[MEA #mi("6 \\times 10")], 60 elettrodi in Ti-iR di diametro #mi("30\\,\\mu\\text{m}"), passo #mi("500\\,\\mu\\text{m}"), amplificatore MEA1060, campionati a #mi("f_s = 2\\,\\text{kHz}") con filtro passa-basso a #mi("1\\,\\text{kHz}")). Il dataset comprende #strong[10 tracce da #mi("100\\,\\text{s}")] dalla corteccia paraippocampale: 6 con solo evento ictale, 3 con evento ictale + scariche interictali, e 1 contenente solo un artefatto elettrico.

#figure(image("figure/fig15_netten_lfp_detection_pcb_die.png", width: 88%), caption: [Esempio di rilevazione LFP su NET-TEN e fotografia di PCB e die CMOS])
#emph[Figura 15 — Estratta da Ronchini et al. (2023), Fig. 1 e Fig. 2: (In alto) Segnale LFP di 100 s con evento ictale, conversione in spike UP e DW tramite algoritmo SFE (soglia #mi("2.7\\,\\mu\\text{V}")), densità di spike su finestre di 1 s, etichetta manuale (0=baseline, 1=interictal, 2=ictal) e risposta in tensione misurata all'oscilloscopio su un neurone di uscita di NET-TEN. (In basso) PCB di prototipazione HERMES con potenziometri a 25 giri per la regolazione fine dei bias e microfotografia dei die CMOS a 180 nm.]

=== B. Conversione del Segnale LFP in Spike (#emph[Step-Forward Encoding], SFE) e Topologia della Rete 10–10–10
Il segnale analogico LFP viene convertito in due flussi binari di eventi (#strong[UP] e #strong[DW]) mediante l'algoritmo #strong[Step-Forward Encoding (SFE)] (equivalente algoritmico di un modulatore delta asincrono ADM): ad ogni campione (#mi("2\\,\\text{kHz}")), se #mi("S(t) > \\text{baseline} + \\text{threshold}") viene emesso uno spike #raw("UP") e la baseline viene incrementata di #mi("+\\text{threshold}"); se #mi("S(t) < \\text{baseline} - \\text{threshold}") viene emesso uno spike #raw("DW") e la baseline viene decrementata di #mi("-\\text{threshold}"). La soglia è calibrata in modo che l'OR logico tra UP e DW produca un firing rate medio del #mi("\\sim 30\\%") dei time-step (#mi("2.7\\,\\mu\\text{V}") in Fig. 15). Gli impulsi binari sono convertiti in impulsi fisici di tensione con #strong[ampiezza di picco #mi("200\\,\\text{mV}")] e larghezza a metà altezza (#strong[FWHM]) di #strong[#mi("130\\,\\mu\\text{s}")] (distanza minima inter-impulso #mi("350\\,\\mu\\text{s}")), inviati al chip tramite generatore di forme d'onda Keysight 33600A.

#figure(image("figure/fig16_netten_arch_neuron_epsc_stdp.png", width: 88%), caption: [Architettura della rete NET-TEN e schemi a livello transistor di neurone Izhikevich, EPSC e STDP])
#emph[Figura 16 — Estratta da Ronchini et al. (2023), Fig. 3: (a) Architettura feed-forward a 3 strati (10–10–10 neuroni) di NET-TEN con fan-out pari a 2 tra input e hidden layer e connessione 1-a-1 tra hidden e output layer. (b) Circuito CMOS del neurone di Izhikevich (#mi("M_1\\text{-}M_{\\text{12}}, C_v, C_u")). (c) Circuito sinaptico EPSC (#mi("M_{\\text{E1}}\\text{-}M_{\\text{E4}}, C_{\\text{syn}}")). (d) Circuito di plasticità STDP in sottosoglia (#mi("M_{\\text{S1}}\\text{-}M_{\\text{S12}}, C_w")).]

Come mostrato in #strong[Figura 16a], l'architettura di NET-TEN è una SNN #emph[feed-forward] a #strong[3 layer da 10 neuroni ciascuno (30 neuroni di Izhikevich totali)]:
- #strong[Input Layer (10 neuroni + 10 blocchi EPSC a peso statico):] I primi 5 neuroni ricevono il treno di #strong[UP spikes], gli altri 5 ricevono i #strong[DW spikes], mediati da 10 circuiti EPSC il cui peso #mi("V_w") è fissato esternamente su PCB.
- #strong[Hidden Layer (10 neuroni + 20 sinapsi plastiche STDP+EPSC):] Ogni neurone di input proietta esattamente a #strong[2 neuroni hidden (fan-out = 2)] e ogni neurone hidden riceve #strong[2 connessioni (fan-in = 2)]. Le correnti #mi("I_{\\text{syn}}") dei due blocchi EPSC convergenti vengono sommate per KCL sul condensatore #mi("C_v") del neurone hidden.
- #strong[Output Layer (10 neuroni + 10 sinapsi plastiche STDP+EPSC):] Connesso #strong[1-a-1] con i 10 neuroni dell'hidden layer. In totale il chip integra #strong[30 neuroni di Izhikevich, 40 circuiti EPSC e 30 circuiti STDP] su un'area complessiva di layout di soli #strong[#mi("1.08\\,\\text{mm}^2")], alimentati a una tensione ultra-ridotta #strong[#mi("V_{\\text{DD}} = 250\\,\\text{mV}")] (#mi("0.25\\,\\text{V}")).

=== C. Meccanismo Fisico di Filtraggio Spazio-Temporale Senza Training Offline
Una caratteristica ingegneristica fondamentale di NET-TEN è l'#strong[assenza totale di una fase di addestramento offline]:
+ #strong[I neuroni agiscono come filtri passa-alto (\*High-Pass Filters\*) nel dominio della frequenza di spike:] Poiché i transistor operano in sottosoglia profonda con correnti di perdita, un neurone riesce ad accumulare su #mi("C_v") carica sufficiente per superare la soglia del comparatore #strong[solo quando gli spike pre-sinaptici arrivano ad alta frequenza ravvicinata] (come accade durante le scariche epilettiformi). Il firing rate di uscita di ciascuno strato è quindi sempre inferiore a quello di ingresso, sopprimendo completamente il rumore di baseline (da cui una #strong[Precision = #mi("0.998")], quasi totale assenza di falsi positivi durante la baseline).
+ #strong[La STDP agisce come un filtro dinamico a memoria breve:] Poiché la capacità di memorizzazione del peso nel blocco STDP è molto piccola (#strong[#mi("C_w = 206.30\\,\\text{fF}")]), il peso analogico #mi("V_w") decade in #strong[decine di millisecondi]. La STDP non "memorizza" pesi statici, ma potenzia dinamicamente in tempo reale le sinapsi attraversate da burst persistenti e correlati (eventi ictali), facilitando la propagazione verso lo strato di uscita.
+ #strong[Effetto del \*Device Mismatch\* in Sottosoglia:] Sebbene tutti i 30 neuroni condividano gli stessi bias globali su PCB, la dispersione statistica dei transistor a #mi("V_{\\text{DD}} = 0.25\\,\\text{V}") fa sì che #strong[4 canali di uscita su 10 (#raw("Ch6"), #raw("Ch7"), #raw("Ch8") e #raw("Ch10"))] si sintonizzino spontaneamente in modo ottimale per rispondere agli eventi epilettiformi.

=== D. Risultati Sperimentali, Discriminazione Ictale/Interictale/Artefatto e Post-Processing a 2 Contatori
Nelle misure sperimentali sui 10 campioni animali, la risposta grezza del primo spike emesso da NET-TEN mostra una #strong[latenza mediana di appena #mi("56.7\\,\\text{ms}\\ [\\text{IQR } 79.1\\,\\text{ms}]")] per gli eventi ictali (media #mi("110.4\\,\\text{ms}")) e di #strong[#mi("138.6\\,\\text{ms}\\ [\\text{IQR } 39.2\\,\\text{ms}]")] per gli eventi interictali (Tabella 3.1).

#strong[Tabella 3.1 — Latenza di risposta ictale e interictale (in ms) sui 4 canali informativi di NET-TEN \*(Ronchini et al., 2023, Table 1)]\*

#block(breakable: true, width: 100%)[
  #set text(size: 7.5pt)
  #table(columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr), stroke: 0.5pt + luma(180), inset: 4.5pt,
    table.header([#strong[Sample]], [#strong[Tipologia Traccia]], [#strong[Ictal Ch6 (ms)]], [#strong[Ictal Ch7 (ms)]], [#strong[Ictal Ch8 (ms)]], [#strong[Ictal Ch10 (ms)]], [#strong[Interictal Ch6 (ms)]], [#strong[Interictal Ch7 (ms)]], [#strong[Interictal Ch8 (ms)]], [#strong[Interictal Ch10 (ms)]]),
    [#strong[1]], [Ictal], [31.4], [31.2], [31.6], [52.9], [—], [—], [—], [—],
    [#strong[2]], [Ictal + Interictal], [48.1], [48.1], [48.4], [57.5], [#mi("80.1^*")], [#mi("86.1^*")], [#mi("80.4^*")], [#mi("130.8^*")],
    [#strong[3]], [Ictal + Interictal], [104.2], [104.1], [104.6], [874.8], [138.6], [138.2], [138.8], [Non rilevato],
    [#strong[4]], [Artifact], [—], [—], [—], [—], [—], [—], [—], [—],
    [#strong[5]], [Ictal + Interictal], [203.1], [228.3], [203.8], [202.9], [147.8], [147.5], [148.2], [155.6],
    [#strong[6]], [Ictal], [178.9], [201.9], [179.3], [178.6], [—], [—], [—], [—],
    [#strong[7]], [Ictal], [44.1], [43.8], [44.3], [55.9], [—], [—], [—], [—],
    [#strong[8]], [Ictal], [43.9], [43.9], [44.3], [62.8], [—], [—], [—], [—],
    [#strong[9]], [Ictal], [41.7], [26.1], [49.7], [38.4], [—], [—], [—], [—],
    [#strong[10]], [Ictal], [74.5], [74.0], [74.7], [98.7], [—], [—], [—], [—],
    [#strong[Mediana \[IQR\] per ch.]], [], [#strong[48.1 \[60.3\]]], [#strong[48.1 \[60.3\]]], [#strong[49.7 \[60.3\]]], [#strong[62.8 \[122.7\]]], [#strong[138.6 \[33.9\]]], [#strong[138.2 \[30.7\]]], [#strong[138.8 \[33.9\]]], [#strong[143.2 \[12.4\]]],
    [#strong[Mediana \[IQR\] globale]], [], [\\multicolumn{4}{c], [}{\\textbf{56.7 \[79.1\] ms}}], [\\multicolumn{4}{c}{\\textbf{138.6 \[39.2\] ms}}], [], [], [], [], [],
  )
]

Per isolare esclusivamente le crisi #strong[ictali] (che durano decine di secondi e generano una mediana di #strong[#mi("1117.5") spike]) scartando sia le scariche #strong[interictali] (brevi, mediana di soli #strong[#mi("4.5") spike]) sia gli #strong[artefatti elettrici] (mediana di #mi("27.5") spike ma più diluiti all'esordio), gli autori hanno analizzato l'intervallo inter-spike tra il #mi("1^\\circ") e il #mi("3^\\circ") spike (#mi("\\text{ISI}_{\\text{I}-\\text{III}}")) combinato col conteggio degli spike, progettando una logica digitale minimale alimentata a #mi("V_{\\text{DD}} = 0.3\\,\\text{V}") composta da soli #strong[due contatori]:
+ #strong[Filtro Anti-Artefatto (primi 3 spike entro #mi("10\\,\\text{ms}")):] All'arrivo di uno spike #mi("f"), si verifica che il terzo spike (#mi("f+2")) cada entro #strong[#mi("\\text{ISI}_{\\text{I}-\\text{III}} < 10\\,\\text{ms}")]. Ciò esclude immediatamente l'artefatto.
+ #strong[Filtro Anti-Interictale (almeno altri 10 spike nei successivi #mi("190\\,\\text{ms}")):] Si verifica che il #strong[#mi("13^\\circ") spike] complessivo cada entro una finestra totale di #strong[#mi("200\\,\\text{ms}")] (#mi("10\\,\\text{ms} + 190\\,\\text{ms}")) dal primo spike.

In hardware CMOS 180 nm a #mi("0.3\\,\\text{V}"), questo post-processing richiede un #strong[contatore a 8-bit] (clockato a #mi("1\\,\\text{kHz}") per misurare le finestre di #mi("10\\,\\text{ms}") e #mi("190\\,\\text{ms}"), potenza dinamica di soli #strong[#mi("31\\,\\text{pW}")]) e un #strong[contatore asincrono a 3-bit] (pilotato dagli spike di uscita, che consuma #strong[#mi("11.4\\,\\text{fJ/spike}")], ovvero #mi("11.4\\,\\text{fJ} \\times 13 = \\mathbf{148.2\\,\\text{fJ/classificazione}}")). Con questa logica completa, l'artefatto è rigettato al #mi("100\\%"), le scariche interictali sono ignorate e le crisi ictali vengono rilevate al #mi("13^\\circ") spike con un #strong[ritardo mediano di soli #mi("229.4\\,\\text{ms}") (#mi("0.23\\,\\text{s}"), pari allo #mi("0.6\\%") della durata media della crisi di #mi("40.45\\,\\text{s}"))], con una potenza totale di sistema di #strong[#mi("3.50\\,\\text{nW} + 31\\,\\text{pW} = \\mathbf{3.53\\,\\text{nW}}")]!

#line(length: 100%, stroke: 0.5pt + luma(200))

== 3.2 Rilevamento Real-Time Sub-Milliwatt di Epilessia da EEG da Scalpo su Processore Neuromorfico Digitale Edge: WaveSense su SynSense Xylo #emph[(Li et al., 2024 — Paper 4)]

=== A. Obiettivo Biomedicale, Dataset EEG Clinici e Pre-Processing
Mentre NET-TEN opera su segnali LFP intracranici, #strong[Li et al. (2024)] affrontano il monitoraggio continuo indossabile (#emph[wearable edge inference]) su tracciati #strong[EEG da scalpo non invasivi] (banda #mi("1\\text{-}80\\,\\text{Hz}"), campionati a #mi("512\\,\\text{Hz}") secondo il sistema internazionale 10-20), validando il sistema su due benchmark clinici:
+ #strong[CHB-MIT Scalp EEG Database (Boston Children's Hospital):] 23 casi da 22 pazienti pediatrici/giovani (1.5–22 anni) con epilessia intrattabile, selezionando i 2 canali bipolari più informativi (#strong[C3–P3] e #strong[C4–P4]).
+ #strong[Siena Scalp EEG Database (Università di Siena):] 14 pazienti adulti (20–71 anni) con registrazioni di lunga durata (145–1408 minuti).

Prima della codifica in spike, il segnale EEG subisce un #strong[pre-processing off-chip] composto da: ri-riferimento alla media comune (#emph[Common Average Reference]), filtro passa-banda #mi("1\\text{-}80\\,\\text{Hz}"), filtro #strong[Notch a #mi("50\\,\\text{Hz}")], e #strong[Analisi delle Componenti Indipendenti (ICA)] per rimuovere artefatti oculari (EOG), cardiaci (ECG), muscolari (EMG) e da movimento (#strong[Figura 18]). Il segnale pulito (segmentato in finestre di #mi("5\\,\\text{s}")) viene convertito da un #strong[codificatore Sigma-Delta (#mi("\\Sigma\\Delta"))] (Corradi & Indiveri, 2015) in due serie temporali di spike per canale (#strong[UP] e #strong[DOWN]).

#figure(image("figure/fig17_xylo_lif_model_and_arch.png", width: 88%), caption: [Modello LIF e architettura del processore digitale SynSense Xylo])
#emph[Figura 17 — Estratta da Li et al. (2024), Fig. 1, 2 e 3: (A sinistra) Circuito elettrico equivalente RC parallelo e schema a blocchi funzionale del neurone LIF. (A destra) Architettura logica dell'ASIC neuromorfico digitale SynSense Xylo (28 nm CMOS), comprendente fino a 16 canali di ingresso, una popolazione nascosta di 1000 neuroni LIF digitali con pesi ricorrenti sparsi (max 32 target/neurone) e una popolazione di readout di 8 neuroni LIF.]

#figure(image("figure/fig18_xylo_spike_encoding_wavesense.png", width: 88%), caption: [Codifica Sigma-Delta del segnale EEG e architettura SNN WaveSense])
#emph[Figura 18 — Estratta da Li et al. (2024), Fig. 5 e Fig. 6: (In alto) Tracciato EEG originale (con periodo ictale evidenziato in rosso) e corrispondenti serie temporali di spike UP e DOWN generate dal codificatore Sigma-Delta. (In basso) Architettura complessiva della SNN WaveSense basata su blocchi convoluzionali temporali dilatati impilati.]

=== B. Architettura SNN #emph[WaveSense], Regolarizzazione di Sparsità e Deploy su ASIC SynSense Xylo (28 nm)
La rete SNN adottata è #strong[WaveSense] (ispirata a WaveNet), una rete #emph[feed-forward] composta da blocchi impilati di #strong[convoluzioni temporali dilatate] (#emph[dilated temporal convolutions]), realizzate nelle SNN sfruttando proiezioni sinaptiche multiple con #strong[diverse costanti di tempo di decadimento]. Il modello implementato è estremamente compatto: #strong[soli #mi("2.400") pesi (#mi("2.4\\text{K}"))] totali, 16 neuroni nello strato di readout nascosto, 2 sinapsi nello strato dilatato, costante di tempo di membrana #mi("\\tau_{\\text{mem}} = 2\\,\\text{ms}") (#mi("0.002\\,\\text{s}")), soglia #mi("V_{\\text{th}} = 0.6") e 2 neuroni di uscita (ictale vs interictale).

L'addestramento avviene off-chip tramite #strong[BPTT (Backpropagation Through Time)] con #emph[surrogate gradient] (ottimizzatore Adam, learning rate #mi("0.0005"), 150 epoche). Per minimizzare il consumo energetico una volta mappata la rete su hardware, alla funzione di costo #emph[Cross-Entropy] (#mi("L_{\\text{CE}}"), calcolata sulla corrente sinaptica di picco dei neuroni di uscita) viene sommato un #strong[termine di regolarizzazione dell'attività di firing]:

#mitex("L = L_{\\text{CE}} + \\sum_{t} \\sum_{i} \\left( \\frac{N_i^t \\, \\Theta\\!\\left(N_i^t - l\\right)}{T \\cdot N_{\\text{neurons}}} \\right)^2")

dove #mi("N_i^t") è il numero di spike emessi dal neurone #mi("i") nel time-bin #mi("t"), #mi("l") è la soglia massima tollerata di spike e #mi("\\Theta(\\cdot)") è il gradino di Heaviside: qualsiasi attività di firing eccedente #mi("l") viene penalizzata quadraticamente durante il training. Tramite il framework #strong[Rockpool], i pesi in virgola mobile vengono poi quantizzati e scalati a #strong[interi a 8-bit (#mi("\\pm 128"))] e caricati sull'ASIC #strong[SynSense Xylo]:
- #strong[Specifiche fisiche di Xylo:] Processo #strong[28 nm CMOS], area del chip #strong[#mi("6.5\\,\\text{mm}^2")], frequenza massima di clock #strong[#mi("250\\,\\text{MHz}")], memoria integrata #strong[#mi("124\\,\\text{KB}") SRAM], alimentazione #strong[#mi("V_{DD,\\text{Core}} = 1.8\\,\\text{V}")] e #strong[#mi("V_{DD,\\text{IO}} = 2.5\\,\\text{V}")], decadimento esponenziale realizzato con #emph[bit-shift decay].

=== C. Prestazioni di Classificazione, Latenza e Consumo Energetico Misurato Real-Time
In modalità #emph[streaming] (passo decisionale di #mi("0.5\\,\\text{s}"), con filtro anti-falso allarme che conferma l'allarme dopo 4 predizioni consecutive concordi):
- #strong[Accuratezza e Sensibilità:] Sul dataset #strong[CHB-MIT], il modello ottiene in simulazione #strong[Accuratezza #mi("93.3\\%")], #strong[Sensibilità #mi("90.4\\%")], #strong[Specificità #mi("96.7\\%")], #strong[F1-score #mi("91.2\\%")], e dopo quantizzazione a 8-bit su hardware Xylo mantiene un'#strong[Accuratezza dell'#mi("89.87\\%")] (perdita di #mi("\\sim 3.43\\%")). Sul dataset #strong[Siena Scalp], ottiene in simulazione #strong[Accuratezza #mi("92.9\\%")] (Sensibilità #mi("89.7\\%"), Specificità #mi("90.1\\%"), F1 #mi("92.3\\%")) e su hardware Xylo #strong[#mi("88.62\\%")] (con soli #mi("2.4\\text{K}") pesi, contro i #mi("10.8\\text{K}\\text{-}27.3\\text{M}") pesi delle CNN in letteratura!).
- #strong[Latenza:] Latenza mediana di rilevazione di #strong[#mi("0.5\\,\\text{s}")] su CHB-MIT e #strong[#mi("0.75\\,\\text{s}")] su Siena Scalp.
- #strong[Potenza Misurata Real-Time (ADC onboard a #mi("1000\\,\\text{Hz}")):]
- #strong[Potenza Core (logica SNN + lettura/scrittura 124 KB SRAM + routing eventi):] media #strong[#mi("287.9\\,\\mu\\text{W}")] (range #mi("280.3\\text{-}292.1\\,\\mu\\text{W}"));
- #strong[Potenza I/O (interfaccia SPI):] media #strong[#mi("87.4\\,\\mu\\text{W}")] (range #mi("80.2\\text{-}95.5\\,\\mu\\text{W}"));
- #strong[Potenza Totale del Chip:] #strong[#mi("375.3\\,\\mu\\text{W}")] (#mi("\\sim 550\\times") inferiore alle implementazioni FPGA/GPU e inferiore ai #mi("448\\text{-}1589\\,\\mu\\text{W}") degli ASIC dedicati SVM/ANN).

#line(length: 100%, stroke: 0.5pt + luma(200))

== 3.3 Rilevamento Event-Driven di Crisi Epilettiche da iEEG Umano tramite Sincronizzazione Parziale su Processore Mixed-Signal: DYNAP-SE2 #emph[(Bartels et al., 2025 — Paper 6)]

=== A. Razionale Neurofisiologico (Sincronizzazione Parziale / Stati Chimera) e Setup su DYNAP-SE2
Durante una crisi epilettica focale registrata con elettrodi intracranici (#strong[iEEG]), le popolazioni neurali della zona epilettogena non passano istantaneamente a una sincronia globale perfetta, ma attraversano stati di #strong[sincronizzazione parziale locale (stati Chimera)] caratterizzati da cluster spaziali di canali adiacenti fortemente correlati. #strong[Bartels et al. (2025)] dimostrano come una SNN implementata sui circuiti analogici in sottosoglia del processore multicore #strong[DYNAP-SE2] (#strong[180 nm CMOS], 4 core da 256 neuroni AdEx = 1024 neuroni, #mi("V_{\\text{DD}} = 1.8\\,\\text{V}"), #strong[Figura 21]) possa agire da trasformatore non lineare per amplificare selettivamente queste correlazioni spazio-temporali.

#figure(image("figure/fig21_dynapse2_eeg_seizure_overview.png", width: 88%), caption: [Panoramica del sistema di rilevamento crisi iEEG su DYNAP-SE2])
#emph[Figura 21 — Estratta da Bartels et al. (2025), Fig. 1: (a) Approccio convenzionale ospedaliero vs diario paziente. (b, c) Sistema proposto basato su processore mixed-signal DYNAP-SE2 con AFE/ADM integrato e core SNN per dispositivi impiantabili/indossabili. (d, e) Fotografia del die DYNAP-SE2 (4 core SNN + AFE) e scheda di sviluppo con FPGA. (f, g) Diagramma a blocchi del setup sperimentale con scheda DAC a 18 bit e architettura della SNN a due strati (Translation Layer FF-I / R-E / R-I + NLNG Layer).]

#figure(image("figure/fig22_dynapse2_snn_translation_nlng.png", width: 88%), caption: [Setup hardware con AFE + ADM e architettura a due strati della SNN su DYNAP-SE2])
#emph[Figura 22 — Estratta da Bartels et al. (2025), Fig. 3: (a) Architettura dettagliata della SNN on-chip: per ciascuno degli #mi("M") canali ADM, un Translation Layer con 3 neuroni (FF-I, R-E, R-I) realizza un filtro passa-banda di firing rate, seguito dal layer Non-Local Non-Global (NLNG) con matrice di connettività spaziale #raw("1-2-1-0-1-2-1"). (b) Curva di trasferimento #mi("FR_{\\text{out}}") vs #mi("FR_{\\text{in}}") misurata sul chip che dimostra l'azione passa-banda (200–600 Hz) del neurone R-E. (c) Correlazione di Pearson e risposta del layer NLNG al variare del jitter temporale #mi("\\sigma").]

#figure(image("figure/fig23_dynapse2_afe_adm_setup.png", width: 88%), caption: [Catena di condizionamento AFE + ADM di DYNAP-SE2])
#emph[Figura 23 — Estratta da Bartels et al. (2025), Fig. 6: Schede hardware (DYNAP-SE2 dev board + DAC board AD5781 a 18 bit con Teensy 4.1), tracce all'oscilloscopio del segnale iEEG rigenerato (#mi("\\sim 100\\,\\text{mV}_{\\text{pp}}")) e amplificato dall'LNA di +20 dB, e schema a blocchi dell'Analog Front-End (LNA + filtro passa-banda + Asynchronous Delta Modulator UP/DN).]

Lo studio utilizza il database clinico #strong[SWEC-ETHZ iEEG] (Inselspital Berna, campionato a #mi("512\\,\\text{Hz}"), banda #mi("0.5\\text{-}150\\,\\text{Hz}")), analizzando #strong[10 crisi in 5 pazienti] con epilessia del lobo temporale (TLE) o parietale (PLE) aventi un numero di canali #mi("M \\in \\{42, 47, 56, 59, 62\\}") (#mi("M < 64") per rispettare il fan-in massimo di 64 sinapsi CAM per neurone di DYNAP-SE2). I tracciati digitali vengono riconvertiti in segnali fisici analogici da un #strong[DAC a 18-bit (AD5781)] e inviati all'#strong[AFE integrato sul die DYNAP-SE2] (#strong[Figura 23]), composto da un #strong[LNA con guadagno di #mi("20\\,\\text{dB}")] seguito da un #strong[Asynchronous Delta Modulator (ADM)] che codifica in hardware gli eventi #raw("UP") e #raw("DN").

=== B. Architettura della SNN Hardware-Aware a 2 Layer (Translation Layer + NLNG Layer)
Per un paziente con #mi("M") canali iEEG, vengono allocati #strong[#mi("4M") neuroni AdEx] distribuiti su #strong[3 core fisici distinti] (poiché i generatori di correnti di bias #emph[Coarse/Fine] sono condivisi all'interno di ciascun core, Tabella 3.2):

+ #strong[Layer 1 — Translation Layer (#mi("3M") neuroni: Filtro Passa-Banda in Frequenza di Firing #mi("200\\text{-}600\\,\\text{Hz}")):]
Per ciascun canale #mi("x \\in \\{1..M\\}") sono istanziati 3 neuroni connessi con sinapsi DPI lente eccitatorie (NMDA-like) e inibitorie (#mi("\\text{GABA}_B")-like):
- #strong[Neurone FF-I (\*Fast-Firing Inhibitory\*, sul Core 2):] Polarizzato con costante di tempo breve (#mi("I_\\tau = 4.528\\,\\text{nA}")) e alto guadagno (#mi("I_{\\text{gain}} = 35.39\\,\\text{nA}")), risponde rapidamente agli spike ADM saturando a #mi("\\sim 180\\,\\text{Hz}") per ingressi #mi(">200\\,\\text{Hz}") e inibisce il neurone R-E, #strong[tagliando le basse frequenze di firing (#mi("<200\\,\\text{Hz}"), rumore di baseline)].
- #strong[Coppia Bilanciata R-E / R-I (\*Recurrent Excitatory / Inhibitory\*, sul Core 1):] R-E riceve gli spike ADM ed è accoppiato ricorrentemente con R-I (#mi("I_\\tau = 0.628 / 0.667\\,\\text{nA}")). L'inibizione ricorrente di R-I #strong[sopprime le frequenze eccessive (#mi(">600\\,\\text{Hz}"))]. Di conseguenza, la risposta di #strong[R-E] (curva verde in #strong[Figura 22b]) è lineare esclusivamente nella finestra #strong[#mi("200\\text{-}600\\,\\text{Hz}")].
+ #strong[Layer 2 — NLNG (\*Non-Local Non-Global\*) Encoding Layer (#mi("M") neuroni sul Core 3):]
Ottenuto tramite #emph[Evolutionary Neural Architecture Search] (#strong[ENAS]), connette il neurone R-E del canale #mi("x") ai 6 neuroni NLNG vicini (#mi("x-3, x-2, x-1") e #mi("x+1, x+2, x+3")) con molteplicità di pesi sinaptici #strong[#raw("1 - 2 - 1 - 0 - 1 - 2 - 1")] (peso nullo sul canale #mi("x") stesso!).
- #strong[Effetto dinamico:] In fase pre-ictale (ingressi poco correlati), i neuroni NLNG restano sotto i #mi("100\\,\\text{Hz}"); durante la crisi ictale, l'arrivo sincrono di spike da canali vicini fa superare la soglia ai neuroni NLNG, che balzano a #strong[#mi(">100\\,\\text{Hz}")] formando #strong[matrici di sincronizzazione #mi("N_{\\text{i,j}}") (norma #mi("L_1") a lag zero con kernel esponenziale #mi("\\tau = 1\\,\\text{ms}")) fortemente clusterizzate], classificate poi da una #strong[Linear SVM (LSVM)].

#strong[Tabella 3.2 — Parametri #mi("(C, F)") del Bias Generator e correnti sottosoglia nei 3 core di DYNAP-SE2 \*(Bartels et al., 2025, Tables 3 & 4)]\*

#block(breakable: true, width: 100%)[
  #set text(size: 7.5pt)
  #table(columns: (1fr, 1fr, 1fr, 1fr, 1fr), stroke: 0.5pt + luma(180), inset: 4.5pt,
    table.header([#strong[Parametro Sinaptico]], [#strong[Formato / Unità]], [#strong[Core 1: R-E / R-I (exc. / inh.)]], [#strong[Core 2: FF-I]], [#strong[Core 3: NLNG]]),
    [#strong[Costante di tempo (#mi("\\tau_{\\text{syn}}"))]], [Coarse/Fine #mi("(C, F)")], [#mi("(1, 20)\\ /\\ (1, 30)")], [#mi("(2, 20)")], [#mi("(1, 12)")],
    [#strong[Corrente #mi("I_\\tau")]], [#mi("\\text{nA}")], [#mi("0.628\\ /\\ 0.667\\,\\text{nA}")], [#mi("4.528\\,\\text{nA}")], [#mi("0.597\\,\\text{nA}")],
    [#strong[Guadagno DPI (#mi("I_{\\text{gain}}"))]], [Coarse/Fine #mi("(C, F)")], [#mi("(2, 100)\\ /\\ (2, 100)")], [#mi("(3, 100)")], [#mi("(2, 100)")],
    [#strong[Corrente #mi("I_{\\text{gain}}")]], [#mi("\\text{nA}")], [#mi("4.84\\ /\\ 4.84\\,\\text{nA}")], [#mi("35.39\\,\\text{nA}")], [#mi("4.84\\,\\text{nA}")],
    [#strong[Peso Sinaptico (#mi("I_w"))]], [Coarse/Fine #mi("(C, F)")], [#mi("(3, 128)\\ /\\ 2\\times(3, 128)")], [#mi("(3, 128)")], [#mi("(3, 128)")],
    [#strong[Corrente #mi("I_w")]], [#mi("\\text{nA}")], [#mi("35.5\\ /\\ 71.0\\,\\text{nA}")], [#mi("35.5\\,\\text{nA}")], [#mi("35.5\\,\\text{nA}")],
  )
]

#emph[(Valori di corrente Coarse #mi("I_p(C_p)"): #mi("C_0 = 0.07\\,\\text{nA}"), #mi("C_1 = 0.55\\,\\text{nA}"), #mi("C_2 = 4.45\\,\\text{nA}"), #mi("C_3 = 35\\,\\text{nA}"), #mi("C_4 = 280\\,\\text{nA}"), #mi("C_5 = 2250\\,\\text{nA}"), con legge #mi("I = I_p(C_p) \\cdot \\frac{F_p}{256}")).]

=== C. Prestazioni LSVM e Analisi del Consumo Energetico Paziente-per-Paziente
Grazie alla trasformazione eseguita dalla SNN sul chip, la classificazione LSVM migliora significativamente rispetto all'uso diretto degli eventi ADM:
- Con feature di #strong[Sincronizzazione (NLNG SYN)]: Accuratezza media #strong[#mi("71.07 \\pm 6.42\\%")] (fino a #mi("78.78\\%") su ID1, contro #mi("53.54\\% \\to 69.76\\%") su ID2), Sensibilità #strong[#mi("63.56\\%")] (#mi("+4.7\\%") vs ADM), Specificità #strong[#mi("77.10\\%")], F1-Score #strong[#mi("65.30\\%")] (#mi("+5.44\\%") vs ADM), AUC #strong[#mi("73.80\\%")].
- Con feature di #strong[Firing Rate (NLNG FR)]: Accuratezza media #strong[#mi("78.35 \\pm 10.95\\%")] (fino a #mi("86.04\\%")), Sensibilità #strong[#mi("66.71\\%")] (#mi("+8.15\\%") rispetto al #mi("58.56\\%") dell'ADM!), Specificità #strong[#mi("85.54\\%")], F1-Score #strong[#mi("69.96\\%")], AUC #strong[#mi("80.91\\%")].

Dal punto di vista energetico (Tabella 3.3), il consumo dinamico medio dell'intera SNN sui 5 pazienti (media #mi("53.2") canali) è pari a #strong[#mi("149.96\\,\\mu\\text{W}")] (#strong[#mi("2.80\\,\\mu\\text{W/canale}")]), scendendo fino a #strong[#mi("1.77\\,\\mu\\text{W}") totali (#mi("0.03\\,\\mu\\text{W/canale}"))] durante il periodo pre-ictale quiescente del Paziente 2!

#strong[Tabella 3.3 — Consumo di potenza della SNN su DYNAP-SE2 (#mi("V_{\\text{DD}}=1.8\\,\\text{V}")) attraverso le fasi cliniche \*(Bartels et al., 2025, Table 5 & 6)]\*

#block(breakable: true, width: 100%)[
  #set text(size: 7.5pt)
  #table(columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr), stroke: 0.5pt + luma(180), inset: 4.5pt,
    table.header([#strong[Paziente (SWEC ID, Età, Epilessia)]], [#strong[Canali (#mi("M"))]], [#strong[Crisi (Durata s)]], [#strong[Pre-ictal (#mi("\\mu\\text{W}"))]], [#strong[Seiz-1ª metà (#mi("\\mu\\text{W}"))]], [#strong[Seiz-2ª metà (#mi("\\mu\\text{W}"))]], [#strong[Post-ictal (#mi("\\mu\\text{W}"))]], [#strong[#strong[Potenza Totale (#mi("\\mu\\text{W}"))]]], [#strong[#strong[Potenza / Canale (#mi("\\mu\\text{W/ch}"))]]]),
    [#strong[Pat 1] (ID2, 19a, TLE)], [42], [Seiz-1 (96 s)], [14.55], [35.95], [66.39], [11.60], [#strong[128.50]], [#strong[3.06]],
    [#strong[Pat 1] (ID2, 19a, TLE)], [42], [Seiz-2 (260 s)], [3.81], [62.69], [30.80], [—], [#strong[97.29]], [#strong[2.32]],
    [#strong[Pat 2] (ID9, 27a, TLE)], [56], [Seiz-1 (104 s)], [#strong[1.77]], [25.50], [32.28], [7.02], [#strong[66.56]], [#strong[1.19]],
    [#strong[Pat 2] (ID9, 27a, TLE)], [56], [Seiz-2 (118 s)], [2.78], [44.50], [35.99], [3.17], [#strong[86.45]], [#strong[1.54]],
    [#strong[Pat 3] (ID1, 24a, TLE)], [47], [Seiz-1 (125 s)], [65.67], [68.34], [53.96], [58.58], [#strong[246.55]], [#strong[5.24]],
    [#strong[Pat 3] (ID1, 24a, TLE)], [47], [Seiz-2 (70 s)], [49.89], [64.99], [43.40], [47.02], [#strong[205.30]], [#strong[4.37]],
    [#strong[Pat 4] (ID16, 31a, TLE)], [59], [Seiz-1 (81 s)], [5.68], [52.73], [31.37], [1.25], [#strong[91.03]], [#strong[1.54]],
    [#strong[Pat 4] (ID16, 31a, TLE)], [59], [Seiz-2 (67 s)], [1.95], [24.48], [37.98], [12.74], [#strong[77.14]], [#strong[1.31]],
    [#strong[Pat 5] (ID4, 32a, PLE)], [62], [Seiz-1 (160 s)], [108.25], [64.65], [65.83], [58.33], [#strong[297.06]], [#strong[4.80]],
    [#strong[Pat 5] (ID4, 32a, PLE)], [62], [Seiz-2 (127 s)], [54.69], [52.99], [42.47], [53.54], [#strong[203.69]], [#strong[3.28]],
    [#strong[MEDIA GLOBALE]], [#strong[53.2]], [—], [—], [—], [—], [—], [#strong[149.96 (#mi("\\sim 150\\,\\mu\\text{W}"))]], [#strong[2.80 #mi("\\mu\\text{W/ch}")]],
  )
]

#line(length: 100%, stroke: 0.5pt + luma(200))

== 3.4 Interfaccia Neurale Impiantabile a 32 Canali con Direct Multiplexing, Rilevazione Clockless di Spike e Telemetria Wireless IR-UWB: Il SoC NeuroSEED #emph[(Wu et al., 2026 — Paper 7)]

=== A. Architettura End-to-End del SoC NeuroSEED in TSMC 40 nm CMOS
Mentre i lavori precedenti si concentrano sull'elaborazione di segnali a bassa frequenza (EEG/iEEG/LFP, #mi("<150\\text{-}1000\\,\\text{Hz}")), #strong[NeuroSEED (\*Wu et al., 2026\*)] realizza un #strong[System-on-Chip (SoC) impiantabile completo a 32 canali] in tecnologia #strong[TSMC 40 nm CMOS] (#mi("V_{\\text{DD}} = 1.2\\,\\text{V} / 0.6\\,\\text{V}"), area totale del die #mi("857\\,\\mu\\text{m} \\times 820\\,\\mu\\text{m} = \\mathbf{0.70\\,\\text{mm}^2}"), area attiva #strong[#mi("0.16\\,\\text{mm}^2")]) progettato per acquisire, comprimere di oltre #mi("500\\times") e trasmettere via radio #strong[potenziali d'azione extracellulari (\*Neural Action Potentials / Spikes\*, banda fino a #mi("5.2\\,\\text{kHz}") per canale)] (#strong[Figura 25]).

#figure(image("figure/fig25_neuroseed_32ch_system_block.png", width: 88%), caption: [Schema a blocchi complessivo del SoC NeuroSEED a 32 canali])
#emph[Figura 25 — Estratta da Wu et al. (2026), Fig. 3: Architettura completa del SoC NeuroSEED a 32 canali: front-end analogico a Time-Division Multiplexing diretto (32-Ch Mux-Chop + CCIA LNA + integratore Gm-C con Windowed Integration Sampling e loop digitale di calibrazione dell'offset DC a 6-bit C-DAC), 32 convertitori Analog-to-Spike (ASC), 32 rivelatori di spike Integrate-and-Fire clockless e trasmettitore wireless impulsivo IR-UWB.]

Il sistema risolve i tre colli di bottiglia storici delle interfacce neurali multicanale impiantabili attraverso quattro blocchi co-progettati:

=== B. Front-End Analogico Direct-Multiplexing (32-Ch TDM AFE) e Loop Digitale di Cancellazione dell'Offset d'Elettrodo (EDO)
+ #strong[Multiplexing Rapido Prima dell'Amplificatore (#mi("N = 32")):]
Anziché replicare 32 amplificatori LNA (che occuperebbero troppa area), i 32 elettrodi sono divisi in 8 gruppi collegati a un #strong[4-Ch Mux-Chop] che campiona ciascun canale a #mi("f_{\\text{ch}} = 10.4\\,\\text{kHz}"), portando la frequenza complessiva di multiplexing e di chopping a #strong[#mi("f_s = f_{\\text{CHOP}} = 32 \\times 10.4\\,\\text{kHz} = \\mathbf{333\\,\\text{kHz}}")] (tempo di #emph[settling] per canale #mi("T_s = 3\\,\\mu\\text{s}")). Per garantire un errore di settling #mi("\\epsilon \\le 0.1\\%") (10 bit), la banda dell'LNA deve soddisfare #mi("f_{\\text{BW}} \\ge \\frac{-\\ln \\epsilon}{2\\pi T_s} \\approx 0.37\\,\\text{MHz}") ed è fissata a #strong[#mi("700\\,\\text{kHz}")] (ottenendo un #emph[matched spike ratio] #mi(">93\\%") sul dataset simulato di Quiroga et al.).
+ #strong[Primo Stadio CCIA (\*Capacitively Coupled Instrumentation Amplifier\*) con LNA \*Inverter-Based Current-Reuse\* (]Figura 26#strong[, in alto):]
Il guadagno ad anello chiuso è programmabile tramite il rapporto capacitivo #mi("C_{\\text{IN}} / C_{\\text{NFB}} = \\mathbf{7.3\\,\\text{pF}} / (\\mathbf{147\\,\\text{fF}} \\times \\{1, 4, 8\\})") (guadagno complessivo AFE misurato: #strong[#mi("41.2, 45.3, 47.1, 58.3\\,\\text{dB}")]), con condensatore di feedback positivo #mi("C_{\\text{PFB}} = C_{\\text{NFB}}") (#emph[Impedance Boosting Loop]). Il core LNA adotta una topologia #strong[inverter-based current-reuse] in cui le coppie differenziali complementari PMOS e NMOS condividono la stessa corrente di polarizzazione e operano in #strong[debole inversione (#mi("g_m / I_D \\approx 26"))] con transistor #emph[thick-oxide], raddoppiando la transconduttanza efficace e raggiungendo un #strong[Noise Efficiency Factor (#mi("\\text{NEF}")) di appena #mi("2.1")] e un rumore riferito all'ingresso (#strong[IRN]) di #strong[#mi("2.9\\,\\mu\\text{V}_{\\text{rms}}")] (#mi("1\\,\\text{Hz}\\text{-}1\\,\\text{kHz}"), densità media #mi("91\\,\\text{nV}/\\sqrt{\\text{Hz}}")).
+ #strong[Secondo Stadio Integratore Charge-Sampling #mi("G_m\\text{-}C") con \*Windowed Integration Sampling\* (WIS, ]Figura 26#strong[, in basso):]
Durante il demultiplexing verso i 32 canali, integra il segnale sui condensatori #mi("C_{\\text{INT}}") producendo una funzione di trasferimento #strong[#mi("\\text{sinc}")] (#mi("\\text{sinc}^2") in potenza) i cui #strong[zeri (notch profondi) cadono esattamente ai multipli interi di #mi("1/T_{\\text{SMP}} = f_{\\text{CHOP}} = 333\\,\\text{kHz}")], abbattendo il ripple di chopping e il rumore fuori banda prima del campionamento. L'equazione di decomposizione del rumore totale all'ingresso del CCIA è:
#mitex("\\overline{v_{n,\\text{tot}}^2} = \\overline{v_{n,\\text{th}}^2} + \\overline{v_{n,1/f}^2} + \\overline{v_{n,\\text{fold}}^2} + \\overline{v_{n,\\text{mux}}^2}")
dove il rumore termico dell'LNA inverter-based scala come #mi("\\frac{8kT}{3g_m} f_{\\text{BW,AFE}}") e il condensatore #mi("C_{\\text{IN}} = 7.3\\,\\text{pF}") fissa un bassissimo pavimento di rumore #mi("kT/C") sugli switch del multiplexer.
+ #strong[Loop Digitale di Calibrazione dell'Offset DC d'Elettrodo (#mi("\\pm 50\\,\\text{mV}") EDO):]
In un sistema TDM, l'offset elettrochimico tra elettrodi diversi (#mi("\\pm 50\\,\\text{mV}")) si presenta come un'onda a gradini a #mi("333\\,\\text{kHz}") che saturerebbe l'LNA. Ogni #mi("4.8\\,\\text{s}") (per #mi("0.96\\,\\text{ms}")), il transconduttore #mi("G_m") viene commutato in modalità a bassa transconduttanza (#strong[#mi("g_m = G_m / 100")]) e tutti i 32 condensatori #mi("C_{\\text{INT}}") vengono connessi in parallelo, aumentando la costante di tempo #mi("\\tau = C_{\\text{eff}} / g_m") di un fattore #strong[#mi("\\sim 3200\\times")] per isolare il puro offset DC. L'ASC converte questa deriva in impulsi UP/DN accumulati da un #strong[Dual-Counter] a 6-bit che pilota un #strong[C-DAC capacitivo a 6-bit (#mi("C_{\\text{EDO}}"))] in retroazione negativa all'ingresso dell'LNA, riducendo l'errore di quantizzazione a #mi("\\le 0.78\\,\\text{mV}") (residuo di caso peggiore #mi("<16.4\\,\\text{mV}"), ben entro il margine di saturazione di #mi("\\pm 25\\,\\text{mV}") a #mi("58.3\\,\\text{dB}")).

#figure(image("figure/fig26_neuroseed_lna_and_gmc_integrator.png", width: 88%), caption: [Schemi circuitali dell'LNA current-reuse, integratore Gm-C WIS, ASC e Spike Detector di NeuroSEED])
#emph[Figura 26 — Estratta da Wu et al. (2026), Fig. 6 e Fig. 7: (In alto) Schematico a livello transistor del core LNA inverter-based current-reuse e del relativo circuito CMFB. (In basso) Stadio integratore charge-sampling #mi("G_m\\text{-}C") con transconduttore dual-mode (#mi("g_m = G_m/100")), risposta in frequenza sinc con notch a #mi("f_{\\text{CHOP}}") e diagramma temporale.]

=== C. Convertitore Analogico-Spike (ASC), Rilevatore di Spike Clockless Valley-to-Peak e Telemetria IR-UWB
Come illustrato nelle #strong[Figure 27 e 28], ciascuno dei 32 canali demultiplexati comprende:
+ #strong[ASC (\*Analog-to-Spike Converter\*, #mi("0.164\\,\\mu\\text{W/ch}")):] Composto da un DAC capacitivo di #emph[signal folding] a 1-bit con condensatori accoppiati #strong[#mi("C_1 = C_2 = 6\\,\\text{pF}")] e switch NMOS (#mi("W/L = 440\\,\\text{nm}/220\\,\\text{nm}")), due comparatori asincroni a 3 stadi con transistor #emph[low-#mi("V_t")] alimentati a #mi("0.6\\,\\text{V}") e un #strong[circuito refrattario bio-ispirato] (stadio PMOS con carico NMOS regolabile da #mi("V_{\\text{Refra}}") su #mi("C_L")). Per soddisfare una risoluzione equivalente di #mi("M = 6\\,\\text{bit}") a #mi("f_{\\text{IN}} = 10\\,\\text{kHz}"), il ritardo di propagazione del loop è mantenuto a #mi("T_{\\min} < 498\\,\\text{ns}"). Durante la fase di folding, il circuito refrattario applica un #strong[power-gating aggressivo ai comparatori], azzerandone il consumo statico. L'ASC raggiunge un #strong[SNDR di picco di #mi("47.2\\,\\text{dB}") (#mi("\\text{ENOB} = 7.6\\,\\text{bit}"))] a #mi("500\\,\\text{Hz}") e una compressione dati #strong[#mi(">100\\times")].
+ #strong[Clockless Spike Detector (\*Integrate-and-Fire Valley-to-Peak\*, #mi("0.48\\,\\mu\\text{W/ch}"), #mi("0.0007\\,\\text{mm}^2/\\text{ch}")):] Opera senza alcun clock esterno sugli impulsi #raw("UP")/#raw("DN") dell'ASC. Un rivelatore di picchi e valli a flip-flop D (#strong[Figura 28d]) individua un minimo locale (#emph[Valley]), abilitando un contatore digitale che integra gli impulsi #raw("UP") successivi. Se l'escursione relativa valle-picco supera la soglia programmabile #raw("UP_threshold") prima del reset al picco (#emph[Peak]), il neurone digitale #emph[Integrate-and-Fire] dichiara uno #strong[Spike Rilevato (\*Fire\*)], portando la compressione dati totale a #strong[#mi(">500\\times")] ed eliminando qualsiasi sensibilità al #emph[baseline wander] o all'offset residuo (validato su registrazioni #emph[in-vivo] da radice dorsale L5 di ratto).
+ #strong[Trasmettitore Wireless Event-Triggered IR-UWB (]Figura 29#strong[, a sinistra, #mi("4.6\\,\\mu\\text{W}") totali):] Rimane spento in #emph[deep sleep] e viene attivato in modalità OOK solo quando viene rilevato uno spike: un #emph[Impulse Generator] (edge-combiner) genera un impulso di abilitazione #raw("En") di soli #strong[#mi("3.2\\,\\text{ns}")] che accende un oscillatore LC complementare #emph[current-reuse] a #strong[#mi("4.25\\,\\text{GHz}")] (banda #mi("510\\,\\text{MHz}")) e un #emph[Digital Power Amplifier] (DPA) inverter-based (#mi("110\\,\\text{mV}_{\\text{pp}}") su #mi("50\\,\\Omega"), #mi("\\text{PSD} = -42.05\\,\\text{dBm/MHz}") conforme alla maschera FCC, #mi("\\text{BER} = 10^{\\text{-3}}") a #mi("100\\,\\text{Mbps}") attraverso #mi("1.5\\,\\text{cm}") di tessuto cranico + #mi("3\\,\\text{cm}") in aria).

#figure(image("figure/fig27_neuroseed_asc_and_spike_detector_topologies.png", width: 88%), caption: [Topologie e schemi circuitali dell'ASC e dello Spike Detector clockless di NeuroSEED])
#emph[Figura 27 — Estratta da Wu et al. (2026), Fig. 8 e Fig. 9: Processo di compressione event-driven (#mi(">100\\times") dopo ASC, #mi(">500\\times") dopo Spike Detection) e schemi a blocchi dell'ASC core (Signal Folding, comparatori #mi("V_H/V_L"), circuito refrattario bio-ispirato) e dello Spike Detector clockless Valley-to-Peak.]

#figure(image("figure/fig28_neuroseed_asc_folding_comp_refractory_circuits.png", width: 88%), caption: [Schemi transistor-level dei blocchi ASC e Spike Detector di NeuroSEED])
#emph[Figura 28 — Estratta da Wu et al. (2026), Fig. 10: Schemi circuitali di: (a) circuito di signal folding SC-DAC a 1-bit (#mi("C_1, C_2 = 6\\,\\text{pF}")), (b) comparatore asincrono a 3 stadi con power-gating, (c) circuito refrattario riconfigurabile (#mi("V_{\\text{Refra}}, C_L")), (d) rivelatore digitale asincrono di picco e valle.]

#figure(image("figure/fig29_neuroseed_uwb_die_power_area_breakdown.png", width: 88%), caption: [Trasmettitore IR-UWB, micrografia del die NeuroSEED e grafici a torta di potenza e area])
#emph[Figura 29 — Estratta da Wu et al. (2026), Fig. 11, 12 e 13: (A sinistra) Architettura e schemi transistor-level del trasmettitore wireless IR-UWB (Impulse Generator da 3.2 ns, oscillatore LC current-reuse e DPA). (In alto a destra) Micrografia del chip in TSMC 40 nm CMOS (#mi("857\\times 820\\,\\mu\\text{m}")) e riepilogo prestazioni. (In basso a destra) Ripartizione percentuale della potenza totale (#mi("63.61\\,\\mu\\text{W}"), #mi("1.99\\,\\mu\\text{W/ch}")) e dell'area attiva (#mi("0.16\\,\\text{mm}^2")) tra AFE, ASC, Spike Detector e UWB TX.]


#line(length: 100%, stroke: 0.5pt + luma(200))

= Capitolo 4 — Implementazioni Circuitali CMOS di Neuroni e Sinapsi Spiking

Questo capitolo risponde in modo sistematico e analitico alla seconda domanda fondamentale della consegna: #strong[#emph[Come si realizza fisicamente un neurone spiking (e una rete sinaptica) in tecnologia CMOS? Quali sono i blocchi circuitali fondamentali, le equazioni fisiche a livello transistor e le architetture proposte nella letteratura?]]

#line(length: 100%, stroke: 0.5pt + luma(200))

== 4.1 Fisica del MOSFET in Sottosoglia (#emph[Weak Inversion]), Principio Translineare e Filtri #emph[Log-Domain] (Tau-Cell, LPF, DPI)

=== A. Il MOSFET in Regime di Inversione Debole (#emph[Sub-threshold / Weak Inversion])
L'intuizione fondante dell'ingegneria neuromorfica analogica (Mead, 1989; Indiveri et al., 2011) risiede nell'omologia fisica diretta tra il trasporto ionico attraverso le membrane biologiche e il trasporto elettronico in un transistor MOSFET polarizzato in #strong[inversione debole (sottosoglia)], ovvero con tensione gate-source inferiore alla tensione di soglia (#mi("V_{\\text{GS}} < V_T")):

- #strong[Trasporto per Diffusione vs Deriva (\*Drift\*):] Mentre sopra soglia (#mi("V_{\\text{GS}} > V_T"), #emph[strong inversion]) si forma un canale conduttivo continuo e la corrente è dominata dal moto di #strong[deriva (\*drift\*)] sotto l'azione del campo elettrico longitudinale (con legge quadratica/lineare rispetto a #mi("V_{\\text{GS}} - V_T")), in sottosoglia la concentrazione di portatori mobili nel canale è bassissima e il flusso di corrente dalla sorgente (#emph[source]) al pozzo (#emph[drain]) è governato dalla #strong[diffusione termodinamica di Boltzmann] attraverso una barriera di potenziale energetico controllata elettrostaticamente dal gate — esattamente come gli ioni #mi("\\text{Na}^+, \\text{K}^+, \\text{Ca}^{2+}") diffondono attraverso i canali proteici voltaggio-dipendenti della membrana neuronale.
- #strong[Equazione Fondamentale del MOSFET in Sottosoglia:]
Per un transistor nMOS riferito al substrato (bulk), la corrente di drain #mi("I_D") in regime di sottosoglia vale:
#mitex("I_D = I_0 \\exp\\left(\\frac{\\kappa V_G - V_S}{U_T}\\right) \\left[ 1 - \\exp\\left(-\\frac{V_D - V_S}{U_T}\\right) \\right]")
dove:
- #strong[#mi("U_T = \\dfrac{k_B T}{q} \\approx 25.8\\,\\text{mV}")] (a #mi("T = 300\\,\\text{K}")) è la #strong[tensione termica] (#mi("k_B") costante di Boltzmann, #mi("q") carica elementare);
- #strong[#mi("\\kappa = \\dfrac{C_{\\text{ox}}}{C_{\\text{ox}} + C_{\\text{dep}}} \\in [0.6,\\, 0.8]")] è il #strong[fattore di pendenza sottosoglia (\*subthreshold slope factor\*)], che misura l'efficacia dell'accoppiamento capacitivo tra il gate e il potenziale superficiale del canale rispetto alla capacità di svuotamento #mi("C_{\\text{dep}}");
- #strong[#mi("I_0 = \\mu C_{\\text{ox}} \\dfrac{W}{L} (\\kappa - 1) U_T^2 \\exp\\left(-\\dfrac{\\kappa V_{\\text{T0}}}{U_T}\\right)")] è la corrente di zero-bias (#emph[off-current] o #emph[dark current]), dell'ordine dei #mi("\\text{fA}\\text{-}\\text{pA}").
- #strong[Condizione di Saturazione in Sottosoglia:]
Non appena la tensione drain-source supera appena #strong[4 volte la tensione termica] (#mi("V_{\\text{DS}} = V_D - V_S > 4 U_T \\approx 100\\,\\text{mV}")), il termine #mi("\\exp(-V_{\\text{DS}}/U_T)") diventa #mi("< 0.018 \\ll 1") e il transistor entra in #strong[saturazione], comportandosi come un generatore di corrente ideale controllato esponenzialmente da #mi("V_G") e #mi("V_S"):
#mitex("I_D = I_0 \\exp\\left(\\frac{\\kappa V_G - V_S}{U_T}\\right) = I_0 \\exp\\left(\\frac{\\kappa V_{\\text{GS}} + (\\kappa - 1)V_{\\text{BS}}}{U_T}\\right)")
#emph[(Questa proprietà spiega perché il chip #strong[NET-TEN] riesce a funzionare perfettamente con un'alimentazione totale di appena #strong[#mi("V_{\\text{DD}} = 250\\,\\text{mV}")]!).]
- #strong[Massima Efficienza di Transconduttanza (#mi("g_m / I_D")) e Costanti di Tempo Biologiche:]
Derivando #mi("I_D") rispetto a #mi("V_G"), la transconduttanza in sottosoglia è lineare con la corrente di polarizzazione:
#mitex("g_m = \\frac{∂ I_D}{∂ V_G} = \\frac{\\kappa I_D}{U_T} \\implies \\frac{g_m}{I_D} = \\frac{\\kappa}{U_T} \\approx 26\\text{-}30\\,\\text{V}^{\\text{-1}}")
Operando con correnti comprese tra #strong[#mi("100\\,\\text{fA}") e #mi("10\\,\\text{nA}")], la conduttanza equivalente #mi("g_m") risulta estremamente piccola (#mi("10^{\\text{-12}}\\text{-}10^{\\text{-7}}\\,\\text{S}"), corrispondente a resistenze di #mi("10\\,\\text{M}\\Omega\\text{-}1\\,\\text{T}\\Omega")). Di conseguenza, accoppiando tali transistor a piccoli condensatori integrati su silicio (#strong[#mi("C \\approx 100\\,\\text{fF} \\text{ - } 1\\,\\text{pF}")]), si ottengono direttamente #strong[costanti di tempo fisiche #mi("\\tau = \\frac{C}{g_m} = \\frac{C U_T}{\\kappa I_D}") comprese tra #mi("0.1\\,\\text{ms}") e #mi("1\\,\\text{s}")], identiche a quelle dei neuroni e dei recettori sinaptici biologici (AMPA, NMDA, #mi("\\text{GABA}_A"), #mi("\\text{GABA}_B")) senza ricorrere ad alcun clock digitale!

#line(length: 100%, stroke: 0.5pt + luma(200))

=== B. Il Principio Translineare e i Tre Filtri #emph[Log-Domain] di Conduttanza Sinaptica e Membrana
La dinamica temporale del primo ordine di una conduttanza sinaptica o di una membrana passiva (Destexhe et al., 1998; Indiveri et al., 2011, Sez. 3.1) è espressa dall'equazione differenziale lineare:

#mitex("\\tau \\frac{dy}{dt} = -y + x")

Nei circuiti #strong[current-mode log-domain] (Frey, 1993; Tomazou et al., 1990), la variabile di stato fisica #mi("y") è rappresentata da una #strong[corrente in sottosoglia] #mi("I_{\\text{syn}}") (o #mi("I_{\\text{mem}}")), mentre la tensione #mi("V_{\\text{syn}}") sul nodo capacitivo #mi("C_{\\text{syn}}") è una compressione logaritmica della corrente (#mi("V_{\\text{syn}} \\propto \\frac{U_T}{\\kappa} \\ln(I_{\\text{syn}}/I_0)")). Sfruttando il #strong[principio translineare di Gilbert (1975)] (secondo cui lungo un anello chiuso di giunzioni esponenziali la somma delle tensioni gate-source in senso orario uguaglia quella in senso antiorario, il che equivale all'uguaglianza dei prodotti delle correnti nei rami pari e dispari), un'equazione differenziale non lineare nella tensione #mi("V_{\\text{syn}}") su #mi("C_{\\text{syn}}") si trasforma esattamente in un'equazione differenziale #strong[lineare nella corrente di uscita #mi("I_{\\text{syn}}")].

#figure(image("figure/fig01_taucell_lpf_dpi.png", width: 88%), caption: [Schemi circuitali dei tre filtri passa-basso log-domain: Tau-cell, LPF sottosoglia e DPI])
#emph[Figura 1 — Estratta da Indiveri et al. (2011), Fig. 1: Confronto tra i tre circuiti log-domain passa-basso (LPF) del primo ordine per l'integrazione temporale di impulsi di tensione (spike): (A) Circuito "Tau-Cell"; (B) Filtro LPF del primo ordine in sottosoglia (Arthur & Boahen); (C) Circuito "DPI" (Differential Pair Integrator, Bartolozzi & Indiveri, 2007).]

Come illustrato in #strong[Figura 1], l'evoluzione di questi integratori comprende tre topologie:

+ #strong[Circuito \*Tau-Cell\* (Figura 1A — Edwards & Cauwenberghs, 2000; van Schaik & Jin, 2003):]
Utilizza un anello translineare completo con tensione di riferimento #mi("V_{\\text{ref}}") e generatori di corrente #mi("I_0") e #mi("2I_0") che fissano la costante di tempo #mi("\\tau") sulla capacità #mi("C_{\\text{syn}}"), mentre l'impulso pre-sinaptico #mi("V_{\\text{in}}") modula una corrente #mi("I_w") (controllata da #mi("V_w")) per generare la corrente post-sinaptica #mi("I_{\\text{syn}}").
+ #strong[Filtro LPF Sottosoglia Semplificato (Figura 1B — Arthur & Boahen, 2004, 2007):]
Riduce il circuito a 4 transistor e una capacità #mi("C_{\\text{syn}}") riferita a #mi("V_{\\text{dd}}"). All'arrivo di uno spike negativo su #mi("V_{\\text{in}}"), il ramo di ingresso estrae da #mi("C_{\\text{syn}}") una corrente di peso #mi("I_w") (fissata dal bias #mi("V_w")), abbassando la tensione sul condensatore e facendo crescere esponenzialmente la corrente di uscita #mi("I_{\\text{syn}}") del pFET di destra. Al termine dello spike, il transistor di leak polarizzato da #mi("V_\\tau") (corrente #mi("I_\\tau")) ricarica linearmente #mi("C_{\\text{syn}}") verso #mi("V_{\\text{dd}}"), producendo un decadimento esponenziale di #mi("I_{\\text{syn}}") nel tempo. Tuttavia, in questa topologia l'ampiezza massima raggiungibile da #mi("I_{\\text{syn}}") dipende simultaneamente sia da #mi("V_w") sia da #mi("V_\\tau").
+ #strong[Il Circuito DPI (\*Differential Pair Integrator\*, Figura 1C — Bartolozzi & Indiveri, 2007):]
Sostituisce il singolo transistor di iniezione con una #strong[coppia differenziale nMOS operante in configurazione di retroazione negativa]: un ramo della coppia differenziale ha il gate polarizzato da una tensione di soglia accordabile #strong[#mi("V_{\\text{thr}}")], mentre l'altro ramo ha il gate collegato al nodo capacitivo #mi("V_{\\text{syn}}") (e il drain collegato anch'esso a #mi("C_{\\text{syn}}")). La corrente di coda (#emph[tail current]) della coppia è pari a #mi("I_w = I_0 e^{\\kappa V_w / U_T}") durante lo spike #mi("V_{\\text{in}}").
- #strong[Derivazione Analitica dell'Equazione del DPI:]
Detta #mi("V_{\\text{syn}}") la tensione sul condensatore #mi("C_{\\text{syn}}"), la corrente di uscita del pMOS di lettura (col source a #mi("V_{\\text{dd}}")) vale:
#mitex("I_{\\text{syn}} = I_0 \\exp\\left(\\frac{\\kappa (V_{\\text{dd}} - V_{\\text{syn}})}{U_T}\\right) \\implies \\frac{dI_{\\text{syn}}}{dt} = -\\frac{\\kappa I_{\\text{syn}}}{U_T} \\frac{dV_{\\text{syn}}}{dt}")
Per la legge di Kirchhoff sul condensatore #mi("C_{\\text{syn}}"), si ha #mi("C_{\\text{syn}} \\frac{dV_{\\text{syn}}}{dt} = I_\\tau - I_{\\text{dp}}"), dove #mi("I_\\tau") è la corrente di carica di leak e #mi("I_{\\text{dp}}") è la corrente del ramo destro della coppia differenziale:
#mitex("I_{\\text{dp}} = \\frac{I_w}{1 + \\exp\\left(\\frac{\\kappa (V_{\\text{syn}} - V_{\\text{thr}})}{U_T}\\right)} = \\frac{I_w}{1 + \\frac{I_{\\text{thr}}}{I_{\\text{syn}}}}, \\qquad \\text{con } I_{\\text{thr}} \\triangleq I_0 \\exp\\left(\\frac{\\kappa (V_{\\text{dd}} - V_{\\text{thr}})}{U_T}\\right)")
Sostituendo #mi("\\frac{dV_{\\text{syn}}}{dt}") nell'espressione di #mi("\\frac{dI_{\\text{syn}}}{dt}") e definendo la costante di tempo #strong[#mi("\\tau \\triangleq \\dfrac{C_{\\text{syn}} U_T}{\\kappa I_\\tau}")], si ottiene l'equazione esatta del circuito DPI:
#mitex("\\tau \\frac{dI_{\\text{syn}}}{dt} + I_{\\text{syn}} = \\frac{I_w \\, I_{\\text{syn}}}{I_\\tau \\left(1 + \\frac{I_{\\text{thr}}}{I_{\\text{syn}}}\\right)}")
Nel regime operativo lineare in cui #mi("I_{\\text{syn}} \\ll I_{\\text{thr}}") (oppure #mi("I_{\\text{syn}} \\gg I_{\\text{thr}}") con guadagno virtuale #mi("I_{\\text{thr}}/I_\\tau")), l'equazione si riduce a un #strong[filtro passa-basso lineare del primo ordine nel dominio delle correnti] il cui guadagno di trasferimento può essere modulato indipendentemente dalla costante di tempo #mi("\\tau") tramite il terzo parametro di controllo #strong[#mi("V_{\\text{thr}}")] (utilizzato per l'omeostasi sinaptica e la plasticità intrinseca).

#line(length: 100%, stroke: 0.5pt + luma(200))

== 4.2 I Blocchi Funzionali del Neurone al Silicio e Analisi Transistor-per-Transistor delle Topologie in Letteratura #emph[(Indiveri et al., 2011 — Paper 1)]

Come sintetizzato nella Tabella 1 di #emph[Indiveri et al. (2011)], qualsiasi neurone spiking integrato su silicio (#emph[Silicon Neuron], #strong[SiN]) è scomponibile in #strong[quattro blocchi computazionali fondamentali]:
+ #strong[Stadio di Integrazione Temporale e Conduttanza di Ingresso (\*Conductance / Input Stage\*):] Converte le correnti sinaptiche nella variabile di stato di membrana (#mi("V_{\\text{mem}}") o #mi("I_{\\text{mem}}")) introducendo una perdita (#emph[leak]).
+ #strong[Stadio di Generazione dello Spike e Retroazione Positiva (\*Spike-Event Generation & Positive Feedback\*):] Rileva il superamento della soglia e innesca un #emph[run-away] rigenerativo (analogo all'apertura dei canali #mi("\\text{Na}^+")) che commuta rapidamente l'uscita digitale per il bus AER.
+ #strong[Stadio di Reset e Periodo Refrattario (\*Refractory Period & Reset Mechanism\*):] Emula l'apertura ritardata dei canali #mi("\\text{K}^+") scaricando la membrana a #mi("V_{\\text{reset}}") e bloccandola per un tempo #mi("T_R") regolabile (tipicamente tramite #emph[starved inverters] e una capacità #mi("C_R") o #mi("C_K")).
+ #strong[Stadio di Adattamento della Frequenza di Sparo (\*Spike-Frequency Adaptation\*, SFA, o Soglia Adattativa):] Introduce una seconda variabile di stato lenta (#mi("I_g"), #mi("U") o #mi("\\Theta")) che riduce la frequenza di firing durante una stimolazione prolungata.

Analizziamo ora nel dettaglio #strong[transistor-per-transistor] ciascuna delle architetture circuitali fondamentali presentate in #emph[Indiveri et al. (2011)].

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.1 Circuito #emph[Axon-Hillock] #emph[(Mead, 1989 — Figura 2)]

#figure(image("figure/fig02_axon_hillock.png", width: 88%), caption: [Schema elettrico e forme d'onda del circuito Axon-Hillock e del neurone Voltage-Amplifier I&F])
#emph[Figura 2 — Estratta da Indiveri et al. (2011), Fig. 3: Circuito Axon-Hillock (Mead, 1989). (A) Schema elettrico con capacità di membrana #mi("C_{\\text{mem}}"), amplificatore non invertente #mi("A") (due inverter CMOS in cascata), capacità di retroazione positiva #mi("C_{\\text{fb}}") e ramo nMOS di reset con corrente #mi("I_r(V_{\\text{pw}})"). (B) Tracce temporali di #mi("V_{\\text{mem}}") (verde) e #mi("V_{\\text{out}}") (rosso).]

Il circuito #strong[Axon-Hillock] (#strong[Figura 2]) è il capostipite storico dei neuroni neuromorfici:
- #strong[Ruolo dei Componenti:]
- #strong[#mi("C_{\\text{mem}}"):] Capacità di membrana che integra la corrente d'ingresso #mi("I_{\\text{in}}").
- #strong[Blocco #mi("A"):] Doppio inverter CMOS in cascata (amplificatore ad alto guadagno non invertente) con tensione di soglia di commutazione #mi("V_{\\text{inv}}").
- #strong[#mi("C_{\\text{fb}}"):] Capacità di feedback positivo collegata tra l'uscita #mi("V_{\\text{out}}") e il nodo #mi("V_{\\text{mem}}"), che forma un partitore capacitivo con #mi("C_{\\text{mem}}").
- #strong[ due transistor nMOS in serie sul ramo di scarica (#mi("I_r")):] Il transistor superiore funge da interruttore abilitato da #mi("V_{\\text{out}}"), mentre il transistor inferiore (polarizzato in sottosoglia dal bias #strong[#mi("V_{\\text{pw}}")]) fissa la corrente di reset #mi("I_r") che controlla la durata dell'impulso (#emph[pulse width], #mi("t_H")).
- #strong[Funzionamento fisico nel tempo:]
+ Inizialmente #mi("V_{\\text{out}} = 0\\,\\text{V}") e lo switch di reset è spento. La corrente #mi("I_{\\text{in}}") carica linearmente la capacità totale vista al nodo di membrana: #mi("V_{\\text{mem}}(t)") sale con pendenza #mi("\\frac{I_{\\text{in}}}{C_{\\text{mem}} + C_{\\text{fb}}}").
+ Quando #mi("V_{\\text{mem}}") raggiunge la soglia di commutazione #mi("V_{\\text{inv}}") del primo inverter, #mi("V_{\\text{out}}") sale verso #mi("V_{\\text{dd}}"). Tramite l'accoppiamento capacitivo #mi("C_{\\text{fb}}"), l'innalzamento di #mi("V_{\\text{out}}") viene retroazionato positivamente su #mi("V_{\\text{mem}}"), producendo un salto istantaneo di tensione verso l'alto:
#mitex("\\Delta V_{\\text{mem}} = \\frac{C_{\\text{fb}}}{C_{\\text{mem}} + C_{\\text{fb}}} V_{\\text{dd}}")
+ Con #mi("V_{\\text{out}} = V_{\\text{dd}}"), lo switch nMOS di reset si accende e sottrae la corrente #mi("I_r") (con #mi("I_r > I_{\\text{in}}")). #mi("V_{\\text{mem}}") scende linearmente per un tempo #mi("t_H \\approx \\frac{C_{\\text{fb}} V_{\\text{dd}}}{I_r - I_{\\text{in}}}") finché ritorna a #mi("V_{\\text{inv}}").
+ A questo punto l'amplificatore #mi("A") commuta a #mi("0\\,\\text{V}") e il partitore capacitivo abbassa istantaneamente #mi("V_{\\text{mem}}") di #mi("-\\Delta V_{\\text{mem}}") al valore di reset #mi("V_{\\text{inv}} - \\Delta V_{\\text{mem}}"), dando inizio all'intervallo inter-spike #mi("t_L \\approx \\frac{C_{\\text{fb}} V_{\\text{dd}}}{I_{\\text{in}}}").
- #strong[Pregi e Difetti:] Poiché l'ampiezza del ciclo di isteresi #mi("\\Delta V_{\\text{mem}}") dipende dal #strong[rapporto tra due capacità (#mi("C_{\\text{fb}}/C_{\\text{mem}}"))] anziché dai parametri dei transistor, il circuito gode di un #strong[eccellente matching tra neuroni diversi]. Tuttavia, quando #mi("I_{\\text{in}}") è molto piccola, #mi("V_{\\text{mem}}") attraversa lentamente la regione di soglia #mi("V_{\\text{inv}}") mantenendo entrambi i transistor pMOS e nMOS del primo inverter contemporaneamente accesi, causando una #strong[forte dissipazione di potenza statica/di corto circuito (#mi("\\sim \\mu\\text{W}"))].

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.2 Neurone I&F a Comparatore di Tensione e #emph[Starved Inverters] #emph[(van Schaik, 2001 — Figura 3)]

#figure(image("figure/fig03_voltage_amp_if.png", width: 88%), caption: [Schema elettrico e traccia temporale del neurone Voltage-Amplifier I&F di van Schaik])
#emph[Figura 3 — Estratta da Indiveri et al. (2011), Fig. 4: Neurone I&F basato su amplificatore di tensione (van Schaik, 2001). (A) Schema elettrico con leak #mi("M_1(V_{\\text{lk}})"), comparatore OTA a 5 transistor (#mi("V_{\\text{thr}}, I_{\\text{amp}}")), correnti #mi("I_{\\text{Na}}") (#mi("M_3")) e #mi("I_{\\text{K}}") (#mi("M_2")) e due starved inverters (#mi("M_4, M_5")) con capacità del potassio #mi("C_K"). (B) Fasi dell'azione potenziale: Integration, Up-swing, Spike width, Down-swing e Refractory period.]

Per ottenere un controllo esplicito e indipendente della soglia di sparo #mi("V_{\\text{thr}}"), della larghezza dello spike e del periodo refrattario, #strong[van Schaik (2001)] ha proposto il circuito di #strong[Figura 3]:
- #strong[#mi("M_1") (nMOS, gate a #mi("V_{\\text{lk}}")):] Implementa la conduttanza passiva di leak in parallelo a #mi("C_{\\text{mem}}").
- #strong[Comparatore (OTA a 5 transistor polarizzato da #mi("I_{\\text{amp}}")):] Confronta direttamente #mi("V_{\\text{mem}}") (ingresso #mi("+")) con una tensione di soglia regolabile esternamente #strong[#mi("V_{\\text{thr}}")] (ingresso #mi("-")).
- #strong[Generazione dell'Upswing (#mi("\\text{Na}^+")) tramite Primo Inverter (#mi("M_4, M_5") limitato da #mi("I_{\\text{lp}}")) e #mi("M_3"):] Quando #mi("V_{\\text{mem}} > V_{\\text{thr}}"), l'uscita dell'OTA sale a #mi("V_{\\text{dd}}") e l'uscita del primo inverter scende a #mi("0\\,\\text{V}"), accendendo lo switch pMOS #strong[#mi("M_3")] che inietta la forte #strong[corrente di Sodio #mi("I_{\\text{Na}}")] su #mi("C_{\\text{mem}}"), generando il fronte di salita rapido (#emph[Up-swing]).
- #strong[Controllo dello \*Spike Width\* e del Periodo Refrattario (#mi("\\text{K}^+")) tramite Secondo \*Starved Inverter\*, #mi("C_K") e #mi("M_2"):]
Contemporaneamente, l'uscita bassa del primo inverter pilota un secondo #emph[starved inverter] (#mi("M_5") pMOS limitato dalla corrente #strong[#mi("I_{\\text{Kup}}")], #mi("M_4") nMOS limitato dalla corrente #strong[#mi("I_{\\text{Kdn}}")]) che carica la capacità del potassio #strong[#mi("C_K")] con rampa proporzionale a #mi("I_{\\text{Kup}}"):
- Il tempo impiegato dalla tensione su #mi("C_K") per raggiungere la soglia di accensione dell'nMOS #strong[#mi("M_2")] è inversamente proporzionale a #strong[#mi("I_{\\text{Kup}}")], che quindi #strong[governa direttamente lo \*Spike Width]\*.
- Una volta acceso #strong[#mi("M_2")], la #strong[corrente di Potassio #mi("I_{\\text{K}}")] scarica rapidamente #mi("C_{\\text{mem}}") sotto #mi("V_{\\text{thr}}") (#emph[Down-swing]).
- Non appena #mi("V_{\\text{mem}} < V_{\\text{thr}}"), l'OTA commuta, #mi("M_3") (#mi("I_{\\text{Na}}")) si spegne e il secondo #emph[starved inverter] inizia a scaricare lentamente #mi("C_K") attraverso la piccola corrente #strong[#mi("I_{\\text{Kdn}}")]: finché la tensione su #mi("C_K") mantiene acceso #mi("M_2"), il neurone non può essere eccitato da correnti #mi("I_{\\text{in}} < I_{\\text{K}}"). Pertanto #strong[#mi("I_{\\text{Kdn}}") controlla indipendentemente il periodo refrattario].

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.3 Neuroni Basati su Conduttanza (#emph[Conductance-Based]): Talamico, H–H Translineare, H–H BiCMOS SiGe e Accelerato #mi("\\times 10^4")

#emph[Indiveri et al. (2011)] analizzano quattro implementazioni di modelli biofisici basati su conduttanza:
+ #strong[Neurone Talamico di Relè a Due Compartimenti (Hynna & Boahen, 2009 — Fig. 8 di Paper 1):] Utilizza il circuito termodinamico a 2 transistor (#mi("M_1, M_2") di Fig. 2A di Paper 1) per implementare il canale del Calcio a bassa soglia (#mi("I_T")) in un compartimento dendritico connesso tramite un diodo pMOS (#mi("M_2")) a un compartimento somatico #emph[Axon-Hillock], riproducendo sia il firing #emph[tonico] sia il #emph[bursting] da rimbalzo post-inibitorio.
+ #strong[Neurone Hodgkin–Huxley Sottosoglia Translineare (Yu & Cauwenberghs, 2010a — Fig. 9 di Paper 1):] Implementa 4 neuroni H–H e 12 sinapsi usando filtri #emph[Tau-Cell] per le cinetiche di #mi("m, h, n"), profili sigmoidali programmabili su spline a 7 punti tramite DAC on-chip, e moltiplicatori translineari in corrente a cascata per calcolare esattamente i prodotti #mi("m^3 h \\bar{g}_{\\text{Na}}") e #mi("n^4 \\bar{g}_{\\text{K}}").
+ #strong[Neurone Hodgkin–Huxley Sopra Soglia in SiGe BiCMOS (Renaud et al., 2007; Saighi et al., 2011 — Fig. 15 di Paper 1):] Realizzato in processo BiCMOS SiGe #mi("0.35\\,\\mu\\text{m}") e #mi("0.8\\,\\mu\\text{m}") con coppie differenziali bipolari BJT (#mi("Q_1\\text{-}Q_4, Q_{\\text{11}}\\text{-}Q_{\\text{12}}")) in #emph[voltage-mode] per l'interfacciamento #emph[real-time] diretto con neuroni biologici in #emph[patch-clamp dinamico].
+ #strong[Neurone a Conduttanza Controllata in Corrente a Tempo Accelerato (#mi("\\times 10^4\\text{-}10^5"), Schemmel et al., 2006 — Figura 8):]

#figure(image("figure/fig08_conductance_accelerated_neuron.png", width: 88%), caption: [Neurone a conduttanza controllata in corrente a tempo accelerato di Schemmel et al.])
#emph[Figura 8 — Estratta da Indiveri et al. (2011), Fig. 17: Neurone a conduttanza a tempo accelerato (#mi("\\times 10^4"), Schemmel et al., 2006) parte di un chip da 100k sinapsi. (A) Schema elettrico con specchi di corrente pMOS, cascode nMOS #mi("M_3, M_6, M_9"), amplificatori OTA1 (leak verso #mi("E_{\\text{leak}}")) e OTA2 (inibizione verso #mi("E_{\\text{inhib}}")), specchio veloce #mi("M_7\\text{-}M_8") per l'eccitazione (#mi("E_{\\text{exc}}")) e comparatore di spike con switch di reset #mi("M_{\\text{10}}") (#mi("E_{\\text{reset}}")). (B) Confronto tra la traccia misurata sul chip (#mi("10\\,\\mu\\text{s/div}")) e la simulazione numerica sul simulatore software NEST (#mi("100\\,\\text{ms/div}")).]

Come mostrato in #strong[Figura 8], questo circuito opera in #strong[forte inversione (\*strong inversion\*)] comprimendo il tempo biologico di un fattore #strong[#mi("10^4\\text{-}10^5")] (#mi("1\\,\\text{ms}") biologico #mi("\\to 10\\,\\text{ns}") su silicio): i nodi di somma delle correnti sinaptiche (#mi("I_{\\text{leak}}, I_{\\text{inhib}}, I_{\\text{exc}}")) sono mantenuti a bassa impedenza dai transistor cascode #mi("M_3, M_6, M_9") (polarizzati da #mi("V_c")). Le conduttanze di leak e inibitoria sono realizzate da due amplificatori a transconduttanza (#raw("OTA1") e #raw("OTA2")) verso i potenziali di inversione #mi("E_{\\text{leak}}") ed #mi("E_{\\text{inhib}}"), mentre la conduttanza eccitatoria (che deve rispondere con #emph[rise-time] #mi("<10\\,\\text{ns}") erogando fino a #mi("10\\,\\mu\\text{A}") per sinapsi) evita l'uso di un OTA impiegando direttamente uno specchio di corrente veloce a canale minimo #strong[#mi("M_7\\text{-}M_8")] col source collegato a #mi("E_{\\text{exc}}").

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.4 Neuroni I&F Compatti a Basso Consumo (#emph[Octopus Retina] e #emph[DVS Differencing Neuron])

Per abbattere la corrente di corto circuito del circuito #emph[Axon-Hillock] durante l'attraversamento lento della soglia:
- #strong[L'\*Octopus Retina Neuron\* (Culurciello et al., 2003 — Fig. 10 di Paper 1)] introduce due innovazioni fondamentali riprese poi nel neurone DPI e in ROLLS: (1) usa #strong[retroazione positiva in corrente] (specchi di corrente pMOS/nMOS che riutilizzano la corrente di corto circuito del primo inverter per iniettarla in #mi("C_{\\text{mem}}"), accelerando di #mi("\\sim 100\\times") la transizione a soglia); (2) durante la generazione dello spike #strong[disconnette temporaneamente #mi("C_{\\text{mem}}")] dall'ingresso dell'inverter, riducendo la potenza durante lo spike di #mi("\\sim 25\\times") e raggiungendo un'energia per spike #strong[#mi("< 4\\,\\text{pJ/spike}")] in tecnologia CMOS #mi("0.6\\,\\mu\\text{m}").
- #strong[Il Neurone Differenziatore ON–OFF del Sensore Visivo Dinamico DVS (Lichtsteiner et al., 2008 — Fig. 11 di Paper 1)] precede i due comparatori di soglia (#raw("AON") e #raw("AOFF")) con un amplificatore invertente a capacità commutate (#mi("A_1 = -C_1/C_2 \\approx -20")) dotato di switch di reset refrattario pMOS #mi("M_{\\text{ref}}"): il condensatore serie #mi("C_1") blocca completamente l'offset DC del fotorecettore logaritmico e il guadagno capacitivo riduce il mismatch di soglia dei comparatori da #mi("20\\,\\text{mV}") a solo #strong[#mi("1\\,\\text{mV}") riferito all'ingresso] (#mi("\\sim 2\\%") di contrasto su una matrice di #mi("128\\times 128") pixel).

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.5 Il Neurone #emph[Tau-Cell] #emph[(van Schaik et al., 2010 — Figura 4)]

#figure(image("figure/fig04_taucell_neuron.png", width: 88%), caption: [Schema elettrico a livello transistor del neurone Tau-Cell])
#emph[Figura 4 — Estratta da Indiveri et al. (2011), Fig. 12: Schema elettrico completo a livello transistor (#mi("M_1\\text{-}M_{\\text{16}}, C_{\\text{mem}}")) del neurone log-domain Tau-Cell.]

Il neurone #strong[Tau-Cell] (#strong[Figura 4]) trasforma il filtro #emph[log-domain] di Figura 1A in un neurone spiking completo utilizzando 16 transistor (#mi("M_1\\text{-}M_{\\text{16}}")):
- #strong[Integrazione Leaky Log-Domain (#mi("M_1, M_2, M_3, M_4") nMOS, #mi("M_6, M_7") pMOS, #mi("C_{\\text{mem}}, V_{\\text{ref}}, I_0, 2I_0")):] La corrente d'ingresso #mi("I_{\\text{in}}") (iniettata sul source di #mi("M_1")) viene integrata producendo la corrente di stato di membrana #mi("I_{\\text{mem}}") nel ramo di #mi("M_4").
- #strong[Comparazione di Corrente (#mi("M_5, M_8, M_9")):] Lo specchio pMOS #mi("M_5\\text{-}M_8") copia #mi("I_{\\text{mem}}") sul nodo #mi("V_{\\text{comp}}"), dove si confronta con la corrente di soglia #mi("I_\\theta") fissata dall'nMOS #mi("M_9") (gate a #mi("V_\\theta")).
- #strong[Starved Inverter, Feedback Positivo e Reset (#mi("M_{\\text{12}}\\text{-}M_{\\text{16}}")):] Quando #mi("I_{\\text{mem}} > I_\\theta"), l'inverter limitato in corrente (#mi("M_{\\text{12}}, M_{\\text{13}}") con bias #mi("V_{\\text{il}}")) abbassa il nodo #mi("V_{\\text{nspk}}"), attivando il feedback positivo tramite #mi("M_7") e facendo salire l'uscita del secondo inverter (#mi("M_{\\text{14}}, M_{\\text{15}}")) a #mi("V_{\\text{spk}} = V_{\\text{dd}}"). Con un lieve ritardo di propagazione, #mi("V_{\\text{spk}}") accende l'nMOS di reset #strong[#mi("M_{\\text{16}}")] che porta il nodo capacitivo #mi("C_{\\text{mem}}") al potenziale di reset #strong[#mi("V_{\\text{el}}")], terminando lo spike.

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.6 Il Neurone #emph[Log-Domain LPF] (LLN) a Feedback Positivo Cubico #emph[(Arthur & Boahen, 2004, 2007 — Figura 5)]

#figure(image("figure/fig05_lln_neuron.png", width: 88%), caption: [Schema elettrico a 4 blocchi e tracce sperimentali del neurone Log-Domain LPF (LLN)])
#emph[Figura 5 — Estratta da Indiveri et al. (2011), Fig. 13: Il neurone Log-Domain LPF (LLN). (A) Schema elettrico suddiviso in 4 blocchi funzionali: filtro LPF di membrana (giallo, #mi("M_{L1\\text{-}3}, C_{\\text{mem}}")), generatore di spike con feedback positivo cubico translineare (rosso, #mi("M_{A1\\text{-}6}")), generatore di impulso refrattario/reset (blu, #mi("M_{R1\\text{-}3}, C_R")) e filtro LPF di adattamento di frequenza (verde, #mi("M_{G1\\text{-}4}, C_P")). (B) Tracce sperimentali misurate su chip CMOS #mi("0.25\\,\\mu\\text{m}"): regular spiking, spike-frequency adaptation e bursting.]

Come mostrato in #strong[Figura 5], il neurone #strong[LLN] (che dissipa appena #strong[#mi("50\\text{-}1000\\,\\text{nW}")] in CMOS #mi("0.25\\,\\mu\\text{m}")) accoppia due filtri #emph[log-domain] del tipo di Figura 1B con un anello translineare cubico, implementando esattamente il sistema dinamico dell'#strong[Equazione (1)]:

#mitex("\\begin{cases}
\\tau \\dfrac{dv}{dt} = -v(1 + g) + v_\\infty + \\dfrac{v^3}{3} \\\\
\\tau_g \\dfrac{dg}{dt} = -g + g_{\\max} r(t)
\\end{cases}")

- #strong[Blocco Giallo (#mi("M_{\\text{L1}}\\text{-}M_{\\text{L3}}, C_{\\text{mem}}")):] Filtro LPF di membrana con corrente di leak fissata da #mi("V_{\\text{lk}}") su #mi("M_{\\text{L3}}").
- #strong[Blocco Rosso (#mi("M_{\\text{A1}}\\text{-}M_{\\text{A6}}")):] Il pMOS #mi("M_{\\text{A1}}") legge la tensione su #mi("C_{\\text{mem}}") generando una corrente proporzionale a #mi("v"). L'anello translineare formato dagli nMOS #mi("M_{\\text{A2}}, M_{\\text{A3}}, M_{\\text{A4}}") e dai pMOS #mi("M_{\\text{A5}}, M_{\\text{A6}}") (polarizzati da #mi("V_{\\text{fb}}")) eleva al cubo tale corrente e reinietta nel nodo di membrana una corrente di feedback positivo #strong[#mi("I_{\\text{fb}} \\propto \\frac{v^3}{3}")]. Quando #mi("\\frac{v^3}{3} > v"), la derivata #mi("\\frac{dv}{dt}") esplode positivamente generando la richiesta di spike #raw("REQ").
- #strong[Blocco Blu (#mi("M_{\\text{R1}}\\text{-}M_{\\text{R3}}, C_R")):] All'arrivo dell'acknowledge #raw("ACK"), genera l'impulso di reset #mi("r(t)") di durata #mi("T_R") regolata da #mi("V_{\\text{ref}}") su #mi("M_{\\text{R2}}"), accendendo il pMOS #mi("M_{\\text{R3}}") che tira #mi("C_{\\text{mem}}") a #mi("V_{\\text{dd}}") (azzerando #mi("v")).
- #strong[Blocco Verde (#mi("M_{\\text{G1}}\\text{-}M_{\\text{G4}}, C_P")):] Ad ogni impulso #mi("r(t)"), #mi("M_{\\text{G1}}") scarica parzialmente #mi("C_P") attraverso #mi("M_{\\text{G2}}") (#mi("V_{\\text{wahp}} \\to g_{\\max}")), mentre #mi("M_{\\text{G3}}") (#mi("V_{\\text{lkahp}} \\to \\tau_g")) lo ricarica lentamente; il pMOS #mi("M_{\\text{G4}}") inietta la corrente adattativa #mi("I_g \\propto g") sul nodo di membrana, moltiplicando il termine di decadimento #mi("-v(1+g)").

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.7 Il Neurone DPI (#emph[Adaptive Exponential I&F] in Modalità Corrente) #emph[(Livi & Indiveri, 2009; Indiveri et al., 2010 — Figura 6)]

#figure(image("figure/fig06_dpi_adex_neuron.png", width: 88%), caption: [Schema elettrico completo e fit esponenziale del neurone DPI AdEx di Indiveri])
#emph[Figura 6 — Estratta da Indiveri et al. (2011), Fig. 14: Il circuito del neurone DPI (AdEx in modalità corrente). (A) Schema elettrico a 21 transistor e 3 condensatori (#mi("C_{\\text{mem}}, C_P, C_R")) suddiviso in 4 blocchi: filtro DPI di ingresso/leak (giallo, #mi("M_{L1\\text{-}3}")), filtro DPI di adattamento SFA (verde, #mi("M_{G1\\text{-}6}")), amplificatore di generazione spike con feedback positivo esponenziale (rosso, #mi("M_{A1\\text{-}6}")) e blocco di reset/periodo refrattario (blu, #mi("M_{R1\\text{-}6}")). (B) Risposta misurata della corrente di membrana #mi("I_{\\text{mem}}/I_0") a un gradino di corrente e fit analitico con doppio esponenziale (#mi("\\propto e^{-t/\\tau_K}") all'onset dello stimolo e #mi("\\propto e^{+t/\\tau_{\\text{Na}}}") all'innesco dello spike).]

Il #strong[Neurone DPI] (#strong[Figura 6]) sostituisce i filtri LPF semplici del neurone LLN con due circuiti #strong[DPI] (Figura 1C) e un generatore di spike a feedback positivo esponenziale, realizzando con #strong[21 transistor e 3 capacità] il modello #strong[Adaptive Exponential Integrate-and-Fire (AdEx)] di Brette & Gerstner (2005):

#mitex("\\begin{cases}
\\tau \\dfrac{dI_{\\text{mem}}}{dt} = -I_{\\text{mem}} \\left(1 + \\dfrac{I_g}{I_\\tau}\\right) + I_{\\text{mem}\\infty} + f(I_{\\text{mem}}) \\\\
\\tau_g \\dfrac{dI_g}{dt} = -I_g + I_{g\\max} r(t)
\\end{cases}")

con parametri fisici governati dalle tensioni di bias in sottosoglia:
#mitex("\\tau = \\frac{C_{\\text{mem}} U_T}{\\kappa I_\\tau}, \\quad \\tau_g = \\frac{C_P U_T}{\\kappa I_{\\tau g}}, \\quad I_{\\text{mem}\\infty} = \\frac{I_{\\text{in}}}{I_\\tau} I_0 e^{\\frac{\\kappa}{U_T} V_{\\text{thr}}}, \\quad I_{g\\max} = \\frac{I_{\\text{MG2}}}{I_{\\tau g}} I_0 e^{\\frac{\\kappa}{U_T} V_{\\text{thrahp}}}, \\quad I_\\tau = I_0 e^{\\frac{\\kappa}{U_T} V_{\\text{lk}}}, \\quad I_{\\tau g} = I_0 e^{\\frac{\\kappa}{U_T} V_{\\text{lkahp}}}")

- #strong[Analisi Transistor-per-Transistor dei 4 Blocchi di Figura 6A:]
+ #strong[Blocco Giallo — DPI di Membrana e Leak (#mi("M_{\\text{L1}}\\text{-}M_{\\text{L3}}, C_{\\text{mem}}")):]
La corrente sinaptica totale #mi("I_{\\text{in}}") alimenta la coppia differenziale nMOS #strong[#mi("M_{\\text{L1}}\\text{-}M_{\\text{L2}}")] (con gate di #mi("M_{\\text{L1}}") polarizzato da #mi("V_{\\text{thr}}") e gate di #mi("M_{\\text{L2}}") collegato al nodo di membrana #mi("C_{\\text{mem}}")). L'nMOS #strong[#mi("M_{\\text{L3}}")] (polarizzato da #mi("V_{\\text{lk}}")) sottrae la corrente di leak #mi("I_\\tau") da #mi("C_{\\text{mem}}").
+ #strong[Blocco Rosso — Generazione Spike e Feedback Positivo Esponenziale (#mi("M_{\\text{A1}}\\text{-}M_{\\text{A6}}")):]
L'nMOS #strong[#mi("M_{\\text{A4}}")] (col gate collegato a #mi("C_{\\text{mem}}")) converte esponenzialmente la tensione su #mi("C_{\\text{mem}}") nella corrente sottosoglia di membrana #mi("I_{\\text{mem}}"). Quando #mi("I_{\\text{mem}}") supera la corrente di soglia del pMOS #strong[#mi("M_{\\text{A1}}")], la tensione sul drain di #mi("M_{\\text{A1}}/M_{\\text{A3}}") scende, accendendo l'inverter successivo (#mi("M_{\\text{A2}}") pMOS, #mi("M_{\\text{A3}}") nMOS) e lo specchio di corrente pMOS #strong[#mi("M_{\\text{A5}}\\text{-}M_{\\text{A6}}")]. Il transistor #strong[#mi("M_{\\text{A6}}")] reinietta su #mi("C_{\\text{mem}}") una corrente di feedback positivo #strong[#mi("I_a = f(I_{\\text{mem}})")] che cresce #strong[esponenzialmente] con #mi("I_{\\text{mem}}"), generando l'impennata dello spike (fit rosso in Figura 6B) con dissipazione di potenza minima e attivando la linea #raw("/REQ").
+ #strong[Blocco Blu — Reset e Periodo Refrattario (#mi("M_{\\text{R1}}\\text{-}M_{\\text{R6}}, C_R")):]
All'arrivo del segnale di handshaking #raw("/ACK") sul gate del pMOS #strong[#mi("M_{\\text{R1}}")], il nodo della capacità di refrattarietà #strong[#mi("C_R")] viene caricato a #mi("V_{\\text{dd}}"). Al termine dello spike, #mi("C_R") si scarica lentamente attraverso il ramo #emph[starved inverter] formato da #strong[#mi("M_{\\text{R2}}, M_{\\text{R3}}, M_{\\text{R4}}, M_{\\text{R5}}")] con velocità fissata dalla tensione di bias #strong[#mi("V_{\\text{ref}}")] sul gate di #mi("M_{\\text{R5}}"). Finché la tensione su #mi("C_R") resta alta, l'nMOS di reset #strong[#mi("M_{\\text{R6}}")] rimane acceso e scarica #mi("C_{\\text{mem}}") con una forte corrente #mi("I_r"), mantenendo il neurone bloccato per tutto il periodo refrattario.
+ #strong[Blocco Verde — DPI di Spike-Frequency Adaptation (#mi("M_{\\text{G1}}\\text{-}M_{\\text{G6}}, C_P")):]
Ad ogni spike emesso, il pMOS #strong[#mi("M_{\\text{G1}}")] si accende e inietta la corrente fissata da #strong[#mi("M_{\\text{G2}}")] (#mi("V_{\\text{ahp}}")) nella coppia differenziale pMOS #strong[#mi("M_{\\text{G3}}\\text{-}M_{\\text{G4}}")] (soglia #mi("V_{\\text{thrahp}}") su #mi("M_{\\text{G3}}"), gate di #mi("M_{\\text{G4}}") collegato alla capacità di adattamento #strong[#mi("C_P")]). L'nMOS #strong[#mi("M_{\\text{G5}}")] (#mi("V_{\\text{lkahp}}")) scarica lentamente #mi("C_P") con costante di tempo #mi("\\tau_g"), mentre l'nMOS di uscita #strong[#mi("M_{\\text{G6}}")] converte la tensione su #mi("C_P") nella corrente iperpolarizzante lenta #strong[#mi("I_g")], sottraendola direttamente da #mi("C_{\\text{mem}}") in parallelo a #mi("M_{\\text{L3}}").

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.8 Il Neurone Quadratico di Izhikevich in CMOS #emph[(Wijekoon & Dudek, 2008 — Figura 7; Ronchini et al., 2023 — Figura 16b)]

#figure(image("figure/fig07_izhikevich_neuron.png", width: 88%), caption: [Schema elettrico a 14 transistor e pattern di firing del neurone di Izhikevich in CMOS])
#emph[Figura 7 — Estratta da Indiveri et al. (2011), Fig. 16: Neurone di Izhikevich in CMOS #mi("0.35\\,\\mu\\text{m}") (Wijekoon & Dudek, 2008). (A) Schema elettrico a 14 transistor (#mi("M_1\\text{-}M_{\\text{14}}")) e due capacità (#mi("C_v") per il potenziale di membrana #mi("V") e #mi("C_u") per la variabile lenta #mi("U")). (B) Pattern di firing registrati dal chip variando le tensioni di bias ai nodi #mi("c") e #mi("d"): regular spiking con adattamento, fast spiking, intrinsically bursting e chattering.]

Il circuito di #strong[Figura 7A] (e la sua versione in sottosoglia a 12 transistor #mi("M_1\\text{-}M_{\\text{12}}") a #mi("V_{\\text{DD}}=0.25\\,\\text{V}") impiegata in #strong[NET-TEN], #strong[Figura 16b], área #mi("1476.84\\,\\mu\\text{m}^2"), #mi("C_v = 76.86\\,\\text{fF}"), #mi("C_u = 614.88\\,\\text{fF}")) implementa direttamente la coppia di equazioni differenziali di Izhikevich:
- #strong[Circuito della Variabile Veloce #mi("V_{\\text{mem}}") (#mi("M_1\\text{-}M_5, C_v")):]
Il condensatore #mi("C_v") integra la corrente sinaptica #mi("I_{\\text{syn}}"). L'nMOS #strong[#mi("M_1")] (col gate collegato a #mi("V_{\\text{mem}}") su #mi("C_v")) genera una corrente di drain non lineare (quadratica in forte inversione / esponenziale in debole inversione) che viene specchiata dallo specchio di corrente pMOS #strong[#mi("M_2\\text{-}M_3")] e reiniettata positivamente su #mi("C_v") (implementando il termine rigenerativo #mi("+0.04 V_{\\text{mem}}^2 + 5V_{\\text{mem}}")). L'nMOS #strong[#mi("M_4")] ha il gate pilotato dalla tensione #mi("U") sul condensatore lento #mi("C_u") e sottrae da #mi("C_v") la corrente di recupero #mi("-U").
- #strong[Circuito della Variabile Lenta di Recupero #mi("U") (#mi("M_1, M_2, M_6\\text{-}M_8, C_u")):]
Un secondo pMOS #strong[#mi("M_7")] (accoppiato a specchio con #mi("M_2")) inietta in #mi("C_u") una corrente proporzionale a #mi("I_{\\text{M1}}(V_{\\text{mem}})") (termine #mi("+a b V_{\\text{mem}}")), mentre l'nMOS connesso a diodo #strong[#mi("M_6")] scarica #mi("C_u") verso massa con una corrente dipendente da #mi("U") stessa (termine #mi("-a U")). Poiché #mi("C_u \\approx 8 C_v") e #mi("(W/L)_{M_7} < (W/L)_{M_3}"), la dinamica di #mi("U") è molto più lenta di quella di #mi("V_{\\text{mem}}").
- #strong[Comparatore e Reset Post-Spike ai Nodi #mi("c") e #mi("d") (#mi("M_5, M_8, M_9\\text{-}M_{\\text{14}}")):]
Quando #mi("V_{\\text{mem}}") supera la soglia del comparatore (#mi("M_9\\text{-}M_{\\text{14}}") in Fig. 7A, oppure i due inverter in cascata #mi("M_9\\text{-}M_{\\text{10}}") e #mi("M_{\\text{11}}\\text{-}M_{\\text{12}}") in Fig. 16b di NET-TEN):
+ L'impulso positivo d'uscita accende lo switch nMOS #strong[#mi("M_5")], che scarica istantaneamente #mi("C_v") alla tensione di bias #strong[#raw("c")] (#mi("V_C"), parametro #mi("c"): #mi("V_{\\text{mem}} \\leftarrow c")).
+ L'impulso complementare negativo accende lo switch pMOS #strong[#mi("M_8")], che inietta un pacchetto di carica dalla tensione di bias #strong[#raw("d")] (#mi("V_D")) nel condensatore #mi("C_u") (parametro #mi("d"): #mi("U \\leftarrow U + d")).

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.2.9 Il Neurone #emph[Switched-Capacitor] di Mihalas–Niebur #emph[(Folowosele et al., 2009 — Figura 9)]

#figure(image("figure/fig09_switched_cap_mihalas_niebur.png", width: 88%), caption: [Schema elettrico del neurone Switched-Capacitor di Mihalas-Niebur])
#emph[Figura 9 — Estratta da Indiveri et al. (2011), Fig. 18: Implementazione Switched-Capacitor (S-C) del neurone a soglia adattativa di Mihalas–Niebur (Folowosele et al., 2009a). (A) Circuito di membrana (#mi("C_m"), resistore S-C di leak #mi("\\text{SW}_1") pilotato da #mi("\\phi_1, \\phi_2"), e switch di reset #mi("M_1, M_2") verso #mi("E_L")). (B) Circuito della soglia adattativa (#mi("C_\\Theta"), blocchi S-C #mi("\\text{SW}_2, \\text{SW}_3, \\text{SW}_4") e switch di aggiornamento #mi("M_3, M_4, M_5") verso #mi("\\Theta_r")).]

Per eliminare alla radice la sensibilità al mismatch dei transistor in sottosoglia, #strong[Folowosele et al. (2009a,b)] (#strong[Figura 9]) hanno implementato il modello di Mihalas–Niebur sostituendo i transistor di leak con #strong[resistori a capacità commutate (\*Switched-Capacitor\*, S-C)]: un piccolo condensatore #mi("C_{\\text{sw}}") commutato tra due nodi da due fasi di clock non sovrapposte (#mi("\\phi_1, \\phi_2") a frequenza #mi("f_{\\text{clk}}")) trasferisce una carica #mi("\\Delta Q = C_{\\text{sw}} \\Delta V") per ciclo, realizzando una conduttanza equivalente altamente precisa e accordabile via frequenza:
#mitex("G_{\\text{eq}} = f_{\\text{clk}} C_{\\text{sw}} \\implies \\tau_m = \\frac{C_m}{f_{\\text{clk}} C_{\\text{sw}}}")
Il blocco #raw("SW1") realizza il leak di membrana verso #mi("E_L"), mentre i blocchi #raw("SW2"), #raw("SW3"), #raw("SW4") accoppiano linearmente la soglia #mi("\\Theta") (su #mi("C_\\Theta")) a #mi("V_m"), permettendo di riprodurre 10 pattern di spiking corticali senza alcuno sforzo di calibrazione analogica (a fronte però della necessità di distribuire molteplici fasi di clock a ogni neurone).
#emph[(Completa la rassegna di Paper 1 il neurone a pacchetti di carica calibrati digitalmente a 5-bit tramite #strong[Digi-MOS] di Serrano-Gotarredona et al., 2006 — Fig. 20 di Paper 1, e il neurone interamente digitale a 18-bit di Camuñas Mesa et al., 2008 — Fig. 21 di Paper 1).]


#line(length: 100%, stroke: 0.5pt + luma(200))

== 4.3 Architettura e Circuiti Transistor-Level del Processore Neuromorfico ROLLS #emph[(Qiao et al., 2015 — Paper 2)]

=== 4.3.1 Architettura del Chip e Distribuzione dell'Area Silicea
Il processore #strong[ROLLS (\*Reconfigurable On-line Learning Spiking Neuromorphic Processor\*, Qiao et al., 2015)] rappresenta la realizzazione completa su larga scala VLSI dei principi di progettazione #emph[sub-threshold current-mode] esposti in #emph[Indiveri et al. (2011)]. Fabbricato in un processo standard #strong[180 nm CMOS 1P6M] (1 Poly, 6 Metal), occupa un'area di die di #strong[#mi("51.4\\,\\text{mm}^2")], integra circa #strong[#mi("12.2\\,\\text{milioni}") di transistor] e dissipa una potenza media di #strong[#mi("\\approx 4\\,\\text{mW}")] in condizioni operative tipiche (#strong[Figura 10]).

#figure(image("figure/fig10_rolls_arch_die_area.png", width: 88%), caption: [Architettura a blocchi, microfotografia del die e tabella delle aree del processore ROLLS])
#emph[Figura 10 — Estratta da Qiao et al. (2015), Fig. 1, Fig. 2 e Table 1: (In alto) Diagramma a blocchi dell'architettura di ROLLS: matrice di #mi("256\\times 256") sinapsi programmabili a breve termine (STP), matrice di #mi("256\\times 256") sinapsi plastiche bistabili a lungo termine (LTP), fila di #mi("256\\times 2") sinapsi virtuali, Synapse De-Multiplexer, fila di 256 somi AdEx, periferiche asincrone AER Input/Output, Bias Generator e ADC. (In basso a sinistra) Microfotografia del die in CMOS 180 nm (#mi("51.4\\,\\text{mm}^2")). (In basso a destra) Tabella ufficiale della distribuzione dell'area silicea.]

L'architettura co-localizza memoria e calcolo (#emph[in-memory computing] non-von Neumann) mediante:
- #strong[#mi("256 \\times 1") Neuroni al Silicio (Soma AdEx):] ciascuno affiancato dal proprio circuito post-sinaptico di apprendimento (#emph[stop-learning] basato sul Calcio) e da circuiti di #emph[synaptic scaling] omeostatico.
- #strong[#mi("256 \\times 256 = 65\\,536") (#mi("64\\text{K}")) Sinapsi di Apprendimento a Lungo Termine (LTP):] implementano l'algoritmo bistabile #emph[spike-driven] di Brader, Senn & Fusi (2007). Tutte le 256 sinapsi di una riga sommano le proprie correnti d'uscita in #strong[un unico filtro lineare DPI eccitatorio per riga], polarizzato con tecnica #emph[shifted-source biasing] per raggiungere costanti di tempo di #strong[centinaia di millisecondi (dinamica NMDA)].
- #strong[#mi("256 \\times 256 = 65\\,536") (#mi("64\\text{K}")) Sinapsi Programmabili a Breve Termine (STP):] ciascuna dotata di peso digitale a #strong[2-bit] (4 livelli), #strong[1-bit di polarità Eccitatoria/Inibitoria (#raw("E/I"))] e circuito analogico di #strong[Short-Term Depression (STD)]. Ogni riga condivide #strong[due integratori DPI di riga] (uno eccitatorio #strong[AMPA] e uno inibitorio #strong[GABA]) con capacità da #mi("1\\,\\text{pF}") e costanti di tempo di decine di millisecondi.
- #strong[#mi("256 \\times 2 = 512") Sinapsi Virtuali:] 2 filtri DPI per neurone per l'iniezione di stimoli esterni in #emph[time-multiplexing].
- #strong[Synapse De-Multiplexer:] matrice di commutazione statica che di default assegna 1 riga da 512 sinapsi (256 LTP + 256 STP) a ciascuno dei 256 neuroni, ma può essere riconfigurata per aggregare più righe sinaptiche su un numero inferiore di neuroni (fino a connettere tutte le #mi("128\\text{K}") sinapsi a #strong[1 singolo neurone], disconnettendo gli altri 255).

Come documentato nella #strong[Tabella 1 di Figura 10], l'analisi della ripartizione dell'area di silicio rivela un dato architetturale di fondamentale importanza:
- I #strong[256 somi neuronali] (#mi("55.69 \\times 16.48\\,\\mu\\text{m}^2") ciascuno) occupano complessivamente appena #strong[#mi("0.235\\,\\text{mm}^2"), pari allo #mi("0.47\\%") dell'area del chip] (e i 256 circuiti post-sinaptici di apprendimento occupano #mi("0.165\\,\\text{mm}^2"), lo #mi("0.32\\%")).
- Al contrario, le #strong[#mi("64\\text{K}") sinapsi LTP] (#mi("15.3 \\times 16.48\\,\\mu\\text{m}^2"), totale #strong[#mi("16.147\\,\\text{mm}^2 = 31.41\\%")]) e le #strong[#mi("64\\text{K}") sinapsi STP] (#mi("16.24 \\times 16.48\\,\\mu\\text{m}^2"), totale #strong[#mi("17.129\\,\\text{mm}^2 = 33.32\\%")]) assorbono da sole il #strong[#mi("64.73\\%") dell'intero die (#mi("33.276\\,\\text{mm}^2"))], ovvero #strong[oltre #mi("140") volte l'area dei somi neuronali]!

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.3.2 Analisi Transistor-per-Transistor del Soma AdEx in ROLLS (#raw("NMDA"), #raw("LEAK"), #raw("AHP"), #raw("Na+"), #raw("K+"))

#figure(image("figure/fig11_rolls_silicon_neuron_schematic.png", width: 88%), caption: [Schema elettrico completo a livello transistor del neurone al silicio AdEx di ROLLS])
#emph[Figura 11 — Estratta da Qiao et al. (2015), Fig. 3: Schema elettrico completo a livello transistor del neurone al silicio AdEx integrato in ROLLS, suddiviso in 5 blocchi funzionali: #raw("NMDA") (rosa, #mi("M_{N1\\text{-}N2}")), #raw("LEAK") (giallo, #mi("M_{L1\\text{-}L7}, C_M")), #raw("AHP") (verde, #mi("M_{A1\\text{-}A7}, C_A")), #raw("Na+") (azzurro, #mi("M_{Na1\\text{-}Na5}")) e #raw("K+") (blu, #mi("M_{K1\\text{-}K8}, C_R")).]

Lo schema elettrico completo del soma integrato in ROLLS (#strong[Figura 11]) evolve il neurone DPI di Indiveri (Figura 6) introducendo #strong[5 blocchi funzionali] controllati da 13 bias globali (generati dal #emph[BiasGen] on-chip e contrassegnati dal punto esclamativo #raw("!")) e da 2 latch digitali locali che permettono di selezionare tra due costanti di tempo di leak e due periodi refrattari (4 popolazioni neuronali distinte):

+ #strong[Blocco #raw("NMDA") — \*Voltage-Gating\* Sinaptico (#mi("M_{\\text{N1}}, M_{\\text{N2}}"), in alto a sinistra, rosa):]
Riceve la corrente post-sinaptica lenta dal DPI di riga della matrice LTP. La coppia differenziale nMOS #strong[#mi("M_{\\text{N1}}\\text{-}M_{\\text{N2}}")] confronta il potenziale di membrana #strong[#raw("Vmem")] (sul gate di #mi("M_{\\text{N2}}")) con la soglia di sblocco del magnesio #strong[#raw("if_nmda!")] (sul gate di #mi("M_{\\text{N1}}")): solo quando il neurone post-sinaptico è sufficientemente depolarizzato (#mi("V_{\\text{mem}} > \\text{if\\_nmda!}")), la corrente fluisce nel ramo di #mi("M_{\\text{N2}}") e viene specchiata dallo specchio pMOS superiore dentro il nodo di membrana #raw("Vmem").
+ #strong[Blocco #raw("LEAK") — DPI di Membrana con \*Shifted-Source Biasing\* e Doppia Costante di Tempo (#mi("M_{\\text{L1}}\\text{-}M_{\\text{L7}}, C_M"), in basso a sinistra, giallo):]
- #strong[#mi("M_{\\text{L1}}") (pMOS, gate a #raw("if_dc!")):] Inietta una corrente di stimolazione costante regolabile.
- #strong[#mi("M_{\\text{L2}}, M_{\\text{L3}}") (coppia differenziale nMOS del DPI):] Il gate di #mi("M_{\\text{L2}}") è polarizzato dalla soglia #strong[#raw("if_thr!")], il gate di #mi("M_{\\text{L3}}") è collegato a #strong[#raw("Vmem")] sulla capacità di membrana #strong[#mi("C_M")].
- #strong[#mi("M_{\\text{L4}}, M_{\\text{L5}}") (nMOS di leak) e #mi("M_{\\text{L6}}, M_{\\text{L7}}") (switch di selezione):] Il latch digitale locale (#raw("tau1") / #raw("tau2")) seleziona se scaricare il nodo tramite #mi("M_{\\text{L4}}") (bias #strong[#raw("if_tau1!")]) oppure tramite #mi("M_{\\text{L5}}") (bias #strong[#raw("if_tau2!")]).
- #strong[Accorgimenti progettuali contro il Mismatch e per Costanti di Tempo Lunghe:] I terminali di source di #mi("M_{\\text{L6}}") e #mi("M_{\\text{L7}}") sono connessi al potenziale rialzato #strong[#raw("SSN!")] (#emph[Shifted-Source Biasing], Fig. 7C di Paper 1) per raggiungere correnti sub-pA e costanti di tempo #mi("\\tau_m") fino a centinaia di ms. Inoltre, i transistor critici di leak #mi("M_{\\text{L4}}") e #mi("M_{\\text{L5}}") sono sovradimensionati a #strong[#mi("W / L = 2\\,\\mu\\text{m} / 4\\,\\mu\\text{m}")] per minimizzare il mismatch di Pelgrom.
+ #strong[Blocco #raw("AHP") — \*Spike-Frequency Adaptation\* DPI (#mi("M_{\\text{A1}}\\text{-}M_{\\text{A7}}, C_A"), al centro, verde):]
Ad ogni spike confermato da #strong[#raw("/ACK")] (gate del pMOS #strong[#mi("M_{\\text{A1}}")]), il pMOS #strong[#mi("M_{\\text{A2}}")] (#strong[#raw("if_ahw!")]) inietta un impulso di carica nella coppia differenziale pMOS #strong[#mi("M_{\\text{A3}}\\text{-}M_{\\text{A4}}")] (soglia #strong[#raw("if_ahthr!")] su #mi("M_{\\text{A3}}"), capacità di adattamento #strong[#mi("C_A")] sul gate di #mi("M_{\\text{A4}}")). L'nMOS #strong[#mi("M_{\\text{A7}}")] (gate a #strong[#raw("if_ahtau!")], source a #strong[#raw("SSN!")]) scarica lentamente #mi("C_A"), mentre l'nMOS #strong[#mi("M_{\\text{A6}}")] (in serie al cascode #strong[#mi("M_{\\text{A5}}")] polarizzato da #strong[#raw("if_casc!")]) sottrae da #raw("Vmem") la corrente iperpolarizzante lenta #mi("I_g").
+ #strong[Blocco #raw("Na+") — Feedback Positivo Esponenziale (#mi("M_{\\text{Na1}}\\text{-}M_{\\text{Na5}}"), centro-destra, azzurro):]
L'nMOS #strong[#mi("M_{\\text{Na4}}")] (col gate collegato a #raw("Vmem")) è posto in serie a #strong[#mi("M_{\\text{Na3}}")] e allo switch di inattivazione #strong[#mi("M_{\\text{Na5}}")] (controllato in opposizione di fase dalla capacità di refrattarietà #mi("C_R")). Quando #raw("Vmem") sale, la corrente di drain di #mi("M_{\\text{Na3}}/M_{\\text{Na4}}") abbassa il nodo di richiesta #strong[#raw("/REQ")] e viene specchiata dallo specchio pMOS #strong[#mi("M_{\\text{Na1}}\\text{-}M_{\\text{Na2}}")], che reinietta esponenzialmente corrente in #raw("Vmem"). Per abbattere la variabilità della soglia di sparo, i transistor sono dimensionati a #strong[#mi("(W/L)_{M_{\\text{Na3}}} = 4\\,\\mu\\text{m}/0.4\\,\\mu\\text{m}")] e #strong[#mi("(W/L)_{M_{\\text{Na4}}} = 1\\,\\mu\\text{m}/4\\,\\mu\\text{m}")], ottenendo un #strong[mismatch medio della curva #mi("f\\text{-}I") su tutti i 256 neuroni del chip pari a solo il #mi("9.4\\%")]!
+ #strong[Blocco #raw("K+") — Reset Regolabile e Doppia Refrattarietà (#mi("M_{\\text{K1}}\\text{-}M_{\\text{K8}}, C_R"), a destra, blu):]
All'arrivo di #strong[#raw("/ACK")] su #strong[#mi("M_{\\text{K1}}")], lo #emph[starved inverter] (#strong[#mi("M_{\\text{K2}}, M_{\\text{K3}}")]) carica la capacità #strong[#mi("C_R")], che si scarica poi attraverso #strong[#mi("M_{\\text{K4}}")] (#strong[#raw("if_rfr1!")]) o #strong[#mi("M_{\\text{K5}}")] (#strong[#raw("if_rfr2!")]), selezionati dagli switch #strong[#mi("M_{\\text{K6}}, M_{\\text{K7}}")] (#raw("iftau1sel") / #raw("iftau2sel")). Finché #mi("C_R") è alta, l'nMOS di reset #strong[#mi("M_{\\text{K8}}")] (col source collegato al potenziale di reset accordabile #strong[#raw("Vrst")]) mantiene #raw("Vmem") inchiodato a #strong[#raw("Vrst")] e spegne #mi("M_{\\text{Na5}}").

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.3.3 Circuiti Post-Sinaptici di Apprendimento (#emph[Stop-Learning] del Calcio e Circuiti #emph[Winner-Take-All])

#figure(image("figure/fig12_rolls_postsynaptic_learning_wta.png", width: 88%), caption: [Schema elettrico dei circuiti post-sinaptici di apprendimento e stop-learning di ROLLS])
#emph[Figura 12 — Estratta da Qiao et al. (2015), Fig. 6: Circuiti post-sinaptici di apprendimento per la valutazione dell'aggiornamento del peso e delle condizioni di "stop-learning" basate sulla concentrazione di Calcio: blocco #raw("DPI") del Calcio (#mi("M_{D1\\text{-}D5}, C_{\\text{Ca}}")) e tre circuiti Winner-Take-All in modalità corrente #raw("WTA") (#mi("M_{W1\\text{-}W9}")), #raw("WTAUP") (#mi("M_{WU1\\text{-}WU12}")) e #raw("WTADN") (#mi("M_{WD1\\text{-}WD12}")).]

Come mostrato in #strong[Figura 12], per implementare le condizioni dell'algoritmo di Brader et al. (2007):
#mitex("\\begin{cases}
w_i \\leftarrow w_i + \\Delta w^+ & \\text{se } V_{\\text{mem}}(t_{\\text{pre}}) > \\theta_{\\text{mem}} \\;\\land\\; \\theta_1 < Ca(t_{\\text{pre}}) < \\theta_3 \\\\
w_i \\leftarrow w_i - \\Delta w^- & \\text{se } V_{\\text{mem}}(t_{\\text{pre}}) < \\theta_{\\text{mem}} \\;\\land\\; \\theta_1 < Ca(t_{\\text{pre}}) < \\theta_2
\\end{cases}")
ogni neurone integra i propri spike post-sinaptici (#strong[#raw("if_req")]) tramite il #strong[blocco #raw("DPI") del Calcio (#mi("M_{\\text{D1}}\\text{-}M_{\\text{D5}}, C_{\\text{Ca}}"))]: la tensione risultante #strong[#raw("Vca")] su #mi("C_{\\text{Ca}}") pilota i gate dei transistor pMOS nei tre comparatori #strong[Winner-Take-All (WTA) in corrente]:
- #strong[#raw("WTA") (#mi("M_{\\text{W1}}\\text{-}M_{\\text{W9}}")):] confronta la corrente di Calcio (#mi("M_{\\text{W2}}")) con la soglia inferiore #mi("\\theta_1") (#strong[#raw("sl_thmin!")] su #mi("M_{\\text{W9}}")), abilitando i pull-up #mi("M_{\\text{WU1}}") e #mi("M_{\\text{WD1}}") solo se #mi("Ca > \\theta_1").
- #strong[#raw("WTAUP") (#mi("M_{\\text{WU1}}\\text{-}M_{\\text{WU12}}")):] confronta #mi("Ca") (#mi("M_{\\text{WU5}}")) con la soglia superiore #mi("\\theta_3") (#strong[#raw("sl_thup!")] su #mi("M_{\\text{WU6}}")) e la corrente di membrana #strong[#raw("ifvmem")] (#mi("M_{\\text{WU4}}")) con #mi("\\theta_{\\text{mem}}") (#mi("M_{\\text{WU2}}\\text{-}M_{\\text{WU3}}")), attivando il segnale digitale di potenziamento #strong[#raw("slnup")].
- #strong[#raw("WTADN") (#mi("M_{\\text{WD1}}\\text{-}M_{\\text{WD12}}")):] confronta #mi("Ca") (#mi("M_{\\text{WD4}}")) con la soglia #mi("\\theta_2") (#strong[#raw("sl_thdn!")] su #mi("M_{\\text{WD5}}")) e la corrente di membrana con #mi("\\theta_{\\text{mem}}") (#strong[#raw("sl_memthr!")] su #mi("M_{\\text{WD6}}")), attivando il segnale digitale di depressione #strong[#raw("sldn")].

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.3.4 Sinapsi Plastica Bistabile a Lungo Termine (LTP: blocchi #raw("SET"), #raw("JUMP"), #raw("BIST"), #raw("CC"))

#figure(image("figure/fig13_rolls_ltp_bistable_synapse.png", width: 88%), caption: [Diagramma logico, protocollo a 4 fasi e schema transistor-level della sinapsi plastica LTP di ROLLS])
#emph[Figura 13 — Estratta da Qiao et al. (2015), Fig. 7: Elemento della matrice sinaptica a lungo termine (LTP) di ROLLS. (A) Diagramma a blocchi della logica asincrona locale (3 latch configurabili #raw("bc_en"), #raw("rec_en"), #raw("mon_en"), pulse generator e pulse extender). (B) Diagramma temporale del protocollo handshaking a 4 fasi per le modalità broadcast e ricorrente. (C) Schema elettrico a livello transistor dei 4 blocchi analogici connessi al nodo capacitivo del peso interno #mi("V_w"): #raw("SET") (#mi("M_{S1\\text{-}S4}")), #raw("JUMP") (#mi("M_{D1\\text{-}D6}")), #raw("BIST") (#mi("M_{B1\\text{-}B9}, M_{CS1\\text{-}CS2}")) e #raw("CC") (#mi("M_{W1\\text{-}W4}")).]

In ciascuna delle #mi("64\\text{K}") celle LTP (#strong[Figura 13C]), il peso interno è rappresentato dalla tensione analogica #strong[#mi("V_w")] sul condensatore di peso, su cui agiscono quattro blocchi a transistor:
+ #strong[Blocco #raw("SET") (#mi("M_{\\text{S1}}\\text{-}M_{\\text{S4}}")):] Permette di inizializzare dall'esterno via AER lo stato binario del peso caricando #mi("V_w \\to V_{\\text{dd}}") (#raw("~set_hi") e #raw("~PW") sui pMOS #mi("M_{\\text{S1}}, M_{\\text{S2}}")) o scaricandolo a massa (#raw("set_low") e #raw("PW") sugli nMOS #mi("M_{\\text{S3}}, M_{\\text{S4}}")).
+ #strong[Blocco #raw("JUMP") (#mi("M_{\\text{D1}}\\text{-}M_{\\text{D6}}")):] All'arrivo dell'impulso pre-sinaptico esteso #strong[#raw("PW")] / #strong[#raw("~PW")], se il segnale post-sinaptico #strong[#raw("~up")] (copia invertita di #raw("slnup")) è attivo basso, i pMOS #strong[#mi("M_{\\text{D1}}, M_{\\text{D2}}, M_{\\text{D3}}")] iniettano su #mi("V_w") un gradino positivo #mi("+\\Delta w^+") regolato da #strong[#raw("delta_up!")]; se invece #strong[#raw("dn")] (#raw("sldn")) è attivo alto, gli nMOS #strong[#mi("M_{\\text{D4}}, M_{\\text{D5}}, M_{\\text{D6}}")] sottraggono un gradino #mi("-\\Delta w^-") regolato da #strong[#raw("delta_dn!")].
+ #strong[Blocco #raw("BIST") (#mi("M_{\\text{B1}}\\text{-}M_{\\text{B9}}, M_{\\text{CS1}}, M_{\\text{CS2}}")):] Implementa il drift bistabile continuo #mi("\\frac{dw_i}{dt} = \\pm C_{\\text{drift}}"). È un amplificatore a transconduttanza #emph[wide-range] (coppia differenziale pMOS #strong[#mi("M_{\\text{B2}}\\text{-}M_{\\text{B3}}")] polarizzata da #strong[#mi("M_{\\text{B1}}")] #raw("ota_tail!") e specchi #strong[#mi("M_{\\text{B4}}\\text{-}M_{\\text{B9}}")]) collegato in #strong[retroazione positiva] sul nodo #mi("V_w") stesso, con correnti di uscita limitate dai transistor di #emph[current-starving] #strong[#mi("M_{\\text{CS1}}")] (pMOS, bias #strong[#raw("drift_up!")]) e #strong[#mi("M_{\\text{CS2}}")] (nMOS, bias #strong[#raw("drift_dn!")]): se #mi("V_w > \\text{bi\\_thr!}") (gate di #mi("M_{\\text{B2}}")), l'OTA spinge lentamente #mi("V_w") verso il rail positivo #mi("V_{\\text{dd}}"); se #mi("V_w < \\text{bi\\_thr!}"), lo spinge verso massa, rendendo il peso immune al leakage a lungo termine!
+ #strong[Blocco #raw("CC") — \*Current Converter\* (#mi("M_{\\text{W1}}\\text{-}M_{\\text{W4}}")):] Durante l'impulso pre-sinaptico #raw("PW") (#mi("M_{\\text{W4}}")), la coppia differenziale nMOS #strong[#mi("M_{\\text{W1}}\\text{-}M_{\\text{W2}}")] confronta #mi("V_w") con la soglia #strong[#raw("pa_wthr!")] ed eroga verso il filtro DPI di riga una corrente EPSC con ampiezza massima fissata da #strong[#raw("pa_wht!")] (#mi("M_{\\text{W3}}")).

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.3.5 Sinapsi Programmabile a Breve Termine (STP: DAC a 2 bit, #raw("STD"), #raw("ECC"), #raw("ICC")) e Circuiti EPSC/STDP di NET-TEN

#figure(image("figure/fig14_rolls_stp_synapse.png", width: 88%), caption: [Diagramma a blocchi e schema transistor-level della sinapsi programmabile STP con Short-Term Depression di ROLLS])
#emph[Figura 14 — Estratta da Qiao et al. (2015), Fig. 9: Elemento della matrice sinaptica a breve termine (STP) di ROLLS. (A) Diagramma a blocchi con latch configurabili per il peso a 2 bit (#raw("W0"), #raw("W1")), polarità #raw("E/I") e attivazione #raw("bc_en")/#raw("rec_en"). (B) Schema elettrico a livello transistor del DAC eccitatorio a 2 bit (#mi("M_{C1\\text{-}C5}")), convertitore eccitatorio #raw("ECC") (#mi("M_{W1\\text{-}W3}")), circuito di Short-Term Depression #raw("STD") (#mi("M_{S1\\text{-}S5}, C_{\\text{STD}}")) e convertitore inibitorio #raw("ICC") (#mi("M_{W4\\text{-}W5}, M_{C6\\text{-}C10}")).]

Nelle #mi("64\\text{K}") sinapsi STP di ROLLS (#strong[Figura 14B]):
- #strong[DAC di Corrente a 2-bit Eccitatorio (#mi("M_{\\text{C1}}\\text{-}M_{\\text{C5}}")) e Inibitorio (#raw("ICC"), #mi("M_{\\text{W4}}\\text{-}M_{\\text{W5}}, M_{\\text{C6}}\\text{-}M_{\\text{C10}}")):] I bit #raw("W0") e #raw("W1") attivano i rami binari pesati (#raw("wht_exc0!"), #raw("wht_exc1!") per #raw("E/I = 1"); #raw("wht_inh0!"), #raw("wht_inh1!") per #raw("E/I = 0")) generando 4 livelli discreti di corrente sinaptica #mi("I_{\\text{exc}}") o #mi("I_{\\text{inh}}").
- #strong[Circuito #raw("STD") — \*Short-Term Depression\* (#mi("M_{\\text{S1}}\\text{-}M_{\\text{S5}}, C_{\\text{STD}}")):] A riposo, il condensatore #mi("C_{\\text{STD}}") si carica attraverso il pMOS connesso a diodo #strong[#mi("M_{\\text{S3}}")] in modo che la tensione di gate del pMOS di uscita #strong[#mi("M_{\\text{W2}}")] (nel blocco #raw("ECC")) eguagli quella di #mi("M_{\\text{S1}}"). Ad ogni impulso pre-sinaptico #raw("PW") sul gate di #strong[#mi("M_{\\text{S5}}")], il transistor #strong[#mi("M_{\\text{S4}}")] (polarizzato da #strong[#raw("std!")]) sottrae un pacchetto di carica da #mi("C_{\\text{STD}}"), riducendo transitoriamente l'ampiezza degli impulsi #mi("I_{\\text{exc}}") successivi finché #mi("C_{\\text{STD}}") non recupera lentamente attraverso il diodo #mi("M_{\\text{S3}}").

==== Confronto con i Circuiti Sinaptici EPSC e STDP di NET-TEN #emph[(Ronchini et al., 2023 — Figura 16c,d)]
Nel chip #strong[NET-TEN] (#strong[Figura 16c,d]), progettato per operare a #mi("V_{\\text{DD}} = 250\\,\\text{mV}") con area minima:
- #strong[Il circuito EPSC (Figura 16c, 4 transistor #mi("M_{\\text{E1}}\\text{-}M_{\\text{E4}} + C_{\\text{syn}}"), area #mi("462.09\\,\\mu\\text{m}^2"))] è una versione ultra-compatta del filtro LPF sottosoglia: durante l'impulso positivo #raw("pre"), l'nMOS #mi("M_{\\text{E1}}") si accende e il pMOS #mi("M_{\\text{E3}}") si spegne, scaricando #mi("C_{\\text{syn}}") con una corrente regolata dal peso #mi("V_w") sul gate di #mi("M_{\\text{E2}}"); il pMOS d'uscita #mi("M_{\\text{E4}}") converte esponenzialmente #mi("V_{\\text{syn}}") in #mi("I_{\\text{syn}}") (picco #mi("486.39\\,\\text{pA}") per #mi("V_w = 200\\,\\text{mV}")); al termine dell'impulso #raw("pre"), #mi("M_{\\text{E3}}") si riaccende e ricarica lentamente #mi("C_{\\text{syn}}") verso #mi("V_{\\text{DD}}") con costante di tempo #mi("\\tau = 212.83\\,\\mu\\text{s}").
- #strong[Il circuito STDP in sottosoglia (Figura 16d, 12 transistor #mi("M_{\\text{S1}}\\text{-}M_{\\text{S12}} + C_w = 206.30\\,\\text{fF}"), area #mi("1054.75\\,\\mu\\text{m}^2"))] costruisce due tracce esponenziali temporali: una traccia pre-sinaptica nel ramo sinistro (#mi("M_{\\text{S1}}\\text{-}M_{\\text{S3}}"), costante di tempo #mi("\\tau_+") regolata da #mi("V_{\\text{tp}}") su #mi("M_{\\text{S3}}")) che viene campionata all'arrivo dell'impulso negativo #raw("post") su #mi("M_{\\text{S5}}") per iniettare la corrente di potenziamento #mi("I_{\\text{pot}}") (regolata da #mi("V_p") su #mi("M_{\\text{S6}}")) in #mi("C_w"); e una traccia post-sinaptica nel ramo destro (#mi("M_{\\text{S10}}\\text{-}M_{\\text{S12}}"), costante di tempo #mi("\\tau_-") regolata da #mi("V_{\\text{td}}") su #mi("M_{\\text{S12}}")) campionata all'arrivo dell'impulso positivo #raw("pre") su #mi("M_{\\text{S8}}") per sottrarre la corrente di depressione #mi("I_{\\text{dep}}") (regolata da #mi("V_d") su #mi("M_{\\text{S7}}")) da #mi("C_w").

#line(length: 100%, stroke: 0.5pt + luma(200))

== 4.4 Architetture Multi-Core Scalabili, Routing Asincrono QDI e Memorie Eterogenee Ibride CAM/SRAM: DYNAPs / DYNAP-SE #emph[(Moradi et al., 2018 — Paper 5)]

=== 4.4.1 Ottimizzazione Analitica della Memoria di Routing Tag-Based a Due Stadi
In un processore singolo-core a crossbar pieno come ROLLS (#mi("N \\times N") sinapsi fisiche), l'area delle sinapsi cresce quadraticamente (#mi("\\mathcal{O}(N^2)")), impedendo di scalare a migliaia di neuroni. D'altra parte, nelle architetture digitali pure (come IBM TrueNorth o SpiNNaker) che usano memorie SRAM centralizzate con routing #emph[point-to-point], per una rete di #mi("N") neuroni con fan-out #mi("F") ciascun neurone richiede #mi("F \\log_2(N)") bit di memoria (es. per #mi("N = 2^{\\text{20}} \\approx 10^6") e #mi("F = 2^{\\text{13}} \\approx 8192"), servirebbero #strong[#mi("160\\,\\text{kbit/neurone}")]!).

#strong[Moradi et al. (2018)] risolvono questo problema ispirandosi alla connettività modulare della corteccia cerebrale (cluster locali densamente connessi + poche proiezioni a lungo raggio): i neuroni vengono suddivisi in #strong[#mi("N/C") cluster (core)] da #strong[#mi("C") neuroni ciascuno] (#mi("C = 256") in DYNAP-SE), combinando #strong[due stadi di routing con memorie eterogenee (SRAM + CAM)]:
+ #strong[Stadio 1 (\*Point-to-Point Source Routing\* tramite SRAM nei router R1):] Ogni neurone sorgente invia il proprio evento (contenente un identificativo locale o #emph[tag] scelto tra #mi("K") tag possibili nel cluster) a un numero ridotto di #strong[#mi("F/M") core di destinazione]. La memoria SRAM sorgente richiesta per neurone è:
#mitex("\\text{MEM}_S = \\frac{F}{M} \\left[\\log_2(K) + \\log_2\\!\\left(\\frac{N}{C}\\right)\\right] = \\frac{F}{M} \\log_2\\!\\left(\\frac{KN}{C}\\right)")
+ #strong[Stadio 2 (\*Local Broadcast Destination Routing\* tramite CAM nelle sinapsi):] Il core di destinazione effettua il #strong[broadcast] del tag a tutti i suoi #mi("C") neuroni; all'interno del core, in media #strong[#mi("M") neuroni] (#mi("M \\le C")) hanno memorizzato quel tag nelle proprie celle #strong[CAM (Content-Addressable Memory)] e ricevono lo spike. La memoria CAM target per neurone vale:
#mitex("\\text{MEM}_T = \\frac{KM}{C} \\log_2(K)")

Definendo il rapporto di flessibilità #mi("\\alpha = K/C"), la #strong[memoria totale per neurone] è:
#mitex("\\text{MEM}(M) = \\text{MEM}_S + \\text{MEM}_T = \\frac{F}{M} \\log_2(\\alpha N) + \\alpha M \\log_2(\\alpha C)")
Uguagliando a zero la derivata rispetto a #mi("M") (#mi("\\frac{∂ \\text{MEM}}{∂ M} = 0")), si trova il #strong[fan-out locale ottimo #mi("M^*")] e la #strong[memoria minima assoluta per neurone] (per #mi("\\alpha = 1"), ossia #mi("K = C")):

#mitex("M^* = \\sqrt{F \\frac{\\log_2(N)}{\\log_2(C)}} \\implies \\mathbf{\\text{MEM}_{\\min} = 2 \\sqrt{F \\log_2(C) \\log_2(N)}}")

#block(fill: rgb("#f0f4f8"), inset: 10pt, radius: 4pt, stroke: (left: 3pt + rgb("#2b6cb0")), width: 100%)[
  #strong[TIP:] #strong[Impatto Quantitativo dell'Architettura Ibrida SRAM + CAM di DYNAPs:]
  Per una rete corticale di #mi("N = 2^{\\text{20}}") neuroni (#mi("1\\,\\text{M}")) con fan-out #mi("F = 2^{\\text{13}}") (#mi("8192")) e cluster di #mi("C = 256") neuroni, la formula di Moradi et al. riduce la memoria necessaria da #strong[#mi("160\\,\\text{kbit/neurone}")] a #strong[meno di #mi("1.2\\,\\text{kbit/neurone}")] (un risparmio superiore a #strong[#mi("130\\times")]!), garantendo inoltre uno #strong[scaling strettamente lineare] della memoria con la dimensione delle reti convoluzionali (contro lo scaling quadratico di IBM TrueNorth mostrato in Fig. 13 di Paper 5).
]

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.4.2 Architettura del Nodo Computazionale, Sintesi Asincrona QDI e Routing Gerarchico R1–R2–R3

#figure(image("figure/fig19_dynaps_hierarchical_routing.png", width: 88%), caption: [Rete di routing gerarchica ibrida 2D-mesh/albero di DYNAPs])
#emph[Figura 19 — Estratta da Moradi et al. (2018), Fig. 2: Rete di routing gerarchica ibrida (Mixed-mode hierarchical-mesh) di DYNAPs: i singoli core trasmettono e ricevono eventi in broadcast tramite un router locale #strong[R1]; gruppi di 4 core sono interconnessi da router ad albero #strong[R2] (livelli 1, 2, 3) per bassa latenza locale, mentre il traffico globale inter-chip su griglia bidimensionale è gestito dai router 2D-mesh #strong[R3].]

Il chip prototipo #strong[DYNAP-SE] (fabbricato in CMOS #strong[#mi("0.18\\,\\mu\\text{m}") 1P6M], area die #strong[#mi("43.79\\,\\text{mm}^2")], area core #strong[#mi("38.5\\,\\text{mm}^2")], alimentazione core da #strong[#mi("1.3\\,\\text{V}") a #mi("1.8\\,\\text{V}")]) integra #strong[4 core da 256 neuroni = 1024 neuroni totali]. Come illustrato nelle #strong[Figure 19, 20 e 24]:
- #strong[Il Singolo Nodo Computazionale (Figura 20, in alto, e Figura 24):]
Ciascuno dei 256 nodi di un core co-localizza:
- #strong[64 parole di memoria mista:] ciascuna formata da #strong[10-bit CAM] (per il matching asincrono del tag sorgente, fan-in = 64) + #strong[2-bit SRAM] (per selezionare il tipo di recettore sinaptico);
- #strong[64 Pulse Generators (PG), 64 Pulse Extenders (PE) e 64 Pulse Decoders (DEC):] estendono l'impulso di match e lo indirizzano verso uno dei #strong[4 filtri analogici DPI dedicati per neurone]:
+ #raw("FEPSP") (#emph[Fast Excitatory] — tipo #strong[AMPA]);
+ #raw("SEPSP") (#emph[Slow Excitatory] — tipo #strong[NMDA] con #emph[voltage-gating]);
+ #raw("FIPSP") (#emph[Subtractive Inhibitory] — tipo #strong[#mi("\\text{GABA}_B")]);
+ #raw("SIPSP") (#emph[Shunting Inhibitory] — tipo #strong[#mi("\\text{GABA}_A")]);
- #strong[1 Soma Analogico AdExp-I&F] e #strong[1 blocco di Handshaking (HS)].
- #strong[Infrastruttura di Routing Digitale Asincrono QDI (R1, R2, R3 — Figura 19):]
Progettata senza alcun clock globale tramite sintesi formale di Martin (#emph[Communicating Hardware Processes] CHP #mi("\\to") #emph[Handshaking Expansion] HSE a 4 fasi con codifica #strong[dual-rail] #mi("\\to") #emph[Production Rules] CMOS con #strong[C-elements di Muller]):
- #strong[Router R1 (1 per core):] Contiene un #emph[Memory Address Loop] e una #strong[SRAM asincrona da #mi("20\\,\\text{kbit}")] (#mi("1024 \\times 20\\,\\text{bit}")). Quando un neurone spara, il loop legge fino a 4 parole SRAM da 20 bit (ciascuna contenente: #raw("10-bit Tag") + #raw("6-bit relative XY chip address") #mi("\\Delta X, \\text{sign}X, \\Delta Y, \\text{sign}Y") + #raw("4-bit Core ID")), consentendo un fan-out massimo di #strong[#mi("4\\text{k}") (#mi("4096")) neuroni post-sinaptici].
- #strong[Router R2 (Albero Intra-Chip):] Collega i 4 router R1 del chip; se #mi("\\Delta X = 0 \\land \\Delta Y = 0"), smista l'evento direttamente al core locale tramite alberi #emph[Controlled-Split] (#raw("SPT")), altrimenti lo invia a R3.
- #strong[Router R3 (2D-Mesh Inter-Chip XY):] Gestisce il routing relativo XY senza tabelle di routing attraverso le 4 porte cardinali (#raw("North"), #raw("South"), #raw("East"), #raw("West")) con una latenza intrinseca di soli #strong[#mi("2.5\\,\\text{ns}")] (latenza totale #emph[chip-to-chip] inclusi i pad pari a #strong[#mi("15.4\\,\\text{ns}")], throughput #strong[#mi("400\\,\\text{Mevents/s}")]).

#figure(image("figure/fig20_dynaps_node_and_cam_circuit.png", width: 88%), caption: [Diagramma a blocchi del nodo computazionale e schema transistor-level della memoria CAM asincrona 9T di DYNAPs])
#emph[Figura 20 — Estratta da Moradi et al. (2018), Fig. 9 e Fig. 10: (In alto) Diagramma a blocchi di uno dei 256 nodi computazionali di un core DYNAP-SE (64 parole miste da 10-bit CAM + 2-bit SRAM, 64 PG, 64 PE, 64 DEC, 4 filtri sinaptici DPI \[FEPSP, SEPSP, FIPSP, SIPSP\], 1 soma AdEx e blocco HS). (In basso) Circuito della memoria CAM asincrona: a sinistra, organizzazione della matrice #mi("16\\times 16") nel core con #raw("Event BUF"), #raw("Validity Check (VC)") e cella dummy #raw("CAM_D"); a destra, schematico transistor-level della cella CAM a 9 transistor (9T NOR-type) con inverter a bassa soglia #raw("LTH"), pull-up #raw("Weak_up") e Pulse Generator.]

#figure(image("figure/fig24_dynapse2_analog_neuron_dpi_block.png", width: 88%), caption: [Dettaglio del compartimento neuronale e dei 4 filtri DPI in DYNAP-SE2])
#emph[Figura 24 — Estratta da Bartels et al. (2025), Fig. 7: Micrografia del die DYNAP-SE2 con zoom su un core neurale e schema a blocchi del compartimento neuronale analogico (routing per 64 sinapsi, peso a 4-bit, 4 blocchi DPI \[fast exc, slow exc, slow inh, fast inh\] sommati nel soma Exp. I&F).]

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 4.4.3 Circuito della Memoria CAM Asincrona a 9 Transistor (9T NOR-type) e Invarianza Spaziale del #emph[Pulse-Width]

Il circuito più critico per l'efficienza di DYNAP-SE è la #strong[memoria CAM asincrona a 9 transistor (9T NOR-type)] mostrata in #strong[Figura 20 (in basso a destra)]:
- #strong[Cella 9T NOR-type e \*Match-Line\* Pre-Caricata Alta:]
Ogni bit della parola CAM da 10 bit utilizza una cella SRAM di memorizzazione accoppiata a transistor di confronto di tipo NOR collegati alla linea comune #raw("M_line<0>"). Durante lo stato neutro delle search-lines (#raw("SL = 0, SLB = 0")), il blocco #emph[Validity Check] (#raw("VC"), posto nell'angolo in alto a destra del core) mantiene #raw("PreB = 0"), pre-caricando tutte le #mi("64 \\times 256 = 16\\,384") #raw("M_line") del core a #mi("V_{\\text{dd}}"). All'arrivo di un evento, #raw("PreB") passa a #mi("1"): qualsiasi bit non corrispondente (#emph[miss]) accende il proprio ramo nMOS scaricando #raw("M_line") a massa; solo le parole con tutti i 10 bit in #emph[match] mantengono #raw("M_line") alta. Un #strong[inverter a bassa soglia (#raw("LTH"))] con un #strong[pMOS di pull-up debole (#raw("Weak_up"))] in retroazione compensa la corrente di leakage sottosoglia dei 10 rami NOR spenti, evitando falsi #emph[miss].
- #strong[Cella Dummy #raw("CAM_D") e Cancellazione Esatta del Mismatch Spaziale di Ritardo:]
Poiché l'impulso #raw("Match") generato dalla CAM pilota i convertitori di corrente analogici, una variazione della sua larghezza temporale #mi("\\Delta t_{\\text{pulse}}") tra il primo e l'ultimo neurone del core introdurrebbe un grave errore sistematico sui pesi sinaptici. Per evitarlo senza appesantire ogni cella con logica QDI, nell'angolo opposto a #raw("VC") (in basso a destra) è inserita una #strong[parola CAM dummy (#raw("CAM_D"))] cablata per avere sempre #strong[un solo bit su 10 in stato di \*miss\* (\*worst-case miss\*, scarica più lenta possibile)]. Quando #raw("CAM_D") completa la scarica, asserisce il segnale globale #raw("Check = 1"). Sia #raw("PreB") (che determina il fronte di discesa #mi("t_{\\text{dx}}") dell'impulso di match) sia #raw("Check") (che determina il fronte di salita #mi("t_{\\text{ux}}")) vengono propagati attraverso catene di buffer identiche nella #strong[stessa direzione spaziale (dall'alto a sinistra verso il basso a destra)]. Di conseguenza, per una generica sinapsi #mi("\\text{CAM}_x") i ritardi di propagazione spaziale #mi("t_{\\text{d1x}}") e #mi("t_{\\text{d2x}}") si elidono esattamente:
#mitex("\\Delta t_{\\text{pulse},x} = t_{\\text{dx}} - t_{\\text{ux}} = \\left(t_{\\text{pre}} + t_{\\text{d2x}}\\right) - \\left(t_{\\text{ck}} + t_{\\text{d1x}}\\right) \\approx t_{\\text{pre}} - t_{\\text{ck}}")
garantendo una larghezza d'impulso #strong[costante e invariante rispetto alla posizione fisica del neurone sul die] (tempo totale di broadcast + search pari a soli #strong[#mi("27\\,\\text{ns}")])!


#line(length: 100%, stroke: 0.5pt + luma(200))

= Capitolo 5 — Confronto Multiparametrico Globale e Analisi dei Compromessi (Trade-off)

In conformità alle richieste della traccia d'esame, questo capitolo mette a confronto in modo sistematico tutte le implementazioni di neuroni al silicio e tutti i sistemi/processori neuromorfici esaminati nei 7 articoli scientifici secondo i sette parametri ingegneristici chiave: #strong[tensione di alimentazione (#mi("V_{\\text{DD}}")), consumo statico, potenza dinamica/totale, energia per spike, area silicea, frequenza di firing (e costanti di tempo) e variabilità dei parametri (\*device mismatch\*)].

#line(length: 100%, stroke: 0.5pt + luma(200))

== 5.1 Confronto Sinottico delle Topologie di Neuroni al Silicio (SiN)

La #strong[Tabella 5.1] sintetizza e confronta le principali topologie circuitali di neuroni spiking analizzate nel Capitolo 4 (integrando la Tabella 2 di #emph[Indiveri et al., 2011] con i dati quantitativi estratti da #emph[Qiao et al., 2015], #emph[Ronchini et al., 2023] e #emph[Wu et al., 2026]).

#strong[Tabella 5.1 — Confronto multiparametrico delle topologie circuitali CMOS di neuroni spiking]

#block(breakable: true, width: 100%)[
  #set text(size: 7.5pt)
  #table(columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr), stroke: 0.5pt + luma(180), inset: 4.5pt,
    table.header([#strong[Topologia Circuito Neurone (Riferimento)]], [#strong[Regime Operativo e Stile Circuitale]], [#strong[Modello Matematico Implementato]], [#strong[Nodo CMOS / #mi("V_{\\text{DD}}") Tipica]], [#strong[Componenti del Soma (Transistor + Cap.)]], [#strong[Potenza / Energia per Spike]], [#strong[Area del Singolo Soma]], [#strong[Scala Temporale e Firing Rate]], [#strong[Sensibilità al Mismatch e Compromessi Principali]]),
    [#strong[Axon-Hillock] #emph[(Mead, 1989)]], [Sub-threshold, Voltage-mode, asincrono], [Basic I&F (non-leaky o con leak)], [#mi("0.6\\text{-}2\\,\\mu\\text{m}") / #mi("3.3\\text{-}5\\,\\text{V}")], [#mi("\\sim 6\\text{-}8\\,\\text{MOS} + 2\\,\\text{Cap}") (#mi("C_{\\text{mem}}, C_{\\text{fb}}"))], [#mi("\\sim \\mu\\text{W}") (alta corrente di corto circuito)], [Molto compatta], [Real-time (#mi("\\text{Hz}\\text{-}\\text{kHz}"))], [#strong[Basso mismatch] (dipende da #mi("C_{\\text{fb}}/C_{\\text{mem}}")), ma #strong[alto consumo] per ingressi lenti sulla soglia dell'inverter.],
    [#strong[Voltage-Amplifier I&F] #emph[(van Schaik, 2001)]], [Sub-threshold, Voltage-mode, asincrono], [Leaky I&F con #mi("V_{\\text{thr}}"), #mi("I_{\\text{Na}}"), #mi("I_{\\text{K}}") e refrattarietà], [#mi("0.5\\text{-}0.8\\,\\mu\\text{m}")], [#mi("\\sim 18\\,\\text{MOS} + 2\\,\\text{Cap}") (#mi("C_{\\text{mem}}, C_K"))], [#mi("\\sim 100\\,\\text{nW}\\text{-}\\mu\\text{W}")], [Media], [Real-time (#mi("\\text{Hz}\\text{-}\\text{kHz}"))], [Controllo indipendente di #mi("V_{\\text{thr}}"), #emph[spike width] (#mi("I_{\\text{Kup}}")) e refrattarietà (#mi("I_{\\text{Kdn}}")); consumo statico dell'OTA.],
    [#strong[Thalamic Relay 2-Comp.] #emph[(Hynna & Boahen, 2009)]], [Sub-threshold, Termodinamico, Voltage/Log], [Conduttanza a 2 compartimenti (canale #mi("\\text{Ca}^{2+}") #mi("I_T"))], [#mi("0.25\\text{-}0.5\\,\\mu\\text{m}")], [#mi("\\sim 15\\,\\text{MOS} + 3\\,\\text{Cap}")], [Basso consumo (#mi("\\text{nW}"))], [Compatta], [Real-time (Tonic & Burst)], [Riproduce fedelmente gating sigmoidale #mi("u_\\infty(V)") e #mi("\\tau_u(V)") a campana con soli 2 MOS; soggetto a mismatch sub-threshold.],
    [#strong[Sub-threshold H–H] #emph[(Yu & Cauwenberghs, 2010a)]], [Sub-threshold, Current-mode Log-domain], [Hodgkin–Huxley completo (#mi("m^3 h, n^4"))], [#mi("0.5\\,\\mu\\text{m}") / #mi("3.3\\,\\text{V}")], [Moltiplicatori translineari + Tau-cells + DAC spline], [#mi("\\sim \\mu\\text{W}")], [#strong[Grande] (non compatto: 4 neuroni/chip)], [Real-time scalabile tramite bias], [Altissimo realismo biofisico e programmabilità a 7 punti spline, ma area proibitiva per grandi matrici.],
    [#strong[Octopus Retina I&F] #emph[(Culurciello et al., 2003)]], [Sub-threshold, Feedback in corrente], [Basic I&F ultra-low-power], [#mi("0.6\\,\\mu\\text{m}") / #mi("3.0\\,\\text{V}")], [#mi("\\sim 12\\,\\text{MOS} + 1\\text{-}2\\,\\text{Cap}")], [#strong[#mi("< 4\\,\\text{pJ/spike}")]], [Molto compatta], [Real-time (fino a #mi("\\text{kHz}"))], [Feedback positivo in corrente (#mi("\\times 100") velocità) + disconnessione di #mi("C_{\\text{mem}}") (#mi("\\div 25") potenza); assenza di adattamento.],
    [#strong[DVS Differencing SiN] #emph[(Lichtsteiner et al., 2008)]], [Sub-threshold + Cap-feedback], [Basic ON/OFF Differencing I&F], [#mi("0.35\\,\\mu\\text{m}") / #mi("3.3\\,\\text{V}")], [Fotorecettore + Amp #mi("C_1/C_2 + 2") comp.], [#mi("\\sim 100\\,\\text{nW/pixel}")], [#mi("40 \\times 40\\,\\mu\\text{m}^2")], [Real-time (fino a #mi(">1\\,\\text{kHz}"))], [#strong[Mismatch bassissimo] (#mi("1\\,\\text{mV}") eq., #mi("2\\%") contrasto) grazie al blocco DC su #mi("C_1") e guadagno #mi("-C_1/C_2 = -20").],
    [#strong[Tau-Cell Neuron] #emph[(van Schaik et al., 2010)]], [Sub-threshold, Current-mode Log-domain], [Leaky I&F in modalità corrente], [#mi("0.35\\text{-}0.5\\,\\mu\\text{m}")], [#mi("16\\,\\text{MOS}") (#mi("M_1\\text{-}M_{\\text{16}}")) #mi("+ 1\\,\\text{Cap}") (#mi("C_{\\text{mem}}"))], [Basso consumo (#mi("\\text{nW}"))], [Compatta e modulare], [Real-time (#mi("\\text{Hz}\\text{-}\\text{kHz}"))], [Lineare nelle correnti; sensibile al mismatch sugli specchi di corrente e riferimenti #mi("V_{\\text{ref}}").],
    [#strong[Log-Domain LPF (LLN)] #emph[(Arthur & Boahen, 2007)]], [Sub-threshold, Current-mode Log-domain], [Modello a 2 variabili con feedback cubico (#mi("v^3/3"))], [#mi("0.25\\,\\mu\\text{m}")], [#mi("16\\,\\text{MOS} + 3\\,\\text{Cap}") (#mi("C_{\\text{mem}}, C_P, C_R"))], [#strong[#mi("50\\text{-}1000\\,\\text{nW}")]], [Compatta], [Real-time (RS, SFA, Bursting)], [Pochi transistor e ricco repertorio dinamico; guadagno e costante di tempo accoppiati nel filtro LPF semplice.],
    [#strong[DPI Neuron (AdEx)] #emph[(Indiveri 2010; ROLLS 2015; DYNAP-SE 2018)]], [Sub-threshold, Current-mode Log-domain (DPI)], [#strong[Adaptive Exponential I&F (AdEx)] + NMDA gating], [#mi("180\\,\\text{nm}") / #strong[#mi("1.3\\text{-}1.8\\,\\text{V}")]], [#mi("21\\,\\text{MOS}") (base) / #strong[#mi("29\\,\\text{MOS}")] (in ROLLS) #mi("+ 3\\,\\text{Cap}")], [#strong[#mi("260\\,\\text{pJ/spike}")] (\@ #mi("1.3\\,\\text{V}")) / #strong[#mi("883\\,\\text{pJ/spike}")] (\@ #mi("1.8\\,\\text{V}"))], [#strong[#mi("918\\,\\mu\\text{m}^2")] (#mi("55.69 \\times 16.48\\,\\mu\\text{m}^2") in ROLLS)], [Real-time (#mi("\\tau \\in [0.1\\,\\text{ms}, 500\\,\\text{ms}]"), firing #mi("0\\text{-}600\\,\\text{Hz}"))], [Grado di libertà extra #mi("V_{\\text{thr}}"); con #emph[sizing] #mi("W/L = 2/4\\,\\mu\\text{m}") e #mi("1/4\\,\\mu\\text{m}") riduce il mismatch #mi("f\\text{-}I") al #strong[#mi("9.4\\%")] (ROLLS) / CV #mi("20\\text{-}30\\%") sui bias (DYNAP-SE2).],
    [#strong[Izhikevich Above-Thr.] #emph[(Wijekoon & Dudek, 2008)]], [#strong[Strong inversion], Voltage-mode], [Izhikevich 2D quadratico (#mi("V, U"))], [#mi("0.35\\,\\mu\\text{m}") / #mi("3.3\\,\\text{V}")], [#mi("14\\,\\text{MOS}") (#mi("M_1\\text{-}M_{\\text{14}}")) #mi("+ 2\\,\\text{Cap}") (#mi("C_v, C_u"))], [#strong[#mi("< 10\\,\\text{pJ/spike}")]], [Molto compatta], [#strong[Tempo accelerato (#mi("\\times 10^4"))] (#mi("\\sim \\text{MHz}"))], [Bassissima energia/spike e alta velocità, ma costanti di tempo #mi("\\times 10^4") più veloci della biologia (inadatto al #emph[real-time] diretto senza rallentamento).],
    [#strong[Izhikevich Sub-Thr. (NET-TEN)] #emph[(Ronchini et al., 2023)]], [#strong[Sub-threshold ultra-low-#mi("V_{\\text{DD}}")], Voltage-mode], [Izhikevich 2D (#mi("V_{\\text{mem}}, U"))], [#mi("180\\,\\text{nm}") / #strong[#mi("0.25\\,\\text{V}") (#mi("250\\,\\text{mV}"))]], [#mi("12\\,\\text{MOS}") (#mi("M_1\\text{-}M_{\\text{12}}")) #mi("+ 2\\,\\text{Cap}") (#mi("C_v=76.9\\,\\text{fF}, C_u=614.9\\,\\text{fF}"))], [#strong[#mi("0.68\\,\\text{pW}") statici] / #strong[#mi("3.50\\,\\text{nW}")] (intera rete 30 neuroni!)], [#strong[#mi("1476.84\\,\\mu\\text{m}^2")]], [Real-time (#mi("\\text{Hz}\\text{-}\\text{centinaia di Hz}"))], [Consumo paragonabile al neurone biologico (#mi("0.5\\text{-}4\\,\\text{nW}")); l'elevato mismatch a #mi("0.25\\,\\text{V}") rende informativi 4 canali di uscita su 10.],
    [#strong[BiCMOS SiGe H–H] #emph[(Saighi et al., 2011)]], [Bipolar / Above-threshold, Voltage-mode], [Hodgkin–Huxley esatto], [#mi("0.35 / 0.8\\,\\mu\\text{m}") SiGe BiCMOS], [Moltiplicatori BJT + condensatori esterni/grandi], [#mi("\\sim \\text{mW}")], [Grande (non compatto)], [Real-time], [Elevata precisione e ripetibilità per esperimenti bio-ibridi #emph[patch-clamp], ma alto consumo e area.],
    [#strong[Accelerated Conductance] #emph[(Schemmel et al., 2006)]], [#strong[Strong inversion], Voltage-mode (OTA)], [Leaky I&F basato su conduttanza], [#mi("180\\,\\text{nm}") / #mi("1.8\\,\\text{V}")], [#mi("10\\,\\text{MOS} + 2\\,\\text{OTA} + \\text{Spike Amp} + C_{\\text{mem}}")], [#mi("\\sim \\text{mW}") (correnti fino a #mi("10\\text{-}500\\,\\mu\\text{A}"))], [Media], [#strong[Tempo accelerato (#mi("\\times 10^4\\text{-}10^5"))] (#mi("10\\,\\text{ns}") rise time)], [Eccellente riproducibilità rispetto al simulatore software NEST, ma alte correnti e incompatibilità col tempo reale biologico.],
    [#strong[Switched-Capacitor M–N] #emph[(Folowosele et al., 2009)]], [#strong[Switched-Capacitor] a tempo discreto (#mi("\\phi_1, \\phi_2"))], [Mihalas–Niebur (soglia adattativa #mi("\\Theta"))], [#mi("0.35 / 0.5\\,\\mu\\text{m}")], [#mi("5\\,\\text{MOS} + 4\\,\\text{blocchi S-C} + C_m, C_\\Theta")], [Basso/Medio], [Compatta e modulare], [Tempo discreto (controllato da #mi("f_{\\text{clk}}"))], [#strong[Altissima immunità al mismatch] (dipende da rapporti capacitivi e clock), riproduce 10 pattern senza tuning; richiede distribuzione di fasi di clock.],
    [#strong[Charge-Packet Calibrated] #emph[(Serrano-Gotarredona, 2006)]], [Impulsato (#mi("100\\,\\text{ns}")) + calibrazione #strong[Digi-MOS 5-bit]], [Basic Leaky I&F], [#mi("0.35\\,\\mu\\text{m}")], [Specchi impulsati + DAC 5-bit], [Basso], [#mi("90 \\times 90\\,\\mu\\text{m}^2") (#mi("8100\\,\\mu\\text{m}^2"))], [Real-time / Event-driven], [Precisione effettiva dei pesi di 3 bit + segno grazie alla calibrazione locale Digi-MOS; richiede impulso periodico globale per il leak.],
    [#strong[Digital / Clockless I&F] #emph[(Xylo 2024; NeuroSEED 2026)]], [#strong[All-Digital] sincrono (Xylo) o #strong[Clockless] asincrono (NeuroSEED)], [LIF digitale (Xylo) / Valley-to-Peak I&F (NeuroSEED)], [#mi("28\\,\\text{nm}") (#mi("1.8\\,\\text{V}")) / #mi("40\\,\\text{nm}") (#mi("0.6\\text{-}1.2\\,\\text{V}"))], [Registri, contatori e comparatori digitali], [#strong[#mi("0.48\\,\\mu\\text{W/ch}")] (Spike Det. NeuroSEED)], [#strong[#mi("700\\,\\mu\\text{m}^2")] (#mi("0.0007\\,\\text{mm}^2") in 40 nm)], [Real-time streaming / Event-driven], [#strong[Zero mismatch analogico], perfettamente scalabile nei nodi avanzati (28–40 nm), immune al baseline wander.],
  )
]

#line(length: 100%, stroke: 0.5pt + luma(200))

== 5.2 Confronto Multiparametrico Completo dei Processori e Sistemi Neuromorfici Analizzati (7 Articoli)

La #strong[Tabella 5.2] confronta in dettaglio tutti e 7 i lavori della bibliografia d'esame, mettendo in luce l'evoluzione tecnologica dai circuiti fondamentali fino ai SoC biomedicali impiantabili completi del 2023–2026.

#strong[Tabella 5.2 — Confronto multiparametrico globale dei 7 articoli scientifici analizzati]

#block(breakable: true, width: 100%)[
  #set text(size: 7.5pt)
  #table(columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr), stroke: 0.5pt + luma(180), inset: 4.5pt,
    table.header([#strong[Parametro / Metrica]], [#strong[#strong[1. Indiveri et al. (2011)] #emph[(Frontiers Neurosci.)]]], [#strong[#strong[2. ROLLS — Qiao et al. (2015)] #emph[(Frontiers Neurosci.)]]], [#strong[#strong[3. NET-TEN — Ronchini et al. (2023)] #emph[(J. Neural Eng.)]]], [#strong[#strong[4. WaveSense su Xylo — Li et al. (2024)] #emph[(Comput. Biol. Med.)]]], [#strong[#strong[5. DYNAPs / DYNAP-SE — Moradi et al. (2018)] #emph[(IEEE TBioCAS)]]], [#strong[#strong[6. Seizure SNN su DYNAP-SE2 — Bartels et al. (2025)] #emph[(Sci. Reports)]]], [#strong[#strong[7. NeuroSEED SoC — Wu et al. (2026)] #emph[(IEEE JETCAS)]]]),
    [#strong[Tipologia di Sistema e Paradigma]], [Rassegna di circuiti SiN analogici (sub/above-thr.), S-C e digitali], [Processore neuromorfico mixed-signal con learning on-line], [Rete SNN analogica in sottosoglia + post-proc. digitale 2 contatori], [Processore ASIC SNN #strong[all-digital] edge per inferenza streaming], [Processore multi-core mixed-signal con memorie eterogenee CAM/SRAM], [Sistema mixed-signal (AFE+ADM + SNN a 2 layer) su DYNAP-SE2], [#strong[SoC impiantabile completo a 32 ch] (TDM AFE + ASC + I&F Det. + UWB TX)],
    [#strong[Applicazione e Segnale Biologico]], [Emulazione biofisica corticale, retine DVS, protesi neurali], [Working memory (attrattori) e classificazione visione DVS], [#strong[Rilevazione crisi epilettiche (Ictal vs Interictal/Artifact) in LFP] (topo CTX)], [#strong[Rilevazione crisi epilettiche real-time in Scalp EEG] (CHB-MIT, Siena)], [Riconoscimento pattern rapidi (CNN su Poker-DVS) e reti multi-chip], [#strong[Rilevazione crisi epilettiche in iEEG umano] (SWEC-ETHZ, 42–62 ch)], [#strong[Spike detection intracorticale/periferico e telemetria wireless] (ratto L5)],
    [#strong[Tecnologia CMOS]], [#mi("0.8\\,\\mu\\text{m} \\to 180\\,\\text{nm}") CMOS / BiCMOS SiGe], [#strong[180 nm CMOS] (1P6M, #mi("\\sim 12.2\\text{M}") MOS)], [#strong[180 nm TSMC CMOS] (full-custom sub-threshold)], [#strong[28 nm CMOS]], [#strong[180 nm CMOS] (1P6M)], [#strong[180 nm CMOS] (DYNAP-SE2 con AFE integrato)], [#strong[40 nm TSMC CMOS] (transistor thick-oxide e low-#mi("V_t"))],
    [#strong[Architettura Neuroni e Sinapsi]], [H–H, Tau-cell, LLN, #strong[DPI (AdEx)], Izhikevich, Mihalas–Niebur], [#strong[256 neuroni AdEx], #mi("64\\text{K}") LTP bistabili + #mi("64\\text{K}") STP (2-bit + STD) + 512 virtuali], [#strong[30 neuroni Izhikevich] (3 layer #mi("10\\text{-}10\\text{-}10"), fan-out 2), #strong[40 EPSC], #strong[30 STDP]], [#strong[1000 hidden LIF] + #strong[8 readout LIF] digitali (modello: #strong[2.4K pesi] a 8-bit, 16 readout)], [#strong[4 core #mi("\\times") 256 = 1024 neuroni AdEx], #mi("64\\text{K}") CAM (fan-in 64) + #mi("4\\text{K}") SRAM (fan-out #mi("4\\text{k}")), 4 DPI/soma], [#strong[#mi("4M") neuroni AdEx su 3 core]: Translation Layer (#mi("3M"): FF-I, R-E, R-I) + NLNG Layer (#mi("M"), #raw("1-2-1-0-1-2-1"))], [#strong[32 ch TDM AFE + 32 ASC + 32 Clockless I&F Valley-to-Peak Detectors]],
    [#strong[Tensione di Alimentazione (#mi("V_{\\text{DD}}"))]], [#mi("1.0\\,\\text{V} \\text{ - } 5.0\\,\\text{V}")], [#strong[#mi("1.8\\,\\text{V}")]], [#strong[#mi("0.25\\,\\text{V}") (#mi("250\\,\\text{mV}"))] per SNN; #strong[#mi("0.30\\,\\text{V}")] per contatori digitali], [#strong[#mi("1.8\\,\\text{V}") (Core)] / #strong[#mi("2.5\\,\\text{V}") (I/O SPI)]], [#strong[#mi("1.3\\,\\text{V} \\text{ - } 1.8\\,\\text{V}") (Core)] / #strong[#mi("1.8\\text{-}3.3\\,\\text{V}") (I/O)]], [#strong[#mi("1.8\\,\\text{V}")]], [#strong[#mi("1.2\\,\\text{V}")] (AFE/UWB) / #strong[#mi("0.6\\,\\text{V}")] (ASC/logica low-#mi("V_t"))],
    [#strong[Consumo Statico]], [Sub-pA / nW in sottosoglia; #mi("\\mu\\text{W}\\text{-}\\text{mW}") sopra soglia], [Basso (correnti di bias sub-threshold pA–nA)], [#strong[#mi("0.68\\,\\text{pW}")] (intera rete SNN a riposo!)], [Dominato da leakage SRAM 124 KB e bias digitale], [Decine di #mi("\\mu\\text{W}") a #mi("0\\,\\text{Hz}") (Fig. 11)], [Minimo nei periodi silenti (#strong[#mi("1.77\\,\\mu\\text{W}")] su 56 ch in pre-ictal Pat. 2)], [Comparatori ASC #strong[power-gated] (zero statico in folding); UWB in #emph[deep sleep]],
    [#strong[Potenza Dinamica e Totale]], [#mi("50\\text{-}1000\\,\\text{nW}") (LLN); #mi("\\sim \\mu\\text{W}") (DPI)], [#strong[#mi("\\approx 4\\,\\text{mW}")] (attività tipica di rete)], [#strong[#mi("3.50\\,\\text{nW}")] (SNN) #mi("+ \\mathbf{31\\,\\text{pW}}") (cnt 8b) #mi("= \\mathbf{3.53\\,\\text{nW}}") totali], [#strong[#mi("287.9\\,\\mu\\text{W}") (Core)] #mi("+ \\mathbf{87.4\\,\\mu\\text{W}}") #strong[(I/O)] #mi("= \\mathbf{375.3\\,\\mu\\text{W}}") totali], [#strong[#mi("1.4\\,\\text{mW}")] (\@ #mi("1.3\\,\\text{V}"), 1024 neuroni a #mi("100\\,\\text{Hz}")) / #strong[#mi("4.75\\,\\text{mW}")] (\@ #mi("1.8\\,\\text{V}"))], [#strong[Media #mi("149.96\\,\\mu\\text{W}")] (#mi("66.6\\text{-}297.1\\,\\mu\\text{W}"), pari a #strong[#mi("2.80\\,\\mu\\text{W/ch}")]) per la SNN], [#strong[#mi("63.61\\,\\mu\\text{W}") totali] (#strong[#mi("1.99\\,\\mu\\text{W/ch}")]): AFE #mi("38.4\\,\\mu\\text{W}"), Det. #mi("15.36\\,\\mu\\text{W}"), ASC #mi("5.25\\,\\mu\\text{W}"), UWB #mi("4.6\\,\\mu\\text{W}")],
    [#strong[Energia per Spike / Operazione]], [#strong[#mi("< 4\\,\\text{pJ/spike}")] (Octopus); #strong[#mi("< 10\\,\\text{pJ/spike}")] (Izhikevich #mi("0.35\\,\\mu\\text{m}"))], [#mi("\\sim \\text{ centinaia di pJ/spike}")], [#strong[#mi("11.4\\,\\text{fJ/spike}")] (cnt 3b) #mi("\\implies \\mathbf{148.2\\,\\text{fJ/classificazione}}") (13 spike)], [Minimizzata via regolarizzatore di attività nella Loss e #emph[bit-shift decay]], [\@ #mi("1.3 / 1.8\\,\\text{V}"): Soma #strong[#mi("260 / 883\\,\\text{pJ}")], PE #strong[#mi("26 / 324\\,\\text{pJ}")], En #strong[#mi("507 / 883\\,\\text{pJ}")], Broadcast CAM #strong[#mi("2.2 / 6.84\\,\\text{nJ}")], Route #strong[#mi("78 / 360\\,\\text{pJ}")], Hop #strong[#mi("17\\,\\text{pJ}")]], [\@ #mi("1.8\\,\\text{V}"): Input #strong[#mi("1207\\,\\text{pJ}")] (#mi("883") soma #mi("+ 324") PE); Output #strong[#mi("8083\\,\\text{pJ}")] (#mi("883") En #mi("+ 6840") Br #mi("+ 360") Rt) #mi("= \\mathbf{9.29\\,\\text{nJ/evento}}")], [TX UWB: #strong[#mi("17.16\\,\\text{pJ/bit}")] (\@ #mi("25\\,\\text{Mbps}") continuo), #strong[#mi("0.78\\,\\text{nJ/tx-bit}")] (spike-gated); FoM AFE #strong[#mi("0.265\\,\\text{nW/Hz}")]],
    [#strong[Area di Silicio (Totale e Blocchi)]], [Da #mi("40\\times 40\\,\\mu\\text{m}^2") (DVS) a #mi("100\\times 100\\,\\mu\\text{m}^2") (digitale)], [#strong[#mi("51.4\\,\\text{mm}^2")] (Soma #mi("918\\,\\mu\\text{m}^2") \[#mi("0.47\\%")\]; Sinapsi LTP+STP #mi("33.28\\,\\text{mm}^2") \[#mi("64.7\\%")\])], [#strong[#mi("1.08\\,\\text{mm}^2")] (Soma #mi("1476.8\\,\\mu\\text{m}^2"), EPSC #mi("462.1\\,\\mu\\text{m}^2"), STDP #mi("1054.8\\,\\mu\\text{m}^2"))], [#strong[#mi("6.5\\,\\text{mm}^2")] (include 124 KB SRAM)], [#strong[#mi("43.79\\,\\text{mm}^2") die] (#mi("38.5\\,\\text{mm}^2") core: Memorie #mi("31.7\\%"), PE/DEC #mi("25.2\\%"), Neuroni+DPI #mi("22.8\\%"), Router #mi("9.7\\%"))], [#strong[#mi("77.2\\,\\text{mm}^2")] (die DYNAP-SE2 completo di 4 core + AFE)], [#strong[#mi("0.70\\,\\text{mm}^2") die] (#strong[#mi("0.16\\,\\text{mm}^2") attivi]: AFE #mi("32.5\\%"), ASC #mi("31.25\\%"), UWB #mi("21.25\\%"), Spike Det. #mi("15\\%") \[#mi("700\\,\\mu\\text{m}^2\\text{/ch}")\])],
    [#strong[Frequenza di Firing e Costanti di Tempo]], [Real-time (#mi("\\text{Hz}\\text{-}\\text{kHz}")) o Accelerato (#mi("\\times 10^4\\text{-}10^5"))], [Real-time: firing #strong[#mi("0\\text{-}150\\,\\text{Hz}")] (attrattori #mi("15\\text{-}81\\,\\text{Hz}")), #mi("\\tau \\sim 10\\text{-}500\\,\\text{ms}")], [Real-time: #mi("\\tau_{\\text{EPSC}} = 212.83\\,\\mu\\text{s}") (#mi("I_{\\text{peak}} = 486.4\\,\\text{pA}")), #mi("\\text{ISI}_{\\text{I}-\\text{II}} = 4.3\\,\\text{ms}") in crisi], [Clock max #strong[#mi("250\\,\\text{MHz}")]; #mi("\\tau_{\\text{mem}} = 2\\,\\text{ms}"), finestra streaming #mi("0.5\\,\\text{s}")], [Real-time: firing #strong[#mi("0\\text{-}100+\\,\\text{Hz}")], broadcast time #strong[#mi("27\\,\\text{ns}")] (#mi("38\\,\\text{Meps/core}"))], [Real-time: Translation Layer passa-banda #strong[#mi("200\\text{-}600\\,\\text{Hz}")]; NLNG #mi(">100\\,\\text{Hz}") in crisi], [Campionamento #mi("10.4\\,\\text{kHz/ch}") (#mi("f_{\\text{CHOP}} = 333\\,\\text{kHz}")), banda #strong[#mi("5.2\\,\\text{kHz/ch}")], #mi("T_{\\min,\\text{ASC}} < 498\\,\\text{ns}")],
    [#strong[Variabilità / Mismatch e Mitigazione]], [7 tecniche (cap-ratio, guadagno AC, Digi-MOS 5b, S-C, sizing, plasticità)], [#strong[Mismatch #mi("f\\text{-}I = 9.4\\%")] grazie a sizing #mi("M_{\\text{L4,5}}=2/4\\,\\mu\\text{m}") e #mi("M_{\\text{Na4}}=1/4\\,\\mu\\text{m}") + bistabilità], [Ottimizzazione #strong[Monte Carlo] (#mi("C_v, C_u")) + basso fan-out (2); #strong[4 canali su 10 informativi] per mismatch a #mi("0.25\\,\\text{V}")], [#strong[Assente] (logica digitale), ma #strong[perdita del #mi("3.4\\text{-}4.3\\%") di accuratezza per quantizzazione a 8-bit]], [Cella #strong[CAM\_D dummy] annulla il mismatch spaziale di #mi("\\Delta t_{\\text{pulse}}"); pooling di 64 neuroni/classe nella CNN], [#strong[#mi("\\text{CV} = 20\\text{-}30\\%") sui bias] in sottosoglia; mitigato con pesi fissi, ridondanza (#mi("\\times 10") sinapsi) e topologia NLNG], [Matching capacitivo #mi("C_1=C_2=6\\,\\text{pF}") nell'ASC + #strong[Digital DC-Servo Loop a 6-bit C-DAC] (residuo #mi("<16.4\\,\\text{mV}")) + rilevazione relativa valle-picco],
    [#strong[Prestazioni Biomedicali e Latenza]], [—], [Classificazione real-time Caltech-101 e working memory], [#strong[Precision = #mi("0.998")], #strong[Latenza mediana = #mi("56.7\\,\\text{ms}")] (grezza) / #strong[#mi("229.4\\,\\text{ms}")] (ictal-only, #mi("100\\%") rigetto artefatti)], [#strong[CHB-MIT: Acc. #mi("93.3\\%") (#mi("89.87\\%") H/W), Latenza #mi("0.5\\,\\text{s}")]; #strong[Siena: Acc. #mi("92.9\\%") (#mi("88.62\\%") H/W), Latenza #mi("0.75\\,\\text{s}")]], [#strong[100% accuratezza] su Poker-DVS CNN con #strong[latenza #mi("< 30\\,\\text{ms}")]], [#strong[LSVM NLNG FR: Acc. #mi("78.35\\%"), AUC #mi("80.91\\%")] (+#mi("8.15\\%") Sens. vs ADM); estrazione cluster sincronizzati], [#strong[#mi("\\text{IRN} = 2.9\\,\\mu\\text{V}_{\\text{rms}}"), #mi("\\text{NEF} = 2.1")], ASC #mi("\\text{ENOB} = 7.6\\,\\text{b}"), #strong[Compressione #mi(">500\\times")], link UWB #mi("100\\,\\text{Mbps}") attraverso #mi("1.5\\,\\text{cm}") cranio],
  )
]

#line(length: 100%, stroke: 0.5pt + luma(200))

== 5.3 Analisi Fisica del #emph[Device Mismatch] in Sottosoglia (Legge di Pelgrom) e Strategie di Mitigazione

Uno degli aspetti più critici emersi dal confronto tra i 7 articoli riguarda la #strong[variabilità dei parametri (\*device mismatch\*)] nei circuiti analogici CMOS in sottosoglia.

=== A. Derivazione Analitica dell'Amplificazione Esponenziale del Mismatch in Sottosoglia
Secondo la #strong[Legge di Pelgrom (Pelgrom et al., 1989)], due transistor adiacenti nominalmente identici di larghezza #mi("W") e lunghezza di canale #mi("L") presentano una variazione casuale della tensione di soglia #mi("\\Delta V_T") (dovuta alle fluttuazioni stocastiche di drogaggio nel canale) con deviazione standard inversamente proporzionale alla radice quadrata dell'area attiva #mi("W \\cdot L"):

#mitex("\\sigma(\\Delta V_T) = \\frac{A_{V_T}}{\\sqrt{W \\cdot L}}")

dove #mi("A_{V_T}") è la costante tecnologica di Pelgrom (tipicamente #mi("\\sim 3\\text{-}5\\,\\text{mV}\\cdot\\mu\\text{m}") in un nodo a #mi("180\\,\\text{nm}")).
- #strong[In Forte Inversione (\*Strong Inversion\*):] Poiché #mi("I_D = \\frac{1}{2}\\mu C_{\\text{ox}}\\frac{W}{L}(V_{\\text{GS}} - V_T)^2"), la variazione relativa di corrente vale:
#mitex("\\left(\\frac{\\sigma(\\Delta I_D)}{I_D}\\right)_{\\text{strong}} = \\frac{2 \\, \\sigma(\\Delta V_T)}{V_{\\text{GS}} - V_T}")
che può essere ridotta aumentando la tensione di overdrive #mi("(V_{\\text{GS}} - V_T)").
- #strong[In Debole Inversione (\*Sub-threshold / Weak Inversion\*):] Poiché la corrente dipende #strong[esponenzialmente] da #mi("V_T") secondo #mi("I_D \\propto \\exp\\left(-\\frac{\\kappa V_T}{U_T}\\right)"), una piccola deviazione #mi("\\Delta V_T") viene divisa per la piccolissima tensione termica #mi("U_T \\approx 25.8\\,\\text{mV}"):
#mitex("\\frac{I_{\\text{D1}}}{I_{\\text{D2}}} = \\exp\\left(-\\frac{\\kappa \\Delta V_T}{U_T}\\right) \\implies \\left(\\frac{\\sigma(\\Delta I_D)}{I_D}\\right)_{\\text{sub-thr}} \\approx \\frac{\\kappa}{U_T} \\sigma(\\Delta V_T) = \\frac{\\kappa}{U_T} \\frac{A_{V_T}}{\\sqrt{W \\cdot L}}")
Poiché #mi("\\frac{\\kappa}{U_T} \\approx 28\\,\\text{V}^{\\text{-1}}"), una dispersione #mi("\\sigma(\\Delta V_T)") di soli #mi("8\\,\\text{mV}") su un transistor di area minima produce un #strong[Coefficiente di Variazione (#mi("\\text{CV} = \\sigma/\\mu")) della corrente pari al #mi("22\\text{-}30\\%")] — esattamente il valore sperimentale #strong[#mi("\\text{CV} = 20\\text{-}30\\%")] misurato sulle correnti di bias di #strong[DYNAP-SE2] in #emph[Bartels et al. (2025)]!

=== B. Sintesi delle Strategie Circuitali e Architetturali di Mitigazione nei 7 Articoli
I lavori analizzati dimostrano come superare questo limite fisico su tre livelli:
+ #strong[A Livello di Dimensionamento Fisico (\*Transistor Sizing\* e Simulazione Monte Carlo):]
In #strong[ROLLS] (#emph[Qiao et al., 2015]), aumentando selettivamente l'area #mi("W \\cdot L") dei soli transistor che fissano la costante di tempo di leak (#mi("M_{\\text{L4}}, M_{\\text{L5}}") con #mi("W/L = 2\\,\\mu\\text{m}/4\\,\\mu\\text{m}")) e la soglia di innesco del Sodio (#mi("M_{\\text{Na4}}") con #mi("W/L = 1\\,\\mu\\text{m}/4\\,\\mu\\text{m}") e #mi("M_{\\text{Na3}}") con #mi("W/L = 4\\,\\mu\\text{m}/0.4\\,\\mu\\text{m}")), il mismatch della curva #mi("f\\text{-}I") sull'intero array di 256 neuroni scende al #strong[#mi("9.4\\%")]. In #strong[NET-TEN] (#emph[Ronchini et al., 2023]), i condensatori #mi("C_v = 76.86\\,\\text{fF}") e #mi("C_u = 614.88\\,\\text{fF}") sono dimensionati via Monte Carlo.
+ #strong[A Livello di Topologia Circuitale (Rapporti Capacitivi, Calibrazione Digi-MOS, Switched-Capacitor e Cella Dummy #raw("CAM_D")):]
- Sfruttare il matching superiore dei condensatori integrati rispetto ai MOSFET: nel circuito #strong[Axon-Hillock] (#mi("C_{\\text{fb}}/C_{\\text{mem}}")), nel sensore #strong[DVS] (guadagno #mi("-C_1/C_2 = -20") che riduce il mismatch a #mi("1\\,\\text{mV}")), nel circuito #strong[Switched-Capacitor di Mihalas–Niebur], e nel DAC di #emph[signal folding] dell'#strong[ASC di NeuroSEED] (#mi("C_1 = C_2 = 6\\,\\text{pF}")).
- Calibrazione digitale locale tramite #strong[Digi-MOS a 5-bit] (#emph[Indiveri et al., 2011], Fig. 7A) o tramite #strong[Digital DC-Servo Loop con C-DAC a 6-bit] (#strong[NeuroSEED], #emph[Wu et al., 2026]).
- Compensazione geometrica dei ritardi di propagazione tramite la cella dummy #strong[#raw("CAM_D")] in #strong[DYNAP-SE] (#emph[Moradi et al., 2018]), che rende la durata dell'impulso sinaptico #mi("\\Delta t_{\\text{pulse},x}") invariante rispetto alle coordinate spaziali nel core.
+ #strong[A Livello di Rete e Apprendimento (Bistabilità, Ridondanza di Popolazione e Architetture ENAS):]
- Nelle sinapsi #strong[LTP di ROLLS], il circuito bistabile #raw("BIST") attira i pesi verso due attrattori stabili (#mi("V_{\\text{dd}}") o #mi("\\text{GND}")), rendendoli immuni alla deriva.
- Nella CNN di #strong[DYNAP-SE] e nel classificatore di #strong[ROLLS], l'uscita è codificata da popolazioni ridondanti di #strong[64 neuroni per classe] (#emph[ensemble averaging]), dove le fluttuazioni stocastiche individuali si cancellano statisticamente.
- In #strong[DYNAP-SE2] (#emph[Bartels et al., 2025]), il mismatch del #mi("20\\text{-}30\\%") viene aggirato usando pesi unitari con #strong[molteplicità di connessioni fisiche in parallelo] (10 sinapsi per connessione nel #emph[Translation Layer]) e la topologia spaziale #raw("1-2-1-0-1-2-1") del layer #strong[NLNG].

#line(length: 100%, stroke: 0.5pt + luma(200))

= Capitolo 6 — Discussione Critica Conclusiva: Il Vero Bilancio Energetico nei Sistemi Biomedicali Impiantabili

Affrontiamo infine la domanda critica conclusiva posta dalla traccia:

#block(fill: rgb("#f0f4f8"), inset: 10pt, radius: 4pt, stroke: (left: 3pt + rgb("#2b6cb0")), width: 100%)[
  #strong[#emph[«Le SNN offrono un vantaggio energetico concreto per i sistemi biomedicali impiantabili oppure il consumo dei circuiti di acquisizione, delle sinapsi, della memoria e delle interconnessioni può ridimensionare il beneficio ottenuto con neuroni ultra-low-power?»]]
]

L'analisi incrociata dei dati quantitativi estratti dai 7 articoli permette di formulare una risposta ingegneristica rigorosa e priva di semplificazioni: #strong[valutare l'efficienza energetica di un sistema neuromorfico guardando esclusivamente al consumo del singolo soma spiking (#mi("<4\\text{-}883\\,\\text{pJ/spike}") o pochi nanowatt) è profondamente fuorviante]. Quando si passa dal singolo neurone isolato a un #strong[sistema biomedicale impiantabile completo end-to-end], il consumo energetico e l'occupazione d'area sono #strong[dominati per oltre il #mi("75\\text{-}90\\%") proprio dai circuiti di acquisizione (AFE), dalle sinapsi, dalle memorie di indirizzamento (CAM/SRAM) e dalle interconnessioni di routing/I/O].

Tuttavia, #strong[ciò non vanifica affatto il vantaggio delle SNN]: al contrario, i lavori più recenti (#strong[NET-TEN 2023], #strong[Xylo 2024], #strong[DYNAP-SE2 2025], #strong[NeuroSEED 2026]) dimostrano che quando l'intera catena (acquisizione, codifica, rete sinaptica, memoria e telemetria) viene #strong[co-progettata secondo il paradigma \*event-driven]\*, il sistema neuromorfico mantiene un #strong[vantaggio energetico concreto di #mi("10\\times \\text{ - } 1000\\times")] rispetto alle architetture digitali convenzionali. Dimostriamo analiticamente entrambe le facce di questa tesi attraverso quattro evidenze quantitative.

#line(length: 100%, stroke: 0.5pt + luma(200))

== 6.1 Scomposizione Quantitativa dei "Costi Nascosti": Acquisizione (AFE), Sinapsi, Memoria (CAM/SRAM), Clock/Bias e Interconnessioni

=== 1. Il Peso Dominante del Front-End di Acquisizione Analogica (AFE) e il Limite Fisico #mi("kT/C")
La prova sperimentale più nitida proviene dal SoC #strong[NeuroSEED (\*Wu et al., 2026\*, #raw("paperSNN7"))], che integra sull'unico die in 40 nm sia l'acquisizione a 32 canali sia l'elaborazione spiking e la telemetria wireless (Tabella 6.1 e Figura 29):

#strong[Tabella 6.1 — Ripartizione esatta di potenza e area attiva nel SoC impiantabile NeuroSEED (32 canali, TSMC 40 nm, #mi("V_{\\text{DD}}=1.2/0.6\\,\\text{V}"))]

#block(breakable: true, width: 100%)[
  #set text(size: 7.5pt)
  #table(columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr), stroke: 0.5pt + luma(180), inset: 4.5pt,
    table.header([#strong[Blocco Funzionale del SoC]], [#strong[Potenza Dissipata (#mi("\\mu\\text{W}"))]], [#strong[Quota sul Totale Potenza (%)]], [#strong[Potenza per Canale (#mi("\\mu\\text{W/ch}"))]], [#strong[Area Attiva (#mi("\\text{mm}^2"))]], [#strong[Quota sul Totale Area (%)]]),
    [#strong[1. Front-End Analogico (AFE: 32-Ch Mux-Chop + CCIA LNA + #mi("G_m\\text{-}C") WIS + C-DAC)]], [#strong[#mi("38.40\\,\\mu\\text{W}")]], [#strong[#mi("60.4\\%")]], [#mi("1.200\\,\\mu\\text{W}")], [#strong[#mi("0.052\\,\\text{mm}^2")]], [#strong[#mi("32.50\\%")]],
    [#strong[2. Convertitore Analogico-Spike (32#mi("\\times") ASC con Signal Folding)]], [#strong[#mi("5.25\\,\\mu\\text{W}")]], [#strong[#mi("8.2\\%")]], [#mi("0.164\\,\\mu\\text{W}")], [#strong[#mi("0.050\\,\\text{mm}^2")]], [#strong[#mi("31.25\\%")]],
    [#emph[Subtotale Stadio di Acquisizione e Conversione (AFE + ASC)]], [#strong[#emph[#mi("43.65\\,\\mu\\text{W}")]]], [#strong[#emph[#mi("68.6\\%")]]], [#strong[#emph[#mi("1.38\\,\\mu\\text{W/ch}")]]], [#strong[#emph[#mi("0.102\\,\\text{mm}^2")]]], [#strong[#emph[#mi("63.75\\%")]]],
    [#strong[3. Elaborazione Spiking (32#mi("\\times") Clockless I&F Spike Detector)]], [#strong[#mi("15.36\\,\\mu\\text{W}")]], [#strong[#mi("24.2\\%")]], [#strong[#mi("0.480\\,\\mu\\text{W}")]], [#strong[#mi("0.024\\,\\text{mm}^2")]], [#strong[#mi("15.00\\%")]],
    [#strong[4. Telemetria Wireless (Trasmettitore IR-UWB Event-Triggered)]], [#strong[#mi("4.60\\,\\mu\\text{W}")]], [#strong[#mi("7.2\\%")]], [#mi("0.144\\,\\mu\\text{W}")], [#strong[#mi("0.034\\,\\text{mm}^2")]], [#strong[#mi("21.25\\%")]],
    [#strong[TOTALE SoC NeuroSEED (32 Canali)]], [#strong[#mi("63.61\\,\\mu\\text{W}")]], [#strong[#mi("100.0\\%")]], [#strong[#mi("1.99\\,\\mu\\text{W/ch}")]], [#strong[#mi("0.160\\,\\text{mm}^2")] (#mi("0.70") die)], [#strong[#mi("100.0\\%")]],
  )
]

- #strong[Perché l'AFE e l'ASC assorbono il #mi("68.6\\%") della potenza e il #mi("63.75\\%") dell'area?]
Perché l'amplificazione di segnali biologici dell'ordine dei microvolt (#mi("\\text{IRN} = 2.9\\,\\mu\\text{V}_{\\text{rms}}")) è governata da #strong[limiti termodinamici incomprimibili]: il rumore termico dell'LNA è inversamente proporzionale alla transconduttanza (#mi("\\overline{v_{n,\\text{th}}^2} \\propto \\frac{8kT}{3g_m} f_{\\text{BW}}")), che a sua volta impone una corrente minima di polarizzazione #mi("I_D") nell'LNA (#mi("38.4\\,\\mu\\text{W}")), mentre il rumore di campionamento #mi("\\frac{kT}{C}") e i requisiti di matching impongono condensatori fisici enormi (#strong[#mi("C_{\\text{IN}} = 7.3\\,\\text{pF}")] nell'AFE e #strong[#mi("C_1 = C_2 = 6\\,\\text{pF}") per ciascuno dei 32 canali ASC]), che non scalano con la legge di Moore!
- Allo stesso modo, in #strong[Li et al. (2024) (#raw("paperSNN4"))], i #mi("287.9\\,\\mu\\text{W}") misurati sul core di Xylo #strong[non includono] il consumo dell'AFE né il costo computazionale dell'estrazione ICA e del filtraggio Notch/passa-banda eseguiti off-chip prima della codifica Sigma-Delta.

#line(length: 100%, stroke: 0.5pt + luma(200))

=== 2. Il Peso Schiacciante di Sinapsi, Memorie (CAM/SRAM) e Interconnessioni di Routing rispetto al Soma Spiking
Nelle reti SNN multi-neurone (#strong[ROLLS], #strong[DYNAP-SE], #strong[DYNAP-SE2]), i dati relativi ad area ed energia per evento sono ancora più eloquenti:

#strong[Tabella 6.2 — Scomposizione dell'energia per singolo evento spiking in DYNAP-SE / DYNAP-SE2 \*(Moradi et al., 2018, Table III; Bartels et al., 2025, Eq. 6)]\*

#block(breakable: true, width: 100%)[
  #set text(size: 7.5pt)
  #table(columns: (1fr, 1fr, 1fr, 1fr), stroke: 0.5pt + luma(180), inset: 4.5pt,
    table.header([#strong[Operazione Fisica Associata a 1 Spike]], [#strong[Energia \@ #mi("V_{\\text{DD}} = 1.8\\,\\text{V}")]], [#strong[Energia \@ #mi("V_{\\text{DD}} = 1.3\\,\\text{V}")]], [#strong[Quota % sull'Evento Completo Inter-Core (#mi("9290\\,\\text{pJ}") \@ #mi("1.8\\,\\text{V}"))]]),
    [#strong[1. Generazione dello spike nel soma analogico (#mi("E_{\\text{spike}}"))]], [#strong[#mi("883\\,\\text{pJ}")]], [#strong[#mi("260\\,\\text{pJ}")]], [#strong[#mi("9.5\\%")]],
    [#strong[2. Estensione dell'impulso nella sinapsi (#mi("E_{\\text{pulse}}"), circuito PE)]], [#strong[#mi("324\\,\\text{pJ}")]], [#strong[#mi("26\\,\\text{pJ}")]], [#strong[#mi("3.5\\%")]],
    [#emph[Subtotale Calcolo Analogico/Sinaptico Locale (#mi("E_{\\text{in}} = E_{\\text{spike}} + E_{\\text{pulse}}"))]], [#strong[#emph[#mi("1207\\,\\text{pJ}")]]], [#strong[#emph[#mi("286\\,\\text{pJ}")]]], [#strong[#emph[#mi("13.0\\%")]]],
    [#strong[3. Codifica AER e lettura tabella destinazioni SRAM in R1 (#mi("E_{\\text{en}}"))]], [#strong[#mi("883\\,\\text{pJ}")]], [#strong[#mi("507\\,\\text{pJ}")]], [#strong[#mi("9.5\\%")]],
    [#strong[4. Broadcasting intra-core e ricerca nelle #mi("16\\text{K}") CAM (#mi("E_{\\text{br}}"))]], [#strong[#mi("6840\\,\\text{pJ}") (#mi("6.84\\,\\text{nJ}"))]], [#strong[#mi("2200\\,\\text{pJ}") (#mi("2.20\\,\\text{nJ}"))]], [#strong[#mi("73.6\\%")]],
    [#strong[5. Routing digitale asincrono inter-core R1 #mi("\\leftrightarrow") R2 (#mi("E_{\\text{rt}}"))]], [#strong[#mi("360\\,\\text{pJ}")]], [#strong[#mi("78\\,\\text{pJ}")]], [#strong[#mi("3.9\\%")]],
    [#emph[Subtotale Memoria e Interconnessioni (#mi("E_{\\text{out}} = E_{\\text{en}} + E_{\\text{br}} + E_{\\text{rt}}"))]], [#strong[\*#mi("8083\\,\\text{pJ}") (#mi("8.08\\,\\text{nJ}"))\* ]], [#strong[\*#mi("2785\\,\\text{pJ}") (#mi("2.79\\,\\text{nJ}"))\* ]], [#strong[#emph[#mi("87.0\\%")]]],
    [#strong[TOTALE ENERGIA PER EVENTO (#mi("E_{\\text{tot}} = E_{\\text{in}} + E_{\\text{out}}"))]], [#strong[#mi("9290\\,\\text{pJ}") (#mi("9.29\\,\\text{nJ}"))]], [#strong[#mi("3071\\,\\text{pJ}") (#mi("3.07\\,\\text{nJ}"))]], [#strong[#mi("100.0\\%")]],
  )
]

Dalla #strong[Tabella 6.2] e dalle tabelle di area di #strong[ROLLS] e #strong[DYNAP-SE] emergono tre conclusioni fondamentali:
+ #strong[L'#mi("87.0\\%") dell'energia per spike in DYNAP-SE2 se ne va nelle memorie e nelle interconnessioni (#mi("8083\\,\\text{pJ}") contro #mi("883\\,\\text{pJ}") del soma):]
In particolare, la sola operazione di #strong[broadcasting e ricerca associativa nelle #mi("16\\,384") parole CAM di un core (#mi("E_{\\text{br}} = 6840\\,\\text{pJ}") a #mi("1.8\\,\\text{V}"))] consuma #strong[da sola il #mi("73.6\\%") dell'energia totale], ovvero #strong[#mi("7.75") volte l'energia del neurone spiking]! Ciò accade perché ad ogni spike in ingresso a un core occorre pre-caricare e commutare le capacità parassite delle lunghe linee di ricerca dual-rail (#raw("SL")/#raw("SLB")) e delle #mi("16\\text{K}") #emph[Match-Lines] distribuite sull'intero core.
+ #strong[In ROLLS e DYNAP-SE, le sinapsi e le memorie occupano oltre il #mi("57\\text{-}65\\%") dell'area del chip, mentre i somi occupano meno dell'#mi("1\\text{-}5\\%"):]
In #strong[ROLLS] (#raw("paperSNN2")), i 256 somi occupano appena lo #strong[#mi("0.47\\%") dell'area (#mi("0.235\\,\\text{mm}^2"))], mentre le #mi("128\\text{K}") sinapsi (LTP + STP) occupano il #strong[#mi("64.73\\%") (#mi("33.28\\,\\text{mm}^2"))]. In #strong[DYNAP-SE] (#raw("paperSNN5")), le memorie CAM/SRAM (#mi("31.7\\%")), i circuiti sinaptici PE/DEC (#mi("25.2\\%")) e i router R1–R3 (#mi("9.7\\%")) occupano il #strong[#mi("66.6\\%") dell'area di core].
+ #strong[Anche nei chip SNN completamente digitali a 28 nm (Xylo, #raw("paperSNN4")), la comunicazione I/O e l'accesso alla SRAM sono critici:]
In Xylo, la sola interfaccia #strong[I/O SPI consuma #mi("87.4\\,\\mu\\text{W}"), pari al #mi("23.3\\%") della potenza totale del chip (#mi("375.3\\,\\mu\\text{W}"))]. Inoltre, per contenere la potenza del core entro #mi("287.9\\,\\mu\\text{W}"), è stato necessario limitare drasticamente gli accessi ai #mi("124\\,\\text{KB}") di SRAM imponendo un fan-out ricorrente sparso di #strong[massimo 32 sinapsi per neurone] e comprimendo la rete #emph[WaveSense] a soli #strong[#mi("2.400") pesi].

#line(length: 100%, stroke: 0.5pt + luma(200))

== 6.2 Perché le SNN Mantengono un Vantaggio Energetico Concreto e Decisivo a Livello di Sistema End-to-End

Se l'AFE, le memorie CAM/SRAM e il routing assorbono la maggior parte della potenza istantanea, #strong[perché i sistemi neuromorfici SNN risultano comunque nettamente superiori all'elaborazione convenzionale per i dispositivi biomedicali impiantabili?] La risposta risiede in quattro meccanismi di sistema dimostrati dai paper analizzati:

+ #strong[Il Costo Elevato del Routing e delle Sinapsi (#mi("8083\\,\\text{pJ}")) viene Pagato \*Solo Quando C'è un Evento Significativo\*:]
Un processore DSP/CNN sincrono paga il costo di accesso alla memoria SRAM e di calcolo MAC #emph[ad ogni ciclo di clock, 24 ore su 24]. In una SNN guidata da un codificatore #emph[level-crossing] (ADM o ASC), l'energia di broadcast/routing (#mi("E_{\\text{out}} = 8083\\,\\text{pJ}")) è moltiplicata per la frequenza di firing #mi("f_{\\text{out}}"):
#mitex("P_{\\text{spike}} = f_{\\text{in}} E_{\\text{in}} + f_{\\text{out}} E_{\\text{out}}")
Durante il #mi("99\\%") del tempo in cui il paziente non ha una crisi epilettica (fase pre-ictale/interictale), #mi("f_{\\text{in}}") e #mi("f_{\\text{out}}") sono bassissime: come dimostrato nella Tabella 5 di #strong[Bartels et al. (2025)], la potenza dell'intera rete SNN a 56 canali su DYNAP-SE2 scende a soli #strong[#mi("1.77\\,\\mu\\text{W}") (#mi("31\\,\\text{nW/canale}"))] in fase pre-ictale, per salire a #mi("35\\text{-}66\\,\\mu\\text{W}") esclusivamente durante i pochi secondi della crisi!
+ #strong[Quando la Topologia è Dedicata e Sparsa (Senza Memorie CAM/SRAM di Routing General-Purpose), il Consumo Crolla ai Nanowatt:]
Il confronto tra #strong[DYNAP-SE2] (#mi("150\\,\\mu\\text{W}") a #mi("1.8\\,\\text{V}"), processore general-purpose riconfigurabile con #mi("64\\text{K}") CAM) e #strong[NET-TEN] (#strong[#mi("3.53\\,\\text{nW}")] a #mi("0.25\\,\\text{V}"), #raw("paperSNN3")) è illuminante: eliminando le tabelle di routing SRAM/CAM e cablando direttamente in analogico una rete sparsa di 30 neuroni con #strong[fan-out pari a 2] a #mi("V_{\\text{DD}} = 250\\,\\text{mV}"), l'overhead delle interconnessioni scompare e l'intero classificatore epilettico consuma quanto un singolo neurone biologico (#mi("3.53\\,\\text{nW}") e #mi("148.2\\,\\text{fJ/classificazione}")), contro i #mi("66\\text{-}162\\,\\mu\\text{W}") e #mi("\\sim 2\\,\\mu\\text{J/classificazione}") degli ASIC LSVM/DSP allo stato dell'arte (Tabella 3 di #raw("paperSNN3")).
+ #strong[Eliminazione dell'ADC di Nyquist e Abbattimento di Oltre #mi("500\\times") della Potenza di Telemetria Wireless:]
In un impianto multicanale (come una BMI intracorticale a 32–1024 canali), il vero divoratore di energia a livello di sistema non è il processore, bensì il #strong[trasmettitore wireless RF] se costretto a trasmettere il flusso continuo di un ADC di Nyquist (#mi("3.3\\,\\text{Mbps}") per 32 canali). Grazie alla catena neuromorfica #strong[ASC + Clockless I&F Spike Detector] di #strong[NeuroSEED (#raw("paperSNN7"))], il volume di dati viene compresso in-situ di #strong[oltre #mi("500") volte]: il trasmettitore #strong[IR-UWB] resta spento in #emph[deep sleep] e si accende solo per impulsi di #strong[#mi("3.2\\,\\text{ns}")] alla rilevazione di uno spike, consumando appena #strong[#mi("4.6\\,\\mu\\text{W}") (#mi("7.2\\%") della potenza del SoC)]!
+ #strong[Eliminazione dei Buffer di Memoria Temporale grazie alle Costanti di Tempo Fisiche (#mi("\\tau = \\frac{C U_T}{\\kappa I_\\tau}")):]
Poiché le sinapsi DPI e i neuroni in sottosoglia integrano il segnale su scale temporali di decine o centinaia di millisecondi sfruttando direttamente la fisica dei condensatori, non occorre mai memorizzare lunghe finestre di campioni EEG/LFP in grandi banchi SRAM prima di calcolare trasformate spettrali (FFT/DWT), garantendo simultaneamente #strong[minima area, potenza sub-milliwatt e latenza millisecondica (#mi("30\\text{-}56.7\\,\\text{ms}"))] indispensabile per la neurostimolazione #emph[closed-loop].

#block(fill: rgb("#f0f4f8"), inset: 10pt, radius: 4pt, stroke: (left: 3pt + rgb("#2b6cb0")), width: 100%)[
  #strong[IMPORTANT:] #strong[Sintesi Conclusiva:]
  Le SNN offrono un #strong[vantaggio energetico concreto, misurabile e decisivo] per i sistemi biomedicali impiantabili #strong[a condizione che la progettazione non si limiti al singolo neurone ultra-low-power, ma abbracci una co-progettazione olistica dell'intero sistema]: (1) front-end di acquisizione a basso rumore con multiplexing diretto e conversione immediata #emph[level-crossing] (ADM/ASC) per eliminare l'ADC di Nyquist; (2) connettività sinaptica sparsa o gerarchica a due stadi (SRAM+CAM in DYNAPs o cablaggio a basso fan-out in NET-TEN) per contenere l'energia di broadcast/routing; (3) regolarizzazione della sparsità di firing in fase di training (Xylo); e (4) telemetria wireless impulsiva #emph[send-on-event] (IR-UWB in NeuroSEED).
]

#line(length: 100%, stroke: 0.5pt + luma(200))

= Capitolo 7 — Bibliografia di Riferimento

+ #strong[Indiveri, G., Linares-Barranco, B., Hamilton, T. J., van Schaik, A., Etienne-Cummings, R., Delbruck, T., Liu, S.-C., Dudek, P., Häfliger, P., Renaud, S., Schemmel, J., Cauwenberghs, G., Arthur, J., Hynna, K., Folowosele, F., Saighi, S., Serrano-Gotarredona, T., Wijekoon, J., Wang, Y., & Boahen, K. (2011).] #emph[Neuromorphic silicon neuron circuits]. Frontiers in Neuroscience, 5, 73. DOI: #raw("10.3389/fnins.2011.00073") (#raw("paperSNN1.pdf")).
+ #strong[Qiao, N., Mostafa, H., Corradi, F., Osswald, M., Stefanini, F., Sumislawska, D., & Indiveri, G. (2015).] #emph[A reconfigurable on-line learning spiking neuromorphic processor comprising 256 neurons and 128K synapses]. Frontiers in Neuroscience, 9, 141. DOI: #raw("10.3389/fnins.2015.00141") (#raw("paperSNN2.pdf")).
+ #strong[Ronchini, M., Rezaeiyan, Y., Zamani, M., Panuccio, G., & Moradi, F. (2023).] #emph[NET-TEN: a silicon neuromorphic network for low-latency detection of seizures in local field potentials]. Journal of Neural Engineering, 20(3), 036002. DOI: #raw("10.1088/1741-2552/acd029") (#raw("paperSNN3.pdf")).
+ #strong[Li, R., Zhao, G., Muir, D. R., Ling, Y., Burelo, K., Khoe, M., Wang, D., Xing, Y., & Qiao, N. (2024).] #emph[Real-time sub-milliwatt epilepsy detection implemented on a spiking neural network edge inference processor]. Computers in Biology and Medicine, 183, 109225. DOI: #raw("10.1016/j.compbiomed.2024.109225") (#raw("paperSNN4.pdf")).
+ #strong[Moradi, S., Qiao, N., Stefanini, F., & Indiveri, G. (2018).] #emph[A scalable multicore architecture with heterogeneous memory structures for Dynamic Neuromorphic Asynchronous Processors (DYNAPs)]. IEEE Transactions on Biomedical Circuits and Systems, 12(1), 106–122. DOI: #raw("10.1109/TBCAS.2017.2759700") (#raw("paperSNN5.pdf")).
+ #strong[Bartels, J., Gallou, O., Ito, H., Cook, M., Sarnthein, J., Indiveri, G., & Ghosh, S. (2025).] #emph[Event driven neural network on a mixed signal neuromorphic processor for EEG based epileptic seizure detection]. Scientific Reports, 15, 15965. DOI: #raw("10.1038/s41598-025-99272-6") (#raw("paperSNN6.pdf")).
+ #strong[Wu, H., Chen, J., Eskandari, R., Han, Y., Liu, X., Zou, W., Tian, F., Hou, Q., Lin, S., Yang, J., & Sawan, M. (2026).] #emph[NeuroSEED: A Neuromorphic Scalable Event-Driven SoC with Direct Multiplexing for Spike Detection and Wireless Telemetry]. IEEE Journal on Emerging and Selected Topics in Circuits and Systems (Early Access). DOI: #raw("10.1109/JETCAS.2026.3705440") (#raw("paperSNN7.pdf")).
