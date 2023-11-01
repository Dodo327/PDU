"""
Imię i nazwisko
Rozwiązanie pracy domowej nr 5
"""

# 1.) Przygotowanie danych

# a) wykonaj import potrzebnych pakietów
# import pandas as pd
# import numpy as np
# import sqlite3
# import os, os.path

# b) wczytaj ramki danych, na których będziesz dalej pracował
# Posts = pd.read_csv("travel_stackexchange_com/Posts.csv.gz", compression = 'gzip')
# Comments = pd.read_csv("travel_stackexchange_com/Comments.csv.gz", compression = 'gzip')
# Users = pd.read_csv("travel_stackexchange_com/Users.csv.gz", compression = 'gzip')
# c) przygotuj bazę danych zgodnie z instrukcją zamieszczoną w treści pracy domowej

# baza = 'solution.db'
# conn = sqlite3.connect(baza)
# Comments.to_sql("Comments", conn)
# Posts.to_sql("Posts", conn)
# Users.to_sql("Users", conn)

# 2.) Wyniki zapytań SQL

# sql_1 = pd.read_sql_query("""SELECT Location, SUM(UpVotes) as TotalUpVotes
#                             FROM Users
#                             WHERE Location != ''
#                             GROUP BY Location
#                             ORDER BY TotalUpVotes DESC
#                             LIMIT 10""", conn)
# sql_2 = pd.read_sql_query("""SELECT STRFTIME('%Y', CreationDate) AS Year, STRFTIME('%m', CreationDate) AS Month,
#                             COUNT(*) AS PostsNumber, MAX(Score) AS MaxScore
#                             FROM Posts
#                             WHERE PostTypeId IN (1, 2)
#                             GROUP BY Year, Month
#                             HAVING PostsNumber > 1000""", conn)
# sql_3 = pd.read_sql_query("""SELECT Id, DisplayName, TotalViews
#                             FROM (
#                             SELECT OwnerUserId, SUM(ViewCount) as TotalViews
#                             FROM Posts
#                             WHERE PostTypeId = 1
#                             GROUP BY OwnerUserId
#                             ) AS Questions
#                             JOIN Users
#                             ON Users.Id = Questions.OwnerUserId
#                             ORDER BY TotalViews DESC
#                             LIMIT 10
#                             """, conn)
# sql_4 = pd.read_sql_query("""SELECT DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes
#                             FROM (
#                             SELECT *
#                             FROM (
#                             SELECT COUNT(*) as AnswersNumber, OwnerUserId
#                             FROM Posts
#                             WHERE PostTypeId = 2
#                             GROUP BY OwnerUserId
#                             ) AS Answers
#                             JOIN
#                             (
#                             SELECT COUNT(*) as QuestionsNumber, OwnerUserId
#                             FROM Posts
#                             WHERE PostTypeId = 1
#                             GROUP BY OwnerUserId
#                             ) AS Questions
#                             ON Answers.OwnerUserId = Questions.OwnerUserId
#                             WHERE AnswersNumber > QuestionsNumber
#                             ORDER BY AnswersNumber DESC
#                             LIMIT 5
#                             ) AS PostsCounts
#                             JOIN Users
#                             ON PostsCounts.OwnerUserId = Users.Id""", conn)
# sql_5 = pd.read_sql_query("""SELECT Title, CommentCount, ViewCount, CommentsTotalScore, DisplayName, Reputation, Location
#                             FROM (
#                             SELECT Posts.OwnerUserId, Posts.Title, Posts.CommentCount, Posts.ViewCount,
#                             CmtTotScr.CommentsTotalScore
#                             FROM (
#                             SELECT PostId, SUM(Score) AS CommentsTotalScore
#                             FROM Comments
#                             GROUP BY PostId
#                             ) AS CmtTotScr
#                             JOIN Posts ON Posts.Id = CmtTotScr.PostId
#                             WHERE Posts.PostTypeId=1
#                             ) AS PostsBestComments
#                             JOIN Users ON PostsBestComments.OwnerUserId = Users.Id
#                             ORDER BY CommentsTotalScore DESC
#                             LIMIT 10""", conn)


# Uwaga: Zapytania powinny się wykonywać nie dłużej niż kilka sekund każde, jednak czasem występują problemy zależne od systemu, np. pod Linuxem zapytania 3 i 5 potrafią zająć odp. kilka minut i ponad godzinę. Żeby obejść ten problem wyniki zapytań mozna zapisac do tymczasowych plików pickle.

