rwsim <- function(tau,P,Q=rep(.5,2),V=.25,t0=0) {
  
  # C <- vector()
  out <- vector()
  G <- 1
  
  beta <- 4
  alpha <- .6
  for (t in 1:120) {
    
    if (t %% P == 1) G <- ifelse(G == 1, 2, 1)
    
    p <- plogis(beta*(Q[2] - Q[1]))
    C <- rbinom(1,1,p) + 1
    R <- ifelse(C == G, rbinom(1,1,.8), rbinom(1,1,.2))
    
    delta <- R - Q[C]
    Q[C] <- Q[C] + alpha * delta
    V <- V + tau/(1+.1*(t+t0)) * (delta^2 - V)
    out[t] <- V
  }
  
  return(out)
}

transfersim <- function(tau,P) {
  V1 <- rwsim(tau,P)
  V2 <- rwsim(tau,20,V=V1[length(V1)],t0=120)
  return(c(V1,V2))
}

tau <- 0.1
foo <- data.table(PE2=c(sapply(1:500,function(x) transfersim(tau,10)) |> rowMeans(),
                        sapply(1:500,function(x) transfersim(tau,30)) |> rowMeans()),
                  volatility=rep(c("high","low"),each=240),t=rep(1:240,2))
ggplot(foo,aes(y=PE2,x=t,color=volatility)) + geom_line() + ylab("learned volatility (a.u.)") + xlab("trial") + theme_classic()

qplot(x=1:240,y=(sapply(1:500,function(x) transfersim(0.3,10)) |> rowMeans()),geom="line")
