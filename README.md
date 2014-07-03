tpl
===

This R package includes functions to query the latest version of The Plant List database alongside with a shiny web application as an alternative front end.

## Developer

+ [Gustavo Carvalho](https://github.com/gustavobio)

## Data

All data from The Plant List are included in [tpldata](http://github.com/gustavobio/tpldata). Please cite [The Plant List](http://www.theplantlist.org) accordingly. The data included in the package come from csv files they make available on their website.

## Installation

#### Install devtools and shiny

```coffee
install.packages("devtools")
install.packages("shiny")
library("devtools")
```

#### Install tpldata (this is a 50 Mb download)

```coffee
install_github("gustavobio/tpldata")
```

#### Install tpl

*Since `tpl` depends on `tpldata`, which is very large, it is likely that `tpl` will not be published on CRAN.*

```coffee
install_github("gustavobio/tpl")
```

## Usage

The main function is `tpl.get`, which will fix misspelled names, replace synonyms for accepted taxa, and return a data frame with taxonomic information:

```coffee
library(tpl)
### First calls are a bit slow, but the following ones are substantially faster.
tpl.get(c("Miconia albicans", "Myrcia lingua", "Cofea arabica"))
```

```coffee
            id          family   genus    species infraspecific.rank infraspecific.epithet   authorship taxonomic.status.in.tpl confidence.level source
1 tro-20300135 Melastomataceae Miconia   albicans                                          (Sw.) Steud.                Accepted                M    TRO
2   kew-131274       Myrtaceae  Myrcia guianensis                                           (Aubl.) DC.                Accepted                H   WCSP
3    kew-45400       Rubiaceae  Coffea    arabica                                                    L.                Accepted                H   WCSP
  accepted.id              name             note  original.search
1              Miconia albicans                  Miconia albicans
2             Myrcia guianensis replaced synonym    Myrcia lingua
3                Coffea arabica   was misspelled    Cofea arabica
```

There are a few arguments to `tpl.get`, including `replace.synonyms`, `suggest.names`, and `drop`:

```coffee
tpl.get(c("Miconia albicans", "Myrcia lingua", "Cofea arabica"), replace.synonyms = F, suggest.names = F)
```

```coffee
            id          family   genus  species infraspecific.rank infraspecific.epithet   authorship taxonomic.status.in.tpl confidence.level source accepted.id             name
1 tro-20300135 Melastomataceae Miconia albicans                                          (Sw.) Steud.                Accepted                M    TRO             Miconia albicans
2         <NA>            <NA>    <NA>     <NA>               <NA>                  <NA>         <NA>                    <NA>             <NA>   <NA>        <NA>             <NA>
3         <NA>            <NA>    <NA>     <NA>               <NA>                  <NA>         <NA>                    <NA>             <NA>   <NA>        <NA>             <NA>
              note  original.search
1                  Miconia albicans
2 check +1 entries    Myrcia lingua
3        not found    Cofea arabica
```

Other functions include `noauthors`, to remove authors from names, `suggest.names`, to get name suggestions, and `trim` and `fixCase` to fix casing and duplicate whitespaces.

```coffee
sp <- trim("Miconia albicans                                          (Sw.) Steud.")
sp
[1] "Miconia albicans (Sw.) Steud."
```
```coffee
noauthors(sp)
[1] "Miconia albicans"
```

## Web application

There is a web application included where one can simply paste names into a textbox and get taxonomic information, links to the original data source, search within the results and export to a csv file.

```
web.tpl()
```
*Click on the screenshot for an expanded view*
![](http://i.imgur.com/Kjbb9nx.png)