%Projet IA02 : Creation d'un jeu d'awale en langage prolog.

%======================================= initialisation ==============================================


%va changer plus tard
:- dynamic(etat/2).
:- dynamic(score/2).
:- dynamic(joueur_courrant/1).

%etats initiaux
etat(j1, [4,4,4,4,4,4]).
etat(j2, [4,4,4,4,4,4]).
score(j1,0).
score(j2,0).
joueur_courrant(j1).

%sauvegardes
:- assert(etat(j1_sauve, [4,4,4,4,4,4])).
:- assert(etat(j2_sauve, [4,4,4,4,4,4])).
:- assert(score(j1_sauve, 0)).
:- assert(score(j2_sauve, 0)).




%======================================== Conditions d'arrêt ==========================================

%Deux plateaux vides
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    cote_vide(L1),
    cote_vide(L2),
    maximum(Score1, Score2, Gagnant).

% 1 vide, un pas encore vide  
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    cote_vide(L1),
    affame(L2),
    calcul_somme(L2, Resultat),
    Score2_bis is Score2 + Resultat,
    maximum(Score1, Score2_bis, Gagnant).

% idem inverse
fin_jeu(L1, L2, Score1, Score2, Gagnant) :- 
    jeu_valide(L1, L2, Score1, Score2),
    cote_vide(L2),
    affame(L1),
    calcul_somme(L1, Resultat),
    Score1_bis is Score1 + Resultat,
    maximum(Score2, Score1_bis, Gagnant).

%un joueur a un score > 24
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

