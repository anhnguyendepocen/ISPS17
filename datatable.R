##### R-Script for data.table introduction
##### Gerhard Nachtmann
##### 20170613

### data.table example
library(data.table)
library(microbenchmark)

data(iris)
head(iris)
str(iris)
class(iris)

## create data.table object
idt <- as.data.table(iris)
idt
class(idt)

### output
getwd()
fwrite(idt, "iris.csv")
idtcsv <- fread("iris.csv", stringsAsFactors = TRUE)
head(idtcsv)
all.equal(idt, idtcsv)
class(idtcsv)
class(as.data.frame(idtcsv))

idt1 <- copy(idt)
idt2 <- idt1
names(idt2)
idt2[, Species := NULL]
head(idt2)
head(idt1) # also removed here
head(idt)

## values in inch
idt[, .SD / 2.54, .SDcols = setdiff(names(idt), "Species")]

### https://stackoverflow.com/questions/31326691/apply-function-across-subset-of-columns-in-data-table-with-sdcols
idt1 <- copy(idt)
valcols <- setdiff(names(idt1), "Species")
idt1[, (valcols) := (.SD / 2.54), .SDcols = valcols]
head(idt1)
idt1 <- copy(idt)
paste(valcols, "inch", sep = "_")
idt1[, (paste(valcols, "inch", sep = "_")) :=
       (.SD / 2.54), .SDcols = valcols]
head(idt1)
str(idt1)

## some counting
idt[, .N, by = Species]
idt[, .N]

idt$Species
## data.frame style
idt$val <- rnorm(nrow(idt))
idt

## data.table style
idt[, group := rep(letters[1:5], each = 30)]
idt
## "-" means decreasing order
setorder(idt, Sepal.Length, -Sepal.Width)
idt

## data.frame style
idt[idt$group == "d", ]

## data.table style
idt[J("d"), on = "group"]

### change d to x
idt[J("d"), group := "x", on = "group"]
idt
str(idt)
idt[J("d"), on = "group"]
idt["x", on = "group"]

setindex(idt, group) # not necessary
indices(idt)

## binary search in data.table should be faster for large
## datasets but is slower here :-(
microbenchmark(df = idt[idt$group == "d", ],
               dt = idt["d", on = "group"])

setkey(idt, Species)
idt
## after setting key -- physical sorting
idt[!J("setosa"), ]

## add mean by species to original dataset
idt[, gm := mean(Sepal.Length), by = Species]
idt

idt1[, lapply(.SD, mean), .SDcols = valcols]
idt1[, lapply(.SD, mean), .SDcols = valcols, by = Species]

## base R
with(iris, aggregate(Sepal.Length, by = list(Species), mean))

## create new object containing just the species means
idtm <- idt[, list(gm = mean(Sepal.Length)),
            by = Species]
idtm

microbenchmark(df = with(iris, aggregate(Sepal.Length,
                                         by = list(Species),
                                         mean)),
               dt = idt[, list(gm = mean(Sepal.Length)),
                        by = Species])

## the same for species and group
## .() is an abbreviation for list() in data.table
idt1 <- idt[, list(gm = mean(Sepal.Length)),
      by = .(Species, group)]
idt1

idt[, list(gm = mean(Sepal.Length)), keyby = .(Species, group)]

## without name
idt[,  mean(Sepal.Length), keyby = .(Species, group)]

## show species mean ans species sum
idt[, list(gm = mean(Sepal.Length),
           gs = sum(Sepal.Length)),
    by = Species]

## add various variables
idt[, c("vat2", "sth") := .(runif(150), rnorm(150))]
idt

## remove it again
idt[, c("vat2", "sth") := NULL]
idt

##### questions
sp1 <- data.table(Species = unique(idt$Species), specid = 1:3,
                  key = "Species")
sp1
key(sp1)
key(idt)
stopifnot(key(sp1) == key(idt))

idt[sp1]

### assign it
idt[sp1, specid := specid, on = key(sp1)]

