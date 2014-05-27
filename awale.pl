%Projet IA02 : Creation d'un jeu d'awale en langage prolog.

%======================================= Initialisation ==============================================


/* Pour établie la base en dynamique */
:- dynamic(etat/2).
:- dynamic(score/2).
:- dynamic(joueur_courant/1).

/* Etats initiaux */
etat(j1, [4,4,4,4,4,4]).
etat(j2, [4,4,4,4,4,4]).
score(j1,0).
score(j2,0).
joueur_courant(j1).

/* Sauvegardes  */
ajout :- asserta(etat(j1_sauve, [4,4,4,4,4,4])).
ajout :- asserta(etat(j2_sauve, [4,4,4,4,4,4])).
ajout :- asserta(score(j1_sauve, 0)).
ajout :- asserta(score(j2_sauve, 0)). 




%======================================== Conditions d'arrêt ==========================================

/* Deux plateaux vides */
/*PAUL : 
Gagnant peut prendre la valeur '1' ou '2'. 
Gagnant est vrai si le gagnant est le 1 ou 2 envoyé en paramètre. Cette condition se verifie par le maximum, qui renvoie le gagnant.
*/
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
    maximum(Score1_bis, Score2, Gagnant).

/* un joueur a un score > 24 */
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    Score1 > 24,
    Gagnant is 1.

fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    Score2 > 24,
    Gagnant is 2.

maximum(X1, X1, 0).
maximum(X1, X2, 1):- X1 > X2.
maximum(X1, X2, 2):- X1 < X2.

jeu_valide(L1, L2, Score1, Score2) :- 
                                        calcul_somme(L1, R1),
                                        calcul_somme(L2, R2),
                                        somme(Score1, Score2, RS),
                                        somme(R1, R2, RL),
                                        somme(RS, RL, 48).

somme(A,B,C) :- C is (A+B).

calcul_somme([],0).
calcul_somme([T|Q],R) :- calcul_somme(Q,R1), R is R1+T.


cote_vide(J) :- calcul_somme(J,0).

affame(A) :- \+cote_vide(A), cote_vide(_).

/* Reinitialise le jeu */
reinit :- set_etat(j1, [4,4,4,4,4,4]), set_etat(j2, [4,4,4,4,4,4]),
		  set_score(j1, 0), set_score(j2, 0),
		  retract(joueur_courant(_)), assert(joueur_courant(j1)),
		  draw_game.


%=======================Affichage=====================%

afficheSousEtatJoueur([]):- nl.
afficheSousEtatJoueur([T|Q]) :- write(T), write('|'), afficheSousEtatJoueur(Q).

afficheSousEtatAdversaire(L):- inverse(L, R), afficheSousEtatJoueur(R).

afficheTiret(0):-!.
afficheTiret(N):- write('- '), N1 is N-1, afficheTiret(N1).

afficheEtat([Jo1, Jo2]):- afficheTiret(6), nl, 
						afficheSousEtatAdversaire(Jo1), 
						afficheTiret(6),  nl,
						afficheSousEtatJoueur(Jo2),
						afficheTiret(6), nl.		


						
/* Affiche le plateau de jeu et les scores */
afficheJeu :-
    etat(j1, Etat1), etat(j2, Etat2),
    score(j1, Score1), score(j2, Score2),
    write('\n'),
    write('------------------------- PLATEAU DE JEU ------------------------- SCORE -------\n'),
    write('------------------------------------------------------\n'),
    write('|  Joueur 2  |  '),
    afficheValeur(Etat2, 0), write(Score2),
    (Score2 < 10 -> write('      |\n');
	write('     |\n')),
    write('------------------------------------------------------\n'),
    write('|  Joueur 1  |  '),
    afficheValeur(Etat1, 0), write(Score1),
    (Score1 < 10 -> write('      |\n');
    write('     |\n')),
    write('------------------------------------------------------\n\n').
	
afficheValeur(Liste, X) :- 
    X < 6 -> get(Liste, X, Valeur),
    write(Valeur),
	(Valeur < 10 -> write('  |  ');
    write(' |  ')), N is X + 1,
    afficheValeur(Liste, N);
    write('          |      ').

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
				
				
/* Copier une liste */
copie(L1, L2) :- sous_copie(L1,L2).
sous_copie([],[]).
sous_copie([T|Q],[T|QR]) :- sous_copie(Q,QR).

