-- queries used for login
USE gameswapDB;
-- define some test cases
SET @Email_or_Phone1='user1@gmail.com';
SET @Email_or_Phone2='0000000001';

-- the case when user input an email
SELECT password
FROM gameswapDB.User
WHERE User.email=@Email_or_Phone1;

-- the case when user input a phone number
SELECT password
FROM gameswapDB.User
WHERE User.email=(
    SELECT ownerEmail
    FROM gameswapDB.Phone
    WHERE Phone.phoneNumber=@Email_or_Phone2
);
