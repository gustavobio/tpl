tpl
===

This R package includes functions to query the latest version of The Plant List database alongside with a shiny web application as an alternative front end.

## Developer

+ [Gustavo Carvalho](https://github.com/gustavobio)

## Data

All data from The Plant List are included in [tpldata](http://github.com/gustavobio/tpldata). Please cite [The Plant List](http://www.theplantlist.org) accordingly.

## Instalation

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

```coffee
install_github("gustavobio/tpl")
```

## Usage

The main function is `tpl.get` (the first call builds the hash table for fastmatch, so it takes a while. Following calls are much faster):

```coffee
library(tpl)
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

## Web application

There is a web application included where one can simply paste names into a textbox and get taxonomic information, links to the original data source, search within the results and export to a csv file.

```
web.tpl()
```
*Click the screenshot for a larger view*
![](http://i.imgur.com/Kjbb9nx.png)