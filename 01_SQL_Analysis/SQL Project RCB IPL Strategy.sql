1. List the different dtypes of columns in table “ball_by_ball” (using
information schema)

SELECT DISTINCT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='ipl'
AND TABLE_NAME='Ball_by_Ball';

2. What is the total number of runs scored in 1st season by RCB
(bonus: also include the extra runs using the extra runs table)

SELECT SUM(b.Runs_Scored+IFNULL(e.Extra_Runs,0)) AS total_runs
FROM Ball_by_Ball b
LEFT JOIN Extra_Runs e
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
JOIN Matches m
USING(Match_Id)
WHERE m.Season_Id=6
AND b.Team_Batting=2;

3. How many players were more than the age of 25 during season
2014?

SELECT COUNT(DISTINCT pm.Player_Id) AS players_above_25
FROM Player_Match pm
JOIN Player p USING(Player_Id)
JOIN Matches m USING(Match_Id)
JOIN Season s USING(Season_Id)
WHERE s.Season_Year=2014
AND TIMESTAMPDIFF(YEAR,p.DOB,m.Match_Date)>25;

4. How many matches did RCB win in 2013?

SELECT COUNT(*) AS matches_won
FROM Matches m
JOIN Season s USING(Season_Id)
WHERE s.Season_Year=2013
AND m.Match_Winner=2;

5. List the top 10 players according to their strike rate in the last 4
seasons

SELECT p.Player_Name,
ROUND(SUM(b.Runs_Scored)*100/COUNT(*),2) AS Strike_Rate
FROM Ball_by_Ball b
JOIN Matches m USING(Match_Id)
JOIN Player p
ON b.Striker=p.Player_Id
WHERE m.Season_Id BETWEEN 6 AND 9
GROUP BY p.Player_Id,p.Player_Name
ORDER BY Strike_Rate DESC
LIMIT 10;

6. What are the average runs scored by each batsman considering
all the seasons?

SELECT p.Player_Name,
ROUND(AVG(b.Runs_Scored),2) AS Avg_Runs
FROM Ball_by_Ball b
JOIN Player p
ON b.Striker=p.Player_Id
GROUP BY p.Player_Id,p.Player_Name
ORDER BY Avg_Runs DESC;

7. What are the average wickets taken by each bowler considering all
the seasons?

SELECT p.Player_Name,
ROUND(COUNT(*)/COUNT(DISTINCT m.Season_Id),0) AS Avg_Wickets
FROM Wicket_Taken w
JOIN Ball_by_Ball b
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
JOIN Player p
ON b.Bowler=p.Player_Id
JOIN Matches m
USING(Match_Id)
GROUP BY p.Player_Id,p.Player_Name
ORDER BY Avg_Wickets DESC;

8. List all the players who have average runs scored greater than the
overall average and who have taken wickets greater than the
overall average

players who have average runs scored greater than the
overall average 

SELECT p.Player_Name,
       AVG(b.Runs_Scored) Avg_Runs
FROM Ball_by_Ball b
JOIN Player p
ON b.Striker = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING AVG(b.Runs_Scored) >
(
    SELECT AVG(Runs_Scored)
    FROM Ball_by_Ball
)
ORDER BY Avg_Runs DESC;

who have taken wickets greater than the
overall average

SELECT p.Player_Name,
       COUNT(*) Wickets
FROM Ball_by_Ball b
JOIN Wicket_Taken w
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
JOIN Player p
ON b.Bowler = p.Player_Id
GROUP BY p.Player_Id, p.Player_Name
HAVING COUNT(*) >
(
    SELECT AVG(Wicket_Count)
    FROM
    (
        SELECT COUNT(*) Wicket_Count
        FROM Ball_by_Ball b
        JOIN Wicket_Taken w
        USING(Match_Id,Over_Id,Ball_Id,Innings_No)
        GROUP BY b.Bowler
    ) x
)
ORDER BY Wickets DESC;

9. Create a table rcb_record table that shows the wins and losses of
RCB in an individual venue.

CREATE TABLE rcb_record AS
SELECT v.Venue_Name,
       SUM(m.Match_Winner=2) AS Wins,
       SUM(m.Match_Winner<>2) AS Losses
FROM Matches m
JOIN Venue v USING(Venue_Id)
WHERE m.Team_1=2 OR m.Team_2=2
GROUP BY v.Venue_Id,v.Venue_Name;

select * from rcb_record;



10. What is the impact of bowling style on wickets taken?

SELECT bs.Bowling_skill,
       COUNT(*) AS Wickets
