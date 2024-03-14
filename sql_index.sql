use Типография
go

CREATE INDEX name_publ ON dbo.Издательство(Наименование)
GO

CREATE INDEX date_publ ON dbo.Издательство_Книги(Дата_публикации)
GO
CREATE INDEX id_publ ON dbo.Издательство_Книги(id_издательства)
GO
CREATE INDEX id_book ON Издательство_Книги (id_книги);
GO

CREATE INDEX name_gen ON dbo.Жанр(Наименование)
GO

CREATE INDEX id_book ON dbo.Жанр_Книги(id_книги)
Go
CREATE INDEX id_gen ON dbo.Жанр_Книги(id_жанра)
Go

CREATE INDEX aut ON dbo.Автор_Книги(id_автора)
GO
CREATE INDEX book ON dbo.Автор_Книги(id_книги)
GO