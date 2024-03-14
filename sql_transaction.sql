-- ���������� � ����������. 1 �����.
use ����������
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

-- ������� ������
begin transaction
update ������������_�����
set ���� = ���� - 5000
where id_������� = 1

waitfor delay '00:00:10' 
rollback transaction

-- ������������� ������
begin transaction

select *
from ������������_�����
where id_������� = 7

waitfor delay '00:00:10' 

select *
from ������������_�����
where id_������� = 7

commit transaction
select @@version

-- ��������� ������
begin transaction

select * from ������������_����� where ���� < 102

waitfor delay '00:00:15' 

select * from ������������_����� where ���� < 102

commit transaction

-- ����� (�������� ����������)

begin transaction

update ������������_����� set ����� = ����� + 10000 where id_������� = 500

waitfor delay '00:00:10'

update ������������_����� set ����� = ����� + 10000 where id_������� = 1500

commit transaction
