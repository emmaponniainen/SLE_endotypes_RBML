##### RScript to read all affymetrix datafiles 
#### Adapted from Hubbard et al 2023 by Emma Pöniäinen
#### All i have to do is to give it the full list, change the directories to the right place


library(BiocManager)
library(limma)
library(GEOquery)
library(affy)
library(affycoretools) 
library(gcrma)



#make a list of all GSE you want to read (they have to be affymetrix)
all_GSE <- ("GSE72747")
  



for (i in all_GSE) {
  filename = i
  
  #set this to your data directory in the server
  setwd("YOUR PATH GOES HERE")
  
  ##### Provide the GSE number in order to down the raw data, pheno data from NCBI GEO ########
  gse <- getGEO(filename, GSEMatrix = TRUE)
  
  
  # gse is a list, and there is one object inside which is the expression set we want to extract. This is to extract the object from gse
  for (obj in gse) {
    # Check if the object is of class "ExpressionSet"
    if (class(obj) == "ExpressionSet") {
      # If it is, assign it to a variable
      metadata <- obj
      # Exit the loop since you've found the object
      break
    }
  }
  
  #extracting the metadata to it's own variable
  metadata <- pData(metadata)   
  
  
  
###When you use getGEOSuppFiles it creates a dataframe with all the file paths as rownames. This is the raw data.
  filePaths = getGEOSuppFiles(filename) 
  
  
  # Find the row name containing ".tar" (in case there are multiple datafiles available)
  tar_row <- rownames(filePaths)[grepl(".tar", rownames(filePaths))]
  
  # If a row with ".tar" is found
  if (length(tar_row) > 0) {
    # Print the row name
    path <- tar_row # this is the path + filename that will be untared
  } else {
    print("No row with .tar found.")
  }
  

  
  directory= paste0(getwd(),"/",filename) #this is the directory that the file is in, where to untar the .cel files to

  
  untar(path, exdir = directory) #extracting the files to the directory of the specific GSE
  
  setwd(directory)
  
  ####Decompress the CEL files#####
  celfiles <- list.celfiles()
  for(i in 1:length(celfiles))
  {
    gunzip(celfiles[i])
  }
  celfilenames <- as.data.frame(list.celfiles())
  colnames(celfilenames)[1] <- "CELFILES"
  order(celfilenames$CELFILES)
  rownames(metadata) <- celfilenames$CELFILES
  
  pheno <- metadata
  
  
  ##When you do ReadAffy without specifying a file it will take all the .cel files in the wd
  affy_data<- ReadAffy(verbose=TRUE, phenoData=pheno)
  
  # NORMALISING. only worked with rma for me here, 
  #eset_brainarray_gcrma_ampel <- gcrma(affy_data, cdfname=cdf), I do not use this one
  
  eset_rma <- rma(affy_data) #i deleted cdfname = cdf here, i think it is already specified
  
  #change this directory to where you want to save all the eset
  save(eset_rma,file=(paste0("PATH TO WHERE YOU WANT TO SAVE IT",filename, "_eset_rma.RData"))) #Saving the expression set with a personalised name
  

  }


