-- 02. Insert

INSERT INTO Models
	   (Manufacturer, Model, ProductionYear, Seats, Class, Consumption)
VALUES ('Chevrolet', 'Astro', '2005-07-27 ', 4, 'Economy', 12.60),
	   ('Toyota', 'Solara', '2009-10-15 ', 7, 'Family', 13.80),
	   ('Volvo', 'S40', '2010-10-12 ', 3, 'Average', 11.30),
	   ('Suzuki', 'Swift', '2000-02-03 ', 7, 'Economy', 16.20)


INSERT INTO Orders
	   (ClientId, TownId, VehicleId, CollectionDate, CollectionOfficeId, ReturnDate, ReturnOfficeId, Bill, TotalMileage)
VALUES (17,	2, 52, '08/08/2017', 30, '2017-09-04', 42, 2360, 7434),
	   (78, 17, 50,	'2017-04-22', 10, '2017-05-09', 12,	2326, 7326),
	   (27, 13, 28, '2017-04-25', 21, '2017-05-09', 34,	597, 1880)


-- 03. Update

UPDATE Models
   SET Class = 'Luxury'
 WHERE Consumption > 20


-- 04. Delete

DELETE FROM Orders
 WHERE ReturnDate IS NULL