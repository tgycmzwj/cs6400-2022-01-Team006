-- queries for swap details

-- define some test cases
SET @RecordID=2;
SET @UserID='user5@gmail.com';

WITH TargetSwapRecord AS (
SELECT recordID, proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate, counterparty_rate
FROM  SwapRecord WHERE recordID = @RecordID),
UserItemPhone AS  (
SELECT  email, postalCode, first_name, last_name, nick_name, phoneNumber, phone_type, share_phone, itemID, title, description, game_condition,
    CASE WHEN Item.itemID IN (SELECT itemID FROM BoardGame) THEN 'Board Game'
				 WHEN Item.itemID IN (SELECT itemID FROM CardGame) THEN 'Card Game'
         WHEN Item.itemID IN (SELECT itemID FROM JigsawPuzzle) THEN 'Jigsaw Puzzle'
         WHEN Item.itemID IN (SELECT itemID FROM ComputerGame) THEN 'Computer Game'
         WHEN Item.itemID IN (SELECT itemID FROM VideoGame) THEN 'Video Game'
         ELSE 'Error Type'
    END AS game_Type
FROM User
JOIN Item ON User.email = Item.ownerEmail
LEFT JOIN Phone ON User.email = Phone.ownerEmail),
TargetSwapAllInfo AS (
SELECT recordID, PUserItemPhone.email AS proposerEmail, CUserItemPhone.email AS counterpartyEmail,
			 proposedItemID, desiredItemID, status, propose_date, decide_date, proposer_rate,
       counterparty_rate, PUserItemPhone.title AS Ptitle, CUserItemPhone.title AS Ctitle,
       PUserItemPhone.game_type AS Pgame_type, CUserItemPhone.game_type as Cgame_type,
       PUserItemPhone.game_condition AS Pgame_condition, CUserItemPhone.game_condition AS Cgame_condition,
       PUserItemPhone.description AS Pdescription, PUserItemPhone.nick_name AS Pnick_name,
       CUserItemPhone.nick_name AS Cnick_name, PUserItemPhone.first_name AS Pfirst_name,
       CUserItemPhone.first_name AS Cfirst_name,PUserItemPhone.last_name AS Plast_name,
       CUserItemPhone.last_name AS Clast_name, PUserItemPhone.postalCode AS PpostalCode,
       CUserItemPhone.postalCode AS CpostalCode, PUserItemPhone.phoneNumber AS PphoneNumber,
       CUserItemPhone.phoneNumber AS CphoneNumber, PUserItemPhone.phone_type AS Pphone_type,
       CUserItemPhone.phone_type AS Cphone_type, PUserItemPhone.share_phone AS Pshare_phone,
       CUserItemPhone.share_phone AS Cshare_phone
       FROM TargetSwapRecord
       JOIN UserItemPhone AS PUserItemPhone
       ON TargetSwapRecord.proposedItemID = PUserItemPhone.itemID
       JOIN UserItemPhone AS CUserItemPhone
       ON TargetSwapRecord.desiredItemID = CUserItemPhone.itemID)

SELECT
-- swap details
   propose_date AS Proposed, decide_date AS "Accepted/Rejected", status AS Status,
   CASE WHEN TargetSwapAllInfo.proposerEmail = @UserID THEN "Proposer"
        WHEN TargetSwapAllInfo.counterpartyEmail = @UserID THEN "Counterparty"
   END AS "My Role",
   CASE WHEN TargetSwapAllInfo.proposerEmail = @UserID THEN
        CASE WHEN proposer_rate IS NOT NULL THEN proposer_rate
             ElSE "$Rating"
	 END
        WHEN TargetSwapAllInfo.counterpartyEmail = @UserID THEN
	 CASE WHEN counterparty_rate IS NOT NULL THEN counterparty_rate
             ElSE "$Rating"
        END
   END AS "Rating left",
-- other user details
   CASE WHEN proposerEmail =@UserID THEN Cnick_name
        WHEN counterpartyEmail =@UserID THEN Pnick_name
   END AS "Nickname",
   cal_dist(PpostalCode, CpostalCode) AS Distance,
   CASE WHEN status = 1 THEN
		 CASE WHEN proposerEmail = @UserID THEN Cfirst_name
              WHEN counterpartyEmail = @UserID THEN Pfirst_name
		 END
         ELSE NULL
	END AS "Name",
	CASE WHEN status = 1 THEN
       CASE WHEN proposerEmail = @UserID THEN counterpartyEmail
			      WHEN counterpartyEmail = @UserID THEN proposerEmail
		   END
       ELSE NULL
	END AS "Email",
	CASE WHEN status = 1 THEN
       CASE WHEN (proposerEmail = @UserID AND Cshare_phone=1) THEN CphoneNumber
			 WHEN (counterpartyEmail = @UserID AND Pshare_phone=1) THEN PphoneNumber
            ELSE NULL
       END
       ELSE NULL
  END AS "Phone Number",
	CASE WHEN status = 1 THEN
       CASE WHEN (proposerEmail = @UserID AND Cshare_phone=1) THEN Cphone_type
			      WHEN (counterpartyEmail = @UserID AND pshare_phone=1) THEN Pphone_type
            ELSE NULL
       END
       ELSE NULL
  END AS "Phone Type",
-- proposed item
  proposedItemID AS "Item #", Ptitle AS "Title", Pgame_type AS "Game type",
            Pgame_condition AS "Condition", Pdescription AS "Description",
-- desired item
  desiredItemID AS "Item #", Ctitle AS "Title", Cgame_type AS "Game type",
            Cgame_condition AS "Condition"
FROM    TargetSwapAllInfo;
