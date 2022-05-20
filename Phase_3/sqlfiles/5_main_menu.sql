-- queries used for main menu
USE gameswapDB;

-- define some test cases
SET @UserID='user5@gmail.com';


-- show welcome information
SELECT first_name,last_name
FROM gameswapDB.User
WHERE User.email=@UserID;


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
WHERE ((proposerEmail=@UserID AND proposer_rate IS NULL) OR (counterpartyEmail=@UserID AND counterparty_rate IS NULL)) AND (status=1);


-- show my rating
SELECT AVG(rate)
FROM(
    -- when I am the proposer of the swap, select the counterparty_rate
    SELECT counterparty_rate AS rate
    FROM gameswapDB.SwapRecord
        NATURAL JOIN(
            SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	        FROM gameswapDB.Item
        ) AS M1
    WHERE M1.proposerEmail=@UserID

    UNION

    -- when I am the counterparty of the swap, select the proposer_rate
	SELECT proposer_rate AS rate
    FROM gameswapDB.SwapRecord
        NATURAL JOIN(
            SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	        FROM gameswapDB.Item
        ) AS M2
    WHERE M2.counterpartyEmail=@UserID
) AS M;
