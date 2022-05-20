DROP FUNCTION IF EXISTS cal_distance;
DELIMITER $$
CREATE FUNCTION cal_distance(
    lat1 FLOAT,
    lon1 FLOAT,
    lat2 FLOAT,
    lon2 FLOAT
) RETURNS float
DETERMINISTIC
BEGIN
    DECLARE delta_lat FLOAT DEFAULT 0;
    DECLARE delta_lon FLOAT DEFAULT 0;
    DECLARE a FLOAT DEFAULT 0;
    DECLARE c FLOAT DEFAULT 0;
    SELECT pi()*lat1/180-pi()*lat2/180 INTO delta_lat;
    SELECT pi()*lon1/180-pi()*lon2/180 INTO delta_lon;
    SELECT power(sin(delta_lat/2),2)+cos(pi()*lat1/180)*cos(pi()*lat2/180)*power(sin(delta_lon/2),2) INTO a;
    SELECT 2*atan2(sqrt(a),sqrt(1-a)) INTO c;
    RETURN c*6371;
END$$
DELIMITER ;