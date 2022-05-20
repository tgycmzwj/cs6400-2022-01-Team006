-- queries for rating a swap

-- define some test cases
SET @UserID="user5@gmail.com";
SET @Rating=4;
SET @RecordID=1;

-- obstain unrated swaps
WITH UserItem AS (
    SELECT email, postalCode, first_name, last_name, nick_name, itemID, title, description, game_condition
	  FROM User
    JOIN Item ON User.email = Item.ownerEmail),
MySwapRecord AS (SELECT recordID, PUserItem.email AS proposerEmail, CUserItem.email AS counterpartyEmail, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate, PUserItem.title AS Ptitle, CUserItem.title AS Ctitle, PUserItem.nick_name AS Pnick_name, CUserItem.nick_name as Cnick_name
    FROM SwapRecord
    JOIN UserItem AS PUserItem
    ON SwapRecord.proposedItemID = PUserItem.itemID
    JOIN UserItem AS CUserItem
    ON SwapRecord.desiredItemID = CUserItem.itemID
    WHERE   (PUserItem.email = @UserID OR CUserItem.email = @UserID) AND status IS NOT NULL)
SELECT decide_date AS "Accepted/Rejected Date",
    CASE WHEN MySwapRecord.proposerEmail = @UserID THEN "Proposer"
         WHEN MySwapRecord.counterpartyEmail = @UserID THEN "Counterparty"
    END AS "My Role",
    Ptitle AS "Proposed Item", Ctitle AS "Desired Item",
    CASE WHEN MySwapRecord.proposerEmail != @UserID THEN Pnick_name
         WHEN MySwapRecord.counterpartyEmail != @UserID THEN Cnick_name
    END AS "Other User",
	  CASE WHEN MySwapRecord.proposerEmail = @UserID AND MySwapRecord.proposer_rate IS NULL THEN "$Rating"
         WHEN MySwapRecord.counterpartyEmail = @UserID AND MySwapRecord.counterparty_rate IS NULL THEN "$Rating"
    END AS Rating
FROM    MySwapRecord
WHERE   status = 1 AND ((MySwapRecord.proposerEmail = @UserID AND MySwapRecord.proposer_rate IS NULL) OR (MySwapRecord.counterpartyEmail = @UserID AND MySwapRecord.counterparty_rate IS NULL))
ORDER BY decide_date DESC;


-- change rating: when user is counterparty
UPDATE  SwapRecord
SET     counterparty_rate = "$Rating"
WHERE   recordID = "$recordID";


-- change rating: when user is proposer
UPDATE  SwapRecord
SET     proposer_rate = "$Rating"
WHERE   recordID = "$recordID";
