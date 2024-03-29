#Prepare FASTA file out of named vector of sequences
MakeFasta=function(SeqDF,NameFile){
  for (i in 1:length(SeqDF)) {
    write(paste(">",names(SeqDF[i]),"\n",SeqDF[i],sep = ""),NameFile,append = TRUE)
  }
}

#Find all windows across all sequences in a named vector of sequences
FindWindows=function(SeqDF,Window=5){
  AllSeqWindows=list()
  for (j in 1:length(SeqDF)) {
    CurrentSequence=SeqDF[j]
    PartitionedSeq=character()
    for (i in 1:(nchar(CurrentSequence)-Window+1)) {
      PartitionedSeq[i]=substring(CurrentSequence,i,(i+Window-1))
    }
    AllSeqWindows[[names(SeqDF[j])]]=PartitionedSeq
  }
  unlist(AllSeqWindows)
}

#Create list with all unique windows across all sequences in a named vector of sequences
FindWindowsV2=function(SeqDF,Window=5){
  AllSeqWindows=list()
  for (j in 1:length(SeqDF)) {
    CurrentSequence=SeqDF[j]
    PartitionedSeq=character()
    for (i in 1:(nchar(CurrentSequence)-Window+1)) {
      PartitionedSeq[i]=substring(CurrentSequence,i,(i+Window-1))
    }
    AllSeqWindows[[names(SeqDF[j])]]=unique(PartitionedSeq)
  }
  AllSeqWindows
}

#Machine Learning split into 5 equal live% subsets
run_5ml <- function(lib, my_lambda = 10^seq(-6, 3, length = 50)){
  set.seed(777)
  live <- lib %>% filter(binary_stop == 'live')
  die <- lib %>% filter(binary_stop == 'die')
  live_size <- round(nrow(live) * 0.2)
  ro <- sample(1:nrow(live), live_size)
  live1 <- live[ro,]
  live <- live[-ro,]
  ro <- sample(1:nrow(live), live_size)
  live2 <- live[ro,]
  live <- live[-ro,]
  ro <- sample(1:nrow(live), live_size)
  live3 <- live[ro,]
  live <- live[-ro,]
  ro <- sample(1:nrow(live), live_size)
  live4 <- live[ro,]
  live <- live[-ro,]
  live5 <- live
  die_size <- round(nrow(die) * 0.2)
  ro <- sample(1:nrow(die), die_size + 1)
  die1 <- die[ro,]
  die <- die[-ro,]
  ro <- sample(1:nrow(die), die_size)
  die2 <- die[ro,]
  die <- die[-ro,]
  ro <- sample(1:nrow(die), die_size)
  die3 <- die[ro,]
  die <- die[-ro,]
  ro <- sample(1:nrow(die), die_size)
  die4 <- die[ro,]
  die <- die[-ro,]
  die5 <- die
  MLset1 <- rbind(live1,die1)
  MLset2 <- rbind(live2,die2)
  MLset3 <- rbind(live3,die3)
  MLset4 <- rbind(live4,die4)
  MLset5 <- rbind(live5,die5)
  #For each ML, train on 4 and test on 1. Loop through all 5 training/testing combinations
  MLsets <- c('MLset1','MLset2','MLset3','MLset4','MLset5')
  auc_list <- c()
  for(i in 1:5){
    test_set <- get(MLsets[i])
    x <- which(1:5 != i)
    y1 <- get(MLsets[x[1]])
    y2 <- get(MLsets[x[2]])
    y3 <- get(MLsets[x[3]])
    y4 <- get(MLsets[x[4]])
    train_set <- rbind(y1,y2,y3,y4)
    ridge <- train(binary_stop ~., data = train_set, method = "glmnet",
                   tuneGrid = expand.grid(alpha = 0, lambda = my_lambda))
    # Get ROC curve AUC results
    predicted_prob <- predict.train(ridge, test_set,type = "prob") 
    myroc <- roc(test_set$binary_stop, predicted_prob$die)
    auc <- myroc$auc %>% as.numeric() %>% round(3)
    auc <- ifelse(auc < 0.5, 1 - auc, auc)
    auc_list <- c(auc, auc_list)
  }
  return(auc_list)
}

#Find max cluster size for each sequence using sapply(SequenceVector, Clustering, Res="L")
Clustering <- function(Seq,Res) {
  CL=0
  CC=0
  for (i in 1:nchar(Seq)) {
    if (i==nchar(Seq) & substr(Seq,i,i)==Res) {
      CC=CC+1
      if (CC>CL) {
        CL=CC
      }
    } else if (substr(Seq,i,i)==Res) {
      CC=CC+1
    } else if (substr(Seq,i,i)!=Res & CC>CL) {
      CL=CC
      CC=0
    } else {
      CC=0
    }
  }
  CL
}

