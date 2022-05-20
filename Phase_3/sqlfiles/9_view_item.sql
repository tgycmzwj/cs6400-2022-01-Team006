-- queries for viewing items

-- define some test cases
SET @UserID='user5@gmail.com';
SET @ItemID=11;

-- view items
SELECT itemID, CASE
WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
ELSE 'Error Type'
END AS Game_Type, title, game_condition, description, first_name, last_name,
cal_dist(postalCode, (SELECT postalCode FROM User WHERE email=@UserID)) AS Distance,
(SELECT AVG(rate)
FROM(
    SELECT proposerEmail as Email, counterparty_rate AS rate
    FROM gameswapDB.SwapRecord
        NATURAL JOIN(
            SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	        FROM gameswapDB.Item
        ) AS M1
    WHERE M1.proposerEmail=(SELECT ownerEmail FROM Item WHERE itemID=@ItemID)

    UNION

    -- when I am the counterparty of the swap, select the proposer_rate
	SELECT counterpartyEmail AS Email, proposer_rate AS rate
    FROM gameswapDB.SwapRecord
        NATURAL JOIN(
            SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	        FROM gameswapDB.Item
        ) AS M2
    WHERE M2.counterpartyEmail=(SELECT ownerEmail FROM Item WHERE itemID=@ItemID)
) AS M) AS Rating
FROM Item
NATURAL JOIN
(SELECT first_name, last_name, email AS ownerEmail, postalCode FROM User) AS U
WHERE Item.itemID=@ItemID;



-- show the number of unaccepted swaps
SELECT COUNT(*)
FROM gameswapDB.SwapRecord NATURAL JOIN (
    SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
    FROM gameswapDB.Item
) AS M
WHERE M.counterpartyEmail=@UserID AND SwapRecord.status IS NULL;


-- show the number of unrated swaps
SELECT COUNT(*)
FROM gameswapDB.SwapRecord NATURAL JOIN (
	SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	FROM gameswapDB.Item
)AS M1 NATURAL JOIN (
	SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	FROM gameswapDB.Item
)AS M2
WHERE ((proposerEmail=@UserID AND proposer_rate IS NULL) OR (counterpartyEmail=@UserID AND counterparty_rate IS NULL)) AND (status=1)
