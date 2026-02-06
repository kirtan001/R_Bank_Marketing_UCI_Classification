FROM rocker/r-ver:4.3.1

# 1. System Dependencies (Cached Layer)
# These rarely change.
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. R Packages (Cached Layer - Binary from PPM)
# We add 'tidyverse' explicitly as requested.
# Using a fixed date or specific snapshot could make this even more robust, 
# but 'latest' for Jammy is fine for this context.
RUN R -e "install.packages(c('tidyverse', 'shiny', 'bslib', 'jsonlite', 'plumber', 'tidymodels', 'ranger', 'xgboost', 'themis', 'rmarkdown', 'yardstick', 'vip'), repos='https://packagemanager.posit.co/cran/__linux__/jammy/latest')"

# 3. Copy Application Code (Changes Frequently)
# This is done LAST so that changes to app.R don't trigger a reinstall of packages.
COPY . /app
WORKDIR /app

# 4. Expose Port & Define Entrypoint
EXPOSE 7860
CMD ["R", "-e", "shiny::runApp('src/app.R', host = '0.0.0.0', port = 7860)"]
