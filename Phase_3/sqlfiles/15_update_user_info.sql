-- queries used for update user information
-- define some test cases
SET @UserID='user1@gmail.com';
SET @UserID2='user5@gmail.com';
SET @Password='aaaaaaaa';
SET @First_Name='first_name100';
SET @Last_Name='last_name100';
SET @Nick_Name='nick_name100';
SET @Postal_Code='02241';
SET @Phone_Number='0000000100';
SET @Phone_Type='home';
SET @Share_Phone=True;


-- number of unapproved swaps
SELECT COUNT(*)
FROM gameswapDB.SwapRecord NATURAL JOIN (
	SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	FROM gameswapDB.Item
)AS M1 NATURAL JOIN (
	SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	FROM gameswapDB.Item
)AS M2
WHERE ((proposerEmail=@UserID) OR (counterpartyEmail=@UserID)) AND (status IS NULL);



-- number of unrated swaps
SELECT COUNT(*)
FROM gameswapDB.SwapRecord NATURAL JOIN (
	SELECT ownerEmail AS proposerEmail, ItemID AS proposedItemID
	FROM gameswapDB.Item
)AS M1 NATURAL JOIN (
	SELECT ownerEmail AS counterpartyEmail, ItemID AS desiredItemID
	FROM gameswapDB.Item
)AS M2
WHERE ((proposerEmail=@UserID2 AND proposer_rate IS NULL) OR (counterpartyEmail=@UserID2 AND counterparty_rate IS NULL)) AND (status=1);



-- display email
SELECT *
FROM gameswapDB.User
WHERE User.email=@UserID;
-- check if the phone number exists
SELECT COUNT(*)
FROM gameswapDB.Phone
WHERE Phone.phoneNumber=@Phone_Number AND Phone.ownerEmail!=@UserID;
-- check if the postal code is valid
SELECT COUNT(*)
FROM gameswapDB.Location
WHERE Location.postalCode=@Postal_Code;
-- check if the postal code is valid
SELECT city,state
FROM gameswapDB.Location
WHERE Location.postalCode=@Postal_Code;
-- update information for the user
UPDATE gameswapDB.User
SET postalCode=@Postal_Code,password=@Password,first_name=@First_Name,last_name=@Last_Name,nick_name=@Nick_Name
WHERE email=@UserID;
-- update phone for the user
UPDATE gameswapDB.Phone
SET phoneNumber=@Phone_Number, phone_type=@Phone_Type, share_phone=@Share_Phone
WHERE ownerEmail=@UserID;
