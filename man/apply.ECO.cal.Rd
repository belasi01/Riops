% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/apply.ECO.cal.R
\name{apply.ECO.cal}
\alias{apply.ECO.cal}
\title{Apply ECOVSF calibration}
\usage{
apply.ECO.cal(raw, dev.file = NA, dark.file = NA, ECO.type = "VSF3",
  ECO.bands = NA)
}
\arguments{
\item{raw}{is a list of raw data from an ECO VSF, BB9 (or BB3 not implemented yet) with measurements}

\item{dev.file}{is the full path for the device file needed to convert the raw to calibrated data. 
This field is mandatory}

\item{dark.file}{is the full path for file containing dark measurements. 
Must be consistent with the ECO.type VSF3, BB9 (or BB3 not implemented yet)}

\item{ECO.type}{is a character string for the type of ECO meter: BB9, BB3, VSF3.
(Default is VSF3)}

\item{ECO.bands}{must be provided if ECO.type == VSF3. It is a character string indicating the bands (BLUE, GREEN and RED), 
i.e. either "B", "G", "R" or "BG", or "BGR".}
}
\value{
It returns a list with raw data and calibrated VSF (uncorrected).
}
\description{
Apply ECOVSF calibration
}
\author{
Simon Belanger
}
