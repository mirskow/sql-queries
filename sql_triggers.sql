use ����������
go
select * from �����

--��������
-- �������� ������� ���� (after, instead of) ��� ������ �� �������� (insert, update, delete):

-- after insert
alter table ����� add ����������_�������� int
go

update �����
	set ����������_�������� = (select distinct count(*) 
								from ������������_����� 
								where �����.id_����� = ������������_�����.id_�����)
go

create trigger ������������_�����_insert
on ������������_�����
after insert
as
	update ����� 
	set ����������_�������� = ����������_�������� + 1 
	where id_����� = (select id_����� from inserted);
go

-- after update
alter table ����� add ���������� bit default 0
go

update �����
set ���������� = 0

select * from �����
go

create trigger ��������_��_����������
on ������������_�����
after update
as
	declare @proc real
	select @proc = (convert(real, (select �������_���� from inserted)) / convert(real, (select ����� from inserted))) * 100
	if @proc > 90 and (datediff(day, (select ����_���������� from inserted), (select ����_���������� from deleted)) < 30)
		begin
			update �����
			set ���������� = 1
			where id_����� = (select id_����� from inserted)
		end
go

select * from ������������_�����
select * from �����

update ������������_�����
set �������_���� = 9600
where id_������� = 38
go

-- after delete
create trigger delete_�����_check_����
on �����
after delete
as
	delete from ����
	where id_����� not in (select distinct id_����� from ����_�����)
go

select * from �����
select * from ����
select * from ����_�����

delete from �����
where id_����� = 24

insert into ����� values ('������', 0, 0)
insert into ����_����� values 
((select id_����� from ���� where ����.������������ = '������'),
(select id_����� from ����� where �����.�������� = '������'))
go
drop trigger delete_�����_check_����

-- instead of insert
create trigger ��������_�����
on ����_�����
instead of insert
as
	if exists(select ����.id_����� from ����, inserted where ����.id_����� = inserted.id_�����)
		insert into ����_�����(id_�����, id_�����) select id_�����, id_����� from inserted
	else
		print('������ ���� ����������� � ���� ������.')
go

insert into ����_�����(id_�����, id_�����) values (50, 7)

-- instead of update
create table ������_���������_����������(
	id int identity primary key,
	nameRed varchar(50),
	prevPubl varchar(50)
)
go

create trigger ���_���������
on ������������
instead of update
as
	if not exists(select * from ������������, deleted where ������������.������������ = deleted.������������)
		begin
			print('������ ������������ ����������� � ���� ������')
		end
	else
		begin
			if ((select ������������.���_��������� from ������������, inserted where ������������.id_������������ = inserted.id_������������) != 
				(select inserted.���_��������� from inserted))
				begin
					insert into ������_���������_���������� (nameRed, prevPubl) values 
					((select ������������.���_��������� from ������������, inserted where ������������.id_������������ = inserted.id_������������),
					(select inserted.������������ from inserted))
					update ������������
						set ���_��������� = (select inserted.���_��������� from inserted)
						where id_������������ = (select inserted.id_������������ from inserted)
					print('������ ��������� ���������� ����������')
				end
		end
go
drop trigger ���_���������
update ������������
set ���_��������� = '��������� �.�.'
where ������������ = '���'

select * from ������������
select * from ������_���������_����������


-- instead of delete
create trigger ��������_�����������_��������_������
on �����
instead of delete
as
	if exists(select id_����� from �����_�����, deleted where �����_�����.id_������ = deleted.id_������)		
		print('����� �� ����� ���� ������ �� ����, ��� ��� � ���� ���� ����������')
	else
		delete from ����� where id_������ = (select id_������ from deleted)
go

insert into ����� values ('�������� �.�.', +75943958430, 'ARTEM@yandex.ru')

delete from �����
where id_������ = 11

SELECT *  FROM �����

-- �������, ����������� ���������� ��� ������������ ���������� ��� ������� ������� ��������� � ��:
create table History_�������(
	id_record int identity primary key,
	time_record datetime default GETDATE(),
	type_record varchar(50),
	book varchar(50),
	publisher varchar(50),
	date_publisher date,
)
go

create trigger ����������
on ������������_�����
after insert, update, delete
as
	declare @ci int, @cd int, @type varchar(50), @descr varchar(200)
	select @ci = (select count(*) from inserted)
	select @cd = (select count(*) from deleted)
	if @ci = 1 and @cd = 1 return -- ���������� ��������� > 1 ������
	if @ci = 0 and @cd = 1
		begin
			insert into History_�������(type_record, book, publisher, date_publisher) values 
			('��������', 
			(select �������� from �����, deleted where �����.id_����� = deleted.id_�����),
			(select ������������ from ������������, deleted where ������������.id_������������ = deleted.id_������������),
			(select ����_���������� from deleted))
		end
	if @ci = 1 and @cd = 0
		begin
			insert into History_�������(type_record, book, publisher, date_publisher) values 
			('����������', 
			(select �������� from �����, inserted where �����.id_����� = inserted.id_�����),
			(select ������������ from ������������, inserted where ������������.id_������������ = inserted.id_������������),
			(select ����_���������� from inserted))
		end
	if @ci = 1 and @cd = 1
		begin
			insert into History_�������(type_record, book, publisher, date_publisher) values 
			('����������',
			(select �������� from �����, inserted where �����.id_����� = inserted.id_�����),
			(select ������������ from ������������, inserted where ������������.id_������������ = inserted.id_������������),
			(select ����_���������� from inserted))
		end
go

update ������������_�����
set �������_���� = 5000
where �������_���� = 0


select * from ������������_�����
select * from History_�������