FROM Wicket_Taken w
JOIN Ball_by_Ball b
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
JOIN Player p
ON b.Bowler=p.Player_Id
JOIN Bowling_Style bs
ON p.Bowling_skill=bs.Bowling_Id
GROUP BY bs.Bowling_Id,bs.Bowling_skill
ORDER BY Wickets DESC;


-- 11. Write the SQL query to provide a status of whether the
-- performance of the team is better than the previous year's
-- performance on the basis of the number of runs scored by the
-- team in the season and the number of wickets taken

WITH t AS (
SELECT
    s.Season_Id,
    b.Team_Batting Team_Id,
    Team_Name,
    SUM(b.Runs_Scored+IFNULL(e.Extra_Runs,0)) Runs,
    COUNT(w.Player_Out) Wickets
FROM Ball_by_Ball b
JOIN Matches m USING(Match_Id)
JOIN Season s USING(Season_Id)
LEFT JOIN Extra_Runs e
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
LEFT JOIN Wicket_Taken w
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
GROUP BY s.Season_Id,b.Team_Batting
)
SELECT *,
CASE
WHEN Runs>LAG(Runs) OVER(PARTITION BY Team_Id ORDER BY Season_Id)
AND Wickets>LAG(Wickets) OVER(PARTITION BY Team_Id ORDER BY Season_Id)
THEN 'Better'
ELSE 'Not Better'
END Status
FROM t;




-- 12. Can you derive more KPIs for the team strategy?

Top Run Scorers


SELECT p.Player_Name,
       SUM(Runs_Scored) Runs
FROM Ball_by_Ball b
JOIN Player p
ON b.Striker=p.Player_Id
GROUP BY p.Player_Id,p.Player_Name
ORDER BY Runs DESC;


13. Using SQL, write a query to find out the average wickets taken by
each bowler in each venue. Also, rank the gender according to the
average value.

WITH cte AS (
    SELECT v.Venue_Name,
           p.Player_Name,
           COUNT(*)/COUNT(DISTINCT b.Match_Id) AS Avg_Wickets
    FROM Wicket_Taken w
    JOIN Ball_by_Ball b
    USING(Match_Id,Over_Id,Ball_Id,Innings_No)
    JOIN Player p
    ON b.Bowler=p.Player_Id
    JOIN Matches m
    USING(Match_Id)
    JOIN Venue v
    USING(Venue_Id)
    GROUP BY v.Venue_Id,v.Venue_Name,p.Player_Id,p.Player_Name
)
SELECT *,
       DENSE_RANK() OVER(PARTITION BY Venue_Name ORDER BY Avg_Wickets DESC) AS Ranking
FROM cte;


14. Which of the given players have consistently performed well in
past seasons? (will you use any visualization to solve the problem)

SELECT s.Season_Year,
       p.Player_Name,
       avg(b.Runs_Scored) as avg_Runs
FROM Ball_by_Ball b
JOIN Matches m USING(Match_Id)
JOIN Season s USING(Season_Id)
JOIN Player p
ON b.Striker=p.Player_Id
GROUP BY s.Season_Year,p.Player_Id,p.Player_Name
ORDER BY avg_Runs desc,s.Season_Year,p.Player_Name;


15. Are there players whose performance is more suited to specific
venues or conditions? (how would you present this using charts?)


with a as(
	SELECT p.Player_Name,
       v.Venue_Name,
       SUM(b.Runs_Scored) AS Runs,
       ROUND(AVG(b.Runs_Scored),2) AS Avg_Runs
FROM Ball_by_Ball b
JOIN Player p
ON b.Striker=p.Player_Id
JOIN Matches m
USING(Match_Id)
JOIN Venue v
USING(Venue_Id)
GROUP BY p.Player_Id,p.Player_Name,v.Venue_Id,v.Venue_Name
ORDER BY p.Player_Name,Runs DESC)

select player_name,venue_name,sum(runs) Total_runs,avg(avg_runs) avg_runs from a 
 group by 1,2 order by total_runs desc;
 
---Subjective Questions---


1. How does the toss decision affect the result of the match? (which
visualizations could be used to present your answer better) And is
the impact limited to only specific venues?

SELECT
v.Venue_Name,
td.Toss_Name Toss_Decision,
COUNT(*) Matches,
SUM(m.Toss_Winner=m.Match_Winner) Toss_Winner_Wins,
ROUND(SUM(m.Toss_Winner=m.Match_Winner)*100/COUNT(*),2) Win_Percentage
FROM Matches m
JOIN Venue v USING(Venue_Id)
JOIN Toss_Decision td
ON m.Toss_Decide=td.Toss_Id
GROUP BY v.Venue_Name,td.Toss_Id,td.Toss_Name
ORDER BY v.Venue_Name,Win_Percentage DESC;


