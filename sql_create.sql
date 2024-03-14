--use master
--go
--create database ����������
--go
use ����������
go

create table ������������(
	id_������������ int identity primary key,
	������������ varchar(50) NOT NULL,
	����� varchar(100) NOT NULL,
	���_��������� varchar(100) NOT NULL,
)
go

create table �����(
	id_����� int identity primary key,
	�������� varchar(50) NOT NULL,
)
go

create table �����(
	id_������ int identity primary key,
	��� varchar(100) NOT NULL,
	������� varchar(12) NULL unique,
	Email varchar(50) NOT NULL unique,
)
go

create table ����(
	id_����� int identity primary key,
	������������ varchar(50) NOT NULL,
)
go

create table ����_�����(
	id_������ int identity primary key,
	id_����� int references ����(id_�����) on delete cascade on update cascade,
	id_����� int references �����(id_�����) on delete cascade on update cascade,
)
go

create table �����_�����(
	id_������ int identity primary key,
	id_������ int references �����(id_������) on delete cascade on update cascade,
	id_����� int references �����(id_�����) on delete cascade on update cascade,
)
go

create table ������������_�����(
	id_������� int identity primary key,
	id_������������ int references ������������(id_������������) on delete cascade on update cascade,
	id_����� int references �����(id_�����) on delete cascade on update cascade,
	����_���������� date NOT NULL,
	����� int NOT NULL check (����� > 0),
	����� int NOT NULL check (����� > 0),
	�������_���� int default 0
)
go




