use Типография
go
select * from Книга

--ТРИГГЕРЫ
-- триггеры каждого вида (after, instead of) для каждой из операций (insert, update, delete):

-- after insert
alter table Книга add Количество_выпусков int
go

update Книга
	set Количество_выпусков = (select distinct count(*) 
								from Издательство_книги 
								where Книга.id_книги = Издательство_Книги.id_книги)
go

create trigger Издательство_Книги_insert
on Издательство_Книги
after insert
as
	update Книга 
	set Количество_выпусков = Количество_выпусков + 1 
	where id_книги = (select id_книги from inserted);
go

-- after update
alter table Книга add Бестселлер bit default 0
go

update Книга
set Бестселлер = 0

select * from Книга
go

create trigger Проверка_на_Бестселлер
on Издательство_Книги
after update
as
	declare @proc real
	select @proc = (convert(real, (select Продано_книг from inserted)) / convert(real, (select Тираж from inserted))) * 100
	if @proc > 90 and (datediff(day, (select Дата_публикации from inserted), (select Дата_публикации from deleted)) < 30)
		begin
			update Книга
			set Бестселлер = 1
			where id_книги = (select id_книги from inserted)
		end
go

select * from Издательство_Книги
select * from Книга

update Издательство_Книги
set Продано_книг = 9600
where id_выпуска = 38
go

-- after delete
create trigger delete_Книга_check_Жанр
on Книга
after delete
as
	delete from Жанр
	where id_жанра not in (select distinct id_жанра from Жанр_Книги)
go

select * from Книга
select * from Жанр
select * from Жанр_Книги

delete from Книга
where id_книги = 24

insert into Книга values ('Сказка', 0, 0)
insert into Жанр_Книги values 
((select id_жанра from Жанр where Жанр.Наименование = 'Сказка'),
(select id_книги from Книга where Книга.Название = 'Сказка'))
go
drop trigger delete_Книга_check_Жанр

-- instead of insert
create trigger Проверка_Жанра
on Жанр_Книги
instead of insert
as
	if exists(select Жанр.id_жанра from Жанр, inserted where Жанр.id_жанра = inserted.id_жанра)
		insert into Жанр_Книги(id_книги, id_жанра) select id_книги, id_жанра from inserted
	else
		print('Данный жанр отсутствует в базе данных.')
go

insert into Жанр_Книги(id_жанра, id_книги) values (50, 7)

-- instead of update
create table Список_свободных_редакторов(
	id int identity primary key,
	nameRed varchar(50),
	prevPubl varchar(50)
)
go

create trigger Обн_Редактора
on Издательство
instead of update
as
	if not exists(select * from Издательство, deleted where Издательство.Наименование = deleted.Наименование)
		begin
			print('Данное издательство отсутствует в базе данных')
		end
	else
		begin
			if ((select Издательство.ФИО_редактора from Издательство, inserted where Издательство.id_издательства = inserted.id_издательства) != 
				(select inserted.ФИО_редактора from inserted))
				begin
					insert into Список_свободных_редакторов (nameRed, prevPubl) values 
					((select Издательство.ФИО_редактора from Издательство, inserted where Издательство.id_издательства = inserted.id_издательства),
					(select inserted.Наименование from inserted))
					update Издательство
						set ФИО_редактора = (select inserted.ФИО_редактора from inserted)
						where id_издательства = (select inserted.id_издательства from inserted)
					print('Список свободных редакторов пополнился')
				end
		end
go
drop trigger Обн_Редактора
update Издательство
set ФИО_редактора = 'Романенко Н.Н.'
where Наименование = 'АСТ'

select * from Издательство
select * from Список_свободных_редакторов


-- instead of delete
create trigger Проверка_Возможности_Удаления_Автора
on Автор
instead of delete
as
	if exists(select id_книги from Автор_Книги, deleted where Автор_Книги.id_автора = deleted.id_автора)		
		print('Автор не может быть удален из базы, так как у него есть публикации')
	else
		delete from Автор where id_автора = (select id_автора from deleted)
go

insert into Автор values ('Артемьев А.А.', +75943958430, 'ARTEM@yandex.ru')

delete from Автор
where id_автора = 11

SELECT *  FROM Автор

-- триггер, реализующий вычисления или формирование статистики или ведение истории изменений в БД:
create table History_Изданий(
	id_record int identity primary key,
	time_record datetime default GETDATE(),
	type_record varchar(50),
	book varchar(50),
	publisher varchar(50),
	date_publisher date,
)
go

create trigger Статистика
on Издательство_книги
after insert, update, delete
as
	declare @ci int, @cd int, @type varchar(50), @descr varchar(200)
	select @ci = (select count(*) from inserted)
	select @cd = (select count(*) from deleted)
	if @ci = 1 and @cd = 1 return -- инструкция затронула > 1 строки
	if @ci = 0 and @cd = 1
		begin
			insert into History_Изданий(type_record, book, publisher, date_publisher) values 
			('Удаление', 
			(select Название from Книга, deleted where Книга.id_книги = deleted.id_книги),
			(select Наименование from Издательство, deleted where Издательство.id_издательства = deleted.id_издательства),
			(select Дата_публикации from deleted))
		end
	if @ci = 1 and @cd = 0
		begin
			insert into History_Изданий(type_record, book, publisher, date_publisher) values 
			('Добавление', 
			(select Название from Книга, inserted where Книга.id_книги = inserted.id_книги),
			(select Наименование from Издательство, inserted where Издательство.id_издательства = inserted.id_издательства),
			(select Дата_публикации from inserted))
		end
	if @ci = 1 and @cd = 1
		begin
			insert into History_Изданий(type_record, book, publisher, date_publisher) values 
			('Обновление',
			(select Название from Книга, inserted where Книга.id_книги = inserted.id_книги),
			(select Наименование from Издательство, inserted where Издательство.id_издательства = inserted.id_издательства),
			(select Дата_публикации from inserted))
		end
go

update Издательство_Книги
set Продано_книг = 5000
where Продано_книг = 0


select * from Издательство_Книги
select * from History_Изданий