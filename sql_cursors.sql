use Типография
go

-- КУРСОРЫ
-- 1. реализовать ПЗ или ХП или Т, использующие курсоры (ISO Syntax)

-- ХП, которая считает сколько книг каждого жанра было выпущено каждым издательством
create procedure Колич_Книг_Кажд_Жанр_Изд
as
	begin
		create table #Жанры_Изд(
			Названиие_Издательства varchar(50)
		)

		insert into #Жанры_Изд
		select Наименование from Издательство

		declare @жанр varchar(20)

		declare Жанры cursor for
		select Наименование from Жанр

		open Жанры
		fetch next from Жанры into @жанр

		while @@FETCH_STATUS = 0
			begin
				execute('alter table #Жанры_Изд add ' + @жанр + ' int')
				execute('update #Жанры_Изд set ' + @жанр + ' = 0')

				declare @cJ int, @Publ varchar(50)

				declare ПодсчетЖанров cursor for
				select count(Жанр_Книги.id_жанра), Издательство.Наименование 
				from Издательство_Книги, Издательство, Жанр_Книги, Жанр
				where Издательство_Книги.id_издательства = Издательство.id_издательства 
						and Издательство_Книги.id_книги = Жанр_Книги.id_книги and
						Жанр_Книги.id_жанра = Жанр.id_жанра and Жанр.Наименование = @жанр
				group by Издательство.Наименование

				open ПодсчетЖанров
				fetch next from ПодсчетЖанров into @cJ, @Publ

				while @@FETCH_STATUS = 0
					begin
						execute('update #Жанры_Изд 
								set ' + @жанр + ' = ' + @cJ + 
								' where Названиие_Издательства = ''' + @Publ + '''')								
						fetch next from ПодсчетЖанров into @cJ, @Publ
					end

				close ПодсчетЖанров
				deallocate ПодсчетЖанров

				fetch next from Жанры into @жанр
			end

		close Жанры
		deallocate Жанры

		select * from #Жанры_Изд
	end
go

exec Колич_Книг_Кажд_Жанр_Изд
go

drop procedure Колич_Книг_Кажд_Жанр_Изд

-- 2. продемонстрировать различия в работе статических и динамических курсоров, а также курсоров keyset
select * from Издательство

-- статический курсор
declare staticListPublisher cursor static for
select Наименование from Издательство

open staticListPublisher

insert into Издательство values ('Чайка', 'Спб, Московский проспект 169', 'Редакторов А.В.', 'email')

declare @name varchar(50)
fetch next from staticListPublisher into @name
while @@FETCH_STATUS = 0 
	begin
		print @name
		fetch next from staticListPublisher into @name
	end

close staticListPublisher
deallocate staticListPublisher
go


-- динамический курсор
declare dynamicListPublisher cursor dynamic for
select Наименование from Издательство

open dynamicListPublisher

insert into Издательство values ('Чайка', 'Спб, Московский проспект 169', 'Редакторов А.В.', 'email')

declare @name varchar(50)
fetch next from dynamicListPublisher into @name
while @@FETCH_STATUS = 0 
	begin
		print @name
		fetch next from dynamicListPublisher into @name
	end

close dynamicListPublisher
deallocate dynamicListPublisher
go

-- курсор keyset

create table АвторBuf(
	id_автора int primary key,
	fio varchar(100) NOT NULL,
	tel varchar(50) NULL unique,
)
go

delete АвторBuf
go

insert into АвторBuf
select id_автора, ФИО, Телефон from Автор
go

select * from АвторBuf
go

---------------------------------------------------------------------

declare СписокАвторов cursor keyset for
select id_автора, fio, tel from АвторBuf

open СписокАвторов 

declare @fioA varchar(60), @telA varchar(20), @count int, @idA int

fetch next from СписокАвторов into @idA, @fioA, @telA

select @count = 1

while @@FETCH_STATUS = 0
begin
	print cast(@idA as varchar) + ' ' + @fioA + ' ' + @telA

	if (@count = 2) begin
			update АвторBuf
			set tel = '+1 111 111 11 11'
			where fio = 'Носов Н.Н.'
	end

	if (@count = 4)
		begin
			insert into АвторBuf values (69, 'Парусов А.А.', '+7 599 765 45 45')
		end

	if (@count = 5)
		begin
			delete from АвторBuf
			where id_автора = 6
		end
	
	select @count = @count + 1

	fetch next from СписокАвторов into @idA, @fioA, @telA
end

close СписокАвторов
deallocate СписокАвторов
go

-----------------------------------------------------------

select * from АвторBuf
go

-- 3. используя директивы update и delete с условиями where current of <имя курсора> реализовать примеры 
-- изменения и удаления записей посредством курсора

-- update where current of
declare Повыш_Цен_Издательства cursor for
select id_книги, Цена 
from Издательство_Книги, Издательство 
where Издательство_Книги.id_издательства = Издательство.id_издательства and Издательство.Наименование = 'Эксмо'

open Повыш_Цен_Издательства
declare @id_book int, @cost real, @avgcost real
select @avgcost = (select avg(Цена) from Издательство_Книги, Издательство where Издательство_Книги.id_издательства = Издательство.id_издательства and Издательство.Наименование = 'Эксмо')
fetch next from Повыш_Цен_Издательства into @id_book, @cost
	while @@FETCH_STATUS = 0
		begin
			if @cost < @avgcost
				begin
					update Издательство_Книги
					set Цена = Цена + Цена * 0.1
					where current of Повыш_Цен_Издательства
				end
			fetch next from Повыш_Цен_Издательства into @id_book, @cost
		end

close Повыш_Цен_Издательства
deallocate Повыш_Цен_Издательства
go

-- delete where current of
select * from Автор
insert into Автор values ('Парусов А.А.', '75997654545', 'email')

declare Удаление_Неизд_Авторов cursor for 
select id_автора from Автор

open Удаление_Неизд_Авторов
declare @id_autor int
fetch next from Удаление_Неизд_Авторов into @id_autor
while @@FETCH_STATUS = 0
	begin
		if @id_autor not in (select distinct id_автора from Автор_Книги, Издательство_Книги
														where Автор_Книги.id_книги = Издательство_Книги.id_книги)
			delete from Автор
			where current of Удаление_Неизд_Авторов
		fetch next from Удаление_Неизд_Авторов into @id_autor
	end

close Удаление_Неизд_Авторов
deallocate Удаление_Неизд_Авторов
go
