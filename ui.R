# ui.R
library(shiny)

# List of Nifty 50 companies and their symbols (as used by Yahoo Finance)
nifty_50_companies <- c(
  "Adani Enterprises" = "ADANIENT.NS",
  "Adani Ports" = "ADANIPORTS.NS",
  "Apollo Hospitals" = "APOLLOHOSP.NS",
  "Asian Paints" = "ASIANPAINT.NS",
  "Axis Bank" = "AXISBANK.NS",
  "Bajaj Auto" = "BAJ-AUTO.NS",
  "Bajaj Finance" = "BAJFINANCE.NS",
  "Bajaj Finserv" = "BAJFINSV.NS",
  "Bharti Airtel" = "BHARTIARTL.NS",
  "BPCL" = "BPCL.NS",
  "Britannia Industries" = "BRITANNIA.NS",
  "Cipla" = "CIPLA.NS",
  "Coal India" = "COALINDIA.NS",
  "Divi's Laboratories" = "DIVISLAB.NS",
  "Dr. Reddy's Laboratories" = "DRREDDY.NS",
  "Eicher Motors" = "EICHERMOT.NS",
  "GAIL (India)" = "GAIL.NS",
  "Grasim Industries" = "GRASIM.NS",
  "HCL Technologies" = "HCLTECH.NS",
  "HDFC Life" = "HDFCLIFE.NS",
  "HDFC Bank" = "HDFCBANK.NS",
  "Hero MotoCorp" = "HEROMOTOCO.NS",
  "Hindalco Industries" = "HINDALCO.NS",
  "Hindustan Unilever" = "HINDUNILVR.NS",
  "ICICI Bank" = "ICICIBANK.NS",
  "IndusInd Bank" = "INDUSINDBK.NS",
  "Infosys" = "INFY.NS",
  "ITC" = "ITC.NS",
  "JSW Steel" = "JSWSTEEL.NS",
  "Kotak Mahindra Bank" = "KOTAKBANK.NS",
  "Larsen & Toubro" = "LT.NS",
  "Mahindra & Mahindra" = "M&M.NS",
  "Maruti Suzuki" = "MARUTI.NS",
  "NTPC" = "NTPC.NS",
  "Nestle India" = "NESTLEIND.NS",
  "Oil & Natural Gas Corporation" = "ONGC.NS",
  "Power Grid Corporation of India" = "POWERGRID.NS",
  "Reliance Industries" = "RELIANCE.NS",
  "SBI Life Insurance Company" = "SBILIFE.NS",
  "State Bank of India" = "SBIN.NS",
  "Sun Pharmaceutical Industries" = "SUNPHARMA.NS",
  "Tata Consultancy Services" = "TCS.NS",
  "Tata Consumer Products" = "TATACONSUM.NS",
  "Tata Motors" = "TATAMOTORS.NS",
  "Tata Steel" = "TATASTEEL.NS",
  "Tech Mahindra" = "TECHM.NS",
  "Titan Company" = "TITAN.NS",
  "UltraTech Cement" = "ULTRACEMCO.NS",
  "Wipro" = "WIPRO.NS"
)

ui <- fluidPage(
  titlePanel("Nifty 50 Stock Data"),
  sidebarLayout(
    sidebarPanel(
      selectInput("stock", "Select Stock:",
                  choices = nifty_50_companies,
                  selectize = TRUE),
      dateRangeInput("dates", "Select Date Range:",
                     start = Sys.Date() - 365,
                     end = Sys.Date()),
      actionButton("fetch", "Fetch Data")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Stock Data", DTOutput("stock_table")),
        tabPanel("Stock Plot", plotOutput("stock_plot")),
        tabPanel("Stock vs Nifty", plotOutput("comparison_plot")),
        tabPanel("Daily Change", DTOutput("daily_change_table"))
      )
    )
  )
)
