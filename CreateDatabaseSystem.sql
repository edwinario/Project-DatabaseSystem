create database UniDlox
--drop database UniDlox
use UniDlox

create table MsStaff(
	StaffId char(5) primary key
		check(StaffId like 'SF[0-9][0-9][0-9]'),
	StaffName varchar(50) not null,
	StaffPhone varchar(12) not null,
	StaffAddress varchar(15)
		check(LEN(StaffAddress) between 10 and 15) not null,
	StaffAge int not null,
	StaffGender varchar(10)
		check(StaffGender in ('Male' ,'Female')) not null,
	StaffSalary int not null
)

create table MsCustomer(
	CustomerId char(5) primary key
		check(CustomerId like 'CU[0-9][0-9][0-9]'),
	CustomerName varchar(50) not null,
	CustomerPhone varchar(12) not null,
	CustomerAddress varchar(15)
		check(LEN(CustomerAddress) between 10 and 15) not null,
	CustomerGender varchar(10)
		check(CustomerGender in ('Male' ,'Female')) not null,
	CustomerEmail varchar(30)
		check(CustomerEmail like '%@gmail.com' or CustomerEmail like '%@yahoo.com') not null,
	CustomerDOB date not null
)

create table MsSupplier(
	SupplierId char(5) primary key
		check(SupplierId like 'SU[0-9][0-9][0-9]'),
	SupplierName varchar(50)
		check(LEN(SupplierName) > 6) not null,
	SupplierPhone varchar(12) not null,
	SupplierAddress varchar(15)
		check(LEN(SupplierAddress) between 10 and 15) not null
)

create table MsMaterial(
	MaterialId char(5) primary key
		check(MaterialId like 'MA[0-9][0-9][0-9]'),
	MaterialName varchar(50) not null,
	MaterialPrice int 
		check(MaterialPrice > 0) not null,
	MaterialQuantity int not null
)

create table MsCloth(
	ClothId char(5) primary key
		check(ClothId like 'CL[0-9][0-9][0-9]'),
	ClothName varchar(50) not null,
	ClothStock int
		check(ClothStock between 0 and 250) not null,
	ClothPrice int
		check(ClothPrice > 0) not null
)

create table MsPayment(
	PaymentTypeId char(5) primary key
		check(PaymentTypeId like 'PA[0-9][0-9][0-9]'),
	PaymentType varchar(30) not null
)

create table Sales(
	SalesId char (5) primary key
		check(SalesId like 'SA[0-9][0-9][0-9]'),
	StaffId char(5) foreign key
		references MsStaff(StaffId)
		on update cascade
		on delete cascade not null,
	CustomerId char(5) foreign key
		references MsCustomer(CustomerId)
		on update cascade
		on delete cascade not null,
	SalesDate date not null,
)

create table SalesDetail(
	SalesId char (5) foreign key
		references Sales(SalesId)
		on update cascade
		on delete cascade not null,
	ClothId char(5) foreign key
		references MsCloth(ClothId)
		on update cascade
		on delete cascade not null,
	PaymentTypeId char (5) foreign key
		references MsPayment(PaymentTypeId)
		on update cascade
		on delete cascade not null,
	SalesQuantity int not null
	CONSTRAINT PK_SalesDetail PRIMARY KEY(SalesId,ClothId)
)

create table Purchase(
	PurchaseId char (5) primary key
		check(PurchaseId like 'PU[0-9][0-9][0-9]'),
	StaffId char(5) foreign key
		references MsStaff(StaffId)
		on update cascade
		on delete cascade not null,
	SupplierId char(5) foreign key
		references MsSupplier(SupplierId)
		on update cascade
		on delete cascade not null,
	PurchaseDate date not null
)

create table PurchaseDetail(
	PurchaseId char (5) foreign key
		references Purchase(PurchaseId)
		on update cascade
		on delete cascade not null,
	MaterialId char(5) foreign key
		references MsMaterial(MaterialId)
		on update cascade
		on delete cascade not null,
	PaymentTypeId char (5) foreign key
		references MsPayment(PaymentTypeId)
		on update cascade
		on delete cascade not null,
	PurchaseQuantity int not null
	CONSTRAINT PK_PurchaseDetail PRIMARY KEY(MaterialId,PurchaseId)
)