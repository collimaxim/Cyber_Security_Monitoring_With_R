
#  cysirs  is the Cyber Security Incident Response System
#  This project will develop a wide varity of skills complimentary to data science engineering toolkit
#
#  Pull in computer statistics data into R,  store the data into a database, 
#  display the data in a web app 
#  and deliver reporting analytics dashboard with actionable intfomation 
# 
#   Step 1 - Gather the data ( what are the objectives and purpose of the application )
#   Step 2 - create repository to store data and retrieve historical data
#   Step 3 - build web frontend to deliver the data to users
# Note: Must run as Rstudio as administrator for security log reading


# ****  Step 1  ****

#  Computer info
#  Netstat info
#  Active processes info
#  Installed Apps info
#  Event Log key alerts
#  Common Vulnerability Exploit cross validation with installed apps and processes
#   ( this brings up a comparision matching algorithm based on percentage of a matching set of strings, if there is 
#  an 85 % match on a given  CVE and a process running locally then flag it for investigation...
#   Research that matching algorith  )


# load the library packages
library(sqldf)
library(dplyr)
library(data.table)
library(zoo)

library(stringr)

library(stringi)
library(tidyr)
# install.packages("devtools")
library(devtools)



# Set the working Directory
setwd("C:/mydata/cysirs/Cyber_Security_Monitoring_With_R")

# run a shell command / vb script 
shell("cscript cyberup_Computer_Installed_Apps.vbs")

# read in tab delimited txt doc...
Comp_installed_apps <-  read.csv("run/Computer_Installed_Apps.txt", header= FALSE, sep= "\t")

# assign column names
colnames(Comp_installed_apps) <- c("computer_name", "app_name", "publisher", "installed_date", "size", "version")
View(Comp_installed_apps)

# make data table of cia dataset
cia <- data.table(Comp_installed_apps)
# create dataset of publisher and total size
cia_size <- cia %>%
    group_by(publisher) %>%
  summarise(tot_size  = sum(size)
  )%>%
  filter( !is.na(tot_size))%>% 
  arrange(desc(tot_size))
View(cia_size)
str(cia_size)

#  get rid  of the scientific notation with scientific=FALSE
ggplot(subset(cia_size, format(cia_size$tot_size, scientific=FALSE) > '1100000'),  aes(x = publisher, y = format(tot_size, scientific=FALSE), color=publisher))+
  geom_point( aes(size= tot_size))+
  ylab("Size in bytes") +
  theme(axis.text.x = element_text(angle=60, hjust=1, size = 8)) + ggtitle("Largest Apps Installed")





# network computer assets
# only one for sole computer 
shell("cscript network_computers_assets.vbs")
network_comp_assets <- read.csv("run/Network_computer_assets.txt", header = TRUE, sep="\t")

colnames(network_comp_assets) <- c("domain_name",	"computer_name",	"user_name",	"dns_host_name"	, "computer_role",	"manufacturer",	"model",	"admin_password_status", "computer_system_type")

View(network_comp_assets)



#######

# NESTAT Info
ac2 <- ""

shell("NETSTAT -a-b-f-n-o-r-s > tcp_ip.txt' ")
shell("NETSTAT -s > tcp_ip.txt" )

# working    nestat - a
system('powershell -command $a = netstat -a ; $a[3..$a.count] | ConvertFrom-String | select p2,p3,p4,p5 | Export-CSv  active_conn.csv', intern=TRUE)
# next pull in data with Import Dataset button

# netstat - s  TCP IP statistics   0  will need additional data tidying for this data
system('powershell -command $s = netstat -s ; $s > tcp_ip.txt' )

??read 

# due to error In read.table(file = file, header = header, sep = sep, quote = quote,  :
# line 5 appears to contain embedded nulls I added the fileEncoding="UCS-2LE" and it worked fine
nstat_s <- read.delim("tcp_ip.txt", header = FALSE, strip.white = TRUE, fileEncoding="UCS-2LE")


 
 
# give column name
colnames(nstat_s) <-  c("stat")




# select detected macthes
# con1$stat[str_detect(con1$stat, "=")]

# use tidy separate to split the strings into 2 columns
nstat_s <- separate(data = nstat_s, col = stat, into = c("stat_name", "stat_val"), sep = "=")

# remove extra (leading/trailing) white space with str_trim
# nstat_s <- str_trim(nstat_s$stat_name, side = "both")
# nstat_s <- str_trim(nstat_s$stat_val, side = "both")

