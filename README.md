# Spiking Neural Networks per Sistemi Biomedicali Impiantabili: Applicazioni e Architetture Circuitali CMOS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Field](https://img.shields.io/badge/Field-Biomedical%20Electronics%20%7C%20Neuromorphic%20Engineering-blue.svg)](#)
[![Format](https://img.shields.io/badge/Report-PDF%20%7C%20LaTeX%20%7C%20Typst%20%7C%20Markdown%20%7C%20HTML-brightgreen.svg)](#)

Monografia tecnica, ricerca bibliografica approfondita e analisi circuitale a livello di transistor sull'impiego delle **Spiking Neural Networks (SNN)** e dell'**ingegneria neuromorfica analogica/mixed-signal** per l'elaborazione ultra-low-power di segnali biologici in dispositivi biomedicali impiantabili (*closed-loop neural implants*, rilevamento di crisi epilettiche, interfacce neurali wireless).

---

## 📌 Indice dei Contenuti
- [Panoramica del Progetto](#-panoramica-del-progetto)
- [Domande Guida della Ricerca](#-domande-guida-della-ricerca)
- [Struttura della Relazione e Capitoli](#-struttura-della-relazione-e-capitoli)
- [Articoli Scientifici di Riferimento (I 7 Paper)](#-articoli-scientifici-di-riferimento-i-7-paper)
- [Architetture Circuitali Analizzate (Transistor-Level)](#-architetture-circuitali-analizzate-transistor-level)
- [Galleria delle Figure e Schemi Circuitali](#-galleria-delle-figure-e-schemi-circuitali)
- [Confronto Sinottico e Bilancio Energetico End-to-End](#-confronto-sinottico-e-bilancio-energetico-end-to-end)
- [Struttura della Repository](#-struttura-della-repository)
- [Autore e Note Accademiche](#-autore-e-note-accademiche)

---

## 🔬 Panoramica del Progetto

I sistemi biomedicali impiantabili moderni (dispositivi di neurostimolazione corticale a circuito chiuso, interfacce cervello-computer intracraniche, pacemaker cardiaci intelligenti) affrontano vincoli termici ed energetici severissimi:
- **Limite termico biologico:** Incremento di temperatura cerebrale localizzato rigidamente limitato a $\Delta T < 1^\circ\text{C}$ (per evitare necrosi del tessuto neurale), che fissa la densità di dissipazione di potenza a un massimo di **$1.6\text{--}2.0\text{ mW/mm}^2$** (potenza totale consentita tipicamente **$< 15\text{--}40\text{ mW}$** per l'intero impianto).
- **Limite di telemetria wireless:** La trasmissione continua all'esterno (*raw streaming*) di decine o centinaia di canali neurali campionati a frequenza di Nyquist richiede tra $10$ e $100\text{ pJ/bit}$ nei transceiver RF convenzionali, esaurendo in poche ore le batterie impiantate e saturando la banda termica.

Il **paradigma neuromorfico spiking (SNN)** supera queste barriere elaborando i segnali in modo asincrono, basato su eventi (*event-driven*), operando i transistor MOSFET nella regione di **sottosoglia (*weak inversion*)** a correnti comprese tra centinaia di femtoampere e decine di nanoampere, e comprimendo l'informazione alla sorgente mediante conversioni analogico-spike a campionamento adattativo.

---

## 🎯 Domande Guida della Ricerca

Il lavoro risponde in maniera quantitativa e critica a tre quesiti ingegneristici cardine:

1. **Perché utilizzare una SNN in un dispositivo biomedicale impiantabile?**  
   Quali vantaggi offre l'elaborazione *event-driven* a tempo continuo rispetto al campionamento di Nyquist e all'elaborazione sincrona convenzionale (von Neumann, DSP, microcontrollori) in termini di latenza, consumo statico e dinamico, e riduzione del traffico dati?
2. **Come si realizza fisicamente un neurone e una sinapsi spiking in tecnologia CMOS?**  
   Quali topologie circuitali sono state proposte in letteratura (da *Axon-Hillock* ai filtri log-domain e al neurone *DPI*, fino ai modelli quadratici di Izhikevich e *Switched-Capacitor*) e quali compromessi presentano tra fedeltà biofisica, consumo statico, area silicea e sensibilità alla variabilità di processo (*Pelgrom device mismatch*)?
3. **Le SNN offrono un reale vantaggio energetico a livello di sistema?**  
   Oppure il consumo degli stadi di amplificazione e filtraggio (*Analog Front-End*), dei circuiti sinaptici, delle memorie di configurazione/routing (CAM/SRAM) e della telemetria ridimensiona il beneficio promesso dai neuroni ultra-low-power?

---

## 📖 Struttura della Relazione e Capitoli

La monografia completa (`Relazione_SNN_Sistemi_Biomedicali_Impiantabili.pdf`, disponibile anche in sorgenti `.tex`, `.typ`, `.md` e `.html`) è articolata in 6 capitoli tecnici:

### [Capitolo 1 — Principi di Funzionamento delle SNN e Modelli di Neurone Artificiale](file:///Relazione_SNN_Sistemi_Biomedicali_Impiantabili.md#capitolo-1--principi-di-funzionamento-delle-spiking-neural-networks-snn-e-modelli-di-neurone-artificiale)
- Evoluzione delle Reti Neurali: Prima Generazione (McCulloch-Pitts), Seconda Generazione (Rate-based: MLP, CNN, RNN) e Terza Generazione (SNN: *"time represents itself"*).
- Schemi di codifica neurale: *Rate coding*, *Temporal coding* (ISI, Time-to-First-Spike), *Population Synchrony/Chimera states*.
- Circuiti di conversione analogico-evento: *Asynchronous Delta Modulator (ADM)*, *Step-Forward Encoding (SFE)*, codifica Sigma-Delta ($\Sigma\Delta$) e *Analog-to-Spike Converter (ASC)* con folding capacitivo bio-ispirato.
- Tassonomia matematica: Hodgkin-Huxley (H-H, 4 variabili di stato), Leaky Integrate-and-Fire (LIF, derivazione analitica e curva $f\text{–}I$), Quadratic I&F (QIF / Izhikevich), Adaptive Exponential I&F (AdEx), Mihalas-Niebur con soglia adattativa.
- Regole di plasticità e dinamiche sinaptiche: STDP (*Spike-Timing-Dependent Plasticity*), SDSP (*Spike-Driven Synaptic Plasticity* bistabile con stop-learning del calcio), STP (*Short-Term Plasticity*), e algoritmi moderni con *Surrogate Gradient* e *ENAS*.

### [Capitolo 2 — Perché Utilizzare una SNN in un Dispositivo Impiantabile?](file:///Relazione_SNN_Sistemi_Biomedicali_Impiantabili.md#capitolo-2--perch%C3%A9-utilizzare-una-snn-in-un-dispositivo-biomedicale-impiantabile)
- Vincoli termici, densità di potenza e volume nei tessuti corticali.
- Il "collo di bottiglia" dell'elaborazione digitale standard (ADC a frequenza fissa, commutazione di clock continua anche sul rumore di fondo, *memory wall* di von Neumann).
- I vantaggi intrinseci del silicio neuromorfico: consumo dinamico zero in assenza di eventi biologici, dinamica temporale a livello fisico analogico senza digitalizzazione forzata, latenza di decisione sub-millisecondo.

### [Capitolo 3 — Applicazioni Biomedicali delle SNN nell'Elaborazione di Segnali Biologici](file:///Relazione_SNN_Sistemi_Biomedicali_Impiantabili.md#capitolo-3--applicazioni-biomedicali-delle-snn-nellelaborazione-di-segnali-biologici)
Analisi comparativa di quattro piattaforme all'avanguardia:
1. **NET-TEN** *(Ronchini et al., 2023)*: Rilevamento ultra-rapido ($1.53\text{ ms}$) di crisi epilettiche da Local Field Potentials (LFP) con chip analogico neuromorfico (180 nm, 60 neuroni Izhikevich, consumo totale $4.94\,\mu\text{W}$).
2. **SynSense Xylo / WaveSense** *(Li et al., 2024)*: Classificazione real-time sub-milliwatt di crisi epilettiche da EEG da scalpo su coprocessore neuromorfico digitale edge a 28 nm ($283\,\mu\text{W}$, sensibilità $93.7\%$, specificità $96.8\%$).
3. **DYNAP-SE2** *(Bartels et al., 2025)*: Rilevamento event-driven da iEEG intracranico umano su processore mixed-signal a 180 nm sfruttando il layer Non-Local Non-Global (NLNG) per catturare la sincronizzazione parziale multi-canale ($33.6\,\mu\text{W}$ su 16 canali).
4. **NeuroSEED** *(Wu et al., 2026)*: Interfaccia neurale impiantabile a 32 canali in tecnologia 180 nm con *Direct Multiplexing*, convertitore ASC clockless ripiegato, rilevamento combinato spikes/LFP e telemetria wireless IR-UWB impulsiva ($23.95\,\mu\text{W}$ complessivi di SoC).

### [Capitolo 4 — Implementazioni Circuitali CMOS di Neuroni e Sinapsi Spiking](file:///Relazione_SNN_Sistemi_Biomedicali_Impiantabili.md#capitolo-4--implementazioni-circuitali-cmos-di-neuroni-e-sinapsi-spiking)
- **Fisica del MOSFET in sottosoglia (*Weak Inversion*):** Modello EKV, tensione termica $U_T = kT/q$, fattore di pendenza $\kappa$, principio translineare di Gilbert e circuiti integratori log-domain.
- **Topologie di neurone a livello di transistor:**
  - *Tau-Cell* e filtri *Differential Pair Integrator* (**DPI**).
  - Neurone *Axon-Hillock* di Mead e neurone I&F a comparatore e *starved inverters* di van Schaik.
  - Neurone *Conductance-Based* accelerato ($\times 10^4$).
  - Neurone I&F a log-domain con feedback cubico (LLN di Arthur & Boahen).
  - Neurone **DPI AdEx** a 20 transistor in modalità corrente (Livi & Indiveri).
  - Neurone quadratico di **Izhikevich** in CMOS a 14 transistor (Wijekoon & Dudek).
  - Neurone *Switched-Capacitor* di Mihalas-Niebur.
- **Il Processore Neuromorfico ROLLS** *(Qiao et al., 2015)*:
  - Architettura a 256 neuroni e 128k sinapsi (180 nm, $51.4\text{ mm}^2$).
  - Soma AdEx transistor-level con canali di perdita (`LEAK`), adattamento (`AHP`), corrente eccitatoria `NMDA` e rami di feedback positivo e refrattarietà (`Na+`, `K+`).
  - Sinapsi bistabili a lungo termine (LTP/LTD con circuiti di stop-learning del calcio e WTA).
  - Sinapsi a breve termine programmabili (STP con DAC a 2 bit, depressione/facilitazione e invarianza temporale).
- **Architetture Multi-Core Scalabili e Routing Asincrono QDI: DYNAPs / DYNAP-SE** *(Moradi et al., 2018)*:
  - Teoria analitica del routing tag-based gerarchico a due stadi.
  - Sintesi quasi-delay-insensitive (QDI) da specifiche CHP a Production Rules (C-Element di Muller).
  - Router gerarchici asincroni R1 (intra-core), R2 (inter-core) e R3 (inter-chip).
  - Progettazione della memoria **CAM asincrona a 9 transistor (9T NOR-type)** per il matching asincrono dei tag e la rigenerazione spaziale della larghezza d'impulso sinaptico.

### [Capitolo 5 — Confronto Multiparametrico Globale e Analisi dei Compromessi](file:///Relazione_SNN_Sistemi_Biomedicali_Impiantabili.md#capitolo-5--confronto-multiparametrico-globale-e-analisi-dei-compromessi-trade-off)
- Matrice di comparazione analitica tra tutte le topologie di neurone al silicio (transistor count, area in $\mu\text{m}^2$, consumo statico, energia per spike in fJ/pJ, fedeltà biologica).
- Tabella riassuntiva dei 7 sistemi analizzati (tecnologia di processo, area del die, tensione di alimentazione, consumo di potenza per canale, metriche di rilevamento clinico).
- Analisi fisica del disadattamento tra dispositivi (*device mismatch*) in sottosoglia secondo la **legge di Pelgrom** ($\sigma_{V_{th}} \propto 1/\sqrt{WL}$) e strategie di calibrazione (bistrot, routing stocastico, algoritmi *hardware-aware training*).

### [Capitolo 6 — Discussione Critica Conclusiva: Il Vero Bilancio Energetico nei Sistemi Impiantabili](file:///Relazione_SNN_Sistemi_Biomedicali_Impiantabili.md#capitolo-6--discussione-critica-conclusiva-il-vero-bilancio-energetico-nei-sistemi-biomedicali-impiantabili)
- Scomposizione analitica dei consumi "nascosti" del sistema:
  1. *Analog Front-End* (LNA, filtri passa-banda, buffer): $1\text{--}10\,\mu\text{W/canale}$.
  2. Matrice sinaptica e memorie di routing (CAM/SRAM statiche ed eventi di lettura): $5\text{--}50\,\mu\text{W}$.
  3. Circuiti di bias, PLL/oscillatori e riferimenti di corrente.
- Dimostrazione quantitativa del vantaggio sistemico delle SNN: eliminazione del costo energetico della telemetria wireless tramite compressione a monte e classificazione *on-chip*.

---

## 📚 Articoli Scientifici di Riferimento (I 7 Paper)

I 7 articoli scientifici analizzati e allegati alla repository sono:

| # | File PDF | Titolo Articolo | Autori & Journal | Anno | Argomento Chiave |
|---|---|---|---|---|---|
| **1** | [`paperSNN1.pdf`](file:///paperSNN1.pdf) | *Neuromorphic Silicon Neuron Circuits* | G. Indiveri et al. — *Frontiers in Neuroscience* | 2011 | Rassegna fondamentale di tutte le topologie di neuroni analogici CMOS |
| **2** | [`paperSNN2.pdf`](file:///paperSNN2.pdf) | *A Reconfigurable On-line Learning Spiking Neuromorphic Processor Comprising 256 Neurons and 128K Synapses* | N. Qiao et al. — *Frontiers in Neuroscience* | 2015 | Chip ROLLS: soma AdEx, sinapsi plastiche bistabili LTP e dinamiche STP |
| **3** | [`paperSNN3.pdf`](file:///paperSNN3.pdf) | *NET-TEN: A Silicon Neuromorphic Network for Low-Latency Detection of Seizures in Local Field Potentials* | N. Ronchini et al. — *Journal of Neural Engineering* | 2023 | Rilevamento crisi epilettiche da LFP in 1.53 ms su chip da 4.94 µW |
| **4** | [`paperSNN4.pdf`](file:///paperSNN4.pdf) | *Real-time Sub-milliwatt Epilepsy Detection Implemented on a Spiking Neural Network Edge Inference Processor* | Y. Li et al. — *IEEE TBioCAS / PubMed* | 2024 | Piattaforma WaveSense su chip SynSense Xylo (28 nm, 283 µW) per EEG scalpo |
| **5** | [`paperSNN5.pdf`](file:///paperSNN5.pdf) | *A Scalable Multicore Architecture with Heterogeneous Memory Structures for Dynamic Neuromorphic Asynchronous Processors (DYNAPs)* | S. Moradi et al. — *IEEE TBCAS* | 2018 | Routing QDI a due stadi, architettura multi-core e memorie CAM 9T asincrone |
| **6** | [`paperSNN6.pdf`](file:///paperSNN6.pdf) | *Event Driven Neural Network on a Mixed Signal Neuromorphic Processor for EEG Based Epileptic Seizure Detection* | J. Bartels et al. — *IEEE TBioCAS* | 2025 | DYNAP-SE2 su iEEG umano con layer NLNG per rilevamento sincronia |
| **7** | [`paperSNN7.pdf`](file:///paperSNN7.pdf) | *NeuroSEED: A Neuromorphic Scalable Event-Driven SoC with Direct Multiplexing for Spike Detection and Wireless Telemetry* | X. Wu et al. — *IEEE JETCAS* | 2026 | SoC impiantabile a 32 canali con Direct Multiplexing, ASC e telemetria IR-UWB |

---

## ⚡ Architetture Circuitali Analizzate (Transistor-Level)

Nel testo della monografia e nelle figure a corredo vengono illustrati in dettaglio:

1. **Cella Tau (*Tau-Cell*) e Integratore a Coppia Differenziale (*DPI*):**
   $$\tau = \frac{C\,U_T}{\kappa\,I_\tau}$$
2. **Neurone DPI AdEx a 20 Transistor (Livi & Indiveri):**
   Circuito con specchio di corrente translineare, iniezione di corrente esponenziale con feedback positivo controllato da $V_{thr}$, scarica con ramo di reset e periodo refrattario configurabile via $V_{refr}$.
3. **Neurone di Izhikevich a 14 Transistor (Wijekoon & Dudek):**
   Generatore della caratteristica corrente-tensione $I\text{–}V$ quadratica ($I \propto V^2$) tramite coppia differenziale dissimetrica polarizzata in saturazione, in grado di emettere treni di spike, bursting autonomo, e risonanza di membrana con soli $14\text{ MOS}$.
4. **Neurone *Switched-Capacitor* (Mihalas-Niebur):**
   Integratore discreto di carica privo di resistenze ad alto valore ohmico, con soglia dinamica lineare retta da condensatori integrati.
5. **Memoria CAM Asincrona 9T (NOR-type in DYNAPs):**
   Circuito di cella di memoria associativa a 9 transistor con pre-carica a terra e pull-up dinamico sul match line, garantendo che la durata dell'impulso di eccitazione della sinapsi sia puramente determinata localmente dal transistor di scarica senza dispersioni introdotte dai ritardi del bus di indirizzi.

---

## 🖼️ Galleria delle Figure e Schemi Circuitali

La cartella [`figure/`](file:///figure/) contiene 29 illustrazioni originali ad altissima risoluzione estratte ed elaborate dai paper di riferimento:

| File | Descrizione del Circuito / Architettura |
|---|---|
| `fig01_taucell_lpf_dpi.png` | Schema di principio della Tau-Cell, filtri Log-Domain LPF e cella DPI |
| `fig02_axon_hillock.png` | Circuito Axon-Hillock a 6 transistor (Mead, 1989) |
| `fig03_voltage_amp_if.png` | Neurone I&F a comparatore e starved inverters (van Schaik) |
| `fig04_taucell_neuron.png` | Neurone completo basato su Tau-Cell con feedback |
| `fig05_lln_neuron.png` | Neurone Log-Domain LPF (LLN) con feedback cubico |
| `fig06_dpi_adex_neuron.png` | Schema schematico a livello di transistor del neurone DPI AdEx (20 MOS) |
| `fig07_izhikevich_neuron.png` | Schema transistor-level del neurone quadratico di Izhikevich (14 MOS) |
| `fig08_conductance_accelerated_neuron.png` | Neurone conductance-based accelerato ($\times 10^4$) |
| `fig09_switched_cap_mihalas_niebur.png` | Architettura switched-capacitor per neurone Mihalas-Niebur |
| `fig10_rolls_arch_die_area.png` | Microfotografia del die ROLLS (51.4 mm²) e partizione delle aree |
| `fig11_rolls_silicon_neuron_schematic.png` | Schema schematico del soma neuronale AdEx completo del chip ROLLS |
| `fig12_rolls_postsynaptic_learning_wta.png` | Circuiti di apprendimento post-sinaptico stop-learning e WTA |
| `fig13_rolls_ltp_bistable_synapse.png` | Schema della sinapsi bistabile a lungo termine (LTP/LTD) |
| `fig14_rolls_stp_synapse.png` | Schema della sinapsi dinamica a breve termine (STP) |
| `fig15_netten_lfp_detection_pcb_die.png` | Sistema NET-TEN: setup sperimentale, microfotografia die e PCB |
| `fig16_netten_arch_neuron_epsc_stdp.png` | Architettura a 60 neuroni NET-TEN, cella EPSC e sinapsi STDP |
| `fig17_xylo_lif_model_and_arch.png` | Modello LIF digitale e microarchitettura del processore SynSense Xylo |
| `fig18_xylo_spike_encoding_wavesense.png` | Pipeline WaveSense e codifica degli eventi EEG su Xylo |
| `fig19_dynaps_hierarchical_routing.png` | Rete di routing gerarchica 2D-Mesh/Tree asincrona del processore DYNAPs |
| `fig20_dynaps_node_and_cam_circuit.png` | Nodo computazionale QDI e schema transistor-level della cella CAM 9T |
| `fig21_dynapse2_eeg_seizure_overview.png` | Diagramma di flusso e architettura DYNAP-SE2 per rilevamento epilessia |
| `fig22_dynapse2_snn_translation_nlng.png` | Mappatura hardware dell'algoritmo SNN e layer Non-Local Non-Global |
| `fig23_dynapse2_afe_adm_setup.png` | Catena di condizionamento: AFE, modulatore ADM e setup DYNAP-SE2 |
| `fig24_dynapse2_analog_neuron_dpi_block.png` | Schema a blocchi del neurone analogico DPI in DYNAP-SE2 |
| `fig25_neuroseed_32ch_system_block.png` | Diagramma a blocchi completo del SoC NeuroSEED a 32 canali |
| `fig26_neuroseed_lna_and_gmc_integrator.png` | Schema transistor-level del LNA a basso rumore e integratore Gm-C |
| `fig27_neuroseed_asc_and_spike_detector_topologies.png` | Topologie del convertitore Analog-to-Spike (ASC) e spike detector |
| `fig28_neuroseed_asc_folding_comp_refractory_circuits.png` | Circuiti di folding capacitivo e comparatore refrattario in NeuroSEED |
| `fig29_neuroseed_uwb_die_power_area_breakdown.png` | Microfotografia die NeuroSEED e breakdown dettagliato di potenza e area |

---

## 📊 Confronto Sinottico e Bilancio Energetico End-to-End

### Tabella 1: Confronto delle Topologie di Neurone Spiking al Silicio

| Modello / Topologia | Complessità Circuitale | Dinamica / Fedeltà Biologica | Consumo Statico | Energia per Spike | Area Silicea Tipica |
|---|---|---|---|---|---|
| **Axon-Hillock (Mead)** | Minima (6 MOS, 2 C) | Integrazione e scarica pura, no refrettarietà programmabile | $< 1\text{ nW}$ | $\sim 1\text{ pJ}$ | Piccola ($< 150\,\mu\text{m}^2$) |
| **I&F Starved-Inverters** | Bassa (10-12 MOS, 1 C) | Corrente di leak e refrettarietà separate | $\sim 5\text{--}50\text{ pW}$ | $100\text{--}800\text{ fJ}$ | Piccola |
| **DPI AdEx (Livi-Indiveri)** | Media (20 MOS, 3 C) | Adattamento di frequenza, soglia dinamica esponenziale, AHP | $1\text{--}10\text{ nW}$ | $1\text{--}5\text{ pJ}$ | Media ($\sim 800\,\mu\text{m}^2$) |
| **Izhikevich (Wijekoon)** | Media (14 MOS, 2 C) | 20+ pattern corticali (bursting, chattering, risonanza) | $10\text{--}100\text{ nW}$ | $2\text{--}8\text{ pJ}$ | Compatta ($\sim 400\,\mu\text{m}^2$) |
| **Conductance-Based H-H** | Elevata (> 40 MOS, 4 C) | Potenziale d'azione biofisico identico al canale ionico naturale | $> 1\,\mu\text{W}$ | $> 50\text{ pJ}$ | Molto elevata |

### Tabella 2: Confronto dei 4 Sistemi Neuromorfici per Elettrofisiologia Impiantabile

| Sistema Neuromorfico | Riferimento | Tecnologia CMOS | Alimentazione | Consumo Totale / Canale | Metrica di Rilevamento / Latenza |
|---|---|---|---|---|---|
| **NET-TEN** | Ronchini et al. (2023) | TSMC 180 nm | $1.8\text{ V}$ | $4.94\,\mu\text{W}$ (totale chip) | Latenza: **$1.53\text{ ms}$**; Accuratezza: **$98.8\%$** |
| **WaveSense (SynSense Xylo)** | Li et al. (2024) | TSMC 28 nm | $0.8\text{ V}$ | $283\,\mu\text{W}$ ($17.7\,\mu\text{W}$/canale) | Sensibilità: **$93.7\%$**; Specificità: **$96.8\%$** |
| **DYNAP-SE2 (NLNG)** | Bartels et al. (2025) | UMC 180 nm | $1.3\text{ V} / 1.8\text{ V}$ | $33.6\,\mu\text{W}$ (16 canali) | Sensibilità: **$90.0\%$**; Specificità: **$96.0\%$** |
| **NeuroSEED** | Wu et al. (2026) | TSMC 180 nm | $1.2\text{ V} / 0.8\text{ V}$ | $23.95\,\mu\text{W}$ ($0.75\,\mu\text{W}$/canale) | Telemetria IR-UWB: **$1.17\text{ pJ/pulse}$** |

---

## 📁 Struttura della Repository

```text
progetto_el_biomedica/
├── Relazione_SNN_Sistemi_Biomedicali_Impiantabili.pdf    # Monografia completa compilata ad alta definizione
├── Relazione_SNN_Sistemi_Biomedicali_Impiantabili.md     # Documento sorgente completo in Markdown
├── Relazione_SNN_Sistemi_Biomedicali_Impiantabili.html   # Versione HTML autonoma con formule MathJax e navigazione
├── Relazione_SNN_Sistemi_Biomedicali_Impiantabili.tex    # Sorgente LaTeX professionale (formattazione libro/report)
├── Relazione_SNN_Sistemi_Biomedicali_Impiantabili.typ    # Sorgente Typst moderno per impaginazione rapida
├── Spiking Neural Networks per sistemi biomedicali impiantabili.md  # Traccia e linee guida del corso
├── README.md                                             # Questo documento illustrativo
├── .gitignore                                            # Filtro file temporanei e build LaTeX
│
├── figure/                                               # 29 illustrazioni e schemi circuitali ad alta risoluzione
│   ├── fig01_taucell_lpf_dpi.png
│   ├── fig02_axon_hillock.png
│   ├── ...
│   └── fig29_neuroseed_uwb_die_power_area_breakdown.png
│
└── Articoli Scientifici di Riferimento (PDF):
    ├── paperSNN1.pdf                                     # Indiveri et al. (2011) - Silicon Neurons
    ├── paperSNN2.pdf                                     # Qiao et al. (2015) - ROLLS Processor
    ├── paperSNN3.pdf                                     # Ronchini et al. (2023) - NET-TEN Seizures
    ├── paperSNN4.pdf                                     # Li et al. (2024) - Xylo WaveSense Seizures
    ├── paperSNN5.pdf                                     # Moradi et al. (2018) - DYNAPs Multicore
    ├── paperSNN6.pdf                                     # Bartels et al. (2025) - DYNAP-SE2 iEEG
    └── paperSNN7.pdf                                     # Wu et al. (2026) - NeuroSEED SoC
```

---

## 👨‍💻 Autore e Note Accademiche

- **Autore:** Luca Avanzi
- **Corso:** Elettronica Biomedica
- **Argomento:** Spiking Neural Networks per Sistemi Biomedicali Impiantabili: Applicazioni e Architetture Circuitali CMOS
- **Repository GitHub:** [https://github.com/lucavnz/biomedic.git](https://github.com/lucavnz/biomedic.git)
