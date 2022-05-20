SELECT COUNT(*) 
FROM SwapRecord
WHERE status IS NULL;

SELECT curdate();

SELECT COUNT(*)
FROM gameswapDB.SwapRecord NATURAL JOIN (
     SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
     FROM gameswapDB.Item
     ) AS M
WHERE M.counterpartyEmail="user1@gmail.com" AND SwapRecord.status IS NULL AND DATEDIFF(CURDATE(),SwapRecord.propose_date)>200;


select DATEDIFF('2011/08/15', '2011/08/25');


SELECT COUNT(*) FROM gameswapDB.Item WHERE ownerEmail='user1@gmail.com' AND itemID=5;

SELECT COUNT(*) FROM
(SELECT proposedItemID AS ItemID FROM SwapRecord WHERE status!=0 
UNION
SELECT desiredItemID AS ItemID FROM SwapRecord WHERE status!=0) AS M
WHERE M.ItemID=100;


WITH M1 AS (SELECT itemID AS proposedItemID, ownerEmail AS proposerEmail FROM Item),
     M2 AS (SELECT itemID AS desiredItemID, ownerEmail as counterpartyEmail FROM Item)
SELECT * 
FROM SwapRecord LEFT JOIN M1 ON SwapRecord.proposedItemID=M1.proposedItemID LEFT JOIN M2 ON SwapRecord.desiredItemID=M2.desiredItemID
WHERE (proposerEmail='user2@gmail.com' OR counterpartyEmail='user2@gmail.com') AND recordID=11;





SELECT AVG(rate) FROM(
                           -- when I am the proposer of the swap, select the counterparty_rate
                           SELECT counterparty_rate AS rate
                           FROM gameswapDB.SwapRecord ATURAL JOIN(
                               SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	                           FROM gameswapDB.Item
                           ) AS M1
                           WHERE M1.proposerEmail="user11@gmail.com"
                           UNION
                           -- when I am the counterparty of the swap, select the proposer_rate
	                       SELECT proposer_rate AS rate
                           FROM gameswapDB.SwapRecord
                           NATURAL JOIN(
                               SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	                           FROM gameswapDB.Item
                           ) AS M2
                           WHERE M2.counterpartyEmail="user11@gmail.com") AS M;
                           
                           
                           SELECT *
                           FROM gameswapDB.SwapRecord
                           NATURAL JOIN(
                               SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	                           FROM gameswapDB.Item
                           ) AS M2
                           WHERE M2.counterpartyEmail="user11@gmail.com";
                           
                           SELECT counterparty_rate AS rate
                           FROM gameswapDB.SwapRecord NATURAL JOIN(
                               SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	                           FROM gameswapDB.Item
                           ) AS M1
                           WHERE M1.proposerEmail="user11@gmail.com";
                           
                           
                           SELECT COUNT(*) FROM
(SELECT proposedItemID AS ItemID FROM SwapRecord WHERE status!=0 
UNION
SELECT desiredItemID AS ItemID FROM SwapRecord WHERE status!=0) AS M
WHERE M.ItemID=139;

SELECT COUNT(*) FROM gameswapDB.Item WHERE ownerEmail="user1@gmail.com" AND itemID=139;


SHOW FUNCTION STATUS;

SELECT cal_dist('60201','10010');

SELECT COUNT(*) FROM
(SELECT proposedItemID AS ItemID FROM SwapRecord WHERE status 
UNION
SELECT desiredItemID AS ItemID FROM SwapRecord WHERE status!=0) AS M
WHERE M.ItemID=139;   






SELECT AVG(rate) FROM(
                           -- when I am the proposer of the swap, select the counterparty_rate
                           SELECT counterparty_rate AS rate
                           FROM gameswapDB.SwapRecord NATURAL JOIN(
                               SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	                           FROM gameswapDB.Item
                           ) AS M1
                           WHERE M1.proposerEmail="usr005@gt.edu"
                           UNION ALL
                           -- when I am the counterparty of the swap, select the proposer_rate
	                       SELECT proposer_rate AS rate
                           FROM gameswapDB.SwapRecord
                           NATURAL JOIN(
                               SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	                           FROM gameswapDB.Item
                           ) AS M2
                           WHERE M2.counterpartyEmail="usr005@gt.edu") AS M; 
                           

USE gameswapdb;
SELECT *
FROM Item
WHERE ownerEmail = "usr007@gt.edu" AND
		(itemID NOT IN (SELECT proposedItemID
                        FROM SwapRecord
                        WHERE status = 1 or status IS NULL)) AND
		(itemID NOT IN (SELECT desiredItemID
                    FROM SwapRecord
                    WHERE status = 1 or status IS NULL ORDER BY desiredItemID));
                    
                    
                    
SELECT itemID, CASE
WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
ELSE 'Error Type'
END AS Game_Type
, title, game_condition
FROM Item
WHERE ownerEmail = "usr998@gt.edu" AND
		(itemID NOT IN (SELECT proposedItemID
                        FROM SwapRecord
                        WHERE status = 1 or status IS NULL)) AND
		(itemID NOT IN (SELECT desiredItemID
                    FROM SwapRecord
                    WHERE status = 1 or status IS NULL)) AND 
        (SELECT COUNT(*) FROM SwapRecord WHERE desiredItemID= AND proposedItemID=5364)=0;
    