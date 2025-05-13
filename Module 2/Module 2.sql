-- Virtual Table
Select * from OrdersView;

-- JOIN Query
Select `customers`.CustomerID, `customers`.Name, `menu`.name, `MenuItems`.CourseName, `MenuItems`.SaladName
FROM 
`customers` inner join `order` on `customers`.CustomerID = `order`.CustomerID
inner join `menu` on `order`.MenuID = `menu`.MenuID 
inner join `MenuItems` on `menu`.MenuItemID = `MenuItems`.MenuItemID
Where `order`.TotalCost > 150;

-- ANY Clause
Select `menu`.Name from `menu` Where `menu`.MenuID = ANY (Select `order`.MenuID from `order` where `order`.Quantity > 2);

-- Stored Procedure
Create Procedure GetMaxQuantity()
Select MAX(`order`.Quantity) as `Max Quantity in Order` from `order`;

Call GetMaxQuantity();

-- Prepared Statement
Prepare GetOrderDetail FROM 'SELECT `order`.OrderID, `order`.Quantity, `order`.TotalCost from `order` where `order`.CustomerID = ?;';
SET @id = 2;
EXECUTE GetOrderDetail USING @id;

-- Stored Procedure - CancelOrder
DELIMITER //
Create Procedure CancelOrder(orderId INT)
BEGIN
SELECT 
CASE
	WHEN orderId in (Select `order`.orderID from `order`) THEN CONCAT('Order ', orderId, ' is cancelled')
    ELSE "Order not available"
 END as `Confirmation`;
Delete from `order` where `order`.OrderID = orderID;
END//
DELIMITER ;

CALL CancelOrder(2);


-- INSERT Statements

INSERT into `bookings` (`customerId`, `tableNo`, `bookingDate`) Values 
(1, 5, '2022-10-10'), 
(3, 3, '2022-11-12'),
(2, 2, '2022-11-10'),
(1, 2, '2022-10-13');

Select * from `bookings`;

-- CheckBooking 
DELIMITER //
CREATE PROCEDURE CheckBooking(IN bookingDate DATE, IN tableNo INT)
BEGIN
    DECLARE tableStatus INT DEFAULT 0;
    SELECT COUNT(*) 
    INTO tableStatus 
    FROM `bookings` 
    WHERE `bookings`.tableNo = tableNo 
      AND `bookings`.bookingDate = bookingDate;
    SELECT 
        CASE 
            WHEN tableStatus > 0 THEN CONCAT('Table ', tableNo, ' is already booked')
            ELSE CONCAT('Table ', tableNo, ' is available')
        END AS `Booking Status`;
END//
DELIMITER ;

Call CheckBooking('2022-11-12', 3);

-- AddValidBooking
delimiter //
Create procedure AddValidBooking(bookingDate Date, tableNo int, custId int)
begin
	declare tablecount int default 0;
	start transaction;
    Insert into `bookings` (`bookings`.bookingDate, `bookings`.tableNo, `bookings`.customerId) Values (bookingDate, tableNo, custId);
    Select count(*) into tablecount from `bookings` where `bookings`.bookingDate = bookingDate and `bookings`.tableNo = tableNo;
    if tablecount > 1 then 
		Begin
			Select concat('Table ', tableNo, ' is already booked. Booking Cancelled') as `Booking Status`;
			rollback;
        END;
    else 
		Begin
			Select concat('Table ', tableNo, ' is available and booked') as `Booking Status`;
			commit;
        END;
	END if;
end//
delimiter ;

call AddValidBooking('2022-12-17', '5', 2);

-- AddBooking 
delimiter //
create procedure AddBooking(bookingId int, customerId int, bookingDate date, tableNo int)
begin
declare stat int default 0;
start transaction;
insert into `bookings` (`bookings`.bookingId, `bookings`.customerId, `bookings`.bookingDate, `bookings`.tableNo)
values (bookingId, customerId, bookingDate, tableNo);
select count(*) into stat from `bookings` where `bookings`.bookingId = bookingId;
if stat > 0 then 
		Begin
			Select "New booking added" as `Confirmation`;
			commit;
        END;
    else 
		Begin
			Select "Booking not added" as `Confirmation`;
			rollback;
        END;
	END if;
end//
delimiter ;

call AddBooking(7, 3, "2022-12-30", 4);

-- UpdateBooking
delimiter //
create procedure UpdateBooking(bookingId int, bookingDate date)
begin
declare stat int default 0;
start transaction;
update `bookings` set `bookings`.bookingDate = bookingDate where `bookings`.bookingId = bookingId;
select count(*) into stat from `bookings` where `bookings`.bookingId = bookingId and `bookings`.bookingDate = bookingDate;
if stat > 0 then 
		Begin
			Select concat("Booking ", bookingId, " updated") as `Confirmation`;
			commit;
        END;
    else 
		Begin
			Select "Booking not updated" as `Confirmation`;
			rollback;
        END;
	END if;
end//
delimiter ;

call UpdateBooking(7, "2022-11-03");

-- CancelBooking
delimiter //
create procedure CancelBooking(bookingId int)
begin
declare stat int default 0;
start transaction;
delete from `bookings` where `bookings`.bookingId = bookingId;
select count(*) into stat from `bookings` where `bookings`.bookingId = bookingId;
if stat = 0 then 
		Begin
			Select concat("Booking ", bookingId, " cancelled") as `Confirmation`;
			commit;
        END;
    else 
		Begin
			Select "Booking not cancelled" as `Confirmation`;
			rollback;
        END;
	END if;
end//
delimiter ;

call CancelBooking(7);