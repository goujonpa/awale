%Projet IA02 : Creation d'un jeu d'awale en langage prolog

%======================================= Initialisation ==============================================

/* Pour utiliser des bibliothèques */
bleu :- module(ansi_term, [ansi_format([fg(cyan)])/3]).
vert :- module(ansi_term, [ansi_format([fg(green)])/3]).
rouge :- module(ansi_term, [ansi_format([fg(red)])/3]).

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

/* Reinitialise le jeu */
reinit :- maj_etat(j1, [4,4,4,4,4,4]), maj_etat(j2, [4,4,4,4,4,4]),
		  maj_score(j1, 0), maj_score(j2, 0),
		  retract(joueur_courant(_)), assert(joueur_courant(j1)),
		  affiche_jeu.



%======================================== Conditions d'arrêt ==========================================%

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
	
/* verifie_fin(Joueur) */

maximum(A, B, 0):- A>B.
maximum(A, B, 1):- A<B.
maximum(A, A, 2).

/*jeu_valide(L1, L2, Score1, Score2) :- somme(calcul_somme(L1,_),somme(calcul_somme(L2,_),somme(Score1,Score2,_),_),48).*/

somme(A,B,C) :- C is (A+B).

calcul_somme([],0).
calcul_somme([X|R],N) :- calcul_somme(R,N1), N is N1+X.


cote_vide(J) :- calcul_somme(J,0).

affame(A) :- \+cote_vide(A), cote_vide(_).



%=======================Affichage=====================%

						
/* Affiche le plateau de jeu et les scores */
affiche_jeu :-
    etat(j1, Etat1), etat(j2, Etat2),
    score(j1, Score1), score(j2, Score2),
    write('\n'),
    write('------------------------- PLATEAU DE JEU ------------------------- SCORE -------\n'),
    write('------------------------------------------------------\n'),
    write('|  Joueur 2  |  '),
    affiche_valeur(Etat2, 0), write(Score2),
    (Score2 < 10 -> write('      |\n');
	write('     |\n')),
    write('------------------------------------------------------\n'),
    write('|  Joueur 1  |  '),
    affiche_valeur(Etat1, 0), write(Score1),
    (Score1 < 10 -> write('      |\n');
    write('     |\n')),
    write('------------------------------------------------------\n\n').

/* Vérifier que ca affiche bien les trucs de l'adversaire a linverse des trucs du joueurs. Sinon faire une procédure inverser et l'utiliser */

affiche_valeur(Liste, X) :- 
    X < 6 -> position(Liste, X, Valeur),
    write(Valeur),
	(Valeur < 10 -> write('  |  ');
    write(' |  ')), N is X + 1,
    affiche_valeur(Liste, N);
    write('          |      ').

%===========Fonctions de base==========%

inverse([],[]).
inverse([T|Q], R):- inverse(Q,QR), concat(QR, [T], R).

concat([], L, L).
concat([T|Q], L, [T|R]):- concat(Q, L, R).

/*Retourne la valeur de la case N*/
nieme(1, [H|_], H).
nieme(N, [_|T], Z):- N > 0, N1 is N - 1, nieme(N1, T, Z). 

/* Copier une liste */
copie(L1, L2) :- sous_copie(L1,L2).

sous_copie([],[]).
sous_copie([T|Q],[T|QR]) :- sous_copie(Q,QR).

maj(Le, Indice, Valeur, Ls) :-
    length(Ltmp, Indice),
    append(Ltmp, [_B|Q], Le),
    append(Ltmp, [Valeur|Q], Ls).



%=================Pour pouvoir jouer====================%

/*Mise à jour de l'etat du plateau d'un des deux joueurs*/
maj_etat(J, NouvelEtat) :- retract(etat(J, _)), assert(etat(J, NouvelEtat)).

/* Sauvegarde  : nth0(?Index, ?List, ?Elem) retourne True qd Elem est le ième élément de la liste, commence à 0
Ou utiliser nth1 pour que les indices commencent à 1 */
position(Liste, Indice, Valeur) :- nth0(Indice, Liste, Valeur). 


/* Copie du plateau d'un des deux joueurs */
etat_sauve(J, A) :- etat(J, T),
					position(T, 0, V1),
					position(T, 1, V2),
					position(T, 2, V3),
					position(T, 3, V4),
					position(T, 4, V5),
					position(T, 5, V6),
					A = [V1, V2, V3, V4, V5, V6].

/* Met à jour le score d'un des joueurs */
maj_score(J, NouveauScore) :- retract(score(J, _)), assert(score(J, NouveauScore)).

/* Mise à jour de tous le plateau */
maj_jeu(NouvelEtatj1, NouvelEtatj2, Score1, Score2) :-
    maj_etat(j1, NouvelEtatj1),
    maj_etat(j2, NouvelEtatj2),
    score(j1, TmpScore1),
    NouveauScore1 is TmpScore1 + Score1,
    score(j2, TmpScore2),
    NouveauScore2 is TmpScore2 + Score2,
    maj_score(j2, NouveauScore2),
    maj_score(j1, NouveauScore1).
	
/* Mise à jour du joueur courant */
maj_joueur :- joueur_courant(J),
				J == j1 -> retract(joueur_courant(_)),
				assert(joueur_courant(j2));
				retract(joueur_courant(_)),
				assert(joueur_courant(j1)).
				

/* Gagne 2 graines */
gagne_deux(Etat, NouvelEtat, Graine, 2, AjoutScore) :-
		maj(Etat, Graine, 0, TmpNouvelEtat),
		NouvelEtat = TmpNouvelEtat,
		AjoutScore = 2.
		
/* Gagne 3 graines */
gagne_trois(Etat, NouvelEtat, Graine, 3, AjoutScore) :-
		maj(Etat, Graine, 0, TmpNouvelEtat),
		NouvelEtat = TmpNouvelEtat,
		AjoutScore = 3.
		
/* Tour normal */
gagne_rien(Etat, NouvelEtat, _, _, AjoutScore) :-
    NouvelEtat = Etat,
    AjoutScore = 0.
	
/* Pour tout le tour */
gagne(Etat, NouvelEtat, _, _, AjoutScore):- gagne_deux ; gagne_rien ; gagne_trois.

/* On checke la case d'avant */
gagne_avant(Etat, NouvelEtat, Graine, AjoutScore) :-
    position(Etat, Graine, Trou),
    gagne(Etat, NouvelEtat, Graine, Trou, AjoutScore).
	
/* On verifie que le joueur ne joue pas une case vide */
case_vide(Graine) :- etat(j1, Etat),
					 position(Etat, Graine, Valeur),
					 Valeur > 0 -> true;
					 write('Vous ne pouvez jouer une case vide!'), fail.



%================= Pour jouer ====================%
				
debut1 :- write('\nBienvenue dans le jeu de l\'awale !\n\n').
debut2 :- affiche_jeu.


%================= Informations ====================%

				

				