2. Suggest some of the players who would be best fit for the team.


SELECT p.Player_Name,
       SUM(b.Runs_Scored) Runs
FROM Ball_by_Ball b
JOIN Player p
ON b.Striker=p.Player_Id
GROUP BY p.Player_Id,p.Player_Name
ORDER BY Runs DESC
LIMIT 5;


3. What are some of the parameters that should be focused on while
selecting the players?


SELECT p.Player_Name,
       IFNULL(r.Runs,0) Runs,
       IFNULL(w.Wickets,0) Wickets
FROM Player p
LEFT JOIN(
    SELECT Striker Player_Id,
           SUM(Runs_Scored) Runs
    FROM Ball_by_Ball
    GROUP BY Striker
) r
ON p.Player_Id=r.Player_Id
LEFT JOIN(
    SELECT b.Bowler Player_Id,
           COUNT(*) Wickets
    FROM Ball_by_Ball b
    JOIN Wicket_Taken w
    USING(Match_Id,Over_Id,Ball_Id,Innings_No)
    GROUP BY b.Bowler
) w
ON p.Player_Id=w.Player_Id
ORDER BY Runs DESC,Wickets DESC;

4. Which players offer versatility in their skills and can contribute
effectively with both bat and ball? (can you visualize the data for
the same)

with a as(
SELECT p.Player_Name,
       r.Runs,
       w.Wickets
FROM Player p
JOIN (
    SELECT Striker Player_Id,
           SUM(Runs_Scored) Runs
    FROM Ball_by_Ball
    GROUP BY Striker
) r
ON p.Player_Id = r.Player_Id
JOIN (
    SELECT b.Bowler Player_Id,
           COUNT(*) Wickets
    FROM Ball_by_Ball b
    JOIN Wicket_Taken w
    USING(Match_Id,Over_Id,Ball_Id,Innings_No)
    GROUP BY b.Bowler
) w
ON p.Player_Id = w.Player_Id
ORDER BY Runs DESC, Wickets DESC)
select * from a where runs>1000 and wickets >10;


5. Are there players whose presence positively influences the morale
and performance of the team? (justify your answer using
visualization)
											
SELECT
    p.Player_Name,
    COUNT(*) AS Matches_Played,
    SUM(m.Match_Winner=pm.Team_Id) AS Matches_Won,
    ROUND(SUM(m.Match_Winner=pm.Team_Id)*100/COUNT(*),2) AS Win_Percentage
FROM Player_Match pm
JOIN Player p
ON pm.Player_Id=p.Player_Id
JOIN Matches m
ON pm.Match_Id=m.Match_Id
GROUP BY p.Player_Id,p.Player_Name
HAVING COUNT(*)>=20
ORDER BY Win_Percentage DESC,Matches_Played DESC;



6. What would you suggest to RCB before going to the mega
auction?

Best Players (Runs + Wickets)

with a as(
SELECT p.Player_Name,
       IFNULL(r.Runs,0) Runs,
       IFNULL(w.Wickets,0) Wickets
FROM Player p
LEFT JOIN(
SELECT Striker Player_Id,
       SUM(Runs_Scored) Runs
FROM Ball_by_Ball
GROUP BY Striker
) r
ON p.Player_Id=r.Player_Id
LEFT JOIN(
SELECT b.Bowler Player_Id,
       COUNT(*) Wickets
FROM Ball_by_Ball b
JOIN Wicket_Taken w
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
GROUP BY b.Bowler
) w
ON p.Player_Id=w.Player_Id
ORDER BY Runs DESC,Wickets DESC)
select *, case when runs>1000 and wickets>10 then 'All-Rounder'
when runs > 1000 then 'Top Batsman'
when wickets>10 then 'Top Bowler'
end as Player_category from a where runs>1000 or wickets>10;

7. What do you think could be the factors contributing to the
high-scoring matches and the impact on viewership and team
strategies

Average score by venue


SELECT
v.Venue_Name,
ROUND(AVG(score.Total_Runs),2) Avg_Score
FROM(
SELECT
Match_Id,
Innings_No,
SUM(Runs_Scored) Total_Runs
FROM Ball_by_Ball
GROUP BY Match_Id,Innings_No
) score
JOIN Matches m
USING(Match_Id)
JOIN Venue v
USING(Venue_Id)
GROUP BY v.Venue_Id,v.Venue_Name
ORDER BY Avg_Score DESC;


Highest scoring teams


