% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trafo_on_repeated_param.R
\name{trafo_on_repeated_param}
\alias{trafo_on_repeated_param}
\title{A helper to create trafo functions for repeated parameters.}
\usage{
trafo_on_repeated_param(fun, repeated_param_id,
  additional_params = character(0L))
}
\arguments{
\item{fun}{[\code{function}]\cr
A trafo function with the arguments x, dict, tags}

\item{repeated_param_id}{[\code{character(1)}]\cr
The id of the parameter the that is repeated_}

\item{additional_params}{[\code{character}]\cr
Additional parameter ids that will be passed inside the \code{dict} object.}
}
\value{
function
}
\description{
A helper to create trafo functions for repeated parameters.
}
