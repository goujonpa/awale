/* Projet IA02 : Creation d'un jeu d'awale en langage Prolog*/

%======================================= Initialisation ==============================================


/* Pour établie la base en dynamique */
:- dynamic(etat/2).
:- dynamic(score/2).
:- dynamic(joueur_courant/1).
:- dynamic(case_courante/1).
:- dynamic(camps_courant/1).
:- dynamic(gagnant/1).


/* Etats initiaux */
etat(j1, [4,4,4,4,4,4]).
etat(j2, [4,4,4,4,4,4]).
score(j1,0).
score(j2,0).
joueur_courant(j1).
case_courante(0).
camps_courant(0).
gagnant(0).

/* Sauvegardes  */
:- asserta(etat(j1, [4,4,4,4,4,4])).
:- asserta(etat(j2, [4,4,4,4,4,4])).
:- asserta(score(j1, 0)).
:- asserta(score(j2, 0)). 
:- asserta(joueur_courant(j1)).
:- asserta(case_courante(0)).
:- asserta(camps_courant(0)).
:- asserta(gagnant(0)).



%======================================== Conditions d'arrêt ==========================================%

/* Gagnant peut prendre la valeur '1' ou '2'. Gagnant est vrai si le gagnant est le 1 ou 2 envoyé en paramètre. Cette condition se verifie par le maximum, qui renvoie le gagnant. */

/* Deux plateaux vides */
fin_jeu(Etat1, Etat2, Score1, Score2) :- 
										    cote_vide(Etat1),
										    cote_vide(Etat2).

/* 2 vide, 1 pas vide à la fin du tour */
/* Joueur_courant à j2 parce que maj_joueur intervient avant */
fin_jeu(Etat1, Etat2, Score1, Score2) :- 
											joueur_courant(j2),
										    affame(Etat1, Etat2),
										    calcul_somme(Etat1, Resultat),
										    NouveauScore1 is Score1 + Resultat,
										    maj_score(j1, NouveauScore1),
										    maj_etat(j1, [0,0,0,0,0,0]).


/* 2 vide, 1 pas vide à la fin du tour */
/* idem */
fin_jeu(Etat1, Etat2, Score1, Score2) :- 
											joueur_courant(j1),
										    affame(Etat2, Etat1),
										    calcul_somme(Etat2, Resultat),
										    NouveauScore2 is Score2 + Resultat,
										    maj_score(j2, NouveauScore2),
										    maj_etat(j2, [0,0,0,0,0,0]).

/* un joueur a un score > 24 */
fin_jeu(Etat1, Etat2, Score1, Score2) :- 
    Score1 > 24.

fin_jeu(Etat1, Etat2, Score1, Score2) :- 
    Score2 > 24.
	
verifie_fin:- 
				etat(j1, Etat1),
				etat(j2, Etat2),
				score(j1, Score1),
				score(j2, Score2),
				jeu_valide(Etat1, Etat2, Score1, Score2),
				fin_jeu(Etat1, Etat2, Score1, Score2),
				(fin_jeu(Etat1, Etat2, Score1, Score2) ->
					score(j1, ScoreFinal1),
					score(j2, ScoreFinal2),
				    maximum(ScoreFinal1, ScoreFinal2, Gagnant),
				    maj_gagnant(Gagnant)
				;
				!
				).

maximum(X1, X1, 0).
maximum(X1, X2, j1):- X1 > X2.
maximum(X1, X2, j2):- X1 < X2.

jeu_valide(Etat1, Etat2, Score1, Score2) :- calcul_somme(Etat1, R1),
									  calcul_somme(Etat2, R2),
									  somme(Score1, Score2, RS),
									  somme(R1, R2, RL),
									  somme(RS, RL, 48).

somme(A,B,C) :- C is (A+B).

calcul_somme([],0).
calcul_somme([T|Q],R) :- calcul_somme(Q,R1), R is R1+T.

cote_vide(Etat) :- calcul_somme(Etat,0).

affame(A, B) :- \+cote_vide(A), cote_vide(B).


concat([], L, L).
concat([T|Q], L, [T|R]):- concat(Q, L, R).

inverse([],[]).
inverse([T|Q], R):- inverse(Q,QR), concat(QR, [T], R).


/* Reinitialise le jeu */
reinit :- 	maj_etat(j1, [4,4,4,4,4,4]), 
			maj_etat(j2, [4,4,4,4,4,4]),
		  	maj_score(j1, 0), 
		  	maj_score(j2, 0),
		  	retract(joueur_courant(_)), 
		  	asserta(joueur_courant(j1)),
		  	maj_case(0),
		  	maj_camps(0),
		  	maj_gagnant(0).		 
		  

%===========Fonctions de base==========%
/* Le : Liste à modifier
Ls : Liste modifiée renvoyée
Indice : Case à modifier
Valeur : nouvelle valeur à remplacer dans la case "Indice"*/

maj(Le, Indice, Valeur, Ls) :-
    length(Ltmp, Indice),
    append(Ltmp, [_B|Q], Le),
    append(Ltmp, [Valeur|Q], Ls).
	

