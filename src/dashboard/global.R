library(shiny)
library(shinythemes)
library(ggplot2)
library(tidyverse)
library(readr)
library(ggthemes)
library(plotly)
library(shinydashboard)
library(dashboardthemes)
library(scales)

df = read.csv("https://raw.githubusercontent.com/supertrashpanda/BeautifulBars/main/data/new_long_inc_data.csv",check.names=FALSE)

