use ����������

insert into ����� values ('�������� �.�.', +75943958439, 'bul@yandex.ru')

insert into �����_����� values (8, 22), (7, 22)

insert into �����_����� values 
((select id_������ from ����� where �����.��� = '������ �.�.'), 
(select id_����� from ����� where �����.�������� = '������ ����������'))

insert into ����_����� values 
((select id_����� from ���� where ����.������������ = '������'),
(select id_����� from ����� where �����.�������� = '������'))

insert into ������������_����� values 
((select id_������������ from ������������ where ������������ = '��������'),
(select id_����� from ����� where �����.�������� = '������� ���'),
'2023-09-01',
50,
10000,
0,
350)