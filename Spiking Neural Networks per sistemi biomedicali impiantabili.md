Spiking Neural Networks per sistemi biomedicali impiantabili: applicazioni e
architetture circuitali CMOS
Obiettivo
Ricerca bibliografica sulle Spiking Neural Networks (SNN), approfondendone le potenzialità
per l'elaborazione a basso consumo di segnali biologici in dispositivi biomedicali, con
particolare riferimento ai sistemi impiantabili.
Il lavoro dovrà comprendere una breve introduzione ai principi di funzionamento delle SNN
e ai modelli di neurone artificiale, con particolare attenzione al modello Leaky Integrate-andFire (LIF).
Il candidato dovrà quindi approfondire due aspetti:
1. Applicazioni biomedicali
Analizzare alcuni esempi di impiego delle SNN nell'elaborazione di segnali biologici, con
particolare attenzione alle applicazioni che richiedono bassi consumi, elaborazione in tempo
reale e ridotta latenza, come il monitoraggio dell'attività neurale e il riconoscimento di eventi
epilettici.
2. Implementazioni circuitali CMOS
Esaminare le principali architetture analogiche e mixed-signal utilizzate per realizzare
neuroni spiking in tecnologia CMOS, descrivendone i blocchi circuitali fondamentali e il
principio di funzionamento.
Il confronto dovrà considerare, dove disponibili, tensione di alimentazione, consumo statico,
energia per spike, area, frequenza di firing e variabilità dei parametri.
L'idea centrale è rispondere a due domande:
 Perché utilizzare una SNN in un dispositivo biomedicale impiantabile? Quali vantaggi
può offrire rispetto all'elaborazione convenzionale, soprattutto in termini di consumo
energetico, latenza ed elaborazione locale?
 Come si realizza fisicamente un neurone spiking in tecnologia CMOS? Quali
architetture sono state proposte e quali compromessi presentano in termini di area,
potenza, energia per spike, frequenza di firing e variabilità?
Bibliografia
Tre articoli di partenza:
1. Indiveri et al. (2011)
Neuromorphic Silicon Neuron Circuits
Frontiers in Neuroscience, 5, 73.
2. Qiao et al. (2015)
A Reconfigurable On-line Learning Spiking Neuromorphic Processor Comprising 256
Neurons and 128K Synapses
Frontiers in Neuroscience, 9, 141.
3. NET-TEN (2023)
NET-TEN: A Silicon Neuromorphic Network for Low-Latency Detection of Seizures in
Local Field Potentials
Journal of Neural Engineering, 2023.
Altri due a scelta tra questi:
4. Real-time Sub-milliwatt Epilepsy Detection Implemented on a Spiking Neural Network
Edge Inference Processor (2024)
Scheda PubMed
5. Moradi et al. (2018)
A Scalable Multicore Architecture with Heterogeneous Memory Structures for Dynamic
Neuromorphic Asynchronous Processors (DYNAPs)
6. Event Driven Neural Network on a Mixed Signal Neuromorphic Processor for EEG Based
Epileptic Seizure Detection (2025).
Scheda PubMed
7. NeuroSEED: A Neuromorphic Scalable Event-Driven SoC with Direct Multiplexing for
Spike Detection and Wireless Telemetry (2026).
IEEE Journal on Emerging and Selected Topics in Circuits and Systems, Early Access.
La conclusione dei confronti tra neuroni, architetture, sistemi dovrebbe affrontare una
domanda critica:
Le SNN offrono un vantaggio energetico concreto per i sistemi biomedicali impiantabili
oppure il consumo dei circuiti di acquisizione, delle sinapsi, della memoria e delle
interconnessioni può ridimensionare il beneficio ottenuto con neuroni ultra-low-power?