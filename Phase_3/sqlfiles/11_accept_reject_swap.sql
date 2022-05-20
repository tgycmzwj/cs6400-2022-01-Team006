-- queries for accept or reject a swap
-- define some test cases
SET @UserID='user3@gmail.com';
SET @RecordID=1;


-- show proposed swaps where the user is the counterparty (just fixed)
WITH UserItem AS (
SELECT email, postalCode, nick_name,
    (SELECT AVG(rate)
	 FROM(
          SELECT proposerEmail as Email, counterparty_rate AS rate
          FROM SwapRecord NATURAL JOIN(
              SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
		      FROM Item
		  ) AS M1
          WHERE M1.proposerEmail=email
          UNION
		  SELECT counterpartyEmail AS Email, proposer_rate AS rate
          FROM SwapRecord NATURAL JOIN(
              SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	          FROM Item
          ) AS M2
          WHERE M2.counterpartyEmail=email
      ) AS M)
      AS rating, itemID, title
FROM    User
JOIN    Item
ON      User.email = Item.ownerEmail)
SELECT  SwapRecord.recordID, SwapRecord.propose_date AS Date, CUserItem.title AS "Desired Item",
		PUserItem.nick_name AS "Proposer", PUserItem.rating AS "Rating",
		cal_dist(PUserItem.postalCode, CUserItem.postalCode) AS Distance,
		PUserItem.title AS "Proposed Item"
FROM    SwapRecord
JOIN    UserItem AS CUserItem
ON      SwapRecord.desiredItemID = CUserItem.itemID
JOIN    UserItem AS PUserItem
ON      SwapRecord.proposedItemID = PUserItem.itemID
WHERE   SwapRecord.status IS NULL AND CUserItem.email=@UserID
ORDER BY SwapRecord.propose_date;


-- accept a swap
UPDATE  SwapRecord
SET     status = 1, decide_date = CURDATE()
WHERE   recordID = @RecordID;


-- Return contact information for swap proposer by query user in User where user.Email=swap_record.Proposer
WITH UserItemPhone AS (
    SELECT  email, first_name, phoneNumber, phone_type, itemID
	FROM User
    JOIN Item
	ON User.email = Item.ownerEmail
	JOIN Phone
    ON User.email = Phone.ownerEmail)
SELECT  email, first_name, phonenumber, phone_type
FROM    UserItemPhone
JOIN    (Select proposedItemID
		 FROM    SwapRecord
		 WHERE   recordID = @RecordID) AS t1
ON      UserItemPhone.itemID = t1.proposedItemID;

-- reject a swap
UPDATE  SwapRecord
SET     status = 0, decide_date = CURDATE()
WHERE   recordID = @RecordID;
