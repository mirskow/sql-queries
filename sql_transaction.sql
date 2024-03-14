-- БЛОКИРОВКИ И ТРАНЗАКЦИИ. 1 сеанс.
use Типография
go

-- read uncommitted
set transaction isolation level read uncommitted
go
-- read committed
set transaction isolation level read committed
go
-- repeatable read
set transaction isolation level repeatable read
go
-- serializable
set transaction isolation level serializable
go

dbcc useroptions

-- грязное чтение
begin transaction
update Издательство_Книги
set Цена = Цена - 5000
where id_выпуска = 1

waitfor delay '00:00:10' 
rollback transaction

-- неповторяемое чтение
begin transaction

select *
from Издательство_Книги
where id_выпуска = 7

waitfor delay '00:00:10' 

select *
from Издательство_Книги
where id_выпуска = 7

commit transaction
select @@version

-- фантомные строки
begin transaction

select * from Издательство_Книги where Цена < 102

waitfor delay '00:00:15' 

select * from Издательство_Книги where Цена < 102

commit transaction

-- тупик (взаимная блокировка)

begin transaction

update Издательство_Книги set Тираж = Тираж + 10000 where id_выпуска = 500

waitfor delay '00:00:10'

update Издательство_Книги set Тираж = Тираж + 10000 where id_выпуска = 1500

commit transaction
