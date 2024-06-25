:- use_module(library(http/http_path)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_server_files)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_files)).

% :- http_handler(root(static), http_reply_from_files('static', []), [prefix]).

:- http_handler('/static/', http_reply_from_files('./static/', []), [prefix]).


% Handlers
:- http_handler(root(.), home_page_handler, []).
:- http_handler('/calcul_itineraire', calcul_itineraire_handler, [method(post)]).

% Charger index.html
:- http_handler('/index.html', http_reply_file('index.html', []), []).

% Home page handler
home_page_handler(_Request) :-
    reply_file('index.html', []).

% Calcul itineraire handler
% Calcul itineraire handler
calcul_itineraire_handler(Request) :-
    http_parameters(Request,
                    [ station_depart(StationDepart, []),
                      station_arrivee(StationArrivee, []),
                      heure_depart(HeureDepart, []),
                      mode_transport(Mode, [])
                    ]),
    (station(StationDepart), station(StationArrivee), mode_transport(Mode, _, _) ->
        recherche_itineraire_optimal(StationDepart, StationArrivee, Mode, court, Itineraire, Cout, Duree, Distance),
        calculer_heure_arrivee(HeureDepart, Duree, HeureArrivee),
        (Itineraire = [_] ->
            ItineraireStr = "Pas de stations intermédiaires";
            atomic_list_concat(Itineraire, ' -> ', ItineraireStr)),
       HtmlContent = 
        html([
            head([
                title('Résultat du calcul d\'itinéraire'),
                link([ rel('stylesheet'), href('/static/bootstrap-5.3.3-dist/css/bootstrap.min.css') ])

            ]),
            body([
                div(class('container mt-5 mb-5 p-5 bg-light border border-primary rounded'),
                    [
                        h1(class('text-center text-primary mb-4'), "Résultat du calcul d'itinéraire"),
                    p(class('text-center fs-4'), ['Itinéraire : de ', StationDepart, ' à ', StationArrivee, ' en ', Mode, '.']),
			p(class('text-center fs-4'),
			    [
				'Coût : ', 
				format('~2f', [Cout]), ' francs, ',
				br([]), % Balise <br> pour passer à la ligne suivante
				'Durée : ', 
				format('~2f', [Duree]), ' minutes, ',
				br([]), % Balise <br> pour passer à la ligne suivante
				'Distance : ', 
				format('~2f', [Distance]), ' km.'
			    ]),
			p(class('text-center fs-4'), ['Heure d\'arrivée : ', HeureArrivee, '.']),
			p(class('text-center fs-4'), ['Stations intermédiaires : ', ItineraireStr])

                    ]
                ),
                p(class('text-center'),
                  a([href('/index.html'), class('btn btn-primary mt-3')], 'Retourner à la page d\'accueil'))
            ])
        ]),
        reply_html_page(title('Résultat de la recherche'), HtmlContent)
    ;
        reply_html_page(title('Erreur'), 
                        html([div(class('container my-5'),
                                [
                                    div(class('card'),
                                        [
                                            div(class('card-header bg-danger text-white'), "Erreur"),
                                            div(class('card-body'), 
                                                [
                                                    p(class('card-text'), 'Données d\'entrée invalides.')
                                                ]
                                            )
                                        ]
                                    )
                                ]
                               )]))
    ).
    
% Lancer le serveur HTTP
:- initialization(http_server(http_dispatch, [port(8000)])).

% Définition des stations
station(chateau).
station(poste).
station(belibi).
station(emonbo).
station(briquetterie).
station(tsinga).
station(nkomkana).
station(melen).
station(mecc).
station(mokolo).
station(nkolbison).
station(oyomabang).
station(ekounou).
station(awai).
station(essomba).
station(nkoabang).

% Modes de transport avec coûts et vitesses
mode_transport(car, 50, 40).    % coût par km, vitesse km/h
mode_transport(voiture, 75, 60). % coût par km, vitesse km/h
mode_transport(moto, 100, 80).    % coût par km, vitesse km/h

% Prédicat pour rechercher un itinéraire entre deux stations
recherche_itineraire(Station_depart, Station_arrivee, Itineraire) :-
    trouve_chemin(Station_depart, Station_arrivee, [Station_depart], Itineraire).

% Prédicat pour trouver un chemin entre deux stations
trouve_chemin(Station_courante, Station_cible, Chemin, Itineraire) :-
    (Station_courante = Station_cible ->
        reverse(Chemin, Itineraire);
        (next_station(Station_courante, Station_suivante); prev_station(Station_courante, Station_suivante)),
        \+ member(Station_suivante, Chemin),
        trouve_chemin(Station_suivante, Station_cible, [Station_suivante|Chemin], Itineraire)).

% Déclaration discontiguë pour éviter les warnings
:- discontiguous next_station/2.
:- discontiguous prev_station/2.

% Trouver la station suivante
next_station(chateau, poste).
next_station(poste, belibi).
next_station(belibi, emonbo).
next_station(poste, briquetterie).
next_station(briquetterie, tsinga).
next_station(tsinga, nkomkana).
next_station(chateau, melen).
next_station(melen, mecc).
next_station(mecc, mokolo).
next_station(mokolo, tsinga).
next_station(mecc, nkolbison).
next_station(mecc, oyomabang).
next_station(oyomabang, nkolbison).
next_station(poste, ekounou).
next_station(ekounou, awai).
next_station(emonbo, essomba).
next_station(essomba, awai).
next_station(mokolo, poste).
next_station(poste, essomba).
next_station(essomba, nkoabang).