# convert to data table
nstat_s <- data.table(nstat_s)

# use sqldf to update the stat_val column with the names of the IP groupings
# ?sqldf
nstat_s <- sqldf("select stat_name, case when  stat_name = 'IPv4 Statistics' then 'IPv4 Statistics' 
                    when stat_name = 'TCP Statistics for IPv4' then 'TCP Statistics for IPv4'
               when stat_name = 'UDP Statistics for IPv4' then 'UDP Statistics for IPv4'
               when stat_name = 'IPv6 Statistics' then 'IPv6 Statistics'
               when stat_name = 'TCP Statistics for IPv6' then 'TCP Statistics for IPv6'
               when stat_name = 'UDP Statistics for IPv6' then 'UDP Statistics for IPv6'
               else stat_val end as stat_val from nstat_s")

# pull only data that have stat_vals or group heading
nstat_s  <- sqldf("select * from nstat_s where stat_val is not null")
View(nstat_s)
 
# assign a group name based on row ids  for the stat_grp column
 # "IPv4 Statistics"
for (i in 1:18){
  nstat_s[i,3] <- "IPv4 Statistics"
  print(i)
}
  
 
#  "IPv6 Statistics"
  
  for (j in 19:36){
    nstat_s[j,3] <- "IPv6 Statistics"
    print(j)
  }
  
  
#  "TCP Statistics for IPv4"
  for (n in 37:45){
    nstat_s[n,3] <- "TCP Statistics for IPv4"
    print(n)
     }

 
#  "TCP Statistics for IPv6"
  for (a in 46:54){
    nstat_s[a,3] <- "TCP Statistics for IPv6"
    print(a)
  }
  
   
#  "UDP Statistics for IPv4"
  for (b in 55:59){
    nstat_s[b,3] <- "UDP Statistics for IPv4"
    print(b)
  }
  
  
  
#  "UDP Statistics for IPv6"
  for (v in 60:64){
    nstat_s[v,3] <- "UDP Statistics for IPv6"
    print(v)
  }
  
# rename the new V3 column to stat_grp
colnames(nstat_s) <- c("stat_name", "stat_val", "stat_grp")

View(nstat_s) 
 
today <- Sys.Date()

fds <- format(today, "%Y%m%d")
# "2014-04-12"
#format(today, "%d-%m-%Y" + )
# "12-04-2014"
#format(today, "%d-%b-%Y")
# "12-Apr-2014"
# format(today, "%a %d-%b-%Y")

# append date string to file name


csvfile_nstat_s <-paste("nstat_s_", fds, ".csv",sep="")   

try(write.table(nstat_s, file = csvfile_nstat_s , append = FALSE, 
               
                col.names = TRUE, row.names = FALSE,sep=","), TRUE)







# Incase need to read in
# nstat_s <- read.csv(paste0("nstat_s_", fds, ".csv"))



# Work on cleaning up below

 system('powershell -command $a = netstat -a ; $a[3..$a.count] | ConvertFrom-String | select p2,p3,p4,p5 | Export-CSv > c:/mydata/cysirs/acc1.csv '  )


 
 
#remove first 4 lines
ac <-  ac[5:length(ac)]
#

a2 <- read.csv("ac2.txt", header = FALSE, sep="\t")
#  strip.white = TRUE
 



 

system('powershell -command  Get-NetworkStatistics -computername THIG | Export-CSv active_connections.csv')
 
# Active connections
system('powershell -command  netstat -a | Export-CSv active_connections.csv')

shell("NETSTAT -a > active_cons.csv")

active_conn <- read.csv("active_cons.txt", header = FALSE, sep="\t", skip = 4, strip.white = TRUE )

ac <- read.delim("ac2.txt", header = FALSE, strip.white = TRUE, skip = 4)
#, fileEncoding="UCS-2LE"
# ?read.table
View(ac)

??pattern

View(active_conn)

 
?readLines


#####    Processes running 
# Run powershell command to get running processes
system('powershell -command $p = Get-Process ; $p[2..$p.count]  | Export-CSV procs.csv', intern=TRUE)
# This command will store the output in a variable 
#procs <- system('powershell -command Get-Process ', intern=TRUE)

# Read in Process data
procs <- read.csv("procs.csv", header= TRUE, skip = 1)

# filter dataset and convert to data table to work with
procs <- data.table(subset(procs, !is.na(CPU)))

View(procs)

#number active process count
proc_ct <- nrow(procs)

# Create dataframe of data with desired columns 
act_process <- data.frame(  "Name" = procs$Name, "Path" = procs$Path, "CPU" = procs$CPU,
               "Description"  = procs$Description,	"Id" = procs$Id,
               "PrivateMemorySize"  = procs$PrivateMemorySize,	"StartTime" = procs$StartTime) 

# round cpu column
act_process$CPU <- round((act_process$CPU), 2)

# Add memory usage column with mb 
act_process$MemoryUsage <-  round((act_process$PrivateMemorySize/1048576),2) 

act_process %>% 
  ggvis(x = ~CPU, y = ~MemoryUsage)

act_process %>%  ggvis(~MemoryUsage)

act_process %>% filter(CPU < 2000)  %>%
  ggvis(x = ~CPU, y = ~MemoryUsage) %>%
  layer_points() %>%
  layer_smooths(stroke := "red")

act_process %>% filter(CPU < 2000)  %>%
  ggvis(x = ~CPU, y = ~MemoryUsage) %>%
  layer_points() %>%
  layer_smooths(stroke  = "smooth") %>%
  layer_model_predictions(model = "lm", stroke = "lm")

act_process %>% 
  ggvis(StartTime)


# not working section
animate(act_process, grand_tour(d = 2), display = display_xy() )

lb <- linked_brush(keys = act_process$Name, fill = "red")

act_process %>%  ggvis(~CPU, ~MemoryUsage, key := ~Name) %>%
  layer_points( fill := lb$fill, fill.brush := "red") %>%
  (lb$input)
 

View(act_process)

# the act_process will be the main data vector for processes section














# Event Log info  

#  https://www.petri.com/monitoring-windows-event-logs-for-security-breaches

# System Log

system('powershell -command Get-EventLog system -newest 2000 | Export-CSV system_event_log.csv', intern=TRUE)

sysevent <- read.csv(file="system_event_log.csv", header= TRUE, skip=1, sep = ",")

View(sysevent)


sysevent_watch <- filter(sysevent, EventID %in% c("1001", "104", "4719", "1125", "1127", "1129"))




# Security Log

system('powershell -command Get-EventLog security -newest 4000 | Export-CSV security_event_log.csv', intern=TRUE)

secevent <- read.csv(file="security_event_log.csv", header= TRUE, skip=1, sep = ",")

secevent <- data.frame(secevent)
View(secevent)

secevent_watch <- data.table(subset(secevent, secevent$EventID %in% c("4740", "4728", "4732", "4756", "4735", "4724", "4625", "4648", "102")))
 # or 
# filter(secevent, EventID %in%  c("4740", "4728", "4732", "4756", "4735", "4724", "4625", "4648", "102")   )

View(secevent_watch)
 
 



#  create a loop with a pause time interval between iterations (in seconds)
x <- c(1:100)
x
for (i in 1:length(x)) {
  
  print(paste("How many times do I have to tell you? ", i, "times show do the trick!"))
Sys.sleep(20)
  }



## Application Log

system('powershell -command Get-EventLog application -newest 1000 | Export-CSV app_event_log.csv', intern=TRUE)

appevent <- read.csv(file="app_event_log.csv", header= TRUE, skip=1, sep = ",")

View(appevent)

appevent_watch <- filter(appevent, EventID %in% c("1000", "1002", "1001"))

## event log counts
?dataTableOutput  
#appevent_watch
#secevent_watch
#sysevent_watch

appevent_watch <- data.table(appevent_watch)
secevent_watch <- data.table(secevent_watch)
sysevent_watch <- data.table(sysevent_watch)

app_watch_ct <- nrow(appevent_watch)
sec_watch_ct <- nrow(secevent_watch)
sys_watch_ct <- nrow(sysevent_watch)




#







########   Create Database cysirs_db


# Create new sqlite3 database
cysirs_db <- src_sqlite("C:/mydata/cysirs/Cyber_Security_Monitoring_With_R/cysirsdb.sqlite3", create = FALSE)

# Copy dataframe to database
copy_to(cysirs_db, as.data.frame(Comp_installed_apps), name = "Comp_installed_apps", 
      #  indexes = list(c("date", "hour"), "plane", "dest", "arr"),
        temporary = FALSE)

# Once you have the data in the database, connect to it, instead of 
# loading data from disk
Comp_installed_apps_db <- cysirs_db %>% tbl("Comp_installed_apps")

View(Comp_installed_apps_db)

 



 