/*	NOTE -- As of MySQL version 5.7, a view is subject to the following restriction:
		"Within a stored program, the SELECT statement cannot refer to program parameters or local variables."
        (https://dev.mysql.com/doc/refman/5.7/en/create-view.html) */
DROP PROCEDURE IF EXISTS `crypto-compare`.getClosingPriceByCurrencyAndToneDirection;

DELIMITER //
CREATE PROCEDURE `crypto-compare`.getClosingPriceByCurrencyAndToneDirection(IN inCurrencyName VARCHAR(10), 
									    IN inToneDirection VARCHAR(10), 
                                                                            OUT outCurrencyName VARCHAR(10), 
                                                                            OUT outToneDirection VARCHAR(10), 
                                                                            OUT outProportionSuccess DOUBLE) 
BEGIN 

    DROP VIEW IF EXISTS v;
    CREATE VIEW v AS 
	    SELECT cs.`currency_symbol` AS currency, 
	    cs.`published_on` AS published_on, 
            cs.`sentiment` AS sentiment, 
            cs.`score` AS score, 
            wt.`direction` AS direction, 
            dbd_pre.`close` AS closing_price_pre_pub, 
            dbd_post.`close` AS closing_price_post_pub,
            dbd_pre.`time` AS closing_time_pre_pub, 
            dbd_post.`time` AS closing_time_post_pub 
	    FROM `crypto-compare`.`currencies_sentiments` cs 
            JOIN `crypto-compare`.`watson_tones` wt 
	    ON cs.`sentiment` = wt.`tone` 
	    JOIN `crypto-compare`.`data_by_date` dbd_pre 
	    ON cs.`currency_symbol` = dbd_pre.`fromCurrency` 
	    JOIN `crypto-compare`.`data_by_date` dbd_post 
            ON cs.`currency_symbol` = dbd_post.`fromCurrency` 
            WHERE dbd_pre.`toCurrency` = 'USD' 
            AND dbd_post.`toCurrency` = 'USD' 
            AND (
		dbd_pre.`time` >= (cs.`published_on` - 86400) 
                AND dbd_pre.`time` < cs.`published_on`
            ) 
	    AND (
		dbd_post.`time` >= cs.`published_on` 
                AND dbd_post.`time` < (cs.`published_on` + 86400)
	    );
                
	# If/else statement merely alters the comparison operator between the pre and post publication prices.
	IF inToneDirection = 'positive' THEN 
    
	    SELECT currency, direction, 
	        ((SELECT COUNT(*) FROM v 
		  WHERE currency = inCurrencyName 
		      AND direction = inToneDirection 
		      AND closing_price_post_pub > closing_price_pre_pub) 
		      / (SELECT COUNT(*) FROM v 
			 WHERE currency = inCurrencyName 
			 AND direction = inToneDirection)) AS proportion_success 
            INTO outCurrencyName, outToneDirection, outProportionSuccess 
	    FROM v 
	    WHERE currency = inCurrencyName AND direction = inToneDirection 
            LIMIT 1; 
        
        ELSEIF inToneDirection = 'negative' THEN 
    
	    SELECT currency, direction, watson_tones
		((SELECT COUNT(*) FROM v 
		 WHERE currency = inCurrencyName 
		     AND direction = inToneDirection 
		     AND closing_price_post_pub > closing_price_pre_pub) 
		     / (SELECT COUNT(*) FROM v 
			WHERE currency = inCurrencyName 
			AND direction = inToneDirection)) 
	    INTO outCurrencyName, outToneDirection, outProportionSuccess 
	    FROM v 
	    WHERE currency = inCurrencyName AND direction = inToneDirection 
            LIMIT 1; 
        
	END IF; 

END //
DELIMITER ;

CALL getClosingPriceByCurrencyAndToneDirection('ETH', 'positive', @outCurrencyName, @outToneDirection, @outProportionSuccess);
