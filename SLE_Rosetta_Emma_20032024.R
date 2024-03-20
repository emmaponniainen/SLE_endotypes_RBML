

library(devtools)
library(R.ROSETTA)
library(VisuNet)


if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("clusterProfiler")
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
1
BiocManager::install("org.Hs.eg.db")
#For visunet
install.packages("tm") 
install.packages("SnowballC") 
install.packages("wordcloud") 
install.packages("RColorBrewer")


##Here I am reading the .csv files (placed in the same directory)

csv_files <- list.files(pattern = "*.csv")

for (file in csv_files) {
  # Read the CSV file
  df <- read.csv(file, stringsAsFactors = FALSE)
  
  # Set the first and second columns as the index separated by a comma
  rownames(df) <- paste(df[, 1], df[, 2], sep = ",")
  
  # Remove the first and second columns from the dataframe
  df <- df[, -c(1, 2)]
  
  # Assign the dataframe to a variable with filename (without extension) as the name
  assign(tools::file_path_sans_ext(file), df)
}


#Running rosetta for all the files in one go, and saving them in the working directory

for (file in file_names) {
  clroc_variable = substr(file, 0,1)
  print(clroc_variable)
  df <- get(file)
  rosetta <- rosetta(df, roc= TRUE, clroc = clroc_variable)
  print(paste0(file, "_rosetta.RData"))
  saveRDS(rosetta, file = paste0(file, "_rosetta.RData")) 
}



#### Here I am reading the .RData files (I was doing rosetta on a different computer which is why i was saving and then reading again)
# Get list of all RData files in the working directory
rdata_files <- list.files(pattern = "*.RData")

# Iterate over each RData file
for (file in rdata_files) {
  # Load the RData file
  loaded_data <- readRDS(file)
  
  # Extract the filename without extension
  file_name <- tools::file_path_sans_ext(file)
  
  # Assign the loaded object to a variable with the filename as the name
  assign(file_name, loaded_data)
}



#Visualising the rules, more info on this can be found on R.Rosetta documentation
rules <- BvG_12_rosetta$main
qual <- AvB_1_rosetta$quality

rules <- viewRules(rules)
plotMeanROC(AvB_1_rosetta)
plotMeanROC(BvF_11_rosetta)

features <- getFeatures(rules)

#Using visunet to visualise clusteres. More info on this can be found on VisuNet documentation
vis <- visunet(GvH_28_rosetta$main)

