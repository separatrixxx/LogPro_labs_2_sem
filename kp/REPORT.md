# Отчет по курсовому проекту
## по курсу "Логическое программирование"

### студент: Лохматов Никита Игоревич

## Результат проверки

Вариант задания:

 - [ ] стандартный, без NLP (на 3)
 - [x] стандартный, с NLP (на 3-4)
 - [ ] продвинутый (на 3-5)
 
| Преподаватель     | Дата         |  Оценка       |
|-------------------|--------------|---------------|
| Сошников Д.В. |              |               |
| Левинская М.А.|              |               |

> *Комментарии проверяющих (обратите внимание, что более подробные комментарии возможны непосредственно в репозитории по тексту программы)*

## Введение

Приступая к выполнению курсового проекта, я, во-первых, хотел бы ещё больше усовершенствовать свои навыки в логическом программировании. Также мне интересно поработать с генеалогическими деревьями, научиться их парсить и обрабатывать связи на Прологе. Этот курсовой проект особенно интересен тем, что во время его выполнения я реализую естесственно-языковой интерфейс в системе логического программирования, что очень интересно. 

## Задание

1. Создать родословное дерево в формате GEDCOM.
2. Преобразовать получившийся файл в набор утверждений на языке Prolog с использованием предиката child(ребенок, родитель), male(человек), female(человек) (вариант 3).
3. Реализовать предикат проверки/поиска шурина (вариант 1).
4. Реализовать программу на языке Prolog, которая позволит определять степень родства двух произвольных индивидуумов в дереве.
5. Реализовать естественно-языковый интерфейс к системе, позволяющий задавать вопросы относительно степеней родства, и получать осмысленные ответы.

## Получение родословного дерева

Я скачал программу Gramps, в которой добавил сначала себя, а потом по очереди всех родственников, создавая параллельно родословные связи. После этого я экспортировал дерево в формете GEDCOM.

## Конвертация родословного дерева

Для написания парсера я выбрал язык Python, посколько на нём подобный парсен написать проще всего, к тому же я хорошо знаю этот язык. 

Парсер открывает файл в формате GEDCOM в режиме чтения, считывает из файла все строки в список, присваивая этот список переменной `file`:

```python
my_tree_file = open("my_gen_tree.ged", "r", encoding='utf-8')
file = my_tree_file.readlines()
my_tree_file.close()
```

Затем он проходится по списку, считывая нужную информацию файла GEDCOM, например, пол или родственные связи. Для моего варианта я считывал отметки `HUSB`, `WIFE` и `CHIL`, чтобы определить родителей человека, далее я записывал это в объект:

```python
relative = {}

for line in file:
    if line.find('INDI') != -1:
        ID = line.split(' ')[1].rstrip()
    elif (line.find('GIVN')) != -1:
        name_and_surname = line.split(' ')[2].rstrip()
    elif line.find('SURN') != -1:
        name_and_surname = name_and_surname + ' ' + line.split(' ')[2].rstrip()
    elif line.find('SEX') != -1:
        if line.split(' ')[2].rstrip() == 'F':
            relative[ID] = [name_and_surname, '-1', '-1', 'female']
        else:
            relative[ID] = [name_and_surname, '-1', '-1', 'male']
    if line.find('HUSB') != -1:
        father = relative[line.split(' ')[2].rstrip()][0]
    elif line.find('WIFE') != -1:
        mother = relative[line.split(' ')[2].rstrip()][0]
    elif line.find('CHIL') != -1:
        relative[line.split(' ')[2].rstrip()][1] = father
        relative[line.split(' ')[2].rstrip()][2] = mother
```

В конце парсер открывает файл пролога в режиме записи и записывает необходимую инфорамцию в нужном для моего варианта виде, то есть `child(ребенок, родитель), male(человек), female(человек)`:

```python
prolog_file = open("tree.pl", "w", encoding='utf-8')

for i in relative:
    if relative[i][1] != '-1':
        prolog_file.write("child('" + relative[i][0] + "','" + relative[i][1] +
                          "').\n")
    if relative[i][2] != '-1':
        prolog_file.write("child('" + relative[i][0] + "','" + relative[i][2] +
                          "').\n")
for i in relative:
    if relative[i][3] == 'male':
        prolog_file.write(relative[i][3] + "('" + relative[i][0] + "').\n")
for i in relative:
    if relative[i][3] == 'female':
        prolog_file.write(relative[i][3] + "('" + relative[i][0] + "').\n")
prolog_file.close()
```

(мне пришлось написать имена родственников латинскими буквами)

## Предикат поиска родственника

В моём варианте нужно было реализовать предикат поиска шурина, то есть брата жены. Для его поиска необходимо знать, собственно, жену и её братьев. Для их поиска я реализовал предикаты `wife` и `sibling` соответственно:

```prolog
sibling(Person, Sibling):-
    child(Person, P),
    child(Sibling, P),
    Person \= Sibling.
    
sibling(Person, Sibling):-
    child(Person, P),
    child(Sibling, P),
    Person \= Sibling.
```

Зная эту информацию легко найти шурина:

```prolog
shurin(Man, Shur):-
    wife(Man, Woman),
    sibling(Woman, Shur),
    male(Shur).
```

**Результат:**

```prolog
?- shurin(Man, Shur).
Man = 'Igor Lokhmatov', 
Shur = 'Andrey Birykov' ;
```

**Да, это верно!**

## Определение степени родства

Сначала определим отношения мужа, жены, брата, сестры, отца, матери, дочки, сына и шурина. Для этого будем использовать поиск с итерационным заглублением:

```prolog
check(husband, Wife, Husband) :- wife(Husband, Wife).
check(wife, Husband, Wife) :- wife(Wife, Husband).
check(brother, Y, Brother) :- sibling(Brother, Y), male(Brother).
check(sister, Y, Sister) :- sibling(Sister, Y), female(Sister).
check(father, Child, Father) :- child(Child, Father), male(Father).
check(mother, Child, Mother) :- child(Child, Mother), female(Mother).
check(son, Parent, Child) :- child(Child, Parent), male(Child).
check(daughter, Parent, Child) :- child(Child, Parent), female(Child).
check(shurin, Man, Shurin) :- shurin(Man, Shurin).
```

Затем необходимо определим шаги, которые будет выполнять поиск. Он будет переходить к родителям, детям и брату/сестре:

```prolog
next_iteration(X, Z) :- child(X,Z).
next_iteration(X, Z) :- child(Z,X).
next_iteration(X, Z) :- sibling(X, Z).
```

Если нашлась связь между двумя людьми, то на выходе из рекурсии мы должны получить список отношений между льдьми, которые были на пути. В случае, если связь не нашлась, необходимо сделать шаг и искать связи относительно нового человека:

```prolog
search(Path, X, Y, N) :- N = 1, check(A, X, Y), Path = [A].
search(Path, X, Y, N) :- N > 1, next_iteration(X, Z), N1 is N-1, search(Res, Z, Y, N1), check(B, X, Z), append([B], Res, Path).
```

Далее возможны два случая:

1. Если путь не дан, и нам н7еобходимо его найти, то выполняем поиск с итерационным углублением.
2. В противном случае находим длину пути и ищем элементы с заданной длиной пути.

```prolog
relative(Res, X, Y) :- var(Res), inc(N), N < 6,  search(Res, X, Y, N), Y \= X.
relative(Res, X, Y) :- nonvar(Res), length(Res, N), search(Res, X, Y, N), Y \= X.
```

**Результат:**

```prolog
?- relative(Rel, 'Nikita Lokhmatov', 'Natalia Biryukova') .
Rel = [mother] ;

?-  relative(X, 'Lidia Lokhmatova', Y).
X = [brother],
Y = 'Nikita Lokhmatov' ;
X = [brother],
Y = 'Nikita Lokhmatov' ;
X = [brother],
Y = 'Arseniy Lokhmatov' ;
X = [brother],
Y = 'Arseniy Lokhmatov' ;
X = [father],
Y = 'Igor Lokhmatov' ;
X = [mother],
Y = 'Natalia Biryukova' ;
X = [father, shurin],
Y = 'Andrey Biryukov' ;
X = [father, shurin],
Y = 'Andrey Biryukov'
```

## Естественно-языковый интерфейс

Для выполнения работы на оценку 4 я решил реализовать естественно-языковой интерфейс. Существуют запросы:

1. Is name_1 relation name_2? - проверяет нахождение в ролственных связях двух людей.
2. Whose relation is name? - определяет, с кем имеет родственную связь заданные человек.
3. What relations between name_1 and name_2? - определяет тип родственной связи между двумя людьми.
 
Мной был реализован предикат `question(L)`, принимающий списки определенного вида и выводящий ответ на экран. Для определения слов `What`, `Whose` и других используются соответсвующие предикаты:

```prolog
question_1(X) :- member(X, [whose, "Whose"]).
question_2(X) :- member(X, [what, "What"]).
rel(X) :- member(X, [relations, relationship]).
bet(X) :- member(X, [between]).
word_1(X) :- member(X, [is, "Is"]).
word_2(X) :- member(X, [and, "And"]).
question_sign(X) :- member(X, ['?']).
```

Предикат `question(L)`:

```prolog
question(L) :-
    L = [IS, NAME_0, REL,NAME_1, QS],
    word_1(IS), relative(X, NAME_1,NAME_0), !,
    have_lst(X, REL), question_sign(QS),
    write(NAME_0), write(" is "), write(REL), write(" "), write(NAME_1),write(".").
question(L) :-
    L = [WHOSE, REL, IS, NAME, QS],
    question_1(WHOSE), word_1(IS), question_sign(QS),
    relative([REL], NAME, Ans),
    write(NAME), write(" is "), write(REL), write(" "), write(Ans), write("."), nl.
question(L) :-
    L = [WHAT, RELATIONS, BETWEEN, NAME_1, AND, NAME_0,QS],
    question_2(WHAT), rel(RELATIONS), bet(BETWEEN), word_2(AND), question_sign(QS),
    relative(Res, NAME_1, NAME_0),
    write_list(Res), nl.
```

**Примеры:**

```prolog
?- question([Is, 'Nikita Lokhmatov', son, 'Igor Lokhmatov', ?]).   
Nikita Lokhmatov is son Igor Lokhmatov.
Is = (is).

?- question([Whose, brother, is, 'Nikita Lokhmatov', ?]). 
Nikita Lokhmatov is brother Arseniy Lokhmatov.
Whose = whose ;
```

## Выводы

Язык Prolog является очень удобным для выполнения каких-либо задач, похожих на представленную в курсовом проекте. Он сильно упрощает решение логических задач, написание некоторых алгоритмов (dfs, bfs), также в нём есть механизм отсечения, который позволяет ускорять работу программы, убирая лишние вхождения. 

В результате выполнения курсового проекта я полностью удовлетворил свои ожидания, описанные во введении. Написал естественно-языковый интерфейс, создал генеалогочиское древо семье, написал парсер. Всё это было очень полезно для понимания не только логического программирования, но и для других областей.
