### Przetwarzanie Danych Ustrukturyzowanych 2023L
### Praca domowa nr. 3
###
### UWAGA:
### nazwy funkcji oraz ich parametrow powinny pozostac niezmienione.
###  
### Wskazane fragmenty kodu przed wyslaniem rozwiazania powinny zostac 
### zakomentowane
###

# -----------------------------------------------------------------------------#
# Wczytanie danych oraz pakietow.
# !!! Przed wyslaniem zakomentuj ten fragment
# -----------------------------------------------------------------------------#

# Posts <- read.csv("C:/PDW/Projekt1/travel_stackexchange_com/Posts.csv.gz")
# Users <- read.csv("C:/PDW/Projekt1/travel_stackexchange_com/Users.csv.gz")
# Comments <- read.csv("C:/PDW/Projekt1/travel_stackexchange_com/Comments.csv.gz")
# library("sqldf")
# library("dplyr") 
# library("data.table")
# library("microbenchmark")


# -----------------------------------------------------------------------------#
# Zadanie 1
# -----------------------------------------------------------------------------#

sql_1 <- function(Users){
    sqldf("SELECT Location, SUM(UpVotes) as TotalUpVotes
            FROM Users
            WHERE Location != ''
            GROUP BY Location
            ORDER BY TotalUpVotes DESC
            LIMIT 10")
}

base_1 <- function(Users){
    # Filtrujemy użytkowników z niepustymi wartościami w kolumnie Location
    filteredUsers <- Users[ Users$Location != "",]
    
    # Sumujemy UpVotes po lokalizacji użytkowników
    usersTotalUpVotes <- aggregate(UpVotes ~ Location, filteredUsers, sum)

    # Sortujemy dane według liczby UpVotes w porządku malejącym
    sortedUsers <- usersTotalUpVotes[order(usersTotalUpVotes$UpVotes, decreasing = TRUE),]

    # Wybieramy top10 użytkowników z największą liczbą UpVotes
    top10Users <- sortedUsers[1:10,]

    # Nadajemy nazwy kolumnom i numerację wierszom
    colnames(top10Users) <- c("Location", "TotalUpVotes")
    rownames(top10Users) <- 1:10

    return(top10Users)
}

dplyr_1 <- function(Users){
    x <- Users %>% 
        # Wybieramy kolumny Location i UpVotes z ramki danych Users
        select(Location, UpVotes) %>%
        
        # Filtrujemy wiersze, w których lokalizacji nie jest puste
        filter(Location != "") %>%
        
        # Grupujemy wiersze według lokalizacji
        group_by(Location) %>%
        
        # Obliczamy sumę UpVotes dla każdej grupy (lokalizacji)
        summarise(TotalUpVotes = sum(UpVotes)) %>%
        
        # Sortujemy według TotalUpVotes w porządku malejącym
        arrange(desc(TotalUpVotes)) %>%
        
        # Wybieramy top10 wyników
        head(10) 

    return(as.data.frame(x))
}

table_1 <- function(Users){
    # Wczytujemy dane
    u <- data.table(Users)

    # Filtrujemy wiersze, w których lokalizacji nie jest puste
    u <- u[(Location != "")]

    # Wybieramy kolumny Location i UpVotes
    u <- u[, .(Location, UpVotes)]

    # Sumujemy UpVotes według Location
    u <- u[, .(TotalUpVotes = sum(UpVotes, na.rm = TRUE)), by = .(Location)]
    
    # Sortujemy według TotalUpVotes malejąco
    u <- u[order(-TotalUpVotes)]

    # Wybieramy top10 wyników
    u <- head(u, 10)

    return(as.data.frame(u))
}

# Sprawdzenie rownowaznosci wynikow - zakomentuj te czesc przed wyslaniem

# print(all.equal(sql_1(Users), base_1(Users)))
# print(all.equal(sql_1(Users), dplyr_1(Users)))
# print(all.equal(sql_1(Users), table_1(Users)))

# Porowanie czasow wykonania - zakomentuj te czesc przed wyslaniem

# print(microbenchmark(
# sql_call_score=sql_1(Users),
# base_call_score=base_1(Users),
# dplyr_call_score=dplyr_1(Users),
# table_call_score=table_1(Users),
# times=10
# ))

# -----------------------------------------------------------------------------#
# Zadanie 2
# -----------------------------------------------------------------------------#

sql_2 <- function(Posts){
    sqldf("SELECT STRFTIME('%Y', CreationDate) AS Year, STRFTIME('%m', CreationDate) AS Month,
            COUNT(*) AS PostsNumber, MAX(Score) AS MaxScore
            FROM Posts
            WHERE PostTypeId IN (1, 2)
            GROUP BY Year, Month
            HAVING PostsNumber > 1000")
}

base_2 <- function(Posts){
    # Dodajemy kolumny z informacją o roku i miesiącu z CreationDate
    Posts$Year <- format(as.Date(Posts$CreationDate, "%Y-%m-%d"), "%Y")
    Posts$Month <- format(as.Date(Posts$CreationDate, "%Y-%m-%d"), "%m")
    
    # Filtrujemy posty według PostTypeId == 1 lub PostTypeId == 2
    postsFiltered <- subset(Posts, PostTypeId == 1 | PostTypeId == 2)

    # Zliczamy liczbę postów w każdym unikatowym roku i miesiącu
    postsCounted <- aggregate(postsFiltered[, "Score"], by = postsFiltered[,c("Year", "Month")], FUN = length)
    
    # Szukamy najwyższy Score w każdym unikatowym roku i miesiącu
    postsMaxScore <- aggregate(postsFiltered[, "Score"], by = postsFiltered[,c("Year", "Month")], FUN = max)

    # Łączymy tablice z ilością postów i z maksymalnym Score 
    postsFinal <- cbind(postsCounted, postsMaxScore[3])
    
    # Nadajemy nazwy kolumnom
    names(postsFinal) <- NULL
    colnames(postsFinal) <- c( "Year", "Month", "PostsNumber", "MaxScore")
    
    # Wybieramy rok i miesiąc z PostNumber > 1000
    postsFinal <- subset(postsFinal, PostsNumber > 1000)
    
    # Segregujemy według roku i miesiąca
    postsFinal <- postsFinal[order(postsFinal$Year, postsFinal$Month),]
    
    # Nadajemy numerację wierszom
    rownames(postsFinal) <- 1:length(postsFinal$Year)
    
    return(postsFinal)
}

dplyr_2 <- function(Posts){
    x <- Posts %>%
        # Filtrujemy posty według PostTypeId == 1 lub PostTypeId == 2
        filter(PostTypeId == 1 | PostTypeId == 2) %>%
        
        # Dodajemy kolumny z informacją o roku i miesiącu z CreationDate
        mutate(Year = format(as.Date(CreationDate), "%Y"), Month = format(as.Date(CreationDate), "%m")) %>%
        
        # Wybieramy kolumny Year, Month i Score
        select(Year, Month, Score) %>%
        
        # Grupujemy według Year i Month
        group_by(Year, Month) %>%
        
        # Dodajemy kolumny PostsNumber (liczba postów w każdym miesiącu) i MaxScore (maksymalny wynik w każdym miesiącu)
        reframe(PostsNumber = length(Year), MaxScore = max(Score)) %>%
        
        # Filtrujemy według PostsNumber > 1000
        filter(PostsNumber > 1000) %>%
        
        #Sortujemy według Year i Month
        arrange(Year, Month)

    return(as.data.frame(x))
        
}

table_2 <- function(Posts){
    p <- data.table(Posts)
    
    # Filtrujemy posty według PostTypeId == 1 lub PostTypeId == 2
    p <- p[(PostTypeId == 1) | (PostTypeId == 2)]
    
    # Dodajemy kolumny z informacją o roku i miesiącu z CreationDate
    p$Year <- format(as.Date(p$CreationDate), "%Y")
    p$Month <- format(as.Date(p$CreationDate), "%m")
    
    # Wybieramy kolumny Year, Month i Score
    p <- p[, .(Year, Month, Score)]
    
    # Dodajemy kolumny PostsNumber (liczba postów w każdym miesiącu) i MaxScore (maksymalny wynik w każdym miesiącu)
    p <- p[, .(PostsNumber = length(Score), MaxScore = max(Score, na.rm = TRUE)), by = .(Year, Month)]
    
    # Filtrujemy według PostsNumber > 1000
    p <- p[PostsNumber > 1000,]
    
    #Sortujemy według Year i Month
    p <- p[order(Year, Month)]

    return(as.data.frame(p))
}

# Sprawdzenie rownowaznosci wynikow - zakomentuj te czesc przed wyslaniem

# print(all.equal(sql_2(Posts), base_2(Posts)))
# print(all.equal(sql_2(Posts), dplyr_2(Posts)))
# print(all.equal(sql_2(Posts), table_2(Posts)))

# Porowanie czasow wykonania - zakomentuj te czesc przed wyslaniem

# print(microbenchmark(
# sql_call_score=sql_2(Posts),
# base_call_score=base_2(Posts),
# dplyr_call_score=dplyr_2(Posts),
# table_call_score=table_2(Posts),
# times=10
# ))

# -----------------------------------------------------------------------------#
# Zadanie 3
# -----------------------------------------------------------------------------#

sql_3 <- function(Posts, Users){
    Questions <- sqldf( 'SELECT OwnerUserId, SUM(ViewCount) as TotalViews
                            FROM Posts
                            WHERE PostTypeId = 1
                            GROUP BY OwnerUserId' )
    
    sqldf( "SELECT Id, DisplayName, TotalViews
                FROM Questions
                JOIN Users
                ON Users.Id = Questions.OwnerUserId
                ORDER BY TotalViews DESC
                LIMIT 10")
}

base_3 <- function(Posts, Users){
    
    #Filtrujemy Posts według PostTypeId == 1 i wybieramy kolumny OwnerUserId i ViewCount
    questions <- Posts[Posts$PostTypeId == 1, c("OwnerUserId", "ViewCount")]
    
    # Zliczamy sumę ViewCount dla każdego użytkownika
    questions <- aggregate(ViewCount ~ OwnerUserId, Posts, sum)
    colnames(questions) <- c("OwnerUserId", "TotalViews")
    
    # Łączymy tablice według Id użytkownika
    final <- merge(Users, questions, by.x = "Id", by.y = "OwnerUserId")

    # Wybieramy kolumny Id, DisplayName i TotalViews
    final <- final[, c("Id", "DisplayName", "TotalViews")]

    # Sortujemy według TotalViews malejąco
    final <- final[order(final$TotalViews, decreasing = TRUE),]
    
    # Wybieramy top10 użytkowników
    finalTop10 <- final[1:10,]
    
    # Nadajemy numerację wierszom
    rownames(finalTop10) <- 1:10
    
    
    return(finalTop10)
}

dplyr_3 <- function(Posts, Users){ 
    questions <- Posts %>%
        
        #Filtrujemy Posts według PostTypeId == 1
        filter(PostTypeId == 1) %>%

        # Wybieramy kolumny OwnerUserId i ViewCount
        select(OwnerUserId, ViewCount) %>%
        
        #Grupujemy według OwnerUserId
        group_by(OwnerUserId) %>%
        
        # Zliczamy sumę ViewCount
        reframe(TotalViews = sum(ViewCount))

    x <- Users %>%
        # Wybieramy kolumny Id i DisplayName
        select(Id, DisplayName) %>%
        
        # Łączymy tablice według Id = OwnerUserId
        left_join(questions, by = c("Id" = "OwnerUserId")) %>%
        
        # Sortujemy według TotalViews malejąco
        arrange(desc(TotalViews)) %>%
        
        # Wybieramy top użytkowników
        head(10)

    return(as.data.frame(x))
}

table_3 <- function(Posts, Users){
    questions <- data.table(Posts)
    
    # Filtrujemy według PostTypeId == 1
    questions <- questions[(PostTypeId == 1)]

    # Wybieramy kolumny OwnerUserId i ViewCount
    questions <- questions[, .(OwnerUserId, ViewCount)]

    # Zliczamy sumę ViewCount dla każdego użytkownika
    questions <- questions[, .(TotalViews = sum(ViewCount)), by = .(OwnerUserId)]

    usersData <- data.table(Users)

    # Łączymy tablice według Id = OwnerUserId
    joinedData <- na.omit(usersData[questions, on = .(Id = OwnerUserId)])
    
    # Wybieramy kolumny Id, DisplayName i TotalViews
    joinedData <- joinedData[,.(Id, DisplayName, TotalViews)]
    
    # Sourtujemy według TotalViews malejąco
    joinedData <- joinedData[order(-TotalViews)]
    joinedData <- head(joinedData, 10)

    return(as.data.frame(joinedData))

}

# Sprawdzenie rownowaznosci wynikow - zakomentuj te czesc przed wyslaniem

# print(all.equal(dplyr_3(Posts, Users), base_3(Posts, Users)))
# print(all.equal(table_3(Posts, Users), dplyr_3(Posts, Users)))
# print(all.equal(base_3(Posts, Users), table_3(Posts, Users)))

# Porowanie czasow wykonania - zakomentuj te czesc przed wyslaniem

# print(microbenchmark(
# sql_call_score=sql_3(Posts, Users),
# base_call_score=base_3(Posts, Users),
# dplyr_call_score=dplyr_3(Posts, Users),
# table_call_score=table_3(Posts, Users),
# times=10
# ))

# -----------------------------------------------------------------------------#
# Zadanie  4
# -----------------------------------------------------------------------------#

sql_4 <- function(Posts, Users){
    sqldf("SELECT DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes
            FROM (
            SELECT *
            FROM (
            SELECT COUNT(*) as AnswersNumber, OwnerUserId
            FROM Posts
            WHERE PostTypeId = 2
            GROUP BY OwnerUserId
            ) AS Answers
            JOIN
            (
            SELECT COUNT(*) as QuestionsNumber, OwnerUserId
            FROM Posts
            WHERE PostTypeId = 1
            GROUP BY OwnerUserId
            ) AS Questions
            ON Answers.OwnerUserId = Questions.OwnerUserId
            WHERE AnswersNumber > QuestionsNumber
            ORDER BY AnswersNumber DESC
            LIMIT 5
            ) AS PostsCounts
            JOIN Users
            ON PostsCounts.OwnerUserId = Users.Id")
}

base_4 <- function(Posts, Users){
    # Tworzymy tablice z pytaniami tj. PostTypeId == 1, oraz tablice z odpowiedziami tj. PostTypeId == 2
    postsQuestions <- Posts[Posts[,"PostTypeId"] == 1,]
    postsAnswers <- Posts[Posts[,"PostTypeId"] == 2,]
    
    # W tablicy z użytkownikami wybieramy kolumny Id, DisplayName, Location, Reputation, UpVotes, DownVotes
    usersFiltered <- Users[, c("Id", "DisplayName", "Location", "Reputation", "UpVotes", "DownVotes")]
    
    # Zliczamy liczbę pytań i odpowiedzi dla każdego użytkownika
    questions <- aggregate(PostTypeId ~ OwnerUserId, postsQuestions, length)
    answers <- aggregate(PostTypeId ~ OwnerUserId, postsAnswers, length)

    # Nadajemy nazwy kolumnom
    colnames(questions) <- c("OwnerUserId", "QuestionsNumber")
    colnames(answers) <- c("OwnerUserId", "AnswersNumber")

    # Łączymy tablice według OwnerUserId
    PostsCounts <- merge(questions, answers, by = "OwnerUserId", all = FALSE)
    
    # Filtrujemy według AnswersNumber > QuestionsNumber
    PostsCounts <- PostsCounts[PostsCounts[,"AnswersNumber"] > PostsCounts[,"QuestionsNumber"],]
    
    # Łączymy tablice według Id = OwnerUserId
    final <- merge( usersFiltered, PostsCounts, by.x = "Id", by.y = "OwnerUserId", all = FALSE)
    
    # Wybieramy kolumny DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes
    final <- final[, c("DisplayName", "QuestionsNumber", "AnswersNumber", "Location", "Reputation", "UpVotes", "DownVotes")]
    
    # Sortujemy według AnserwsNumber malejąco
    final <- final[order(final$AnswersNumber, decreasing = TRUE),]
    
    # Wybieramy top5 użytkowników
    final <- final[1:5,]
    
    # Nadajemy numerację wierszom
    rownames(final) <- 1:5
    
    return(final)
}

dplyr_4 <- function(Posts, Users){
    answers <- Posts %>%
        # Wybieramy z Posts odpowiedzi tj. PostTypeId == 2
        filter(PostTypeId == 2) %>%
        
        # Wybieramy kolumnę OwnerUserId
        select(OwnerUserId) %>%
        
        # Grupujemy według OwnerUserId
        group_by(OwnerUserId) %>%
        
        # Dodajemy kolumnę z informacją o ilości odpowiedzi każdego użytkownika
        reframe(AnswersNumber = length(OwnerUserId)) 

    questions <- Posts %>%
        # Wybieramy z Posts pytania tj. PostTypeId == 1
        filter(PostTypeId == 1) %>%
        
        # Wybieramy kolumnę OwnerUserId
        select(OwnerUserId) %>%

        # Grupujemy według OwnerUserId
        group_by(OwnerUserId) %>%

        # Dodajemy kolumnę z informacją o ilości pytań każdego użytkownika
        reframe(QuestionsNumber = length(OwnerUserId))

    # Łączymy tablice Questions i Answers według OwnerUserId
    postsCounts <- left_join(answers, questions, by = "OwnerUserId") %>% 
        
        # Filtrujemy, tak żeby AnswersNumber > QuestionsNumber
        filter(AnswersNumber > QuestionsNumber)

    # Łączymy tablice Users i postsCounts według Id = OwnerUserId
    final <- left_join(Users, postsCounts, by = c("Id" = "OwnerUserId")) %>%
        
        # Wybieramy kolumny DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes
        select(DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes) %>%
        
        # Sortujemy # Sortujemy według AnswersNumber malejąco
        arrange(desc(AnswersNumber)) %>%
        
        # Wybieramy top5 użytkowników
        head(5)

    return(as.data.frame(final))
}

table_4 <- function(Posts, Users){
    answers <- data.table(Posts)
    
    # Wybieramy z Posts odpowiedzi tj. PostTypeId == 2
    answers <- answers[(PostTypeId == 2)]

    # Dodajemy kolumnę z informacją o ilości odpowiedzi każdego użytkownika
    answers <- answers[, .(AnswersNumber = length(PostTypeId)), by = .(OwnerUserId)]

    # Wybieramy kolumnę OwnerUserId i AnswersNumber
    answers <- answers[,.(OwnerUserId, AnswersNumber)]
    
    questions <- data.table(Posts)

    # Wybieramy z Posts pytania tj. PostTypeId == 1
    questions <- questions[(PostTypeId == 1)]

    # Dodajemy kolumnę z informacją o ilości pytań każdego użytkownika
    questions <- questions[, .(QuestionsNumber = length(PostTypeId)), by = .(OwnerUserId)]

    # Wybieramy kolumnę OwnerUserId i QuestionsNumber
    questions <- questions[,.(OwnerUserId, QuestionsNumber)]
    
    # Łączymy tablice Questions i Answers według OwnerUserId
    postsCounts <- na.omit(questions[answers, on = .(OwnerUserId)])
    
    # Filtrujemy, tak żeby AnswersNumber > QuestionsNumber
    postsCounts <- postsCounts[(AnswersNumber > QuestionsNumber)]

    usersFiltered <- data.table(Users)
    
    # Łączymy tablice Users i postsCounts według Id = OwnerUserId
    final <- na.omit(postsCounts[usersFiltered, on = .(OwnerUserId = Id)])
    
    # Wybieramy kolumny DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes
    final <- final[, .(DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes)]
    
    # Sortujemy według AnswersNumber malejąco
    final <- final[order(-AnswersNumber)]
    
    # Wybieramy top5 użytkowników
    final <- head(final, 5)

    return(as.data.frame(final))
}

# Sprawdzenie rownowaznosci wynikow - zakomentuj te czesc przed wyslaniem

# print(all.equal(sql_4(Posts, Users), base_4(Posts, Users)))
# print(all.equal(sql_4(Posts, Users), dplyr_4(Posts, Users)))
# print(all.equal(sql_4(Posts, Users), table_4(Posts, Users)))

# Porowanie czasow wykonania - zakomentuj te czesc przed wyslaniem

# print(microbenchmark(
# sql_call_score=sql_4(Posts, Users),
# base_call_score=base_4(Posts, Users),
# dplyr_call_score=dplyr_4(Posts, Users),
# table_call_score=table_4(Posts, Users),
# times=10
# ))

# -----------------------------------------------------------------------------#
# Zadanie 5
# -----------------------------------------------------------------------------#

sql_5 <- function(Posts, Comments, Users){
         CmtTotScr <- sqldf( 'SELECT PostId, SUM(Score) AS CommentsTotalScore
                                      FROM Comments
                                      GROUP BY PostId' )

     PostsBestComments <- sqldf( 'SELECT Posts.OwnerUserId, Posts.Title, Posts.CommentCount, Posts.ViewCount,
                                CmtTotScr.CommentsTotalScore
                                FROM CmtTotScr
                                JOIN Posts ON Posts.Id = CmtTotScr.PostId
                                WHERE Posts.PostTypeId=1' )
      
      sqldf( 'SELECT Title, CommentCount, ViewCount, CommentsTotalScore, DisplayName, Reputation, Location
                 FROM PostsBestComments
                 JOIN Users ON PostsBestComments.OwnerUserId = Users.Id
                 ORDER BY CommentsTotalScore DESC
                 LIMIT 10' )
}

base_5 <- function(Posts, Comments, Users){
    # Wybieramy interesujące nas kolumny
    postsFiltered <- Posts[, c("Id", "PostTypeId","OwnerUserId", "Title", "CommentCount", "ViewCount")]
    usersFiltered <- Users[, c("Id", "DisplayName", "Reputation", "Location")]
    commentsFiltered <- Comments[,c("PostId", "Score")]

    # Dodajemy kolumnę z informacją o sumie Score dla każdego postu
    commentsScore <- aggregate(Score ~ PostId, commentsFiltered, sum)
    colnames(commentsScore) <- c("PostId", "CommentsTotalScore")

    # Filtrujemy Posts, tak żeby PostTypeId == 1
    postsFiltered <- postsFiltered[postsFiltered[,"PostTypeId"] == 1,]
    
    # Łączymy tablice postsFiltered i commentsScore według Id = PostId
    postsComments <- merge(postsFiltered, commentsScore, by.x = "Id", by.y = "PostId")

    # Łaczymy tablice postsType1 i usersFiltered według OwnerUserId = Id
    postsComUsers <- merge(postsComments, usersFiltered, by.x = "OwnerUserId", by.y = "Id")

    # Wybieramy intersujące nas kolumny
    final <- postsComUsers[,c("Title", "CommentCount", "ViewCount", "CommentsTotalScore", "DisplayName", "Reputation", "Location")]
    
    # Sortujemy według CommentsTotalScore malejąco
    final <- final[order(final$CommentsTotalScore, decreasing = TRUE),]
    
    # Wybieramy top10 
    final <- final[1:10,]
    
    # Nadajemy numerację wierszom
    rownames(final) <- 1:10

    return(final)
}

dplyr_5 <- function(Posts, Comments, Users){
    CmtTotScr <- Comments %>%
        
        # Wybieramy kolumny PostId i Score
        select(PostId, Score) %>%
        
        # Grupujemy według PostId
        group_by(PostId) %>%
        
        # Dodajemy kolumnę z informacją o sumie Score dla każdego PostId
        reframe(CommentsTotalScore = sum(Score))

    PostsBestComments <- Posts %>%
        
        # Filtrujemy Posts, tak że PostTypeId == 1
        filter(PostTypeId == 1) %>%
        
        # Łączymy tablice według Id = PostId
        left_join(CmtTotScr, by = c("Id" = "PostId")) %>%
        
        # Wybieramy intersujące nas kolumny
        select(OwnerUserId, Title, CommentCount, ViewCount, CommentsTotalScore)

    
    # Łączymy tablice według Id = OwnerUserId
    final <- left_join(Users, PostsBestComments, by = c("Id" = "OwnerUserId")) %>%
        
        # Wybieramy intersujące nas kolumny
        select(Title, CommentCount, ViewCount, CommentsTotalScore, DisplayName, Reputation, Location) %>%
        
        # Sortujemy według CommentsTotalScore malejąco
        arrange(desc(CommentsTotalScore)) %>%
        
        #Wybieramy top10
        head(10)

    return(as.data.frame(final))

}

table_5 <- function(Posts, Comments, Users){
    comScore <- data.table(Comments)
    
    # Wybieramy kolumny PostId i Score
    comScore <- comScore[, .(PostId, Score)]
    
    # Zliczamy sume Score dla każdego PostId
    comScore <- comScore[, .(CommentsTotalScore = sum(Score)), by = .(PostId)]
    
    postsBestComments <- data.table(Posts)
    
    # Łączymy tablice według Id = PostId
    postsBestComments <- postsBestComments[comScore, on = .(Id = PostId)]
    
    # Wybieramy intersujące nas kolumny
    postsBestComments <- postsBestComments[, .(OwnerUserId, Title, CommentCount, ViewCount, CommentsTotalScore)]

    final <- data.table(Users)
    
    # Łączymy tablice według Id = OwnerUserId
    final <- na.omit(final[postsBestComments, on = .(Id = OwnerUserId)])
    
    # Wybieramy intersujące nas kolumny
    final <- final[, .(Title, CommentCount, ViewCount, CommentsTotalScore, DisplayName, Reputation, Location)]
    
    # Sortujemy według CommentsTotalScore malejąco
    final <- final[order(-CommentsTotalScore)]
   
    # Wybieramy top10
    final <- head(final, 10)

    return(as.data.frame(final))
}

# Sprawdzenie rownowaznosci wynikow - zakomentuj te czesc przed wyslaniem

# print(all.equal(sql_5(Posts, Comments, Users), base_5(Posts, Comments, Users)))
# print(all.equal(sql_5(Posts, Comments, Users), dplyr_5(Posts, Comments, Users)))
# print(all.equal(sql_5(Posts, Comments, Users), table_5(Posts, Comments, Users)))


# Porowanie czasow wykonania - zakomentuj te czesc przed wyslaniem

# print(microbenchmark(
# sql_call_score=sql_5(Posts, Comments, Users),
# base_call_score=base_5(Posts, Comments, Users),
# dplyr_call_score=dplyr_5(Posts, Comments, Users),
# table_call_score=table_5(Posts, Comments, Users),
# times=10
# ))