/* Sauvegarde  : nth0(?Index, ?List, ?Elem) retourne True qd Elem est le ième élément de la liste, commence à 0
Ou utiliser nth1 pour que les indices commencent à 1 */
position(Liste, Indice, Valeur) :- nth0(Indice, Liste, Valeur). 

%=======================Affichage=====================%

						
/* Affiche le plateau de jeu et les scores */
affiche_jeu :-
    etat(j1, Etat1), etat(j2, Etat2),
    score(j1, Score1), score(j2, Score2),
    write('\n\n\n'),
    write('------------------------- PLATEAU DE JEU ------------------------- SCORE -------\n'),
    write('------------------------------------------------------\n'),
    write('|  Joueur 2  |  '),
	inverse(Etat2, NewEtat2),
    affiche_valeur(NewEtat2, 0), write(Score2),
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


%=================Pour pouvoir jouer====================%

/*Mise à jour de l'etat du plateau d'un des deux joueurs*/
maj_etat(Joueur, NouvelEtat) :- retract(etat(Joueur, _)), asserta(etat(Joueur, NouvelEtat)).


/* Met à jour le score d'un des joueurs */
maj_score(Joueur, NouveauScore) :- retract(score(Joueur, _)), asserta(score(Joueur, NouveauScore)). 

/* Mise à jour de tout le plateau */
maj_jeu(NouvelEtatj1, NouvelEtatj2, Score1, Score2) :- 
    maj_etat(j1, NouvelEtatj1),
    maj_etat(j2, NouvelEtatj2),
    score(j1, TmpScore1),
    NouveauScore1 is TmpScore1 + Score1,
    score(j2, TmpScore2),
    NouveauScore2 is TmpScore2 + Score2,
    maj_score(j2, NouveauScore2),
    maj_score(j1, NouveauScore1).

/* Mise à jour du gagnant */
maj_gagnant(Joueur) :-   retract(gagnant(_)),
						asserta(gagnant(Joueur)).

/* Mise à jour du joueur courant */
maj_joueur(Joueur) :- joueur_courant(Joueur),
					Joueur == j1 -> retract(joueur_courant(_)), asserta(joueur_courant(j2));
					retract(joueur_courant(_)), asserta(joueur_courant(j1)).

/* Mise à jour de la dernière case insérée */
maj_case(Case) :-   retract(case_courante(_)),
					asserta(case_courante(Case)).

/* Mise à jour du dernier camp inséré */
maj_camps(Camps) :- retract(camps_courant(_)),
					asserta(camps_courant(Camps)).

/* Gagne quoi que ce soit ??? */
gagne(Joueur):-	case_courante(Case),
				camps_courant(Camps),
				(Camps \= Joueur -> 
					etat(Camps, Etat),
					position(Etat, Case, NbGraines),
					gagne_joueur(Etat, Joueur, Camps, NbGraines, Case),
					(NbGraines == 2 -> 
						gagne_avant(Case, Joueur)
					;
					!
					),
					(NbGraines == 3 ->
						gagne_avant(Case, Joueur)
					;
					!
					)
				;
				!
				).

/* Gagne 2 graines */
gagne_joueur(Etat, Joueur, Camps, 2, Case) :-  maj(Etat, Case, 0, TmpNouvelEtat),
										maj_etat(Camps, TmpNouvelEtat),
										score(Joueur, Score),
										NouveauScore is Score + 2,
										maj_score(Joueur, NouveauScore).
		
/* Gagne 3 graines */
gagne_joueur(Etat, Joueur, Camps, 3, Case) :-  maj(Etat, Case, 0, TmpNouvelEtat),
										maj_etat(Camps, TmpNouvelEtat),
										score(Joueur, Score),
										NouveauScore is Score + 3,
										maj_score(Joueur, NouveauScore).
		
/* Tour normal */
gagne_joueur(Etat, Joueur, Camps, _, Case):- !.
	

/* On checke la case d'avant : il faut ajouter que la case d'avant doit etre chez l'adversaire
Je vérifie que je suis bien dans le camp adverse, ça se répète autant de fois qu'il y a de cases adverses avant */
gagne_avant(Case, Joueur) :-
													(Case > 0 ->
														NouvelleCase is Case - 1,
														maj_case(NouvelleCase),
														gagne(Joueur)
													; 
													!
													).
	
/* On verifie que le joueur ne joue pas une case vide */
case_vide(Case) :-  joueur_courant(Joueur),
					etat(Joueur, Etat),
					position(Etat, Case, Valeur),
					(Valeur > 0 -> true
					;
					write('\n\nVous ne pouvez jouer une case vide!\n\n'),
					!,fail
					).


/*Insertion des graines dans les cases. Tant que le nombre de graines est superieur a 0 on ajoute une graine. Si le nombre de graine est egale a 0,
on verifie alors le joueur courant et si la case courante possede une ou deux graine */

distribue(Etat1,Etat2,Case,0).

