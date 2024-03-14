use Типография

insert into Автор values ('Булгаков М.А.', +75943958439, 'bul@yandex.ru')

insert into Автор_Книги values (8, 22), (7, 22)

insert into Автор_Книги values 
((select id_автора from Автор where Автор.ФИО = 'Гоголь Н.В.'), 
(select id_книги from Книга where Книга.Название = 'Братья Карамазовы'))

insert into Жанр_Книги values 
((select id_жанра from Жанр where Жанр.Наименование = 'Сказка'),
(select id_книги from Книга where Книга.Название = 'Сказка'))

insert into Издательство_Книги values 
((select id_издательства from Издательство where Наименование = 'Лабиринт'),
(select id_книги from Книга where Книга.Название = 'Золотой жук'),
'2023-09-01',
50,
10000,
0,
350)