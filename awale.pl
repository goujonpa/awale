%Projet IA02 : Creation d'un jeu d'awale en langage prolog.

%======================================= initialisation ==============================================


/* va changer plus tard */
:- dynamic(etat/2).
:- dynamic(score/2).
:- dynamic(joueur_courant/1).

/* etats initiaux */
etat(j1, [4,4,4,4,4,4]).
etat(j2, [4,4,4,4,4,4]).
score(j1,0).
score(j2,0).
joueur_courant(j1).

/* sauvegardes 
:- initialization(etat(j1_sauve, [4,4,4,4,4,4])).
:- initialization(etat(j2_sauve, [4,4,4,4,4,4])).
:- initialization(score(j1_sauve, 0)).
:- initialization(score(j2_sauve, 0)). */




%======================================== Conditions d'arrêt ==========================================

/* Deux plateaux vides */
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    cote_vide(L1),
    cote_vide(L2),
    maximum(Score1, Score2, Gagnant).

/* 1 vide, un pas encore vide */
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    cote_vide(L1),
    affame(L2),
    calcul_somme(L2, Resultat),
    Score2_bis is Score2 + Resultat,
    maximum(Score1, Score2_bis, Gagnant).

/* idem inverse */
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    cote_vide(L2),
    affame(L1),
    calcul_somme(L1, Resultat),
    Score1_bis is Score1 + Resultat,
    maximum(Score2, Score1_bis, Gagnant).

/* un joueur a un score > 24 */
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    Score1 > 24,
    Gagnant is j1.

fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    Score2 > 24,
    Gagnant is j2.

maximum(A, B, 0):- A>B.
maximum(A, B, 1):- A<B.
maximum(A, A, 2).

/*jeu_valide().
cote_vide().
affame().
calcul_somme().*/


%=======================Affichage=====================%

afficheSousEtatJoueur([]):- nl.
afficheSousEtatJoueur([T|Q]) :- write(T), write('|'), afficheSousEtatJoueur(Q).

afficheSousEtatAdversaire(L):- inverse(L, R), afficheSousEtatJoueur(R).

afficheTiret(0):-!.
afficheTiret(N):- write('- '), N1 is N-1, afficheTiret(N1).

afficheEtat([H, B]):- afficheTiret(6), nl, 
						afficheSousEtatAdversaire(H), 
						afficheTiret(6),  nl,
						afficheSousEtatJoueur(B),
						afficheTiret(6), nl.		


						
%===========Fonctions de base==========%

inverse([],[]).
inverse([T|Q], R):- inverse(Q,QR), concat(QR, [T], R).

concat([], L, L).
concat([T|Q], L, [T|R]):- concat(Q, L, R).

/*Retourne la valeur de la case N*/
nieme(1, [H|_], H).
nieme(N, [_|T], Z):- N > 0, N1 is N - 1, nieme(N1, T, Z). 





%=================Pour pouvoir jouer====================%

/*Mise à jour de l'etat du plateau d'un des deux joueurs*/
set_etat(J, NouvelEtat) :- retract(etat(J, _)), assert(etat(J, NouvelEtat)).

/* Sauvegarde  : nth0(?Index, ?List, ?Elem) retourne True qd Elem est le ième élément de la liste. Commence à 0.*/
get(Liste, Indice, Valeur) :- nth0(Indice, Liste, Valeur). 
/* Ou utiliser nth1 pour que les indices commencent à 1 */

/* Copie du plateau d'un des deux joueurs */
etat_sauve(J, A) :- etat(J, T),
					get(T, 0, V1),
					get(T, 1, V2),
					get(T, 2, V3),
					get(T, 3, V4),
					get(T, 4, V5),
					get(T, 5, V6),
					A = [V1, V2, V3, V4, V5, V6].

/* Met à jour le score d'un des joueurs */
set_score(J, NouveauScore) :- retract(score(J, _)), assert(score(J, NouveauScore)).

/* Mise à jour de tous le plateau */
set_jeu(NouvelEtatj1, NouvelEtatj2, Score1, Score2) :-
    set_etat(j1, NouvelEtatj1),
    set_etat(j2, NouvelEtatj2),
    score(j1, TmpScore1),
    NouveauScore1 is TmpScore1 + Score1,
    score(j2, TmpScore2),
    NouveauScore2 is TmpScore2 + Score2,
    set_score(j2, NouveauScore2),
    set_score(j1, NouveauScore1).
	
/* Mise à jour du joueur courant */
set_joueur :- joueur_courant(J),
				J == j1 -> retract(joueur_courant(_)),
				assert(joueur_courant(j2));
				retract(joueur_courant(_)),
				assert(joueur_courant(j1)).