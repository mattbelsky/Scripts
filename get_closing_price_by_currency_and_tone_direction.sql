/*	NOTE -- As of MySQL version 5.7, a view is subject to the following restriction:
		"Within a stored program, the SELECT statement cannot refer to program parameters or local variables."
        (https://dev.mysql.com/doc/refman/5.7/en/create-view.html) */
DROP PROCEDURE IF EXISTS getClosingPriceByCurrencyAndToneDirection;

DELIMITER //
CREATE PROCEDURE getClosingPriceByCurrencyAndToneDirection() 
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
		WHERE cs.`currency_symbol` = 'BTC' 
			AND wt.`direction` = 'negative' 
            AND dbd_pre.`toCurrency` = 'USD' 
            AND dbd_post.`toCurrency` = 'USD' 
            AND (
				dbd_pre.`time` >= (cs.`published_on` - 86400) 
                AND dbd_pre.`time` < cs.`published_on`
                ) 
			AND (
				dbd_post.`time` >= cs.`published_on` 
                AND dbd_post.`time` < (cs.`published_on` + 86400)
                );
	SELECT currency, direction, (SELECT COUNT(*) FROM v WHERE closing_price_post_pub < closing_price_pre_pub) / COUNT(*) AS proportion_success 
    FROM v;
END //
DELIMITER ;

CALL getClosingPriceByCurrencyAndToneDirection();