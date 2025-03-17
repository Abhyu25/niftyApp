# dependencies.R

# List of required packages
required_packages <- c("shiny", "quantmod", "DT", "lubridate", "dplyr")

# Function to check if a package is installed
is_installed <- function(pkg){
  is.element(pkg, installed.packages()[,1])
}

# Install missing packages
for (pkg in required_packages){
  if (!is_installed(pkg)){
    print(paste("Installing package:", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# Load required packages
for (pkg in required_packages){
  library(pkg)
}
