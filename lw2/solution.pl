:- encoding(utf8).

better(X,Y,[X|Z]):-
    member(Y,Z).
better(X,Y,[_|Z]):-
    better(X,Y,Z).

begin(A,[A,_,_,_]).
medium(B,[_,B,_,_]).
medium(C,[_,_,C,_]).
end(D,[_,_,_,D]).

ans() :-
    Engineers = [man(A, WhoA), man(B, WhoB), man(C, WhoC),  man(D, WhoD)],
    ['Борисов','Кириллов','Данин','Савин']=[A, B, C, D],
    permutation(['Aвтомеханик','Радиотехник','Химик','Строитель'],[WhoA, WhoB, WhoC, WhoD]),
    
    permutation(Engineers,Age),
    member(Engineer1, Engineers),
    better(man('Борисов', _), Engineer1, Age),
    medium(man(_,'Химик'),Age),
    end(Young, Age),
    begin(Elderly,Age),

    permutation(Engineers,Chess),
    begin(Elderly,Chess),
    better( man('Борисов', _),man('Данин', _), Chess),
    better(man('Савин', _),man('Борисов', _),  Chess),
    better(man(_, 'Aвтомеханик'), man(_, 'Строитель'),  Chess),

    permutation(Engineers, Ski),
    begin(Young, Ski),
    better(man(_, 'Радиотехник'), man(_, 'Строитель'), Ski),
    better(man('Борисов', _), _, Ski),

    permutation(Engineers, Theatre),
    begin(Elderly,Theatre),
    member(Engineer2, Engineers),
    better(man('Борисов', _), Engineer2,  Theatre),
    better(Engineer2, man('Кириллов', _), Age),
    better(man(_, 'Химик'), man(_, 'Aвтомеханик'), Theatre),
    better(man(_, 'Строитель'),  man(_, 'Химик'), Theatre),

    write(A), write(' - '), write(WhoA), write('\n'),
    write(B), write(' - '), write(WhoB), write('\n'),
    write(C), write(' - '), write(WhoC), write('\n'),
    write(D), write(' - '), write(WhoD), write('\n').

    /*
    Борисов - Строитель
    Кириллов - Aвтомеханик
    Данин - Химик
    Савин - Радиотехник
    */
