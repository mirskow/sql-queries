use ����������
go

-- �������
-- 1. ����������� �� ��� �� ��� �, ������������ ������� (ISO Syntax)

-- ��, ������� ������� ������� ���� ������� ����� ���� �������� ������ �������������
create procedure �����_����_����_����_���
as
	begin
		create table #�����_���(
			���������_������������ varchar(50)
		)

		insert into #�����_���
		select ������������ from ������������

		declare @���� varchar(20)

		declare ����� cursor for
		select ������������ from ����

		open �����
		fetch next from ����� into @����

		while @@FETCH_STATUS = 0
			begin
				execute('alter table #�����_��� add ' + @���� + ' int')
				execute('update #�����_��� set ' + @���� + ' = 0')

				declare @cJ int, @Publ varchar(50)

				declare ������������� cursor for
				select count(����_�����.id_�����), ������������.������������ 
				from ������������_�����, ������������, ����_�����, ����
				where ������������_�����.id_������������ = ������������.id_������������ 
						and ������������_�����.id_����� = ����_�����.id_����� and
						����_�����.id_����� = ����.id_����� and ����.������������ = @����
				group by ������������.������������

				open �������������
				fetch next from ������������� into @cJ, @Publ

				while @@FETCH_STATUS = 0
					begin
						execute('update #�����_��� 
								set ' + @���� + ' = ' + @cJ + 
								' where ���������_������������ = ''' + @Publ + '''')								
						fetch next from ������������� into @cJ, @Publ
					end

				close �������������
				deallocate �������������

				fetch next from ����� into @����
			end

		close �����
		deallocate �����

		select * from #�����_���
	end
go

exec �����_����_����_����_���
go

drop procedure �����_����_����_����_���

-- 2. ������������������ �������� � ������ ����������� � ������������ ��������, � ����� �������� keyset
select * from ������������

-- ����������� ������
declare staticListPublisher cursor static for
select ������������ from ������������

open staticListPublisher

insert into ������������ values ('�����', '���, ���������� �������� 169', '���������� �.�.', 'email')

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


-- ������������ ������
declare dynamicListPublisher cursor dynamic for
select ������������ from ������������

open dynamicListPublisher

insert into ������������ values ('�����', '���, ���������� �������� 169', '���������� �.�.', 'email')

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

-- ������ keyset

create table �����Buf(
	id_������ int primary key,
	fio varchar(100) NOT NULL,
	tel varchar(50) NULL unique,
)
go

delete �����Buf
go

insert into �����Buf
select id_������, ���, ������� from �����
go

select * from �����Buf
go

---------------------------------------------------------------------

declare ������������� cursor keyset for
select id_������, fio, tel from �����Buf

open ������������� 

declare @fioA varchar(60), @telA varchar(20), @count int, @idA int

fetch next from ������������� into @idA, @fioA, @telA

select @count = 1

while @@FETCH_STATUS = 0
begin
	print cast(@idA as varchar) + ' ' + @fioA + ' ' + @telA

	if (@count = 2) begin
			update �����Buf
			set tel = '+1 111 111 11 11'
			where fio = '����� �.�.'
	end

	if (@count = 4)
		begin
			insert into �����Buf values (69, '������� �.�.', '+7 599 765 45 45')
		end

	if (@count = 5)
		begin
			delete from �����Buf
			where id_������ = 6
		end
	
	select @count = @count + 1

	fetch next from ������������� into @idA, @fioA, @telA
end

close �������������
deallocate �������������
go

-----------------------------------------------------------

select * from �����Buf
go

-- 3. ��������� ��������� update � delete � ��������� where current of <��� �������> ����������� ������� 
-- ��������� � �������� ������� ����������� �������

-- update where current of
declare �����_���_������������ cursor for
select id_�����, ���� 
from ������������_�����, ������������ 
where ������������_�����.id_������������ = ������������.id_������������ and ������������.������������ = '�����'

open �����_���_������������
declare @id_book int, @cost real, @avgcost real
select @avgcost = (select avg(����) from ������������_�����, ������������ where ������������_�����.id_������������ = ������������.id_������������ and ������������.������������ = '�����')
fetch next from �����_���_������������ into @id_book, @cost
	while @@FETCH_STATUS = 0
		begin
			if @cost < @avgcost
				begin
					update ������������_�����
					set ���� = ���� + ���� * 0.1
					where current of �����_���_������������
				end
			fetch next from �����_���_������������ into @id_book, @cost
		end

close �����_���_������������
deallocate �����_���_������������
go

-- delete where current of
select * from �����
insert into ����� values ('������� �.�.', '75997654545', 'email')

declare ��������_�����_������� cursor for 
select id_������ from �����

open ��������_�����_�������
declare @id_autor int
fetch next from ��������_�����_������� into @id_autor
while @@FETCH_STATUS = 0
	begin
		if @id_autor not in (select distinct id_������ from �����_�����, ������������_�����
														where �����_�����.id_����� = ������������_�����.id_�����)
			delete from �����
			where current of ��������_�����_�������
		fetch next from ��������_�����_������� into @id_autor
	end

close ��������_�����_�������
deallocate ��������_�����_�������
go
