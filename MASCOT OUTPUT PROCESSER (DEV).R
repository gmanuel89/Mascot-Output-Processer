mascot_output_processer <- function() {
  #################### MASCOT OUTPUT PROCESSER ####################
  
  
  # Clear the console
  #cat("\014")
  # Empty the workspace
  #rm(list = ls())
  
  
  
  
  
  ### Program version (Specified by the program writer!!!!)
  R_script_version <- "2017.10.24.0"
  ### Force update (in case something goes wrong after an update, when checking for updates and reading the variable force_update, the script can automatically download the latest working version, even if the rest of the script is corrupted, because it is the first thing that reads)
  force_update <- FALSE
  ### GitHub URL where the R file is
  github_R_url <- "https://raw.githubusercontent.com/gmanuel89/Mascot-Output-Processer/master/MASCOT%20OUTPUT%20PROCESSER.R"
  ### GitHub URL of the program's WIKI
  github_wiki_url <- "https://github.com/gmanuel89/Mascot-Output-Processer/wiki"
  ### Name of the file when downloaded
  script_file_name <- "MASCOT OUTPUT PROCESSER"
  # Change log
  change_log <- "1. New software!"
  
  
  
  
  
  
  ########## FUNCTIONS
  # Check internet connection
  check_internet_connection <<- function(method = "getURL", website_to_ping = "www.google.it") {
    ##### Start with getURL...
    there_is_internet <- FALSE
    ##### GET URL
    if (method == "getURL") {
      try({
        # Install the RCurl package if not installed
        if ("RCurl" %in% installed.packages()[,1]) {
          library(RCurl)
        } else {
          # Check for the personal local library presence before installing (~/R/packages/), then instlall in the local library
          if (!dir.exists(Sys.getenv("R_LIBS_USER"))) {
            dir.create(Sys.getenv("R_LIBS_USER"))
          }
          .libPaths(Sys.getenv("R_LIBS_USER"))
          install.packages("RCurl", repos = "http://cran.mirror.garr.it/mirrors/CRAN/", quiet = TRUE, verbose = FALSE, lib = Sys.getenv("R_LIBS_USER"))
          library(RCurl)
        }
      }, silent = TRUE)
      there_is_internet <- FALSE
      try({
        there_is_internet <- is.character(getURL(u = website_to_ping, followLocation = TRUE, .opts = list(timeout = 1, maxredirs = 2, verbose = FALSE)))
      }, silent = TRUE)
    }
    ##### If getURL failed... Go back to ping (which should never fail)
    ##### PING
    if (method == "ping" || there_is_internet == FALSE) {
      if (Sys.info()[1] == "Linux") {
        # -c: number of packets sent/received (attempts) ; -W timeout in seconds
        there_is_internet <- !as.logical(system(command = paste("ping -c 1 -W 2", website_to_ping), intern = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE))
      } else if (Sys.info()[1] == "Windows") {
        # -n: number of packets sent/received (attempts) ; -w timeout in milliseconds
        there_is_internet <- !as.logical(system(command = paste("ping -n 1 -w 2000", website_to_ping), intern = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE))
      } else {
        there_is_internet <- !as.logical(system(command = paste("ping", website_to_ping), intern = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE))
      }
    }
    return(there_is_internet)
  }
  
  # Install and load required packages
  install_and_load_required_packages <<- function(required_packages, repository = "http://cran.mirror.garr.it/mirrors/CRAN/", update_packages = FALSE, print_messages = FALSE) {
    ### Check internet connection
    there_is_internet <- check_internet_connection(method = "getURL", website_to_ping = "www.google.it")
    ########## Update all the packages (if there is internet connection)
    if (update_packages == TRUE) {
      if (there_is_internet == TRUE) {
        ##### If a repository is specified
        if (repository != "" || !is.null(repository)) {
          # Check for the personal local library presence before installing (~/R/packages/), then install in the local library
          if (!dir.exists(Sys.getenv("R_LIBS_USER"))) {
            dir.create(Sys.getenv("R_LIBS_USER"))
          }
          .libPaths(Sys.getenv("R_LIBS_USER"))
          update.packages(repos = repository, ask = FALSE, checkBuilt = TRUE, quiet = TRUE, verbose = FALSE, lib.loc = Sys.getenv("R_LIBS_USER"))
        } else {
          # Check for the personal local library presence before installing (~/R/packages/), then instlall in the local library
          if (!dir.exists(Sys.getenv("R_LIBS_USER"))) {
            dir.create(Sys.getenv("R_LIBS_USER"))
          }
          .libPaths(Sys.getenv("R_LIBS_USER"))
          update.packages(ask = FALSE, checkBuilt = TRUE, quiet = TRUE, verbose = FALSE, lib.loc = Sys.getenv("R_LIBS_USER"))
        }
        if (print_messages == TRUE) {
          cat("\nPackages updated\n")
        }
      } else {
        if (print_messages == TRUE) {
          cat("\nPackages cannot be updated due to internet connection problems\n")
        }
      }
    }
    ##### Retrieve the installed packages
    installed_packages <- installed.packages()[,1]
    ##### Determine the missing packages
    missing_packages <- required_packages[!(required_packages %in% installed_packages)]
    ##### If there are packages to install...
    if (length(missing_packages) > 0) {
      ### If there is internet...
      if (there_is_internet == TRUE) {
        ### If a repository is specified
        if (repository != "" || !is.null(repository)) {
          # Check for the personal local library presence before installing (~/R/packages/), then instlall in the local library
          if (!dir.exists(Sys.getenv("R_LIBS_USER"))) {
            dir.create(Sys.getenv("R_LIBS_USER"))
          }
          .libPaths(Sys.getenv("R_LIBS_USER"))
          install.packages(missing_packages, repos = repository, quiet = TRUE, verbose = FALSE, lib = Sys.getenv("R_LIBS_USER"))
        } else {
          ### If NO repository is specified
          # Check for the personal local library presence before installing (~/R/packages/), then instlall in the local library
          if (!dir.exists(Sys.getenv("R_LIBS_USER"))) {
            dir.create(Sys.getenv("R_LIBS_USER"))
          }
          .libPaths(Sys.getenv("R_LIBS_USER"))
          install.packages(missing_packages, quiet = TRUE, verbose = FALSE, lib = Sys.getenv("R_LIBS_USER"))
        }
        if (print_messages == TRUE) {
          cat("\nAll the required packages have been installed\n")
        }
        all_needed_packages_are_installed <<- TRUE
      } else {
        ### If there is NO internet...
        if (print_messages == TRUE) {
          cat("\nSome packages cannot be installed due to internet connection problems\n")
        }
        all_needed_packages_are_installed <<- FALSE
      }
    } else {
      if (print_messages == TRUE) {
        cat("\nAll the required packages are installed\n")
      }
      all_needed_packages_are_installed <<- TRUE
    }
    ##### Load the packages (if there are all the packages)
    if ((length(missing_packages) > 0 && there_is_internet == TRUE) || length(missing_packages) == 0) {
      for (i in 1:length(required_packages)) {
        library(required_packages[i], character.only = TRUE, verbose = FALSE, quietly = TRUE, warn.conflicts = FALSE)
      }
      all_needed_packages_are_installed <<- TRUE
    } else {
      if (print_messages == TRUE) {
        cat("\nPackages cannot be installed/loaded... Expect issues...\n")
      }
      all_needed_packages_are_installed <<- FALSE
    }
  }
  
  install_and_load_required_packages("tcltk", update_packages = FALSE, print_messages = TRUE)
  
  
  
  
  
  ###################################### Initialize the variables (default values)
  input_file <- ""
  output_folder <- getwd()
  output_format <- "Comma Separated Values (.csv)"
  file_format <- "csv"
  image_format <- ".png"
  class_name <- "CLASS"
  input_data <- NULL
  
  
  
  
  
  ################## Values of the variables (for displaying and dumping purposes)
  output_file_type_export_value <- "Comma Separated Values (.csv)"
  image_file_type_export_value <- "PNG (.png)"
  
  
  
  
  
  
  ##################################################### DEFINE WHAT THE BUTTONS DO
  
  ##### Check for updates (from my GitHub page) (it just updates the label telling the user if there are updates) (it updates the check for updates value that is called by the label). The function will read also if an update should be forced.
  check_for_updates_function <- function() {
    ### Initialize the version number
    online_version_number <- NULL
    ### Initialize the force update
    online_force_update <- FALSE
    ### Initialize the variable that says if there are updates
    update_available <- FALSE
    ### Initialize the change log
    online_change_log <- "Bug fixes"
    # Check if there is internet connection by pinging a website
    there_is_internet <- check_internet_connection(method = "getURL", website_to_ping = "www.google.it")
    # Check for updates only in case of working internet connection
    if (there_is_internet == TRUE) {
      try({
        ### Read the file from the web (first 10 lines)
        online_file <- readLines(con = github_R_url)
        ### Retrieve the version number
        for (l in online_file) {
          if (length(grep("R_script_version <-", l, fixed = TRUE)) > 0) {
            # Isolate the "variable" value
            online_version_number <- unlist(strsplit(l, "R_script_version <- ", fixed = TRUE))[2]
            # Remove the quotes
            online_version_number <- unlist(strsplit(online_version_number, "\""))[2]
            break
          }
        }
        ### Retrieve the force update
        for (l in online_file) {
          if (length(grep("force_update <-", l, fixed = TRUE)) > 0) {
            # Isolate the "variable" value
            online_force_update <- as.logical(unlist(strsplit(l, "force_update <- ", fixed = TRUE))[2])
            break
          }
          if (is.null(online_force_update)) {
            online_force_update <- FALSE
          }
        }
        ### Retrieve the change log
        for (l in online_file) {
          if (length(grep("change_log <-", l, fixed = TRUE)) > 0) {
            # Isolate the "variable" value
            online_change_log <- unlist(strsplit(l, "change_log <- ", fixed = TRUE))[2]
            # Remove the quotes
            online_change_log_split <- unlist(strsplit(online_change_log, "\""))[2]
            # Split at the \n
            online_change_log_split <- unlist(strsplit(online_change_log_split, "\\\\n"))
            # Put it back to the character
            online_change_log <- ""
            for (o in online_change_log_split) {
              online_change_log <- paste(online_change_log, o, sep = "\n")
            }
            break
          }
        }
        ### Split the version number in YYYY.MM.DD
        online_version_YYYYMMDDVV <- unlist(strsplit(online_version_number, ".", fixed = TRUE))
        ### Compare with the local version
        local_version_YYYYMMDDVV = unlist(strsplit(R_script_version, ".", fixed = TRUE))
        ### Check the versions (from the Year to the Day)
        # Check the year
        if (as.numeric(local_version_YYYYMMDDVV[1]) < as.numeric(online_version_YYYYMMDDVV[1])) {
          update_available <- TRUE
        }
        # If the year is the same (update is FALSE), check the month
        if (update_available == FALSE) {
          if ((as.numeric(local_version_YYYYMMDDVV[1]) == as.numeric(online_version_YYYYMMDDVV[1])) && (as.numeric(local_version_YYYYMMDDVV[2]) < as.numeric(online_version_YYYYMMDDVV[2]))) {
            update_available <- TRUE
          }
        }
        # If the month and the year are the same (update is FALSE), check the day
        if (update_available == FALSE) {
          if ((as.numeric(local_version_YYYYMMDDVV[1]) == as.numeric(online_version_YYYYMMDDVV[1])) && (as.numeric(local_version_YYYYMMDDVV[2]) == as.numeric(online_version_YYYYMMDDVV[2])) && (as.numeric(local_version_YYYYMMDDVV[3]) < as.numeric(online_version_YYYYMMDDVV[3]))) {
            update_available <- TRUE
          }
        }
        # If the day and the month and the year are the same (update is FALSE), check the daily version
        if (update_available == FALSE) {
          if ((as.numeric(local_version_YYYYMMDDVV[1]) == as.numeric(online_version_YYYYMMDDVV[1])) && (as.numeric(local_version_YYYYMMDDVV[2]) == as.numeric(online_version_YYYYMMDDVV[2])) && (as.numeric(local_version_YYYYMMDDVV[3]) == as.numeric(online_version_YYYYMMDDVV[3])) && (as.numeric(local_version_YYYYMMDDVV[4]) < as.numeric(online_version_YYYYMMDDVV[4]))) {
            update_available <- TRUE
          }
        }
        ### Return messages
        if (is.null(online_version_number)) {
          # The version number could not be ckecked due to internet problems
          # Update the label
          check_for_updates_value <- paste("Version: ", R_script_version, "\nUpdates not checked:\nconnection problems", sep = "")
        } else {
          if (update_available == TRUE) {
            # Update the label
            check_for_updates_value <- paste("Version: ", R_script_version, "\nUpdate available:\n", online_version_number, sep = "")
          } else {
            # Update the label
            check_for_updates_value <- paste("Version: ", R_script_version, "\nNo updates available", sep = "")
          }
        }
      }, silent = TRUE)
    }
    ### Something went wrong: library not installed, retrieving failed, errors in parsing the version number
    if (is.null(online_version_number)) {
      # Update the label
      check_for_updates_value <- paste("Version: ", R_script_version, "\nUpdates not checked:\nconnection problems", sep = "")
    }
    # Escape the function
    update_available <<- update_available
    online_change_log <<- online_change_log
    check_for_updates_value <<- check_for_updates_value
    online_version_number <<- online_version_number
    online_force_update <<- online_force_update
  }
  
  ##### Download the updated file (from my GitHub page)
  download_updates_function <- function() {
    # Download updates only if there are updates available
    if (update_available == TRUE || online_force_update == TRUE) {
      # Initialize the variable which says if the file has been downloaded successfully
      file_downloaded <- FALSE
      # Choose where to save the updated script
      tkmessageBox(title = "Download folder", message = "Select where to save the updated script file", icon = "info")
      download_folder <- tclvalue(tkchooseDirectory())
      # Download the file only if a download folder is specified, otherwise don't
      if (download_folder != "") {
        # Go to the working directory
        setwd(download_folder)
        tkmessageBox(message = paste("The updated script file will be downloaded in:\n\n", download_folder, sep = ""))
        # Download the file
        try({
          download.file(url = github_R_url, destfile = paste0(script_file_name, ".R"), method = "auto")
          file_downloaded <- TRUE
        }, silent = TRUE)
        if (file_downloaded == TRUE) {
          tkmessageBox(title = "Updated file downloaded!", message = paste("The updated script, named:\n\n", paste0(script_file_name, ".R"), "\n\nhas been downloaded to:\n\n", download_folder, "\n\nClose everything, delete this file and run the script from the new file!", sep = ""), icon = "info")
          tkmessageBox(title = "Changelog", message = paste("The updated script contains the following changes:\n", online_change_log, sep = ""), icon = "info")
        } else {
          tkmessageBox(title = "Connection problem", message = paste("The updated script file could not be downloaded due to internet connection problems!\n\nManually download the updated script file at:\n\n", github_R_url, sep = ""), icon = "warning")
        }
      } else {
        # No download folder specified!
        tkmessageBox(message = "The updated script file will not be downloaded!")
      }
    } else {
      tkmessageBox(title = "No update available", message = "NO UPDATES AVAILABLE!\n\nThe latest version is running!", icon = "info")
    }
    # Raise the focus on the main window (if there is)
    try(tkraise(window), silent = TRUE)
  }
  
  ### Downloading forced updates
  check_for_updates_function()
  if (online_force_update == TRUE) {
    download_updates_function()
  }
  
  ##### Output file type (export)
  output_file_type_export_choice <- function() {
    # Catch the value from the menu
    output_format <- select.list(c("Comma Separated Values (.csv)", "Microsoft Excel (.xls)", "Microsoft Excel (.xlsx)"), title = "Choose output file format")
    # Focus the main window
    tkraise(window)
    # Fix the file format
    if (output_format == "Comma Separated Values (.csv)" || output_format == "") {
      file_format <- "csv"
    } else if (output_format == "Microsoft Excel (.xlsx)") {
      file_format <- "xlsx"
      # Try to install the XLConnect (it will fail if Java is not installed)
      Java_is_installed <- FALSE
      try({
        install_and_load_required_packages("XLConnect")
        Java_is_installed <- TRUE
      }, silent = TRUE)
      # If it didn't install successfully, set to CSV
      if (Java_is_installed == FALSE) {
        tkmessageBox(title = "Java not installed", message = "Java is not installed, therefore the package XLConnect cannot be installed and loaded.\nThe output format is switched back to CSV", icon = "warning")
        file_format <- "csv"
      }
    } else if (output_format == "Microsoft Excel (.xls)") {
      file_format <- "xls"
      # Try to install the XLConnect (it will fail if Java is not installed)
      Java_is_installed <- FALSE
      try({
        install_and_load_required_packages("XLConnect")
        Java_is_installed <- TRUE
      }, silent = TRUE)
      # If it didn't install successfully, set to CSV
      if (Java_is_installed == FALSE) {
        tkmessageBox(title = "Java not installed", message = "Java is not installed, therefore the package XLConnect cannot be installed and loaded.\nThe output format is switched back to CSV", icon = "warning")
        file_format <- "csv"
      }
    }
    # Set the value of the displaying label
    output_file_type_export_value_label <- tklabel(window, text = output_format, font = label_font, bg = "white", width = 30)
    tkgrid(output_file_type_export_value_label, row = 2, column = 2, padx = c(10, 10), pady = c(10, 10))
    # Escape the function
    output_format <<- output_format
    file_format <<- file_format
  }
  
  ##### Image file type (export)
  image_file_type_export_choice <- function() {
    # Catch the value from the menu
    image_output_format <- select.list(c("JPG (.jpg)", "PNG (.png)", "TIFF (.tiff)"), title = "Choose image format")
    # Focus the main window
    tkraise(window)
    # Fix the file format
    if (image_output_format == "JPG (.jpg)") {
      image_format <- ".jpg"
    } else if (image_output_format == "PNG (.png)" || image_output_format == "") {
      image_format <- ".png"
    } else if (image_output_format == "TIFF (.tiff)") {
      image_format <- ".tiff"
    }
    # Set the value of the displaying label
    image_file_type_export_value_label <- tklabel(window, text = image_output_format, font = label_font, bg = "white", width = 20)
    tkgrid(image_file_type_export_value_label, row = 3, column = 2, padx = c(10, 10), pady = c(10, 10))
    # Escape the function
    image_output_format <<- image_output_format
    image_format <<- image_format
  }
  
  ##### File import
  file_import_function <- function() {
    # Folder for the input files
    tkmessageBox(title = "Input file", message = "Select the Mascot output file", icon = "info")
    input_file <- tclvalue(tkgetOpenFile(filetypes = "{{Comma Separated Value files} {.csv}}"))
    # Read the CSV files
    # Import data only if a file path is specified
    if (input_file != "") {
      #################### IMPORT THE DATA FROM THE FILE
      ### Progress bar
      import_progress_bar <- tkProgressBar(title = "Importing file...", label = "", min = 0, max = 1, initial = 0, width = 300)
      setTkProgressBar(import_progress_bar, value = 0, title = NULL, label = "0 %")
      ### Remove all the lines that are not the desired lines (the useless header)
      setTkProgressBar(import_progress_bar, value = 0.10, title = "Discarding header...", label = "10 %")
      input_file_lines <- readLines(input_file)
      # Start to read from the matrix header: "prot_hit"
      input_file_header_line_number <- 0
      for (l in 1:length(input_file_lines)) {
        if (startsWith(input_file_lines[l], "prot_hit")) {
          input_file_header_line_number <- l
          break
        }
      }
      # Keep only the selected lines
      final_input_file_lines <- character()
      if (input_file_header_line_number > 0) {
        final_input_file_lines <- input_file_lines[input_file_header_line_number : length(input_file_lines)]
      } else {
        final_input_file_lines <- character()
      }
      setTkProgressBar(import_progress_bar, value = 0.40, title = "Reading CSV table...", label = "40 %")
      # Read the CSV file from the lines
      if (length(final_input_file_lines) > 0) {
        input_data <- read.csv(text = final_input_file_lines, header = TRUE)
        if (is.null(rownames(input_data))) {
          rownames(input_data) <- seq(from = 1, to = nrow(input_data), by = 1)
        }
      } else {
        input_data <- NULL
      }
      setTkProgressBar(import_progress_bar, value = 0.95, title = "Setting file name...", label = "95 %")
      ### Retrieve the input file name
      input_filename <- character()
      try({
        if (Sys.info()[1] == "Linux" || Sys.info()[1] == "Darwin") {
          input_filename <- unlist(strsplit(input_file, "/"))
          input_filename <- input_filename[length(input_filename)]
          input_filename <- unlist(strsplit(input_filename, ".csv", fixed = TRUE))[1]
        } else if (Sys.info()[1] == "Windows") {
          input_filename <- unlist(strsplit(input_file, "\\\\"))
          input_filename <- input_filename[length(input_filename)]
          input_filename <- unlist(strsplit(input_filename, ".csv", fixed = TRUE))[1]
        }
      }, silent = TRUE)
      # Input folder as class name
      #class_name <- unlist(strsplit(input_folder, .Platform$file.sep))
      #class_name <- class_name[length(class_name)]
      # Escape the function
      input_file <<- input_file
      #class_name <<- class_name
      #input_file_list <<- input_file_list
      input_filename <<- input_filename
      input_data <<- input_data
      setTkProgressBar(import_progress_bar, value = 1.00, title = "Done!", label = "100 %")
      close(import_progress_bar)
      # Message
      if (!is.null(input_data)) {
        tkmessageBox(title = "File imported", message = "The file has been successfully imported!", icon = "info")
      } else {
        tkmessageBox(title = "File not imported", message = "The file could not be imported! Check the file structure and re-import it!", icon = "warning")
      }
    } else {
      # Escape the function
      input_file <<- input_file
      input_filename <<- NULL
      input_data <<- NULL
      tkmessageBox(title = "No input file selected", message = "No input file has been selected!!!\nPlease, select a file to be imported", icon = "warning")
    }
  }
  
  ##### Output
  browse_output_function <- function() {
    output_folder <- tclvalue(tkchooseDirectory())
    if (!nchar(output_folder)) {
      # Get the output folder from the default working directory
      output_folder <- getwd()
    }
    # Go to the working directory
    setwd(output_folder)
    tkmessageBox(message = paste("Every file will be saved in", output_folder))
    tkmessageBox(message = "A sub-directory named 'MASCOT X' will be created for each run!")
    # Escape the function
    output_folder <<- output_folder
  }
  
  ##### Exit
  end_session_function <- function() {
    q(save = "no")
  }
  
  ##### Run the mod-processer
  run_mascot_output_modprocesser_function <- function() {
    #### Run only if there is data
    if (!is.null(input_data)) {
      
      
      ### Progress bar
      program_progress_bar <- tkProgressBar(title = "Reading data...", label = "", min = 0, max = 1, initial = 0, width = 400)
      setTkProgressBar(program_progress_bar, value = 0.01, title = "Reading data...", label = "1 %")
      # Go to the working directory
      setwd(output_folder)
      # Check if all the columns are present
      columns_needed <- c("pep_var_mod", "pep_ident", "pep_homol", "pep_score", "prot_acc", "pep_seq", "pep_var_mod_pos")
      all_the_columns_are_present <- all(columns_needed %in% colnames(input_data))
      missing_columns_value <- NULL
      missing_columns <- columns_needed[columns_needed %in% colnames(input_data) == FALSE]
      if (length(missing_columns) > 0) {
        for (m in 1:length(missing_columns)) {
          if (is.null(missing_columns_value)) {
            missing_columns_value <- missing_columns[m]
          } else {
            missing_columns_value <- paste0(missing_columns_value, "\n", missing_columns[m])
          }
        }
      }
      
      
      
      
      
      # Run only if there is data and the data is correct
      if (!is.null(input_data) && all_the_columns_are_present == TRUE) {
        ##### Automatically create a subfolder with all the results
        ## Check if such subfolder exists
        list_of_directories <- list.dirs(output_folder, full.names = FALSE, recursive = FALSE)
        ## Check the presence of a MASCOT folder
        MASCOT_folder_presence <- FALSE
        if (length(list_of_directories) > 0) {
          for (dr in 1:length(list_of_directories)) {
            if (length(grep("MASCOT", list_of_directories[dr], fixed = TRUE)) > 0) {
              MASCOT_folder_presence <- TRUE
            }
          }
        }
        ## If it present...
        if (isTRUE(MASCOT_folder_presence)) {
          ## Extract the number after the STATISTICS
          # Number for the newly created folder
          MASCOT_new_folder_number <- 0
          # List of already present numbers
          MASCOT_present_folder_numbers <- integer()
          # For each folder present...
          for (dr in 1:length(list_of_directories)) {
            # If it is named MASCOT
            if (length(grep("MASCOT", list_of_directories[dr], fixed = TRUE)) > 0) {
              # Split the name
              MASCOT_present_folder_split <- unlist(strsplit(list_of_directories[dr], "MASCOT"))
              # Add the number to the list of MASCOT numbers (if it is NA it means that what was following the MASCOT was not a number)
              try({
                if (!is.na(as.integer(MASCOT_present_folder_split[2]))) {
                  MASCOT_present_folder_numbers <- append(MASCOT_present_folder_numbers, as.integer(MASCOT_present_folder_split[2]))
                } else {
                  MASCOT_present_folder_numbers <- append(MASCOT_present_folder_numbers, as.integer(0))
                }
              }, silent = TRUE)
            }
          }
          # Sort the STATISTICS folder numbers
          try(MASCOT_present_folder_numbers <- sort(MASCOT_present_folder_numbers))
          # The new folder number will be the greater + 1
          try(MASCOT_new_folder_number <- MASCOT_present_folder_numbers[length(MASCOT_present_folder_numbers)] + 1)
          # Generate the new subfolder
          MASCOT_subfolder <- paste("MASCOT", MASCOT_new_folder_number)
          # Estimate the new output folder
          output_subfolder <- file.path(output_folder, MASCOT_subfolder)
          # Create the subfolder
          dir.create(output_subfolder)
        } else {
          # If it not present...
          # Create the folder where to dump the files and go to it...
          MASCOT_subfolder <- paste("MASCOT", "1")
          # Estimate the new output folder
          output_subfolder <- file.path(output_folder, MASCOT_subfolder)
          # Create the subfolder
          dir.create(output_subfolder)
        }
        # Go to the new working directory
        setwd(output_subfolder)
        
        
        
        
        
        # Progress bar
        setTkProgressBar(program_progress_bar, value = 0.05, title = "Splitting data...", label = "5 %")
        
        
        
        
        
        ########## DATA SPLIT: MODIFIED vs NON-MODIFIED
        # Convert the pep_var_mod column to character
        input_data$pep_var_mod <- as.character(input_data$pep_var_mod)
        # The modified peptides have something in this column
        modified_peptides_df <- input_data[input_data$pep_var_mod != "", ]
        # The unmodified peptides do not have anything as modification
        non_modified_peptides_df <- input_data[input_data$pep_var_mod == "", ]
        
        
        
        
        
        # Progress bar
        setTkProgressBar(program_progress_bar, value = 0.10, title = "Determining homology and identity...", label = "10 %")
        
        
        
        
        
        ########## IDENTITY
        # Insert a column named "identity", which contains the information about the identity or the homology of the peptides, according to their scores...
        # If pep_score is more than the pep_ident, the peptide is flagged as "identity". If this condition is not satisfied check the pep_homol: if pep_homol is present (not NA or > 0) and the pep_score is more than the pep_homol, flag the peptide as "homology". If pep_homol is not present (NA or 0) or the pep_score is not more than the pep_homol, "discard" the peptide.
        
        non_modified_peptides_df$identity <- non_modified_peptides_df$pep_var_mod
        modified_peptides_df$identity <- modified_peptides_df$pep_var_mod
        
        for (l in 1:length(non_modified_peptides_df$identity)) {
          if (non_modified_peptides_df$pep_score[l] >= non_modified_peptides_df$pep_ident[l]) {
            non_modified_peptides_df$identity[l] <- "identity"
          } else {
            if (!is.na(non_modified_peptides_df$pep_homol[l]) && (non_modified_peptides_df$pep_score[l] > non_modified_peptides_df$pep_homol[l])) {
              non_modified_peptides_df$identity[l] <- "homology"
            } else {
              non_modified_peptides_df$identity[l] <- "discard"
            }
          }
        }
        
        for (l in 1:length(modified_peptides_df$identity)) {
          if (modified_peptides_df$pep_score[l] >= modified_peptides_df$pep_ident[l]) {
            modified_peptides_df$identity[l] <- "identity"
          } else {
            if (!is.na(modified_peptides_df$pep_homol[l]) && (modified_peptides_df$pep_score[l] > modified_peptides_df$pep_homol[l])) {
              modified_peptides_df$identity[l] <- "homology"
            } else {
              modified_peptides_df$identity[l] <- "discard"
            }
          }
        }
        
        # Discard the peptides to be discarded
        non_modified_peptides_df <- non_modified_peptides_df[non_modified_peptides_df$identity != "discard", ]
        modified_peptides_df <- modified_peptides_df[modified_peptides_df$identity != "discard", ]
        
        
        
        
        
        # Progress bar
        setTkProgressBar(program_progress_bar, value = 0.20, title = "Discarding non-modified duplicates...", label = "20 %")
        
        
        
        
        
        ########## REMOVE DUPLICATES (NON-MODIFIED)
        non_modified_peptides_df$prot_acc <- as.character(non_modified_peptides_df$prot_acc)
        non_modified_peptides_df$pep_seq <- as.character(non_modified_peptides_df$pep_seq)
        
        # Order the dataframe according to prot_acc, pep_seq, pep_score
        non_modified_peptides_df <- non_modified_peptides_df[order(non_modified_peptides_df$prot_acc, non_modified_peptides_df$pep_seq, -non_modified_peptides_df$pep_score), ]
        
        # Extract the unique values (keep unique prot_acc and pep_seq and only the highest score for prot_acc/pep_seq duplicates)
        row_ID_to_keep <- numeric()
        prot_acc_unique <- character()
        non_modified_peptides_df_prot_acc <- character()
        pep_seq_unique <- character()
        non_modified_peptides_df_prot_acc_pep_seq <- character()
        final_df <- NULL
        
        # Determine the unique values of the prot_acc column
        prot_acc_unique <- unique(non_modified_peptides_df$prot_acc)
        # For each prot_acc...
        for (pa in 1:length(prot_acc_unique)) {
          # Rows with the prot_acc_value
          non_modified_peptides_df_prot_acc <- non_modified_peptides_df[non_modified_peptides_df$prot_acc == prot_acc_unique[pa],]
          # Determine the unique values of the pep_seq column
          pep_seq_unique <- unique(non_modified_peptides_df_prot_acc$pep_seq)
          # For each pep_seq...
          for (ps in 1:length(pep_seq_unique)) {
            # Rows with the pep_seq_value
            non_modified_peptides_df_prot_acc_pep_seq <- non_modified_peptides_df_prot_acc[non_modified_peptides_df_prot_acc$pep_seq == pep_seq_unique[ps],]
            # Keep only the first (with the highest pep_score) (store the row ID)
            row_ID_to_keep <- append(row_ID_to_keep, rownames(non_modified_peptides_df_prot_acc_pep_seq[1,]))
          }
        }
        # Retrieve the rows to keep
        final_df <- non_modified_peptides_df[rownames(non_modified_peptides_df) %in% row_ID_to_keep, ]
        non_modified_peptides_df <- final_df
        
        # Display the 'identity' first
        non_modified_peptides_df <- non_modified_peptides_df[order(non_modified_peptides_df$identity, non_modified_peptides_df$pep_score, non_modified_peptides_df$prot_acc, decreasing = TRUE), ]
        
        
        
        
        
        # Progress bar
        setTkProgressBar(program_progress_bar, value = 0.30, title = "Discarding modified duplicates...", label = "30 %")
        
        
        
        
        
        ########## REMOVE DUPLICATES (MODIFIED)
        modified_peptides_df$prot_acc <- as.character(modified_peptides_df$prot_acc)
        modified_peptides_df$pep_seq <- as.character(modified_peptides_df$pep_seq)
        
        # Order the dataframe according to prot_acc, pep_seq, pep_var_mod, pep_var_mod_pos, pep_score
        modified_peptides_df <- modified_peptides_df[order(modified_peptides_df$prot_acc, modified_peptides_df$pep_seq, modified_peptides_df$pep_var_mod, modified_peptides_df$pep_var_mod_pos, -modified_peptides_df$pep_score), ]
        
        # Extract the unique values (keep unique prot_acc, pep_seq, pep_var_mod and pep_var_mod_pos and only the highest score for prot_acc/pep_seq/pep_var_mod/pep_var_mod_pos duplicates)
        row_ID_to_keep <- numeric()
        prot_acc_unique <- character()
        modified_peptides_df_prot_acc <- character()
        pep_seq_unique <- character()
        modified_peptides_df_prot_acc_pep_seq <- character()
        pep_var_mod_unique <- character()
        modified_peptides_df_prot_acc_pep_seq_pep_var_mod <- character()
        pep_var_mod_pos_unique <- character()
        modified_peptides_df_prot_acc_pep_seq_pep_var_mod_pep_var_mod_pos <- character()
        final_df <- NULL
        # Determine the unique values of the prot_acc column
        prot_acc_unique <- unique(modified_peptides_df$prot_acc)
        # For each prot_acc...
        for (pa in 1:length(prot_acc_unique)) {
          # Rows with the prot_acc_value
          modified_peptides_df_prot_acc <- modified_peptides_df[modified_peptides_df$prot_acc == prot_acc_unique[pa],]
          # Determine the unique values of the pep_seq column
          pep_seq_unique <- unique(modified_peptides_df_prot_acc$pep_seq)
          # For each pep_seq...
          for (ps in 1:length(pep_seq_unique)) {
            # Rows with the pep_seq_value
            modified_peptides_df_prot_acc_pep_seq <- modified_peptides_df_prot_acc[modified_peptides_df_prot_acc$pep_seq == pep_seq_unique[ps],]
            # Determine the unique values of the pep_var_mod column
            pep_var_mod_unique <- unique(modified_peptides_df_prot_acc_pep_seq$pep_var_mod)
            # For each pep_var_mod...
            for (pvm in 1:length(pep_var_mod_unique)) {
              # Rows with the pep_var_mod_value
              modified_peptides_df_prot_acc_pep_seq_pep_var_mod <- modified_peptides_df_prot_acc_pep_seq[modified_peptides_df_prot_acc_pep_seq$pep_var_mod == pep_var_mod_unique[pvm],]
              # Determine the unique values of the pep_var_mod_pos column
              modified_peptides_df_prot_acc_pep_seq_pep_var_mod$pep_var_mod_pos <- as.character(modified_peptides_df_prot_acc_pep_seq_pep_var_mod$pep_var_mod_pos)
              pep_var_mod_pos_unique <- unique(modified_peptides_df_prot_acc_pep_seq_pep_var_mod$pep_var_mod_pos)
              # For each pep_var_mod_pos...
              for (pvmp in 1:length(pep_var_mod_pos_unique)) {
                # Rows with the pep_var_mod_pos_value
                modified_peptides_df_prot_acc_pep_seq_pep_var_mod_pep_var_mod_pos <- modified_peptides_df_prot_acc_pep_seq_pep_var_mod[modified_peptides_df_prot_acc_pep_seq_pep_var_mod$pep_var_mod_pos == pep_var_mod_pos_unique[pvmp],]
                # Keep only the first (with the highest pep_score) (store the row ID)
                row_ID_to_keep <- append(row_ID_to_keep, rownames(modified_peptides_df_prot_acc_pep_seq_pep_var_mod_pep_var_mod_pos[1,]))
              }
            }
          }
        }
        # Retrieve the rows to keep
        final_df <- modified_peptides_df[rownames(modified_peptides_df) %in% row_ID_to_keep, ]
        modified_peptides_df <- final_df
        
        # Display the 'identity' first
        modified_peptides_df <- modified_peptides_df[order(modified_peptides_df$identity, modified_peptides_df$pep_score, modified_peptides_df$prot_acc, decreasing = TRUE), ]
        
        
        
        
        
        # Progress bar
        setTkProgressBar(program_progress_bar, value = 0.60, title = "Discarding modified sequence duplicates...", label = "60 %")
        
        
        
        
        
        ########## REMOVE SEQUENCE DUPLICATES (MODIFIED)
        modified_peptides_df_sequences <- modified_peptides_df
        
        # Order the dataframe according to prot_acc, pep_seq, pep_var_mod, pep_var_mod_pos, pep_score
        modified_peptides_df_sequences <- modified_peptides_df_sequences[order(modified_peptides_df_sequences$prot_acc, modified_peptides_df_sequences$pep_seq, -modified_peptides_df_sequences$pep_score), ]
        
        # Extract the unique values (keep unique prot_acc and pep_seq, and only the highest score for prot_acc/pep_seq duplicates)
        row_ID_to_keep <- character()
        prot_acc_unique <- character()
        modified_peptides_df_sequences_prot_acc <- character()
        pep_seq_unique <- character()
        modified_peptides_df_sequences_prot_acc_pep_seq <- character()
        final_df <- NULL
        # Determine the unique values of the prot_acc column
        prot_acc_unique <- unique(modified_peptides_df_sequences$prot_acc)
        # For each prot_acc...
        for (pa in 1:length(prot_acc_unique)) {
          # Rows with the prot_acc_value
          modified_peptides_df_sequences_prot_acc <- modified_peptides_df_sequences[modified_peptides_df_sequences$prot_acc == prot_acc_unique[pa],]
          # Determine the unique values of the pep_seq column
          pep_seq_unique <- unique(modified_peptides_df_sequences_prot_acc$pep_seq)
          # For each pep_seq...
          for (ps in 1:length(pep_seq_unique)) {
            # Rows with the pep_seq_value
            modified_peptides_df_sequences_prot_acc_pep_seq <- modified_peptides_df_sequences_prot_acc[modified_peptides_df_sequences_prot_acc$pep_seq == pep_seq_unique[ps],]
            # Keep only the first (with the highest pep_score) (store the row ID)
            row_ID_to_keep <- append(row_ID_to_keep, rownames(modified_peptides_df_sequences_prot_acc_pep_seq[1,]))
          }
        }
        # Retrieve the rows to keep
        final_df <- modified_peptides_df_sequences[rownames(modified_peptides_df_sequences) %in% row_ID_to_keep, ]
        modified_peptides_df_sequences <- final_df
        
        # Display the 'identity' first
        modified_peptides_df_sequences <- modified_peptides_df_sequences[order(modified_peptides_df_sequences$identity, modified_peptides_df_sequences$pep_score, modified_peptides_df_sequences$prot_acc, decreasing = TRUE), ]
        
        
        
        
        
        # Progress bar
        setTkProgressBar(program_progress_bar, value = 0.95, title = "Saving files...", label = "95 %")
        
        
        ########## SAVE FILES
        if (is.null(input_filename)) {
          input_filename <- "Input Data"
        }
        if (file_format == "csv") {
          write.csv(input_data, file = paste(input_filename, ".", file_format, sep = ""), row.names = FALSE)
          write.csv(non_modified_peptides_df, file = paste("Non-modified peptides.", file_format, sep = ""), row.names = FALSE)
          write.csv(modified_peptides_df, file = paste("Modified peptides.", file_format, sep = ""), row.names = FALSE)
          write.csv(modified_peptides_df_sequences, file = paste("Modified peptides (unique sequences).", file_format, sep = ""), row.names = FALSE)
        } else if (file_format == "xlsx" || file_format == "xls") {
          writeWorksheetToFile(file = paste0(input_filename, ".", file_format), data = input_data, sheet = "Input data", header = TRUE, clearSheets = TRUE)
          writeWorksheetToFile(file = paste0("Non-modified peptides.", file_format), data = non_modified_peptides_df, sheet = "Non-modified peptides", header = TRUE, clearSheets = TRUE)
          writeWorksheetToFile(file = paste0("Modified peptides.", file_format), data = modified_peptides_df, sheet = "Modified peptides", header = TRUE, clearSheets = TRUE)
          writeWorksheetToFile(file = paste0("Modified peptides (unique sequences).", file_format), data = modified_peptides_df, sheet = "Modified sequences", header = TRUE, clearSheets = TRUE)
        }
        
        # Progress bar
        setTkProgressBar(program_progress_bar, value = 1.00, title = "Done!", label = "100 %")
        close(program_progress_bar)
        
        
        # Go to the working directory
        setwd(output_folder)
        
        
        tkmessageBox(title = "Success!", message = "The process has successfully finished!", icon = "info")
      } else {
        close(program_progress_bar)
        if (input_file == "" || is.null(input_data)) {
          ########## NO INPUT FILE
          tkmessageBox(title = "No input file selected!", message = "No input file has been selected!", icon = "warning")
        }
        if (all_the_columns_are_present == FALSE) {
          ########## MISSING DATA
          tkmessageBox(title = "Missing data!", message = paste0("Some data is missing from the selected input file!\n\n\n", missing_columns_value), icon = "warning")
        }
      }
    } else {
      ########## MISSING DATA
      tkmessageBox(title = "Data not imported", message = "Import the data before running the software", icon = "warning")
    }
  }
  
  ##### Show info function
  show_info_function <- function() {
    if (Sys.info()[1] == "Linux") {
      system(command = paste("xdg-open", github_wiki_url), intern = FALSE)
    } else if (Sys.info()[1] == "Darwin") {
      system(command = paste("open", github_wiki_url), intern = FALSE)
    } else if (Sys.info()[1] == "Windows") {
      system(command = paste("cmd /c start", github_wiki_url), intern = FALSE)
    }
  }
  
  
  
  
  
  
  
  
  
  ###############################################################################
  
  
  
  
  ##################################################################### WINDOW GUI
  
  
  
  ######################## GUI
  
  # Get system info (Platform - Release - Version (- Linux Distro))
  system_os = Sys.info()[1]
  os_release = Sys.info()[2]
  os_version = Sys.info()[3]
  
  ### Get the screen resolution
  try({
    # Windows
    if (system_os == "Windows") {
      # Get system info
      screen_info <- system("wmic path Win32_VideoController get VideoModeDescription", intern = TRUE)[2]
      # Get the resolution
      screen_resolution <- unlist(strsplit(screen_info, "x"))
      # Retrieve the values
      screen_height <- as.numeric(screen_resolution[2])
      screen_width <- as.numeric(screen_resolution[1])
    } else if (system_os == "Linux") {
      # Get system info
      screen_info <- system("xdpyinfo -display :0", intern = TRUE)
      # Get the resolution
      screen_resolution <- screen_info[which(screen_info == "screen #0:") + 1]
      screen_resolution <- unlist(strsplit(screen_resolution, "dimensions: ")[1])
      screen_resolution <- unlist(strsplit(screen_resolution, "pixels"))[2]
      # Retrieve the wto dimensions...
      screen_width <- as.numeric(unlist(strsplit(screen_resolution, "x"))[1])
      screen_height <- as.numeric(unlist(strsplit(screen_resolution, "x"))[2])
    }
  }, silent = TRUE)
  
  
  
  ### FONTS
  # Default sizes (determined on a 1680x1050 screen) (in order to make them adjust to the size screen, the screen resolution should be retrieved)
  title_font_size_default <- 24
  other_font_size_default <- 11
  title_font_size <- title_font_size_default
  other_font_size <- other_font_size_default
  
  # Adjust fonts size according to the pixel number
  try({
    # Windows
    if (system_os == "Windows") {
      # Determine the font size according to the resolution
      total_number_of_pixels <- screen_width * screen_height
      # Determine the scaling factor (according to a complex formula)
      scaling_factor_title_font <- as.numeric((0.03611 * total_number_of_pixels) + 9803.1254)
      scaling_factor_other_font <- as.numeric((0.07757 * total_number_of_pixels) + 23529.8386)
      title_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_title_font))
      other_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_other_font))
    } else if (system_os == "Linux") {
      # Linux
      # Determine the font size according to the resolution
      total_number_of_pixels <- screen_width * screen_height
      # Determine the scaling factor (according to a complex formula)
      scaling_factor_title_font <- as.numeric((0.03611 * total_number_of_pixels) + 9803.1254)
      scaling_factor_other_font <- as.numeric((0.07757 * total_number_of_pixels) + 23529.8386)
      title_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_title_font))
      other_font_size <- as.integer(round(total_number_of_pixels / scaling_factor_other_font))
    } else if (system_os == "Darwin") {
      # macOS
      print("Using default font sizes...")
    }
    # Go back to defaults if there are NAs
    if (is.na(title_font_size)) {
      title_font_size <- title_font_size_default
    }
    if (is.na(other_font_size)) {
      other_font_size <- other_font_size_default
    }
  }, silent = TRUE)
  
  # Define the fonts
  # Windows
  if (system_os == "Windows") {
    garamond_title_bold = tkfont.create(family = "Garamond", size = title_font_size, weight = "bold")
    garamond_other_normal = tkfont.create(family = "Garamond", size = other_font_size, weight = "normal")
    arial_title_bold = tkfont.create(family = "Arial", size = title_font_size, weight = "bold")
    arial_other_normal = tkfont.create(family = "Arial", size = other_font_size, weight = "normal")
    trebuchet_title_bold = tkfont.create(family = "Trebuchet MS", size = title_font_size, weight = "bold")
    trebuchet_other_normal = tkfont.create(family = "Trebuchet MS", size = other_font_size, weight = "normal")
    trebuchet_other_bold = tkfont.create(family = "Trebuchet MS", size = other_font_size, weight = "bold")
    georgia_title_bold = tkfont.create(family = "Georgia", size = title_font_size, weight = "bold")
    georgia_other_normal = tkfont.create(family = "Georgia", size = other_font_size, weight = "normal")
    georgia_other_bold = tkfont.create(family = "Georgia", size = other_font_size, weight = "bold")
    # Use them in the GUI
    title_font = georgia_title_bold
    label_font = georgia_other_normal
    entry_font = georgia_other_normal
    button_font = georgia_other_bold
  } else if (system_os == "Linux") {
    #Linux
    # Ubuntu
    if (length(grep("Ubuntu", os_version, ignore.case = TRUE)) > 0) {
      # Define the fonts
      ubuntu_title_bold = tkfont.create(family = "Ubuntu", size = (title_font_size + 2), weight = "bold")
      ubuntu_other_normal = tkfont.create(family = "Ubuntu", size = (other_font_size + 1), weight = "normal")
      ubuntu_other_bold = tkfont.create(family = "Ubuntu", size = (other_font_size + 1), weight = "bold")
      liberation_title_bold = tkfont.create(family = "Liberation Sans", size = title_font_size, weight = "bold")
      liberation_other_normal = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "normal")
      liberation_other_bold = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "bold")
      bitstream_charter_title_bold = tkfont.create(family = "Bitstream Charter", size = title_font_size, weight = "bold")
      bitstream_charter_other_normal = tkfont.create(family = "Bitstream Charter", size = other_font_size, weight = "normal")
      bitstream_charter_other_bold = tkfont.create(family = "Bitstream Charter", size = other_font_size, weight = "bold")
      # Use them in the GUI
      title_font = ubuntu_title_bold
      label_font = ubuntu_other_normal
      entry_font = ubuntu_other_normal
      button_font = ubuntu_other_bold
    } else if (length(grep("Fedora", os_version, ignore.case = TRUE)) > 0) {
      # Fedora
      cantarell_title_bold = tkfont.create(family = "Cantarell", size = title_font_size, weight = "bold")
      cantarell_other_normal = tkfont.create(family = "Cantarell", size = other_font_size, weight = "normal")
      cantarell_other_bold = tkfont.create(family = "Cantarell", size = other_font_size, weight = "bold")
      liberation_title_bold = tkfont.create(family = "Liberation Sans", size = title_font_size, weight = "bold")
      liberation_other_normal = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "normal")
      liberation_other_bold = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "bold")
      # Use them in the GUI
      title_font = cantarell_title_bold
      label_font = cantarell_other_normal
      entry_font = cantarell_other_normal
      button_font = cantarell_other_bold
    } else {
      # Other linux distros
      liberation_title_bold = tkfont.create(family = "Liberation Sans", size = title_font_size, weight = "bold")
      liberation_other_normal = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "normal")
      liberation_other_bold = tkfont.create(family = "Liberation Sans", size = other_font_size, weight = "bold")
      # Use them in the GUI
      title_font = liberation_title_bold
      label_font = liberation_other_normal
      entry_font = liberation_other_normal
      button_font = liberation_other_bold
    }
  } else if (system_os == "Darwin") {
    # macOS
    helvetica_title_bold = tkfont.create(family = "Helvetica", size = title_font_size, weight = "bold")
    helvetica_other_normal = tkfont.create(family = "Helvetica", size = other_font_size, weight = "normal")
    helvetica_other_bold = tkfont.create(family = "Helvetica", size = other_font_size, weight = "bold")
    # Use them in the GUI
    title_font = helvetica_title_bold
    label_font = helvetica_other_normal
    entry_font = helvetica_other_normal
    button_font = helvetica_other_bold
  }
  
  
  # The "area" where we will put our input lines
  window <- tktoplevel(bg = "white")
  tkwm.resizable(window, FALSE, FALSE)
  #tkpack.propagate(window, FALSE)
  tktitle(window) <- "MASCOT OUTPUT PROCESSER"
  # Title label
  title_label <- tkbutton(window, text = "MASCOT\nOUTPUT\nPROCESSER", command = show_info_function, font = title_font, bg = "white", relief = "flat")
  #### Browse
  select_input_button <- tkbutton(window, text="IMPORT FILE...", command = file_import_function, font = button_font, bg = "white", width = 20)
  browse_output_button <- tkbutton(window, text="BROWSE\nOUTPUT FOLDER...", command = browse_output_function, font = button_font, bg = "white", width = 20)
  #### Entries
  output_file_type_export_entry <- tkbutton(window, text="Output\nfile type", command = output_file_type_export_choice, font = button_font, bg = "white", width = 20)
  # Buttons
  download_updates_button <- tkbutton(window, text="DOWNLOAD\nUPDATE...", command = download_updates_function, font = button_font, bg = "white", width = 20)
  run_mascot_output_modprocesser_function_button <- tkbutton(window, text = "RUN MASCOT OUTPUT\nPROCESSER", command = run_mascot_output_modprocesser_function, font = button_font, bg = "white", width = 20)
  end_session_button <- tkbutton(window, text="QUIT", command = end_session_function, font = button_font, bg = "white", width = 20)
  #### Displaying labels
  check_for_updates_value_label <- tklabel(window, text = check_for_updates_value, font = label_font, bg = "white", width = 20)
  output_file_type_export_value_label <- tklabel(window, text = output_file_type_export_value, font = label_font, bg = "white", width = 30)
  
  #### Geometry manager
  tkgrid(title_label, row = 1, column = 1, padx = c(20, 20), pady = c(20, 20))
  tkgrid(download_updates_button, row = 1, column = 2, padx = c(10, 10), pady = c(10, 10))
  tkgrid(check_for_updates_value_label, row = 1, column = 3, padx = c(10, 10), pady = c(10, 10))
  tkgrid(output_file_type_export_entry, row = 2, column = 1, padx = c(10, 10), pady = c(10, 10))
  tkgrid(output_file_type_export_value_label, row = 2, column = 2, padx = c(10, 10), pady = c(10, 10))
  tkgrid(browse_output_button, row = 3, column = 1, padx = c(10, 10), pady = c(10, 10))
  tkgrid(select_input_button, row = 3, column = 2, padx = c(10, 10), pady = c(10, 10))
  tkgrid(run_mascot_output_modprocesser_function_button, row = 3, column = 3, padx = c(10, 10), pady = c(10, 10))
  tkgrid(end_session_button, row = 4, column = 2, padx = c(10, 10), pady = c(10, 10))
  
  
  ################################################################################
}




# Run the function
mascot_output_processer()

