# Guide d'utilisation de l'application de calcul d'itinéraire

## Introduction

Cette application Prolog permet de calculer des itinéraires optimaux entre différentes stations, en fonction des modes de transport disponibles (voiture, moto, car). Elle prend en compte les coûts et les durées pour proposer l'itinéraire le plus court.

## Installation

1. Assurez-vous d'avoir Prolog installé sur votre machine. Vous pouvez télécharger et installer SWI-Prolog à partir de [ce lien](https://www.swi-prolog.org/Download.html).
2. Téléchargez le fichier `main.pl` contenant le code du programme.

## Utilisation

1. Ouvrez un terminal.
2. Lancez SWI-Prolog en tapant la commande suivante :
   ```bash
   swipl
   ```
3. Chargez le fichier Prolog contenant le programme en utilisant la commande suivante dans le terminal Prolog :
   ```prolog
   [main].
   ```
4. Exécutez le prédicat `main` pour démarrer l'application :
   ```prolog
   itineraire.
   ```

## Fonctionnalités

### Calcul d'itinéraire

L'application vous demandera les informations suivantes pour calculer un itinéraire :

1. **Station de départ** : Saisissez le nom de la station de départ (par exemple, `chateau`).
2. **Station d'arrivée** : Saisissez le nom de la station d'arrivée (par exemple, `mokolo`).
3. **Heure de départ** : Saisissez l'heure de départ au format `HH:MM` (par exemple, `08:00`).
4. **Mode de transport** : Choisissez votre mode de transport parmi les options disponibles (`pieds`, `voiture`, `moto`).

### Résultats affichés

L'application affichera les informations suivantes pour l'itinéraire optimal :

- **Itinéraire le plus court** : Liste des stations intermédiaires de l'itinéraire.
- **Station de départ** : La station de départ saisie.
- **Heure de départ** : L'heure de départ saisie.
- **Durée du trajet** : La durée estimée du trajet en minutes.
- **Coût du trajet** : Le coût estimé du trajet en francs.
- **Distance totale** : La distance totale de l'itinéraire en kilomètres.
- **Station d'arrivée** : La station d'arrivée saisie.
- **Heure d'arrivée** : L'heure estimée d'arrivée à la station d'arrivée.

### Exemple d'utilisation

Voici un exemple d'utilisation de l'application :

```prolog
?- main.
Bienvenue dans l'application de calcul d'itinéraire.
Saisissez la station de départ: tsinga.
Saisissez la station d'arrivée: |: awai.
Saisissez l'heure de départ (HH:MM): |: "15:15".
Choisissez votre mode de transport (car, voiture, moto) : |: moto
|: .


Itinéraire le plus court :
De tsinga à briquetterie : 0.75 km
De briquetterie à poste : 1.5 km
De poste à ekounou : 3 km
De ekounou à awai : 2 km

Station de départ: tsinga
Heure de départ: 15:15
Durée du trajet: 5.4375 minutes
Coût du trajet: 725.0 francs
Distance totale: 7.25 km
Station d'arrivée: awai
Heure d'arrivée: 15:20
true .

```
