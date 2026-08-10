# RCB IPL Strategy — SQL Data Analysis

## Project Overview

A data-driven IPL analytics project designed to evaluate Royal Challengers Bengaluru's (RCB) historical performance and develop a strategic player-selection and auction framework.

The project approaches RCB's performance as a sports analytics problem:

**Where is RCB? → What is driving performance? → Where are the weaknesses? → What should RCB do next?**

The analysis combines relational SQL data, advanced analytical queries, performance KPIs, player evaluation, venue analysis, team comparisons, and business recommendations to support squad-building decisions for the 2017 Mega Auction.

---

## Business Problem

RCB needs to identify top-performing and reliable players while balancing on-field performance with value for money during the Mega Auction.

The objective is to:

- Evaluate RCB's historical team performance
- Identify performance gaps
- Assess individual player contributions
- Measure batting and bowling strength
- Evaluate squad balance and player dependency
- Analyze venue and toss effects
- Compare RCB with leading IPL teams
- Identify suitable player profiles for different roles
- Develop a data-driven auction strategy

---

## Dataset & Database Structure

The project works with a relational IPL database containing interconnected datasets covering matches, players, teams, seasons, ball-by-ball events, batting, bowling, wickets, venues, and other match-level information.

### Core datasets highlighted in the project

| Dataset | Purpose |
|---|---|
| Ball_by_Ball | Ball-by-ball match data |
| Matches | Match details and results |
| Player | Player information |
| Player_Match | Player participation records |
| Team | Team information |
| Season | IPL season details |
| Batsman_Scored | Runs scored per delivery |
| Extra_Runs | Wide, no-ball and other extras |
| Wicket_Taken | Wicket and dismissal information |
| Bowling_Style | Bowler classification |

The project also uses supporting relational tables such as Venue and Toss_Decision for deeper venue and match-strategy analysis. The database schema and table relationships are documented in the project presentation. :contentReference[oaicite:2]{index=2}

---

## Analytical Framework

The analysis follows a structured sports-analytics workflow:

```text
Business Understanding
        ↓
Data Understanding
        ↓
Data Exploration
        ↓
KPI Generation
        ↓
SQL Analysis
        ↓
Performance Comparison
        ↓
Visualization
        ↓
Insight Generation
        ↓
Strategic Recommendations