% Trouver la station précédente
prev_station(poste, chateau).
prev_station(belibi, poste).
prev_station(emonbo, belibi).
prev_station(briquetterie, poste).
prev_station(tsinga, briquetterie).
prev_station(nkomkana, tsinga).
prev_station(melen, chateau).
prev_station(mecc, melen).
prev_station(mokolo, mecc).
prev_station(tsinga, mokolo).
prev_station(nkolbison, mecc).
prev_station(oyomabang, mecc).
prev_station(nkolbison, oyomabang).
prev_station(ekounou, poste).
prev_station(awai, ekounou).
prev_station(essomba, emonbo).
prev_station(awai, essomba).
prev_station(poste, mokolo).
prev_station(essomba, poste).
prev_station(nkoabang, essomba).

% Calcul du coût, de la durée et de la distance pour un trajet
calcule_cout_duree_distance(Trajet, Mode, Cout, Duree, Distance) :-
    mode_transport(Mode, Cout_km, Vitesse),
    distance_total(Trajet, Distance),
    Cout is Cout_km * Distance,
    Duree is Distance / Vitesse * 60.

distance_total([_], 0).
distance_total([Station1, Station2|Stations], Distance) :-
    distance(Station1, Station2, Dist),
    distance_total([Station2|Stations], RestDistance),
    Distance is Dist + RestDistance.

% Exemple de distances entre stations (en km)
distance(chateau, poste, 2).
distance(poste, chateau,  2).

distance(poste, belibi, 2).
distance(belibi, poste,  2).

distance(belibi, emonbo, 0.75).
distance(emonbo, belibi,  0.75).

distance(poste, briquetterie, 1.5).
distance(briquetterie, poste,  1.5).

distance(briquetterie, tsinga, 0.75).
distance(tsinga, briquetterie,  0.75).

distance(tsinga, nkomkana, 0.75).
distance(nkomkana, tsinga, 0.75).

distance(chateau, melen, 0.75).
distance(melen, chateau, 0.75).

distance(melen, mecc, 1.5).
distance(mecc,melen,  1.5).

distance(mecc, mokolo, 0.75).
distance(mokolo, mecc,  0.75).

distance(mokolo, tsinga, 1.5).
distance(tsinga, mokolo,  1.5).

distance(mecc, nkolbison, 2).
distance(nkolbison, mecc,  2).

distance(mecc, oyomabang, 2).
distance(oyomabang, mecc,  2).

distance(oyomabang, nkolbison, 1.5).
distance(nkolbison, oyomabang,  1.5).

distance(poste, ekounou, 3).
distance(ekounou, poste,  3).

distance(ekounou, awai, 2).
distance(awai, ekounou,  2).

distance(emonbo, essomba, 1.5).
distance(essomba, emonbo,  1.5).

distance(essomba, awai, 1.5).
distance(awai, essomba,  1.5).

distance(mokolo, poste, 1.5).
distance(poste, mokolo, 1.5).

distance(poste, essomba, 3.75).
distance(essomba, poste,  3.75).

distance(essomba, nkoabang, 1.5).
distance(nkoabang, essomba,  1.5).

% Prédicat pour minimiser le coût ou la durée du trajet
recherche_itineraire_optimal(Station_depart, Station_arrivee, Mode, Type, Itineraire_optimal, Cout_optimal, Duree_optimal, Distance_optimal) :-
    findall(Itin-Cout-Duree-Dist,
            (recherche_itineraire(Station_depart, Station_arrivee, Itin),
             calcule_cout_duree_distance(Itin, Mode, Cout, Duree, Dist)),
            Itineraires),
    sort(Itineraires, SortedItineraires),
    (Type == court ->
        first(SortedItineraires, Itineraire_optimal-Cout_optimal-Duree_optimal-Distance_optimal);
    Type == long ->
        last(SortedItineraires, Itineraire_optimal-Cout_optimal-Duree_optimal-Distance_optimal)).

% Prédicat pour calculer l'heure d'arrivée
calculer_heure_arrivee(Heure_depart, Duree, Heure_arrivee) :-
    % Convertir l'heure de départ en chaîne de caractères si nécessaire
    (atomic(Heure_depart) -> atom_string(Heure_depart, Heure_depart_Str) ; Heure_depart_Str = Heure_depart),
    split_string(Heure_depart_Str, ":", "", [HeureStr, MinuteStr]),
    number_string(Heure, HeureStr),
    number_string(Minute, MinuteStr),
    Duree_heures is floor(Duree / 60),
    Duree_minutes is floor(Duree) mod 60,
    Heure_depart_minutes_totales is Heure * 60 + Minute,
    Heure_arrivee_minutes_totales is Heure_depart_minutes_totales + Duree_minutes + Duree_heures * 60,
    Heure_arrivee_heures is Heure_arrivee_minutes_totales // 60 mod 24,
    Heure_arrivee_minutes is Heure_arrivee_minutes_totales mod 60,
    format(atom(Heure_arrivee), '~`0t~d~2|:~`0t~d~2|', [Heure_arrivee_heures, Heure_arrivee_minutes]).

first([H|_], H).
last([X], X) :- !.
last([_|T], X) :- last(T, X).

