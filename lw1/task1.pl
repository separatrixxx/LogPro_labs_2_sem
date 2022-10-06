% Первая часть задания - предикаты работы со списками

% Реализация стандартных предикатов обработки списков
mylength([], 0).
mylength([_|T], N):-
	mylength(T, N1),
	N is N1 + 1.
    
mymember(X, [X|_]).
mymember(X, [_|L]) :- mymember(X, L).

myappend([], L, L).
myappend([X|L1], L2, [X|L]) :- myappend(L1, L2, L).

myremove([X|L], X, L).
myremove([K|L], X, [K|L1]) :- myremove(L, X, L1).

mypermute([], []).
mypermute(L, [X|P]) :- myremove(L, X, L1), mypermute(L1, P).

mysublist([], _).
mysublist([H|S], [H|L]) :- mysublist(S, L).
mysublist([H1|S], [H2|L]) :- mysublist([H1|S], L), H1 \= H2.

% Предикат обработки списка

% Получение N-го элемента списка

n_elem(0, [H|_], H):-!.
n_elem(N, [_|L], X):-
    Num is N - 1,
    n_elem(Num, L, X).

% Реализация на основе стандартных предикатов обработки списков
n_elem_standart(N, L, X):-
    append(A, [X|_], L),
    length(A, N).
    
    
% Предикат обработки числового списка

% Проверка списка на геометрическую прогрессию

check_geom_progress(L):-
    L = [X, Y|_],
    D is Y / X,
    check_geom_progress(L, D).
check_geom_progress([_], _):-!.
check_geom_progress([X, Y|T], D):-
    D is Y / X,
    check_geom_progress([Y|T], D).

% Реализация на основе стандартных предикатов обработки списков
del_first(L,R):- 
    append([_],R,L).
check_geom_progress_standart(L):-
    L = [X, Y|_],
    D is Y / X,
    del_first(L,R),
    check_geom_progress_standart(R, D).
check_geom_progress_standart([_], _):-!.
check_geom_progress_standart(R, D):-
    R = [X, Y|_],
    D is Y / X,
    del_first(R,R1),
    check_geom_progress_standart(R1, D).

% Пример совместного использования предикатов, реализованных в пунктах 3 и 4

my_pop(L, R, Last) :-
    mylength(L, Len),
    LastPos is Len - 1,
    n_elem(LastPos, L, Last),
    append(R, [_], L).
