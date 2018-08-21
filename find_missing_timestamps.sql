# Gets the the first and last timestamp for this particular pair/exchange/period combo.
SET @min := (SELECT @min := MIN(`time`) FROM `komodoDB`.`minutely`); 
SET @max := (SELECT @max := MAX(`time`) FROM `komodoDB`.`minutely`); 

# Creates a new table populated by all potential timestamps between the min and max selected earlier.
DROP PROCEDURE IF EXISTS makeSequence;
DELIMITER //
CREATE PROCEDURE makeSequence()
BEGIN   
	DROP TABLE IF EXISTS `komodoDB`.`timestamps`;
	CREATE TEMPORARY TABLE `komodoDB`.`timestamps` (`time` INT NOT NULL);
        SET @i := @min;
	WHILE @i < @max DO
		INSERT INTO `komodoDB`.`timestamps` (`time`) VALUE (@i);
        SET @i := @i + 60;
	END WHILE;
	# Test value to ensure that there is a null value in the left table that the join procedure will return so I know it's working
	INSERT INTO `komodoDB`.`timestamps` (`time`) VALUE (1234);
END //
DELIMITER ;

CALL makeSequence();

SELECT * FROM `komodoDB`.`minutely` d 
RIGHT JOIN `komodoDB`.`timestamps` t 
ON d.`time` = t.`time` LIMIT 1000000;
