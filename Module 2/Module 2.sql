-- Virtual Table
Select * from OrdersView;

-- JOIN Query
Select `customers`.CustomerID, `customers`.Name, `menu`.name, `menuitems`.CourseName, `menuitems`.SaladName
FROM 
`customers` inner join `order` on `customers`.CustomerID = `order`.CustomerID
inner join `menu` on `order`.MenuID = `menu`.MenuID 
inner join `menuitems` on `menu`.MenuItemID = `menuitems`.MenuItemID
Where `order`.TotalCost > 150;

-- ANY Clause
Select `menu`.Name from `menu` Where `menu`.MenuID = ANY (Select `order`.menuid from `order` where `order`.Quantity > 2); 

-- Stored Procedure
Create Procedure GetMaxQuantity()
Select MAX(`order`.Quantity) as `Max Quantity in Order` from `order`;

Call GetMaxQuantity();

-- Prepared Statement
Prepare GetOrderDetail FROM 'SELECT `order`.OrderID, `order`.Quantity, `order`.TotalCost from `order` where `order`.CustomerID = ?;';
SET @id = 2;
EXECUTE GetOrderDetail USING @id;

-- Stored Prcedure - CancelOrder 
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

CALL CancelOrder(3);
