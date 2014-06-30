tpl
===

This R package includes functions to query the latest version of The Plant List database alongside with a shiny web application as an alternative front end.

To install the package, first you need devtools:

```
install.packages("devtools")
library("devtools")
```

Then, install tpldata (this is a 50 Mb download):

```
install_github("gustavobio/tpldata")
```

You will also need the development version of fastmatch:

```
install_github("s-u/fastmatch")
```

Finally, install flora and tpl:

```
install_github("gustavobio/flora")
install_github("gustavobio/tpl")
```

The main function is `tpl.get` (the first call builds the hash table for fastmatch, so it takes a while. Following calls are much faster):

```
tpl.get(c("Miconia albicans", "Myrcia lingua")
```

There is also a web app (same applies, first calls build the hash tables):

```
web.tpl()
```
