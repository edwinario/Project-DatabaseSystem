use UniDlox

-- contoh proses Sales Transaction antara customer dengan staff
-- jadi dimana saat customer membeli baju maka quantity pada tabel MsCloth akan berkurang 
begin tran
insert into Sales values
	('SA016','SF002','CU007','2021-10-20')

insert into SalesDetail values
	('SA016','CL001','PA005',13),
	('SA016','CL003','PA005',7)

update MsCloth
set ClothStock -= 13
where ClothId like 'CL001'

update MsCloth
set ClothStock -= 7
where ClothId like 'CL003'

select *
from Sales

select *
from SalesDetail

select *
from MsCloth
rollback

-- contoh proses Sales Transaction antara supplier dengan staff
-- jadi dimana saat staff membeli material dari supplier maka quantity pada tabel MsMaterial akan berkurang
begin tran
insert into Purchase values
	('PU016','SF010','SU003','2021-12-25')

insert into PurchaseDetail values
	('PU016','MA005','PA006',100),
	('PU016','MA007','PA006',30),
	('PU016','MA009','PA006',60)

update MsMaterial
set MaterialQuantity -= 100
where MaterialId like 'MA005'

update MsMaterial
set MaterialQuantity -= 30
where MaterialId like 'MA007'

update MsMaterial
set MaterialQuantity -= 60
where MaterialId like 'MA009'

select *
from Purchase

select * 
from PurchaseDetail

select *
from MsMaterial
rollback