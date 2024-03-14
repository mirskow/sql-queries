use Типография
go
-- СОЗДАНИЕ ХП в БД, которые реализуют:
create procedure sp_example
	@genre varchar(50),
	@count int output
as
begin
	select @count=count(Книга.id_книги)
	from Книга, Жанр, Жанр_Книги
	where Книга.id_книги = Жанр_Книги.id_книги and Жанр_Книги.id_жанра = Жанр.id_жанра and Жанр.Наименование = @genre
end
go


create procedure sr_example_two
	@max_cost int out,
	@min_cost int out,
	@publisher varchar(50)
as
begin
	select @max_cost = max(Издательство_Книги.Цена), @min_cost = min(Издательство_Книги.Цена)
	from Издательство_Книги, Издательство
	where Издательство_Книги.id_издательства = Издательство.id_издательства and Издательство.Наименование = @publisher 
end
go

-- вставку с пополнением справочников;
create procedure insertIntoИздательствоКниги
	@NamePublisher varchar(50),
	@NameBook varchar(50),
	@NameAutor varchar(50),
	@Date date,
	@countPage int,
	@circulation int,
	@cost int,
	@saleBook int = 0
as
	declare @idBook int
	select @idBook = (select Книга.id_книги from Книга, Автор_Книги, Автор where Книга.Название = @NameBook and
															Книга.id_книги = Автор_Книги.id_книги and
															Автор_Книги.id_автора = Автор.id_автора and
															Автор.ФИО = @NameAutor)

	if @NamePublisher not in (select Издательство.Наименование from Издательство where Издательство.Наименование = @NamePublisher)
		insert into Издательство values (@NamePublisher, 'adress', 'redactor', 'email')
	insert into Издательство_Книги values
	((select id_издательства from Издательство where Издательство.Наименование = @NamePublisher),
	@idBook,
	@Date,
	@countPage,
	@circulation,
	@saleBook,
	@cost)
go

execute insertIntoИздательствоКниги 'Питер', 'Преступление и наказание', 'Достоевский Ф.М.', '2023-09-09', 50, 10000, 5000
go
select * from Издательство_Книги
select * from Издательство


-- удаление с очисткой справочников + каскадное удаление;
create procedure deleteBook
	@NameBook varchar(50),
	@NameAutor varchar(50)
