# server.R

library(shiny)
library(quantmod)
library(DT)
library(lubridate)
library(dplyr)

function(input, output, session) {

  # Fetch stock data when the "Fetch Data" button is clicked
  stock_data <- eventReactive(input$fetch, {
    req(input$stock, input$dates)
    tryCatch({
      getSymbols(input$stock, from = input$dates[1], to = input$dates[2], auto.assign = FALSE)
    }, error = function(e) {
      showNotification(paste("Error fetching data:", e$message), type = "error")
      NULL
    })
  })

  # Fetch Nifty 50 index data when the "Fetch Data" button is clicked
  nifty_data <- eventReactive(input$fetch, {
    req(input$dates)
    tryCatch({
      getSymbols("^NSEI", from = input$dates[1], to = input$dates[2], auto.assign = FALSE)
    }, error = function(e) {
      showNotification(paste("Error fetching Nifty data:", e$message), type = "error")
      NULL
    })
  })

  # Render the stock data table
  output$stock_table <- renderDT({
    req(stock_data())
    data <- stock_data()
    if (nrow(data) > 0) {
      df <- data.frame(Date = index(data), coredata(data))
      colnames(df) <- gsub(paste0(gsub(".NS", "", input$stock), "\\."), "", colnames(df))
      df <- df %>% mutate_if(is.numeric, ~round(., 2))
      datatable(df)
    } else {
      datatable(data.frame(Message = "No data available for the selected range."))
    }
  })

  # Render the stock price plot using quantmod's chartSeries
  output$stock_plot <- renderPlot({
    req(stock_data())
    data <- stock_data()
    if (nrow(data) > 0) {
      chartSeries(data)
    }
  })

  # Render the comparison plot with secondary axis
  output$comparison_plot <- renderPlot({
    req(stock_data(), nifty_data())

    # Ensure data is not NULL and has rows
    if (is.null(stock_data()) || nrow(stock_data()) == 0 ||
        is.null(nifty_data()) || nrow(nifty_data()) == 0) {
      plot.new()
      text(0.5, 0.5, "No data available for comparison", cex = 1.5)
      return(NULL)
    }

    # Subset with correct column names
    stock <- stock_data()[, paste0(input$stock, ".Close")]
    nifty <- nifty_data()[, "NSEI.Close"]

    # Convert xts to data frames
    stock_df <- data.frame(Date = index(stock), Close = as.numeric(coredata(stock)))
    nifty_df <- data.frame(Date = index(nifty), Close = as.numeric(coredata(nifty)))

    # Ensure dates align by merging on common dates
    merged_df <- merge(stock_df, nifty_df, by = "Date", all = FALSE)
    if (nrow(merged_df) == 0) {
      plot.new()
      text(0.5, 0.5, "No overlapping dates for comparison", cex = 1.5)
      return(NULL)
    }

    # Plot with secondary axis
    par(mar = c(5, 4, 4, 4) + 0.1) # Adjust margins for secondary axis
    plot(merged_df$Date, merged_df$Close.y, type = "l", col = "red",
         xlab = "Date", ylab = "Nifty 50 Closing Price (Index)",
         main = paste(gsub(".NS", "", input$stock), "vs. Nifty 50"),
         ylim = range(merged_df$Close.y, na.rm = TRUE))
    par(new = TRUE)
    plot(merged_df$Date, merged_df$Close.x, type = "l", col = "blue",
         axes = FALSE, xlab = "", ylab = "",
         ylim = range(merged_df$Close.x, na.rm = TRUE))
    axis(side = 4, at = pretty(range(merged_df$Close.x, na.rm = TRUE))) # Right Y-axis
    mtext("Stock Closing Price (INR)", side = 4, line = 3) # Label for right Y-axis
    legend("topleft", legend = c(gsub(".NS", "", input$stock), "Nifty 50"),
           col = c("blue", "red"), lty = 1)
  })

  # Reactive expression to get the daily change for all Nifty 50 stocks
  daily_change_data <- eventReactive(input$fetch, {
    all_company_data <- list()
    for (symbol in nifty_50_companies) {
      tryCatch({
        data <- getSymbols(symbol, from = Sys.Date() - 5, to = Sys.Date(), auto.assign = FALSE)
        if (!is.null(data) && nrow(data) >= 2) {
          current_close <- Cl(data)[nrow(data)]
          previous_close <- Cl(data)[nrow(data) - 1]
          change <- current_close - previous_close
          change_percent <- (change / previous_close) * 100
          company_name <- names(nifty_50_companies)[nifty_50_companies == symbol]
          all_company_data[[company_name]] <- data.frame(
            Company = company_name,
            Previous_Close = as.numeric(previous_close),
            Current_Close = as.numeric(current_close),
            Change = as.numeric(change),
            Change_Percent = round(as.numeric(change_percent), 2)
          )
        } else {
          company_name <- names(nifty_50_companies)[nifty_50_companies == symbol]
          all_company_data[[company_name]] <- data.frame(
            Company = company_name,
            Previous_Close = NA,
            Current_Close = NA,
            Change = NA,
            Change_Percent = NA,
            Message = "Not enough data"
          )
        }
      }, error = function(e) {
        company_name <- names(nifty_50_companies)[nifty_50_companies == symbol]
        all_company_data[[company_name]] <- data.frame(
          Company = company_name,
          Previous_Close = NA,
          Current_Close = NA,
          Change = NA,
          Change_Percent = NA,
          Error = paste("Error fetching data:", e$message)
        )
      })
    }
    bind_rows(all_company_data)
  })

  # Render the daily change data table
  output$daily_change_table <- renderDT({
    daily_data <- daily_change_data()
    if (!is.null(daily_data) && nrow(daily_data) > 0) {
      datatable(daily_data, options = list(pageLength = 50)) %>%
        formatStyle(
          'Change',
          backgroundColor = styleInterval(0, c('red', 'lightgreen'))
        )
    } else {
      datatable(data.frame(Message = "Daily change data not available."))
    }
  })
}
