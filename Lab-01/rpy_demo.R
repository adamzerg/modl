

install.packages("reticulate")
library(reticulate)
py_available()
py_config()
py_install("pandas")

py_install("scipy")
scipy <- import("scipy")
scipy$amin(c(11,23,456,7))

source_python("legs.py")
legs_sample()