as
	declare @idBook int 
	select @idBook = (select Книга.id_книги from Книга, Автор_Книги, Автор where Книга.Название = @NameBook and
															Книга.id_книги = Автор_Книги.id_книги and
															Автор_Книги.id_автора = Автор.id_автора and
															Автор.ФИО = @NameAutor)

	create table #Авторы_Данной_Книги(
		id int identity,
		id_автора int
	)
	insert into #Авторы_Данной_книги
		select Автор_Книги.id_автора
		from Автор_Книги
		where Автор_Книги.id_книги = @idBook

	delete from Книга where Книга.id_книги = @idBook
	--также происходит каскадное удаление записей с этой книгой из таблицы Автор_Книги

	declare @n int
	select @n = (select count(*) from #Авторы_Данной_Книги)
	
	checkAutor:
		declare @idAutor int
		select @idAutor = (select #Авторы_Данной_Книги.id_автора from #Авторы_Данной_Книги where #Авторы_Данной_Книги.id = @n)		
		if not exists (select Автор_Книги.id_автора from Автор_Книги where Автор_Книги.id_автора = @idAutor)
			delete from Автор where Автор.id_автора = @idAutor
		select @n = @n - 1
		if @n = 0			
			return
		else
			goto checkAutor
go

execute deleteBook 'Двенадцать стульев', 'Илья Ильиф'
go

select * from Книга
select * from Автор_Книги
select * from Автор

-- вычисление и возврат значения агрегатной функции (на примере одного из запросов из задания);
create procedure Средн_Тираж_Издательства 
	@NamePublisher varchar(20),
	@Circulation int = 0 out
as
	select @Circulation = avg(Издательство_Книги.Тираж) 
	from Издательство_Книги, Издательство
	where Издательство.Наименование = @NamePublisher and 
			Издательство.id_издательства = Издательство_Книги.id_издательства
go

declare @avg int
execute Средн_Тираж_Издательства 'ЛитРес', @avg out
select @avg
go

-- табличные функции для подсчета некоторых статистик по каждому издательству:
--функция возвращает таблицу с количеством выпущенных книг для каждого издательства
create function Кол_во_Выпущенных_Книг() returns table
as
	return(
		select Издательство.id_издательства, count(distinct Книга.id_книги) as Кол_во_Книг
		from Книга, Издательство_Книги, Издательство
		where Книга.id_книги = Издательство_Книги.id_книги and Издательство_Книги.id_издательства = Издательство.id_издательства
		group by Издательство.id_издательства
	)
go

--функция возвращает таблицу с количеством печатающихся авторов для каждого издательства
create function Кол_во_печ_авторов() returns table
as
	return(
		select Издательство.id_издательства, count(distinct Автор.id_автора) as Авторов
		from Издательство, Издательство_Книги, Автор_Книги, Автор
		where Издательство.id_издательства = Издательство_Книги.id_издательства and 
				Издательство_Книги.id_книги = Автор_Книги.id_книги and
				Автор_Книги.id_автора = Автор.id_автора
		group by Издательство.id_издательства
	)
go

-- формирование статистики во временной таблице:
create procedure TipographyState	
as
	begin
		create table #Статистика_Издательства(
			id_Издательства int,
			Издательство varchar(50),
			Количество_выпущенных_книг int,
			Количество_печатающихся_авторов int,
			Средний_тираж int,
			Средний_объем_продаж int
		)
		insert into #Статистика_Издательства
			select Издательство.id_издательства,
					Издательство.Наименование,
					b.Кол_во_Книг,
					a.Авторов,
					avg(Издательство_Книги.Тираж),
					avg(Издательство_Книги.Продано_книг)
			from Издательство
			left join Кол_во_Выпущенных_Книг() as b on Издательство.id_издательства = b.id_издательства
			left join Кол_во_печ_авторов() as a on Издательство.id_издательства = a.id_издательства
			join Издательство_Книги on Издательство.id_издательства = Издательство_Книги.id_издательства
			group by Издательство.id_издательства,
					Издательство.Наименование,
					b.Кол_во_Книг,
					a.Авторов
		
		select * from #Статистика_Издательства
	end
go

execute TipographyState
go

-- реализовать ПЗ или ХП, демонстрирующие использование управляющих операторов
-- пример ПЗ для цикла while
alter table Издательство_Книги add Цена smallmoney
go

update Издательство_Книги
	set Цена = Тираж / 10
go

while (select avg(Издательство_Книги.Цена) from Издательство_Книги) < 5000
	update Издательство_Книги
		set Цена = Цена + Цена * 0.2	
go

select * from Издательство_Книги

--пример для оператора выбора case
select Книга.Название, 'Жанр' = 
	case Жанр_Книги.id_жанра 
		when 1 then 'Роман'
		when 2 then 'Повесть'
		else 'Не определен'
	end
from Книга, Жанр_Книги
where Книга.id_книги = Жанр_Книги.id_книги
order by Жанр
go

-- пример запроса, который использует скалярную функцию
-- запрос возвращает среднее количество страниц среди изданных книг
create function Ср_Цена_За_Книгу() returns real
begin
	declare @avg real
	select @avg = (select avg(Издательство_Книги.Цена) from Издательство_Книги)
	return(@avg)
end
go

select Книга.Название, Издательство_Книги.Цена
from Книга, Издательство_Книги
where Книга.id_книги = Издательство_Книги.id_книги
group by Книга.Название, Издательство_Книги.Цена
having Издательство_Книги.Цена < dbo.Ср_Цена_За_Книгу()
