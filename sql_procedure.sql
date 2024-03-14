use ����������
go
-- �������� �� � ��, ������� ���������:
create procedure sp_example
	@genre varchar(50),
	@count int output
as
begin
	select @count=count(�����.id_�����)
	from �����, ����, ����_�����
	where �����.id_����� = ����_�����.id_����� and ����_�����.id_����� = ����.id_����� and ����.������������ = @genre
end
go


create procedure sr_example_two
	@max_cost int out,
	@min_cost int out,
	@publisher varchar(50)
as
begin
	select @max_cost = max(������������_�����.����), @min_cost = min(������������_�����.����)
	from ������������_�����, ������������
	where ������������_�����.id_������������ = ������������.id_������������ and ������������.������������ = @publisher 
end
go

-- ������� � ����������� ������������;
create procedure insertInto�����������������
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
	select @idBook = (select �����.id_����� from �����, �����_�����, ����� where �����.�������� = @NameBook and
															�����.id_����� = �����_�����.id_����� and
															�����_�����.id_������ = �����.id_������ and
															�����.��� = @NameAutor)

	if @NamePublisher not in (select ������������.������������ from ������������ where ������������.������������ = @NamePublisher)
		insert into ������������ values (@NamePublisher, 'adress', 'redactor', 'email')
	insert into ������������_����� values
	((select id_������������ from ������������ where ������������.������������ = @NamePublisher),
	@idBook,
	@Date,
	@countPage,
	@circulation,
	@saleBook,
	@cost)
go

execute insertInto����������������� '�����', '������������ � ���������', '����������� �.�.', '2023-09-09', 50, 10000, 5000
go
select * from ������������_�����
select * from ������������


-- �������� � �������� ������������ + ��������� ��������;
create procedure deleteBook
	@NameBook varchar(50),
	@NameAutor varchar(50)
as
	declare @idBook int 
	select @idBook = (select �����.id_����� from �����, �����_�����, ����� where �����.�������� = @NameBook and
															�����.id_����� = �����_�����.id_����� and
															�����_�����.id_������ = �����.id_������ and
															�����.��� = @NameAutor)

	create table #������_������_�����(
		id int identity,
		id_������ int
	)
	insert into #������_������_�����
		select �����_�����.id_������
		from �����_�����
		where �����_�����.id_����� = @idBook

	delete from ����� where �����.id_����� = @idBook
	--����� ���������� ��������� �������� ������� � ���� ������ �� ������� �����_�����

	declare @n int
	select @n = (select count(*) from #������_������_�����)
	
	checkAutor:
		declare @idAutor int
		select @idAutor = (select #������_������_�����.id_������ from #������_������_����� where #������_������_�����.id = @n)		
		if not exists (select �����_�����.id_������ from �����_����� where �����_�����.id_������ = @idAutor)
			delete from ����� where �����.id_������ = @idAutor
		select @n = @n - 1
		if @n = 0			
			return
		else
			goto checkAutor
go

execute deleteBook '���������� �������', '���� �����'
go

select * from �����
select * from �����_�����
select * from �����

-- ���������� � ������� �������� ���������� ������� (�� ������� ������ �� �������� �� �������);
create procedure �����_�����_������������ 
	@NamePublisher varchar(20),
	@Circulation int = 0 out
as
	select @Circulation = avg(������������_�����.�����) 
	from ������������_�����, ������������
	where ������������.������������ = @NamePublisher and 
			������������.id_������������ = ������������_�����.id_������������
go

declare @avg int
execute �����_�����_������������ '������', @avg out
select @avg
go

-- ��������� ������� ��� �������� ��������� ��������� �� ������� ������������:
--������� ���������� ������� � ����������� ���������� ���� ��� ������� ������������
create function ���_��_����������_����() returns table
as
	return(
		select ������������.id_������������, count(distinct �����.id_�����) as ���_��_����
		from �����, ������������_�����, ������������
		where �����.id_����� = ������������_�����.id_����� and ������������_�����.id_������������ = ������������.id_������������
		group by ������������.id_������������
	)
go

--������� ���������� ������� � ����������� ������������ ������� ��� ������� ������������
create function ���_��_���_�������() returns table
as
	return(
		select ������������.id_������������, count(distinct �����.id_������) as �������
		from ������������, ������������_�����, �����_�����, �����
		where ������������.id_������������ = ������������_�����.id_������������ and 
				������������_�����.id_����� = �����_�����.id_����� and
				�����_�����.id_������ = �����.id_������
		group by ������������.id_������������
	)
go

-- ������������ ���������� �� ��������� �������:
create procedure TipographyState	
as
	begin
		create table #����������_������������(
			id_������������ int,
			������������ varchar(50),
			����������_����������_���� int,
			����������_������������_������� int,
			�������_����� int,
			�������_�����_������ int
		)
		insert into #����������_������������
			select ������������.id_������������,
					������������.������������,
					b.���_��_����,
					a.�������,
					avg(������������_�����.�����),
					avg(������������_�����.�������_����)
			from ������������
			left join ���_��_����������_����() as b on ������������.id_������������ = b.id_������������
			left join ���_��_���_�������() as a on ������������.id_������������ = a.id_������������
			join ������������_����� on ������������.id_������������ = ������������_�����.id_������������
			group by ������������.id_������������,
					������������.������������,
					b.���_��_����,
					a.�������
		
		select * from #����������_������������
	end
go

execute TipographyState
go

-- ����������� �� ��� ��, ��������������� ������������� ����������� ����������
-- ������ �� ��� ����� while
alter table ������������_����� add ���� smallmoney
go

update ������������_�����
	set ���� = ����� / 10
go

while (select avg(������������_�����.����) from ������������_�����) < 5000
	update ������������_�����
		set ���� = ���� + ���� * 0.2	
go

select * from ������������_�����

--������ ��� ��������� ������ case
select �����.��������, '����' = 
	case ����_�����.id_����� 
		when 1 then '�����'
		when 2 then '�������'
		else '�� ���������'
	end
from �����, ����_�����
where �����.id_����� = ����_�����.id_�����
order by ����
go

-- ������ �������, ������� ���������� ��������� �������
-- ������ ���������� ������� ���������� ������� ����� �������� ����
create function ��_����_��_�����() returns real
begin
	declare @avg real
	select @avg = (select avg(������������_�����.����) from ������������_�����)
	return(@avg)
end
go

select �����.��������, ������������_�����.����
from �����, ������������_�����
where �����.id_����� = ������������_�����.id_�����
group by �����.��������, ������������_�����.����
having ������������_�����.���� < dbo.��_����_��_�����()
