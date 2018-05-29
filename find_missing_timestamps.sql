# Gets the the first and last timestamp for this particular pair/exchange/period combo.
SET @min := (SELECT @min := MIN(`time`) FROM `komodoDB`.`daily`); 
SET @max := (SELECT @max := MAX(`time`) FROM `komodoDB`.`daily`); 

DROP PROCEDURE IF EXISTS makeSequence;
DELIMITER //
CREATE PROCEDURE makeSequence()
BEGIN   
    # Creates a new table populated by all potential daily timestamps between the min and max selected earlier.
    DROP TABLE IF EXISTS `komodoDB`.`timestamps`;
	CREATE TEMPORARY TABLE `komodoDB`.`timestamps` (`time` INT NOT NULL);
    SET @i := @min;
	WHILE @i < @max DO
		INSERT INTO `komodoDB`.`timestamps` (`time`) VALUE (@i);
        SET @i := @i + 86400;
  END WHILE;
  INSERT INTO `komodoDB`.`timestamps` (`time`) VALUE (1234);
END //
DELIMITER ;

CALL makeSequence();

SELECT * FROM `komodoDB`.`daily` d 
RIGHT JOIN `komodoDB`.`timestamps` t 
ON d.`time` = t.`time`; 
