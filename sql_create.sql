--use master
--go
--create database Типография
--go
use Типография
go

create table Издательство(
	id_издательства int identity primary key,
	Наименование varchar(50) NOT NULL,
	Адрес varchar(100) NOT NULL,
	ФИО_редактора varchar(100) NOT NULL,
)
go

create table Книга(
	id_книги int identity primary key,
	Название varchar(50) NOT NULL,
)
go

create table Автор(
	id_автора int identity primary key,
	ФИО varchar(100) NOT NULL,
	Телефон varchar(12) NULL unique,
	Email varchar(50) NOT NULL unique,
)
go

create table Жанр(
	id_жанра int identity primary key,
	Наименование varchar(50) NOT NULL,
)
go

create table Жанр_Книги(
	id_записи int identity primary key,
	id_жанра int references Жанр(id_жанра) on delete cascade on update cascade,
	id_книги int references Книга(id_книги) on delete cascade on update cascade,
)
go

create table Автор_Книги(
	id_записи int identity primary key,
	id_автора int references Автор(id_автора) on delete cascade on update cascade,
	id_книги int references Книга(id_книги) on delete cascade on update cascade,
)
go

create table Издательство_Книги(
	id_выпуска int identity primary key,
	id_издательства int references Издательство(id_издательства) on delete cascade on update cascade,
	id_книги int references Книга(id_книги) on delete cascade on update cascade,
	Дата_публикации date NOT NULL,
	Объем int NOT NULL check (Объем > 0),
	Тираж int NOT NULL check (Тираж > 0),
	Продано_книг int default 0
)
go




