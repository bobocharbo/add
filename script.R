### Set the working directory where the unigram, bigram and trigram are stored 
source("generate_ngram.R")



### Set the working directory where the unigram, bigram and trigram are stored 


## Import the datas as unigramDF, bigramDF, trigramDF
for (file in dir('datas/')) load(paste0('datas/',file))

### 3 DataFrames sont disponibles :
  # unigramDF : { unigram : (str), freq : (int) }
  # bigramDF : { bigram : (str), freq : (int), unigram : (str), name : (str) }
  # trigramDF : { trigram : (str), freq : (int), bigram : (str), name : (str) }
 
# Calcul de la probabilité pour un mot

proba_unigramme <- function(mot, bigramme) {
  probs <- sum(bigramme$name==mot)/nrow(bigramme)
  return(probs)
  }

# Calcul des probabilités des unigrammes pour tous les mots du corpus

prob_uni <- sapply(X=unigramDF$unigram, FUN=proba_unigramme, bigramme=bigramDF)
  
# Calcul de la valeur de réduction
  D <- 1/(nrow(unigramDF) + 2 * nrow(bigramDF))
  
# Calcul de la probabilité conditionnelle pour un bigramme
 
proba_condi_bi <- function(w2,w1,prob_uni, bigramme, D){
  w1w2 <- paste(w1,w2)
  somme <- sum(bigramme[bigramme$unigram==w1,'freq'])
  prob_condi <- (max(bigramme[bigramme$bigram==w1w2,'freq']-D,0)/somme) + (D/somme) * sum(bigramme$unigram==w1)*prob_uni[w2]
  return(prob_condi)
}

proba_condi_tri <- function(w3,w2,w1,trigramme,bigramme,D,prob_uni){
  w1w2 <- paste(w1,w2)
  w1w2w3 <- paste(w1w2,w3)
  
  # Somme des fréquences d'apparition des trigrammes commençant par w1w2 
  sum_freq <- sum(trigramme[trigramme$bigram==w1w2,'freq'])
  prob_condi <- (max(trigramme[trigramme$trigram==w1w2w3,'freq'] - D,0) / sum_freq) + (D/sum_freq) * sum(trigramme$bigram==w1w2) * proba_condi_bi(w3,w2,prob_uni,bigramme,D)
  return(prob_condi)
}

#Prédiction du mot suivant avec des bigrammes
predict_big <- function(w1,prob_uni, bigramme, unigramme, D){
  probs <- sapply(unigramme$unigram, FUN=proba_condi_bi, w1=w1, prob_uni=prob_uni, bigramme=bigramme, D=D, USE.NAMES = F)
  return(head(sort(probs, decreasing=T)))
}

predict_tri <- function(w1,w2,trigramme,bigramme,unigramme,D,prob_uni){
  probs <- sapply(unigramme$unigram, FUN=proba_condi_tri,w1=w1, w2=w2, prob_uni=prob_uni, trigramme=trigramme, bigramme=bigramme,D=D, USE.NAMES = F)
  return(head(sort(probs,decreasing=T)))
}

# Génération d'une phrase avec des bigrammes
predict_sentence_bi <- function(n,first_words, last_words, bigramme, unigramme, prob_uni, D){

  mot <- sample(x = first_words, size=1)
  print(mot)
  sentence <- NULL
  i <- 0
  while (!(mot %in% last_words) & i < n){
    ### MONITORING ####
    ptm0 <- proc.time()
    Sys.sleep(0.5)  
    ###################
    sentence <- c(sentence, mot)
    mot <- names(predict_big(mot, prob_uni, bigramme, unigramme, D))[1]
    i <- i+1
    
    ### MONITORING ###
    ptm1=proc.time() - ptm0
    jnk=as.numeric(ptm1[3])
    cat('\n','It took ', jnk, "seconds to do iteration", i,'\n','\n',mot,'\n')
    ### MONITORING ###
  }
  return(sentence)
}

#predict_sentence_tri <- function()

# Calcul de la probabilité conditionnelle pour un trigramme
 

