SET NAMES utf8mb4;
USE `test_schemas`;

CREATE TABLE `CURS` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `CURS_DATE` DATE NOT NULL COMMENT 'Дата',
  `CURR_CODE` VARCHAR(3) NOT NULL COMMENT 'Код валюты',
  `RATE` DECIMAL(38,8) NOT NULL COMMENT 'Курс за 1',
  PRIMARY KEY (`ID`))
COMMENT = 'Курсы валют';

ALTER TABLE `CURS`
ADD UNIQUE INDEX `UK_CURS` (`CURS_DATE` ASC, `CURR_CODE` ASC) VISIBLE;

CREATE OR REPLACE VIEW `CURS_AVG_YEAR` AS
  SELECT SUBSTR(k.CURS_DATE, 1, 4) as PART_DATE,
         k.CURR_CODE,
         AVG(k.RATE) as AVG_RATE
    FROM CURS k
GROUP BY SUBSTR(k.CURS_DATE, 1, 4), k.CURR_CODE;

CREATE  OR REPLACE VIEW `CURS_REPORT` AS
WITH CURS_AVG (PART_DATE, CURR_CODE, AVG_RATE) AS
                (
                SELECT f.PART_DATE as PART_DATE,
					   f.CURR_CODE as CURR_CODE,
					   AVG(f.AVG_RATE) as AVG_RATE
				FROM (SELECT SUBSTR(k.CURS_DATE, 6, 5) as PART_DATE,
							 k.CURR_CODE,
							 (k.RATE/a.AVG_RATE)*100 as AVG_RATE
					  FROM CURS k
					  INNER JOIN CURS_AVG_YEAR a ON a.PART_DATE = SUBSTR(k.CURS_DATE, 1, 4) AND a.CURR_CODE = k.CURR_CODE
                      ) f
				GROUP BY f.PART_DATE, f.CURR_CODE
               )
 SELECT k.CURS_DATE,
		k.CURR_CODE,
		k.RATE,
		a.AVG_RATE as AVG_RATE
FROM CURS k
INNER JOIN CURS_AVG a ON a.PART_DATE = SUBSTR(k.CURS_DATE, 6, 5) AND a.CURR_CODE = k.CURR_CODE
WHERE SUBSTR(k.CURS_DATE, 1, 4) IN (SELECT SUBSTR(MAX(date(kk.CURS_DATE)),1,4) FROM CURS kk) AND a.AVG_RATE <= 100
ORDER BY 1;

DROP procedure IF EXISTS `INSERT_CURS`;

DELIMITER $$
USE `test_schemas`$$
CREATE PROCEDURE `INSERT_CURS` (p_curs_date datetime, p_curr_code varchar(3), p_rate decimal(38,8))
BEGIN
   INSERT INTO CURS (CURS_DATE, CURR_CODE, RATE)
       SELECT p_curs_date, p_curr_code, p_rate
       FROM DUAL
       WHERE NOT EXISTS (SELECT 1 FROM CURS c where c.curs_date = p_curs_date and c.curr_code = p_curr_code);
END$$

DELIMITER ;