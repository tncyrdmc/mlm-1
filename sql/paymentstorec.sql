SELECT pb.userid, SUM(pb.payment_amount) as ToAccount

FROM payments_balance as pb
# not yet logged to be saved
WHERE accounted = '0' 
# the level is not yet full	
    AND
		(SELECT bl.nmbrpayments 
		FROM bonuslimits as bl
		WHERE bl.userid=pb.userid 
			AND
			bl.level = 
				(SELECT afus.level
				FROM affiliateuser as afus
				where afus.Id = pb.sourceid)
					-
				(SELECT afus.level
				FROM affiliateuser as afus
				where afus.Id = pb.userid)
		) < 1 # random bonus limit - to change later
# performed more than X(==nrpaydays) days ago
	AND 
		TO_DAYS(CURTIME()) - TO_DAYS(createdtime) >= 
			(SELECT nrpaydays
			FROM timeouts)
		

GROUP BY userid 
HAVING
    	(SELECT COUNT(*)
         FROM payments_balance
         WHERE LOWER(side) like "l%" 
			AND userid = pb.userid)
         =
         (SELECT COUNT(*)
         FROM payments_balance
         WHERE LOWER(side) like "r%" 
			AND userid = pb.userid)