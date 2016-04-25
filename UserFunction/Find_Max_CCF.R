
#Source with explanation http://r.789695.n4.nabble.com/ccf-function-td2288257.html

Find_Max_CCF <- function(a, b,lag.max=NULL)
{
    #crosscorrelation
    d <- ccf(a, b, type="correlation",plot=F, lag.max =lag.max,na.action=na.pass)
    #type "covariance" if you want to find out if two variables range in the same relativ amount 
    
    # Extract autocorrelation and lag
    cor = d$acf[, , 1]
    lag = d$lag[, , 1]
    res = data.frame(cor,lag)
    
    # Give Lag with best correlation
    res_max = res[which.max(abs(res$cor)),]
    
    return(res_max)
} 
