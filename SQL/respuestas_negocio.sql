-- 1. Listar los usuarios que cumplen años hoy y que realizaron más de 1500 ventas en enero 2020

SELECT c.nombre, c.apellido, COUNT(o.id) AS ventas_realizadas
FROM Customer c
JOIN Item i ON c.id = i.seller_id
JOIN Order_Item oi ON i.id = oi.item_id
JOIN Orders o ON oi.order_id = o.id
WHERE MONTH(c.fecha_nacimiento) = MONTH(GETDATE()) 
	AND DAY(c.fecha_nacimiento) = DAY(GETDATE())
  AND YEAR(o.fecha_compra) = 2020
  AND MONTH(o.fecha_compra) = 1
GROUP BY c.nombre, c.apellido
HAVING COUNT(o.id) > 1499;

-- 2. Top 5 vendedores por mes en la categoría Celulares en 2020
WITH VentasPorMes AS (
    SELECT 
        CONCAT(YEAR(o.fecha_compra), '-', FORMAT(MONTH(o.fecha_compra), '00')) AS periodo,
        c.nombre, 
        c.apellido,
        COUNT(o.id) AS cantidad_ventas,
        SUM(oi.cantidad) AS productos_vendidos,
        SUM(oi.subtotal) AS monto_total,
        RANK() OVER (PARTITION BY YEAR(o.fecha_compra), MONTH(o.fecha_compra) ORDER BY SUM(oi.subtotal) DESC) AS ranking --
    FROM Orders o
    JOIN Order_Item oi ON o.id = oi.order_id
    JOIN Item i ON oi.item_id = i.id
    JOIN Category cat ON i.category_id = cat.id
    JOIN Customer c ON i.seller_id = c.id
    WHERE cat.nombre = 'Celulares'
      AND YEAR(o.fecha_compra) = 2020
    GROUP BY YEAR(o.fecha_compra), MONTH(o.fecha_compra), c.nombre, c.apellido
)
SELECT * FROM VentasPorMes WHERE ranking <= 5
ORDER BY periodo, ranking;


-- 3. Stored Procedure para poblar la tabla de historial de precios y estados de los ítems

CREATE PROCEDURE update_item_history AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Item_History')
    BEGIN
        CREATE TABLE Item_History (
            id INT PRIMARY KEY IDENTITY,
            item_id INT NOT NULL,
            fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
            precio DECIMAL(10,2),
            estado VARCHAR(50),
            FOREIGN KEY (item_id) REFERENCES Item(id)
        );
    END;
    
    INSERT INTO Item_History (item_id, fecha_registro, precio, estado)
    SELECT id, CURRENT_TIMESTAMP, precio, estado FROM Item;
END;


-- Para ejecutar el SP:
EXEC update_item_history;