distribue(Etat1,Etat2,Case,Graine):- joueur_courant(Joueur),
												(Graine > 0 ->
													(Case == 6 -> 
														maj_joueur(Joueur),
														distribue(Etat2,Etat1,0,Graine),
														maj_joueur(Joueur)
														;
														position(Etat1, Case, GraineCase),
														NbGraines is GraineCase + 1,
														maj(Etat1, Case, NbGraines, NouvelEtat1), 
														maj_etat(Joueur, NouvelEtat1),
														NouvelleCase is Case + 1,
														NouvelleGraine is Graine - 1,
														maj_case(Case),
														maj_camps(Joueur),
														distribue(NouvelEtat1,Etat2,NouvelleCase,NouvelleGraine)
													)

												).
	
	
changement(Case, Etat1, Etat2, Score1, Score2):-    joueur_courant(Joueur), 
													(case_vide(Case) -> 
														(Joueur == j1 ->
															position(Etat1, Case, Graine),
															maj(Etat1, Case, 0, NouvelEtat1), 
															maj_etat(j1, NouvelEtat1),
															NouvelleCase is Case + 1,
															distribue(NouvelEtat1,Etat2,NouvelleCase,Graine),
															gagne(Joueur),
															maj_joueur(Joueur)
															;
															position(Etat2, Case, Graine),
															maj(Etat2, Case, 0, NouvelEtat2),
															maj_etat(j2, NouvelEtat2),
															NouvelleCase is Case + 1,
															distribue(NouvelEtat2,Etat1,NouvelleCase,Graine),
															gagne(Joueur),
															maj_joueur(Joueur)
														)
													;
													write('Reessayez\n')
													).

													
												
														   
%=============== Sans IA ==========================%

debut :- 
			reinit,
		 	write('\nBienvenue dans le jeu de l\'awale !\n\n'),
         	affiche_jeu,
		 	fonction.

fonction :-	write('\nEntrez la case a distribuer (numero de case de 0 a 5)\n\n'),
			read(Case),
			etat(j1, Etat1),
			etat(j2, Etat2),
			score(j1, Score1),
			score(j2, Score2),
			joueur_courant(Joueur),
			changement(Case, Etat1, Etat2, Score1, Score2),
			affiche_jeu,
			(verifie_fin ->
				gagnant(Gagnant),
				affiche_jeu,
				write('\n\nFin du jeu !\n\n'),
				write('Gagnant : '),
				write(Gagnant)
			;
			fonction
			).

%================ IA ============================%


debut2 :- 
			reinit,
		 	write('\nBienvenue dans le jeu de l\'awale !\n\n'),
         	affiche_jeu,
		 	fonction2.

fonction2 :-	
			etat(j1, Etat1),
			etat(j2, Etat2),
			score(j1, Score1),
			score(j2, Score2),
			joueur_courant(Joueur),
			(Joueur == j1 ->
				write('\nEntrez la case a distribuer (numero de case de 0 a 5)\n\n'),
				read(Case)
			;
				Case is random(6)
			),
			changement(Case, Etat1, Etat2, Score1, Score2),
			affiche_jeu,
			(verifie_fin ->
				gagnant(Gagnant),
				affiche_jeu,
				write('\n\nFin du jeu !\n\n'),
				write('Gagnant : '),
				write(Gagnant)
			;
				fonction2
			).





				   
				   
%================= Pour jouer ====================%
				
main :- affichageMenu,
		choixMenu.



affichageMenu:-
    nl,nl,
    write('             ________________________________________________________'),nl,
    write('            |                                                        |'), nl,
    write('            |                                                        |'), nl,
    write('            |                   LE JEU DE L AWALE                    |'), nl,
    write('            |                                                        |'), nl,
    write('            |                                                        |'), nl,
    write('            |-------------------- MENU PRINCIPAL --------------------|'), nl,
    write('            |                                                        |'), nl,
    write('            |                                                        |'), nl,
    write('            | Selectionnez le choix de jeu :                         |'), nl,
    write('            | 1. Partie Joueur contre Joueur                         |'), nl,
    write('            | 2. Partie Joueur contre Ordinateur                     |'), nl,
    write('            | 3. Informations                                        |'), nl,
    write('            | 4. Quitter                                             |'), nl,
    write('            |                                                        |'), nl,
    write('            |________________________________________________________|'), nl,
    nl,nl.


choixMenu:-
    write('Saisissez le numero de votre choix : '),
    read(Choix),nl,nl,
    launch(Choix).


launch(1):- write('Lancement du jeu en mode J&J'), nl, write('----------------------------'), debut, nl, nl.
launch(2):- write('Lancement du jeu en mode J&O'), nl, write('----------------------------'), debut2, nl,nl.
launch(3):- write('Informations'), nl, write('------------'),nl,nl,write('Langage de programation : Prolog'),nl,write('Nom  : Jeu de l AWALE'), nl, write('Developpeurs : Marie CHATELIN & Paul GOUJON'),nl,nl, choixMenu.
launch(4):- write('Merci d avoir joué, à très bientôt !'),nl,nl.