# Zapisanie każdej z ramek danych opisujących wyniki zapytań SQL do osobnego pliku pickle.
# for i, df in enumerate([sql_1, sql_2, sql_3, sql_4, sql_5], 1):
#     df.to_pickle(f'sql_{i}.pkl.gz')

# Wczytanie policzonych uprzednio wyników z plików pickle (możesz to zrobić, jeżeli zapytania wykonują się za długo).
# sql_1, sql_2, sql_3, sql_4, sql_5 = [
#     pd.read_pickle(f'sql_{i}.pkl.gz') for i in range(1, 5 + 1)
# ]

# 3.) Wyniki zapytań SQL odtworzone przy użyciu metod pakietu Pandas.

# zad. 1

# try:
#     pandas_1 = Users[Users["Location"] != ""].groupby("Location")["UpVotes"].sum().rename("TotalUpVotes").sort_values(ascending=False).reset_index().head(10)
#     print (pandas_1.equals(sql_1) )

# except Exception as e:
#     print("Zad. 1: niepoprawny wynik.")
#     print(e)

# zad. 2

# try:
#     pandas_2 = Posts[Posts["PostTypeId"].isin([1, 2])][["CreationDate", "Score"]]
#     date = pd.to_datetime(pandas_2["CreationDate"])
#     pandas_2["Year"] = date.dt.strftime("%Y")
#     pandas_2["Month"] = date.dt.strftime("%m")
#     pandas_2["MaxScore"] = pandas_2.groupby(["Year", "Month"])["Score"].transform("max")
#     pandas_2["PostsNumber"] = pandas_2.groupby(["Year", "Month"])["Score"].transform("count")
#     pandas_2 = pandas_2[["Year", "Month", "PostsNumber", "MaxScore"]].drop_duplicates()
#     pandas_2 = pandas_2[pandas_2["PostsNumber"] > 1000].reset_index(drop=True)
    
#     print (pandas_2.equals(sql_2) )

# except Exception as e:
#     print("Zad. 2: niepoprawny wynik.")
#     print(e)

# zad. 3

# try:
#     Questions = Posts[Posts["PostTypeId"] == 1][["OwnerUserId", "ViewCount"]].groupby("OwnerUserId")["ViewCount"].sum().rename("TotalViews")
#     pandas_3 = pd.merge(Users, Questions, left_on= "Id", right_on= "OwnerUserId")[["Id", "DisplayName", "TotalViews"]].sort_values("TotalViews", ascending=False).head(10).reset_index(drop=True)
    
#     print (pandas_3.equals(sql_3) )

# except Exception as e:
#     print("Zad. 3: niepoprawny wynik.")
#     print(e)

# zad. 4

# try:
#     Answers = Posts[Posts["PostTypeId"] == 2].groupby("OwnerUserId")["OwnerUserId"].count().rename("AnswersNumber").reset_index()
#     Questions = Posts[Posts["PostTypeId"] == 1].groupby("OwnerUserId")["OwnerUserId"].count().rename("QuestionsNumber").reset_index()\
    
#     PostsCounts = pd.merge(Answers, Questions, on="OwnerUserId")
#     PostsCounts = PostsCounts[PostsCounts["AnswersNumber"] > PostsCounts["QuestionsNumber"]].sort_values("AnswersNumber", ascending=False).head(5).reset_index()
    
#     pandas_4 = pd.merge(PostsCounts, Users, left_on="OwnerUserId", right_on="Id")
#     pandas_4 = pandas_4[["DisplayName", "QuestionsNumber", "AnswersNumber", "Location", "Reputation", "UpVotes", "DownVotes"]]
    
#     print (pandas_4.equals(sql_4) )

# except Exception as e:
#     print("Zad. 4: niepoprawny wynik.")
#     print(e)

# zad. 5

# try:
#     CmtTotScr = Comments[["PostId", "Score"]].groupby("PostId")["Score"].sum().rename("CommentsTotalScore")
    
#     PostsBestComments = pd.merge(Posts[Posts["PostTypeId"] == 1], CmtTotScr, left_on="Id", right_on="PostId")[["OwnerUserId", "Title", "CommentCount", "ViewCount", "CommentsTotalScore"]]
    
#     pandas_5 = pd.merge(PostsBestComments, Users, left_on="OwnerUserId", right_on="Id")[["Title", "CommentCount", "ViewCount", "CommentsTotalScore", "DisplayName", "Reputation", "Location"]].sort_values("CommentsTotalScore", ascending=False).head(10).reset_index(drop=True)
    
#     print (pandas_5.equals(sql_5) )

# except Exception as e:
#     print("Zad. 5: niepoprawny wynik.")
#     print(e)
