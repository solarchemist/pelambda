#' Extract data from PerkinElmer spectrum file
#'
#' Reads SP spectrum (ASCII text file) into R dataframe.
#' Preserves PE parameters (metadata) in the returned dataframe.
#' Note that x-axis is assumed to be wavelength in nanometres.
#'
#' @param path path to spectrum file
#' @param sampleid string identifying the sample (optional)
#'
#' @return Dataframe with the following columns:
#'    $ substrateid : chr, included for legacy reasons
#'    $ sampleid    : chr, see https://github.com/solarchemist/R-common
#'    $ wavelength  : num, x column from data, wavelength/nm
#'    $ intensity   : num, y column from data
#'    $ brand       : chr, instrument metadata
#'    $ method      : chr, instrument metadata
#'    $ spectrum    : chr, instrument metadata
#'    $ ascii       : chr, instrument metadata
#'    $ peds        : chr, instrument metadata
#'    $ version     : chr, instrument metadata
#'    $ filename    : chr, input filename
#'    $ startdate   : chr, measurement start date
#'    $ starttime   : chr, measurement start time
#'    $ enddate     : chr, measurement stop date
#'    $ endtime     : chr, measurement stop time
#'    $ xunit       : chr, unit of x-axis (recorded by instrument software)
#'    $ yunit       : chr, unit of y-axis (recorded by instrument software)
#'    $ xstart      : chr, start wavelength (PE usually scans from low energy to high, so this is the max wavelength)
#'    $ xstep       : num, step size/nm
#'    $ nobs        : num, number of recorded data points
#'    $ duration    : num, length of measurement in seconds
#' @export
sp2df <- function(path, sampleid = "") {

   if (sampleid == "") {
      # assume the user did not set sampleid
      this.sampleid <- common::ProvideSampleId(path)
   } else {
      # assume the user explicitly specified sampleid, use it
      this.sampleid <- sampleid
   }
   # Create substrateid for the current job (based on the folder name)
   this.substrateid <- common::ProvideSampleId(path, implementation = "dirname")

   # Read the input file
   infile <- file(path, "r")
   # Note that readLines apparently completely skips empty lines.
   # That causes line numbers to not match between source and f vector.
   # n = -1 to read all lines from input file
   f <- readLines(infile, n = -1)
   close(infile)

   sp.dividers <-
      data.frame(
         label = c("START", "HDR", "GR", "DATA"),
         rexp = c("", "^\\#HDR", "^\\#GR", "^\\#DATA"),
         row = 1)
   sp.labels <-
      c("brand", "method", "spectrum",
        "ascii", "peds", "version", "filename",
        "startdate", "starttime", "enddate", "endtime",
        "xunit", "yunit", "xstart", "xstep",
        "nobs")

   for (i in 1:dim(sp.dividers)[1]) {
      if (sp.dividers$rexp[i] != "") {
         sp.dividers$row[i] <- grep(pattern = sp.dividers$rexp[i], x = f)
      }
   }

   params.df <-
      # t() is a matrix transpose function
      data.frame(
         t(
            c(
               # From the START segment, we want the
               # first, third, fourth, fifth, sixth, and seventh row
               # From the HDR segment, we want no rows
               unlist(strsplit(f[sp.dividers$row[1]:sp.dividers$row[2]][1], "\\s+")),
               f[sp.dividers$row[1]:sp.dividers$row[2]][c(3,4,5,6,7)],
               # From the GR segment, we want the
               # first, second, fifth, sixth, and seventh row
               f[(sp.dividers$row[3]+1):sp.dividers$row[4]][c(1,2,5,6,7)]
            )
         )
      )
   names(params.df) <- sp.labels
   # calculate measurement duration in seconds using start/end date-time
   time.start <- lubridate::ymd_hms(paste(params.df$startdate, params.df$starttime))
   time.stop  <- lubridate::ymd_hms(paste(params.df$enddate, params.df$endtime))
   params.df$duration <-
      lubridate::time_length(
         x = lubridate::interval(time.start, time.stop),
         unit = "second"
      )
   # set column type
   params.df$xstart <- as.numeric(params.df$xstart)
   params.df$xstep <- as.numeric(params.df$xstep)
   params.df$nobs <- as.numeric(params.df$nobs)

   # data
   data.raw <- f[(sp.dividers$row[4]+1):length(f)]
   zz <- textConnection(data.raw, "r")
   data.mtx <-
      matrix(
         scan(
            zz,
            what = numeric()
         ),
         ncol = 2,
         byrow = TRUE
      )
   colnames(data.mtx) <- c("wavelength", "intensity")
   close(zz)

   data.df <-
      data.frame(
         substrateid = this.substrateid,
         sampleid = this.sampleid,
         data.mtx,
         params.df
      )

   return(data.df)
}
