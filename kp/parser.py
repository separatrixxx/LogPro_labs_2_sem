my_tree_file = open("my_gen_tree.ged", "r", encoding='utf-8')
file = my_tree_file.readlines()
my_tree_file.close()

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