SELECT
t.Team_Name,
SUM(b.Runs_Scored) Runs
FROM Ball_by_Ball b
JOIN Team t
ON b.Team_Batting=t.Team_Id
GROUP BY t.Team_Id,t.Team_Name
ORDER BY Runs DESC;



8. Analyze the impact of home-ground advantage on team
performance and identify strategies to maximize this advantage for
RCB.


Home vs Away Performance


SELECT
CASE
WHEN v.Venue_Name='M Chinnaswamy Stadium' THEN 'Home'
ELSE 'Away'
END Venue,
COUNT(*) Matches,
SUM(m.Match_Winner=2) Wins,
COUNT(*)-SUM(m.Match_Winner=2) Losses,
ROUND(SUM(m.Match_Winner=2)*100/COUNT(*),2) Win_Percentage
FROM Matches m
JOIN Venue v USING(Venue_Id)
WHERE m.Team_1=2 OR m.Team_2=2
GROUP BY Venue;


Venue-wise Performance


SELECT
v.Venue_Name,
COUNT(*) Matches,
SUM(m.Match_Winner=2) Wins,
ROUND(SUM(m.Match_Winner=2)*100/COUNT(*),2) Win_Percentage
FROM Matches m
JOIN Venue v USING(Venue_Id)
WHERE m.Team_1=2 OR m.Team_2=2
GROUP BY v.Venue_Id,v.Venue_Name
ORDER BY Win_Percentage DESC;


Toss Impact at Home


SELECT
td.Toss_Name,
COUNT(*) Matches,
SUM(m.Match_Winner=2) Wins
FROM Matches m
JOIN Venue v USING(Venue_Id)
JOIN Toss_Decision td
ON m.Toss_Decide=td.Toss_Id
WHERE v.Venue_Name='M Chinnaswamy Stadium'
AND (m.Team_1=2 OR m.Team_2=2)
GROUP BY td.Toss_Id,td.Toss_Name;


9. Come up with a visual and analytical analysis of the RCB's past
season's performance and potential reasons for them not winning
a trophy.


Season-wise Performance


SELECT
s.Season_Year,
COUNT(*) Matches,
SUM(m.Match_Winner=2) Wins,
COUNT(*)-SUM(m.Match_Winner=2) Losses,
ROUND(SUM(m.Match_Winner=2)*100/COUNT(*),2) Win_Percentage
FROM Matches m
JOIN Season s
USING(Season_Id)
WHERE m.Team_1=2
OR m.Team_2=2
GROUP BY s.Season_Year
ORDER BY s.Season_Year;


Batting Performance


SELECT
s.Season_Year,
SUM(b.Runs_Scored) Runs
FROM Ball_by_Ball b
JOIN Matches m
USING(Match_Id)
JOIN Season s
USING(Season_Id)
WHERE b.Team_Batting=2
GROUP BY s.Season_Year
ORDER BY s.Season_Year;


Bowling Performance

SELECT
s.Season_Year,
COUNT(*) Wickets
FROM Wicket_Taken w
JOIN Ball_by_Ball b
USING(Match_Id,Over_Id,Ball_Id,Innings_No)
JOIN Matches m
USING(Match_Id)
JOIN Season s
USING(Season_Id)
WHERE b.Bowler IN(
SELECT Player_Id
FROM Player_Match
WHERE Team_Id=2
)
GROUP BY s.Season_Year
ORDER BY s.Season_Year;


Home vs Away

SELECT
CASE
WHEN v.Venue_Name='M Chinnaswamy Stadium'
THEN 'Home'
ELSE 'Away'
END Venue,
COUNT(*) Matches,
SUM(m.Match_Winner=2) Wins,
ROUND(SUM(m.Match_Winner=2)*100/COUNT(*),2) Win_Percentage
FROM Matches m
JOIN Venue v
USING(Venue_Id)
WHERE m.Team_1=2
OR m.Team_2=2
GROUP BY Venue;


10. How would you approach this problem, if the objective and
subjective questions weren't given?


Business Understanding
        ↓
Data Understanding
        ↓
Data Cleaning
        ↓
Exploratory Data Analysis (EDA)
        ↓
KPI Generation
        ↓
Visualization
        ↓
Insight Generation
        ↓
Business Recommendations
        ↓
Final Report / Dashboard




11. In the "Match" table, some entries in the "Opponent_Team" column
are incorrectly spelled as "Delhi_Capitals" instead of
"Delhi_Daredevils". Write an SQL query to replace all occurrences
of "Delhi_Capitals" with "Delhi_Daredevils".

UPDATE team
SET team_name = 'Delhi Daredevils'
WHERE team_name = 'Delhi_Capitals';

select * from team;
