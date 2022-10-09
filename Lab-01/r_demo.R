swirl::install_course("The R Programming Environment")

## Entering Input, `<-` symbol is the assignment operator.
x <- 1  ## nothing printed
x       ## auto-printing occurs

x <- 1:20 ## The `:` operator is used to create integer sequences.
x

## Creating Vectors
x <- c(0.5, 0.6)       ## numeric
x <- c(TRUE, FALSE)    ## logical
x <- c(T, F)           ## logical
x <- c("a", "b", "c")  ## character
x <- 9:29              ## integer
x <- c(1+0i, 2+4i)     ## complex

## Mixing Objects
y <- c(1.7, "a")   ## character
y <- c(TRUE, 2)    ## numeric
y <- c("a", TRUE)  ## character

## Matrices
m <- matrix(1:6, nrow = 2, ncol = 3)
m

## Matrices created directly from vectors
m <- 1:10 
m
dim(m) <- c(2, 5)
m

## column-binding or row-binding
x <- 1:3
y <- 10:12
cbind(x, y)
rbind(x, y)

## Lists are a special type of vector that can contain elements of different classes.
x <- list(1, "a", TRUE, 1 + 4i)
x

## Missing values, `NaN` value is also `NA` but the converse is not true
x <- c(1, 2, NaN, NA, 4)
is.na(x)
is.nan(x)

## Data Frames

x <- data.frame(foo = 1:4, bar = c(T, T, F, F))
x

## Assign names to list
x <- 1:3
names(x)
names(x) <- c("foo", "bar", "norf")
names(x)